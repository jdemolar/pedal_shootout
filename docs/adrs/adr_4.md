# #4 Store Product References Only in Workbench State
Date: February 15, 2026

## Status
Accepted

## Context
The workbench stores a list of products the user has selected. The question is whether to store full product data (all fields, jacks, details) or just enough to identify each product and fetch the rest on demand.

## Decision
Workbench state stores **only product references** — `productId`, `productType`, and `addedAt` timestamp. Full product data is fetched fresh from the API each time the workbench view mounts.

```typescript
interface WorkbenchItem {
  productId: number;
  productType: 'pedal' | 'power_supply' | 'pedalboard' | 'midi_controller' | 'utility';
  addedAt: string;
}
```

## Alternatives Considered

**Cache full product snapshots in localStorage.** Would make workbench loads instant (no API calls) and work offline. Rejected because product data changes — prices get updated, specs get corrected, new fields get added. Cached snapshots go stale silently, and users would see outdated information without knowing it. Keeping a cache invalidation strategy in sync with the API adds complexity that outweighs the load-time benefit, especially given that the API calls are fast (8-15 small parallel fetches for a typical workbench).

**Hybrid — cache with TTL.** Store full data with a timestamp and refetch if older than N minutes. Rejected as over-engineered for the current use case. Introduces a stale-while-revalidate pattern, cache versioning concerns, and migration logic when the API response shape changes. All for a marginal improvement in load time on a page that loads in under a second.

## Consequences
- The workbench view requires the API to be reachable to display product data. There is no offline workbench experience.
- Product data is always current — no stale prices, no missing fields added after a product was cached.
- localStorage usage stays minimal (a few KB for typical workbenches of 10-20 items), well within browser limits.
- Workbench load makes N parallel API calls where N is the number of items. For workbenches up to ~30 items this is fast. If larger workbenches become common, a batch endpoint (`GET /api/products/batch?ids=1,5,12`) can be added without changing the stored data model.
