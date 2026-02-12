import './index.scss';
import { useState, useMemo } from 'react';

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

type SortColumn = 'manufacturer' | 'model' | 'footswitch_count' | 'total_preset_slots' | 'audio_loop_count' | 'in_production' | 'msrp_cents' | 'data_reliability';
type SortDirection = 1 | -1;

const CONTROLLER_TYPES = ['All', 'Pure MIDI', 'Loop Switcher'] as const;
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
  { key: 'manufacturer',       label: 'Manufacturer', width: 180, sortable: true },
  { key: 'model',              label: 'Model',        width: 200, sortable: true },
  { key: 'footswitch_count',   label: 'Switches',     width: 80,  align: 'center', sortable: true },
  { key: 'total_preset_slots', label: 'Presets',      width: 80,  align: 'right',  sortable: true },
  { key: 'audio_loop_count',   label: 'Loops',        width: 70,  align: 'center', sortable: true },
  { key: 'in_production',      label: 'Status',       width: 80,  align: 'center', sortable: true },
  { key: 'msrp_cents',         label: 'MSRP',         width: 90,  align: 'right',  sortable: true },
  { key: 'manufacturer',       label: 'Dimensions',   width: 180, align: 'center', sortable: false },
  { key: 'manufacturer',       label: 'Power',        width: 120, align: 'center', sortable: false },
  { key: 'data_reliability',   label: 'Reliability',  width: 80,  align: 'center', sortable: true },
];

const MidiControllers = () => {
  const [search, setSearch] = useState('');
  const [typeFilter, setTypeFilter] = useState<typeof CONTROLLER_TYPES[number]>('All');
  const [statusFilter, setStatusFilter] = useState<typeof STATUSES[number]>('All');
  const [reliabilityFilter, setReliabilityFilter] = useState<typeof RELIABILITIES[number]>('All');
  const [sortCol, setSortCol] = useState<SortColumn>('manufacturer');
  const [sortDir, setSortDir] = useState<SortDirection>(1);
  const [expandedId, setExpandedId] = useState<number | null>(null);

  const filtered = useMemo(() => {
    let result = DATA;

    if (search) {
      const s = search.toLowerCase();
      result = result.filter(c => c.manufacturer.toLowerCase().includes(s) || c.model.toLowerCase().includes(s));
    }

    if (typeFilter !== 'All') {
      const wantsLoops = typeFilter === 'Loop Switcher';
      result = result.filter(c => wantsLoops ? c.audio_loop_count > 0 : c.audio_loop_count === 0);
    }

    if (statusFilter !== 'All') {
      const inProd = statusFilter === 'In Production';
      result = result.filter(c => c.in_production === inProd);
    }

    if (reliabilityFilter !== 'All') {
      result = result.filter(c => c.data_reliability === reliabilityFilter);
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
  }, [search, typeFilter, statusFilter, reliabilityFilter, sortCol, sortDir]);

  const handleSort = (col: SortColumn) => {
    if (sortCol === col) {
      setSortDir(d => (d === 1 ? -1 : 1));
    } else {
      setSortCol(col);
      setSortDir(1);
    }
  };

  const totalControllers = DATA.length;
  const inProductionCount = DATA.filter(c => c.in_production).length;
  const loopSwitcherCount = DATA.filter(c => c.audio_loop_count > 0).length;

  const formatMsrp = (cents: number | null): string => {
    if (cents == null) return '\u2014';
    return `$${(cents / 100).toFixed(2)}`;
  };

  const formatDimensions = (w: number | null, d: number | null, h: number | null): string => {
    if (w != null && d != null && h != null) return `${w} \u00d7 ${d} \u00d7 ${h} mm`;
    return '\u2014';
  };

  const formatPower = (voltage: string | null, current: number | null): string => {
    if (voltage && current) return `${voltage} / ${current}mA`;
    if (voltage) return voltage;
    if (current) return `${current}mA`;
    return '\u2014';
  };

  return (
    <div className="midi-controllers">
      <div className="midi-controllers__header">
        <div className="midi-controllers__title-group">
          <h1 className="midi-controllers__title">MIDI Controller Database</h1>
          <span className="midi-controllers__stats">
            {totalControllers} controllers \u00b7 {inProductionCount} in production \u00b7 {loopSwitcherCount} loop switchers
          </span>
        </div>
      </div>

      <div className="midi-controllers__filters">
        <div className="midi-controllers__search-wrapper">
          <span className="midi-controllers__search-icon">&#x2315;</span>
          <input
            type="text"
            value={search}
            onChange={e => setSearch(e.target.value)}
            placeholder="Search controllers..."
            className="midi-controllers__search"
          />
        </div>

        <select
          value={typeFilter}
          onChange={e => setTypeFilter(e.target.value as typeof CONTROLLER_TYPES[number])}
          className="midi-controllers__select"
        >
          {CONTROLLER_TYPES.map(t => (
            <option key={t} value={t}>
              {t === 'All' ? 'Type: All' : t}
            </option>
          ))}
        </select>

        <select
          value={statusFilter}
          onChange={e => setStatusFilter(e.target.value as typeof STATUSES[number])}
          className="midi-controllers__select"
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
          className="midi-controllers__select"
        >
          {RELIABILITIES.map(r => (
            <option key={r} value={r}>
              {r === 'All' ? 'Reliability: All' : r}
            </option>
          ))}
        </select>

        <span className="midi-controllers__filter-count">
          {filtered.length} controller{filtered.length !== 1 ? 's' : ''} shown
        </span>
      </div>

      <div className="midi-controllers__table-wrapper">
        <table className="midi-controllers__table">
          <thead>
            <tr>
              {COLUMNS.map((col, ci) => (
                <th
                  key={ci}
                  onClick={() => col.sortable ? handleSort(col.key) : undefined}
                  className="midi-controllers__th"
                  style={{ width: col.width, textAlign: col.align || 'left', cursor: col.sortable ? 'pointer' : 'default' }}
                >
                  {col.label}
                  {col.sortable && (
                    <span className={`midi-controllers__sort-icon ${sortCol === col.key ? 'active' : ''}`}>
                      {sortCol === col.key ? (sortDir === 1 ? '\u25b2' : '\u25bc') : '\u21c5'}
                    </span>
                  )}
                </th>
              ))}
            </tr>
          </thead>
          <tbody>
            {filtered.map((c, i) => {
              const isExpanded = expandedId === c.id;

              return (
                <>
                  <tr
                    key={c.id}
                    onClick={() => setExpandedId(isExpanded ? null : c.id)}
                    className={`midi-controllers__row ${isExpanded ? 'expanded' : ''} ${i % 2 === 0 ? 'even' : 'odd'}`}
                  >
                    <td className="midi-controllers__td midi-controllers__td--manufacturer">{c.manufacturer}</td>
                    <td className="midi-controllers__td midi-controllers__td--model">{c.model}</td>
                    <td className="midi-controllers__td midi-controllers__td--number" style={{ textAlign: 'center' }}>
                      {c.footswitch_count}
                    </td>
                    <td className="midi-controllers__td midi-controllers__td--number" style={{ textAlign: 'right' }}>
                      {c.total_preset_slots != null ? c.total_preset_slots.toLocaleString() : <span className="null-value">\u2014</span>}
                    </td>
                    <td className="midi-controllers__td" style={{ textAlign: 'center' }}>
                      {c.audio_loop_count > 0 ? (
                        <span className="loop-badge">{c.audio_loop_count}</span>
                      ) : (
                        <span className="null-value">\u2014</span>
                      )}
                    </td>
                    <td className="midi-controllers__td midi-controllers__td--status" style={{ textAlign: 'center' }}>
                      <span className={`status-badge status-badge--${c.in_production ? 'in-production' : 'discontinued'}`}>
                        {c.in_production ? 'Active' : 'Disc.'}
                      </span>
                    </td>
                    <td className="midi-controllers__td midi-controllers__td--msrp" style={{ textAlign: 'right' }}>
                      {c.msrp_cents != null ? formatMsrp(c.msrp_cents) : <span className="null-value">\u2014</span>}
                    </td>
                    <td className="midi-controllers__td midi-controllers__td--dimensions" style={{ textAlign: 'center' }}>
                      {c.width_mm != null && c.depth_mm != null && c.height_mm != null ? (
                        formatDimensions(c.width_mm, c.depth_mm, c.height_mm)
                      ) : (
                        <span className="null-value">\u2014</span>
                      )}
                    </td>
                    <td className="midi-controllers__td midi-controllers__td--power" style={{ textAlign: 'center' }}>
                      {c.power_voltage != null || c.power_current_ma != null ? (
                        formatPower(c.power_voltage, c.power_current_ma)
                      ) : (
                        <span className="null-value">\u2014</span>
                      )}
                    </td>
                    <td className="midi-controllers__td midi-controllers__td--reliability" style={{ textAlign: 'center' }}>
                      {c.data_reliability ? (
                        <span className={`reliability-badge reliability-badge--${c.data_reliability.toLowerCase()}`}>
                          {c.data_reliability}
                        </span>
                      ) : (
                        <span className="null-value">\u2014</span>
                      )}
                    </td>
                  </tr>
                  {isExpanded && (
                    <tr key={`exp-${c.id}`} className="midi-controllers__expanded-row">
                      <td colSpan={10} className="midi-controllers__expanded-cell">
                        <div className="midi-controllers__expanded-content">
                          {c.display_type != null && (
                            <div className="midi-controllers__detail">
                              <div className="midi-controllers__detail-label">Display</div>
                              <div className="midi-controllers__detail-value">{c.display_type}</div>
                            </div>
                          )}
                          <div className="midi-controllers__detail">
                            <div className="midi-controllers__detail-label">Per-Switch Displays</div>
                            <div className="midi-controllers__detail-value">
                              <span className={c.has_per_switch_displays ? 'bool-yes' : 'bool-no'}>
                                {c.has_per_switch_displays ? 'Yes' : 'No'}
                              </span>
                            </div>
                          </div>
                          <div className="midi-controllers__detail">
                            <div className="midi-controllers__detail-label">Expression Inputs</div>
                            <div className="midi-controllers__detail-value midi-controllers__detail-value--highlight">
                              {c.expression_input_count}
                            </div>
                          </div>
                          <div className="midi-controllers__detail">
                            <div className="midi-controllers__detail-label">Aux Switch Inputs</div>
                            <div className="midi-controllers__detail-value">{c.aux_switch_input_count}</div>
                          </div>
                          <div className="midi-controllers__detail">
                            <div className="midi-controllers__detail-label">Tuner</div>
                            <div className="midi-controllers__detail-value">
                              <span className={c.has_tuner ? 'bool-yes' : 'bool-no'}>
                                {c.has_tuner ? 'Yes' : 'No'}
                              </span>
                            </div>
                          </div>
                          <div className="midi-controllers__detail">
                            <div className="midi-controllers__detail-label">Tap Tempo</div>
                            <div className="midi-controllers__detail-value">
                              <span className={c.has_tap_tempo ? 'bool-yes' : 'bool-no'}>
                                {c.has_tap_tempo ? 'Yes' : 'No'}
                              </span>
                            </div>
                          </div>
                          <div className="midi-controllers__detail">
                            <div className="midi-controllers__detail-label">Setlist Mode</div>
                            <div className="midi-controllers__detail-value">
                              <span className={c.has_setlist_mode ? 'bool-yes' : 'bool-no'}>
                                {c.has_setlist_mode ? 'Yes' : 'No'}
                              </span>
                            </div>
                          </div>
                          <div className="midi-controllers__detail">
                            <div className="midi-controllers__detail-label">Bluetooth MIDI</div>
                            <div className="midi-controllers__detail-value">
                              <span className={c.has_bluetooth_midi ? 'bool-yes' : 'bool-no'}>
                                {c.has_bluetooth_midi ? 'Yes' : 'No'}
                              </span>
                            </div>
                          </div>
                          <div className="midi-controllers__detail">
                            <div className="midi-controllers__detail-label">Software Editor</div>
                            <div className="midi-controllers__detail-value">
                              <span className={c.software_editor_available ? 'bool-yes' : 'bool-no'}>
                                {c.software_editor_available ? 'Yes' : 'No'}
                              </span>
                            </div>
                          </div>
                          {c.software_platforms != null && (
                            <div className="midi-controllers__detail">
                              <div className="midi-controllers__detail-label">Platforms</div>
                              <div className="midi-controllers__detail-value">{c.software_platforms}</div>
                            </div>
                          )}
                          {c.product_page != null && (
                            <div className="midi-controllers__detail">
                              <div className="midi-controllers__detail-label">Product Page</div>
                              <div className="midi-controllers__detail-value">
                                <a
                                  href={c.product_page}
                                  target="_blank"
                                  rel="noopener noreferrer"
                                  onClick={e => e.stopPropagation()}
                                  className="detail-link"
                                >
                                  {c.product_page}
                                </a>
                              </div>
                            </div>
                          )}
                          {c.instruction_manual != null && (
                            <div className="midi-controllers__detail">
                              <div className="midi-controllers__detail-label">Instruction Manual</div>
                              <div className="midi-controllers__detail-value">
                                <a
                                  href={c.instruction_manual}
                                  target="_blank"
                                  rel="noopener noreferrer"
                                  onClick={e => e.stopPropagation()}
                                  className="detail-link"
                                >
                                  {c.instruction_manual}
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
          <div className="midi-controllers__empty">No controllers match your filters.</div>
        )}
      </div>
    </div>
  );
};

export default MidiControllers;
