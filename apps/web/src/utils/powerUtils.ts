/**
 * Shared normalization and validation utilities for power connections.
 * Used by PowerView (workbench) and PowerSupplies (catalog filter).
 */
import { ConnectionWarning, ConnectionValidation } from './connectionValidation';

/** Lowercase + replace spaces with hyphens: "Center Negative" -> "center-negative" */
export function normalizePolarity(p: string): string {
  return p.toLowerCase().replace(/\s+/g, '-');
}

/** Trim whitespace for clean connector comparison */
export function normalizeConnector(c: string): string {
  return c.trim();
}

/** Strip trailing DC/AC, spaces, and 'V' to get bare number(s): "9V DC" -> "9", "9V/12V/18V" -> "9/12/18" */
export function normalizeVoltage(raw: string): string {
  return raw
    .replace(/\s*(DC|AC)\s*/gi, '')
    .replace(/V/gi, '')
    .trim();
}

/** Split a jack's voltage string into individual numeric tokens: "9V/12V/18V" -> ["9","12","18"] */
export function voltageTokensFromJack(voltage: string): string[] {
  const normalized = normalizeVoltage(voltage);
  return normalized.split('/').map(t => t.trim()).filter(t => t.length > 0);
}

/** Check if any supply token satisfies a needed voltage. Supports range tokens like "9-18". */
export function voltageTokensCanSatisfy(supplyTokens: string[], needed: string): boolean {
  const neededNum = parseFloat(needed);
  if (isNaN(neededNum)) return supplyTokens.includes(needed);

  for (const token of supplyTokens) {
    // Range: "9-18"
    const rangeParts = token.split('-');
    if (rangeParts.length === 2) {
      const lo = parseFloat(rangeParts[0]);
      const hi = parseFloat(rangeParts[1]);
      if (!isNaN(lo) && !isNaN(hi) && neededNum >= lo && neededNum <= hi) return true;
    }
    // Exact match
    if (parseFloat(token) === neededNum) return true;
  }
  return false;
}

/** Top-level: does a supply jack's voltage satisfy a consumer's voltage requirement? */
export function voltagesCompatible(supplyVoltage: string, consumerVoltage: string): boolean {
  const supplyTokens = voltageTokensFromJack(supplyVoltage);
  const neededTokens = voltageTokensFromJack(consumerVoltage);
  // Every token the consumer needs must be satisfiable by the supply
  return neededTokens.every(needed => voltageTokensCanSatisfy(supplyTokens, needed));
}

/** Validate a single connection between a supply output jack and a consumer input jack. */
export function validateConnection(
  outputJack: { voltage: string | null; current_ma: number | null; polarity: string | null; connector_type: string | null },
  inputJack: { voltage: string | null; current_ma: number | null; polarity: string | null; connector_type: string | null },
  /** Total current draw of all consumers connected to this output (including this one) */
  totalCurrentOnOutput?: number,
): ConnectionValidation {
  const warnings: ConnectionWarning[] = [];
  let hasError = false;

  // Voltage check
  if (outputJack.voltage && inputJack.voltage) {
    if (!voltagesCompatible(outputJack.voltage, inputJack.voltage)) {
      warnings.push({
        key: 'power:voltage-mismatch',
        severity: 'error',
        message: `Voltage mismatch: supply ${outputJack.voltage} vs pedal ${inputJack.voltage}`,
      });
      hasError = true;
    }
  }

  // Current check
  if (totalCurrentOnOutput != null && outputJack.current_ma != null) {
    if (totalCurrentOnOutput > outputJack.current_ma) {
      warnings.push({
        key: 'power:current-overload',
        severity: 'error',
        message: `Current overload: ${totalCurrentOnOutput}mA needed, output provides ${outputJack.current_ma}mA`,
      });
      hasError = true;
    }
  }

  if (hasError) {
    return { status: 'error', warnings };
  }

  // Polarity check (warning, not error — user can get a reversal cable)
  if (outputJack.polarity && inputJack.polarity) {
    if (normalizePolarity(outputJack.polarity) !== normalizePolarity(inputJack.polarity)) {
      warnings.push({
        key: 'power:polarity-mismatch',
        severity: 'warning',
        message: `Polarity mismatch: supply ${outputJack.polarity}, pedal ${inputJack.polarity} — reversal cable needed`,
        adapterImplication: {
          fromConnectorType: outputJack.connector_type ?? 'unknown',
          toConnectorType: inputJack.connector_type ?? 'unknown',
          description: `Polarity reversal cable (${outputJack.polarity} to ${inputJack.polarity})`,
        },
      });
    }
  }

  // Connector check (warning, not error — user can get an adapter)
  if (outputJack.connector_type && inputJack.connector_type) {
    if (normalizeConnector(outputJack.connector_type) !== normalizeConnector(inputJack.connector_type)) {
      warnings.push({
        key: 'power:connector-mismatch',
        severity: 'warning',
        message: `Connector mismatch: supply ${outputJack.connector_type}, pedal ${inputJack.connector_type} — adapter needed`,
        adapterImplication: {
          fromConnectorType: outputJack.connector_type,
          toConnectorType: inputJack.connector_type,
          description: `${outputJack.connector_type} to ${inputJack.connector_type} power adapter`,
        },
      });
    }
  }

  // Adjustable voltage notice — supply offers multiple voltages but pedal needs a specific one
  if (outputJack.voltage && inputJack.voltage) {
    const supplyTokens = voltageTokensFromJack(outputJack.voltage);
    const consumerTokens = voltageTokensFromJack(inputJack.voltage);
    const supplyIsAdjustable = supplyTokens.length > 1 || supplyTokens.some(t => t.includes('-'));
    if (supplyIsAdjustable && consumerTokens.length === 1) {
      warnings.push({
        key: 'power:adjustable-voltage',
        severity: 'info',
        message: `This output is adjustable — set it to ${inputJack.voltage} for this pedal`,
      });
    }
  }

  return {
    status: warnings.length > 0 ? 'warning' : 'valid',
    warnings,
  };
}
