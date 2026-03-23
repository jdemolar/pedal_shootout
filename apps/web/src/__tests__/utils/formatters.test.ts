import { formatDimensions, formatMsrp, formatPower } from '../../utils/formatters';

describe('formatDimensions', () => {
  it('returns all three dimensions when all are provided', () => {
    expect(formatDimensions(66, 122, 39)).toBe('66 × 122 × 39 mm');
  });

  it('returns width × depth when height is null', () => {
    expect(formatDimensions(60, 112, null)).toBe('60 × 112 mm');
  });

  it('returns em dash when width is null', () => {
    expect(formatDimensions(null, 112, 39)).toBe('—');
  });

  it('returns em dash when depth is null', () => {
    expect(formatDimensions(60, null, 39)).toBe('—');
  });

  it('returns em dash when all are null', () => {
    expect(formatDimensions(null, null, null)).toBe('—');
  });
});

describe('formatMsrp', () => {
  it('formats cents as dollars', () => {
    expect(formatMsrp(9900)).toBe('$99.00');
    expect(formatMsrp(16800)).toBe('$168.00');
  });

  it('returns em dash for null', () => {
    expect(formatMsrp(null)).toBe('—');
  });
});

describe('formatPower', () => {
  it('returns voltage and current when both provided', () => {
    expect(formatPower('9V', 100)).toBe('9V / 100mA');
  });

  it('returns only voltage when current is null', () => {
    expect(formatPower('9V', null)).toBe('9V');
  });

  it('returns only current when voltage is null', () => {
    expect(formatPower(null, 100)).toBe('100mA');
  });

  it('returns em dash when both are null', () => {
    expect(formatPower(null, null)).toBe('—');
  });
});
