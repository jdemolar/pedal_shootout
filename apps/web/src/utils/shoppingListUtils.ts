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
