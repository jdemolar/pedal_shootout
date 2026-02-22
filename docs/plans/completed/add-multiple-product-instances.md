# Allow Multiple Instances of the Same Product on the Workbench

## Context

Currently, the workbench prevents duplicate products — each product can only appear once. Users need to add multiple instances of the same product (e.g., two of the same overdrive pedal on a board). This requires introducing a unique **instance ID** for each workbench item, since `productId` alone can no longer serve as the unique key.

The WorkbenchToggle button will change from a single toggle button to a **+/- button pair with a count indicator** showing how many instances of that product are on the active workbench.

In the list view, duplicate products are **grouped into a single row with a quantity column** rather than shown as separate rows. This keeps the list compact and aligns with future shopping-list features (have/need counts, unit vs total price, purchase links). The Layout and Power views continue to render one card per instance, since physical placement is per-unit.

## Changes

### 1. `WorkbenchItem` — Add `instanceId` (`context/WorkbenchContext.tsx`)

- Add `instanceId: string` field (UUID via `generateId()`)
- Generated on `addItem()`, used everywhere as the unique key

### 2. Context API Changes (`context/WorkbenchContext.tsx`)

**`addItem`** — Remove the duplicate check. Always add a new item with a fresh `instanceId`.

**`removeItem(instanceId: string)`** — Change from removing by `productId` to removing by `instanceId`. This removes exactly one instance.

**`removeAllInstances(productId: number)`** — New function. Removes all instances of a product from the active workbench. Used by the "×" button in the list view (since grouped rows represent all instances).

**`isInWorkbench(productId)`** — Remove this function. Replace with:
- **`countInWorkbench(productId: number): number`** — Returns how many instances of a product are on the active workbench.

**`WorkbenchContextType` interface** — Update signatures:
- `removeItem: (instanceId: string) => void`
- Add `removeAllInstances: (productId: number) => void`
- Remove `isInWorkbench`, add `countInWorkbench: (productId: number) => number`

### 3. `ViewPositions` — Key by `instanceId` (`context/WorkbenchContext.tsx`)

- `updateViewPosition(view, instanceId, x, y)` — change param name from `productId` to `instanceId`
- Positions stored as `{ [instanceId: string]: { x, y } }` instead of `{ [productId: string]: { x, y } }`

### 4. `PowerConnection` — Use `instanceId` (`context/WorkbenchContext.tsx`)

- Change `sourceProductId` / `targetProductId` to `sourceInstanceId` / `targetInstanceId`
- Jack IDs remain the same (they reference database jacks), but the product association now uses instance IDs

### 5. `WorkbenchRow` — Add `instanceId` and `quantity` (`components/Workbench/WorkbenchTable.tsx`)

**New fields on `WorkbenchRow`:**
- `instanceId: string` — still present (used by Layout/Power views which receive un-grouped rows)
- `quantity: number` — how many instances of this product exist on the workbench
- `instanceIds: string[]` — all instance IDs for this product (needed for remove-one-instance operations)

**Two data paths from `useWorkbenchProducts`:**
- `rows: WorkbenchRow[]` — one row per instance, with `quantity` and `instanceIds` populated. Used by Layout and Power views.
- `groupedRows: WorkbenchRow[]` — deduplicated by `productId`, with `quantity` reflecting the count. Used by the list view.

The hook fetches each unique `productId` once (cached), then maps instances to rows.

**List view table changes:**
- Add a **Qty** column showing the quantity (e.g., "× 2")
- Use `productId` as the React `key` for grouped rows
- "×" remove button calls `removeAllInstances(row.id)` to remove the entire group
- Alternatively, could use +/- controls inline in the Qty column — but for now, "×" removes all and users add from the catalog

### 6. `WorkbenchToggle` — Redesign to +/- with count (`components/WorkbenchToggle/index.tsx`)

Replace the single toggle button with:
- A **"+"** button (always visible, always adds an instance)
- A **count indicator** showing the number on the workbench (only visible when count > 0)
- A **"−"** button (only visible when count > 0, removes the most recently added instance)

The component will use `countInWorkbench(productId)` for the count and will need access to the active workbench's items to find the right `instanceId` to remove (the last-added instance of that product).

**Styling**: Update `components/WorkbenchToggle/index.scss` for the new button group layout.

### 7. `LayoutView` — Key by `instanceId` (`components/Workbench/LayoutView.tsx`)

- Receives un-grouped `rows` (one per instance)
- Use `row.instanceId` as the React `key` and for position lookups/saves
- `getPosition` and `handleDragEnd` use `instanceId` instead of `row.id`

### 8. `PowerView` — Key by `instanceId` (`components/Workbench/PowerView.tsx`)

- Receives un-grouped `rows` (one per instance)
- `rowMap` keyed by `instanceId` instead of `row.id`
- Supply/consumer entries use `instanceId`
- Position lookups and card keys use `instanceId`
- Power connections reference `instanceId`
- `jackToProduct` becomes `jackToInstance` mapping `jackId → instanceId`

**Important**: When the same product appears twice, they share the same jack IDs from the database. In PowerView, each instance needs its own separate set of port positions. Since jacks are shared, we'll need to create **virtual jack IDs** for the power view (e.g., combining `instanceId` and `jackId`), or deduplicate by rendering port dots per-instance rather than per-jack-ID. I'll use a composite key approach: `portPositions` will be keyed by `${instanceId}:${jackId}` to keep each instance's ports independent.

### 9. `InsightsSidebar` — Minor update

Receives un-grouped `rows` (one per instance), so totals (cost, weight, item count) naturally account for duplicates with no logic changes. The item count breakdown already iterates over all rows.

### 10. `useWorkbenchProducts` hook — Optimize and group (`components/Workbench/WorkbenchTable.tsx`)

- Fetch each unique `productId` once, then create one `WorkbenchRow` per instance from the cached result
- Produce `groupedRows` by deduplicating on `productId`: take the first row's data, set `quantity` to the count, collect all `instanceIds`
- Return both `rows` (per-instance) and `groupedRows` (deduplicated)

### 11. Workbench index — Route data to views (`components/Workbench/index.tsx`)

- Pass `groupedRows` to `WorkbenchTableView` (list view)
- Pass `rows` (per-instance) to `InsightsSidebar` so totals sum correctly without needing `× quantity` logic
- Pass `rows` to `LayoutView` and `PowerView` (canvas views)
- Detail panel click handler: `handleRowClick` uses `productId` for grouped rows (detail data is identical across instances)

### 12. localStorage migration

Existing workbench data in localStorage won't have `instanceId` on items. Add a migration in `loadStore()` that assigns a `generateId()` to any item missing `instanceId`.

## Files to Modify

| File | Change |
|------|--------|
| `apps/web/src/context/WorkbenchContext.tsx` | Core: add `instanceId`, change API, add `removeAllInstances`, update positions/connections |
| `apps/web/src/components/WorkbenchToggle/index.tsx` | New +/- button group with count |
| `apps/web/src/components/WorkbenchToggle/index.scss` | Styling for button group |
| `apps/web/src/components/Workbench/WorkbenchTable.tsx` | Add `instanceId`/`quantity`/`instanceIds` to `WorkbenchRow`, add Qty column, grouped rows logic |
| `apps/web/src/components/Workbench/LayoutView.tsx` | Key by `instanceId` |
| `apps/web/src/components/Workbench/PowerView.tsx` | Key by `instanceId`, composite port keys |
| `apps/web/src/components/Workbench/index.tsx` | Route `groupedRows` to list view, `rows` to canvas views |

## Implementation Steps

Steps are ordered by dependency — each step should compile (or at least not break more than it fixes) before moving to the next.

### Step 1: Context foundation (sections 1–4, 12)
**File:** `context/WorkbenchContext.tsx`

1. Add `instanceId: string` to the `WorkbenchItem` interface
2. Add localStorage migration in `loadStore()`: iterate all workbenches' items, assign `generateId()` to any item missing `instanceId`
3. Update `addItem`: remove the duplicate check, add `instanceId: generateId()` to the new item
4. Change `removeItem` signature from `(productId: number)` to `(instanceId: string)`, filter by `instanceId` instead of `productId`
5. Add `removeAllInstances(productId: number)` — filters out all items where `item.productId === productId`
6. Replace `isInWorkbench(productId)` with `countInWorkbench(productId)` — returns `items.filter(i => i.productId === productId).length`
7. Update `updateViewPosition` param name from `productId` to `instanceId` (the stored key is already a string, so the storage format doesn't change — just what we pass in)
8. Rename `PowerConnection.sourceProductId` / `targetProductId` to `sourceInstanceId` / `targetInstanceId`
9. Update the `WorkbenchContextType` interface and the `value` memo to expose the new/renamed functions
10. Compile check: `npm run web:build` will fail here because consumers still reference the old API — that's expected, confirms the interface changed

### Step 2: WorkbenchToggle (+/- with count)  (section 6)
**Files:** `components/WorkbenchToggle/index.tsx`, `components/WorkbenchToggle/index.scss`

1. Update imports: replace `isInWorkbench` with `countInWorkbench` and `activeWorkbench` from the context
2. Get count via `countInWorkbench(productId)`
3. Replace the single `<button>` with a button group:
   - "+" button: always visible, calls `addItem(productId, productType)`, `e.stopPropagation()`
   - Count indicator: only rendered when `count > 0`, displays the number
   - "−" button: only rendered when `count > 0`, finds the last-added instance of this product from `activeWorkbench.items` (filter by `productId`, sort by `addedAt` descending, take first), calls `removeItem(instance.instanceId)`, `e.stopPropagation()`
4. Update SCSS: style the button group as an inline horizontal strip (flex row, no gap, shared border-radius on outer edges)

### Step 3: WorkbenchRow + useWorkbenchProducts hook (sections 5, 10)
**File:** `components/Workbench/WorkbenchTable.tsx`

1. Add `instanceId: string`, `quantity: number`, `instanceIds: string[]` to the `WorkbenchRow` interface
2. Update `fetchProduct` to accept the full `WorkbenchItem` (not just the item) and set `instanceId` on the returned row
3. Rewrite `useWorkbenchProducts`:
   - Deduplicate items by `productId` → fetch each unique product once
   - Map results back to per-instance rows: for each `WorkbenchItem`, clone the fetched product data and assign that item's `instanceId`
   - Compute `quantity` and `instanceIds` per `productId` (shared across all instances of the same product)
   - Build `groupedRows`: one entry per unique `productId`, using the first instance's data with aggregate `quantity` and `instanceIds`
   - Return `{ rows, groupedRows, loading, error }`
4. Update the list view table:
   - Add a Qty column between Type and Dimensions (or after Model)
   - Display `row.quantity > 1 ? `× ${row.quantity}` : ''` (or always show the number)
   - Change React `key` from `row.id` to `row.id` (still productId, since these are grouped)
   - Change remove button to call `removeAllInstances(row.id)`

### Step 4: Workbench index — wire up data routing (section 11)
**File:** `components/Workbench/index.tsx`

1. Destructure `{ rows, groupedRows, loading, error }` from `useWorkbenchProducts()`
2. Pass `groupedRows` to `WorkbenchTableView`
3. Pass `rows` (per-instance) to `InsightsSidebar`
4. Pass `rows` to `LayoutView` and `PowerView`
5. Update `handleRowClick`: the `selectedRow` toggle comparison should use `productId` (since grouped rows are keyed by product)

### Step 5: LayoutView (section 7)
**File:** `components/Workbench/LayoutView.tsx`

1. Change `getPosition` to use `row.instanceId` instead of `row.id` for the saved position lookup
2. Change `handleDragEnd` to call `updateViewPosition(VIEW_KEY, row.instanceId, x, y)`
3. Change the React `key` on `ProductCard` from `row.id` to `row.instanceId`

### Step 6: PowerView (section 8)
**File:** `components/Workbench/PowerView.tsx`

This is the most complex step due to shared jack IDs across instances.

1. Add `instanceId` to the row map: key `rowMap` by `instanceId` instead of `row.id`
2. Create virtual jack IDs: for each instance's jacks, produce a composite key `${instanceId}:${jackId}`. Use this composite key in:
   - `jackMap` (composite key → Jack object)
   - `jackToInstance` (composite key → instanceId)
   - `portPositions` (composite key → `{ x, y }`)
3. Update supply/consumer entry computation to use `instanceId` and composite jack keys
4. Update `handlePortClick` to work with composite keys — parse `instanceId` and `jackId` from the composite
5. Update `addPowerConnection` calls to use `sourceInstanceId` / `targetInstanceId`
6. Update connection rendering to look up port positions by composite key
7. Update auto-assign to produce connections with `sourceInstanceId` / `targetInstanceId`
8. Change React `key` on all `ProductCard` components from `entry.productId` to `entry.instanceId`

### Step 7: Build, test, verify
1. `npm run web:build` — fix any remaining TypeScript errors
2. `npm run web:test` — update snapshot if needed
3. Manual browser testing per the verification checklist below

## Verification

1. `npm run web:build` — confirm no TypeScript errors
2. Manual testing in browser:
   - Add a product from catalog — see "1" count and "−" button appear
   - Click "+" again — count shows "2"
   - Click "−" — count drops to "1"
   - Open workbench list view — product appears as one row with "× 2" in Qty column
   - Click "×" on the grouped row — removes all instances, count in catalog resets to 0
   - Click the grouped row — detail panel shows product details
   - Layout view — both instances appear as separate draggable cards
   - Power view — both instances appear independently with their own port dots
   - Refresh page — localStorage migration preserves existing items with generated instanceIds
3. `npm run web:test` — existing tests pass (update snapshot if needed)
