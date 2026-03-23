import { ReactNode } from 'react';
import DataTable, { ColumnDef, FilterConfig } from '../DataTable';
import { formatMsrp, formatDimensions, formatPower } from '../../utils/formatters';
import { useApiData } from '../../hooks/useApiData';
import { api } from '../../services/api';
import { transformMidiController, Jack } from '../../utils/transformers';
import { BooleanDetail, LinkDetail } from '../DetailHelpers';
import JacksList from '../JacksList';
import WorkbenchToggle from '../WorkbenchToggle';

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
  jacks: Jack[];
}

const columns: ColumnDef<MidiController>[] = [
  { label: 'Manufacturer', width: 180, sortKey: 'manufacturer',
    render: c => <span className="data-table__cell-manufacturer">{c.manufacturer}</span> },
  { label: 'Model', width: 200, sortKey: 'model',
    render: c => <span className="data-table__cell-model">{c.model}</span> },
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
    render: c => c.width_mm != null && c.depth_mm != null
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
    <BooleanDetail label="Per-Switch Displays" value={c.has_per_switch_displays} />
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
    <BooleanDetail label="Tuner" value={c.has_tuner} />
    <BooleanDetail label="Tap Tempo" value={c.has_tap_tempo} />
    <BooleanDetail label="Setlist Mode" value={c.has_setlist_mode} />
    <BooleanDetail label="Bluetooth MIDI" value={c.has_bluetooth_midi} />
    <BooleanDetail label="Software Editor" value={c.software_editor_available} />
    {c.software_platforms != null && (
      <div className="data-table__detail">
        <div className="data-table__detail-label">Platforms</div>
        <div className="data-table__detail-value">{c.software_platforms}</div>
      </div>
    )}
    <LinkDetail label="Product Page" url={c.product_page} />
    <LinkDetail label="Instruction Manual" url={c.instruction_manual} />
    <JacksList jacks={c.jacks} />
  </>
);

const stats = (data: MidiController[]) => {
  const inProd = data.filter(c => c.in_production).length;
  const loopSwitchers = data.filter(c => c.audio_loop_count > 0).length;
  return `${data.length} controllers \u00b7 ${inProd} in production \u00b7 ${loopSwitchers} loop switchers`;
};

const MidiControllers = () => {
  const { data, loading, error } = useApiData(api.getMidiControllers, transformMidiController);

  return (
    <DataTable<MidiController>
      title="MIDI Controller Database"
      entityName="controller"
      entityNamePlural="controllers"
      stats={stats}
      data={data}
      columns={columns}
      filters={filters}
      searchFields={['manufacturer', 'model']}
      searchPlaceholder="Search controllers..."
      renderExpandedRow={renderExpandedRow}
      renderRowAction={c => <WorkbenchToggle productId={c.id} productType="midi_controller" />}
      defaultSortKey="manufacturer"
      loading={loading}
      error={error}
    />
  );
};

export default MidiControllers;
