import {
  computeShoppingList,
  deriveCableLabel,
  isCustomCable,
} from '../../utils/shoppingListUtils';
import { Jack } from '../../utils/transformers';
import { PowerConnection } from '../../context/WorkbenchContext';
import { AudioConnection, MidiConnection, ControlConnection } from '../../types/connections';

function makeJack(overrides: Partial<Jack> = {}): Jack {
  return {
    id: 1,
    category: 'audio',
    direction: 'output',
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

function makeAudioConnection(overrides: Partial<AudioConnection> = {}): AudioConnection {
  return {
    id: 'audio-1',
    sourceJackId: 1,
    targetJackId: 2,
    sourceInstanceId: 'inst-1',
    targetInstanceId: 'inst-2',
    orderIndex: 0,
    parallelPathId: null,
    fxLoopGroupId: null,
    signalMode: 'mono',
    stereoPairConnectionId: null,
    waypoints: [],
    ...overrides,
  };
}

function makePowerConnection(overrides: Partial<PowerConnection> = {}): PowerConnection {
  return {
    id: 'power-1',
    sourceJackId: 10,
    targetJackId: 11,
    sourceInstanceId: 'psu-1',
    targetInstanceId: 'pedal-1',
    ...overrides,
  };
}

function makeMidiConnection(overrides: Partial<MidiConnection> = {}): MidiConnection {
  return {
    id: 'midi-1',
    sourceJackId: 20,
    targetJackId: 21,
    sourceInstanceId: 'ctrl-1',
    targetInstanceId: 'pedal-1',
    chainIndex: 0,
    trsMidiStandard: null,
    ...overrides,
  };
}

function makeControlConnection(overrides: Partial<ControlConnection> = {}): ControlConnection {
  return {
    id: 'ctrl-1',
    sourceJackId: 30,
    targetJackId: 31,
    sourceInstanceId: 'exp-1',
    targetInstanceId: 'pedal-1',
    controlType: 'expression',
    trsPolarity: null,
    ...overrides,
  };
}

describe('isCustomCable', () => {
  it('returns false when connectors match', () => {
    expect(isCustomCable('1/4" TS', '1/4" TS')).toBe(false);
  });

  it('returns true when connectors differ', () => {
    expect(isCustomCable('5-pin DIN', '3.5mm TRS')).toBe(true);
  });

  it('returns false when source is null', () => {
    expect(isCustomCable(null, '1/4" TS')).toBe(false);
  });

  it('returns false when target is null', () => {
    expect(isCustomCable('1/4" TS', null)).toBe(false);
  });

  it('returns false when both are null', () => {
    expect(isCustomCable(null, null)).toBe(false);
  });
});

describe('deriveCableLabel', () => {
  it('produces simple label for matching audio connectors', () => {
    expect(deriveCableLabel('1/4" TS', '1/4" TS', 'audio')).toBe('1/4" TS patch cable');
  });

  it('produces "A to B" label for mismatched connectors', () => {
    expect(deriveCableLabel('5-pin DIN', '3.5mm TRS', 'midi')).toBe('5-pin DIN to 3.5mm TRS MIDI cable');
  });

  it('produces fallback label when source is null', () => {
    expect(deriveCableLabel(null, '1/4" TS', 'audio')).toBe('audio cable (connector unknown)');
  });

  it('produces fallback label when target is null', () => {
    expect(deriveCableLabel('1/4" TS', null, 'audio')).toBe('audio cable (connector unknown)');
  });

  it('uses "DC power" suffix for power category', () => {
    expect(deriveCableLabel('2.1mm barrel', '2.1mm barrel', 'power')).toBe('2.1mm barrel DC power cable');
  });

  it('uses "MIDI" suffix for midi category', () => {
    expect(deriveCableLabel('5-pin DIN', '5-pin DIN', 'midi')).toBe('5-pin DIN MIDI cable');
  });

  it('uses control sub-type for expression', () => {
    expect(deriveCableLabel('1/4" TRS', '1/4" TRS', 'control', 'expression')).toBe('1/4" TRS expression cable');
  });

  it('uses control sub-type for auxiliary', () => {
    expect(deriveCableLabel('1/4" TRS', '1/4" TRS', 'control', 'auxiliary')).toBe('1/4" TRS auxiliary cable');
  });

  it('uses control sub-type for CV', () => {
    expect(deriveCableLabel('3.5mm TS', '3.5mm TS', 'control', 'CV')).toBe('3.5mm TS CV cable');
  });

  it('uses "control" as default suffix for control category without sub-type', () => {
    expect(deriveCableLabel('1/4" TRS', '1/4" TRS', 'control')).toBe('1/4" TRS control cable');
  });
});

describe('computeShoppingList', () => {
  it('returns empty list with no connections', () => {
    const result = computeShoppingList([], [], [], [], new Map());
    expect(result.cables).toEqual([]);
    expect(result.summary.totalCables).toBe(0);
    expect(result.summary.totalCustomCables).toBe(0);
    expect(result.summary.byCategory).toEqual({ audio: 0, power: 0, midi: 0, control: 0 });
  });

  it('creates a cable requirement for a single audio connection', () => {
    const jackMap = new Map<number, Jack>([
      [1, makeJack({ id: 1, connector_type: '1/4" TS' })],
      [2, makeJack({ id: 2, connector_type: '1/4" TS', direction: 'input' })],
    ]);
    const audio = [makeAudioConnection()];
    const result = computeShoppingList([], audio, [], [], jackMap);

    expect(result.cables).toHaveLength(1);
    expect(result.cables[0].category).toBe('audio');
    expect(result.cables[0].label).toBe('1/4" TS patch cable');
    expect(result.cables[0].quantity).toBe(1);
    expect(result.cables[0].requiresCustomCable).toBe(false);
    expect(result.cables[0].notes).toEqual([]);
    expect(result.cables[0].connectionIds).toEqual(['audio-1']);
  });

  it('groups identical cable types and increments quantity', () => {
    const jackMap = new Map<number, Jack>([
      [1, makeJack({ id: 1, connector_type: '1/4" TS' })],
      [2, makeJack({ id: 2, connector_type: '1/4" TS', direction: 'input' })],
      [3, makeJack({ id: 3, connector_type: '1/4" TS' })],
      [4, makeJack({ id: 4, connector_type: '1/4" TS', direction: 'input' })],
    ]);
    const audio = [
      makeAudioConnection({ id: 'a1', sourceJackId: 1, targetJackId: 2 }),
      makeAudioConnection({ id: 'a2', sourceJackId: 3, targetJackId: 4 }),
    ];
    const result = computeShoppingList([], audio, [], [], jackMap);

    expect(result.cables).toHaveLength(1);
    expect(result.cables[0].quantity).toBe(2);
    expect(result.cables[0].connectionIds).toEqual(['a1', 'a2']);
  });

  it('detects mismatched connectors as custom cable', () => {
    const jackMap = new Map<number, Jack>([
      [1, makeJack({ id: 1, connector_type: '1/4" TS' })],
      [2, makeJack({ id: 2, connector_type: 'XLR', direction: 'input' })],
    ]);
    const audio = [makeAudioConnection()];
    const result = computeShoppingList([], audio, [], [], jackMap);

    expect(result.cables).toHaveLength(1);
    expect(result.cables[0].requiresCustomCable).toBe(true);
    expect(result.cables[0].label).toBe('1/4" TS to XLR patch cable');
    expect(result.cables[0].notes).toContain('Mismatched connectors \u2014 custom cable or adapter needed');
  });

  it('handles null connector types gracefully', () => {
    const jackMap = new Map<number, Jack>([
      [1, makeJack({ id: 1, connector_type: null })],
      [2, makeJack({ id: 2, connector_type: '1/4" TS', direction: 'input' })],
    ]);
    const audio = [makeAudioConnection()];
    const result = computeShoppingList([], audio, [], [], jackMap);

    expect(result.cables).toHaveLength(1);
    expect(result.cables[0].label).toBe('audio cable (connector unknown)');
    expect(result.cables[0].requiresCustomCable).toBe(false);
    expect(result.cables[0].notes).toContain('Connector type unknown for one or both ends');
  });

  it('handles missing jacks in jackMap', () => {
    const jackMap = new Map<number, Jack>();
    const audio = [makeAudioConnection({ sourceJackId: 999, targetJackId: 998 })];
    const result = computeShoppingList([], audio, [], [], jackMap);

    expect(result.cables).toHaveLength(1);
    expect(result.cables[0].label).toBe('audio cable (connector unknown)');
  });

  it('processes power connections', () => {
    const jackMap = new Map<number, Jack>([
      [10, makeJack({ id: 10, category: 'power', connector_type: '2.1mm barrel' })],
      [11, makeJack({ id: 11, category: 'power', connector_type: '2.1mm barrel', direction: 'input' })],
    ]);
    const power = [makePowerConnection()];
    const result = computeShoppingList(power, [], [], [], jackMap);

    expect(result.cables).toHaveLength(1);
    expect(result.cables[0].category).toBe('power');
    expect(result.cables[0].label).toBe('2.1mm barrel DC power cable');
    expect(result.summary.byCategory.power).toBe(1);
  });

  it('processes MIDI connections', () => {
    const jackMap = new Map<number, Jack>([
      [20, makeJack({ id: 20, category: 'midi', connector_type: '5-pin DIN' })],
      [21, makeJack({ id: 21, category: 'midi', connector_type: '5-pin DIN', direction: 'input' })],
    ]);
    const midi = [makeMidiConnection()];
    const result = computeShoppingList([], [], midi, [], jackMap);

    expect(result.cables).toHaveLength(1);
    expect(result.cables[0].category).toBe('midi');
    expect(result.cables[0].label).toBe('5-pin DIN MIDI cable');
    expect(result.summary.byCategory.midi).toBe(1);
  });

  it('processes control connections with sub-type label', () => {
    const jackMap = new Map<number, Jack>([
      [30, makeJack({ id: 30, category: 'expression', connector_type: '1/4" TRS' })],
      [31, makeJack({ id: 31, category: 'expression', connector_type: '1/4" TRS', direction: 'input' })],
    ]);
    const control = [makeControlConnection({ controlType: 'expression' })];
    const result = computeShoppingList([], [], [], control, jackMap);

    expect(result.cables).toHaveLength(1);
    expect(result.cables[0].category).toBe('control');
    expect(result.cables[0].label).toBe('1/4" TRS expression cable');
    expect(result.summary.byCategory.control).toBe(1);
  });

  it('uses "auxiliary" for aux_switch control type', () => {
    const jackMap = new Map<number, Jack>([
      [30, makeJack({ id: 30, connector_type: '1/4" TRS' })],
      [31, makeJack({ id: 31, connector_type: '1/4" TRS', direction: 'input' })],
    ]);
    const control = [makeControlConnection({ controlType: 'aux_switch' })];
    const result = computeShoppingList([], [], [], control, jackMap);

    expect(result.cables[0].label).toBe('1/4" TRS auxiliary cable');
  });

  it('uses "CV" for cv control type', () => {
    const jackMap = new Map<number, Jack>([
      [30, makeJack({ id: 30, connector_type: '3.5mm TS' })],
      [31, makeJack({ id: 31, connector_type: '3.5mm TS', direction: 'input' })],
    ]);
    const control = [makeControlConnection({ controlType: 'cv' })];
    const result = computeShoppingList([], [], [], control, jackMap);

    expect(result.cables[0].label).toBe('3.5mm TS CV cable');
  });

  it('computes correct summary across all categories', () => {
    const jackMap = new Map<number, Jack>([
      [1, makeJack({ id: 1, connector_type: '1/4" TS' })],
      [2, makeJack({ id: 2, connector_type: '1/4" TS' })],
      [3, makeJack({ id: 3, connector_type: '1/4" TS' })],
      [4, makeJack({ id: 4, connector_type: '1/4" TS' })],
      [10, makeJack({ id: 10, connector_type: '2.1mm barrel' })],
      [11, makeJack({ id: 11, connector_type: '2.1mm barrel' })],
      [20, makeJack({ id: 20, connector_type: '5-pin DIN' })],
      [21, makeJack({ id: 21, connector_type: '3.5mm TRS' })],
      [30, makeJack({ id: 30, connector_type: '1/4" TRS' })],
      [31, makeJack({ id: 31, connector_type: '1/4" TRS' })],
    ]);

    const result = computeShoppingList(
      [makePowerConnection({ sourceJackId: 10, targetJackId: 11 })],
      [
        makeAudioConnection({ id: 'a1', sourceJackId: 1, targetJackId: 2 }),
        makeAudioConnection({ id: 'a2', sourceJackId: 3, targetJackId: 4 }),
      ],
      [makeMidiConnection({ sourceJackId: 20, targetJackId: 21 })],
      [makeControlConnection({ sourceJackId: 30, targetJackId: 31 })],
      jackMap,
    );

    expect(result.summary.totalCables).toBe(5);
    expect(result.summary.totalCustomCables).toBe(1); // MIDI: 5-pin DIN to 3.5mm TRS
    expect(result.summary.byCategory.audio).toBe(2);
    expect(result.summary.byCategory.power).toBe(1);
    expect(result.summary.byCategory.midi).toBe(1);
    expect(result.summary.byCategory.control).toBe(1);
  });

  it('groups multiple identical mismatched cables', () => {
    const jackMap = new Map<number, Jack>([
      [20, makeJack({ id: 20, connector_type: '5-pin DIN' })],
      [21, makeJack({ id: 21, connector_type: '3.5mm TRS' })],
      [22, makeJack({ id: 22, connector_type: '5-pin DIN' })],
      [23, makeJack({ id: 23, connector_type: '3.5mm TRS' })],
    ]);
    const midi = [
      makeMidiConnection({ id: 'm1', sourceJackId: 20, targetJackId: 21 }),
      makeMidiConnection({ id: 'm2', sourceJackId: 22, targetJackId: 23, chainIndex: 1 }),
    ];
    const result = computeShoppingList([], [], midi, [], jackMap);

    expect(result.cables).toHaveLength(1);
    expect(result.cables[0].quantity).toBe(2);
    expect(result.cables[0].requiresCustomCable).toBe(true);
    expect(result.summary.totalCustomCables).toBe(2);
  });

  it('handles audio connections with string jackIds (virtual/placeholder)', () => {
    const jackMap = new Map<number, Jack>([
      [1, makeJack({ id: 1, connector_type: '1/4" TS' })],
    ]);
    const audio = [makeAudioConnection({ sourceJackId: 'virtual-jack:guitar-out', targetJackId: 1 })];
    const result = computeShoppingList([], audio, [], [], jackMap);

    // Virtual jack has no entry in jackMap, so source connector is null
    expect(result.cables).toHaveLength(1);
    expect(result.cables[0].label).toBe('audio cable (connector unknown)');
  });
});
