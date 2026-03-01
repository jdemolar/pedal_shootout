# Phase 5: Unified Shopping List

## Context

This is Phase 5 of the connections & cabling roadmap (`docs/plans/connections-and-cabling.md`). It synthesizes all connection data (audio, power, MIDI, control) into a unified cable and adapter shopping list, integrated into the existing List tab.

**Current state:** The List tab (`WorkbenchTableView`) shows products in a simple HTML table with columns for manufacturer, model, qty, type, dimensions, MSRP, weight, and status. The `InsightsSidebar` shows summary cards (items by type, total cost, total weight, MIDI count, power budget). All four connection views (Audio, MIDI, Control, Power) produce `ConnectionWarning` objects with optional `adapterImplication` fields, but these are display-only — they're shown in popovers but not aggregated anywhere.

**What this phase adds:** A `computeShoppingList()` function that scans all connections to derive cable requirements and adapter needs, then renders them as rows below the product table in the List tab. The shopping list is computed on-the-fly from connection + jack data — no new state is stored in the workbench.

**What this phase defers:**
- Cable length estimation (requires waypoint data from Layout view cable routing, which doesn't exist yet)
- CSV export (straightforward to add later)
- User-editable cable prices
- "Have" checkbox persistence (would need a new workbench state field)

---

## Files to Create

| File | Purpose |
|---|---|
| `apps/web/src/utils/shoppingListUtils.ts` | `computeShoppingList()` — derives cables + adapters from connections |
| `apps/web/src/__tests__/utils/shoppingListUtils.test.ts` | Tests for shopping list computation |

## Files to Modify

| File | Change |
|---|---|
| `apps/web/src/components/Workbench/WorkbenchTable.tsx` | Add cable/adapter rows below the product table |

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
  notes: string[];                     // e.g., 'Polarity reversal needed'
}

export interface AdapterRequirement {
  fromConnectorType: string;
  toConnectorType: string;
  category: CableCategory;
  description: string;                 // from adapterImplication.description
  quantity: number;
  connectionIds: string[];
}

export interface ShoppingList {
  cables: CableRequirement[];
  adapters: AdapterRequirement[];
  summary: {
    totalCables: number;
    totalAdapters: number;
    byCategory: Record<CableCategory, { cables: number; adapters: number }>;
  };
}
```

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
   - Different connector types → the connection itself is the cable type (e.g., `1/4" TS` → `1/4" TRS`), plus check if an `adapterImplication` warning exists for this connection
4. **Group identical cable types** — cables with the same `category + sourceConnectorType + targetConnectorType` are consolidated into one `CableRequirement` with `quantity` incremented and `connectionIds` aggregated.
5. **Collect adapters** — scan all connection warnings for `adapterImplication` entries. These are separate from cables because the adapter is an additional component beyond the cable. Group identical adapters by `fromConnectorType + toConnectorType + category`.
6. **Build summary** — count totals and per-category breakdowns.

### Cable label derivation

```typescript
function deriveCableLabel(
  sourceConnectorType: string | null,
  targetConnectorType: string | null,
  category: CableCategory,
): string
```

Rules:
- If source and target match: `"{connector} {categoryLabel} cable"` (e.g., "1/4\" TS audio cable", "5-pin DIN MIDI cable")
- If they differ: `"{source} to {target} {categoryLabel} cable"` (e.g., "1/4\" TS to 1/4\" TRS audio cable")
- If either is null/unknown: `"{category} cable (connector unknown)"`

Category labels: audio = "audio", power = "DC power", midi = "MIDI", control = "control"

### Adapter collection

For each connection across all categories, run the appropriate validator (`validatePowerConnection`, `validateAudioConnection`, `validateMidiConnection`, `validateControlConnection`) and collect any warnings that have `adapterImplication`. Alternatively, since the views already compute these validations, the function could accept pre-computed validations. However, recomputing is simpler and keeps the function self-contained.

**Decision:** Recompute validations inside `computeShoppingList()`. This avoids coupling to view-specific state and makes the function testable in isolation.

Actually, this is wasteful — the validators do more work than just adapter detection, and we'd need to import all four validators. Instead, take a simpler approach:

**Revised approach:** Accept a flat list of `adapterImplication` objects extracted from connection warnings. The caller (the List tab component) can collect these from the already-computed validations in each view's context, or we can compute them at the call site.

**Simplest approach:** The function only needs jacks and connections. For adapters, just check if `sourceConnectorType !== targetConnectorType` — that's the same condition that triggers `adapterImplication` in the validators. The cable row itself covers the cable need; the adapter row is only needed when the connectors are *incompatible* (not just different). For MIDI, `5-pin DIN ↔ 3.5mm TRS` needs an adapter. For control, `1/4" TRS ↔ 3.5mm TRS` needs an adapter. For audio, `1/4" TS ↔ XLR` needs an adapter.

**Final approach:** Connector mismatch = adapter needed. The cable label already reflects the connector combination. The adapter requirement is derived from the mismatch itself, with a human-readable description.

```typescript
function needsAdapter(
  sourceConnectorType: string | null,
  targetConnectorType: string | null,
): boolean {
  if (!sourceConnectorType || !targetConnectorType) return false;
  return sourceConnectorType !== targetConnectorType;
}
```

---

## Step 2: Integrate into List tab (`WorkbenchTable.tsx`)

### Layout

Below the existing product table, add a "Cables & Adapters" section (only shown when there are any connections):

```
[Existing product table]

─── Cables & Adapters ─────────────────────────────────────────
| Category | Description              | Qty | Notes          |
|----------|--------------------------|-----|----------------|
| Audio    | 1/4" TS patch cable      |  6  |                |
| Audio    | 1/4" TS to XLR cable     |  1  | Adapter needed |
| MIDI     | 5-pin DIN MIDI cable     |  2  |                |
| Control  | 1/4" TRS expression cable|  1  |                |
| MIDI     | 5-pin DIN to 3.5mm TRS   |  1  | Adapter        |
|          | adapter                  |     |                |
───────────────────────────────────────────────────────────────
  Totals: 10 cables, 1 adapter
```

### Implementation

The `WorkbenchTableView` component currently receives `rows` (product rows) from props. For the shopping list, it needs access to connection data. Two options:

**Option A:** Pass connections + jackMap as additional props from the parent.
**Option B:** Access `activeWorkbench` directly via `useWorkbench()` inside the component.

**Choice: Option B.** `WorkbenchTableView` already calls `useWorkbench()` for `removeAllInstances`. Adding `activeWorkbench` access is consistent with existing patterns, and avoids prop drilling through the parent.

```typescript
// Inside WorkbenchTableView
const { activeWorkbench, removeAllInstances } = useWorkbench();

const shoppingList = useMemo(() => {
  // Build jackMap from rows
  const jackMap = new Map<number, Jack>();
  for (const row of allRows) {
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
}, [activeWorkbench, allRows]);
```

Where `allRows` is passed as a new prop — the non-grouped `rows` from `useWorkbenchProducts()`. The parent already has access to both `rows` and `groupedRows`.

**Wait — `WorkbenchTableView` receives `rows` which is already `groupedRows` from the parent.** We need the non-grouped `rows` (with all instances) to build a complete jack map. But actually, `groupedRows` has the same jacks per product — duplicating instances doesn't add new jacks. So `groupedRows` is sufficient for the jack map.

**Revised:** Use the existing `rows` prop (which is `groupedRows`) to build the jack map.

### New props needed

None — `WorkbenchTableView` already has `rows` for the jack map, and can get `activeWorkbench` from the context hook. However, we need the full `rows` (all instances, not just grouped) for correct jack mapping when the same product appears multiple times with different instanceIds in connections. Actually, the jack IDs are per-product, not per-instance — so groupedRows is fine.

### Table styling

Reuse existing `workbench__table` styling. The cables section uses the same table structure but with different columns:
- Category column: colored badge (similar to type badge) — green for audio, red for power, purple for MIDI, teal for control
- Description column: cable label text
- Qty column: same styling as product qty
- Notes column: warning text if adapter needed

Add a section header row spanning all columns: "Cables & Adapters" with a subtle top border to separate from products.

---

## Step 3: Tests (`shoppingListUtils.test.ts`)

### Test cases

**Cable derivation:**
- Audio connections with matching connectors → grouped cable requirement
- Audio connections with mismatched connectors → cable + adapter
- MIDI connections → MIDI cable
- Control connections → control cable
- Power connections → DC power cable
- Multiple connections of same cable type → single entry with qty > 1
- Connections with null connector types → cable with "unknown" note

**Adapter detection:**
- Mismatched connectors → adapter requirement created
- Matching connectors → no adapter
- Multiple identical mismatches → single adapter with qty > 1

**Summary:**
- Correct totals across all categories
- Per-category breakdown is accurate

**Label derivation:**
- Same connector types → simple label
- Different connector types → "A to B" label
- Null connectors → fallback label

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
10 cables, 1 adapter
Audio: 7 · MIDI: 2 · Control: 1
```

This gives users a quick glance at cable requirements without scrolling to the bottom of the List tab.

### Implementation

Add a new card at the bottom of InsightsSidebar (after the Power Budget card). It receives the same `rows` prop and computes the shopping list using `activeWorkbench` from context.

---

## Verification

1. `npm run web:test` — all tests pass (including new shoppingListUtils tests)
2. `npm run web:build` — compiles cleanly
3. Manual: List tab shows cable/adapter section below products when connections exist
4. Manual: Cable rows show correct category, description, quantity
5. Manual: Adapter rows appear for connector mismatches
6. Manual: Cables section is hidden when no connections exist
7. Manual: InsightsSidebar shows cable summary card
8. Manual: Adding/removing connections updates the cable list in real-time
