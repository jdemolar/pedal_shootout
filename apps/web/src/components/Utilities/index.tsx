import { ReactNode } from 'react';
import DataTable, { ColumnDef, FilterConfig } from '../DataTable';
import { formatMsrp, formatDimensions } from '../../utils/formatters';

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
}

// TODO: Replace with API call to Spring Boot backend
const DATA: Utility[] = [
  {
    "id": 203,
    "manufacturer": "Goodwood Audio",
    "model": "The TX Interfacer",
    "in_production": true,
    "width_mm": 73.0,
    "depth_mm": 115.0,
    "height_mm": 68.0,
    "weight_grams": 325,
    "msrp_cents": 27900,
    "product_page": "https://goodwoodaudio.com/products/the-tx-interfacer",
    "instruction_manual": "https://www.manualslib.com/manual/1696395/Goodwood-Audio-The-Tx-Interfacer.html",
    "data_reliability": "High",
    "utility_type": "Junction Box",
    "is_active": true,
    "signal_type": "Analog",
    "bypass_type": "Buffered",
    "has_ground_lift": true
  },
  {
    "id": 204,
    "manufacturer": "Goodwood Audio",
    "model": "The TX Underfacer",
    "in_production": true,
    "width_mm": 100.0,
    "depth_mm": 118.0,
    "height_mm": 34.0,
    "weight_grams": null,
    "msrp_cents": 26900,
    "product_page": "https://goodwoodaudio.com/products/the-tx-underfacer",
    "instruction_manual": "https://www.manualslib.com/manual/1990047/Goodwood-Audio-The-Tx-Underfacer.html",
    "data_reliability": "High",
    "utility_type": "Junction Box",
    "is_active": true,
    "signal_type": "Analog",
    "bypass_type": "Buffered",
    "has_ground_lift": true
  },
  {
    "id": 205,
    "manufacturer": "Goodwood Audio",
    "model": "Output TX",
    "in_production": true,
    "width_mm": 66.0,
    "depth_mm": 111.0,
    "height_mm": 31.0,
    "weight_grams": 200,
    "msrp_cents": 19900,
    "product_page": "https://goodwoodaudio.com/products/output-tx",
    "instruction_manual": "https://www.manualslib.com/manual/2494057/Goodwood-Audio-Output-Tx.html",
    "data_reliability": "High",
    "utility_type": "Junction Box",
    "is_active": true,
    "signal_type": "Analog",
    "bypass_type": "Buffered",
    "has_ground_lift": true
  },
  {
    "id": 206,
    "manufacturer": "Goodwood Audio",
    "model": "LongLine",
    "in_production": true,
    "width_mm": 120.0,
    "depth_mm": 94.0,
    "height_mm": 34.0,
    "weight_grams": null,
    "msrp_cents": 25900,
    "product_page": "https://goodwoodaudio.com/products/longline",
    "instruction_manual": "https://www.manualslib.com/manual/3494393/Goodwood-Audio-Longline.html",
    "data_reliability": "High",
    "utility_type": "Line Level Converter",
    "is_active": true,
    "signal_type": "Analog",
    "bypass_type": null,
    "has_ground_lift": true
  },
  {
    "id": 207,
    "manufacturer": "Goodwood Audio",
    "model": "RCV",
    "in_production": true,
    "width_mm": 112.0,
    "depth_mm": 61.0,
    "height_mm": 38.0,
    "weight_grams": null,
    "msrp_cents": 11900,
    "product_page": "https://goodwoodaudio.com/products/rcv",
    "instruction_manual": null,
    "data_reliability": "High",
    "utility_type": "Line Level Converter",
    "is_active": false,
    "signal_type": "Analog",
    "bypass_type": null,
    "has_ground_lift": false
  },
  {
    "id": 208,
    "manufacturer": "Goodwood Audio",
    "model": "Isolator TX",
    "in_production": true,
    "width_mm": 66.0,
    "depth_mm": 111.0,
    "height_mm": 31.0,
    "weight_grams": null,
    "msrp_cents": 17500,
    "product_page": "https://goodwoodaudio.com/products/isolator",
    "instruction_manual": null,
    "data_reliability": "High",
    "utility_type": "Splitter",
    "is_active": true,
    "signal_type": "Analog",
    "bypass_type": "Buffered",
    "has_ground_lift": true
  },
  {
    "id": 209,
    "manufacturer": "Goodwood Audio",
    "model": "4-Way Buffered Splitter",
    "in_production": true,
    "width_mm": null,
    "depth_mm": null,
    "height_mm": null,
    "weight_grams": null,
    "msrp_cents": 13900,
    "product_page": "https://goodwoodaudio.com/products/4-way-buffered-splitter",
    "instruction_manual": null,
    "data_reliability": "High",
    "utility_type": "Splitter",
    "is_active": true,
    "signal_type": "Analog",
    "bypass_type": "Buffered",
    "has_ground_lift": false
  },
  {
    "id": 210,
    "manufacturer": "Goodwood Audio",
    "model": "3 Channel Stereo Line Mixer",
    "in_production": true,
    "width_mm": 119.0,
    "depth_mm": 94.0,
    "height_mm": 56.0,
    "weight_grams": null,
    "msrp_cents": 44900,
    "product_page": "https://goodwoodaudio.com/products/3-channel-stereo-line-mixer",
    "instruction_manual": null,
    "data_reliability": "High",
    "utility_type": "Mixer",
    "is_active": true,
    "signal_type": "Analog",
    "bypass_type": null,
    "has_ground_lift": false
  },
  {
    "id": 211,
    "manufacturer": "Goodwood Audio",
    "model": "Audition",
    "in_production": true,
    "width_mm": 66.0,
    "depth_mm": 111.0,
    "height_mm": 31.0,
    "weight_grams": 185,
    "msrp_cents": 7500,
    "product_page": "https://goodwoodaudio.com/products/audition",
    "instruction_manual": "https://www.manualslib.com/manual/1637499/Goodwood-Audio-Audition.html",
    "data_reliability": "High",
    "utility_type": "A/B Box",
    "is_active": true,
    "signal_type": "Analog",
    "bypass_type": null,
    "has_ground_lift": false
  },
  {
    "id": 212,
    "manufacturer": "Goodwood Audio",
    "model": "Buzzkill",
    "in_production": true,
    "width_mm": null,
    "depth_mm": null,
    "height_mm": null,
    "weight_grams": null,
    "msrp_cents": 9900,
    "product_page": "https://goodwoodaudio.com/products/buzzkill-transformer-isolation",
    "instruction_manual": null,
    "data_reliability": "High",
    "utility_type": "Impedance Matcher",
    "is_active": false,
    "signal_type": "Analog",
    "bypass_type": null,
    "has_ground_lift": true
  },
  {
    "id": 213,
    "manufacturer": "Goodwood Audio",
    "model": "Bass Interfacer",
    "in_production": true,
    "width_mm": 73.0,
    "depth_mm": 115.0,
    "height_mm": 68.0,
    "weight_grams": 335,
    "msrp_cents": 26900,
    "product_page": "https://goodwoodaudio.com/",
    "instruction_manual": "https://www.manualslib.com/manual/1432556/Goodwood-Audio-Bass-Interfacer.html",
    "data_reliability": "High",
    "utility_type": "Junction Box",
    "is_active": true,
    "signal_type": "Analog",
    "bypass_type": "Buffered",
    "has_ground_lift": true
  },
  {
    "id": 214,
    "manufacturer": "Goodwood Audio",
    "model": "RMT",
    "in_production": true,
    "width_mm": 96.0,
    "depth_mm": 39.0,
    "height_mm": 44.0,
    "weight_grams": 95,
    "msrp_cents": null,
    "product_page": "https://goodwoodaudio.com/products/rmt",
    "instruction_manual": "https://www.manualslib.com/manual/2494059/Goodwood-Audio-Rmt.html",
    "data_reliability": "High",
    "utility_type": "Mute Switch",
    "is_active": false,
    "signal_type": "Analog",
    "bypass_type": null,
    "has_ground_lift": false
  },
  {
    "id": 215,
    "manufacturer": "Goodwood Audio",
    "model": "LIFT 12\"",
    "in_production": true,
    "width_mm": 304.8,
    "depth_mm": 127.0,
    "height_mm": 25.4,
    "weight_grams": null,
    "msrp_cents": 13900,
    "product_page": "https://goodwoodaudio.com/products/lift",
    "instruction_manual": null,
    "data_reliability": "High",
    "utility_type": "Other",
    "is_active": false,
    "signal_type": null,
    "bypass_type": null,
    "has_ground_lift": false
  }
];

const UTILITY_TYPES = ['All', ...Array.from(new Set(DATA.map(d => d.utility_type))).sort()];

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

const filters: FilterConfig<Utility>[] = [
  { label: 'Type', options: UTILITY_TYPES,
    predicate: (u, v) => u.utility_type === v },
  { label: 'Activity', options: ['All', 'Active', 'Passive'],
    predicate: (u, v) => (v === 'Active') === u.is_active },
  { label: 'Status', options: ['All', 'In Production', 'Discontinued'],
    predicate: (u, v) => (v === 'In Production') === u.in_production },
  { label: 'Reliability', options: ['All', 'High', 'Medium', 'Low'],
    predicate: (u, v) => u.data_reliability === v },
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
  </>
);

const stats = (data: Utility[]) => {
  const inProd = data.filter(u => u.in_production).length;
  const active = data.filter(u => u.is_active).length;
  return `${data.length} utilities \u00b7 ${inProd} in production \u00b7 ${active} active`;
};

const Utilities = () => (
  <DataTable<Utility>
    title="Utility Database"
    entityName="utility"
    entityNamePlural="utilities"
    stats={stats}
    data={DATA}
    columns={columns}
    filters={filters}
    searchFields={['manufacturer', 'model']}
    searchPlaceholder="Search utilities..."
    renderExpandedRow={renderExpandedRow}
    defaultSortKey="manufacturer"
  />
);

export default Utilities;
