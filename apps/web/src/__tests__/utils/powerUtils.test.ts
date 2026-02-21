import {
  normalizePolarity,
  normalizeConnector,
  normalizeVoltage,
  voltageTokensFromJack,
  voltageTokensCanSatisfy,
  voltagesCompatible,
  validateConnection,
} from '../../utils/powerUtils';

describe('normalizePolarity', () => {
  it('lowercases and replaces spaces with hyphens', () => {
    expect(normalizePolarity('Center Negative')).toBe('center-negative');
    expect(normalizePolarity('Center Positive')).toBe('center-positive');
  });
});

describe('normalizeConnector', () => {
  it('trims whitespace', () => {
    expect(normalizeConnector(' 2.1mm barrel ')).toBe('2.1mm barrel');
  });
});

describe('normalizeVoltage', () => {
  it('strips V, DC, AC', () => {
    expect(normalizeVoltage('9V DC')).toBe('9');
    expect(normalizeVoltage('9V/12V/18V')).toBe('9/12/18');
    expect(normalizeVoltage('100-240V AC')).toBe('100-240');
  });
});

describe('voltageTokensFromJack', () => {
  it('splits by slash', () => {
    expect(voltageTokensFromJack('9V/12V/18V')).toEqual(['9', '12', '18']);
  });

  it('handles single voltage', () => {
    expect(voltageTokensFromJack('9V')).toEqual(['9']);
  });
});

describe('voltageTokensCanSatisfy', () => {
  it('matches exact', () => {
    expect(voltageTokensCanSatisfy(['9', '12'], '9')).toBe(true);
  });

  it('rejects missing', () => {
    expect(voltageTokensCanSatisfy(['12'], '9')).toBe(false);
  });

  it('matches range', () => {
    expect(voltageTokensCanSatisfy(['9-18'], '12')).toBe(true);
    expect(voltageTokensCanSatisfy(['9-18'], '24')).toBe(false);
  });
});

describe('voltagesCompatible', () => {
  it('matches single voltage', () => {
    expect(voltagesCompatible('9V', '9V')).toBe(true);
    expect(voltagesCompatible('12V', '9V')).toBe(false);
  });

  it('selectable supply matches consumer', () => {
    expect(voltagesCompatible('9V/12V/18V', '9V')).toBe(true);
    expect(voltagesCompatible('9V/12V/18V', '24V')).toBe(false);
  });
});

describe('validateConnection', () => {
  const baseOutput = { voltage: '9V', current_ma: 500, polarity: 'Center Negative', connector_type: '2.1mm barrel' };
  const baseInput = { voltage: '9V', current_ma: 100, polarity: 'Center Negative', connector_type: '2.1mm barrel' };

  it('returns valid for matching jacks', () => {
    const result = validateConnection(baseOutput, baseInput);
    expect(result.status).toBe('valid');
    expect(result.warnings).toHaveLength(0);
  });

  it('returns error for voltage mismatch', () => {
    const result = validateConnection(baseOutput, { ...baseInput, voltage: '18V' });
    expect(result.status).toBe('error');
    expect(result.warnings[0]).toMatch(/Voltage mismatch/);
  });

  it('returns error for current overload', () => {
    const result = validateConnection(baseOutput, baseInput, 600);
    expect(result.status).toBe('error');
    expect(result.warnings[0]).toMatch(/Current overload/);
  });

  it('returns warning for polarity mismatch', () => {
    const result = validateConnection(baseOutput, { ...baseInput, polarity: 'Center Positive' });
    expect(result.status).toBe('warning');
    expect(result.warnings[0]).toMatch(/Polarity mismatch/);
  });

  it('returns warning for connector mismatch', () => {
    const result = validateConnection(baseOutput, { ...baseInput, connector_type: '2.5mm barrel' });
    expect(result.status).toBe('warning');
    expect(result.warnings[0]).toMatch(/Connector mismatch/);
  });

  it('handles null values gracefully', () => {
    const result = validateConnection(
      { voltage: null, current_ma: null, polarity: null, connector_type: null },
      { voltage: null, current_ma: null, polarity: null, connector_type: null },
    );
    expect(result.status).toBe('valid');
  });
});
