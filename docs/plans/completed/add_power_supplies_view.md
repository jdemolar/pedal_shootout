# Plan: Add Power Supplies View

## Context

The app has 5 data table views (Manufacturers, Pedals, MIDI Controllers, Pedalboards, Utilities) that all follow the same pattern: a TypeScript interface, column definitions, filters, an expanded row renderer, a stats function, and a thin component that calls `useApiData` and renders `<DataTable>`. The Spring Boot API already has a `GET /api/power-supplies` endpoint returning `PowerSupplyDto` records. This plan adds a 6th view for Power Supplies following the identical pattern.

---

## API Gap

The `PowerSupplyDto` is missing two fields that the other DTOs already have (fixed previously for Pedals, MidiControllers, Pedalboards, Utilities):

- `instructionManual` (String) — not currently exposed
- `dataReliability` (String) — not currently exposed

Both fields exist on the `Product` entity and need to be added to the DTO record and wired in the `from()` factory method.

**File:** `apps/api/src/main/java/com/pedalshootout/api/dto/PowerSupplyDto.java`

---

## Frontend Changes

### 1. Add `PowerSupplyApiResponse` to API types

**File:** `apps/web/src/types/api.ts`

Add a new interface matching the JSON shape of `PowerSupplyDto`:

```typescript
export interface PowerSupplyApiResponse {
  id: number;
  model: string;
  manufacturerName: string;
  manufacturerId: number;
  colorOptions: string | null;
  inProduction: boolean;
  widthMm: number | null;
  depthMm: number | null;
  heightMm: number | null;
  weightGrams: number | null;
  msrpDisplay: string | null;
  msrpCents: number | null;
  productPage: string | null;
  instructionManual: string | null;
  imagePath: string | null;
  dataReliability: string | null;
  supplyType: string | null;
  topology: string | null;
  inputVoltageRange: string | null;
  inputFrequency: string | null;
  totalOutputCount: number;
  totalCurrentMa: number | null;
  isolatedOutputCount: number | null;
  availableVoltages: string | null;
  hasVariableVoltage: boolean;
  voltageRange: string | null;
  mountingType: string | null;
  bracketIncluded: boolean;
  isExpandable: boolean;
  expansionPortType: string | null;
  isBatteryPowered: boolean;
  batteryCapacityWh: number | null;
  jacks: JackApiResponse[];
}
```

### 2. Add API client method

**File:** `apps/web/src/services/api.ts`

Add to the `api` object:

```typescript
getPowerSupplies: () => get<PowerSupplyApiResponse[]>('/api/power-supplies'),
```

### 3. Add transformer function

**File:** `apps/web/src/utils/transformers.ts`

Add `transformPowerSupply` following the same camelCase → snake_case pattern as other transformers. Maps DTO fields directly (no nested detail object since `PowerSupplyDto` is flat, unlike `PedalApiResponse` which has a nested `pedalDetails`).

### 4. Create PowerSupplies component

**File:** `apps/web/src/components/PowerSupplies/index.tsx` (new file)

Following the exact pattern of the other views:

**Interface `PowerSupply`** — snake_case fields for the component's internal use.

**Table columns** (visible in the main table row):
| Column | Width | Align | Sortable | Notes |
|---|---|---|---|---|
| Manufacturer | 180 | left | yes | Bold white text, same style as other views |
| Model | 200 | left | yes | Subdued text (#d0d0d0) |
| Type | 120 | center | yes | `supply_type` (Isolated/Non-Isolated/Hybrid) |
| Outputs | 70 | center | yes | `total_output_count` |
| Current | 90 | right | yes | `total_current_ma` formatted as "Xma" |
| Mounting | 110 | center | yes | `mounting_type` |
| Status | 80 | center | yes | Active/Disc. badge (same as other views) |
| MSRP | 90 | right | yes | `formatMsrp()` |
| Dimensions | 150 | center | no | `formatDimensions()` |
| Reliability | 80 | center | yes | Reliability badge (same as other views) |

**Expanded row details** (shown when a row is clicked):
- Topology (if not null)
- Input Voltage Range (if not null)
- Input Frequency (if not null)
- Isolated Outputs (always shown)
- Available Voltages (if not null)
- Variable Voltage (bool yes/no)
- Voltage Range (if not null, only relevant when variable voltage is true)
- Bracket Included (bool yes/no)
- Expandable (bool yes/no)
- Expansion Port Type (if not null)
- Battery Powered (bool yes/no)
- Battery Capacity (if not null, formatted as "X Wh")
- Weight (if not null, formatted as kg)
- Product Page (link, if not null)
- Instruction Manual (link, if not null)

**Filters:**
- Supply Type: dynamic from data (All, Isolated, Non-Isolated, Hybrid) — `useMemo`
- Mounting: dynamic from data (All, Under Board, On Board, External, Rack) — `useMemo`
- Status: static (All, In Production, Discontinued)
- Reliability: static (All, High, Medium, Low)

**Stats line:** `"X power supplies · Y in production · Z total outputs"`

**Search fields:** `['manufacturer', 'model']`

### 5. Add route to App

**File:** `apps/web/src/components/App/index.tsx`

Add import and nav element entry, placed after Pedalboards and before Utilities to group related product types logically:

```typescript
import PowerSupplies from '../PowerSupplies';

// In navElements array:
{label: 'Power Supplies', link: 'power-supplies', component: <PowerSupplies />},
```

---

## Implementation Order

1. Add `instructionManual` and `dataReliability` to `PowerSupplyDto.java`
2. Add `PowerSupplyApiResponse` to `apps/web/src/types/api.ts`
3. Add `getPowerSupplies` to `apps/web/src/services/api.ts`
4. Add `transformPowerSupply` to `apps/web/src/utils/transformers.ts`
5. Create `apps/web/src/components/PowerSupplies/index.tsx`
6. Add route in `apps/web/src/components/App/index.tsx`
7. Build verification (`mvnw compile` + `npm run web:build`)

---

## Verification

1. `cd apps/api && ./mvnw compile -q` — API compiles
2. `npm run web:build` — frontend compiles and bundles
3. Manual: start API and dev server, navigate to `/power-supplies`, verify:
   - Table renders with data from the API
   - Column sorting works
   - Filters work (supply type, mounting, status, reliability)
   - Search works
   - Expanded rows show detail fields
   - Loading and error states display correctly
