# Phase 5: Unified Shopping List

## Context

This is Phase 5 of the connections & cabling roadmap (`docs/plans/connections-and-cabling.md`). It synthesizes all connection data (audio, power, MIDI, control) into a unified cable shopping list, integrated into the existing List tab.

**Current state:** The List tab (`WorkbenchTableView`) shows products in a simple HTML table with columns for manufacturer, model, qty, type, dimensions, MSRP, weight, and status. The `InsightsSidebar` shows summary cards (items by type, total cost, total weight, MIDI count, power budget). All four connection views (Audio, MIDI, Control, Power) produce `ConnectionWarning` objects with optional `adapterImplication` fields, but these are display-only — they're shown in popovers but not aggregated anywhere.

**What this phase adds:** A `computeShoppingList()` function that scans all connections to derive cable requirements, then renders them as rows below the product table in the List tab. When connectors mismatch, the cable row itself represents the custom cable or adapter solution — there are no separate "adapter" line items. The shopping list is computed on-the-fly from connection + jack data — no new state is stored in the workbench.

**What this phase defers** (tracked in `docs/plans/todo.md`):
- Cable length estimation (requires waypoint data from Layout view cable routing, which doesn't exist yet)
- CSV export (straightforward to add later)
- User-editable cable prices
- "Have" checkbox persistence (would need a new workbench state field)

---

## Files to Create

| File | Purpose |
|---|---|
| `apps/web/src/utils/shoppingListUtils.ts` | `computeShoppingList()` — derives cable requirements from connections |
| `apps/web/src/__tests__/utils/shoppingListUtils.test.ts` | Tests for shopping list computation |

## Files to Modify

| File | Change |
|---|---|
| `apps/web/src/components/Workbench/WorkbenchTable.tsx` | Add cable rows below the product table |
| `docs/plans/todo.md` | Add deferred shopping list improvements |

---

## Step 1: `shoppingListUtils.ts`

### Types

```typescript
export type CableCategory = 'audio' | 'power' | 'midi' | 'control';

export interface CableRequirement {
  category: CableCategory;
  sourceConnectorType: string;
  targetConnectorType: string;
  label: string;                       // e.g., '1/4" TS patch cable'
  quantity: number;
  connectionIds: string[];             // which connections this serves
  requiresCustomCable: boolean;        // true when connectors mismatch
  notes: string[];                     // e.g., 'Custom cable or adapter needed'
}

export interface ShoppingList {
  cables: CableRequirement[];
  summary: {
    totalCables: number;
    totalCustomCables: number;
    byCategory: Record<CableCategory, number>;
  };
}
```

**Key design decision:** There is no separate `AdapterRequirement` type. When connectors mismatch (e.g., `5-pin DIN` ↔ `3.5mm TRS`), the solution is a single cable with the right connectors on each end — a pedalboard builder can solder a custom cable for any connector combination. The `requiresCustomCable` flag indicates that this isn't an off-the-shelf cable, and the `notes` array carries context like "Mismatched connectors — custom cable or adapter needed."

### `computeShoppingList()` function

```typescript
export function computeShoppingList(
  powerConnections: PowerConnection[],
  audioConnections: AudioConnection[],
  midiConnections: MidiConnection[],
  controlConnections: ControlConnection[],
  jackMap: Map<number, Jack>,
): ShoppingList
```

**Algorithm:**

1. **Iterate all connections** across all four categories.
2. For each connection, look up source and target jacks from `jackMap`.
3. **Derive cable type** from the two connector types:
   - Same connector type → standard cable (e.g., `1/4" TS` → `1/4" TS` = "1/4\" TS patch cable")
   - Different connector types → custom cable (e.g., `5-pin DIN to 3.5mm TRS MIDI cable`) with `requiresCustomCable: true` and a note
4. **Group identical cable types** — cables with the same `category + sourceConnectorType + targetConnectorType` are consolidated into one `CableRequirement` with `quantity` incremented and `connectionIds` aggregated.
5. **Build summary** — count totals and per-category breakdowns.

**Instance handling:** Cable quantity comes from the *connection* count, not the jack count. Connections are instance-scoped (each references a specific `instanceId` + `jackId` pair), so two instances of the same pedal with separate connections correctly produce two cable needs. The `jackMap` is only used for looking up jack metadata (connector_type, etc.) — since jack definitions are per-product (not per-instance), `groupedRows` is sufficient for building it.

### Cable label derivation

```typescript
function deriveCableLabel(
  sourceConnectorType: string | null,
  targetConnectorType: string | null,
  category: CableCategory,
  controlSubType?: string,             // 'expression', 'auxiliary', 'usb', etc.
): string
```

Rules:
- If source and target match: `"{connector} {subTypeOrCategory} cable"` (e.g., "1/4\" TS patch cable", "5-pin DIN MIDI cable", "1/4\" TRS expression cable")
- If they differ: `"{source} to {target} {subTypeOrCategory} cable"` (e.g., "5-pin DIN to 3.5mm TRS MIDI cable", "1/4\" TRS to 3.5mm TRS expression cable")
- If either is null/unknown: `"{category} cable (connector unknown)"`

The label is driven by **connector types**, not the connection category. The category is used only for the colored badge in the table's Category column. For control connections, the sub-type (expression, auxiliary, USB) is pulled from the connection's `controlType` field or jack category to produce specific labels rather than the generic "control cable."

### Connector mismatch detection

```typescript
function isCustomCable(
  sourceConnectorType: string | null,
  targetConnectorType: string | null,
): boolean {
  if (!sourceConnectorType || !targetConnectorType) return false;
  return sourceConnectorType !== targetConnectorType;
}
```

When `isCustomCable` returns true, the `CableRequirement` gets:
- `requiresCustomCable: true`
- A note: `"Mismatched connectors — custom cable or adapter needed"`

The connection validators in Phases 1–4 still produce `adapterImplication` warnings for the connection views (where they serve as FYI notices). The shopping list doesn't treat them as separate line items — it rolls them into the cable row.

---

## Step 2: Integrate into List tab (`WorkbenchTable.tsx`)

### Layout

Below the existing product table, add a "Cables & Adapters" section (only shown when there are any connections). Column headers are sortable (click to sort by Category, Description, or Qty):

```
[Existing product table]

─── Cables & Adapters ─────────────────────────────────────────
| Category ▼ | Description              | Qty | Notes                              |
|------------|--------------------------|-----|------------------------------------|
| Audio      | 1/4" TS patch cable      |  6  |                                    |
| Audio      | 1/4" TS to XLR cable     |  1  | Custom cable or adapter needed     |
| MIDI       | 5-pin DIN MIDI cable     |  2  |                                    |
| MIDI       | 5-pin DIN to 3.5mm TRS   |  1  | Custom cable or adapter needed     |
|            | MIDI cable               |     |                                    |
| Control    | 1/4" TRS expression cable|  1  |                                    |
───────────────────────────────────────────────────────────────
  Totals: 11 cables (2 custom)
```

### Implementation

The `WorkbenchTableView` component currently receives `rows` (product rows) from props. For the shopping list, it needs access to connection data.

**Choice: Option B.** `WorkbenchTableView` already calls `useWorkbench()` for `removeAllInstances`. Adding `activeWorkbench` access is consistent with existing patterns, and avoids prop drilling through the parent.

```typescript
// Inside WorkbenchTableView
const { activeWorkbench, removeAllInstances } = useWorkbench();

const shoppingList = useMemo(() => {
  // Build jackMap from rows — groupedRows is fine here because we only need
  // jack metadata (connector_type, etc.), which is the same across instances
  // of the same product. Cable *quantity* comes from the connection count,
  // not the jack count.
  const jackMap = new Map<number, Jack>();
  for (const row of rows) {
    for (const jack of row.jacks) {
      jackMap.set(jack.id, jack);
    }
  }
  return computeShoppingList(
    activeWorkbench.powerConnections ?? [],
    activeWorkbench.audioConnections ?? [],
    activeWorkbench.midiConnections ?? [],
    activeWorkbench.controlConnections ?? [],
    jackMap,
  );
}, [activeWorkbench, rows]);
```

### New props needed

None — `WorkbenchTableView` already has `rows` for the jack map, and can get `activeWorkbench` from the context hook.

### Table styling

Reuse existing `workbench__table` styling. The cables section uses the same table structure but with different columns:
- Category column: colored badge (similar to type badge) — green for audio, red for power, purple for MIDI, teal for control
- Description column: connector-driven cable label text
- Qty column: same styling as product qty
- Notes column: "Custom cable or adapter needed" for mismatched connectors

Column headers are clickable to sort by that column (lightweight sort toggle — no full `DataTable` needed since there are no expandable rows or filters).

Add a section header row spanning all columns: "Cables & Adapters" with a subtle top border to separate from products.

---

## Step 3: Tests (`shoppingListUtils.test.ts`)

### Test cases

**Cable derivation:**
- Audio connections with matching connectors → grouped cable requirement
- Audio connections with mismatched connectors → cable with `requiresCustomCable: true` and note
- MIDI connections → MIDI cable with connector-specific label
- Control connections → cable labeled by sub-type (expression, auxiliary, USB)
- Power connections → DC power cable
- Multiple connections of same cable type → single entry with qty > 1
- Connections with null connector types → cable with "unknown" note

**Custom cable detection:**
- Mismatched connectors → cable requirement with `requiresCustomCable` flag and note
- Matching connectors → `requiresCustomCable: false`, no extra notes
- Multiple identical mismatches → single cable entry with qty > 1 and `requiresCustomCable` flag

**Summary:**
- Correct totals across all categories
- Per-category breakdown is accurate
- `totalCustomCables` count matches cables with `requiresCustomCable: true`

**Label derivation:**
- Same connector types → simple label (e.g., "1/4\" TS patch cable")
- Different connector types → "A to B" label (e.g., "5-pin DIN to 3.5mm TRS MIDI cable")
- Null connectors → fallback label
- Control connections use sub-type (expression, auxiliary) instead of generic "control"

### Helper

```typescript
function makeJack(overrides: Partial<Jack> = {}): Jack {
  return {
    id: 1,
    category: 'audio',
    direction: 'output',
    jack_name: null,
    position: null,
    connector_type: '1/4" TS',
    impedance_ohms: null,
    voltage: null,
    current_ma: null,
    polarity: null,
    function_desc: null,
    is_isolated: null,
    is_buffered: null,
    has_ground_lift: null,
    has_phase_invert: null,
    group_id: null,
    ...overrides,
  };
}
```

---

## Step 4: Update InsightsSidebar

Add a "Cables" card to the InsightsSidebar showing a quick summary:

```
Cables
11 cables (2 custom)
Audio: 7 · MIDI: 3 · Control: 1
```

This gives users a quick glance at cable requirements without scrolling to the bottom of the List tab.

### Implementation

Add a new card at the bottom of InsightsSidebar (after the Power Budget card). It receives the same `rows` prop and computes the shopping list using `activeWorkbench` from context.

---

## Verification

1. `npm run web:test` — all tests pass (including new shoppingListUtils tests)
2. `npm run web:build` — compiles cleanly
3. Manual: List tab shows cable section below products when connections exist
4. Manual: Cable rows show correct category, connector-specific description, quantity
5. Manual: Custom cable/adapter rows appear for connector mismatches (single row, no separate adapter)
6. Manual: Cables section is hidden when no connections exist
7. Manual: InsightsSidebar shows cable summary card
8. Manual: Adding/removing connections updates the cable list in real-time
9. Manual: Column headers in cable table are sortable
