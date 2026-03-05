/**
 * Shared validation types for all connection categories (power, audio, MIDI, control).
 *
 * Validators in powerUtils, audioUtils, midiUtils, and controlUtils all return
 * ConnectionValidation so the UI can handle warnings uniformly across categories.
 */

export type ValidationSeverity = 'error' | 'warning' | 'info';

export interface ConnectionWarning {
  /** Stable identifier used to track acknowledgements. Format: `category:rule-name`. */
  key: string;
  severity: ValidationSeverity;
  message: string;
  /** Present when this warning implies a physical adapter is needed. */
  adapterImplication?: {
    fromConnectorType: string;
    toConnectorType: string;
    description: string;
  };
}

export interface ConnectionValidation {
  status: 'valid' | 'warning' | 'error';
  warnings: ConnectionWarning[];
}

export interface DirectedEdge {
  sourceInstanceId: string;
  targetInstanceId: string;
}

export function wouldCreateCycle(
  sourceInstanceId: string,
  targetInstanceId: string,
  existingConnections: ReadonlyArray<DirectedEdge>,
): boolean {
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
