import { Jack } from './transformers';
import { AudioConnection } from '../types/connections';
import { ConnectionValidation, ConnectionWarning } from './connectionValidation';

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

// --- Cycle detection ---

export function wouldCreateCycle(
  sourceInstanceId: string,
  targetInstanceId: string,
  existingConnections: AudioConnection[],
): boolean {
  // BFS: can we reach sourceInstanceId starting from targetInstanceId?
  const visited = new Set<string>();
  const queue: string[] = [targetInstanceId];

  while (queue.length > 0) {
    const current = queue.shift()!;
    if (current === sourceInstanceId) return true;
    if (visited.has(current)) continue;
    visited.add(current);

    for (const conn of existingConnections) {
      if (conn.sourceInstanceId === current && !visited.has(conn.targetInstanceId)) {
        queue.push(conn.targetInstanceId);
      }
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
): ConnectionValidation {
  const warnings: ConnectionWarning[] = [];

  // Circular connection check (error)
  if (wouldCreateCycle(sourceInstanceId, targetInstanceId, existingConnections)) {
    warnings.push({
      key: 'audio:circular-connection',
      severity: 'error',
      message: 'This connection would create a feedback loop in the signal chain.',
    });
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
