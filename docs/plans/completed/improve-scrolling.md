# Plan: Sticky Nav, Filters, and Table Headers

## Context

Currently, the entire page scrolls via the browser's default body scroll. When viewing long tables (e.g., 104 pedals), the navbar, page title, filters, and table headers all scroll out of view, forcing users to scroll back up to navigate, search, or re-sort. This change locks those elements to the top so only the table body rows scroll.

## Approach

Convert the app to a **viewport-locked flex layout**. The `<div className="app">` becomes a full-height flex column. The nav stays at the top naturally. A new wrapper div around `<Routes>` fills remaining space. Each page (DataTable, Workbench, etc.) uses `flex: 1` to fill that space, with only the table body (inside `.data-table__table-wrapper`) scrolling vertically.

The `<thead>` already has `position: sticky; top: 0` — once the table-wrapper becomes the vertical scroll container, headers stick automatically.

## Files to Modify

### 1. `apps/web/src/index.scss` — Lock html/body to viewport
- Add `height: 100%` to `html` and `body`
- Add `overflow: hidden` to `body`

### 2. `apps/web/src/components/App/app.scss` — Flex column layout
- `.app`: add `display: flex; flex-direction: column; height: 100vh;` (keep `overflow: hidden`)
- Add `.app__content`: `display: flex; flex-direction: column; flex: 1; min-height: 0; overflow: hidden;`

### 3. `apps/web/src/components/App/index.tsx` — Add content wrapper
- Wrap `<Routes>` in `<div className="app__content">` so all route outputs inherit flex behavior without each route needing to know about it

### 4. `apps/web/src/components/Nav/index.scss` — Prevent nav from shrinking
- Add `flex-shrink: 0;` to `.navbar`

### 5. `apps/web/src/components/DataTable/index.scss` — Core changes
- `.data-table`: remove `min-height: 100vh`, change padding from `24px 20px 40px` to `0 20px`, add `display: flex; flex-direction: column; flex: 1; overflow: hidden; min-height: 0;`
- `.data-table__header`: add `flex-shrink: 0; padding-top: 20px;`
- `.data-table__filters`: add `flex-shrink: 0;`
- `.data-table__table-wrapper`: change `overflow-x: auto` to `overflow: auto` (enables vertical scroll), add `flex: 1; min-height: 0;`
- `.data-table__context-banner`: add `flex-shrink: 0;`

### 6. `apps/web/src/components/Workbench/index.scss` — Adapt non-DataTable route
- Remove `min-height: 100vh`
- Add `flex: 1; overflow-y: auto; min-height: 0;`
- The detail-panel's `max-height: calc(100vh - 160px)` should be reviewed and may need adjustment

### 7. `apps/web/src/components/NotFound/index.scss` — Minor fix
- Add `flex: 1;` so it fills available space

## What Stays the Same
- **DataTable JSX** — no structural changes needed
- **`<thead>` sticky behavior** — already has `position: sticky; top: 0; z-index: 2`, will work correctly once table-wrapper is the scroll container
- **Horizontal scrolling** — `overflow: auto` handles both axes
- **Expanded rows** — still inside `<tbody>`, scroll normally
- **All column definitions, filters, sorting logic** — untouched
- **PowerSupplies context banner** — renders as sibling via Fragment, becomes a flex child of `app__content` with `flex-shrink: 0`

## Verification
1. Open Pedals view (104 rows) — scroll down, verify nav/filters/table headers stay fixed
2. Expand a row — verify expanded detail appears inline and scrolls normally
3. Apply filters that reduce results to < 1 screen — verify layout doesn't collapse
4. Narrow browser window — verify horizontal scroll still works within table
5. Navigate to Workbench — verify it fills viewport and scrolls its own content
6. Navigate to Power Supplies with URL filters — verify context banner stays visible above table
7. `npm run web:build` — no build errors
8. `npm run web:test` — no test regressions
