# Refactoring Plan: Shared DataTable Component

## Context

The 5 data table components (Manufacturers, Pedals, MidiControllers, Pedalboards, Utilities) share ~92% identical code — state management, sort logic, filter UI, table rendering, expanded rows, and SCSS. Each component is 250-600+ lines of TSX and ~260 lines of SCSS, with only the data interface, column definitions, filter config, and expanded row details varying. This refactoring extracts all shared logic into a generic `DataTable<T>` component and consolidates the duplicated SCSS. NotFound is trivial (11 lines) and stays as-is.

---

## New Files

### 1. `apps/web/src/utils/formatters.ts`

Shared formatting functions extracted from all 5 components:

```typescript
export function formatMsrp(cents: number | null): string {
  if (cents == null) return '\u2014';
  return `$${(cents / 100).toFixed(2)}`;
}

export function formatDimensions(w: number | null, d: number | null, h: number | null): string {
  if (w != null && d != null && h != null) return `${w} \u00d7 ${d} \u00d7 ${h} mm`;
  return '\u2014';
}

export function formatPower(voltage: string | null, current: number | null): string {
  if (voltage && current) return `${voltage} / ${current}mA`;
  if (voltage) return voltage;
  if (current) return `${current}mA`;
  return '\u2014';
}
```

### 2. `apps/web/src/components/DataTable/index.tsx`

Generic component. Props interface:

```typescript
import { ReactNode } from 'react';

export interface ColumnDef<T> {
  label: string;
  width: number;
  align?: 'left' | 'center' | 'right';
  sortKey?: keyof T;              // omit = not sortable
  render: (item: T) => ReactNode; // renders <td> content
}

export interface FilterConfig<T> {
  label: string;                         // "Type", "Status"
  options: readonly string[];            // ['All', 'In Production', 'Discontinued']
  predicate: (item: T, value: string) => boolean;
}

export interface DataTableProps<T extends { id: number }> {
  title: string;                         // "Pedal Database"
  entityName: string;                    // "pedal"
  entityNamePlural: string;              // "pedals"
  stats: (data: T[]) => string;          // "67 pedals · 50 in production"
  data: T[];
  columns: ColumnDef<T>[];
  filters: FilterConfig<T>[];
  searchFields: (keyof T)[];             // ['manufacturer', 'model']
  searchPlaceholder?: string;            // "Search pedals..."
  renderExpandedRow: (item: T) => ReactNode;
  defaultSortKey?: keyof T;              // initial sort column
  minTableWidth?: number;                // default 1100
}
```

**Internal state managed by DataTable:**
- `search` (string)
- `filterValues` (string[] — one per filter, all initialized to 'All')
- `sortKey` (keyof T | null)
- `sortDir` (1 | -1)
- `expandedId` (number | null)

**Internal logic (currently duplicated across all 5):**
- `useMemo` filtering: apply search across `searchFields`, then apply each filter's predicate
- `useMemo` sorting: null-safe comparator for boolean/number/string with direction
- `handleSort`: toggle direction or switch column
- Filter count display with singular/plural entity name

**JSX structure (shared):**
- `.data-table` wrapper
- Header: title + stats
- Filters: search input + filter dropdowns + count
- Table: `<thead>` with sortable column headers + `<tbody>` with rows + expanded rows
- Empty state

### 3. `apps/web/src/components/DataTable/index.scss`

Single shared stylesheet using `.data-table` as the BEM block. Contains all ~250 lines of shared styles currently duplicated 5 times:
- Root (font, background, colors, padding)
- `__header`, `__title-group`, `__title`, `__stats`
- `__filters`, `__search-wrapper`, `__search-icon`, `__search`, `__select`, `__filter-count`
- `__table-wrapper`, `__table` (min-width from prop via CSS variable or default)
- `__th`, `__sort-icon`
- `__row` (`.even`, `.odd`, `:hover`, `.expanded`)
- `__td` (base only)
- `__expanded-row`, `__expanded-cell`, `__expanded-content`
- `__detail`, `__detail-label`, `__detail-value`, `__detail-value--highlight`
- `__empty`

### 4. `apps/web/src/styles/badges.scss`

All badge and utility classes consolidated from the 5 component SCSS files:
- `.status-badge` (`--in-production`, `--discontinued`, `--active`, `--defunct`, `--unknown`)
- `.reliability-badge` (`--high`, `--medium`, `--low`)
- `.effect-badge` (`--gain`, `--fuzz`, `--compression`, `--delay`, `--reverb`, `--preamp`, `--utility`, `--multi-effects`, `--other`, `--amp-cab-sim`)
- `.loop-badge`
- `.null-value`
- `.detail-link`, `.website-link` (consolidate to `.detail-link`)
- `.bool-yes`, `.bool-no`
- `.pedal-count-highlight`, `.pedal-count-zero`

Imported once in `apps/web/src/index.scss` so they're globally available.

---

## Modified Files

### 5. `apps/web/src/index.scss`

Add import for the new badges stylesheet:

```scss
@import './styles/badges';
```

### 6–10. Entity Components (Refactored to Thin Wrappers)

Each becomes ~50-120 lines instead of 250-600+:

**`apps/web/src/components/Pedals/index.tsx`** — defines Pedal interface, DATA array, columns with render functions, filters, expanded row renderer, stats function. Renders `<DataTable<Pedal> ... />`.

**`apps/web/src/components/Manufacturers/index.tsx`** — same pattern for Manufacturer data.

**`apps/web/src/components/MidiControllers/index.tsx`** — same pattern for MidiController data.

**`apps/web/src/components/Pedalboards/index.tsx`** — same pattern for Pedalboard data.

**`apps/web/src/components/Utilities/index.tsx`** — same pattern for Utility data.

Example of what `Pedals/index.tsx` looks like after refactoring:

```typescript
import DataTable, { ColumnDef, FilterConfig } from '../DataTable';
import { formatMsrp, formatDimensions, formatPower } from '../../utils/formatters';

interface Pedal { /* ... same fields ... */ }

const DATA: Pedal[] = [ /* ... same hardcoded data ... */ ];

const EFFECT_TYPES = ['All', ...new Set(DATA.map(d => d.effect_type).filter((t): t is string => t !== null))].sort();

const columns: ColumnDef<Pedal>[] = [
  { label: 'Manufacturer', width: 160, sortKey: 'manufacturer',
    render: p => <span style={{ color: '#f0f0f0', fontSize: '12.5px', fontWeight: 600, fontFamily: "'Helvetica Neue', sans-serif" }}>{p.manufacturer}</span> },
  { label: 'Model', width: 200, sortKey: 'model',
    render: p => <span style={{ color: '#d0d0d0' }}>{p.model}</span> },
  { label: 'Type', width: 120, align: 'center', sortKey: 'effect_type',
    render: p => p.effect_type
      ? <span className={`effect-badge effect-badge--${p.effect_type.toLowerCase().replace(/[\s/]+/g, '-')}`}>{p.effect_type}</span>
      : <span className="null-value">{'\u2014'}</span> },
  // ... remaining columns ...
];

const filters: FilterConfig<Pedal>[] = [
  { label: 'Type', options: EFFECT_TYPES,
    predicate: (p, v) => v === 'All' || p.effect_type === v },
  { label: 'Status', options: ['All', 'In Production', 'Discontinued'],
    predicate: (p, v) => v === 'All' || (v === 'In Production') === p.in_production },
  { label: 'Reliability', options: ['All', 'High', 'Medium', 'Low'],
    predicate: (p, v) => v === 'All' || p.data_reliability === v },
];

const renderExpandedRow = (p: Pedal) => (
  <>
    {p.bypass_type != null && <div className="data-table__detail">...</div>}
    {/* ... remaining detail fields ... */}
  </>
);

const stats = (data: Pedal[]) => {
  const inProd = data.filter(p => p.in_production).length;
  const types = new Set(data.map(p => p.effect_type).filter(t => t !== null)).size;
  return `${data.length} pedals \u00b7 ${inProd} in production \u00b7 ${types} effect types`;
};

const Pedals = () => (
  <DataTable<Pedal>
    title="Pedal Database"
    entityName="pedal"
    entityNamePlural="pedals"
    stats={stats}
    data={DATA}
    columns={columns}
    filters={filters}
    searchFields={['manufacturer', 'model']}
    searchPlaceholder="Search pedals..."
    renderExpandedRow={renderExpandedRow}
    defaultSortKey="manufacturer"
  />
);

export default Pedals;
```

### 11. `apps/web/src/components/NotFound/index.tsx` and `index.scss`

**No changes.** Too trivial to warrant refactoring.

---

## Files to Delete

After refactoring, remove the now-unused standalone SCSS files:

- `apps/web/src/components/Manufacturers/index.scss`
- `apps/web/src/components/Pedals/index.scss`
- `apps/web/src/components/MidiControllers/index.scss`
- `apps/web/src/components/Pedalboards/index.scss`
- `apps/web/src/components/Utilities/index.scss`

Each entity component's `import './index.scss'` is also removed. All styling comes from `DataTable/index.scss` (imported by DataTable) and `styles/badges.scss` (imported globally).

---

## Implementation Order

1. Create `utils/formatters.ts`
2. Create `styles/badges.scss` and import it in `index.scss`
3. Create `DataTable/index.tsx` and `DataTable/index.scss`
4. Refactor each entity component one at a time (Manufacturers -> Pedals -> MidiControllers -> Pedalboards -> Utilities), verifying each works before moving to the next
5. Delete unused SCSS files
6. Run build + tests to verify

---

## Verification

1. `npm run web:build` — ensures TypeScript compiles and webpack bundles
2. `npm run web:test` — ensures existing tests pass
3. Manual check: start dev server (`npm run web`), navigate to each view (Manufacturers, Pedals, MIDI Controllers, Pedalboards, Utilities, 404), verify:
   - Table renders with correct data
   - Search filtering works
   - Dropdown filters work
   - Column sorting works (click headers, toggle direction)
   - Expanded rows show correct detail fields
   - Badge colors/styles render correctly
   - Empty state shows when no results match
   - Visual appearance is identical to before
