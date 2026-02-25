export interface RouteWaypoint { x: number; y: number; }

export interface AudioConnection {
  id: string;
  sourceJackId: number | string;   // number for real jacks, string for virtual (e.g. 'virtual-jack:guitar-out')
  targetJackId: number | string;
  sourceInstanceId: string;
  targetInstanceId: string;
  acknowledgedWarnings?: string[];
  orderIndex: number;
  parallelPathId: string | null;
  fxLoopGroupId: string | null;
  signalMode: 'mono' | 'stereo';
  stereoPairConnectionId: string | null;
  waypoints: RouteWaypoint[];
}

export type VirtualNodeType =
  | 'guitar_input' | 'amp_input' | 'amp_fx_send' | 'amp_fx_return'
  | 'secondary_amp_input' | 'direct_output' | 'tuner_output';

export interface VirtualNode {
  instanceId: string;       // e.g. 'virtual:guitar-1'
  nodeType: VirtualNodeType;
  label: string;            // user-editable
  virtualJackId: string;    // e.g. 'virtual-jack:guitar-out'
  connectorType: string;    // default '1/4" TS'
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
