import { ReactNode, useMemo } from 'react';
import DataTable, { ColumnDef, FilterConfig } from '../DataTable';
import { formatMsrp, formatDimensions, formatPower } from '../../utils/formatters';
import { useApiData } from '../../hooks/useApiData';
import { api } from '../../services/api';
import { transformPedal } from '../../utils/transformers';

interface Pedal {
  id: number;
  manufacturer: string;
  model: string;
  effect_type: string | null;
  in_production: boolean;
  width_mm: number | null;
  depth_mm: number | null;
  height_mm: number | null;
  weight_grams: number | null;
  msrp_cents: number | null;
  product_page: string | null;
  instruction_manual: string | null;
  image_path: string | null;
  color_options: string | null;
  data_reliability: 'High' | 'Medium' | 'Low' | null;
  bypass_type: string | null;
  signal_type: string | null;
  circuit_type: string | null;
  mono_stereo: string | null;
  preset_count: number;
  midi_capable: boolean;
  has_tap_tempo: boolean;
  battery_capable: boolean;
  has_software_editor: boolean;
  power_voltage: string | null;
  power_current_ma: number | null;
}

const columns: ColumnDef<Pedal>[] = [
  { label: 'Manufacturer', width: 160, sortKey: 'manufacturer',
    render: p => <span style={{ color: '#f0f0f0', fontSize: '12.5px', fontWeight: 600, fontFamily: "'Helvetica Neue', sans-serif" }}>{p.manufacturer}</span> },
  { label: 'Model', width: 200, sortKey: 'model',
    render: p => <span style={{ color: '#d0d0d0' }}>{p.model}</span> },
  { label: 'Type', width: 120, align: 'center', sortKey: 'effect_type',
    render: p => p.effect_type
      ? <span className={`effect-badge effect-badge--${p.effect_type.toLowerCase().replace(/[\s/]+/g, '-')}`}>{p.effect_type}</span>
      : <span className="null-value">{'\u2014'}</span> },
  { label: 'Status', width: 80, align: 'center', sortKey: 'in_production',
    render: p => (
      <span className={`status-badge status-badge--${p.in_production ? 'in-production' : 'discontinued'}`}>
        {p.in_production ? 'Active' : 'Disc.'}
      </span>
    ) },
  { label: 'MSRP', width: 80, align: 'right', sortKey: 'msrp_cents',
    render: p => p.msrp_cents != null
      ? <>{formatMsrp(p.msrp_cents)}</>
      : <span className="null-value">{'\u2014'}</span> },
  { label: 'Dimensions', width: 160, align: 'center',
    render: p => p.width_mm != null && p.depth_mm != null && p.height_mm != null
      ? <>{formatDimensions(p.width_mm, p.depth_mm, p.height_mm)}</>
      : <span className="null-value">{'\u2014'}</span> },
  { label: 'Power', width: 100, align: 'center',
    render: p => p.power_voltage != null || p.power_current_ma != null
      ? <>{formatPower(p.power_voltage, p.power_current_ma)}</>
      : <span className="null-value">{'\u2014'}</span> },
  { label: 'Reliability', width: 80, align: 'center', sortKey: 'data_reliability',
    render: p => p.data_reliability
      ? <span className={`reliability-badge reliability-badge--${p.data_reliability.toLowerCase()}`}>{p.data_reliability}</span>
      : <span className="null-value">{'\u2014'}</span> },
];

const renderExpandedRow = (p: Pedal): ReactNode => (
  <>
    {p.bypass_type != null && (
      <div className="data-table__detail">
        <div className="data-table__detail-label">Bypass Type</div>
        <div className="data-table__detail-value">{p.bypass_type}</div>
      </div>
    )}
    {p.signal_type != null && (
      <div className="data-table__detail">
        <div className="data-table__detail-label">Signal Type</div>
        <div className="data-table__detail-value">{p.signal_type}</div>
      </div>
    )}
    {p.circuit_type != null && (
      <div className="data-table__detail">
        <div className="data-table__detail-label">Circuit Type</div>
        <div className="data-table__detail-value">{p.circuit_type}</div>
      </div>
    )}
    {p.mono_stereo != null && (
      <div className="data-table__detail">
        <div className="data-table__detail-label">Mono/Stereo</div>
        <div className="data-table__detail-value">{p.mono_stereo}</div>
      </div>
    )}
    <div className="data-table__detail">
      <div className="data-table__detail-label">MIDI Capable</div>
      <div className="data-table__detail-value">
        <span className={p.midi_capable ? 'bool-yes' : 'bool-no'}>{p.midi_capable ? 'Yes' : 'No'}</span>
      </div>
    </div>
    {p.preset_count > 0 && (
      <div className="data-table__detail">
        <div className="data-table__detail-label">Presets</div>
        <div className="data-table__detail-value data-table__detail-value--highlight">{p.preset_count}</div>
      </div>
    )}
    <div className="data-table__detail">
      <div className="data-table__detail-label">Tap Tempo</div>
      <div className="data-table__detail-value">
        <span className={p.has_tap_tempo ? 'bool-yes' : 'bool-no'}>{p.has_tap_tempo ? 'Yes' : 'No'}</span>
      </div>
    </div>
    <div className="data-table__detail">
      <div className="data-table__detail-label">Battery</div>
      <div className="data-table__detail-value">
        <span className={p.battery_capable ? 'bool-yes' : 'bool-no'}>{p.battery_capable ? 'Yes' : 'No'}</span>
      </div>
    </div>
    <div className="data-table__detail">
      <div className="data-table__detail-label">Software Editor</div>
      <div className="data-table__detail-value">
        <span className={p.has_software_editor ? 'bool-yes' : 'bool-no'}>{p.has_software_editor ? 'Yes' : 'No'}</span>
      </div>
    </div>
    {p.color_options != null && (
      <div className="data-table__detail">
        <div className="data-table__detail-label">Color Options</div>
        <div className="data-table__detail-value">{p.color_options}</div>
      </div>
    )}
    {p.product_page != null && (
      <div className="data-table__detail">
        <div className="data-table__detail-label">Product Page</div>
        <div className="data-table__detail-value">
          <a href={p.product_page} target="_blank" rel="noopener noreferrer" onClick={e => e.stopPropagation()} className="detail-link">
            {p.product_page}
          </a>
        </div>
      </div>
    )}
    {p.instruction_manual != null && (
      <div className="data-table__detail">
        <div className="data-table__detail-label">Instruction Manual</div>
        <div className="data-table__detail-value">
          <a href={p.instruction_manual} target="_blank" rel="noopener noreferrer" onClick={e => e.stopPropagation()} className="detail-link">
            {p.instruction_manual}
          </a>
        </div>
      </div>
    )}
  </>
);

const stats = (data: Pedal[]) => {
  const inProd = data.filter(p => p.in_production).length;
  const types = new Set(data.map(p => p.effect_type).filter(t => t !== null)).size;
  return `${data.length} pedals \u00b7 ${inProd} in production \u00b7 ${types} effect types`;
};

const Pedals = () => {
  const { data, loading, error } = useApiData(api.getPedals, transformPedal);

  const effectTypes = useMemo(
    () => ['All', ...Array.from(new Set(data.map(d => d.effect_type).filter((t): t is string => t !== null))).sort()],
    [data]
  );

  const filters: FilterConfig<Pedal>[] = useMemo(() => [
    { label: 'Type', options: effectTypes,
      predicate: (p, v) => p.effect_type === v },
    { label: 'Status', options: ['All', 'In Production', 'Discontinued'],
      predicate: (p, v) => (v === 'In Production') === p.in_production },
    { label: 'Reliability', options: ['All', 'High', 'Medium', 'Low'],
      predicate: (p, v) => p.data_reliability === v },
  ], [effectTypes]);

  return (
    <DataTable<Pedal>
      title="Pedal Database"
      entityName="pedal"
      entityNamePlural="pedals"
      stats={stats}
      data={data}
      columns={columns}
      filters={filters}
      searchFields={['manufacturer', 'model']}
      searchPlaceholder="Search pedals..."
      renderExpandedRow={renderExpandedRow}
      defaultSortKey="manufacturer"
      loading={loading}
      error={error}
    />
  );
};

export default Pedals;
