import { ReactNode, useMemo } from 'react';
import DataTable, { ColumnDef, FilterConfig } from '../DataTable';
import { formatMsrp, formatDimensions } from '../../utils/formatters';
import { useApiData } from '../../hooks/useApiData';
import { api } from '../../services/api';
import { transformPedalboard, Jack } from '../../utils/transformers';
import JacksList from '../JacksList';
import WorkbenchToggle from '../WorkbenchToggle';

interface Pedalboard {
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
  // Pedalboard-specific
  usable_width_mm: number | null;
  usable_depth_mm: number | null;
  surface_type: string | null;
  material: string | null;
  has_second_tier: boolean;
  has_integrated_power: boolean;
  has_integrated_patch_bay: boolean;
  case_included: boolean;
  jacks: Jack[];
}

const columns: ColumnDef<Pedalboard>[] = [
  { label: 'Manufacturer', width: 180, sortKey: 'manufacturer',
    render: p => <span style={{ color: '#f0f0f0', fontSize: '12.5px', fontWeight: 600, fontFamily: "'Helvetica Neue', sans-serif" }}>{p.manufacturer}</span> },
  { label: 'Model', width: 200, sortKey: 'model',
    render: p => <span style={{ color: '#d0d0d0' }}>{p.model}</span> },
  { label: 'Width (mm)', width: 100, align: 'center', sortKey: 'usable_width_mm',
    render: p => p.usable_width_mm != null
      ? <>{p.usable_width_mm}</>
      : <span className="null-value">{'\u2014'}</span> },
  { label: 'Depth (mm)', width: 100, align: 'center', sortKey: 'usable_depth_mm',
    render: p => p.usable_depth_mm != null
      ? <>{p.usable_depth_mm}</>
      : <span className="null-value">{'\u2014'}</span> },
  { label: 'Material', width: 120, sortKey: 'material',
    render: p => p.material
      ? <>{p.material}</>
      : <span className="null-value">{'\u2014'}</span> },
  { label: 'Status', width: 80, align: 'center', sortKey: 'in_production',
    render: p => (
      <span className={`status-badge status-badge--${p.in_production ? 'in-production' : 'discontinued'}`}>
        {p.in_production ? 'Active' : 'Disc.'}
      </span>
    ) },
  { label: 'MSRP', width: 90, align: 'right', sortKey: 'msrp_cents',
    render: p => p.msrp_cents != null
      ? <>{formatMsrp(p.msrp_cents)}</>
      : <span className="null-value">{'\u2014'}</span> },
  { label: 'Dimensions', width: 150, align: 'center',
    render: p => p.width_mm != null && p.depth_mm != null && p.height_mm != null
      ? <>{formatDimensions(p.width_mm, p.depth_mm, p.height_mm)}</>
      : <span className="null-value">{'\u2014'}</span> },
  { label: 'Reliability', width: 80, align: 'center', sortKey: 'data_reliability',
    render: p => p.data_reliability
      ? <span className={`reliability-badge reliability-badge--${p.data_reliability.toLowerCase()}`}>{p.data_reliability}</span>
      : <span className="null-value">{'\u2014'}</span> },
];

const renderExpandedRow = (p: Pedalboard): ReactNode => (
  <>
    {p.surface_type != null && (
      <div className="data-table__detail">
        <div className="data-table__detail-label">Surface Type</div>
        <div className="data-table__detail-value">{p.surface_type}</div>
      </div>
    )}
    <div className="data-table__detail">
      <div className="data-table__detail-label">Second Tier</div>
      <div className="data-table__detail-value">
        <span className={p.has_second_tier ? 'bool-yes' : 'bool-no'}>{p.has_second_tier ? 'Yes' : 'No'}</span>
      </div>
    </div>
    <div className="data-table__detail">
      <div className="data-table__detail-label">Integrated Power</div>
      <div className="data-table__detail-value">
        <span className={p.has_integrated_power ? 'bool-yes' : 'bool-no'}>{p.has_integrated_power ? 'Yes' : 'No'}</span>
      </div>
    </div>
    <div className="data-table__detail">
      <div className="data-table__detail-label">Patch Bay</div>
      <div className="data-table__detail-value">
        <span className={p.has_integrated_patch_bay ? 'bool-yes' : 'bool-no'}>{p.has_integrated_patch_bay ? 'Yes' : 'No'}</span>
      </div>
    </div>
    <div className="data-table__detail">
      <div className="data-table__detail-label">Case Included</div>
      <div className="data-table__detail-value">
        <span className={p.case_included ? 'bool-yes' : 'bool-no'}>{p.case_included ? 'Yes' : 'No'}</span>
      </div>
    </div>
    {p.weight_grams != null && (
      <div className="data-table__detail">
        <div className="data-table__detail-label">Weight</div>
        <div className="data-table__detail-value data-table__detail-value--highlight">
          {(p.weight_grams / 1000).toFixed(2)} kg
        </div>
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
    <JacksList jacks={p.jacks} />
  </>
);

const stats = (data: Pedalboard[]) => {
  const inProd = data.filter(p => p.in_production).length;
  const materials = new Set(data.map(p => p.material).filter(m => m !== null)).size;
  return `${data.length} boards \u00b7 ${inProd} in production \u00b7 ${materials} materials`;
};

const Pedalboards = () => {
  const { data, loading, error } = useApiData(api.getPedalboards, transformPedalboard);

  const materials = useMemo(
    () => ['All', ...Array.from(new Set(data.map(d => d.material).filter((m): m is string => m !== null))).sort()],
    [data]
  );

  const filters: FilterConfig<Pedalboard>[] = useMemo(() => [
    { label: 'Material', options: materials,
      predicate: (p, v) => p.material === v },
    { label: 'Status', options: ['All', 'In Production', 'Discontinued'],
      predicate: (p, v) => (v === 'In Production') === p.in_production },
    { label: 'Reliability', options: ['All', 'High', 'Medium', 'Low'],
      predicate: (p, v) => p.data_reliability === v },
  ], [materials]);

  return (
    <DataTable<Pedalboard>
      title="Pedalboard Database"
      entityName="board"
      entityNamePlural="boards"
      stats={stats}
      data={data}
      columns={columns}
      filters={filters}
      searchFields={['manufacturer', 'model']}
      searchPlaceholder="Search pedalboards..."
      renderExpandedRow={renderExpandedRow}
      renderRowAction={p => <WorkbenchToggle productId={p.id} productType="pedalboard" />}
      defaultSortKey="manufacturer"
      loading={loading}
      error={error}
    />
  );
};

export default Pedalboards;
