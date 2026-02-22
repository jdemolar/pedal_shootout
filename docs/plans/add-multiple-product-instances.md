# Allow Multiple Instances of the Same Product on the Workbench

## Context

Currently, the workbench prevents duplicate products — each product can only appear once. Users need to add multiple instances of the same product (e.g., two of the same overdrive pedal on a board). This requires introducing a unique **instance ID** for each workbench item, since `productId` alone can no longer serve as the unique key.

The WorkbenchToggle button will change from a single toggle button to a **+/- button pair with a count indicator** showing how many instances of that product are on the active workbench.

## Changes

### 1. `WorkbenchItem` — Add `instanceId` (`context/WorkbenchContext.tsx`)

- Add `instanceId: string` field (UUID via `generateId()`)
- Generated on `addItem()`, used everywhere as the unique key

### 2. Context API Changes (`context/WorkbenchContext.tsx`)

**`addItem`** — Remove the duplicate check. Always add a new item with a fresh `instanceId`.

**`removeItem(instanceId: string)`** — Change from removing by `productId` to removing by `instanceId`. This removes exactly one instance.

**`isInWorkbench(productId)`** — Remove this function. Replace with:
- **`countInWorkbench(productId: number): number`** — Returns how many instances of a product are on the active workbench.

**`WorkbenchContextType` interface** — Update signatures:
- `removeItem: (instanceId: string) => void`
- Remove `isInWorkbench`, add `countInWorkbench: (productId: number) => number`

### 3. `ViewPositions` — Key by `instanceId` (`context/WorkbenchContext.tsx`)

- `updateViewPosition(view, instanceId, x, y)` — change param name from `productId` to `instanceId`
- Positions stored as `{ [instanceId: string]: { x, y } }` instead of `{ [productId: string]: { x, y } }`

### 4. `PowerConnection` — Use `instanceId` (`context/WorkbenchContext.tsx`)

- Change `sourceProductId` / `targetProductId` to `sourceInstanceId` / `targetInstanceId`
- Jack IDs remain the same (they reference database jacks), but the product association now uses instance IDs

### 5. `WorkbenchRow` — Add `instanceId` (`components/Workbench/WorkbenchTable.tsx`)

- Add `instanceId: string` to the `WorkbenchRow` interface
- `fetchProduct` receives the `WorkbenchItem` (which now has `instanceId`) and passes it through
- Use `instanceId` as the React `key` in the table rows instead of `row.id`
- Remove button calls `removeItem(row.instanceId)` instead of `removeItem(row.id)`

### 6. `WorkbenchToggle` — Redesign to +/- with count (`components/WorkbenchToggle/index.tsx`)

Replace the single toggle button with:
- A **"+"** button (always visible, always adds an instance)
- A **count indicator** showing the number on the workbench (only visible when count > 0)
- A **"−"** button (only visible when count > 0, removes the most recently added instance)

The component will use `countInWorkbench(productId)` for the count and will need access to the active workbench's items to find the right `instanceId` to remove (the last-added instance of that product).

**Styling**: Update `components/WorkbenchToggle/index.scss` for the new button group layout.

### 7. `LayoutView` — Key by `instanceId` (`components/Workbench/LayoutView.tsx`)

- Use `row.instanceId` as the React `key` and for position lookups/saves
- `getPosition` and `handleDragEnd` use `instanceId` instead of `row.id`

### 8. `PowerView` — Key by `instanceId` (`components/Workbench/PowerView.tsx`)

- `rowMap` keyed by `instanceId` instead of `row.id`
- Supply/consumer entries use `instanceId`
- Position lookups and card keys use `instanceId`
- Power connections reference `instanceId`
- `jackToProduct` becomes `jackToInstance` mapping `jackId → instanceId`

**Important**: When the same product appears twice, they share the same jack IDs from the database. In PowerView, each instance needs its own separate set of port positions. Since jacks are shared, we'll need to create **virtual jack IDs** for the power view (e.g., combining `instanceId` and `jackId`), or deduplicate by rendering port dots per-instance rather than per-jack-ID. I'll use a composite key approach: `portPositions` will be keyed by `${instanceId}:${jackId}` to keep each instance's ports independent.

### 9. `InsightsSidebar` — No structural changes needed

The sidebar already iterates over `rows` and sums values. Multiple instances of the same product will naturally count toward totals (cost, weight, item count). No changes needed.

### 10. `useWorkbenchProducts` hook — Optimize for duplicates

Currently fetches each item independently. With duplicates, the same product would be fetched multiple times. Add a simple cache: fetch each unique `productId` once, then map instances to rows.

### 11. localStorage migration

Existing workbench data in localStorage won't have `instanceId` on items. Add a migration in `loadStore()` that assigns a `generateId()` to any item missing `instanceId`.

## Files to Modify

| File | Change |
|------|--------|
| `apps/web/src/context/WorkbenchContext.tsx` | Core: add `instanceId`, change API, update positions/connections |
| `apps/web/src/components/WorkbenchToggle/index.tsx` | New +/- button group with count |
| `apps/web/src/components/WorkbenchToggle/index.scss` | Styling for button group |
| `apps/web/src/components/Workbench/WorkbenchTable.tsx` | Add `instanceId` to `WorkbenchRow`, update keys and remove logic |
| `apps/web/src/components/Workbench/LayoutView.tsx` | Key by `instanceId` |
| `apps/web/src/components/Workbench/PowerView.tsx` | Key by `instanceId`, composite port keys |
| `apps/web/src/components/Workbench/index.tsx` | Minor — pass `instanceId` through if needed |

## Verification

1. `npm run web:build` — confirm no TypeScript errors
2. Manual testing in browser:
   - Add a product from catalog — see "1" count and "−" button appear
   - Click "+" again — count shows "2"
   - Click "−" — count drops to "1"
   - Open workbench — see both instances listed
   - Remove one via "×" in the table — count in catalog updates
   - Layout view — both instances appear as separate draggable cards
   - Power view — both instances appear independently with their own port dots
   - Refresh page — localStorage migration preserves existing items with generated instanceIds
3. `npm run web:test` — existing tests pass (update snapshot if needed)
