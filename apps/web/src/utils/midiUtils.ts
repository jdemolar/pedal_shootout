import { Jack } from './transformers';
import { MidiConnection } from '../types/connections';
import { ConnectionValidation, ConnectionWarning, wouldCreateCycle } from './connectionValidation';

// --- Jack filtering helpers ---

export function getMidiInputJacks(row: { jacks: Jack[] }): Jack[] {
  return row.jacks.filter(j => j.category === 'midi' && (j.direction === 'input' || j.direction === 'bidirectional'));
}

export function getMidiOutputJacks(row: { jacks: Jack[] }): Jack[] {
  return row.jacks.filter(j => j.category === 'midi' && (j.direction === 'output' || j.direction === 'bidirectional'));
}

export function hasMidiJacks(row: { jacks: Jack[] }): boolean {
  return row.jacks.some(j => j.category === 'midi');
}

// --- Connector type helpers ---

export function isTrsMidiConnector(connectorType: string | null): boolean {
  if (!connectorType) return false;
  const lower = connectorType.toLowerCase();
  return lower.includes('trs');
}

export function is5PinDinConnector(connectorType: string | null): boolean {
  if (!connectorType) return false;
  const lower = connectorType.toLowerCase();
  return lower.includes('5-pin') || lower.includes('din');
}

// --- Chain depth ---

export function getChainDepth(
  instanceId: string,
  connections: MidiConnection[],
): number {
  // Walk backwards from instanceId toward root nodes (nodes with no incoming connections).
  // Returns the number of hops from the closest root.
  const visited = new Set<string>();
  let depth = 0;
  let current = instanceId;

  while (true) {
    visited.add(current);
    const incoming = connections.find(c => c.targetInstanceId === current);
    if (!incoming || visited.has(incoming.sourceInstanceId)) break;
    depth++;
    current = incoming.sourceInstanceId;
  }

  return depth;
}

// --- Connection validation ---

export function validateMidiConnection(
  sourceJack: { connector_type: string | null; jack_name: string | null },
  targetJack: { connector_type: string | null; jack_name: string | null },
  existingConnections: MidiConnection[],
  sourceInstanceId: string,
  targetInstanceId: string,
  sourceJackId?: number,
  targetJackId?: number,
): ConnectionValidation {
  const warnings: ConnectionWarning[] = [];

  // Shared output jack — MIDI can't be passively split (warning)
  if (sourceJackId != null) {
    const otherFromSame = existingConnections.filter(
      c => c.sourceJackId === sourceJackId && c.sourceInstanceId === sourceInstanceId,
    );
    if (otherFromSame.length > 0) {
      warnings.push({
        key: 'midi:shared-output',
        severity: 'warning',
        message: 'This MIDI output already has a connection. MIDI signals cannot be passively split — a MIDI thru box or splitter is needed.',
      });
    }
  }

  // Shared input jack — only one source can drive a MIDI input (warning)
  if (targetJackId != null) {
    const otherToSame = existingConnections.filter(
      c => c.targetJackId === targetJackId && c.targetInstanceId === targetInstanceId,
    );
    if (otherToSame.length > 0) {
      warnings.push({
        key: 'midi:shared-input',
        severity: 'warning',
        message: 'This MIDI input already has a connection. Only one source can drive a MIDI input.',
      });
    }
  }

  // Circular connection check (warning — MIDI loops are common, e.g. controller→chain→controller input)
  if (wouldCreateCycle(sourceInstanceId, targetInstanceId, existingConnections)) {
    warnings.push({
      key: 'midi:circular',
      severity: 'warning',
      message: 'This connection creates a circular MIDI path. This is normal for chains that return to a controller input.',
    });
  }

  // 5-pin DIN ↔ 3.5mm TRS mismatch (warning + adapter)
  const srcIs5Pin = is5PinDinConnector(sourceJack.connector_type);
  const tgtIs5Pin = is5PinDinConnector(targetJack.connector_type);
  const srcIsTrs = isTrsMidiConnector(sourceJack.connector_type);
  const tgtIsTrs = isTrsMidiConnector(targetJack.connector_type);

  if ((srcIs5Pin && tgtIsTrs) || (srcIsTrs && tgtIs5Pin)) {
    warnings.push({
      key: 'midi:din-to-trs',
      severity: 'warning',
      message: `Connector mismatch: ${sourceJack.connector_type} → ${targetJack.connector_type}. An adapter is needed.`,
      adapterImplication: {
        fromConnectorType: sourceJack.connector_type!,
        toConnectorType: targetJack.connector_type!,
        description: `${sourceJack.connector_type} to ${targetJack.connector_type} MIDI adapter`,
      },
    });
  }

  // Long chain warning (info when total chain depth > 4)
  const backDepth = getChainDepth(sourceInstanceId, existingConnections) + 1;
  // Walk forward from target to find remaining chain length
  let forwardDepth = 0;
  {
    const visited = new Set<string>();
    let current = targetInstanceId;
    while (true) {
      visited.add(current);
      const outgoing = existingConnections.find(c => c.sourceInstanceId === current);
      if (!outgoing || visited.has(outgoing.targetInstanceId)) break;
      forwardDepth++;
      current = outgoing.targetInstanceId;
    }
  }
  const totalChainDepth = backDepth + forwardDepth;
  if (totalChainDepth > 4) {
    warnings.push({
      key: 'midi:long-chain',
      severity: 'info',
      message: `Total MIDI chain depth is ${totalChainDepth}. Consider a MIDI thru box for chains longer than 4 devices.`,
    });
  }

  const hasError = warnings.some(w => w.severity === 'error');
  const hasWarning = warnings.some(w => w.severity === 'warning' || w.severity === 'info');

  return {
    status: hasError ? 'error' : hasWarning ? 'warning' : 'valid',
    warnings,
  };
}
