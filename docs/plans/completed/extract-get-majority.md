# Extract generic getMajority function

## Context

Refactoring opportunity #9 from `docs/plans/refactoring-opportunities.md`. Two functions in `apps/web/src/utils/powerAssignment.ts` are structurally identical:

```ts
export function getMajorityPolarity(jacks: Jack[]): string | null {
  const counts: Record<string, number> = {};
  for (const j of jacks) {
    if (j.polarity) {
      const norm = normalizePolarity(j.polarity);
      counts[norm] = (counts[norm] || 0) + 1;
    }
  }
  let best: string | null = null;
  let bestCount = 0;
  for (const [pol, count] of Object.entries(counts)) {
    if (count > bestCount) { best = pol; bestCount = count; }
  }
  return best;
}

export function getMajorityConnector(jacks: Jack[]): string | null {
  // Identical structure — only the field accessor (connector_type) and
  // normalizer (normalizeConnector) differ.
}
```

Both count occurrences of a normalized field value and return the most common one. Only the field accessor and normalizer differ.

## Approach

Extract a generic `getMajority` helper parameterized by extractor and normalizer. Keep the existing `getMajorityPolarity` and `getMajorityConnector` as thin wrappers so the call sites in `PowerBudgetInsight.tsx` don't need to change.

## Files to Modify

| File | Change |
|---|---|
| `apps/web/src/utils/powerAssignment.ts` | Add `getMajority`, simplify `getMajorityPolarity` and `getMajorityConnector` to delegate to it |

No other files change — the existing function signatures and exports are preserved.

## Implementation

### 1. Add generic `getMajority` (private)

```ts
function getMajority<T>(
  items: T[],
  extract: (item: T) => string | null,
  normalize: (value: string) => string,
): string | null {
  const counts: Record<string, number> = {};
  for (const item of items) {
    const raw = extract(item);
    if (raw) {
      const norm = normalize(raw);
      counts[norm] = (counts[norm] || 0) + 1;
    }
  }
  let best: string | null = null;
  let bestCount = 0;
  for (const [value, count] of Object.entries(counts)) {
    if (count > bestCount) {
      best = value;
      bestCount = count;
    }
  }
  return best;
}
```

### 2. Simplify the two exported functions

```ts
export function getMajorityPolarity(jacks: Jack[]): string | null {
  return getMajority(jacks, j => j.polarity, normalizePolarity);
}

export function getMajorityConnector(jacks: Jack[]): string | null {
  return getMajority(jacks, j => j.connector_type, normalizeConnector);
}
```

## Verification

1. `npm run web:build` — no compilation errors
2. `npm run web:test` — all tests pass
3. Check off item #9 in `docs/plans/refactoring-opportunities.md`
4. Move this plan to `docs/plans/completed/`
