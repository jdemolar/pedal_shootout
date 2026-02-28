import {
  getMidiInputJacks,
  getMidiOutputJacks,
  hasMidiJacks,
  isTrsMidiConnector,
  is5PinDinConnector,
  wouldCreateMidiCycle,
  getChainDepth,
  validateMidiConnection,
} from '../../utils/midiUtils';
import { Jack } from '../../utils/transformers';
import { MidiConnection } from '../../types/connections';

// --- Helpers ---

function makeJack(overrides: Partial<Jack> = {}): Jack {
  return {
    id: 1,
    category: 'midi',
    direction: 'output',
    jack_name: null,
    position: null,
    connector_type: '5-pin DIN',
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

function makeMidiConn(overrides: Partial<MidiConnection> = {}): MidiConnection {
  return {
    id: 'conn-1',
    sourceJackId: 1,
    targetJackId: 2,
    sourceInstanceId: 'inst-a',
    targetInstanceId: 'inst-b',
    chainIndex: 0,
    trsMidiStandard: null,
    ...overrides,
  };
}

// --- getMidiInputJacks ---

describe('getMidiInputJacks', () => {
  it('returns only midi input and bidirectional jacks', () => {
    const jacks = [
      makeJack({ id: 1, category: 'midi', direction: 'input' }),
      makeJack({ id: 2, category: 'midi', direction: 'output' }),
      makeJack({ id: 3, category: 'midi', direction: 'bidirectional' }),
      makeJack({ id: 4, category: 'audio', direction: 'input' }),
    ];
    const result = getMidiInputJacks({ jacks });
    expect(result).toHaveLength(2);
    expect(result.map(j => j.id)).toEqual([1, 3]);
  });

  it('returns empty array when no midi inputs', () => {
    const jacks = [makeJack({ category: 'audio', direction: 'input' })];
    expect(getMidiInputJacks({ jacks })).toHaveLength(0);
  });
});

// --- getMidiOutputJacks ---

describe('getMidiOutputJacks', () => {
  it('returns only midi output and bidirectional jacks', () => {
    const jacks = [
      makeJack({ id: 1, category: 'midi', direction: 'input' }),
      makeJack({ id: 2, category: 'midi', direction: 'output' }),
      makeJack({ id: 3, category: 'midi', direction: 'bidirectional' }),
      makeJack({ id: 4, category: 'audio', direction: 'output' }),
    ];
    const result = getMidiOutputJacks({ jacks });
    expect(result).toHaveLength(2);
    expect(result.map(j => j.id)).toEqual([2, 3]);
  });

  it('returns empty array when no midi outputs', () => {
    expect(getMidiOutputJacks({ jacks: [] })).toHaveLength(0);
  });
});

// --- hasMidiJacks ---

describe('hasMidiJacks', () => {
  it('returns false for audio-only rows', () => {
    const jacks = [makeJack({ category: 'audio', direction: 'input' })];
    expect(hasMidiJacks({ jacks })).toBe(false);
  });

  it('returns true for rows with at least one midi jack', () => {
    const jacks = [
      makeJack({ category: 'audio', direction: 'input' }),
      makeJack({ category: 'midi', direction: 'output' }),
    ];
    expect(hasMidiJacks({ jacks })).toBe(true);
  });

  it('returns false for empty jacks array', () => {
    expect(hasMidiJacks({ jacks: [] })).toBe(false);
  });
});

// --- isTrsMidiConnector ---

describe('isTrsMidiConnector', () => {
  it('returns true for 3.5mm TRS', () => {
    expect(isTrsMidiConnector('3.5mm TRS')).toBe(true);
  });

  it('returns true for 3.5mm TRS MIDI', () => {
    expect(isTrsMidiConnector('3.5mm TRS MIDI')).toBe(true);
  });

  it('returns false for 5-pin DIN', () => {
    expect(isTrsMidiConnector('5-pin DIN')).toBe(false);
  });

  it('returns false for null', () => {
    expect(isTrsMidiConnector(null)).toBe(false);
  });

  it('returns true for 1/4" TRS (used for MIDI on some pedals like GFI System)', () => {
    expect(isTrsMidiConnector('1/4" TRS')).toBe(true);
  });
});

// --- is5PinDinConnector ---

describe('is5PinDinConnector', () => {
  it('returns true for 5-pin DIN', () => {
    expect(is5PinDinConnector('5-pin DIN')).toBe(true);
  });

  it('returns true for DIN MIDI', () => {
    expect(is5PinDinConnector('DIN MIDI')).toBe(true);
  });

  it('returns false for 3.5mm TRS', () => {
    expect(is5PinDinConnector('3.5mm TRS')).toBe(false);
  });

  it('returns false for null', () => {
    expect(is5PinDinConnector(null)).toBe(false);
  });
});

// --- wouldCreateMidiCycle ---

describe('wouldCreateMidiCycle', () => {
  it('returns false for new unconnected items', () => {
    expect(wouldCreateMidiCycle('A', 'B', [])).toBe(false);
  });

  it('returns true when adding connection would close a loop', () => {
    const conns = [makeMidiConn({ sourceInstanceId: 'A', targetInstanceId: 'B' })];
    expect(wouldCreateMidiCycle('B', 'A', conns)).toBe(true);
  });

  it('returns true for indirect cycle A→B→C and C→A attempted', () => {
    const conns = [
      makeMidiConn({ id: '1', sourceInstanceId: 'A', targetInstanceId: 'B' }),
      makeMidiConn({ id: '2', sourceInstanceId: 'B', targetInstanceId: 'C' }),
    ];
    expect(wouldCreateMidiCycle('C', 'A', conns)).toBe(true);
  });

  it('returns false for non-cyclic addition', () => {
    const conns = [
      makeMidiConn({ id: '1', sourceInstanceId: 'A', targetInstanceId: 'B' }),
    ];
    expect(wouldCreateMidiCycle('A', 'C', conns)).toBe(false);
  });
});

// --- getChainDepth ---

describe('getChainDepth', () => {
  it('returns 0 for a root node (no incoming connections)', () => {
    expect(getChainDepth('A', [])).toBe(0);
  });

  it('returns 1 for a device one hop from the root', () => {
    const conns = [makeMidiConn({ sourceInstanceId: 'A', targetInstanceId: 'B' })];
    expect(getChainDepth('B', conns)).toBe(1);
  });

  it('returns 2 for a device two hops from root', () => {
    const conns = [
      makeMidiConn({ id: '1', sourceInstanceId: 'A', targetInstanceId: 'B' }),
      makeMidiConn({ id: '2', sourceInstanceId: 'B', targetInstanceId: 'C' }),
    ];
    expect(getChainDepth('C', conns)).toBe(2);
  });

  it('returns 0 for a node with no connections', () => {
    const conns = [makeMidiConn({ sourceInstanceId: 'X', targetInstanceId: 'Y' })];
    expect(getChainDepth('A', conns)).toBe(0);
  });
});

// --- validateMidiConnection ---

const baseSrcJack = { connector_type: '5-pin DIN', jack_name: 'MIDI Out' };
const baseTgtJack = { connector_type: '5-pin DIN', jack_name: 'MIDI In' };

describe('validateMidiConnection', () => {
  it('returns valid status for compatible 5-pin DIN jacks', () => {
    const result = validateMidiConnection(baseSrcJack, baseTgtJack, [], 'inst-a', 'inst-b');
    expect(result.status).toBe('valid');
    expect(result.warnings).toHaveLength(0);
  });

  it('returns warning with adapterImplication for 5-pin DIN to 3.5mm TRS', () => {
    const result = validateMidiConnection(
      { connector_type: '5-pin DIN', jack_name: 'MIDI Out' },
      { connector_type: '3.5mm TRS', jack_name: 'MIDI In' },
      [], 'inst-a', 'inst-b',
    );
    expect(result.status).toBe('warning');
    expect(result.warnings[0].key).toBe('midi:din-to-trs');
    expect(result.warnings[0].adapterImplication).toMatchObject({
      fromConnectorType: '5-pin DIN',
      toConnectorType: '3.5mm TRS',
    });
  });

  it('returns warning for 3.5mm TRS to 5-pin DIN', () => {
    const result = validateMidiConnection(
      { connector_type: '3.5mm TRS', jack_name: 'MIDI Out' },
      { connector_type: '5-pin DIN', jack_name: 'MIDI In' },
      [], 'inst-a', 'inst-b',
    );
    expect(result.status).toBe('warning');
    expect(result.warnings[0].key).toBe('midi:din-to-trs');
  });

  it('returns valid for matching 3.5mm TRS connectors', () => {
    const result = validateMidiConnection(
      { connector_type: '3.5mm TRS', jack_name: 'MIDI Out' },
      { connector_type: '3.5mm TRS', jack_name: 'MIDI In' },
      [], 'inst-a', 'inst-b',
    );
    expect(result.status).toBe('valid');
    expect(result.warnings).toHaveLength(0);
  });

  it('handles null connector types gracefully (no warning)', () => {
    const result = validateMidiConnection(
      { connector_type: null, jack_name: null },
      { connector_type: null, jack_name: null },
      [], 'inst-a', 'inst-b',
    );
    expect(result.status).toBe('valid');
    expect(result.warnings).toHaveLength(0);
  });

  it('returns warning for circular connection (MIDI loops are common)', () => {
    const conns = [makeMidiConn({ sourceInstanceId: 'inst-a', targetInstanceId: 'inst-b' })];
    const result = validateMidiConnection(baseSrcJack, baseTgtJack, conns, 'inst-b', 'inst-a');
    expect(result.status).toBe('warning');
    expect(result.warnings[0].key).toBe('midi:circular');
    expect(result.warnings[0].severity).toBe('warning');
  });

  it('returns info warning for chain depth > 4', () => {
    // Build a chain of depth 4: A→B→C→D→E, now adding E→F makes depth 5
    const conns = [
      makeMidiConn({ id: '1', sourceInstanceId: 'A', targetInstanceId: 'B' }),
      makeMidiConn({ id: '2', sourceInstanceId: 'B', targetInstanceId: 'C' }),
      makeMidiConn({ id: '3', sourceInstanceId: 'C', targetInstanceId: 'D' }),
      makeMidiConn({ id: '4', sourceInstanceId: 'D', targetInstanceId: 'E' }),
    ];
    const result = validateMidiConnection(baseSrcJack, baseTgtJack, conns, 'E', 'F');
    expect(result.warnings.some(w => w.key === 'midi:long-chain')).toBe(true);
    expect(result.warnings.find(w => w.key === 'midi:long-chain')!.severity).toBe('info');
  });

  it('returns warning when source jack already has a connection (shared output)', () => {
    const conns = [makeMidiConn({ sourceJackId: 10, sourceInstanceId: 'inst-a', targetJackId: 20, targetInstanceId: 'inst-b' })];
    const result = validateMidiConnection(baseSrcJack, baseTgtJack, conns, 'inst-a', 'inst-c', 10, 30);
    expect(result.warnings.some(w => w.key === 'midi:shared-output')).toBe(true);
    expect(result.warnings.find(w => w.key === 'midi:shared-output')!.severity).toBe('warning');
  });

  it('returns warning when target jack already has a connection (shared input)', () => {
    const conns = [makeMidiConn({ sourceJackId: 10, sourceInstanceId: 'inst-a', targetJackId: 20, targetInstanceId: 'inst-b' })];
    const result = validateMidiConnection(baseSrcJack, baseTgtJack, conns, 'inst-c', 'inst-b', 30, 20);
    expect(result.warnings.some(w => w.key === 'midi:shared-input')).toBe(true);
    expect(result.warnings.find(w => w.key === 'midi:shared-input')!.severity).toBe('warning');
  });

  it('does not warn for shared jacks when jackIds are not provided', () => {
    const conns = [makeMidiConn({ sourceJackId: 10, sourceInstanceId: 'inst-a', targetJackId: 20, targetInstanceId: 'inst-b' })];
    const result = validateMidiConnection(baseSrcJack, baseTgtJack, conns, 'inst-a', 'inst-c');
    expect(result.warnings.some(w => w.key === 'midi:shared-output')).toBe(false);
    expect(result.warnings.some(w => w.key === 'midi:shared-input')).toBe(false);
  });

  it('does not warn for chain depth <= 4', () => {
    const conns = [
      makeMidiConn({ id: '1', sourceInstanceId: 'A', targetInstanceId: 'B' }),
      makeMidiConn({ id: '2', sourceInstanceId: 'B', targetInstanceId: 'C' }),
    ];
    const result = validateMidiConnection(baseSrcJack, baseTgtJack, conns, 'C', 'D');
    expect(result.warnings.some(w => w.key === 'midi:long-chain')).toBe(false);
  });
});
