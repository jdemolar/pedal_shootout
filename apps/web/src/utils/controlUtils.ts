import { Jack } from './transformers';
import { ControlConnection } from '../types/connections';
import { ConnectionValidation, ConnectionWarning } from './connectionValidation';

// --- Jack filtering helpers ---

const CONTROL_CATEGORIES = ['expression', 'aux', 'cv'];

export function getControlInputJacks(row: { jacks: Jack[] }): Jack[] {
  return row.jacks.filter(j =>
    CONTROL_CATEGORIES.includes(j.category ?? '') &&
    (j.direction === 'input' || j.direction === 'bidirectional')
  );
}

export function getControlOutputJacks(row: { jacks: Jack[] }): Jack[] {
  return row.jacks.filter(j =>
    CONTROL_CATEGORIES.includes(j.category ?? '') &&
    (j.direction === 'output' || j.direction === 'bidirectional') &&
    j.connector_type !== 'USB-A'
  );
}

export function hasControlJacks(row: { jacks: Jack[] }): boolean {
  return row.jacks.some(j => CONTROL_CATEGORIES.includes(j.category ?? ''));
}

// --- Category detection ---

export function inferControlType(jack: { category: string | null }): ControlConnection['controlType'] {
  switch (jack.category) {
    case 'expression': return 'expression';
    case 'aux': return 'aux_switch';
    case 'cv': return 'cv';
    default: return 'other';
  }
}

// --- Connector type helpers ---

export function isTrsConnector(connectorType: string | null): boolean {
  if (!connectorType) return false;
  const lower = connectorType.toLowerCase();
  return lower.includes('trs');
}

// --- Connection validation ---

export function validateControlConnection(
  sourceJack: { category: string | null; connector_type: string | null; jack_name: string | null },
  targetJack: { category: string | null; connector_type: string | null; jack_name: string | null },
  existingConnections: ControlConnection[],
  sourceInstanceId: string,
  targetInstanceId: string,
  sourceJackId?: number,
  targetJackId?: number,
): ConnectionValidation {
  const warnings: ConnectionWarning[] = [];

  // Self-connection (error)
  if (sourceInstanceId === targetInstanceId) {
    warnings.push({
      key: 'control:self-connection',
      severity: 'error',
      message: 'Cannot connect a device to itself.',
    });
  }

  // Category mismatch (error)
  if (sourceJack.category && targetJack.category && sourceJack.category !== targetJack.category) {
    warnings.push({
      key: 'control:category-mismatch',
      severity: 'error',
      message: `Category mismatch: ${sourceJack.category} output cannot connect to ${targetJack.category} input.`,
    });
  }

  // Shared input (warning) — target jack already has a connection
  if (targetJackId != null) {
    const otherToSame = existingConnections.filter(
      c => c.targetJackId === targetJackId && c.targetInstanceId === targetInstanceId,
    );
    if (otherToSame.length > 0) {
      warnings.push({
        key: 'control:shared-input',
        severity: 'warning',
        message: 'This input already has a connection. Multiple control sources on one input may cause conflicts.',
      });
    }
  }

  // Connector type mismatch (warning) — different connector types need an adapter
  if (sourceJack.connector_type && targetJack.connector_type &&
      sourceJack.connector_type !== targetJack.connector_type) {
    warnings.push({
      key: 'control:connector-mismatch',
      severity: 'warning',
      message: `Connector mismatch: ${sourceJack.connector_type} → ${targetJack.connector_type}. An adapter is needed.`,
      adapterImplication: {
        fromConnectorType: sourceJack.connector_type,
        toConnectorType: targetJack.connector_type,
        description: `${sourceJack.connector_type} to ${targetJack.connector_type} adapter`,
      },
    });
  }

  // Polarity unknown (info) — TRS connection where polarity hasn't been confirmed
  if (!warnings.some(w => w.severity === 'error') &&
      (isTrsConnector(sourceJack.connector_type) || isTrsConnector(targetJack.connector_type))) {
    warnings.push({
      key: 'control:polarity-unknown',
      severity: 'info',
      message: 'TRS connection — confirm polarity (tip-active vs ring-active) to ensure compatibility.',
    });
  }

  const hasError = warnings.some(w => w.severity === 'error');
  const hasWarning = warnings.some(w => w.severity === 'warning' || w.severity === 'info');

  return {
    status: hasError ? 'error' : hasWarning ? 'warning' : 'valid',
    warnings,
  };
}
