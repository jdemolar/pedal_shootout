# Combine redundant power extraction functions

## Context

Refactoring opportunity #8 from `docs/plans/refactoring-opportunities.md`. Two functions in `apps/web/src/utils/transformers.ts` scan the same array with the same predicate:

```ts
function extractPowerVoltage(jacks: JackApiResponse[]): string | null {
  const powerJack = jacks.find(j => j.category === 'power' && j.direction === 'input');
  return powerJack?.voltage ?? null;
}

function extractPowerCurrentMa(jacks: JackApiResponse[]): number | null {
  const powerJack = jacks.find(j => j.category === 'power' && j.direction === 'input');
  return powerJack?.currentMa ?? null;
}
```

They are always called back-to-back in `transformPedal` (lines 91–92) and `transformMidiController` (lines 140–141). Each call duplicates the `.find()` traversal.

## Approach

Replace the two functions with a single `extractPowerInfo` that finds the power input jack once and returns both values.

## Files to Modify

| File | Change |
|---|---|
| `apps/web/src/utils/transformers.ts` | Replace `extractPowerVoltage` + `extractPowerCurrentMa` with `extractPowerInfo`; update both call sites |

## Implementation

### 1. Replace the two functions with one

```ts
function extractPowerInfo(jacks: JackApiResponse[]): { voltage: string | null; current_ma: number | null } {
  const powerJack = jacks.find(j => j.category === 'power' && j.direction === 'input');
  return {
    voltage: powerJack?.voltage ?? null,
    current_ma: powerJack?.currentMa ?? null,
  };
}
```

### 2. Update `transformPedal`

```ts
// Before:
power_voltage: extractPowerVoltage(dto.jacks),
power_current_ma: extractPowerCurrentMa(dto.jacks),

// After:
...extractPowerInfo(dto.jacks),
```

The spread works because `extractPowerInfo` returns `{ voltage, current_ma }` — but the existing field names are `power_voltage` and `power_current_ma`. To keep field names unchanged, destructure explicitly:

```ts
const power = extractPowerInfo(dto.jacks);
// ...
power_voltage: power.voltage,
power_current_ma: power.current_ma,
```

### 3. Update `transformMidiController`

Same pattern as `transformPedal`.

## Verification

1. `npm run web:build` — no compilation errors
2. `npm run web:test` — all tests pass
3. Check off item #8 in `docs/plans/refactoring-opportunities.md`
4. Move this plan to `docs/plans/completed/`
