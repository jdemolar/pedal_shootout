# Power Budget Tool Enhancement Plan

## Context

The workbench Power Budget insight currently checks a single dimension: whether the total current draw of the user's pedals exceeds the total current capacity of their power supply. In practice, a user assembling a pedalboard needs to know much more — whether the supply has enough *outputs*, whether any single output can handle their highest-draw pedal, and whether the supply offers the right *voltages*. Beyond electrical compatibility, users should be warned about polarity mismatches, connector type differences, isolation concerns, and mounting considerations.

This plan adds three new URL-param-based filters to the Power Supplies catalog view (output count, per-output current, voltage) and enriches the Power Budget insight with informational warnings for isolation, polarity, connector type, and mounting.

---

## Part 1: New URL Param Filters on Power Supplies View

### New Parameters

| Param | Type | Example | Meaning |
|-------|------|---------|---------|
| `minCurrent` | integer | `2780` | Minimum total current capacity (mA) — **already exists** |
| `minOutputs` | integer | `8` | Minimum number of power outputs (`total_output_count`) |
| `minOutputCurrent` | integer | `300` | Minimum per-output current — at least one output jack must provide this many mA |
| `voltages` | comma-separated strings | `9V,18V` | Required voltages — supply must offer all listed voltages (checked against `available_voltages` field or individual output jack `voltage` values) |

### How Filters Work

All filtering is **client-side** (no API changes). The Power Supplies view already fetches all supplies with full jack data. On mount, the component reads URL search params and applies them as pre-filters on the dataset.

- **`minOutputs`**: Simple numeric comparison against `total_output_count`.
- **`minOutputCurrent`**: Scan the supply's `jacks` array for power output jacks (`category === 'power' && direction === 'output'`). The supply passes if at least one output jack has `current_ma >= minOutputCurrent`.
- **`voltages`**: Parse comma-separated values. For each required voltage, check whether it appears in the supply's `available_voltages` string OR in any power output jack's `voltage` field. The supply passes only if *all* required voltages are matched.

### Context Banner

The existing banner ("Showing power supplies for your 2,780mA requirement") expands to include all active URL-param filters in a single line, e.g.:

> Showing power supplies with 2,780mA+ capacity, 8+ outputs, 300mA+ per output, 9V + 18V

The "Clear" button removes all URL-param filters at once.

### Files to Modify

- `apps/web/src/components/PowerSupplies/index.tsx` — read new params, apply filter predicates, update banner text
- `apps/web/src/components/Workbench/PowerBudgetInsight.tsx` — generate the new params in the link URL (see Part 2)

---

## Part 2: Enriched Power Budget Insight

### Data Already Available

The `WorkbenchRow` type already carries full `jacks: Jack[]` and `detail: Record<string, unknown>` for every row. Each jack has `voltage`, `current_ma`, `polarity`, `connector_type`, and `is_isolated`. The insight currently only reads `current_ma` from consumer power input jacks and `total_current_ma` from supply details. All the data needed for warnings is already present — no API changes required.

### Expanded PowerConsumer Interface

```typescript
interface PowerConsumer {
  manufacturer: string;
  model: string;
  current_ma: number | null;
  voltage: string | null;       // NEW
  polarity: string | null;      // NEW
  connector_type: string | null; // NEW
}
```

### Expanded PowerSupply Interface

```typescript
interface PowerSupply {
  manufacturer: string;
  model: string;
  total_current_ma: number | null;
  total_output_count: number | null;      // NEW
  available_voltages: string | null;      // NEW
  mounting_type: string | null;           // NEW
  output_jacks: Jack[];                   // NEW — power output jacks only
}
```

### Smart Link Generation

The "See all compatible power supplies" link currently sends only `?minCurrent=<totalDraw>`. It will now include:

- `minCurrent=<totalDraw>` (unchanged)
- `minOutputs=<number of power consumers>` — one output per pedal
- `minOutputCurrent=<highest single pedal draw>` — so no output is undersized
- `voltages=<unique voltages needed>` — e.g., `9V,18V` if pedals require both

### New Warnings

These appear as supplementary notes below the existing budget status, only when relevant. They do **not** filter the catalog — they're informational.

**1. Isolation Warning**
- **When:** A supply is present and has non-isolated outputs (`supply_type !== 'Isolated'` or `isolated_output_count < total_output_count`)
- **Message:** "Your [supply model] has [X] non-isolated outputs. Non-isolated outputs can introduce noise — particularly with digital pedals, though analog pedals may also be affected."
- **Always shown** when the supply has non-isolated outputs, regardless of pedal types in the workbench.

**2. Polarity Mismatch Warning** *(only when a supply is present)*
- **When:** Any consumer's power input `polarity` differs from the majority polarity of the supply's output jacks.
- **Message:** "[Pedal Model] requires [polarity] — you may need a polarity-reversal adapter cable."

**3. Connector Type Mismatch Warning** *(only when a supply is present)*
- **When:** Any consumer's power input `connector_type` differs from the supply's output jack `connector_type`.
- **Message:** "[Pedal Model] uses a [connector_type] connector — you may need an adapter cable."

**4. Mounting Info** *(only when a supply is present)*
- **When:** A supply has a `mounting_type` value.
- **Message:** "Mounting: [mounting_type]" — simple informational line, no warning styling.

### Files to Modify

- `apps/web/src/components/Workbench/PowerBudgetInsight.tsx` — expand interfaces, extract new jack fields, generate warnings, build enriched link URL

---

## Verification

1. **Build check**: `cd apps/web && npm run build` — no compile errors
2. **Tests**: `cd apps/web && npm test` — existing tests pass (update PowerBudgetInsight tests if any exist)
3. **Manual test — URL params**: Navigate to `/power-supplies?minCurrent=2000&minOutputs=6&minOutputCurrent=300&voltages=9V,18V` and verify filtering works and banner displays correctly
4. **Manual test — insight warnings**: Add a mix of pedals (some 9V, one 18V, one center-positive) and a power supply to the workbench. Verify warnings appear for voltage, polarity, connector mismatches, and isolation
5. **Manual test — link generation**: With pedals in the workbench but no supply, click "See all compatible power supplies" and verify the URL contains all relevant params
