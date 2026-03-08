import { Jack } from './transformers';
import { AudioConnection } from '../types/connections';
import { ConnectionValidation, ConnectionWarning, wouldCreateCycle } from './connectionValidation';

// --- Jack filtering helpers ---

export function getAudioInputJacks(row: { jacks: Jack[] }): Jack[] {
  return row.jacks.filter(j => j.category === 'audio' && j.direction === 'input');
}

export function getAudioOutputJacks(row: { jacks: Jack[] }): Jack[] {
  return row.jacks.filter(j => j.category === 'audio' && j.direction === 'output');
}

export function hasAudioJacks(row: { jacks: Jack[] }): boolean {
  return row.jacks.some(j => j.category === 'audio');
}

export function getStereoPartner(jack: Jack, allJacks: Jack[]): Jack | undefined {
  if (!jack.group_id) return undefined;
  return allJacks.find(j => j.id !== jack.id && j.group_id === jack.group_id);
}

// --- Send/return loop detection ---

/**
 * Find the existing path from `fromId` to `toId` via BFS.
 * Returns the ordered list of connections forming the path, or null if none.
 */
function findCyclePath(
  fromId: string,
  toId: string,
  connections: AudioConnection[],
): AudioConnection[] | null {
  if (fromId === toId) return [];
  const visited = new Set<string>();
  const queue: Array<[string, AudioConnection[]]> = [[fromId, []]];

  while (queue.length > 0) {
    const [current, path] = queue.shift()!;
    if (visited.has(current)) continue;
    visited.add(current);

    for (const conn of connections) {
      if (conn.sourceInstanceId === current) {
        const newPath = [...path, conn];
        if (conn.targetInstanceId === toId) return newPath;
        if (!visited.has(conn.targetInstanceId)) {
          queue.push([conn.targetInstanceId, newPath]);
        }
      }
    }
  }

  return null;
}

/**
 * Check if a detected cycle is actually a send/return loop topology.
 *
 * Traces the full cycle path and checks every node — not just the endpoints
 * of the new connection. A send/return loop exists when any device in the
 * cycle is entered and exited through jacks that share a group_id (a paired
 * send/return). This works regardless of how many pedals are between send
 * and return, and correctly identifies loops when the new connection is
 * between two pedals inside the loop (where the loop switcher is an
 * intermediate node).
 */
function isSendReturnLoop(
  sourceInstanceId: string,
  targetInstanceId: string,
  newSourceJackId: number | string,
  newTargetJackId: number | string,
  existingConnections: AudioConnection[],
  jackLookup: ReadonlyMap<number, { group_id: string | null }>,
): boolean {
  // Find the existing path that completes the cycle: target → ... → source
  const path = findCyclePath(targetInstanceId, sourceInstanceId, existingConnections);
  if (!path) return false;

  // Build the full cycle as ordered edges
  type CycleEdge = { exitJackId: number | string; entryJackId: number | string };
  const cycle: CycleEdge[] = [
    { exitJackId: newSourceJackId, entryJackId: newTargetJackId },
    ...path.map(c => ({ exitJackId: c.sourceJackId, entryJackId: c.targetJackId })),
  ];

  // For each node, check if its entry jack (from previous edge) and exit jack
  // (from current edge) share a group_id — indicating a paired send/return.
  const len = cycle.length;
  for (let i = 0; i < len; i++) {
    const entryJackId = cycle[(i + len - 1) % len].entryJackId;
    const exitJackId = cycle[i].exitJackId;

    const entryJack = typeof entryJackId === 'number' ? jackLookup.get(entryJackId) : null;
    const exitJack = typeof exitJackId === 'number' ? jackLookup.get(exitJackId) : null;

    if (entryJack?.group_id && exitJack?.group_id && entryJack.group_id === exitJack.group_id) {
      return true;
    }
  }

  return false;
}

// --- Connection validation ---

export function validateAudioConnection(
  sourceJack: { connector_type: string | null; group_id: string | null; impedance_ohms: number | null },
  targetJack: { connector_type: string | null; group_id: string | null; impedance_ohms: number | null },
  sourceSignalMode: 'mono' | 'stereo',
  targetSignalMode: 'mono' | 'stereo',
  existingConnections: AudioConnection[],
  sourceInstanceId: string,
  targetInstanceId: string,
  newSourceJackId: number | string,
  newTargetJackId: number | string,
  jackLookup: ReadonlyMap<number, { group_id: string | null }>,
): ConnectionValidation {
  const warnings: ConnectionWarning[] = [];

  // Circular connection check (error, or info if send/return loop)
  if (wouldCreateCycle(sourceInstanceId, targetInstanceId, existingConnections)) {
    if (isSendReturnLoop(sourceInstanceId, targetInstanceId, newSourceJackId, newTargetJackId, existingConnections, jackLookup)) {
      warnings.push({
        key: 'audio:send-return-loop',
        severity: 'info',
        message: 'This connection completes a send/return loop \u2014 this is expected topology.',
      });
    } else {
      warnings.push({
        key: 'audio:circular-connection',
        severity: 'error',
        message: 'This connection would create a feedback loop in the signal chain.',
      });
    }
  }

  // Connector mismatch (warning + adapter)
  if (
    sourceJack.connector_type &&
    targetJack.connector_type &&
    sourceJack.connector_type !== targetJack.connector_type
  ) {
    warnings.push({
      key: 'audio:connector-mismatch',
      severity: 'warning',
      message: `Connector mismatch: ${sourceJack.connector_type} → ${targetJack.connector_type}. An adapter cable is needed.`,
      adapterImplication: {
        fromConnectorType: sourceJack.connector_type,
        toConnectorType: targetJack.connector_type,
        description: `${sourceJack.connector_type} to ${targetJack.connector_type} adapter`,
      },
    });
  }

  // Mono → stereo
  if (sourceSignalMode === 'mono' && targetSignalMode === 'stereo') {
    warnings.push({
      key: 'audio:mono-to-stereo',
      severity: 'warning',
      message: 'Connecting a mono output to a stereo input — the right channel will be silent.',
    });
  }

  // Stereo → mono
  if (sourceSignalMode === 'stereo' && targetSignalMode === 'mono') {
    warnings.push({
      key: 'audio:stereo-to-mono',
      severity: 'warning',
      message: 'Connecting a stereo output to a mono input — the signal will be summed or the left channel only will pass.',
    });
  }

  // Impedance mismatch
  if (
    sourceJack.impedance_ohms !== null &&
    targetJack.impedance_ohms !== null &&
    targetJack.impedance_ohms / sourceJack.impedance_ohms > 100
  ) {
    warnings.push({
      key: 'audio:impedance-mismatch',
      severity: 'warning',
      message: `Impedance mismatch: source ${sourceJack.impedance_ohms}Ω → target ${targetJack.impedance_ohms}Ω. Signal loss may occur.`,
    });
  }

  const hasError = warnings.some(w => w.severity === 'error');
  const hasWarning = warnings.some(w => w.severity === 'warning');

  return {
    status: hasError ? 'error' : hasWarning ? 'warning' : 'valid',
    warnings,
  };
}
