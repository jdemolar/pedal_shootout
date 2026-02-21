/**
 * Shared normalization utilities for power-related comparisons.
 * Used by PowerBudgetInsight (workbench) and PowerSupplies (catalog filter).
 */

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
