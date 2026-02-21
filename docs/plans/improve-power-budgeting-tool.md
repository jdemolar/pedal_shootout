# Plan: Power Budget Calculator Improvements

## Context

The power budget calculator (in the Workbench sidebar) computes total pedal power draw vs supply capacity and links to the Power Supplies catalog with URL param filters. There are three bugs to fix now and a larger feature (pedal-to-port mapping) to build later as part of a new workbench connection view system.

### Immediate fixes (this round)

1. **Voltage filter is broken** — exact string matching fails because jack voltage values use inconsistent formats (`"9V"` vs `"9V/12V/18V"` vs `"9V DC"`)
2. **URL param filters aren't interactive** — a plain text banner with a single "Clear all" button; users can't see or remove individual filters
3. **Polarity warnings fire incorrectly** — case mismatch in the database (`"center-negative"` vs `"Center Negative"`) causes false positive warnings

### Future feature (separate task)

4. **Pedal-to-port mapping** — drag-and-drop UI for mapping pedals to power supply outputs (see [power-mapping-view.md](./power-mapping-view.md))

---

## Step 1: Create shared utility file `utils/powerUtils.ts`

**New file:** `apps/web/src/utils/powerUtils.ts`

Voltage, polarity, and connector normalization functions used by both `PowerBudgetInsight.tsx` and `PowerSupplies/index.tsx`.

**Functions:**
- `normalizePolarity(p: string): string` — lowercases and replaces spaces with hyphens (`"Center Negative"` → `"center-negative"`)
- `normalizeConnector(c: string): string` — trims whitespace
- `normalizeVoltage(raw: string): string` — strips trailing `DC`/`AC`, spaces, and `V` characters (`"9V DC"` → `"9"`, `"9V/12V/18V"` → `"9/12/18"`)
- `voltageTokensFromJack(voltage: string): string[]` — splits a jack's voltage into individual numeric tokens (`"9V/12V/18V"` → `["9","12","18"]`)
- `voltageTokensCanSatisfy(supplyTokens: string[], needed: string): boolean` — checks if any supply token matches a needed voltage (including range support: `"9-18"` satisfies `"12"`)
- `voltagesCompatible(supplyVoltage: string, consumerVoltage: string): boolean` — top-level check combining the above
- `effectiveCurrentMa(storedMa: number, jackVoltage: string, neededVoltage: string): number` — wattage-based current estimate for selectable-voltage outputs (see [power-mapping-view.md](./power-mapping-view.md))

---

## Step 2: Fix polarity warnings (Issue 3)

**File:** `apps/web/src/components/Workbench/PowerBudgetInsight.tsx`

- Import `normalizePolarity`, `normalizeConnector` from `utils/powerUtils.ts`
- Update `getMajorityPolarity()`: normalize each jack's polarity before counting
- Update `getMajorityConnector()`: normalize each jack's connector_type before counting
- Update the polarity mismatch check (line ~273): normalize consumer polarity before comparing to majority
- Update the connector mismatch check (line ~286): same normalization
- Also update `computeDaisyChainGroups` voltage matching (line 118): replace exact `j.voltage === voltage` with `voltagesCompatible()` from the new utility

---

## Step 3: Fix voltage URL filter (Issue 1)

**File:** `apps/web/src/components/PowerSupplies/index.tsx`

- Import `voltagesCompatible` from `utils/powerUtils.ts`
- Rewrite `supplyHasVoltage()` to use `voltagesCompatible()` on each supply output jack's voltage instead of exact string matching
- Remove the broken `available_voltages` string splitting path entirely — the jack-level check is the reliable data source

---

## Step 4: Interactive filter pills (Issue 2)

**File:** `apps/web/src/components/PowerSupplies/index.tsx`

Replace the plain-text context banner with individually-removable filter pills:
- Build a `filterPills` array from the active URL params (label + paramKey for each)
- Add `handleRemoveUrlFilter(paramKey)` that deletes a single param from the URL
- Render each pill with its label and an `×` remove button
- Keep the "Clear All" button alongside

**File:** `apps/web/src/components/DataTable/index.scss`

Add styles for `.data-table__filter-pills`, `.data-table__filter-pill`, `.data-table__filter-pill-remove`, and update `.data-table__context-banner` to use flex layout with gap.

---

## Files to modify (immediate)

| File | Changes |
|------|---------|
| `apps/web/src/utils/powerUtils.ts` | **New** — shared normalization utilities |
| `apps/web/src/components/Workbench/PowerBudgetInsight.tsx` | Issue 3: polarity/connector normalization, voltage fix in daisy-chain logic |
| `apps/web/src/components/PowerSupplies/index.tsx` | Issues 1 + 2: voltage filter fix, interactive filter pills |
| `apps/web/src/components/DataTable/index.scss` | Issue 2: filter pill styles |

---

## Verification (immediate)

1. **Build check:** `cd apps/web && npm run build` — must compile without errors
2. **Polarity fix:** Add a power supply and pedals to the workbench where both have `center-negative` polarity (but with different casing in the DB). Verify no false polarity warning appears.
3. **Voltage filter:** From the workbench with 9V pedals, click "See compatible power supplies" link. Verify supplies with `"9V"`, `"9V DC"`, and `"9V/12V/18V"` output jacks all appear (not filtered out).
4. **Filter pills:** On the power supplies page with URL params, verify individual pills appear and can be removed independently.
