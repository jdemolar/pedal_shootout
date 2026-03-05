import {
  getAudioInputJacks,
  getAudioOutputJacks,
  hasAudioJacks,
  getStereoPartner,
  validateAudioConnection,
} from '../../utils/audioUtils';
import { wouldCreateCycle } from '../../utils/connectionValidation';
import { Jack } from '../../utils/transformers';
import { AudioConnection } from '../../types/connections';

// --- Helpers ---

function makeJack(overrides: Partial<Jack> = {}): Jack {
  return {
    id: 1,
    category: 'audio',
    direction: 'input',
    jack_name: null,
    position: null,
    connector_type: '1/4" TS',
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

function makeConn(overrides: Partial<AudioConnection> = {}): AudioConnection {
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
    expect(getAudioInputJacks({ jacks })).toEqual([jacks[0]]);
  });

  it('returns empty array when no audio inputs', () => {
    const jacks = [makeJack({ category: 'power', direction: 'input' })];
    expect(getAudioInputJacks({ jacks })).toHaveLength(0);
  });
});

// --- getAudioOutputJacks ---

describe('getAudioOutputJacks', () => {
  it('returns only audio output jacks', () => {
    const jacks = [
      makeJack({ id: 1, category: 'audio', direction: 'input' }),
      makeJack({ id: 2, category: 'audio', direction: 'output' }),
      makeJack({ id: 3, category: 'midi', direction: 'output' }),
    ];
    expect(getAudioOutputJacks({ jacks })).toEqual([jacks[1]]);
  });

  it('returns empty array when no audio outputs', () => {
    expect(getAudioOutputJacks({ jacks: [] })).toHaveLength(0);
  });
});

// --- hasAudioJacks ---

describe('hasAudioJacks', () => {
  it('returns false for power-only rows', () => {
    const jacks = [makeJack({ category: 'power', direction: 'input' })];
    expect(hasAudioJacks({ jacks })).toBe(false);
  });

  it('returns true for rows with at least one audio jack', () => {
    const jacks = [
      makeJack({ category: 'power', direction: 'input' }),
      makeJack({ category: 'audio', direction: 'input' }),
    ];
    expect(hasAudioJacks({ jacks })).toBe(true);
  });

  it('returns false for empty jacks array', () => {
    expect(hasAudioJacks({ jacks: [] })).toBe(false);
  });
});

// --- getStereoPartner ---

describe('getStereoPartner', () => {
  it('returns undefined when jack has no group_id', () => {
    const jack = makeJack({ id: 1, group_id: null });
    const allJacks = [jack, makeJack({ id: 2, group_id: 'stereo-1' })];
    expect(getStereoPartner(jack, allJacks)).toBeUndefined();
  });

  it('returns the partner jack sharing the same group_id', () => {
    const jack = makeJack({ id: 1, group_id: 'stereo-1' });
    const partner = makeJack({ id: 2, group_id: 'stereo-1' });
    const unrelated = makeJack({ id: 3, group_id: 'stereo-2' });
    expect(getStereoPartner(jack, [jack, partner, unrelated])).toBe(partner);
  });

  it('returns undefined when no other jack has the same group_id', () => {
    const jack = makeJack({ id: 1, group_id: 'stereo-x' });
    expect(getStereoPartner(jack, [jack])).toBeUndefined();
  });

  it('does not return the jack itself', () => {
    const jack = makeJack({ id: 1, group_id: 'stereo-1' });
    expect(getStereoPartner(jack, [jack])).toBeUndefined();
  });
});

// --- wouldCreateCycle ---

describe('wouldCreateCycle', () => {
  it('returns false for new unconnected items', () => {
    expect(wouldCreateCycle('A', 'B', [])).toBe(false);
  });

  it('returns false when source is not reachable from target', () => {
    const conns = [makeConn({ sourceInstanceId: 'B', targetInstanceId: 'C' })];
    expect(wouldCreateCycle('A', 'B', conns)).toBe(false);
  });

  it('returns true for direct cycle A→B and B→A attempted', () => {
    const conns = [makeConn({ sourceInstanceId: 'A', targetInstanceId: 'B' })];
    // Trying to add B→A would create a cycle
    expect(wouldCreateCycle('B', 'A', conns)).toBe(true);
  });

  it('returns true for indirect cycle A→B→C and C→A attempted', () => {
    const conns = [
      makeConn({ id: '1', sourceInstanceId: 'A', targetInstanceId: 'B' }),
      makeConn({ id: '2', sourceInstanceId: 'B', targetInstanceId: 'C' }),
    ];
    expect(wouldCreateCycle('C', 'A', conns)).toBe(true);
  });

  it('returns false for non-cyclic chain', () => {
    const conns = [
      makeConn({ id: '1', sourceInstanceId: 'A', targetInstanceId: 'B' }),
      makeConn({ id: '2', sourceInstanceId: 'B', targetInstanceId: 'C' }),
    ];
    // Adding A→C is not a cycle
    expect(wouldCreateCycle('A', 'C', conns)).toBe(false);
  });
});

// --- validateAudioConnection ---

const baseSourceJack = { connector_type: '1/4" TS', group_id: null, impedance_ohms: null };
const baseTargetJack = { connector_type: '1/4" TS', group_id: null, impedance_ohms: null };

describe('validateAudioConnection', () => {
  it('returns valid status for compatible jacks', () => {
    const result = validateAudioConnection(
      baseSourceJack,
      baseTargetJack,
      'mono',
      'mono',
      [],
      'inst-a',
      'inst-b',
    );
    expect(result.status).toBe('valid');
    expect(result.warnings).toHaveLength(0);
  });

  it('returns error for circular connection', () => {
    const conns = [makeConn({ sourceInstanceId: 'inst-a', targetInstanceId: 'inst-b' })];
    const result = validateAudioConnection(
      baseSourceJack,
      baseTargetJack,
      'mono',
      'mono',
      conns,
      'inst-b',
      'inst-a',
    );
    expect(result.status).toBe('error');
    expect(result.warnings[0].key).toBe('audio:circular-connection');
    expect(result.warnings[0].severity).toBe('error');
  });

  it('returns warning with adapterImplication for connector mismatch', () => {
    const result = validateAudioConnection(
      { ...baseSourceJack, connector_type: '1/4" TS' },
      { ...baseTargetJack, connector_type: 'XLR' },
      'mono',
      'mono',
      [],
      'inst-a',
      'inst-b',
    );
    expect(result.status).toBe('warning');
    expect(result.warnings[0].key).toBe('audio:connector-mismatch');
    expect(result.warnings[0].severity).toBe('warning');
    expect(result.warnings[0].adapterImplication).toMatchObject({
      fromConnectorType: '1/4" TS',
      toConnectorType: 'XLR',
    });
  });

  it('returns warning for mono to stereo connection', () => {
    const result = validateAudioConnection(
      baseSourceJack,
      baseTargetJack,
      'mono',
      'stereo',
      [],
      'inst-a',
      'inst-b',
    );
    expect(result.status).toBe('warning');
    expect(result.warnings[0].key).toBe('audio:mono-to-stereo');
    expect(result.warnings[0].severity).toBe('warning');
    expect(result.warnings[0].adapterImplication).toBeUndefined();
  });

  it('returns warning for stereo to mono connection', () => {
    const result = validateAudioConnection(
      baseSourceJack,
      baseTargetJack,
      'stereo',
      'mono',
      [],
      'inst-a',
      'inst-b',
    );
    expect(result.status).toBe('warning');
    expect(result.warnings[0].key).toBe('audio:stereo-to-mono');
    expect(result.warnings[0].severity).toBe('warning');
    expect(result.warnings[0].adapterImplication).toBeUndefined();
  });

  it('returns warning for impedance mismatch (ratio > 100)', () => {
    const result = validateAudioConnection(
      { ...baseSourceJack, impedance_ohms: 150 },
      { ...baseTargetJack, impedance_ohms: 20000 },
      'mono',
      'mono',
      [],
      'inst-a',
      'inst-b',
    );
    expect(result.status).toBe('warning');
    expect(result.warnings[0].key).toBe('audio:impedance-mismatch');
    expect(result.warnings[0].severity).toBe('warning');
  });

  it('does not warn for impedance ratio at or below 100', () => {
    const result = validateAudioConnection(
      { ...baseSourceJack, impedance_ohms: 150 },
      { ...baseTargetJack, impedance_ohms: 15000 },
      'mono',
      'mono',
      [],
      'inst-a',
      'inst-b',
    );
    expect(result.status).toBe('valid');
  });

  it('handles null connector types gracefully (no connector warning)', () => {
    const result = validateAudioConnection(
      { connector_type: null, group_id: null, impedance_ohms: null },
      { connector_type: null, group_id: null, impedance_ohms: null },
      'mono',
      'mono',
      [],
      'inst-a',
      'inst-b',
    );
    expect(result.status).toBe('valid');
    expect(result.warnings).toHaveLength(0);
  });

  it('handles null impedance values gracefully (no impedance warning)', () => {
    const result = validateAudioConnection(
      { ...baseSourceJack, impedance_ohms: null },
      { ...baseTargetJack, impedance_ohms: null },
      'mono',
      'mono',
      [],
      'inst-a',
      'inst-b',
    );
    expect(result.status).toBe('valid');
  });

  it('can accumulate multiple warnings', () => {
    const result = validateAudioConnection(
      { connector_type: '1/4" TS', group_id: null, impedance_ohms: 150 },
      { connector_type: 'XLR', group_id: null, impedance_ohms: 20000 },
      'mono',
      'stereo',
      [],
      'inst-a',
      'inst-b',
    );
    expect(result.status).toBe('warning');
    expect(result.warnings.length).toBeGreaterThanOrEqual(2);
  });
});
