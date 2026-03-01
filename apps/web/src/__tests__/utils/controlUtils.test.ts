import {
  getControlInputJacks,
  getControlOutputJacks,
  hasControlJacks,
  inferControlType,
  isTrsConnector,
  validateControlConnection,
} from '../../utils/controlUtils';
import { Jack } from '../../utils/transformers';
import { ControlConnection } from '../../types/connections';

// --- Helpers ---

function makeJack(overrides: Partial<Jack> = {}): Jack {
  return {
    id: 1,
    category: 'expression',
    direction: 'output',
    jack_name: null,
    position: null,
    connector_type: '1/4" TRS',
    impedance_ohms: null,
    voltage: null,
    current_ma: null,
    polarity: null,
    function_desc: null,
    is_isolated: null,
    is_buffered: null,
    has_ground_lift: null,
    has_phase_invert: null,
    group_id: null,
    ...overrides,
  };
}

function makeControlConn(overrides: Partial<ControlConnection> = {}): ControlConnection {
  return {
    id: 'conn-1',
    sourceJackId: 1,
    targetJackId: 2,
    sourceInstanceId: 'inst-a',
    targetInstanceId: 'inst-b',
    controlType: 'expression',
    trsPolarity: null,
    ...overrides,
  };
}

// --- getControlInputJacks ---

describe('getControlInputJacks', () => {
  it('returns expression/aux/cv input and bidirectional jacks', () => {
    const jacks = [
      makeJack({ id: 1, category: 'expression', direction: 'input' }),
      makeJack({ id: 2, category: 'aux', direction: 'input' }),
      makeJack({ id: 3, category: 'cv', direction: 'bidirectional' }),
      makeJack({ id: 4, category: 'expression', direction: 'output' }),
      makeJack({ id: 5, category: 'audio', direction: 'input' }),
      makeJack({ id: 6, category: 'midi', direction: 'input' }),
    ];
    const result = getControlInputJacks({ jacks });
    expect(result).toHaveLength(3);
    expect(result.map(j => j.id)).toEqual([1, 2, 3]);
  });

  it('returns empty array when no control inputs', () => {
    const jacks = [makeJack({ category: 'audio', direction: 'input' })];
    expect(getControlInputJacks({ jacks })).toHaveLength(0);
  });

  it('returns empty array for empty jacks', () => {
    expect(getControlInputJacks({ jacks: [] })).toHaveLength(0);
  });
});

// --- getControlOutputJacks ---

describe('getControlOutputJacks', () => {
  it('returns expression/aux/cv output and bidirectional jacks', () => {
    const jacks = [
      makeJack({ id: 1, category: 'expression', direction: 'output' }),
      makeJack({ id: 2, category: 'aux', direction: 'output' }),
      makeJack({ id: 3, category: 'cv', direction: 'bidirectional' }),
      makeJack({ id: 4, category: 'expression', direction: 'input' }),
      makeJack({ id: 5, category: 'audio', direction: 'output' }),
    ];
    const result = getControlOutputJacks({ jacks });
    expect(result).toHaveLength(3);
    expect(result.map(j => j.id)).toEqual([1, 2, 3]);
  });

  it('excludes USB-A jacks', () => {
    const jacks = [
      makeJack({ id: 1, category: 'aux', direction: 'output', connector_type: 'USB-A' }),
      makeJack({ id: 2, category: 'aux', direction: 'output', connector_type: '1/4" TS' }),
    ];
    const result = getControlOutputJacks({ jacks });
    expect(result).toHaveLength(1);
    expect(result[0].id).toBe(2);
  });

  it('returns empty array when no control outputs', () => {
    expect(getControlOutputJacks({ jacks: [] })).toHaveLength(0);
  });
});

// --- hasControlJacks ---

describe('hasControlJacks', () => {
  it('returns true for rows with expression jacks', () => {
    const jacks = [makeJack({ category: 'expression', direction: 'input' })];
    expect(hasControlJacks({ jacks })).toBe(true);
  });

  it('returns true for rows with aux jacks', () => {
    const jacks = [makeJack({ category: 'aux', direction: 'output' })];
    expect(hasControlJacks({ jacks })).toBe(true);
  });

  it('returns true for rows with cv jacks', () => {
    const jacks = [makeJack({ category: 'cv', direction: 'input' })];
    expect(hasControlJacks({ jacks })).toBe(true);
  });

  it('returns false for audio-only rows', () => {
    const jacks = [makeJack({ category: 'audio', direction: 'input' })];
    expect(hasControlJacks({ jacks })).toBe(false);
  });

  it('returns false for empty jacks array', () => {
    expect(hasControlJacks({ jacks: [] })).toBe(false);
  });
});

// --- inferControlType ---

describe('inferControlType', () => {
  it('maps expression to expression', () => {
    expect(inferControlType({ category: 'expression' })).toBe('expression');
  });

  it('maps aux to aux_switch', () => {
    expect(inferControlType({ category: 'aux' })).toBe('aux_switch');
  });

  it('maps cv to cv', () => {
    expect(inferControlType({ category: 'cv' })).toBe('cv');
  });

  it('maps unknown category to other', () => {
    expect(inferControlType({ category: 'audio' })).toBe('other');
  });

  it('maps null category to other', () => {
    expect(inferControlType({ category: null })).toBe('other');
  });
});

// --- isTrsConnector ---

describe('isTrsConnector', () => {
  it('returns true for 1/4" TRS', () => {
    expect(isTrsConnector('1/4" TRS')).toBe(true);
  });

  it('returns true for 3.5mm TRS', () => {
    expect(isTrsConnector('3.5mm TRS')).toBe(true);
  });

  it('returns false for 1/4" TS', () => {
    expect(isTrsConnector('1/4" TS')).toBe(false);
  });

  it('returns false for null', () => {
    expect(isTrsConnector(null)).toBe(false);
  });
});

// --- validateControlConnection ---

const baseSrcJack = { category: 'expression', connector_type: '1/4" TRS', jack_name: 'Out 1' };
const baseTgtJack = { category: 'expression', connector_type: '1/4" TRS', jack_name: 'Exp In' };

describe('validateControlConnection', () => {
  it('returns warning status for valid matching connection (polarity unknown info)', () => {
    const result = validateControlConnection(baseSrcJack, baseTgtJack, [], 'inst-a', 'inst-b');
    // Valid connection but TRS triggers polarity-unknown info
    expect(result.status).toBe('warning');
    expect(result.warnings).toHaveLength(1);
    expect(result.warnings[0].key).toBe('control:polarity-unknown');
    expect(result.warnings[0].severity).toBe('info');
  });

  it('returns error for self-connection', () => {
    const result = validateControlConnection(baseSrcJack, baseTgtJack, [], 'inst-a', 'inst-a');
    expect(result.status).toBe('error');
    expect(result.warnings.some(w => w.key === 'control:self-connection')).toBe(true);
  });

  it('returns error for category mismatch', () => {
    const result = validateControlConnection(
      { category: 'expression', connector_type: '1/4" TRS', jack_name: 'Out' },
      { category: 'aux', connector_type: '1/4" TS', jack_name: 'Aux In' },
      [], 'inst-a', 'inst-b',
    );
    expect(result.status).toBe('error');
    expect(result.warnings.some(w => w.key === 'control:category-mismatch')).toBe(true);
  });

  it('returns warning for shared input', () => {
    const conns = [makeControlConn({ targetJackId: 10, targetInstanceId: 'inst-b' })];
    const result = validateControlConnection(baseSrcJack, baseTgtJack, conns, 'inst-c', 'inst-b', 20, 10);
    expect(result.warnings.some(w => w.key === 'control:shared-input')).toBe(true);
    expect(result.warnings.find(w => w.key === 'control:shared-input')!.severity).toBe('warning');
  });

  it('returns warning with adapterImplication for connector mismatch', () => {
    const result = validateControlConnection(
      { category: 'expression', connector_type: '1/4" TRS', jack_name: 'Out' },
      { category: 'expression', connector_type: '3.5mm TRS', jack_name: 'Exp In' },
      [], 'inst-a', 'inst-b',
    );
    expect(result.warnings.some(w => w.key === 'control:connector-mismatch')).toBe(true);
    const w = result.warnings.find(w => w.key === 'control:connector-mismatch')!;
    expect(w.adapterImplication).toMatchObject({
      fromConnectorType: '1/4" TRS',
      toConnectorType: '3.5mm TRS',
    });
  });

  it('does not emit polarity-unknown when there is an error', () => {
    const result = validateControlConnection(
      { category: 'expression', connector_type: '1/4" TRS', jack_name: 'Out' },
      { category: 'expression', connector_type: '1/4" TRS', jack_name: 'Exp In' },
      [], 'inst-a', 'inst-a', // self-connection error
    );
    expect(result.warnings.some(w => w.key === 'control:polarity-unknown')).toBe(false);
  });

  it('does not warn for shared input when jackIds are not provided', () => {
    const conns = [makeControlConn({ targetJackId: 10, targetInstanceId: 'inst-b' })];
    const result = validateControlConnection(baseSrcJack, baseTgtJack, conns, 'inst-c', 'inst-b');
    expect(result.warnings.some(w => w.key === 'control:shared-input')).toBe(false);
  });

  it('returns valid for non-TRS connectors with matching categories', () => {
    const result = validateControlConnection(
      { category: 'aux', connector_type: '1/4" TS', jack_name: 'Switch Out' },
      { category: 'aux', connector_type: '1/4" TS', jack_name: 'Aux In' },
      [], 'inst-a', 'inst-b',
    );
    expect(result.status).toBe('valid');
    expect(result.warnings).toHaveLength(0);
  });

  it('handles null connector types gracefully', () => {
    const result = validateControlConnection(
      { category: 'expression', connector_type: null, jack_name: null },
      { category: 'expression', connector_type: null, jack_name: null },
      [], 'inst-a', 'inst-b',
    );
    expect(result.status).toBe('valid');
    expect(result.warnings).toHaveLength(0);
  });
});
