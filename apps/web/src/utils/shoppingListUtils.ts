import { PowerConnection } from '../context/WorkbenchContext';
import { AudioConnection, MidiConnection, ControlConnection } from '../types/connections';
import { Jack } from './transformers';

export type CableCategory = 'audio' | 'power' | 'midi' | 'control';

export interface CableRequirement {
  category: CableCategory;
  sourceConnectorType: string;
  targetConnectorType: string;
  label: string;
  quantity: number;
  connectionIds: string[];
  requiresCustomCable: boolean;
  notes: string[];
}

export interface ShoppingList {
  cables: CableRequirement[];
  summary: {
    totalCables: number;
    totalCustomCables: number;
    byCategory: Record<CableCategory, number>;
  };
}

/**
 * Determines whether a cable connecting two different connector types
 * would require a custom/non-standard cable.
 */
export function isCustomCable(
  sourceConnectorType: string | null,
  targetConnectorType: string | null,
): boolean {
  if (!sourceConnectorType || !targetConnectorType) return false;
  return sourceConnectorType !== targetConnectorType;
}

/**
 * Derives a human-readable cable label from connector types and category.
 *
 * Rules:
 * - Matching connectors: "{connector} {subType} cable" (e.g., '1/4" TS patch cable')
 * - Mismatched connectors: "{source} to {target} {subType} cable"
 * - Null/unknown connectors: "{category} cable (connector unknown)"
 */
export function deriveCableLabel(
  sourceConnectorType: string | null,
  targetConnectorType: string | null,
  category: CableCategory,
  controlSubType?: string,
): string {
  const suffix = controlSubType || (category === 'audio' ? 'patch' : category === 'midi' ? 'MIDI' : category === 'power' ? 'DC power' : 'control');

  if (!sourceConnectorType || !targetConnectorType) {
    return `${category} cable (connector unknown)`;
  }

  if (sourceConnectorType === targetConnectorType) {
    return `${sourceConnectorType} ${suffix} cable`;
  }

  return `${sourceConnectorType} to ${targetConnectorType} ${suffix} cable`;
}

/** Grouping key for deduplicating identical cable types. */
function cableKey(category: CableCategory, source: string, target: string): string {
  return `${category}::${source}::${target}`;
}

/** Map controlType to a user-friendly sub-type label. */
function controlSubTypeLabel(controlType: string): string {
  switch (controlType) {
    case 'expression': return 'expression';
    case 'aux_switch': return 'auxiliary';
    case 'cv': return 'CV';
    default: return 'control';
  }
}

function isTrsConnector(connectorType: string | null): boolean {
  if (!connectorType) return false;
  return connectorType.toLowerCase().includes('trs');
}

/**
 * Detect TRS-to-2×TS insert cable patterns in audio connections.
 * When two stereo connections share the same jack on one side (TRS)
 * and use different jacks on the other (TS), they represent a single
 * insert cable rather than two separate patch cables.
 */
function consolidateInsertCables(
  audioConnections: AudioConnection[],
  jackMap: Map<number, Jack>,
  grouped: Map<string, CableRequirement>,
): void {
  const stereoConns = audioConnections.filter(c => c.signalMode === 'stereo');

  // Group by jack ID + instance ID — jack IDs are product-level, so two
  // instances of the same product share IDs. Without the instance ID in the
  // key, connections to different instances get incorrectly merged.
  const bySourceKey = new Map<string, { jackId: number | string; conns: AudioConnection[] }>();
  const byTargetKey = new Map<string, { jackId: number | string; conns: AudioConnection[] }>();
  for (const conn of stereoConns) {
    const srcKey = `${conn.sourceInstanceId}::${conn.sourceJackId}`;
    const srcEntry = bySourceKey.get(srcKey) ?? { jackId: conn.sourceJackId, conns: [] };
    srcEntry.conns.push(conn);
    bySourceKey.set(srcKey, srcEntry);

    const tgtKey = `${conn.targetInstanceId}::${conn.targetJackId}`;
    const tgtEntry = byTargetKey.get(tgtKey) ?? { jackId: conn.targetJackId, conns: [] };
    tgtEntry.conns.push(conn);
    byTargetKey.set(tgtKey, tgtEntry);
  }

  bySourceKey.forEach(({ jackId, conns }) => {
    if (conns.length !== 2) return;
    const jack = typeof jackId === 'number' ? jackMap.get(jackId) : null;
    if (!jack || !isTrsConnector(jack.connector_type)) return;
    mergeAsInsertCable(conns, 'source', jack.connector_type!, jackMap, grouped);
  });

  byTargetKey.forEach(({ jackId, conns }) => {
    if (conns.length !== 2) return;
    const jack = typeof jackId === 'number' ? jackMap.get(jackId) : null;
    if (!jack || !isTrsConnector(jack.connector_type)) return;
    mergeAsInsertCable(conns, 'target', jack.connector_type!, jackMap, grouped);
  });
}

function mergeAsInsertCable(
  conns: AudioConnection[],
  sharedSide: 'source' | 'target',
  trsConnectorType: string,
  jackMap: Map<number, Jack>,
  grouped: Map<string, CableRequirement>,
): void {
  const otherJackId = sharedSide === 'source' ? conns[0].targetJackId : conns[0].sourceJackId;
  const otherJack = typeof otherJackId === 'number' ? jackMap.get(otherJackId) : null;
  const tsConnectorType = otherJack?.connector_type ?? 'unknown';

  // Remove the two individual cable entries
  for (const conn of conns) {
    const keys = Array.from(grouped.keys());
    for (const key of keys) {
      const req = grouped.get(key)!;
      const idx = req.connectionIds.indexOf(conn.id);
      if (idx !== -1) {
        req.quantity -= 1;
        req.connectionIds.splice(idx, 1);
        if (req.quantity <= 0) grouped.delete(key);
        break;
      }
    }
  }

  const insertKey = `audio::insert::${trsConnectorType}::${tsConnectorType}`;
  const label = `${trsConnectorType} to 2\u00D7${tsConnectorType} insert cable`;
  grouped.set(insertKey, {
    category: 'audio',
    sourceConnectorType: sharedSide === 'source' ? trsConnectorType : tsConnectorType,
    targetConnectorType: sharedSide === 'source' ? tsConnectorType : trsConnectorType,
    label,
    quantity: 1,
    connectionIds: conns.map(c => c.id),
    requiresCustomCable: true,
    notes: ['Insert cable \u2014 single TRS splits to two TS connections'],
  });
}

interface ConnectionBase {
  id: string;
  sourceJackId: number | string;
  targetJackId: number | string;
}

function processConnection(
  conn: ConnectionBase,
  category: CableCategory,
  jackMap: Map<number, Jack>,
  grouped: Map<string, CableRequirement>,
  controlSubType?: string,
): void {
  const sourceJack = typeof conn.sourceJackId === 'number' ? jackMap.get(conn.sourceJackId) : null;
  const targetJack = typeof conn.targetJackId === 'number' ? jackMap.get(conn.targetJackId) : null;

  const sourceCT = sourceJack?.connector_type ?? null;
  const targetCT = targetJack?.connector_type ?? null;

  const label = deriveCableLabel(sourceCT, targetCT, category, controlSubType);
  const custom = isCustomCable(sourceCT, targetCT);

  // Normalize key — use empty string for nulls
  const key = cableKey(category, sourceCT ?? '', targetCT ?? '');
  const existing = grouped.get(key);

  if (existing) {
    existing.quantity += 1;
    existing.connectionIds.push(conn.id);
  } else {
    const notes: string[] = [];
    if (custom) {
      notes.push('Mismatched connectors \u2014 custom cable or adapter needed');
    }
    if (!sourceCT || !targetCT) {
      notes.push('Connector type unknown for one or both ends');
    }
    grouped.set(key, {
      category,
      sourceConnectorType: sourceCT ?? 'unknown',
      targetConnectorType: targetCT ?? 'unknown',
      label,
      quantity: 1,
      connectionIds: [conn.id],
      requiresCustomCable: custom,
      notes,
    });
  }
}

/**
 * Computes a shopping list of cable requirements from all workbench connections.
 *
 * Cable quantity comes from connection count (instance-scoped), not jack count
 * (product-scoped). The jackMap is only used for metadata lookup.
 */
export function computeShoppingList(
  powerConnections: PowerConnection[],
  audioConnections: AudioConnection[],
  midiConnections: MidiConnection[],
  controlConnections: ControlConnection[],
  jackMap: Map<number, Jack>,
): ShoppingList {
  const grouped = new Map<string, CableRequirement>();

  for (const conn of powerConnections) {
    processConnection(conn, 'power', jackMap, grouped);
  }

  for (const conn of audioConnections) {
    processConnection(conn, 'audio', jackMap, grouped);
  }
  consolidateInsertCables(audioConnections, jackMap, grouped);

  for (const conn of midiConnections) {
    processConnection(conn, 'midi', jackMap, grouped);
  }

  for (const conn of controlConnections) {
    processConnection(conn, 'control', jackMap, grouped, controlSubTypeLabel(conn.controlType));
  }

  const cables = Array.from(grouped.values());

  const byCategory: Record<CableCategory, number> = { audio: 0, power: 0, midi: 0, control: 0 };
  let totalCables = 0;
  let totalCustomCables = 0;

  for (const cable of cables) {
    totalCables += cable.quantity;
    byCategory[cable.category] += cable.quantity;
    if (cable.requiresCustomCable) {
      totalCustomCables += cable.quantity;
    }
  }

  return {
    cables,
    summary: {
      totalCables,
      totalCustomCables,
      byCategory,
    },
  };
}
