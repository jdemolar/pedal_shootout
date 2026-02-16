import { ReactNode, useMemo } from 'react';
import DataTable, { ColumnDef, FilterConfig } from '../DataTable';
import { formatMsrp, formatDimensions } from '../../utils/formatters';
import { useApiData } from '../../hooks/useApiData';
import { api } from '../../services/api';
import { transformUtility, Jack } from '../../utils/transformers';
import JacksList from '../JacksList';
import WorkbenchToggle from '../WorkbenchToggle';

interface Utility {
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
  // Utility-specific
  utility_type: string;
  is_active: boolean;
  signal_type: string | null;
  bypass_type: string | null;
  has_ground_lift: boolean;
  jacks: Jack[];
}

const columns: ColumnDef<Utility>[] = [
  { label: 'Manufacturer', width: 180, sortKey: 'manufacturer',
    render: u => <span style={{ color: '#f0f0f0', fontSize: '12.5px', fontWeight: 600, fontFamily: "'Helvetica Neue', sans-serif" }}>{u.manufacturer}</span> },
  { label: 'Model', width: 200, sortKey: 'model',
    render: u => <span style={{ color: '#d0d0d0' }}>{u.model}</span> },
  { label: 'Type', width: 150, sortKey: 'utility_type',
    render: u => <>{u.utility_type}</> },
  { label: 'Active/Passive', width: 110, align: 'center', sortKey: 'is_active',
    render: u => (
      <span className={u.is_active ? 'bool-yes' : 'bool-no'}>
        {u.is_active ? 'Active' : 'Passive'}
      </span>
    ) },
  { label: 'Status', width: 80, align: 'center', sortKey: 'in_production',
    render: u => (
      <span className={`status-badge status-badge--${u.in_production ? 'in-production' : 'discontinued'}`}>
        {u.in_production ? 'Active' : 'Disc.'}
      </span>
    ) },
  { label: 'MSRP', width: 90, align: 'right', sortKey: 'msrp_cents',
    render: u => u.msrp_cents != null
      ? <>{formatMsrp(u.msrp_cents)}</>
      : <span className="null-value">{'\u2014'}</span> },
  { label: 'Dimensions', width: 150, align: 'center',
    render: u => u.width_mm != null && u.depth_mm != null && u.height_mm != null
      ? <>{formatDimensions(u.width_mm, u.depth_mm, u.height_mm)}</>
      : <span className="null-value">{'\u2014'}</span> },
  { label: 'Reliability', width: 80, align: 'center', sortKey: 'data_reliability',
    render: u => u.data_reliability
      ? <span className={`reliability-badge reliability-badge--${u.data_reliability.toLowerCase()}`}>{u.data_reliability}</span>
      : <span className="null-value">{'\u2014'}</span> },
];

const renderExpandedRow = (u: Utility): ReactNode => (
  <>
    {u.signal_type != null && (
      <div className="data-table__detail">
        <div className="data-table__detail-label">Signal Type</div>
        <div className="data-table__detail-value">{u.signal_type}</div>
      </div>
    )}
    {u.bypass_type != null && (
      <div className="data-table__detail">
        <div className="data-table__detail-label">Bypass Type</div>
        <div className="data-table__detail-value">{u.bypass_type}</div>
      </div>
    )}
    <div className="data-table__detail">
      <div className="data-table__detail-label">Ground Lift</div>
      <div className="data-table__detail-value">
        <span className={u.has_ground_lift ? 'bool-yes' : 'bool-no'}>{u.has_ground_lift ? 'Yes' : 'No'}</span>
      </div>
    </div>
    {u.weight_grams != null && (
      <div className="data-table__detail">
        <div className="data-table__detail-label">Weight</div>
        <div className="data-table__detail-value data-table__detail-value--highlight">
          {(u.weight_grams / 1000).toFixed(2)} kg
        </div>
      </div>
    )}
    {u.product_page != null && (
      <div className="data-table__detail">
        <div className="data-table__detail-label">Product Page</div>
        <div className="data-table__detail-value">
          <a href={u.product_page} target="_blank" rel="noopener noreferrer" onClick={e => e.stopPropagation()} className="detail-link">
            {u.product_page}
          </a>
        </div>
      </div>
    )}
    {u.instruction_manual != null && (
      <div className="data-table__detail">
        <div className="data-table__detail-label">Instruction Manual</div>
        <div className="data-table__detail-value">
          <a href={u.instruction_manual} target="_blank" rel="noopener noreferrer" onClick={e => e.stopPropagation()} className="detail-link">
            {u.instruction_manual}
          </a>
        </div>
      </div>
    )}
    <JacksList jacks={u.jacks} />
  </>
);

const stats = (data: Utility[]) => {
  const inProd = data.filter(u => u.in_production).length;
  const active = data.filter(u => u.is_active).length;
  return `${data.length} utilities \u00b7 ${inProd} in production \u00b7 ${active} active`;
};

const Utilities = () => {
  const { data, loading, error } = useApiData(api.getUtilities, transformUtility);

  const utilityTypes = useMemo(
    () => ['All', ...Array.from(new Set(data.map(d => d.utility_type))).sort()],
    [data]
  );

  const filters: FilterConfig<Utility>[] = useMemo(() => [
    { label: 'Type', options: utilityTypes,
      predicate: (u, v) => u.utility_type === v },
    { label: 'Activity', options: ['All', 'Active', 'Passive'],
      predicate: (u, v) => (v === 'Active') === u.is_active },
    { label: 'Status', options: ['All', 'In Production', 'Discontinued'],
      predicate: (u, v) => (v === 'In Production') === u.in_production },
    { label: 'Reliability', options: ['All', 'High', 'Medium', 'Low'],
      predicate: (u, v) => u.data_reliability === v },
  ], [utilityTypes]);

  return (
    <DataTable<Utility>
      title="Utility Database"
      entityName="utility"
      entityNamePlural="utilities"
      stats={stats}
      data={data}
      columns={columns}
      filters={filters}
      searchFields={['manufacturer', 'model']}
      searchPlaceholder="Search utilities..."
      renderExpandedRow={renderExpandedRow}
      renderRowAction={u => <WorkbenchToggle productId={u.id} productType="utility" />}
      defaultSortKey="manufacturer"
      loading={loading}
      error={error}
    />
  );
};

export default Utilities;
