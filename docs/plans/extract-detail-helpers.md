# Extract expanded-row detail helper components

## Context

Refactoring opportunity #7 from `docs/plans/refactoring-opportunities.md`. The expanded-row sections in data view components repeat two JSX patterns dozens of times:

**Pattern 1 — Boolean detail (20+ occurrences across 5 components):**
```tsx
<div className="data-table__detail">
  <div className="data-table__detail-label">Label</div>
  <div className="data-table__detail-value">
    <span className={value ? 'bool-yes' : 'bool-no'}>{value ? 'Yes' : 'No'}</span>
  </div>
</div>
```

**Pattern 2 — Link detail (10 occurrences — product_page + instruction_manual × 5 components):**
```tsx
{url != null && (
  <div className="data-table__detail">
    <div className="data-table__detail-label">Label</div>
    <div className="data-table__detail-value">
      <a href={url} target="_blank" rel="noopener noreferrer" onClick={e => e.stopPropagation()} className="detail-link">
        {url}
      </a>
    </div>
  </div>
)}
```

Note: `Workbench/DetailPanel.tsx` already has its own `BoolField` and `LinkField` helpers for the workbench detail panel. Those use different class names (`detail-panel__field`, `detail-panel__label`, etc.) and serve a different UI context, so they stay unchanged.

## Approach

Create a `DetailHelpers` shared component with `BooleanDetail` and `LinkDetail`. This follows the existing pattern of shared components like `JacksList`. Each data view component replaces its repeated blocks with the helpers.

## Files to Create

| File | Purpose |
|---|---|
| `apps/web/src/components/DetailHelpers/index.tsx` | `BooleanDetail` and `LinkDetail` components |

## Files to Modify

| File | Change |
|---|---|
| `apps/web/src/components/Pedals/index.tsx` | Replace 4 boolean blocks + 2 link blocks with helpers |
| `apps/web/src/components/PowerSupplies/index.tsx` | Replace 4 boolean blocks + 2 link blocks |
| `apps/web/src/components/Pedalboards/index.tsx` | Replace 4 boolean blocks + 2 link blocks |
| `apps/web/src/components/MidiControllers/index.tsx` | Replace 6 boolean blocks + 2 link blocks |
| `apps/web/src/components/Utilities/index.tsx` | Replace 1 boolean block + 2 link blocks |

## Implementation

### 1. Create `DetailHelpers/index.tsx`

```tsx
export function BooleanDetail({ label, value }: { label: string; value: boolean }) {
  return (
    <div className="data-table__detail">
      <div className="data-table__detail-label">{label}</div>
      <div className="data-table__detail-value">
        <span className={value ? 'bool-yes' : 'bool-no'}>{value ? 'Yes' : 'No'}</span>
      </div>
    </div>
  );
}

export function LinkDetail({ label, url }: { label: string; url: string | null }) {
  if (url == null) return null;
  return (
    <div className="data-table__detail">
      <div className="data-table__detail-label">{label}</div>
      <div className="data-table__detail-value">
        <a href={url} target="_blank" rel="noopener noreferrer" onClick={e => e.stopPropagation()} className="detail-link">
          {url}
        </a>
      </div>
    </div>
  );
}
```

`LinkDetail` handles the null-guard internally — callers no longer need the `{url != null && (...)}` wrapper.

### 2. Update each data view component

Add import and replace blocks. Example for Pedals:

```tsx
import { BooleanDetail, LinkDetail } from '../DetailHelpers';

// Before (6 lines):
<div className="data-table__detail">
  <div className="data-table__detail-label">MIDI Capable</div>
  <div className="data-table__detail-value">
    <span className={p.midi_capable ? 'bool-yes' : 'bool-no'}>{p.midi_capable ? 'Yes' : 'No'}</span>
  </div>
</div>

// After (1 line):
<BooleanDetail label="MIDI Capable" value={p.midi_capable} />

// Before (10 lines):
{p.product_page != null && (
  <div className="data-table__detail">
    <div className="data-table__detail-label">Product Page</div>
    <div className="data-table__detail-value">
      <a href={p.product_page} target="_blank" rel="noopener noreferrer" onClick={e => e.stopPropagation()} className="detail-link">
        {p.product_page}
      </a>
    </div>
  </div>
)}

// After (1 line):
<LinkDetail label="Product Page" url={p.product_page} />
```

## Verification

1. `npm run web:build` — no compilation errors
2. `npm run web:test` — all tests pass (snapshot may need updating)
3. Visual check: expanded rows look identical in all data views
4. Check off item #7 in `docs/plans/refactoring-opportunities.md`
5. Move this plan to `docs/plans/completed/`
