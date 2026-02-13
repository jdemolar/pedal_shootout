import './index.scss';
import { useState, useMemo } from 'react';

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

type SortColumn = 'manufacturer' | 'model' | 'utility_type' | 'is_active' | 'in_production' | 'msrp_cents' | 'data_reliability';
type SortDirection = 1 | -1;

const UTILITY_TYPES = ['All', ...Array.from(new Set(DATA.map(d => d.utility_type))).sort()];
const ACTIVITY = ['All', 'Active', 'Passive'] as const;
const STATUSES = ['All', 'In Production', 'Discontinued'] as const;
const RELIABILITIES = ['All', 'High', 'Medium', 'Low'] as const;

interface ColumnDef {
  key: SortColumn;
  label: string;
  width: number;
  align?: 'left' | 'center' | 'right';
  sortable: boolean;
}

const COLUMNS: ColumnDef[] = [
  { key: 'manufacturer',     label: 'Manufacturer',   width: 180, sortable: true },
  { key: 'model',            label: 'Model',          width: 200, sortable: true },
  { key: 'utility_type',     label: 'Type',           width: 150, sortable: true },
  { key: 'is_active',        label: 'Active/Passive', width: 110, align: 'center', sortable: true },
  { key: 'in_production',    label: 'Status',         width: 80,  align: 'center', sortable: true },
  { key: 'msrp_cents',       label: 'MSRP',           width: 90,  align: 'right',  sortable: true },
  { key: 'manufacturer',     label: 'Dimensions',     width: 150, align: 'center', sortable: false },
  { key: 'data_reliability', label: 'Reliability',    width: 80,  align: 'center', sortable: true },
];

const Utilities = () => {
  const [search, setSearch] = useState('');
  const [typeFilter, setTypeFilter] = useState('All');
  const [activityFilter, setActivityFilter] = useState<typeof ACTIVITY[number]>('All');
  const [statusFilter, setStatusFilter] = useState<typeof STATUSES[number]>('All');
  const [reliabilityFilter, setReliabilityFilter] = useState<typeof RELIABILITIES[number]>('All');
  const [sortCol, setSortCol] = useState<SortColumn>('manufacturer');
  const [sortDir, setSortDir] = useState<SortDirection>(1);
  const [expandedId, setExpandedId] = useState<number | null>(null);

  const filtered = useMemo(() => {
    let result = DATA;

    if (search) {
      const s = search.toLowerCase();
      result = result.filter(u => u.manufacturer.toLowerCase().includes(s) || u.model.toLowerCase().includes(s));
    }

    if (typeFilter !== 'All') {
      result = result.filter(u => u.utility_type === typeFilter);
    }

    if (activityFilter !== 'All') {
      const wantsActive = activityFilter === 'Active';
      result = result.filter(u => u.is_active === wantsActive);
    }

    if (statusFilter !== 'All') {
      const inProd = statusFilter === 'In Production';
      result = result.filter(u => u.in_production === inProd);
    }

    if (reliabilityFilter !== 'All') {
      result = result.filter(u => u.data_reliability === reliabilityFilter);
    }

    return [...result].sort((a, b) => {
      const va = a[sortCol];
      const vb = b[sortCol];

      if (va == null && vb == null) return 0;
      if (va == null) return 1;
      if (vb == null) return -1;

      if (typeof va === 'boolean' && typeof vb === 'boolean') {
        return (Number(va) - Number(vb)) * sortDir;
      }

      if (typeof va === 'number' && typeof vb === 'number') {
        return (va - vb) * sortDir;
      }

      if (typeof va === 'string' && typeof vb === 'string') {
        return va.localeCompare(vb) * sortDir;
      }

      return 0;
    });
  }, [search, typeFilter, activityFilter, statusFilter, reliabilityFilter, sortCol, sortDir]);

  const handleSort = (col: SortColumn) => {
    if (sortCol === col) {
      setSortDir(d => (d === 1 ? -1 : 1));
    } else {
      setSortCol(col);
      setSortDir(1);
    }
  };

  const totalUtilities = DATA.length;
  const inProductionCount = DATA.filter(u => u.in_production).length;
  const activeCount = DATA.filter(u => u.is_active).length;

  const formatMsrp = (cents: number | null): string => {
    if (cents == null) return '\u2014';
    return `$${(cents / 100).toFixed(2)}`;
  };

  const formatDimensions = (w: number | null, d: number | null, h: number | null): string => {
    if (w != null && d != null && h != null) return `${w} \u00d7 ${d} \u00d7 ${h} mm`;
    return '\u2014';
  };

  return (
    <div className="utilities">
      <div className="utilities__header">
        <div className="utilities__title-group">
          <h1 className="utilities__title">Utility Database</h1>
          <span className="utilities__stats">
            {totalUtilities} utilities \u00b7 {inProductionCount} in production \u00b7 {activeCount} active
          </span>
        </div>
      </div>

      <div className="utilities__filters">
        <div className="utilities__search-wrapper">
          <span className="utilities__search-icon">&#x2315;</span>
          <input
            type="text"
            value={search}
            onChange={e => setSearch(e.target.value)}
            placeholder="Search utilities..."
            className="utilities__search"
          />
        </div>

        <select
          value={typeFilter}
          onChange={e => setTypeFilter(e.target.value)}
          className="utilities__select"
        >
          {UTILITY_TYPES.map(t => (
            <option key={t} value={t}>
              {t === 'All' ? 'Type: All' : t}
            </option>
          ))}
        </select>

        <select
          value={activityFilter}
          onChange={e => setActivityFilter(e.target.value as typeof ACTIVITY[number])}
          className="utilities__select"
        >
          {ACTIVITY.map(a => (
            <option key={a} value={a}>
              {a === 'All' ? 'Activity: All' : a}
            </option>
          ))}
        </select>

        <select
          value={statusFilter}
          onChange={e => setStatusFilter(e.target.value as typeof STATUSES[number])}
          className="utilities__select"
        >
          {STATUSES.map(s => (
            <option key={s} value={s}>
              {s === 'All' ? 'Status: All' : s}
            </option>
          ))}
        </select>

        <select
          value={reliabilityFilter}
          onChange={e => setReliabilityFilter(e.target.value as typeof RELIABILITIES[number])}
          className="utilities__select"
        >
          {RELIABILITIES.map(r => (
            <option key={r} value={r}>
              {r === 'All' ? 'Reliability: All' : r}
            </option>
          ))}
        </select>

        <span className="utilities__filter-count">
          {filtered.length} utilit{filtered.length !== 1 ? 'ies' : 'y'} shown
        </span>
      </div>

      <div className="utilities__table-wrapper">
        <table className="utilities__table">
          <thead>
            <tr>
              {COLUMNS.map((col, ci) => (
                <th
                  key={ci}
                  onClick={() => col.sortable ? handleSort(col.key) : undefined}
                  className="utilities__th"
                  style={{ width: col.width, textAlign: col.align || 'left', cursor: col.sortable ? 'pointer' : 'default' }}
                >
                  {col.label}
                  {col.sortable && (
                    <span className={`utilities__sort-icon ${sortCol === col.key ? 'active' : ''}`}>
                      {sortCol === col.key ? (sortDir === 1 ? '\u25b2' : '\u25bc') : '\u21c5'}
                    </span>
                  )}
                </th>
              ))}
            </tr>
          </thead>
          <tbody>
            {filtered.map((u, i) => {
              const isExpanded = expandedId === u.id;

              return (
                <>
                  <tr
                    key={u.id}
                    onClick={() => setExpandedId(isExpanded ? null : u.id)}
                    className={`utilities__row ${isExpanded ? 'expanded' : ''} ${i % 2 === 0 ? 'even' : 'odd'}`}
                  >
                    <td className="utilities__td utilities__td--manufacturer">{u.manufacturer}</td>
                    <td className="utilities__td utilities__td--model">{u.model}</td>
                    <td className="utilities__td utilities__td--type">{u.utility_type}</td>
                    <td className="utilities__td" style={{ textAlign: 'center' }}>
                      <span className={u.is_active ? 'bool-yes' : 'bool-no'}>
                        {u.is_active ? 'Active' : 'Passive'}
                      </span>
                    </td>
                    <td className="utilities__td utilities__td--status" style={{ textAlign: 'center' }}>
                      <span className={`status-badge status-badge--${u.in_production ? 'in-production' : 'discontinued'}`}>
                        {u.in_production ? 'Active' : 'Disc.'}
                      </span>
                    </td>
                    <td className="utilities__td utilities__td--msrp" style={{ textAlign: 'right' }}>
                      {u.msrp_cents != null ? formatMsrp(u.msrp_cents) : <span className="null-value">\u2014</span>}
                    </td>
                    <td className="utilities__td utilities__td--dimensions" style={{ textAlign: 'center' }}>
                      {u.width_mm != null && u.depth_mm != null && u.height_mm != null ? (
                        formatDimensions(u.width_mm, u.depth_mm, u.height_mm)
                      ) : (
                        <span className="null-value">\u2014</span>
                      )}
                    </td>
                    <td className="utilities__td utilities__td--reliability" style={{ textAlign: 'center' }}>
                      {u.data_reliability ? (
                        <span className={`reliability-badge reliability-badge--${u.data_reliability.toLowerCase()}`}>
                          {u.data_reliability}
                        </span>
                      ) : (
                        <span className="null-value">\u2014</span>
                      )}
                    </td>
                  </tr>
                  {isExpanded && (
                    <tr key={`exp-${u.id}`} className="utilities__expanded-row">
                      <td colSpan={8} className="utilities__expanded-cell">
                        <div className="utilities__expanded-content">
                          {u.signal_type != null && (
                            <div className="utilities__detail">
                              <div className="utilities__detail-label">Signal Type</div>
                              <div className="utilities__detail-value">{u.signal_type}</div>
                            </div>
                          )}
                          {u.bypass_type != null && (
                            <div className="utilities__detail">
                              <div className="utilities__detail-label">Bypass Type</div>
                              <div className="utilities__detail-value">{u.bypass_type}</div>
                            </div>
                          )}
                          <div className="utilities__detail">
                            <div className="utilities__detail-label">Ground Lift</div>
                            <div className="utilities__detail-value">
                              <span className={u.has_ground_lift ? 'bool-yes' : 'bool-no'}>
                                {u.has_ground_lift ? 'Yes' : 'No'}
                              </span>
                            </div>
                          </div>
                          {u.weight_grams != null && (
                            <div className="utilities__detail">
                              <div className="utilities__detail-label">Weight</div>
                              <div className="utilities__detail-value utilities__detail-value--highlight">
                                {(u.weight_grams / 1000).toFixed(2)} kg
                              </div>
                            </div>
                          )}
                          {u.product_page != null && (
                            <div className="utilities__detail">
                              <div className="utilities__detail-label">Product Page</div>
                              <div className="utilities__detail-value">
                                <a
                                  href={u.product_page}
                                  target="_blank"
                                  rel="noopener noreferrer"
                                  onClick={e => e.stopPropagation()}
                                  className="detail-link"
                                >
                                  {u.product_page}
                                </a>
                              </div>
                            </div>
                          )}
                          {u.instruction_manual != null && (
                            <div className="utilities__detail">
                              <div className="utilities__detail-label">Instruction Manual</div>
                              <div className="utilities__detail-value">
                                <a
                                  href={u.instruction_manual}
                                  target="_blank"
                                  rel="noopener noreferrer"
                                  onClick={e => e.stopPropagation()}
                                  className="detail-link"
                                >
                                  {u.instruction_manual}
                                </a>
                              </div>
                            </div>
                          )}
                        </div>
                      </td>
                    </tr>
                  )}
                </>
              );
            })}
          </tbody>
        </table>
        {filtered.length === 0 && (
          <div className="utilities__empty">No utilities match your filters.</div>
        )}
      </div>
    </div>
  );
};

export default Utilities;
