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
 * Check if a detected cycle is actually a send/return loop topology.
 *
 * A send/return loop exists when the cycle enters and exits the same device
 * through jacks that share a group_id (a paired send/return). This works
 * regardless of how many pedals are in the chain between send and return.
 */
function isSendReturnLoop(
  sourceInstanceId: string,
  targetInstanceId: string,
  newSourceJackId: number | string,
  newTargetJackId: number | string,
  existingConnections: AudioConnection[],
  jackLookup: ReadonlyMap<number, { group_id: string | null }>,
): boolean {
  // Check the new connection's TARGET instance (where the cycle closes).
  // The new connection enters this device via newTargetJackId.
  // Look for existing connections where this device is the source (the exit point).
  const entryJack = typeof newTargetJackId === 'number' ? jackLookup.get(newTargetJackId) : null;
  if (entryJack?.group_id) {
    for (const conn of existingConnections) {
      if (conn.sourceInstanceId === targetInstanceId) {
        const exitJack = typeof conn.sourceJackId === 'number' ? jackLookup.get(conn.sourceJackId) : null;
        if (exitJack?.group_id && exitJack.group_id === entryJack.group_id) {
          return true;
        }
      }
    }
  }

  // Check the new connection's SOURCE instance (the other closing point).
  // The new connection exits this device via newSourceJackId.
  // Look for existing connections where this device is the target (the entry point).
  const exitJack = typeof newSourceJackId === 'number' ? jackLookup.get(newSourceJackId) : null;
  if (exitJack?.group_id) {
    for (const conn of existingConnections) {
      if (conn.targetInstanceId === sourceInstanceId) {
        const connEntryJack = typeof conn.targetJackId === 'number' ? jackLookup.get(conn.targetJackId) : null;
        if (connEntryJack?.group_id && connEntryJack.group_id === exitJack.group_id) {
          return true;
        }
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
