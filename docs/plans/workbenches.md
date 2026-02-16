# Workbench Feature: Implementation Plan

## Design Decisions

| Decision | Chosen Approach |
|---|---|
| Jacks in catalog views | Eager — data is already in API responses, pass through transformers and render in expanded rows |
| Workbench storage | localStorage with product ID + type only, fetch fresh data on view mount |
| Data fetching | Individual product endpoints in parallel (`Promise.all`) |
| State management | React Context at App level for add/remove/check; workbench view owns its own fetched data |
| Multiple workbenches | Full management from v1 — create, rename, switch, delete |
| Add-to-workbench UX | Icon button at each table row's trailing edge (not a checkbox) |
| Nav integration | Distinct workbench icon in nav bar (separate from catalog links, like a cart icon), with badge count |
| Workbench page layout | Dedicated `/workbench` route with unified product table + aggregate insights sidebar |
| Product detail view | Slide-out panel from right side (keeps table visible for reference) |
| Catalog deep linking | Power Supplies view accepts URL search params for pre-filtering (e.g., `?minCurrent=2780`) |

---

## Implementation Checklist

Track progress through the tasks defined in this plan. Tasks are grouped by dependency wave — each group can begin once the previous group's dependencies are met.

### Wave 1 (no dependencies — can start in parallel)
- [x] **Task 1** — Jacks in catalog expanded rows
- [x] **Task 2** — WorkbenchContext and localStorage persistence
- [ ] **Task 11** — URL-based filter params for Power Supplies view

### Wave 2 (depends on Task 2)
- [x] **Task 3** — Add-to-workbench button on catalog rows
- [x] **Task 4** — Nav workbench icon with badge
- [x] **Task 5** — Workbench management UI

### Wave 3 (depends on Tasks 2, 5)
- [ ] **Task 6** — Workbench page — unified product table

### Wave 4 (depends on Task 6)
- [ ] **Task 7** — Workbench page — slide-out detail panel
- [ ] **Task 8** — Insights sidebar — simple summaries

### Wave 5 (depends on Task 8)
- [ ] **Task 9** — Power budget insight — core

### Wave 6 (depends on Tasks 9, 11)
- [ ] **Task 10** — Power budget insight — inline suggestions and catalog link

---

## Data Model

### localStorage Schema

```typescript
interface WorkbenchStore {
  workbenches: Workbench[];
  activeWorkbenchId: string;
}

interface Workbench {
  id: string;           // UUID
  name: string;
  items: WorkbenchItem[];
  createdAt: string;    // ISO timestamp
  updatedAt: string;    // ISO timestamp
  // Phase 2 (visual layout):
  boardId?: number;     // selected pedalboard for layout background
}

interface WorkbenchItem {
  productId: number;
  productType: 'pedal' | 'power_supply' | 'pedalboard' | 'midi_controller' | 'utility';
  addedAt: string;      // ISO timestamp
  // Phase 2 (visual layout):
  position?: { x: number; y: number };
  rotation?: number;
}
```

Only IDs and types are persisted. Full product data is fetched fresh when the workbench view mounts.

### WorkbenchContext API

```typescript
interface WorkbenchContextType {
  // Workbench management
  workbenches: Workbench[];
  activeWorkbench: Workbench;
  createWorkbench: (name: string) => void;
  renameWorkbench: (id: string, name: string) => void;
  deleteWorkbench: (id: string) => void;
  setActiveWorkbench: (id: string) => void;

  // Item operations (operate on active workbench)
  addItem: (productId: number, productType: WorkbenchItem['productType']) => void;
  removeItem: (productId: number) => void;
  isInWorkbench: (productId: number) => boolean;
  clear: () => void;

  // Aggregate counts (for nav badge, etc.)
  totalItemCount: number;
}
```

Wraps the App at the top level. Persists to localStorage on every change.

---

## Workbench Page Layout

```
┌──────────────────────────────────────────────────────────────────┐
│  Nav bar                                       [🔧 Workbench 7] │
├──────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Workbench: [My Board Build ▼]  [+ New]  [Rename]  [Delete]     │
│                                                                  │
│  ┌─────────────────────────────────────┐  ┌───────────────────┐  │
│  │                                     │  │  Insights Sidebar │  │
│  │  Unified Product Table              │  │                   │  │
│  │                                     │  │  Total Cost       │  │
│  │  Mfr | Model | Type | Dims | MSRP  │  │  $1,247.00        │  │
│  │  ─────────────────────────────────  │  │  (3 of 11 unknown)│  │
│  │  JHS  | Morning Glory | Pedal | ... │  │                   │  │
│  │  Strymon | Ojai        | PSU  | ... │  │  Total Weight     │  │
│  │  ...                                │  │  2.3 kg           │  │
│  │                                     │  │                   │  │
│  │                                     │  │  MIDI Pedals      │  │
│  │                                     │  │  4 of 11 pedals   │  │
│  │                                     │  │                   │  │
│  │                                     │  │  ──────────────── │  │
│  │                                     │  │                   │  │
│  │                                     │  │  ⚡ Power Budget  │  │
│  │                                     │  │  (see below)      │  │
│  │                                     │  │                   │  │
│  └─────────────────────────────────────┘  └───────────────────┘  │
│                                                                  │
│  [Slide-out panel appears from right when a row is clicked]      │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

### Unified Product Table

Columns (shared across all product types):
- **Manufacturer**
- **Model**
- **Type** — product type badge (Pedal, PSU, Pedalboard, MIDI Controller, Utility)
- **Dimensions** — W × D × H mm
- **MSRP**
- **Weight**
- **Status** — Active / Discontinued
- **Actions** — remove from workbench button

Clicking a row opens the slide-out detail panel on the right. The panel renders full product details tailored to that product's type (pedal details for pedals, power supply details for PSUs, etc.), including jacks.

### Insights Sidebar — Simple Summaries

These are read-only totals that update as items are added/removed:

- **Total Cost** — sum of `msrp_cents`, formatted as dollars. Shows count of items with unknown MSRP (null values) so the user knows the total is incomplete.
- **Total Weight** — sum of `weight_grams`, formatted as kg. Shows count of items with unknown weight.
- **MIDI Pedals** — count of pedals where `midi_capable === true` out of total pedal count. Helpful for deciding if a MIDI controller is needed.

Board fit is **deferred** — that will be the job of the visual layout feature.

---

## Power Budget Insight (Guided)

The power budget is the flagship insight panel. Unlike the simple summaries, it's a decision-support tool that shows the user where they are in the planning process and guides them toward what they still need.

### States

**1. No power supply in workbench**

The panel calculates total current draw from all pedals and presents it as an actionable starting point:

```
⚡ Power Budget

Your 11 pedals draw 2,780mA total.
Highest single draw: Strymon Timeline (500mA)

You haven't added a power supply yet.

  Suggested supplies:
  ┌─────────────────────────────────────────────────┐
  │ Strymon Zuma R300        3000mA   $349   [+ Add]│
  │ Cioks DC7                1120mA   $290   [+ Add]│
  │   └─ expandable with: Cioks C4E  (+660mA, $129) │
  │ CIOKS Super Adapter 16   ...                     │
  └─────────────────────────────────────────────────┘

  [See all compatible power supplies →]
```

The "See all compatible" link navigates to `/power-supplies?minCurrent=2780`, which pre-filters the catalog.

**2. Power supply present but insufficient**

```
⚡ Power Budget — ⚠️ Insufficient

Your 11 pedals draw 2,780mA total.
Your Strymon Ojai provides 500mA.
  → 2,280mA short

Pedals exceeding supply capacity:
  Strymon Timeline: 500mA (maxes out a single output)
  Strymon BigSky: 300mA
  ...

  [Find additional power supplies →]
```

**3. Power supply present and sufficient**

```
⚡ Power Budget — ✓ OK

Your 8 pedals draw 820mA total.
Your Strymon Zuma R300 provides 3,000mA.
  → 2,180mA headroom (73%)
```

**4. Power supply oversized**

Same as sufficient. The headroom percentage naturally communicates this. No special treatment needed — having headroom is not a problem.

**5. Multiple power supplies**

If the workbench contains multiple power supplies, show combined capacity and per-supply breakdown:

```
⚡ Power Budget — ✓ OK

Your 11 pedals draw 2,780mA total.
Combined supply capacity: 3,620mA
  → 840mA headroom (23%)

  Cioks DC7:  1,120mA
  Cioks C4E:  +660mA (expansion)
  Strymon Ojai: 500mA
```

### Inline Suggestions

When the user needs a power supply (states 1 and 2), the panel shows 2-3 suggested supplies:

- Fetched via `/api/power-budget/supplies-for-pedals` with the workbench pedal IDs
- **Smart ranking**: supplies that can handle the full load solo listed first, then expandable supply combos
- **Expansion grouping**: supplies that are compatible via EIAJ expansion (tracked in the `product_compatibility` table) are grouped together with combined capacity shown (e.g., "Cioks DC7 + C4E = 1,780mA")
- Each suggestion has an **[+ Add]** button to add it directly to the workbench
- High-draw pedals that exceed typical per-output capacity (>500mA) are flagged, since they constrain which supplies are viable

### Filtered Catalog Link

The "See all compatible power supplies" link navigates to the Power Supplies catalog view with pre-applied filters via URL search params:

```
/power-supplies?minCurrent=2780
```

This requires the Power Supplies view to read filter criteria from `window.location.search` on mount and apply them. This is a general-purpose enhancement — URL-based filter state is useful beyond just the workbench (bookmarkable filters, shareable links).

The filtering logic for multi-supply scenarios:
- Do NOT simply exclude supplies with `total_current_ma < totalDraw` (that would filter out most supplies)
- Filter out supplies whose max single output can't power the highest-draw individual pedal
- Sort by total current capacity descending
- Show expandable supply groups (via `product_compatibility`) together so users can see combination options

---

## Implementation Tasks

### Task 1: Jacks in Catalog Expanded Rows

Update all catalog views to display jacks data in expanded rows.

**Files:**
- `apps/web/src/utils/transformers.ts` — add `jacks` field mapping to all transform functions
- `apps/web/src/components/Pedals/index.tsx` — add jacks to interface, render in `renderExpandedRow`
- Same for `PowerSupplies`, `Pedalboards`, `MidiControllers`, `Utilities`

**Work:**
- Add a `Jack` interface to each component (or a shared one) with fields: category, direction, connector_type, jack_name, position, voltage, current_ma, polarity, function, etc.
- Transform `JackApiResponse[]` to `Jack[]` in each transformer
- Render jacks as a grouped list in expanded rows (group by category: audio, power, midi, expression, usb)

**No API changes needed** — jacks are already in every response.

### Task 2: WorkbenchContext and localStorage Persistence

Build the core state management layer.

**Files:**
- `apps/web/src/context/WorkbenchContext.tsx` — new file
- `apps/web/src/components/App/index.tsx` — wrap with WorkbenchProvider

**Work:**
- Implement `WorkbenchContext` with the full API (workbench CRUD, item add/remove/check)
- Read from localStorage on mount, write on every change
- Initialize with a default "My Workbench" if localStorage is empty
- Generate UUIDs for workbench IDs (crypto.randomUUID or a simple fallback)

### Task 3: Add-to-Workbench Button on Catalog Rows

Add the icon button to DataTable rows.

**Files:**
- `apps/web/src/components/DataTable/index.tsx` — add optional `renderRowAction` prop
- All catalog view components — pass the action renderer

**Work:**
- Add an optional `renderRowAction?: (item: T) => ReactNode` prop to `DataTableProps`
- Render it as the last cell in each row (fixed-width column)
- In each catalog view, implement the action using `useContext(WorkbenchContext)`:
  - Show a `+` icon if item is not in the active workbench
  - Show a checkmark/filled icon if it is
  - Clicking toggles add/remove
- `onClick` must call `e.stopPropagation()` to prevent triggering row expand

### Task 4: Nav Workbench Icon with Badge

Add workbench access to the navigation.

**Files:**
- `apps/web/src/components/App/index.tsx` (or `Nav/index.tsx` if nav is extracted)
- Associated SCSS

**Work:**
- Add a workbench icon (toolbox or similar) to the nav bar, visually distinct from catalog links
- Show a badge with `totalItemCount` from WorkbenchContext
- Links to `/workbench`
- Add the `/workbench` route to the router

### Task 5: Workbench Management UI

Create, rename, switch, and delete workbenches.

**Files:**
- `apps/web/src/components/Workbench/index.tsx` — new file (main page component)
- Associated SCSS

**Work:**
- Dropdown selector showing all workbenches, with the active one selected
- "New Workbench" button — creates a new workbench and switches to it
- Rename — inline edit or small modal for the active workbench name
- Delete — confirmation prompt, switches to another workbench (or creates a default if none remain)
- This is the top section of the workbench page, above the table and sidebar

### Task 6: Workbench Page — Unified Product Table

The main content area of the workbench page.

**Files:**
- `apps/web/src/components/Workbench/index.tsx`
- `apps/web/src/components/Workbench/WorkbenchTable.tsx` — new file
- `apps/web/src/services/api.ts` — may need individual-fetch helper methods

**Work:**
- On mount, read item IDs/types from active workbench via context
- Fetch full product data for each item via individual API calls (`Promise.all`)
- Normalize all product types into a unified row shape:
  ```typescript
  interface WorkbenchRow {
    id: number;
    productType: string;
    manufacturer: string;
    model: string;
    width_mm: number | null;
    depth_mm: number | null;
    height_mm: number | null;
    weight_grams: number | null;
    msrp_cents: number | null;
    in_production: boolean;
    // Full type-specific data retained for detail panel:
    rawData: PedalApiResponse | PowerSupplyApiResponse | ...;
  }
  ```
- Table columns: Manufacturer, Model, Type (badge), Dimensions, MSRP, Weight, Status, Remove button
- Handle loading and error states (some products may fail to fetch if deleted from DB)

### Task 7: Workbench Page — Slide-Out Detail Panel

Full product details when a row is clicked.

**Files:**
- `apps/web/src/components/Workbench/DetailPanel.tsx` — new file
- Associated SCSS

**Work:**
- Panel slides in from the right when a table row is clicked
- Renders full product details based on `productType`:
  - Pedals: effect type, bypass, signal type, MIDI, presets, tap tempo, battery, editor, jacks
  - Power supplies: topology, outputs, voltages, mounting, expandability, jacks
  - etc.
- Includes jacks section (grouped by category)
- Close button and/or click-outside-to-close
- Panel keeps the table partially visible for reference

### Task 8: Insights Sidebar — Simple Summaries

Read-only aggregate panels.

**Files:**
- `apps/web/src/components/Workbench/InsightsSidebar.tsx` — new file
- Associated SCSS

**Work:**
- **Total Cost**: sum `msrp_cents` across all items, format as dollars. Show "(N unknown)" for null MSRPs.
- **Total Weight**: sum `weight_grams`, format as kg. Show "(N unknown)" for null weights.
- **MIDI Pedals**: count pedals with `midi_capable === true` out of total pedal count.
- **Item Count**: total items, broken down by type (e.g., "11 pedals · 1 PSU · 1 pedalboard").
- All summaries recompute when workbench items change.

### Task 9: Power Budget Insight — Core

The guided power budget panel in the sidebar.

**Files:**
- `apps/web/src/components/Workbench/PowerBudgetInsight.tsx` — new file
- Associated SCSS

**Work:**
- Calculate total current draw from all pedals' `power_current_ma` (from jacks data)
- Identify the highest single-pedal draw
- Detect power supply presence in workbench items
- Implement state machine:
  - **No supply**: show total draw, flag high-draw pedals, prompt to find one
  - **Insufficient**: show deficit, per-pedal breakdown, prompt to find additional
  - **Sufficient**: show headroom amount and percentage
  - **Multiple supplies**: show combined capacity with per-supply breakdown
- Handle null `power_current_ma` gracefully (flag pedals with unknown draw)

### Task 10: Power Budget Insight — Inline Suggestions and Catalog Link

Extend the power budget panel with actionable recommendations.

**Files:**
- `apps/web/src/components/Workbench/PowerBudgetInsight.tsx`
- `apps/web/src/services/api.ts` — add methods for Layer 2 endpoints

**Work:**
- Call `/api/power-budget/supplies-for-pedals` with workbench pedal IDs
- Display top 2-3 compatible supplies with [+ Add] buttons
- Group expandable supply combos using `product_compatibility` data (e.g., Cioks DC7 + C4E shown as a group with combined capacity)
- Smart ranking: solo-sufficient supplies first, then best combos
- "See all compatible power supplies →" link that navigates to filtered catalog

**Depends on:** Task 11 (URL filter params) for the catalog link.

### Task 11: URL-Based Filter Params for Power Supplies View

Enable the Power Supplies catalog view to accept pre-applied filters from the URL.

**Files:**
- `apps/web/src/components/PowerSupplies/index.tsx`
- `apps/web/src/components/DataTable/index.tsx` — may need to support externally-controlled initial filter state

**Work:**
- On mount, read URL search params (e.g., `?minCurrent=2780`)
- Apply as initial filter state in DataTable
- The filtering logic for multi-supply awareness:
  - Don't exclude supplies below `minCurrent` outright — only exclude supplies whose max single output can't power the highest-draw individual pedal
  - Sort by total current capacity descending
  - This may require a custom sort/filter mode or a new filter predicate
- Update URL when filters change (optional but good for bookmarkability)

---

## Task Dependencies

```
Task 1 (Jacks in catalog)         — independent, can start immediately
Task 2 (WorkbenchContext)          — independent, can start immediately

Task 3 (Add-to-workbench button)  — depends on Task 2
Task 4 (Nav icon with badge)      — depends on Task 2
Task 5 (Workbench management UI)  — depends on Task 2

Task 6 (Workbench table)          — depends on Task 2, Task 5
Task 7 (Slide-out detail panel)   — depends on Task 6
Task 8 (Simple summaries sidebar) — depends on Task 6

Task 9 (Power budget core)        — depends on Task 8
Task 10 (Suggestions + catalog)   — depends on Task 9, Task 11
Task 11 (URL filter params)       — independent (enhances Power Supplies view)
```

Tasks 1, 2, and 11 can be done in parallel as the starting batch.

---

## Future Work (Not in This Plan)

- **Visual layout view** — 2D canvas rendering of products on a pedalboard using `position`/`rotation` fields. The data model already accommodates this.
- **Board fit insight** — guided panel like power budget, but for physical dimensions. Deferred until visual layout exists, as that's the natural home for spatial planning.
- **MIDI compatibility insight** — guided panel for MIDI controller selection. The Layer 2 API endpoints exist (`/api/midi-planner/compatibility`) but the UX needs its own design pass due to complexity.
- **Pedalboard fit check** — `/api/board-planner/fit-check` integration.
- **Batch product endpoint** — `GET /api/products/batch?ids=1,5,12` if individual fetches become a performance concern with large workbenches.
