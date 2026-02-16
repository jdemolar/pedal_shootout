import './index.scss';
import { useState, useMemo, ReactNode, Fragment } from 'react';

export interface ColumnDef<T> {
  label: string;
  width: number;
  align?: 'left' | 'center' | 'right';
  sortKey?: keyof T;
  render: (item: T) => ReactNode;
}

export interface FilterConfig<T> {
  label: string;
  options: readonly string[];
  predicate: (item: T, value: string) => boolean;
}

export interface DataTableProps<T extends { id: number }> {
  title: string;
  entityName: string;
  entityNamePlural: string;
  stats: (data: T[]) => string;
  data: T[];
  columns: ColumnDef<T>[];
  filters: FilterConfig<T>[];
  searchFields: (keyof T)[];
  searchPlaceholder?: string;
  renderExpandedRow: (item: T) => ReactNode;
  renderRowAction?: (item: T) => ReactNode;
  defaultSortKey?: keyof T;
  minTableWidth?: number;
  loading?: boolean;
  error?: string | null;
}

function DataTable<T extends { id: number }>({
  title,
  entityName,
  entityNamePlural,
  stats,
  data,
  columns,
  filters,
  searchFields,
  searchPlaceholder,
  renderExpandedRow,
  renderRowAction,
  defaultSortKey,
  minTableWidth = 1100,
  loading = false,
  error = null,
}: DataTableProps<T>) {
  const [search, setSearch] = useState('');
  const [filterValues, setFilterValues] = useState<string[]>(() => filters.map(() => 'All'));
  const [sortKey, setSortKey] = useState<keyof T | null>(defaultSortKey ?? null);
  const [sortDir, setSortDir] = useState<1 | -1>(1);
  const [expandedId, setExpandedId] = useState<number | null>(null);

  const filtered = useMemo(() => {
    let result = data;

    if (search) {
      const s = search.toLowerCase();
      result = result.filter(item =>
        searchFields.some(field => {
          const val = item[field];
          return val != null && String(val).toLowerCase().includes(s);
        })
      );
    }

    filters.forEach((f, i) => {
      const value = filterValues[i];
      if (value !== 'All') {
        result = result.filter(item => f.predicate(item, value));
      }
    });

    if (sortKey == null) return result;

    return [...result].sort((a, b) => {
      const va = a[sortKey];
      const vb = b[sortKey];

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
  }, [search, filterValues, sortKey, sortDir, data, searchFields, filters]);

  const handleSort = (key: keyof T) => {
    if (sortKey === key) {
      setSortDir(d => (d === 1 ? -1 : 1));
    } else {
      setSortKey(key);
      setSortDir(1);
    }
  };

  const setFilterValue = (index: number, value: string) => {
    setFilterValues(prev => {
      const next = [...prev];
      next[index] = value;
      return next;
    });
  };

  if (loading) {
    return (
      <div className="data-table">
        <div className="data-table__header">
          <div className="data-table__title-group">
            <h1 className="data-table__title">{title}</h1>
          </div>
        </div>
        <div className="data-table__loading">Loading {entityNamePlural}...</div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="data-table">
        <div className="data-table__header">
          <div className="data-table__title-group">
            <h1 className="data-table__title">{title}</h1>
          </div>
        </div>
        <div className="data-table__error">Failed to load {entityNamePlural}: {error}</div>
      </div>
    );
  }

  return (
    <div className="data-table">
      <div className="data-table__header">
        <div className="data-table__title-group">
          <h1 className="data-table__title">{title}</h1>
          <span className="data-table__stats">{stats(data)}</span>
        </div>
      </div>

      <div className="data-table__filters">
        <div className="data-table__search-wrapper">
          <span className="data-table__search-icon">&#x2315;</span>
          <input
            type="text"
            value={search}
            onChange={e => setSearch(e.target.value)}
            placeholder={searchPlaceholder ?? `Search ${entityNamePlural}...`}
            className="data-table__search"
          />
        </div>

        {filters.map((f, i) => (
          <select
            key={f.label}
            value={filterValues[i]}
            onChange={e => setFilterValue(i, e.target.value)}
            className="data-table__select"
          >
            {f.options.map(opt => (
              <option key={opt} value={opt}>
                {opt === 'All' ? `${f.label}: All` : opt}
              </option>
            ))}
          </select>
        ))}

        <span className="data-table__filter-count">
          {filtered.length} {filtered.length === 1 ? entityName : entityNamePlural} shown
        </span>
      </div>

      <div className="data-table__table-wrapper">
        <table className="data-table__table" style={{ minWidth: minTableWidth }}>
          <thead>
            <tr>
              {columns.map((col, ci) => (
                <th
                  key={ci}
                  onClick={() => col.sortKey != null ? handleSort(col.sortKey) : undefined}
                  className="data-table__th"
                  style={{
                    width: col.width,
                    textAlign: col.align || 'left',
                    cursor: col.sortKey != null ? 'pointer' : 'default',
                  }}
                >
                  {col.label}
                  {col.sortKey != null && (
                    <span className={`data-table__sort-icon ${sortKey === col.sortKey ? 'active' : ''}`}>
                      {sortKey === col.sortKey ? (sortDir === 1 ? '\u25b2' : '\u25bc') : '\u21c5'}
                    </span>
                  )}
                </th>
              ))}
              {renderRowAction != null && (
                <th className="data-table__th data-table__th--action" style={{ width: 40 }} />
              )}
            </tr>
          </thead>
          <tbody>
            {filtered.map((item, i) => {
              const isExpanded = expandedId === item.id;

              return (
                <Fragment key={item.id}>
                  <tr
                    onClick={() => setExpandedId(isExpanded ? null : item.id)}
                    className={`data-table__row ${isExpanded ? 'expanded' : ''} ${i % 2 === 0 ? 'even' : 'odd'}`}
                  >
                    {columns.map((col, ci) => (
                      <td
                        key={ci}
                        className="data-table__td"
                        style={{ textAlign: col.align || 'left' }}
                      >
                        {col.render(item)}
                      </td>
                    ))}
                    {renderRowAction != null && (
                      <td className="data-table__td data-table__td--action">
                        {renderRowAction(item)}
                      </td>
                    )}
                  </tr>
                  {isExpanded && (
                    <tr className="data-table__expanded-row">
                      <td colSpan={columns.length + (renderRowAction != null ? 1 : 0)} className="data-table__expanded-cell">
                        <div className="data-table__expanded-content">
                          {renderExpandedRow(item)}
                        </div>
                      </td>
                    </tr>
                  )}
                </Fragment>
              );
            })}
          </tbody>
        </table>
        {filtered.length === 0 && (
          <div className="data-table__empty">No {entityNamePlural} match your filters.</div>
        )}
      </div>
    </div>
  );
}

export default DataTable;
