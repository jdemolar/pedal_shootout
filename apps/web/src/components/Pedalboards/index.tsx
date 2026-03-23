import { ReactNode, useMemo } from 'react';
import DataTable, { ColumnDef, FilterConfig } from '../DataTable';
import { formatMsrp, formatDimensions } from '../../utils/formatters';
import { useApiData } from '../../hooks/useApiData';
import { api } from '../../services/api';
import { transformPedalboard, Jack } from '../../utils/transformers';
import { BooleanDetail, LinkDetail } from '../DetailHelpers';
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
    render: p => <span className="data-table__cell-manufacturer">{p.manufacturer}</span> },
  { label: 'Model', width: 200, sortKey: 'model',
    render: p => <span className="data-table__cell-model">{p.model}</span> },
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
    render: p => p.width_mm != null && p.depth_mm != null
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
    <BooleanDetail label="Second Tier" value={p.has_second_tier} />
    <BooleanDetail label="Integrated Power" value={p.has_integrated_power} />
    <BooleanDetail label="Patch Bay" value={p.has_integrated_patch_bay} />
    <BooleanDetail label="Case Included" value={p.case_included} />
    {p.weight_grams != null && (
      <div className="data-table__detail">
        <div className="data-table__detail-label">Weight</div>
        <div className="data-table__detail-value data-table__detail-value--highlight">
          {(p.weight_grams / 1000).toFixed(2)} kg
        </div>
      </div>
    )}
    <LinkDetail label="Product Page" url={p.product_page} />
    <LinkDetail label="Instruction Manual" url={p.instruction_manual} />
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
