import {
  getAudioInputJacks,
  getAudioOutputJacks,
  hasAudioJacks,
  getStereoPartner,
  validateAudioConnection,
  wouldCreateCycle,
} from '../../utils/audioUtils';
import { Jack } from '../../utils/transformers';
import { AudioConnection } from '../../types/connections';

// --- Test data helpers ---

function makeJack(overrides: Partial<Jack>): Jack {
  return {
    id: 1,
    category: null,
    direction: null,
    jack_name: null,
    position: null,
    connector_type: null,
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

function makeConnection(overrides: Partial<AudioConnection>): AudioConnection {
  return {
    id: 'conn-1',
    sourceJackId: 1,
    targetJackId: 2,
    sourceInstanceId: 'inst-a',
    targetInstanceId: 'inst-b',
    orderIndex: 0,
    parallelPathId: null,
    fxLoopGroupId: null,
    signalMode: 'mono',
    stereoPairConnectionId: null,
    waypoints: [],
    ...overrides,
  };
}

// --- getAudioInputJacks ---

describe('getAudioInputJacks', () => {
  it('returns only audio input jacks', () => {
    const jacks = [
      makeJack({ id: 1, category: 'audio', direction: 'input' }),
      makeJack({ id: 2, category: 'audio', direction: 'output' }),
      makeJack({ id: 3, category: 'power', direction: 'input' }),
    ];
    const result = getAudioInputJacks({ jacks });
    expect(result).toHaveLength(1);
    expect(result[0].id).toBe(1);
  });

  it('returns empty array when no audio input jacks', () => {
    const jacks = [makeJack({ id: 1, category: 'power', direction: 'input' })];
    expect(getAudioInputJacks({ jacks })).toEqual([]);
  });
});

// --- getAudioOutputJacks ---

describe('getAudioOutputJacks', () => {
  it('returns only audio output jacks', () => {
    const jacks = [
      makeJack({ id: 1, category: 'audio', direction: 'output' }),
      makeJack({ id: 2, category: 'audio', direction: 'input' }),
      makeJack({ id: 3, category: 'power', direction: 'output' }),
    ];
    const result = getAudioOutputJacks({ jacks });
    expect(result).toHaveLength(1);
    expect(result[0].id).toBe(1);
  });

  it('returns empty array when no audio output jacks', () => {
    expect(getAudioOutputJacks({ jacks: [] })).toEqual([]);
  });
});

// --- hasAudioJacks ---

describe('hasAudioJacks', () => {
  it('returns false for power-only row', () => {
    const jacks = [makeJack({ id: 1, category: 'power', direction: 'input' })];
    expect(hasAudioJacks({ jacks })).toBe(false);
  });

  it('returns true for row with audio jacks', () => {
    const jacks = [
      makeJack({ id: 1, category: 'power', direction: 'input' }),
      makeJack({ id: 2, category: 'audio', direction: 'output' }),
    ];
    expect(hasAudioJacks({ jacks })).toBe(true);
  });

  it('returns false for empty jacks array', () => {
    expect(hasAudioJacks({ jacks: [] })).toBe(false);
  });
});

// --- getStereoPartner ---

describe('getStereoPartner', () => {
  it('returns partner jack sharing the same group_id', () => {
    const jack = makeJack({ id: 1, group_id: 'stereo-group-1' });
    const partner = makeJack({ id: 2, group_id: 'stereo-group-1' });
    const allJacks = [jack, partner];
    expect(getStereoPartner(jack, allJacks)).toBe(partner);
  });

  it('returns undefined when jack has no group_id', () => {
    const jack = makeJack({ id: 1, group_id: null });
    const other = makeJack({ id: 2, group_id: null });
    expect(getStereoPartner(jack, [jack, other])).toBeUndefined();
  });

  it('returns undefined when group_id set but no other jack shares it', () => {
    const jack = makeJack({ id: 1, group_id: 'group-x' });
    const other = makeJack({ id: 2, group_id: 'group-y' });
    expect(getStereoPartner(jack, [jack, other])).toBeUndefined();
  });

  it('does not return the same jack as its own partner', () => {
    const jack = makeJack({ id: 1, group_id: 'group-solo' });
    expect(getStereoPartner(jack, [jack])).toBeUndefined();
  });
});

// --- wouldCreateCycle ---

describe('wouldCreateCycle', () => {
  it('returns false for unconnected items', () => {
    expect(wouldCreateCycle('inst-a', 'inst-b', [])).toBe(false);
  });

  it('returns false when no path exists from target to source', () => {
    const conns = [makeConnection({ sourceInstanceId: 'inst-b', targetInstanceId: 'inst-c' })];
    expect(wouldCreateCycle('inst-a', 'inst-b', conns)).toBe(false);
  });

  it('returns true when adding connection would close a loop', () => {
    // a → b → c, adding c → a would be a cycle
    const conns = [
      makeConnection({ id: 'c1', sourceInstanceId: 'inst-a', targetInstanceId: 'inst-b' }),
      makeConnection({ id: 'c2', sourceInstanceId: 'inst-b', targetInstanceId: 'inst-c' }),
    ];
    expect(wouldCreateCycle('inst-c', 'inst-a', conns)).toBe(true);
  });

  it('returns true for a direct self-loop', () => {
    expect(wouldCreateCycle('inst-a', 'inst-a', [])).toBe(true);
  });
});

// --- validateAudioConnection ---

const validSource = { connector_type: '1/4" TS', group_id: null, impedance_ohms: null };
const validTarget = { connector_type: '1/4" TS', group_id: null, impedance_ohms: null };

describe('validateAudioConnection', () => {
  it('returns valid when all checks pass', () => {
    const result = validateAudioConnection(
      validSource, validTarget, 'mono', 'mono', [], 'inst-a', 'inst-b',
    );
    expect(result.status).toBe('valid');
    expect(result.warnings).toHaveLength(0);
  });

  it('warns on connector mismatch with adapterImplication', () => {
    const source = { ...validSource, connector_type: '1/4" TS' };
    const target = { ...validTarget, connector_type: 'XLR' };
    const result = validateAudioConnection(
      source, target, 'mono', 'mono', [], 'inst-a', 'inst-b',
    );
    expect(result.status).toBe('warning');
    const w = result.warnings.find(w => w.key === 'audio:connector-mismatch');
    expect(w).toBeDefined();
    expect(w?.adapterImplication).toBeDefined();
    expect(w?.adapterImplication?.fromConnectorType).toBe('1/4" TS');
    expect(w?.adapterImplication?.toConnectorType).toBe('XLR');
  });

  it('warns on mono-to-stereo without adapterImplication', () => {
    const result = validateAudioConnection(
      validSource, validTarget, 'mono', 'stereo', [], 'inst-a', 'inst-b',
    );
    expect(result.status).toBe('warning');
    const w = result.warnings.find(w => w.key === 'audio:mono-to-stereo');
    expect(w).toBeDefined();
    expect(w?.adapterImplication).toBeUndefined();
  });

  it('warns on stereo-to-mono without adapterImplication', () => {
    const result = validateAudioConnection(
      validSource, validTarget, 'stereo', 'mono', [], 'inst-a', 'inst-b',
    );
    expect(result.status).toBe('warning');
    const w = result.warnings.find(w => w.key === 'audio:stereo-to-mono');
    expect(w).toBeDefined();
    expect(w?.adapterImplication).toBeUndefined();
  });

  it('warns on impedance mismatch when both jacks have impedance_ohms', () => {
    const source = { ...validSource, impedance_ohms: 10 };
    const target = { ...validTarget, impedance_ohms: 10000 };
    const result = validateAudioConnection(
      source, target, 'mono', 'mono', [], 'inst-a', 'inst-b',
    );
    expect(result.status).toBe('warning');
    expect(result.warnings.some(w => w.key === 'audio:impedance-mismatch')).toBe(true);
  });

  it('does not warn on impedance when only one jack has impedance_ohms', () => {
    const source = { ...validSource, impedance_ohms: 10 };
    const target = { ...validTarget, impedance_ohms: null };
    const result = validateAudioConnection(
      source, target, 'mono', 'mono', [], 'inst-a', 'inst-b',
    );
    expect(result.warnings.some(w => w.key === 'audio:impedance-mismatch')).toBe(false);
  });

  it('handles null connector types gracefully (no mismatch warning)', () => {
    const source = { connector_type: null, group_id: null, impedance_ohms: null };
    const target = { connector_type: null, group_id: null, impedance_ohms: null };
    const result = validateAudioConnection(
      source, target, 'mono', 'mono', [], 'inst-a', 'inst-b',
    );
    expect(result.warnings.some(w => w.key === 'audio:connector-mismatch')).toBe(false);
  });

  it('returns error status on circular connection', () => {
    // a → b already exists; trying to add b → a
    const conns = [makeConnection({ sourceInstanceId: 'inst-a', targetInstanceId: 'inst-b' })];
    const result = validateAudioConnection(
      validSource, validTarget, 'mono', 'mono', conns, 'inst-b', 'inst-a',
    );
    expect(result.status).toBe('error');
    expect(result.warnings.some(w => w.key === 'audio:circular-connection')).toBe(true);
  });
});
