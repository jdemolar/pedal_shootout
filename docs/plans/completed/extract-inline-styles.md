# Extract duplicated inline styles to SCSS classes

## Context

Refactoring opportunity #6 from `docs/plans/refactoring-opportunities.md`. The data view components use inline `style=` objects for cell rendering in column definitions. Two patterns are duplicated across 7 files each:

**Pattern 1 — Manufacturer name (7 files):**
```tsx
<span style={{ color: '#f0f0f0', fontSize: '12.5px', fontWeight: 600, fontFamily: "'Helvetica Neue', sans-serif" }}>{p.manufacturer}</span>
```

**Pattern 2 — Model name (7 files):**
```tsx
<span style={{ color: '#d0d0d0' }}>{p.model}</span>
```

**Files with both patterns:** `Pedals/index.tsx`, `PowerSupplies/index.tsx`, `Pedalboards/index.tsx`, `MidiControllers/index.tsx`, `Utilities/index.tsx`, `Manufacturers/index.tsx`, `Workbench/WorkbenchTable.tsx`.

The Manufacturers component also has 3 additional inline styles for column-specific colors (`#3a3a3a`, `#a0a0a0`, `#6a6a6a`) that appear only once or twice — these are low-value to extract and should stay as-is.

The existing SCSS file `DataTable/index.scss` already uses BEM naming under `.data-table` and is the natural home for these classes.

## Scope

Extract only the two high-duplication patterns (14 total occurrences → 2 CSS classes). Leave single-use inline styles alone — extracting them adds indirection without reducing duplication.

## Files to Modify

| File | Change |
|---|---|
| `apps/web/src/components/DataTable/index.scss` | Add `.data-table__cell-manufacturer` and `.data-table__cell-model` classes |
| `apps/web/src/components/Pedals/index.tsx` | Replace 2 inline styles with className |
| `apps/web/src/components/PowerSupplies/index.tsx` | Replace 2 inline styles with className |
| `apps/web/src/components/Pedalboards/index.tsx` | Replace 2 inline styles with className |
| `apps/web/src/components/MidiControllers/index.tsx` | Replace 2 inline styles with className |
| `apps/web/src/components/Utilities/index.tsx` | Replace 2 inline styles with className |
| `apps/web/src/components/Manufacturers/index.tsx` | Replace 1 inline style (manufacturer name only — model column doesn't exist here) |
| `apps/web/src/components/Workbench/WorkbenchTable.tsx` | Replace inline styles for manufacturer and model cells |

## Implementation

### 1. Add classes to `DataTable/index.scss`

Inside the `.data-table` block, add:

```scss
&__cell-manufacturer {
  color: #f0f0f0;
  font-size: 12.5px;
  font-weight: 600;
  font-family: 'Helvetica Neue', sans-serif;
}

&__cell-model {
  color: #d0d0d0;
}
```

### 2. Replace inline styles in each component

In each file's column definitions, change:

```tsx
// Before
render: p => <span style={{ color: '#f0f0f0', fontSize: '12.5px', fontWeight: 600, fontFamily: "'Helvetica Neue', sans-serif" }}>{p.manufacturer}</span>

// After
render: p => <span className="data-table__cell-manufacturer">{p.manufacturer}</span>
```

```tsx
// Before
render: p => <span style={{ color: '#d0d0d0' }}>{p.model}</span>

// After
render: p => <span className="data-table__cell-model">{p.model}</span>
```

WorkbenchTable.tsx may have slightly different render patterns — match the exact inline style and replace with the corresponding className.

## Verification

1. `npm run web:build` — no compilation errors
2. `npm run web:test` — all tests pass (snapshot test will need updating)
3. Visual check: open the app and verify manufacturer/model columns look identical to before in all data views
4. Check off item #6 in `docs/plans/refactoring-opportunities.md`
5. Move this plan to `docs/plans/completed/`
