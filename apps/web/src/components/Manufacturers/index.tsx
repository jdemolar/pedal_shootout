import { ReactNode, useMemo } from 'react';
import DataTable, { ColumnDef, FilterConfig } from '../DataTable';
import { useApiData } from '../../hooks/useApiData';
import { api } from '../../services/api';
import { transformManufacturer } from '../../utils/transformers';

interface Manufacturer {
  id: number;
  name: string;
  country: string | null;
  founded: string | null;
  status: 'Active' | 'Defunct' | 'Discontinued' | 'Unknown';
  specialty: string | null;
  website: string | null;
  notes: string | null;
  updated_at: string | null;
  product_count: number;
}

const formatWebsiteUrl = (website: string) => {
  return website.startsWith('http') ? website : `https://${website}`;
};

const columns: ColumnDef<Manufacturer>[] = [
  { label: '#', width: 40, align: 'center', sortKey: 'id',
    render: m => <span style={{ color: '#3a3a3a', fontSize: '10px' }}>{m.id}</span> },
  { label: 'Manufacturer', width: 200, sortKey: 'name',
    render: m => <span style={{ color: '#f0f0f0', fontSize: '12.5px', fontWeight: 600, fontFamily: "'Helvetica Neue', sans-serif" }}>{m.name}</span> },
  { label: 'Country', width: 120, sortKey: 'country',
    render: m => m.country != null ? <span style={{ color: '#a0a0a0' }}>{m.country}</span> : <span className="null-value">{'\u2014'}</span> },
  { label: 'Founded', width: 80, align: 'center', sortKey: 'founded',
    render: m => m.founded != null ? <span style={{ color: '#6a6a6a' }}>{m.founded}</span> : <span className="null-value">{'\u2014'}</span> },
  { label: 'Status', width: 100, align: 'center', sortKey: 'status',
    render: m => <span className={`status-badge status-badge--${m.status.toLowerCase()}`}>{m.status}</span> },
  { label: 'Specialty', width: 280, sortKey: 'specialty',
    render: m => m.specialty != null ? <span style={{ color: '#6a6a6a' }}>{m.specialty}</span> : <span className="null-value">{'\u2014'}</span> },
  { label: 'Products', width: 64, align: 'center', sortKey: 'product_count',
    render: m => m.product_count > 0
      ? <span className="product-count-highlight">{m.product_count}</span>
      : <span className="product-count-zero">0</span> },
  { label: 'Website', width: 160, sortKey: 'website',
    render: m => m.website
      ? <a href={formatWebsiteUrl(m.website)} target="_blank" rel="noopener noreferrer" onClick={e => e.stopPropagation()} className="detail-link">{m.website}</a>
      : <span className="null-value">{'\u2014'}</span> },
];

const renderExpandedRow = (m: Manufacturer): ReactNode => (
  <>
    <div className="data-table__detail">
      <div className="data-table__detail-label">Notes</div>
      <div className="data-table__detail-value">
        {m.notes ?? <span className="null-value">{'\u2014'}</span>}
      </div>
    </div>
    <div className="data-table__detail">
      <div className="data-table__detail-label">Products in Database</div>
      <div className={`data-table__detail-value ${m.product_count > 0 ? 'data-table__detail-value--highlight' : ''}`}>
        {m.product_count} product{m.product_count !== 1 ? 's' : ''}
      </div>
    </div>
  </>
);

const stats = (data: Manufacturer[]) => {
  const totalProducts = data.reduce((sum, m) => sum + m.product_count, 0);
  const activeCount = data.filter(m => m.status === 'Active').length;
  return `${data.length} manufacturers \u00b7 ${activeCount} active \u00b7 ${totalProducts} products catalogued`;
};

const Manufacturers = () => {
  const { data, loading, error } = useApiData(api.getManufacturers, transformManufacturer);

  const countries = useMemo(
    () => ['All', ...Array.from(new Set(data.map(d => d.country).filter((c): c is string => c !== null))).sort()],
    [data]
  );

  const filters: FilterConfig<Manufacturer>[] = useMemo(() => [
    { label: 'Country', options: countries,
      predicate: (m, v) => m.country === v },
    { label: 'Status', options: ['All', 'Active', 'Defunct', 'Discontinued', 'Unknown'],
      predicate: (m, v) => m.status === v },
  ], [countries]);

  return (
    <DataTable<Manufacturer>
      title="Manufacturer Database"
      entityName="manufacturer"
      entityNamePlural="manufacturers"
      stats={stats}
      data={data}
      columns={columns}
      filters={filters}
      searchFields={['name']}
      searchPlaceholder="Search manufacturer..."
      renderExpandedRow={renderExpandedRow}
      defaultSortKey="name"
      minTableWidth={1050}
      loading={loading}
      error={error}
    />
  );
};

export default Manufacturers;
