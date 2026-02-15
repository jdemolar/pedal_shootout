# Workbench Feature: Design Options

## 1. Jacks Data in Expanded Rows: Load All vs. On-Demand

**Recommendation: Use what you already have (eager).**

The jacks data is *already* in every API response — `PedalApiResponse.jacks`, `PowerSupplyApiResponse.jacks`, etc. The transformers currently only extract `power_voltage` and `power_current_ma` from the jacks array and discard the rest. You're paying the bandwidth cost already but not using the data.

To display jacks in expanded rows, you just need to:
- Pass the full jacks array through the transformer (add a `jacks` field to each component interface)
- Render it in `renderExpandedRow`

No new API calls, no lazy loading logic, no loading spinners inside expanded rows. The typical product has 3-8 jacks, so the marginal payload per product is small.

Lazy loading (fetching `/api/products/{id}/jacks` on expand) would make sense if jacks were large or rarely viewed, but they're small and they're the kind of detail a gear shopper *always* wants to see. Adding a network round-trip plus a loading state to every row expand would hurt the browsing experience — users click rows rapidly to compare, and any delay there breaks the flow.

---

## 2. Workbench: Data Model and State Management

### What to store in localStorage

Store references, not data:

```typescript
interface WorkbenchItem {
  productId: number;
  productType: 'pedal' | 'power_supply' | 'pedalboard' | 'midi_controller' | 'utility';
  addedAt: string; // ISO timestamp — useful for sort order, history
}
```

Product data changes (prices update, specs get corrected). Storing full product snapshots in localStorage means stale data. Store IDs and types only, fetch fresh data when the workbench view mounts.

### How to fetch workbench data

You have two realistic options:

**Option A — Individual fetches.** The API already has `/api/pedals/{id}`, `/api/power-supplies/{id}`, etc. Group the workbench items by type, make one call per item. For a typical workbench of 8-15 items, that's 8-15 parallel requests. Straightforward, no new endpoints needed.

**Option B — Reuse list endpoints with client-side filtering.** Fetch `/api/pedals`, `/api/power-supplies`, etc. (only the types present in the workbench), then filter client-side to just the IDs you need. This is simpler code but loads far more data than necessary. It's fine while datasets are small (hundreds), but it's conceptually wasteful and scales poorly.

**Leaning toward Option A.** It fetches exactly what's needed, the endpoints already exist, and `Promise.all` on 10 parallel requests is fast. If you later find yourself wanting batch fetches, you can add a single endpoint like `GET /api/products/batch?ids=1,5,12` without changing the frontend architecture.

### React state architecture

A React Context wrapping the app is the right level of abstraction:

```
WorkbenchProvider (at App level)
  ├── persists items[] to localStorage
  ├── exposes: addItem, removeItem, isInWorkbench, items, clear
  │
  ├── Pedals view       → calls addItem() via button on each row
  ├── PowerSupplies view → same
  ├── ... other views
  └── Workbench view     → reads items, fetches full data, computes aggregates
```

This keeps workbench state global (any view can add/check items) without prop drilling, and the context itself is lightweight — it only holds the ID/type references, not the fetched product data. The workbench view manages its own data fetching.

### "Add to Workbench" interaction in table views

A few options, in order of preference:

1. **Small icon button at the row trailing edge** (e.g., a `+` icon or toolbox icon). Toggles to a checkmark or filled icon when the item is in the workbench. Visible without expanding. This is the standard "add to list" pattern users know from shopping sites — low friction, discoverable, doesn't clutter the table.

2. **Button in the expanded row detail area.** Less discoverable — users must expand to see it — but avoids adding a column.

3. **Checkbox column.** Familiar but visually heavy and implies "select for batch action" rather than "add to a persistent list." Better suited for one-time multi-select operations.

Recommendation: option 1 with a small persistent count badge in the nav bar (like a cart icon) so users always see how many items are in their workbench.

---

## 3. Workbench View: List Now, Layout Later

The key architectural decision is separating **what's in the workbench** from **how it's rendered**. This is what makes the visual layout a natural extension rather than a rewrite.

### Data model that supports both

```typescript
interface Workbench {
  name: string;
  items: WorkbenchItem[];
  boardId?: number;        // selected pedalboard (future: background image for layout)
}

interface WorkbenchItem {
  productId: number;
  productType: string;
  addedAt: string;
  // Phase 2 fields (ignored until layout view exists):
  position?: { x: number; y: number };
  rotation?: number;
}
```

Phase 1 ignores `position`/`rotation`. Phase 2 populates them when the user drags items on a canvas. The localStorage schema doesn't need to change.

### Phase 1: List view with aggregate insights

The workbench view renders the selected items in a table (reuse `DataTable` or a simplified variant) and computes summaries:

- **Total estimated cost** — sum of `msrp_cents`
- **Power budget** — total current draw of all pedals vs. selected power supply's `total_current_ma`. The Layer 2 API already has `/api/power-budget/calculate` and `/api/power-budget/supplies-for-pedals` for this.
- **Physical fit check** — do the selected pedals fit on the selected pedalboard? `/api/board-planner/fit-check` already exists for this.
- **MIDI compatibility** — does the selected controller have enough channels/loops? `/api/midi-planner/compatibility` exists.
- **Weight total** — sum of `weight_grams`

This is already genuinely useful without any visual layout. A guitarist can curate a shortlist, see if the power supply handles the draw, check if it all fits on the board, and estimate total spend.

### Phase 2: Visual layout (future)

The same workbench data gets a second rendering mode — a 2D canvas (HTML Canvas or SVG) where items are positioned by their `position` coordinates, scaled to real dimensions using `width_mm`/`depth_mm`, and rendered on top of the pedalboard's usable area as a background.

This is a rendering concern only. The data model, localStorage schema, Context API, and aggregation logic all stay the same. The view component just swaps between `<WorkbenchListView />` and `<WorkbenchLayoutView />` via a toggle.

You could put a grayed-out "Layout View" toggle in the workbench UI from day one — it signals the direction to users and gives you a clean integration point when you build it.

### Multiple workbenches

Worth considering early: should users have one workbench or multiple? A guitarist might be planning two different boards. Storing `workbenches: Workbench[]` in localStorage rather than a single `items[]` costs almost nothing architecturally but is significantly harder to retrofit later (every component that calls `addItem` would need a workbench selector). Recommend modeling for multiple from the start, even if the UI only shows one initially.

---

## Summary of Recommendations

| Decision | Recommendation |
|---|---|
| Jacks in expanded rows | Eager — data is already in the response, just transform and render it |
| Workbench storage | localStorage with product ID + type only, fetch fresh data on view mount |
| Data fetching | Individual product endpoints in parallel (`Promise.all`) |
| State management | React Context at App level for add/remove/check, workbench view owns its own fetched data |
| Add-to-workbench UX | Small toggle icon on each table row + badge count in nav |
| Future layout support | Separate data model (what) from rendering (how); add optional `position`/`rotation` fields to workbench items |
| Multiple workbenches | Model for it in the data layer now, expose in UI later |
