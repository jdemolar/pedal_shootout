# Data Loading Strategy at Scale

## The Problem

As views grow to thousands or tens of thousands of rows, the current "load everything in one request" approach will hit limits. Jacks data amplifies the problem but isn't the root cause.

## Payload Estimate at 10,000 Pedals

- ~500 bytes per pedal (core fields)
- ~1KB for its jacks (5 jacks × ~200 bytes each)
- Total: ~15MB for pedals alone (~5MB products, ~10MB jacks)
- Jacks roughly triple the payload

Two things break: the initial payload size and the render performance (React holds all data in memory, DataTable renders every filtered row with no virtualization).

## Two Paths

### Path 1: Server-Side Pagination

Load 50-100 rows per page, include jacks eagerly on each page. A page of 50 pedals with jacks is ~75KB — trivial. The jacks loading strategy doesn't need to change at all.

**Tradeoff:** Client-side sorting, filtering, and search all move to the server. Every filter change, sort click, and search keystroke becomes an API request (debounced). This requires new query parameters on every endpoint, Spring Data `Pageable` support, and the frontend DataTable becomes a controlled component driven by server state rather than local state. It's the right long-term answer for large datasets but a significant architectural change.

### Path 2: Keep Client-Side Filtering, Slim Down the Payload

Preserve the current "load all, filter/sort instantly on the client" experience — which is genuinely nice UX for datasets under ~5,000-10,000 items — by stripping jacks from list responses and lazy-loading them on expand.

This means:
- List endpoints return products without jacks (~5MB for 10K rows instead of ~15MB)
- Expanding a row fetches `/api/products/{id}/jacks` (one small request, already exists)
- Client-side sorting/filtering stays as-is since it operates on slim product objects

This buys significant headroom without rearchitecting the filtering model. Pair it with row virtualization (only rendering the visible ~30-50 rows in the DOM instead of all 10K) and both the payload and render bottlenecks are handled.

On the API side, this could be a query parameter (`GET /api/pedals?include=jacks` defaulting to excluded) rather than separate endpoints, so the workbench or any future view that needs jacks upfront can still request them eagerly.

## Recommended Order of Operations

The two paths aren't mutually exclusive. There's a natural ordering where each step is independently valuable and doesn't invalidate the previous one:

1. **Add row virtualization to DataTable.** Pure frontend change that fixes render performance without touching the API. Keeps the existing "load all" model working at higher row counts.

2. **Strip jacks from list responses, lazy-load on expand.** Cuts payload by ~60-70% and lets the "load all" model scale further. The expanded-row loading spinner is acceptable here because it's a deliberate choice to defer detail data — unlike the current state where the data is already present and a spinner would be gratuitous.

3. **Server-side pagination.** Needed when datasets outgrow what's reasonable to hold in client memory (~50K+ rows, or when combining product types into a unified search). At that point you're building a fundamentally different data browsing experience and the pagination architecture pays for itself.

Steps 1 and 2 together would likely carry the app through tens of thousands of products without needing to rearchitect the filtering model.
