import './index.scss';
import { useState, useMemo } from 'react';

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
}

// TODO: Replace with API call to Spring Boot backend
const DATA: Pedalboard[] = [
  {
    "id": 191,
    "manufacturer": "Creation Music Company",
    "model": "Aero 18 LITE",
    "in_production": true,
    "width_mm": 457.0,
    "depth_mm": 178.0,
    "height_mm": 30.0,
    "weight_grams": 272,
    "msrp_cents": 13999,
    "product_page": "https://creationmusiccompany.com/products/v3-aero-18-lite-pedalboard",
    "instruction_manual": null,
    "data_reliability": "High",
    "usable_width_mm": 457.0,
    "usable_depth_mm": 178.0,
    "surface_type": "Solid Flat",
    "material": "Aluminum",
    "has_second_tier": false,
    "has_integrated_power": false,
    "has_integrated_patch_bay": false,
    "case_included": false
  },
  {
    "id": 192,
    "manufacturer": "Creation Music Company",
    "model": "Aero 18",
    "in_production": true,
    "width_mm": 457.0,
    "depth_mm": 318.0,
    "height_mm": 30.0,
    "weight_grams": 363,
    "msrp_cents": 16999,
    "product_page": "https://creationmusiccompany.com/products/aero-18-pedalboard",
    "instruction_manual": null,
    "data_reliability": "High",
    "usable_width_mm": 457.0,
    "usable_depth_mm": 318.0,
    "surface_type": "Solid Flat",
    "material": "Aluminum",
    "has_second_tier": false,
    "has_integrated_power": false,
    "has_integrated_patch_bay": false,
    "case_included": false
  },
  {
    "id": 193,
    "manufacturer": "Creation Music Company",
    "model": "Aero 24",
    "in_production": true,
    "width_mm": 610.0,
    "depth_mm": 318.0,
    "height_mm": 30.0,
    "weight_grams": 589,
    "msrp_cents": 18999,
    "product_page": "https://creationmusiccompany.com/products/aero-24-pedalboard",
    "instruction_manual": null,
    "data_reliability": "High",
    "usable_width_mm": 610.0,
    "usable_depth_mm": 318.0,
    "surface_type": "Solid Flat",
    "material": "Aluminum",
    "has_second_tier": false,
    "has_integrated_power": false,
    "has_integrated_patch_bay": false,
    "case_included": false
  },
  {
    "id": 194,
    "manufacturer": "Creation Music Company",
    "model": "Aero 24+",
    "in_production": true,
    "width_mm": 610.0,
    "depth_mm": 406.0,
    "height_mm": 30.0,
    "weight_grams": 589,
    "msrp_cents": 20999,
    "product_page": "https://creationmusiccompany.com/products/aero-24-pedalboard-1",
    "instruction_manual": null,
    "data_reliability": "High",
    "usable_width_mm": 610.0,
    "usable_depth_mm": 406.0,
    "surface_type": "Solid Flat",
    "material": "Aluminum",
    "has_second_tier": false,
    "has_integrated_power": false,
    "has_integrated_patch_bay": false,
    "case_included": false
  },
  {
    "id": 195,
    "manufacturer": "Creation Music Company",
    "model": "Aero 28",
    "in_production": true,
    "width_mm": 711.0,
    "depth_mm": 356.0,
    "height_mm": 30.0,
    "weight_grams": 589,
    "msrp_cents": 21999,
    "product_page": "https://creationmusiccompany.com/products/aero-28-pedalboard-1",
    "instruction_manual": null,
    "data_reliability": "High",
    "usable_width_mm": 711.0,
    "usable_depth_mm": 356.0,
    "surface_type": "Solid Flat",
    "material": "Aluminum",
    "has_second_tier": false,
    "has_integrated_power": false,
    "has_integrated_patch_bay": false,
    "case_included": false
  },
  {
    "id": 196,
    "manufacturer": "Creation Music Company",
    "model": "Aero 32+",
    "in_production": true,
    "width_mm": 813.0,
    "depth_mm": 406.0,
    "height_mm": 30.0,
    "weight_grams": 907,
    "msrp_cents": 23999,
    "product_page": "https://creationmusiccompany.com/products/aero-32-pedalboard",
    "instruction_manual": null,
    "data_reliability": "High",
    "usable_width_mm": 813.0,
    "usable_depth_mm": 406.0,
    "surface_type": "Solid Flat",
    "material": "Aluminum",
    "has_second_tier": false,
    "has_integrated_power": false,
    "has_integrated_patch_bay": false,
    "case_included": false
  },
  {
    "id": 197,
    "manufacturer": "Creation Music Company",
    "model": "Elevation 18",
    "in_production": true,
    "width_mm": 457.0,
    "depth_mm": 318.0,
    "height_mm": 98.0,
    "weight_grams": 907,
    "msrp_cents": 26999,
    "product_page": "https://creationmusiccompany.com/products/elevation-18",
    "instruction_manual": null,
    "data_reliability": "High",
    "usable_width_mm": 457.0,
    "usable_depth_mm": 318.0,
    "surface_type": "Solid Flat",
    "material": "Aluminum",
    "has_second_tier": false,
    "has_integrated_power": false,
    "has_integrated_patch_bay": false,
    "case_included": false
  },
  {
    "id": 198,
    "manufacturer": "Creation Music Company",
    "model": "Elevation 24",
    "in_production": true,
    "width_mm": 610.0,
    "depth_mm": 318.0,
    "height_mm": 98.0,
    "weight_grams": 907,
    "msrp_cents": 29999,
    "product_page": "https://creationmusiccompany.com/products/v3-elevation-24-pedalboard",
    "instruction_manual": null,
    "data_reliability": "High",
    "usable_width_mm": 610.0,
    "usable_depth_mm": 318.0,
    "surface_type": "Solid Flat",
    "material": "Aluminum",
    "has_second_tier": false,
    "has_integrated_power": false,
    "has_integrated_patch_bay": false,
    "case_included": false
  },
  {
    "id": 199,
    "manufacturer": "Creation Music Company",
    "model": "Elevation 24+",
    "in_production": true,
    "width_mm": 610.0,
    "depth_mm": 406.0,
    "height_mm": 98.0,
    "weight_grams": 907,
    "msrp_cents": 31999,
    "product_page": "https://creationmusiccompany.com/products/v3-elevation-24-pedalboard-1",
    "instruction_manual": null,
    "data_reliability": "High",
    "usable_width_mm": 610.0,
    "usable_depth_mm": 406.0,
    "surface_type": "Solid Flat",
    "material": "Aluminum",
    "has_second_tier": false,
    "has_integrated_power": false,
    "has_integrated_patch_bay": false,
    "case_included": false
  },
  {
    "id": 200,
    "manufacturer": "Creation Music Company",
    "model": "Elevation 28",
    "in_production": true,
    "width_mm": 711.0,
    "depth_mm": 356.0,
    "height_mm": 98.0,
    "weight_grams": 1089,
    "msrp_cents": 32999,
    "product_page": "https://creationmusiccompany.com/products/v3-elevation-28-pedalboard",
    "instruction_manual": null,
    "data_reliability": "High",
    "usable_width_mm": 711.0,
    "usable_depth_mm": 356.0,
    "surface_type": "Solid Flat",
    "material": "Aluminum",
    "has_second_tier": false,
    "has_integrated_power": false,
    "has_integrated_patch_bay": false,
    "case_included": false
  },
  {
    "id": 201,
    "manufacturer": "Creation Music Company",
    "model": "Elevation 32+",
    "in_production": true,
    "width_mm": 813.0,
    "depth_mm": 406.0,
    "height_mm": 98.0,
    "weight_grams": 1451,
    "msrp_cents": 36999,
    "product_page": "https://creationmusiccompany.com/products/v3-elevation-32-pedalboard",
    "instruction_manual": null,
    "data_reliability": "High",
    "usable_width_mm": 813.0,
    "usable_depth_mm": 406.0,
    "surface_type": "Solid Flat",
    "material": "Aluminum",
    "has_second_tier": false,
    "has_integrated_power": false,
    "has_integrated_patch_bay": false,
    "case_included": false
  },
  {
    "id": 202,
    "manufacturer": "Creation Music Company",
    "model": "The Board (Standard Sizes)",
    "in_production": true,
    "width_mm": null,
    "depth_mm": null,
    "height_mm": 19.0,
    "weight_grams": null,
    "msrp_cents": 4999,
    "product_page": "https://creationmusiccompany.com/products/the-board-standard-sized",
    "instruction_manual": null,
    "data_reliability": "High",
    "usable_width_mm": null,
    "usable_depth_mm": null,
    "surface_type": "Solid Flat",
    "material": "Phenolic birch plywood",
    "has_second_tier": false,
    "has_integrated_power": false,
    "has_integrated_patch_bay": false,
    "case_included": false
  }
];

type SortColumn = 'manufacturer' | 'model' | 'usable_width_mm' | 'usable_depth_mm' | 'material' | 'in_production' | 'msrp_cents' | 'data_reliability';
type SortDirection = 1 | -1;

const MATERIALS = ['All', ...Array.from(new Set(DATA.map(d => d.material).filter((m): m is string => m !== null))).sort()];
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
  { key: 'manufacturer',      label: 'Manufacturer',      width: 180, sortable: true },
  { key: 'model',             label: 'Model',             width: 200, sortable: true },
  { key: 'usable_width_mm',   label: 'Width (mm)',        width: 100, align: 'center', sortable: true },
  { key: 'usable_depth_mm',   label: 'Depth (mm)',        width: 100, align: 'center', sortable: true },
  { key: 'material',          label: 'Material',          width: 120, sortable: true },
  { key: 'in_production',     label: 'Status',            width: 80,  align: 'center', sortable: true },
  { key: 'msrp_cents',        label: 'MSRP',              width: 90,  align: 'right', sortable: true },
  { key: 'manufacturer',      label: 'Dimensions',        width: 150, align: 'center', sortable: false },
  { key: 'data_reliability',  label: 'Reliability',       width: 80,  align: 'center', sortable: true },
];

const Pedalboards = () => {
  const [search, setSearch] = useState('');
  const [materialFilter, setMaterialFilter] = useState('All');
  const [statusFilter, setStatusFilter] = useState<typeof STATUSES[number]>('All');
  const [reliabilityFilter, setReliabilityFilter] = useState<typeof RELIABILITIES[number]>('All');
  const [sortCol, setSortCol] = useState<SortColumn>('manufacturer');
  const [sortDir, setSortDir] = useState<SortDirection>(1);
  const [expandedId, setExpandedId] = useState<number | null>(null);

  const filtered = useMemo(() => {
    let result = DATA;

    if (search) {
      const s = search.toLowerCase();
      result = result.filter(p => p.manufacturer.toLowerCase().includes(s) || p.model.toLowerCase().includes(s));
    }

    if (materialFilter !== 'All') {
      result = result.filter(p => p.material === materialFilter);
    }

    if (statusFilter !== 'All') {
      const inProd = statusFilter === 'In Production';
      result = result.filter(p => p.in_production === inProd);
    }

    if (reliabilityFilter !== 'All') {
      result = result.filter(p => p.data_reliability === reliabilityFilter);
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
  }, [search, materialFilter, statusFilter, reliabilityFilter, sortCol, sortDir]);

  const handleSort = (col: SortColumn) => {
    if (sortCol === col) {
      setSortDir(d => (d === 1 ? -1 : 1));
    } else {
      setSortCol(col);
      setSortDir(1);
    }
  };

  const totalBoards = DATA.length;
  const inProductionCount = DATA.filter(p => p.in_production).length;
  const uniqueMaterials = new Set(DATA.map(p => p.material).filter(m => m !== null)).size;

  const formatMsrp = (cents: number | null): string => {
    if (cents == null) return '\u2014';
    return `$${(cents / 100).toFixed(2)}`;
  };

  const formatDimensions = (w: number | null, d: number | null, h: number | null): string => {
    if (w != null && d != null && h != null) return `${w} \u00d7 ${d} \u00d7 ${h} mm`;
    return '\u2014';
  };

  return (
    <div className="pedalboards">
      <div className="pedalboards__header">
        <div className="pedalboards__title-group">
          <h1 className="pedalboards__title">Pedalboard Database</h1>
          <span className="pedalboards__stats">
            {totalBoards} boards \u00b7 {inProductionCount} in production \u00b7 {uniqueMaterials} materials
          </span>
        </div>
      </div>

      <div className="pedalboards__filters">
        <div className="pedalboards__search-wrapper">
          <span className="pedalboards__search-icon">&#x2315;</span>
          <input
            type="text"
            value={search}
            onChange={e => setSearch(e.target.value)}
            placeholder="Search pedalboards..."
            className="pedalboards__search"
          />
        </div>

        <select
          value={materialFilter}
          onChange={e => setMaterialFilter(e.target.value)}
          className="pedalboards__select"
        >
          {MATERIALS.map(m => (
            <option key={m} value={m}>
              {m === 'All' ? 'Material: All' : m}
            </option>
          ))}
        </select>

        <select
          value={statusFilter}
          onChange={e => setStatusFilter(e.target.value as typeof STATUSES[number])}
          className="pedalboards__select"
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
          className="pedalboards__select"
        >
          {RELIABILITIES.map(r => (
            <option key={r} value={r}>
              {r === 'All' ? 'Reliability: All' : r}
            </option>
          ))}
        </select>

        <span className="pedalboards__filter-count">
          {filtered.length} board{filtered.length !== 1 ? 's' : ''} shown
        </span>
      </div>

      <div className="pedalboards__table-wrapper">
        <table className="pedalboards__table">
          <thead>
            <tr>
              {COLUMNS.map((col, ci) => (
                <th
                  key={ci}
                  onClick={() => col.sortable ? handleSort(col.key) : undefined}
                  className="pedalboards__th"
                  style={{ width: col.width, textAlign: col.align || 'left', cursor: col.sortable ? 'pointer' : 'default' }}
                >
                  {col.label}
                  {col.sortable && (
                    <span className={`pedalboards__sort-icon ${sortCol === col.key ? 'active' : ''}`}>
                      {sortCol === col.key ? (sortDir === 1 ? '\u25b2' : '\u25bc') : '\u21c5'}
                    </span>
                  )}
                </th>
              ))}
            </tr>
          </thead>
          <tbody>
            {filtered.map((p, i) => {
              const isExpanded = expandedId === p.id;

              return (
                <>
                  <tr
                    key={p.id}
                    onClick={() => setExpandedId(isExpanded ? null : p.id)}
                    className={`pedalboards__row ${isExpanded ? 'expanded' : ''} ${i % 2 === 0 ? 'even' : 'odd'}`}
                  >
                    <td className="pedalboards__td pedalboards__td--manufacturer">{p.manufacturer}</td>
                    <td className="pedalboards__td pedalboards__td--model">{p.model}</td>
                    <td className="pedalboards__td pedalboards__td--number" style={{ textAlign: 'center' }}>
                      {p.usable_width_mm != null ? p.usable_width_mm : <span className="null-value">\u2014</span>}
                    </td>
                    <td className="pedalboards__td pedalboards__td--number" style={{ textAlign: 'center' }}>
                      {p.usable_depth_mm != null ? p.usable_depth_mm : <span className="null-value">\u2014</span>}
                    </td>
                    <td className="pedalboards__td pedalboards__td--material">
                      {p.material ? p.material : <span className="null-value">\u2014</span>}
                    </td>
                    <td className="pedalboards__td pedalboards__td--status" style={{ textAlign: 'center' }}>
                      <span className={`status-badge status-badge--${p.in_production ? 'in-production' : 'discontinued'}`}>
                        {p.in_production ? 'Active' : 'Disc.'}
                      </span>
                    </td>
                    <td className="pedalboards__td pedalboards__td--msrp" style={{ textAlign: 'right' }}>
                      {p.msrp_cents != null ? formatMsrp(p.msrp_cents) : <span className="null-value">\u2014</span>}
                    </td>
                    <td className="pedalboards__td pedalboards__td--dimensions" style={{ textAlign: 'center' }}>
                      {p.width_mm != null && p.depth_mm != null && p.height_mm != null ? (
                        formatDimensions(p.width_mm, p.depth_mm, p.height_mm)
                      ) : (
                        <span className="null-value">\u2014</span>
                      )}
                    </td>
                    <td className="pedalboards__td pedalboards__td--reliability" style={{ textAlign: 'center' }}>
                      {p.data_reliability ? (
                        <span className={`reliability-badge reliability-badge--${p.data_reliability.toLowerCase()}`}>
                          {p.data_reliability}
                        </span>
                      ) : (
                        <span className="null-value">\u2014</span>
                      )}
                    </td>
                  </tr>
                  {isExpanded && (
                    <tr key={`exp-${p.id}`} className="pedalboards__expanded-row">
                      <td colSpan={9} className="pedalboards__expanded-cell">
                        <div className="pedalboards__expanded-content">
                          {p.surface_type != null && (
                            <div className="pedalboards__detail">
                              <div className="pedalboards__detail-label">Surface Type</div>
                              <div className="pedalboards__detail-value">{p.surface_type}</div>
                            </div>
                          )}
                          <div className="pedalboards__detail">
                            <div className="pedalboards__detail-label">Second Tier</div>
                            <div className="pedalboards__detail-value">
                              <span className={p.has_second_tier ? 'bool-yes' : 'bool-no'}>
                                {p.has_second_tier ? 'Yes' : 'No'}
                              </span>
                            </div>
                          </div>
                          <div className="pedalboards__detail">
                            <div className="pedalboards__detail-label">Integrated Power</div>
                            <div className="pedalboards__detail-value">
                              <span className={p.has_integrated_power ? 'bool-yes' : 'bool-no'}>
                                {p.has_integrated_power ? 'Yes' : 'No'}
                              </span>
                            </div>
                          </div>
                          <div className="pedalboards__detail">
                            <div className="pedalboards__detail-label">Patch Bay</div>
                            <div className="pedalboards__detail-value">
                              <span className={p.has_integrated_patch_bay ? 'bool-yes' : 'bool-no'}>
                                {p.has_integrated_patch_bay ? 'Yes' : 'No'}
                              </span>
                            </div>
                          </div>
                          <div className="pedalboards__detail">
                            <div className="pedalboards__detail-label">Case Included</div>
                            <div className="pedalboards__detail-value">
                              <span className={p.case_included ? 'bool-yes' : 'bool-no'}>
                                {p.case_included ? 'Yes' : 'No'}
                              </span>
                            </div>
                          </div>
                          {p.weight_grams != null && (
                            <div className="pedalboards__detail">
                              <div className="pedalboards__detail-label">Weight</div>
                              <div className="pedalboards__detail-value midi-controllers__detail-value--highlight">
                                {(p.weight_grams / 1000).toFixed(2)} kg
                              </div>
                            </div>
                          )}
                          {p.product_page != null && (
                            <div className="pedalboards__detail">
                              <div className="pedalboards__detail-label">Product Page</div>
                              <div className="pedalboards__detail-value">
                                <a
                                  href={p.product_page}
                                  target="_blank"
                                  rel="noopener noreferrer"
                                  onClick={e => e.stopPropagation()}
                                  className="detail-link"
                                >
                                  {p.product_page}
                                </a>
                              </div>
                            </div>
                          )}
                          {p.instruction_manual != null && (
                            <div className="pedalboards__detail">
                              <div className="pedalboards__detail-label">Instruction Manual</div>
                              <div className="pedalboards__detail-value">
                                <a
                                  href={p.instruction_manual}
                                  target="_blank"
                                  rel="noopener noreferrer"
                                  onClick={e => e.stopPropagation()}
                                  className="detail-link"
                                >
                                  {p.instruction_manual}
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
          <div className="pedalboards__empty">No pedalboards match your filters.</div>
        )}
      </div>
    </div>
  );
};

export default Pedalboards;
