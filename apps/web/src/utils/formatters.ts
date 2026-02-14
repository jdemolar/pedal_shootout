export function formatMsrp(cents: number | null): string {
  if (cents == null) return '\u2014';
  return `$${(cents / 100).toFixed(2)}`;
}

export function formatDimensions(w: number | null, d: number | null, h: number | null): string {
  if (w != null && d != null && h != null) return `${w} \u00d7 ${d} \u00d7 ${h} mm`;
  return '\u2014';
}

export function formatPower(voltage: string | null, current: number | null): string {
  if (voltage && current) return `${voltage} / ${current}mA`;
  if (voltage) return voltage;
  if (current) return `${current}mA`;
  return '\u2014';
}
