export interface RouteWaypoint { x: number; y: number; }

export interface AudioConnection {
  id: string;
  sourceJackId: number | string;   // number for real jacks, string for virtual/placeholder
  targetJackId: number | string;
  sourceInstanceId: string;
  targetInstanceId: string;
  acknowledgedWarnings?: string[];
  orderIndex: number;
  parallelPathId: string | null;
  fxLoopGroupId: string | null;
  signalMode: 'mono' | 'stereo';
  stereoPairConnectionId: string | null;
  waypoints: RouteWaypoint[];      // always [] in AudioView; reserved for Layout cable routing
}

export type VirtualNodeType =
  | 'guitar_input'
  | 'amp_input' | 'amp_fx_send' | 'amp_fx_return'
  | 'secondary_amp_input'
  | 'frfr_input'
  | 'direct_output'          // FOH / audio interface send
  | 'tuner_output';

export interface VirtualNode {
  instanceId: string;       // e.g. 'virtual:guitar-1'
  nodeType: VirtualNodeType;
  label: string;            // user-editable
  virtualJackId: string;    // e.g. 'virtual-jack:guitar-out'
  connectorType: string;    // '1/4" TS', 'XLR', etc.
}

/** A single configurable jack on a placeholder item */
export interface VirtualJackSpec {
  virtualJackId: string;    // e.g. 'placeholder:inst-x:out-0'
  direction: 'input' | 'output';
  connectorType: string;
  label: string;
  group_id: string | null;  // non-null links this jack to its stereo partner
}

/** A user-defined placeholder item with configurable jack layout, for planning
 *  signal chains before all gear is entered in the database. */
export interface AudioPlaceholder {
  instanceId: string;       // e.g. 'placeholder:uuid'
  label: string;            // user-editable, e.g. 'Reverb pedal'
  jacks: VirtualJackSpec[];
}

// Stubs for Phases 3–4 (defined but unused until MIDI/Control views)
export interface MidiConnection {
  id: string;
  sourceJackId: number;
  targetJackId: number;
  sourceInstanceId: string;
  targetInstanceId: string;
  acknowledgedWarnings?: string[];
  midiChannel: number | null;
  routesMidiClock: boolean;
}

export interface ControlConnection {
  id: string;
  sourceJackId: number;
  targetJackId: number;
  sourceInstanceId: string;
  targetInstanceId: string;
  acknowledgedWarnings?: string[];
  controlType: 'expression' | 'aux_switch' | 'cv' | 'other';
  polarityNormal: boolean;
}
