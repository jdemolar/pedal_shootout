import { ReactNode } from 'react';
import DataTable, { ColumnDef, FilterConfig } from '../DataTable';
import { formatMsrp, formatDimensions, formatPower } from '../../utils/formatters';

interface MidiController {
  id: number;
  manufacturer: string;
  model: string;
  in_production: boolean;
  width_mm: number | null;
  depth_mm: number | null;
  height_mm: number | null;
  weight_grams: number | null;
  msrp_cents: number | null;
  product_page: string | null;
  instruction_manual: string | null;
  data_reliability: 'High' | 'Medium' | 'Low' | null;
  // Controller-specific
  footswitch_count: number;
  total_preset_slots: number | null;
  audio_loop_count: number;
  expression_input_count: number;
  aux_switch_input_count: number;
  has_display: boolean;
  display_type: string | null;
  has_per_switch_displays: boolean;
  has_tuner: boolean;
  has_tap_tempo: boolean;
  has_setlist_mode: boolean;
  has_bluetooth_midi: boolean;
  software_editor_available: boolean;
  software_platforms: string | null;
  power_voltage: string | null;
  power_current_ma: number | null;
}

// TODO: Replace with API call to Spring Boot backend
const DATA: MidiController[] = [
  {
    "id": 185,
    "manufacturer": "RJM Music Technology",
    "model": "Mastermind LT",
    "in_production": true,
    "width_mm": 292.1,
    "depth_mm": 127.0,
    "height_mm": 69.85,
    "weight_grams": 862,
    "msrp_cents": 54900,
    "product_page": "https://www.rjmmusic.com/mastermind-lt/",
    "instruction_manual": "https://www.rjmmusic.com/download-content/MMLT/Mastermind%20LT%20Manual-3.1.pdf",
    "data_reliability": "High",
    "footswitch_count": 7,
    "total_preset_slots": 768,
    "audio_loop_count": 0,
    "expression_input_count": 1,
    "aux_switch_input_count": 2,
    "has_display": true,
    "display_type": "LCD",
    "has_per_switch_displays": false,
    "has_tuner": false,
    "has_tap_tempo": true,
    "has_setlist_mode": true,
    "has_bluetooth_midi": false,
    "software_editor_available": true,
    "software_platforms": "macOS, Windows",
    "power_voltage": "9-12V DC",
    "power_current_ma": 150
  },
  {
    "id": 186,
    "manufacturer": "RJM Music Technology",
    "model": "Mastermind GT/10",
    "in_production": true,
    "width_mm": 492.76,
    "depth_mm": 205.74,
    "height_mm": 82.55,
    "weight_grams": 2722,
    "msrp_cents": 149900,
    "product_page": "https://www.rjmmusic.com/mastermind-gt-10/",
    "instruction_manual": "https://www.rjmmusic.com/download-content/MMGT/Mastermind%20GT%20Manual-4.3.pdf",
    "data_reliability": "High",
    "footswitch_count": 10,
    "total_preset_slots": 768,
    "audio_loop_count": 0,
    "expression_input_count": 4,
    "aux_switch_input_count": 4,
    "has_display": true,
    "display_type": "LCD",
    "has_per_switch_displays": true,
    "has_tuner": false,
    "has_tap_tempo": true,
    "has_setlist_mode": true,
    "has_bluetooth_midi": false,
    "software_editor_available": true,
    "software_platforms": "macOS, Windows",
    "power_voltage": "12V DC",
    "power_current_ma": 1000
  },
  {
    "id": 187,
    "manufacturer": "RJM Music Technology",
    "model": "Mastermind GT/16",
    "in_production": true,
    "width_mm": 492.76,
    "depth_mm": 281.94,
    "height_mm": 82.55,
    "weight_grams": 3629,
    "msrp_cents": 199900,
    "product_page": "https://www.rjmmusic.com/mastermind-gt-16/",
    "instruction_manual": "https://www.rjmmusic.com/download-content/MMGT/Mastermind%20GT%20Manual-4.3.pdf",
    "data_reliability": "High",
    "footswitch_count": 16,
    "total_preset_slots": 768,
    "audio_loop_count": 0,
    "expression_input_count": 4,
    "aux_switch_input_count": 4,
    "has_display": true,
    "display_type": "LCD",
    "has_per_switch_displays": true,
    "has_tuner": false,
    "has_tap_tempo": true,
    "has_setlist_mode": true,
    "has_bluetooth_midi": false,
    "software_editor_available": true,
    "software_platforms": "macOS, Windows",
    "power_voltage": "12V DC",
    "power_current_ma": 1500
  },
  {
    "id": 188,
    "manufacturer": "RJM Music Technology",
    "model": "Mastermind GT/22",
    "in_production": true,
    "width_mm": 492.76,
    "depth_mm": 358.14,
    "height_mm": 82.55,
    "weight_grams": 4536,
    "msrp_cents": 225000,
    "product_page": "https://www.rjmmusic.com/mastermind-gt-22/",
    "instruction_manual": "https://www.rjmmusic.com/download-content/MMGT/Mastermind%20GT%20Manual-4.3.pdf",
    "data_reliability": "High",
    "footswitch_count": 22,
    "total_preset_slots": 768,
    "audio_loop_count": 0,
    "expression_input_count": 4,
    "aux_switch_input_count": 4,
    "has_display": true,
    "display_type": "LCD",
    "has_per_switch_displays": true,
    "has_tuner": false,
    "has_tap_tempo": true,
    "has_setlist_mode": true,
    "has_bluetooth_midi": false,
    "software_editor_available": true,
    "software_platforms": "macOS, Windows",
    "power_voltage": "12V DC",
    "power_current_ma": 2000
  },
  {
    "id": 189,
    "manufacturer": "RJM Music Technology",
    "model": "Mastermind PBC/6X",
    "in_production": true,
    "width_mm": 256.54,
    "depth_mm": 111.76,
    "height_mm": 60.96,
    "weight_grams": 907,
    "msrp_cents": 89900,
    "product_page": "https://www.rjmmusic.com/mastermind-pbc-6x/",
    "instruction_manual": "https://www.rjmmusic.com/download-content/PBC6X/PBC6X%20Manual-4.3.pdf",
    "data_reliability": "High",
    "footswitch_count": 7,
    "total_preset_slots": 768,
    "audio_loop_count": 6,
    "expression_input_count": 1,
    "aux_switch_input_count": 2,
    "has_display": true,
    "display_type": "LCD",
    "has_per_switch_displays": false,
    "has_tuner": true,
    "has_tap_tempo": true,
    "has_setlist_mode": true,
    "has_bluetooth_midi": false,
    "software_editor_available": true,
    "software_platforms": "macOS, Windows",
    "power_voltage": "9-12V DC",
    "power_current_ma": 220
  },
  {
    "id": 190,
    "manufacturer": "RJM Music Technology",
    "model": "Mastermind PBC/10",
    "in_production": true,
    "width_mm": 444.5,
    "depth_mm": 139.7,
    "height_mm": 84.58,
    "weight_grams": 1814,
    "msrp_cents": 124900,
    "product_page": "https://www.rjmmusic.com/mastermind-pbc-2/",
    "instruction_manual": "https://www.rjmmusic.com/download-content/PBC/PBC%20Manual-4.0.pdf",
    "data_reliability": "High",
    "footswitch_count": 11,
    "total_preset_slots": 625,
    "audio_loop_count": 10,
    "expression_input_count": 1,
    "aux_switch_input_count": 4,
    "has_display": true,
    "display_type": "LCD",
    "has_per_switch_displays": false,
    "has_tuner": true,
    "has_tap_tempo": true,
    "has_setlist_mode": true,
    "has_bluetooth_midi": false,
    "software_editor_available": true,
    "software_platforms": "macOS, Windows",
    "power_voltage": "9V DC / 12V DC / 9V AC",
    "power_current_ma": 500
  }
];

const columns: ColumnDef<MidiController>[] = [
  { label: 'Manufacturer', width: 180, sortKey: 'manufacturer',
    render: c => <span style={{ color: '#f0f0f0', fontSize: '12.5px', fontWeight: 600, fontFamily: "'Helvetica Neue', sans-serif" }}>{c.manufacturer}</span> },
  { label: 'Model', width: 200, sortKey: 'model',
    render: c => <span style={{ color: '#d0d0d0' }}>{c.model}</span> },
  { label: 'Switches', width: 80, align: 'center', sortKey: 'footswitch_count',
    render: c => <>{c.footswitch_count}</> },
  { label: 'Presets', width: 80, align: 'right', sortKey: 'total_preset_slots',
    render: c => c.total_preset_slots != null
      ? <>{c.total_preset_slots.toLocaleString()}</>
      : <span className="null-value">{'\u2014'}</span> },
  { label: 'Loops', width: 70, align: 'center', sortKey: 'audio_loop_count',
    render: c => c.audio_loop_count > 0
      ? <span className="loop-badge">{c.audio_loop_count}</span>
      : <span className="null-value">{'\u2014'}</span> },
  { label: 'Status', width: 80, align: 'center', sortKey: 'in_production',
    render: c => (
      <span className={`status-badge status-badge--${c.in_production ? 'in-production' : 'discontinued'}`}>
        {c.in_production ? 'Active' : 'Disc.'}
      </span>
    ) },
  { label: 'MSRP', width: 90, align: 'right', sortKey: 'msrp_cents',
    render: c => c.msrp_cents != null
      ? <>{formatMsrp(c.msrp_cents)}</>
      : <span className="null-value">{'\u2014'}</span> },
  { label: 'Dimensions', width: 180, align: 'center',
    render: c => c.width_mm != null && c.depth_mm != null && c.height_mm != null
      ? <>{formatDimensions(c.width_mm, c.depth_mm, c.height_mm)}</>
      : <span className="null-value">{'\u2014'}</span> },
  { label: 'Power', width: 120, align: 'center',
    render: c => c.power_voltage != null || c.power_current_ma != null
      ? <>{formatPower(c.power_voltage, c.power_current_ma)}</>
      : <span className="null-value">{'\u2014'}</span> },
  { label: 'Reliability', width: 80, align: 'center', sortKey: 'data_reliability',
    render: c => c.data_reliability
      ? <span className={`reliability-badge reliability-badge--${c.data_reliability.toLowerCase()}`}>{c.data_reliability}</span>
      : <span className="null-value">{'\u2014'}</span> },
];

const filters: FilterConfig<MidiController>[] = [
  { label: 'Type', options: ['All', 'Pure MIDI', 'Loop Switcher'],
    predicate: (c, v) => v === 'Loop Switcher' ? c.audio_loop_count > 0 : c.audio_loop_count === 0 },
  { label: 'Status', options: ['All', 'In Production', 'Discontinued'],
    predicate: (c, v) => (v === 'In Production') === c.in_production },
  { label: 'Reliability', options: ['All', 'High', 'Medium', 'Low'],
    predicate: (c, v) => c.data_reliability === v },
];

const renderExpandedRow = (c: MidiController): ReactNode => (
  <>
    {c.display_type != null && (
      <div className="data-table__detail">
        <div className="data-table__detail-label">Display</div>
        <div className="data-table__detail-value">{c.display_type}</div>
      </div>
    )}
    <div className="data-table__detail">
      <div className="data-table__detail-label">Per-Switch Displays</div>
      <div className="data-table__detail-value">
        <span className={c.has_per_switch_displays ? 'bool-yes' : 'bool-no'}>
          {c.has_per_switch_displays ? 'Yes' : 'No'}
        </span>
      </div>
    </div>
    <div className="data-table__detail">
      <div className="data-table__detail-label">Expression Inputs</div>
      <div className="data-table__detail-value data-table__detail-value--highlight">
        {c.expression_input_count}
      </div>
    </div>
    <div className="data-table__detail">
      <div className="data-table__detail-label">Aux Switch Inputs</div>
      <div className="data-table__detail-value">{c.aux_switch_input_count}</div>
    </div>
    <div className="data-table__detail">
      <div className="data-table__detail-label">Tuner</div>
      <div className="data-table__detail-value">
        <span className={c.has_tuner ? 'bool-yes' : 'bool-no'}>{c.has_tuner ? 'Yes' : 'No'}</span>
      </div>
    </div>
    <div className="data-table__detail">
      <div className="data-table__detail-label">Tap Tempo</div>
      <div className="data-table__detail-value">
        <span className={c.has_tap_tempo ? 'bool-yes' : 'bool-no'}>{c.has_tap_tempo ? 'Yes' : 'No'}</span>
      </div>
    </div>
    <div className="data-table__detail">
      <div className="data-table__detail-label">Setlist Mode</div>
      <div className="data-table__detail-value">
        <span className={c.has_setlist_mode ? 'bool-yes' : 'bool-no'}>{c.has_setlist_mode ? 'Yes' : 'No'}</span>
      </div>
    </div>
    <div className="data-table__detail">
      <div className="data-table__detail-label">Bluetooth MIDI</div>
      <div className="data-table__detail-value">
        <span className={c.has_bluetooth_midi ? 'bool-yes' : 'bool-no'}>{c.has_bluetooth_midi ? 'Yes' : 'No'}</span>
      </div>
    </div>
    <div className="data-table__detail">
      <div className="data-table__detail-label">Software Editor</div>
      <div className="data-table__detail-value">
        <span className={c.software_editor_available ? 'bool-yes' : 'bool-no'}>{c.software_editor_available ? 'Yes' : 'No'}</span>
      </div>
    </div>
    {c.software_platforms != null && (
      <div className="data-table__detail">
        <div className="data-table__detail-label">Platforms</div>
        <div className="data-table__detail-value">{c.software_platforms}</div>
      </div>
    )}
    {c.product_page != null && (
      <div className="data-table__detail">
        <div className="data-table__detail-label">Product Page</div>
        <div className="data-table__detail-value">
          <a href={c.product_page} target="_blank" rel="noopener noreferrer" onClick={e => e.stopPropagation()} className="detail-link">
            {c.product_page}
          </a>
        </div>
      </div>
    )}
    {c.instruction_manual != null && (
      <div className="data-table__detail">
        <div className="data-table__detail-label">Instruction Manual</div>
        <div className="data-table__detail-value">
          <a href={c.instruction_manual} target="_blank" rel="noopener noreferrer" onClick={e => e.stopPropagation()} className="detail-link">
            {c.instruction_manual}
          </a>
        </div>
      </div>
    )}
  </>
);

const stats = (data: MidiController[]) => {
  const inProd = data.filter(c => c.in_production).length;
  const loopSwitchers = data.filter(c => c.audio_loop_count > 0).length;
  return `${data.length} controllers \u00b7 ${inProd} in production \u00b7 ${loopSwitchers} loop switchers`;
};

const MidiControllers = () => (
  <DataTable<MidiController>
    title="MIDI Controller Database"
    entityName="controller"
    entityNamePlural="controllers"
    stats={stats}
    data={DATA}
    columns={columns}
    filters={filters}
    searchFields={['manufacturer', 'model']}
    searchPlaceholder="Search controllers..."
    renderExpandedRow={renderExpandedRow}
    defaultSortKey="manufacturer"
  />
);

export default MidiControllers;
