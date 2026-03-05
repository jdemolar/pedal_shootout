# Refactoring Opportunities

Analysis performed 2026-03-04 by Jack the Refactorer.

## Summary

The codebase is well-organized and follows its own conventions consistently in most places. The `DataTable<T>` generic, the `useApiData` hook, and the transformer pattern are clean abstractions. The backend follows proper layered architecture. The highest-impact findings fall into three areas:

1. **Eight identical copies of `formatMsrp` across Java DTOs** -- the most textbook DRY violation in the project.
2. **Massive boilerplate duplication in `WorkbenchContext.tsx`** -- the same add/remove/set/acknowledge pattern is copy-pasted for four connection types, producing a 687-line file that should be roughly half that size.
3. **Repeated expanded-row rendering patterns across data view components** -- the same boolean-detail, link-detail, and product-page/instruction-manual blocks appear in every component with slight variations.

---

## Checklist

### Critical
- [ ] #1 — Duplicate cycle-detection implementations (audioUtils / midiUtils)
- [x] #2 — N+1 query: ManufacturerService per-manufacturer count queries
- [x] #3 — N+1 query: DetailTypeService / PedalService per-product jack queries

### Recommended
- [ ] #4 — `formatMsrp` duplicated in 8 DTOs + 1 service
- [ ] #5 — WorkbenchContext: four identical connection CRUD patterns
- [ ] #6 — Inline styles duplicated across data view components
- [ ] #7 — Expanded-row detail blocks: boolean field pattern (21 occurrences)
- [ ] #8 — `extractPowerVoltage` / `extractPowerCurrentMa` redundant array scans
- [ ] #9 — `getMajorityPolarity` / `getMajorityConnector` identical algorithms
- [ ] #10 — `WorkbenchRow.detail` typed as `Record<string, unknown>`
- [ ] #11 — Frontend type interfaces defined locally in each component
- [ ] #12 — `WorkbenchTable.tsx` exports hook, type, and component from one file
- [ ] #13 — `fetchProductData` switch-case with five identical property extractions

### Low Priority
- [ ] #14 — `Jack` interface field `function_desc` naming
- [ ] #15 — `PowerBudgetService.getPedalPower` naming mismatch with frontend
- [ ] #16 — `useApiData` hook empty dependency array
- [ ] #17 — `PowerBudgetService.findSuppliesForPedals` duplicates jack lookup logic
- [ ] #18 — Tab alignment in App component `navElements`

---

## Critical

### 1. Duplicate cycle-detection implementations

**Files:**
- `apps/web/src/utils/audioUtils.ts:26-49`
- `apps/web/src/utils/midiUtils.ts:35-58`

**Problem:** These two functions are character-for-character identical in logic -- a BFS that traverses `sourceInstanceId -> targetInstanceId` edges. The only difference is the connection type parameter. If you fix a bug in one, you must remember to fix the other.

**Suggestion:** Extract a single generic `wouldCreateCycle` into a shared module (e.g., `graphUtils.ts`):

```typescript
interface DirectedEdge {
  sourceInstanceId: string;
  targetInstanceId: string;
}

export function wouldCreateCycle(
  sourceInstanceId: string,
  targetInstanceId: string,
  existingConnections: DirectedEdge[],
): boolean { /* single BFS implementation */ }
```

Both `AudioConnection` and `MidiConnection` already have `sourceInstanceId`/`targetInstanceId` fields, so they satisfy this interface without changes.

---

### 2. N+1 query: `ManufacturerService.findAll` issues per-manufacturer count queries

**File:** `apps/api/src/main/java/com/pedalshootout/api/service/ManufacturerService.java:48-49`

```java
return manufacturers.stream()
    .map(m -> ManufacturerDto.from(m, productRepository.countByManufacturerId(m.getId())))
    .toList();
```

**Problem:** For 232 manufacturers, this executes 232 individual `SELECT COUNT(*)` queries.

**Suggestion:** Add a grouped count query to `ProductRepository`:

```java
@Query("SELECT p.manufacturer.id, COUNT(p) FROM Product p GROUP BY p.manufacturer.id")
List<Object[]> countByManufacturerGrouped();
```

Build a `Map<Integer, Long>` in the service and look up counts in O(1). Total queries: 2 instead of 233.

---

### 3. N+1 query: `DetailTypeService` and `PedalService` issue per-product jack queries

**Files:**
- `apps/api/src/main/java/com/pedalshootout/api/service/DetailTypeService.java:50-54`
- `apps/api/src/main/java/com/pedalshootout/api/service/PedalService.java:53-56`

**Problem:** Every call to `findAll*` iterates over all detail rows and calls `jackRepository.findByProductId()` per product. For the pedals endpoint with 104 products, that is 104 additional jack queries.

**Suggestion:** Pre-fetch all jacks for the relevant product IDs in a single query:

```java
List<Integer> productIds = details.stream().map(d -> d.getProductId()).toList();
Map<Integer, List<JackDto>> jacksByProduct = jackRepository.findByProductIdIn(productIds)
    .stream()
    .collect(Collectors.groupingBy(Jack::getProductId,
        Collectors.mapping(JackDto::from, Collectors.toList())));
```

Add `findByProductIdIn(List<Integer> ids)` to `JackRepository`. This transforms O(N) queries into O(1) for jacks fetching. The same pattern applies to all five detail type endpoints.

---

## Recommended

### 4. `formatMsrp` duplicated in 8 Java DTO classes plus 1 service

**Files:** `PedalDto.java:65-68`, `PowerSupplyDto.java:64-67`, `PedalboardDto.java:63-66`, `MidiControllerDto.java:84-87`, `UtilityDto.java:64-67`, `PlugDto.java:45-48`, `ProductSummaryDto.java:57-60`, `ProductDetailDto.java:58-61`, `PowerBudgetService.java:129-132`

**Problem:** The exact same three-line method appears nine times:

```java
private static String formatMsrp(Integer cents) {
    if (cents == null) return null;
    return String.format("$%d.%02d", cents / 100, cents % 100);
}
```

**Suggestion:** Create a `DtoUtils` (or `FormatUtils`) class in the `dto` package and replace all nine copies with `DtoUtils.formatMsrp(...)`.

---

### 5. WorkbenchContext: four identical connection CRUD patterns

**File:** `apps/web/src/context/WorkbenchContext.tsx:370-563`

**Problem:** The add/remove/set/acknowledge pattern for `powerConnections`, `audioConnections`, `midiConnections`, and `controlConnections` is nearly identical (~40 lines each, ~200 lines total of repetition).

**Suggestion:** Extract a generic connection CRUD factory:

```typescript
function makeConnectionOperations<T extends { id: string; acknowledgedWarnings?: string[] }>(
  updateStore: (...) => void,
  field: keyof Workbench,
) {
  const add = (conn: Omit<T, 'id'>) => { ... };
  const remove = (connId: string) => { ... };
  const setAll = (conns: T[]) => { ... };
  const acknowledgeWarning = (connId: string, warningKey: string) => { ... };
  return { add, remove, setAll, acknowledgeWarning };
}
```

This would eliminate ~150 lines and make the pattern explicit.

---

### 6. Inline styles duplicated across all data view components

**Problem:** The same inline style objects appear in 6-7 files:

```typescript
style={{ color: '#f0f0f0', fontSize: '12.5px', fontWeight: 600, fontFamily: "'Helvetica Neue', sans-serif" }}
```

**Suggestion:** These should be CSS classes (the project already uses BEM-style SCSS):

```scss
.data-table__manufacturer-name {
  color: #f0f0f0;
  font-size: 12.5px;
  font-weight: 600;
  font-family: 'Helvetica Neue', sans-serif;
}
```

---

### 7. Expanded-row detail blocks: boolean field pattern repeated 21 times

**Problem:** The boolean detail block (`Yes`/`No` with `bool-yes`/`bool-no` classes) appears 21 times across 6 files. Product-page and instruction-manual link blocks are identical in all 5 product-type components.

**Suggestion:** Extract small helper components into `components/DetailHelpers.tsx`:

```tsx
function BooleanDetail({ label, value }: { label: string; value: boolean }) { ... }
function LinkDetail({ label, url }: { label: string; url: string }) { ... }
```

Each expanded row definition would become ~40% shorter.

---

### 8. `extractPowerVoltage` and `extractPowerCurrentMa` scan the same array twice

**File:** `apps/web/src/utils/transformers.ts:55-63`

**Problem:** Both functions perform an identical `find()` with the same predicate, and are always called back-to-back.

**Suggestion:** Combine into a single function:

```typescript
function extractPowerInfo(jacks: JackApiResponse[]): { voltage: string | null; current_ma: number | null } {
  const powerJack = jacks.find(j => j.category === 'power' && j.direction === 'input');
  return { voltage: powerJack?.voltage ?? null, current_ma: powerJack?.currentMa ?? null };
}
```

---

### 9. `getMajorityPolarity` and `getMajorityConnector` are the same algorithm

**File:** `apps/web/src/utils/powerAssignment.ts:53-90`

**Problem:** These two functions are identical in structure -- they count occurrences and find the majority value. Only the field accessor and normalizer differ.

**Suggestion:** Extract a generic `getMajority` function parameterized by field extractor and normalizer.

---

### 10. `WorkbenchRow.detail` typed as `Record<string, unknown>`

**File:** `apps/web/src/components/Workbench/WorkbenchTable.tsx:29`

**Problem:** The `detail` field uses `Record<string, unknown>`, and `fetchProductData` has five `as unknown as Record<string, unknown>` casts. Later code accesses fields with unsafe casts like `(row.detail.total_current_ma as number)`.

**Suggestion:** Define a discriminated union:

```typescript
type WorkbenchDetail =
  | { product_type: 'pedal'; data: ReturnType<typeof transformPedal> }
  | { product_type: 'power_supply'; data: ReturnType<typeof transformPowerSupply> }
  | ...;
```

Narrow on `product_type` before accessing type-specific fields. Eliminates all five `as unknown` casts.

---

### 11. Frontend type interfaces defined locally in each component

**Problem:** The `Pedal`, `PowerSupply`, etc. display-layer interfaces are each defined inline within their component files, not exported. The transformer return types are inferred. Adding a field to a transformer won't cause a compile error in the component.

**Suggestion:** Export explicit types from `transformers.ts`:

```typescript
export type Pedal = ReturnType<typeof transformPedal>;
export type PowerSupply = ReturnType<typeof transformPowerSupply>;
```

Import and use these in components instead of redefining them.

---

### 12. `WorkbenchTable.tsx` exports a hook, a type, and a component from one file

**File:** `apps/web/src/components/Workbench/WorkbenchTable.tsx` (407 lines)

**Problem:** Exports `WorkbenchRow` (interface), `useWorkbenchProducts` (hook), `WorkbenchTableView` (component), and `CableTable` (internal component). The hook is consumed by 6+ other Workbench subcomponents.

**Suggestion:** Move `useWorkbenchProducts` and `WorkbenchRow` to `hooks/useWorkbenchProducts.ts`. The convention is hooks in `hooks/`, components in `components/`.

---

### 13. `fetchProductData` switch-case with five identical property extractions

**File:** `apps/web/src/components/Workbench/WorkbenchTable.tsx:58-90`

**Problem:** Five cases that each call a different API method and transformer but then extract the same fields in an identical destructuring block.

**Suggestion:** Create a type-to-fetcher map:

```typescript
const FETCHERS: Record<ProductType, { fetch: ...; transform: ... }> = {
  pedal: { fetch: api.getPedal, transform: transformPedal },
  power_supply: { fetch: api.getPowerSupply, transform: transformPowerSupply },
  // ...
};
```

Collapse five cases into one lookup.

---

## Consider (low priority)

### 14. `Jack` interface field `function_desc` naming

**File:** `apps/web/src/utils/transformers.ts:22`

The API returns `function` (a JS reserved word). The transformer renames it to `function_desc`, which reads as "function description" rather than "the jack's purpose." Consider `jack_function` or `purpose` as alternatives.

### 15. `PowerBudgetService.getPedalPower` -- name says "pedal" but applies to any product type

**File:** `apps/api/src/main/java/com/pedalshootout/api/service/PowerBudgetService.java:44`

The frontend already uses "consumer" in `PowerConsumer`. Consider renaming to `getConsumerPower` / `ConsumerPower` for cross-stack consistency.

### 16. `useApiData` hook has empty dependency array

**File:** `apps/web/src/hooks/useApiData.ts:33`

The `useEffect` dependency array is `[]`. This works because all callers pass stable module-level references, but it would be flagged by `exhaustive-deps`. Adding `fetchFn` and `transformFn` to deps (or documenting the stable-reference requirement) would be more robust.

### 17. `PowerBudgetService.findSuppliesForPedals` duplicates power jack lookup logic

**File:** `apps/api/src/main/java/com/pedalshootout/api/service/PowerBudgetService.java:99-110`

Re-implements the "find power input jack and get its current_ma" logic that already exists in `getPedalPower`. Could reuse the existing method.

### 18. Tab alignment in App component `navElements`

**File:** `apps/web/src/components/App/index.tsx:16-23`

Uses tab characters for visual alignment, inconsistent with the rest of the codebase (spaces). Minor cosmetic issue.
