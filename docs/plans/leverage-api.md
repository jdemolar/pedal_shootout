# Plan: Connect Frontend Views to Spring Boot API

## Context

The 5 data table views (Pedals, Manufacturers, MidiControllers, Pedalboards, Utilities) currently render from hardcoded `DATA` arrays embedded in each component's TSX file. The Spring Boot API at `apps/api/` already serves all the necessary data via REST endpoints on port 8081. This plan connects the frontend to those endpoints, removes the hardcoded data, and handles the field-name mapping between the API's camelCase JSON and the frontend's snake_case TypeScript interfaces.

### Current State

| Layer | Status |
|-------|--------|
| PostgreSQL database | Running, populated |
| Spring Boot API (25 endpoints) | Running on `:8081`, CORS configured for `:8080` |
| React frontend | Renders hardcoded arrays; no calls to the Spring Boot API |
| FeatureTable component | Calls MongoDB Realm (legacy, separate concern — not part of this plan) |

### API Endpoints to Consume

| View | Endpoint | Response Shape |
|------|----------|----------------|
| Pedals | `GET /api/pedals` | `PedalDto[]` (product fields + nested `pedalDetails` + `jacks[]`) |
| Manufacturers | `GET /api/manufacturers` | `ManufacturerDto[]` (flat, includes `productCount`) |
| MIDI Controllers | `GET /api/midi-controllers` | `MidiControllerDto[]` (product fields + controller fields + `jacks[]`) |
| Pedalboards | `GET /api/pedalboards` | `PedalboardDto[]` (product fields + board fields + `jacks[]`) |
| Utilities | `GET /api/utilities` | `UtilityDto[]` (product fields + utility fields + `jacks[]`) |

All list endpoints return a plain JSON array (no pagination wrapper).

---

## API Gaps

Before the frontend can fully replace hardcoded data, these gaps in the existing DTOs need to be addressed with small API changes.

### 1. `data_reliability` missing from all DTOs

The `products.data_reliability` column exists in the database and is mapped on the `Product` JPA entity, but all DTOs intentionally exclude it (labeled "internal" in `ProductSummaryDto`). The frontend displays it as a sortable/filterable column in every view.

**Fix:** Add `String dataReliability` to `PedalDto`, `MidiControllerDto`, `PedalboardDto`, `UtilityDto`, and `ManufacturerDto`. For manufacturers (which don't have a `products` row), this field doesn't apply — remove the `data_reliability` column from the Manufacturers view, or add a `dataReliability` field to the `manufacturers` table if it's wanted.

**Files to change:**
- `apps/api/src/main/java/com/pedalshootout/api/dto/PedalDto.java` — add field + populate in `from()`
- `apps/api/src/main/java/com/pedalshootout/api/dto/MidiControllerDto.java` — same
- `apps/api/src/main/java/com/pedalshootout/api/dto/PedalboardDto.java` — same
- `apps/api/src/main/java/com/pedalshootout/api/dto/UtilityDto.java` — same
- `apps/api/src/main/java/com/pedalshootout/api/dto/ManufacturerDto.java` — decide: add column to `manufacturers` table, or drop from view

### 2. `instruction_manual` missing from 3 DTOs

`PedalDto` includes `instructionManual`, but `MidiControllerDto`, `PedalboardDto`, and `UtilityDto` do not. The field exists on the `Product` entity for all product types.

**Fix:** Add `String instructionManual` to the 3 missing DTOs and populate from `p.getInstructionManual()`.

**Files to change:**
- `apps/api/src/main/java/com/pedalshootout/api/dto/MidiControllerDto.java`
- `apps/api/src/main/java/com/pedalshootout/api/dto/PedalboardDto.java`
- `apps/api/src/main/java/com/pedalshootout/api/dto/UtilityDto.java`

### 3. Power voltage/current not surfaced as top-level fields

The frontend displays `power_voltage` and `power_current_ma` as columns. In the API, this data lives inside the `jacks[]` array (each jack has `voltage` and `currentMa` fields). The frontend would need to scan the jacks array for the power input jack to extract these values.

**Two options:**

**Option A — Derive on the frontend:** The transformer function filters `jacks` for `category === 'power'` and `direction === 'input'`, then reads `voltage` and `currentMa`. No API change needed.

**Option B — Add convenience fields to DTOs:** Add `powerVoltage` and `powerCurrentMa` to product-type DTOs, populated from the power input jack in the `from()` factory method. Cleaner for the frontend but adds denormalization.

**Recommendation:** Option A. The jacks array is already in the response. A small utility function on the frontend handles the extraction without API changes.

### 4. Manufacturer `notes` and `updated_at` missing from `ManufacturerDto`

The hardcoded frontend `Manufacturer` interface includes `notes` and `updated_at`. The `ManufacturerDto` excludes them.

**Fix:** Add `String notes` and `OffsetDateTime updatedAt` to `ManufacturerDto` if the frontend needs them. Currently `notes` is only shown in expanded rows and `updated_at` is not displayed — consider whether these are needed.

---

## Frontend Changes

### Phase 1: Infrastructure

#### 1a. Add environment variable for API base URL

**File:** `apps/web/.env`

```
REACT_APP_API_BASE_URL=http://localhost:8081
```

Add the same to `apps/web/.env.example` for documentation.

#### 1b. Create API client module

**New file:** `apps/web/src/services/api.ts`

A thin wrapper around `fetch` that:
- Reads `REACT_APP_API_BASE_URL` from environment
- Provides typed functions for each entity endpoint
- Handles JSON parsing and HTTP error status codes

```typescript
const API_BASE = process.env.REACT_APP_API_BASE_URL || 'http://localhost:8081';

async function get<T>(path: string): Promise<T> {
  const res = await fetch(`${API_BASE}${path}`);
  if (!res.ok) {
    throw new Error(`GET ${path} failed: ${res.status}`);
  }
  return res.json();
}

export const api = {
  getPedals: () => get<PedalApiResponse[]>('/api/pedals'),
  getManufacturers: () => get<ManufacturerApiResponse[]>('/api/manufacturers'),
  getMidiControllers: () => get<MidiControllerApiResponse[]>('/api/midi-controllers'),
  getPedalboards: () => get<PedalboardApiResponse[]>('/api/pedalboards'),
  getUtilities: () => get<UtilityApiResponse[]>('/api/utilities'),
};
```

No new dependencies needed — the browser's native `fetch` API is sufficient.

#### 1c. Create API response type definitions

**New file:** `apps/web/src/types/api.ts`

TypeScript interfaces matching the exact JSON shapes returned by the Spring Boot API (camelCase field names). These are the "raw" response types, distinct from the frontend's display interfaces.

```typescript
export interface PedalApiResponse {
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
  description: string | null;
  tags: string | null;
  dataReliability: string | null;  // After API gap #1 is fixed
  pedalDetails: PedalDetailApiResponse;
  jacks: JackApiResponse[];
}

// ... similar for ManufacturerApiResponse, MidiControllerApiResponse, etc.
```

#### 1d. Create transformer functions

**New file:** `apps/web/src/utils/transformers.ts`

One function per entity that maps from the API response type (camelCase) to the frontend display type (snake_case). Each transformer:
- Renames fields (`manufacturerName` → `manufacturer`)
- Flattens nested objects (`pedalDetails.effectType` → `effect_type`)
- Extracts power info from the `jacks` array

```typescript
import { PedalApiResponse } from '../types/api';

function extractPowerVoltage(jacks: JackApiResponse[]): string | null {
  const powerJack = jacks.find(j => j.category === 'power' && j.direction === 'input');
  return powerJack?.voltage ?? null;
}

function extractPowerCurrentMa(jacks: JackApiResponse[]): number | null {
  const powerJack = jacks.find(j => j.category === 'power' && j.direction === 'input');
  return powerJack?.currentMa ?? null;
}

export function transformPedal(dto: PedalApiResponse): Pedal {
  return {
    id: dto.id,
    manufacturer: dto.manufacturerName,
    model: dto.model,
    effect_type: dto.pedalDetails?.effectType ?? null,
    in_production: dto.inProduction,
    width_mm: dto.widthMm,
    depth_mm: dto.depthMm,
    height_mm: dto.heightMm,
    weight_grams: dto.weightGrams,
    msrp_cents: dto.msrpCents,
    product_page: dto.productPage,
    instruction_manual: dto.instructionManual,
    image_path: dto.imagePath,
    color_options: dto.colorOptions,
    data_reliability: dto.dataReliability as Pedal['data_reliability'],
    bypass_type: dto.pedalDetails?.bypassType ?? null,
    signal_type: dto.pedalDetails?.signalType ?? null,
    circuit_type: dto.pedalDetails?.circuitType ?? null,
    mono_stereo: dto.pedalDetails?.monoStereo ?? null,
    preset_count: dto.pedalDetails?.presetCount ?? 0,
    midi_capable: dto.pedalDetails?.midiCapable ?? false,
    has_tap_tempo: dto.pedalDetails?.hasTapTempo ?? false,
    battery_capable: dto.pedalDetails?.batteryCapable ?? false,
    has_software_editor: dto.pedalDetails?.hasSoftwareEditor ?? false,
    power_voltage: extractPowerVoltage(dto.jacks),
    power_current_ma: extractPowerCurrentMa(dto.jacks),
  };
}

// ... transformManufacturer, transformMidiController, transformPedalboard, transformUtility
```

#### 1e. Create a data-fetching hook

**New file:** `apps/web/src/hooks/useApiData.ts`

A generic React hook that manages the fetch lifecycle (loading, data, error):

```typescript
import { useState, useEffect } from 'react';

interface UseApiDataResult<T> {
  data: T[];
  loading: boolean;
  error: string | null;
}

export function useApiData<TRaw, TDisplay>(
  fetchFn: () => Promise<TRaw[]>,
  transformFn: (raw: TRaw) => TDisplay,
): UseApiDataResult<TDisplay> {
  const [data, setData] = useState<TDisplay[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;
    fetchFn()
      .then(raw => {
        if (!cancelled) {
          setData(raw.map(transformFn));
          setLoading(false);
        }
      })
      .catch(err => {
        if (!cancelled) {
          setError(err.message);
          setLoading(false);
        }
      });
    return () => { cancelled = true; };
  }, []);

  return { data, loading, error };
}
```

### Phase 2: Add Loading and Error States to DataTable

The `DataTable` component currently expects `data` to always be present. It needs to handle two new states.

**File:** `apps/web/src/components/DataTable/index.tsx`

Add two optional props:

```typescript
export interface DataTableProps<T extends { id: number }> {
  // ... existing props ...
  loading?: boolean;
  error?: string | null;
}
```

Render a loading indicator when `loading` is true. Render an error message when `error` is set. Render the table normally otherwise. Keep it simple — a text-based spinner or "Loading..." message inside the existing `.data-table` container so the layout doesn't shift.

### Phase 3: Update Entity Components

Each entity component changes from:

```typescript
const DATA: Pedal[] = [ /* 100+ hardcoded items */ ];

const Pedals = () => (
  <DataTable<Pedal> data={DATA} ... />
);
```

To:

```typescript
import { useApiData } from '../../hooks/useApiData';
import { api } from '../../services/api';
import { transformPedal } from '../../utils/transformers';

const Pedals = () => {
  const { data, loading, error } = useApiData(api.getPedals, transformPedal);

  return (
    <DataTable<Pedal> data={data} loading={loading} error={error} ... />
  );
};
```

The interface definition, column definitions, filter configs, expanded row renderer, and stats function all remain unchanged — only the data source changes.

**Files to modify:**
- `apps/web/src/components/Pedals/index.tsx` — remove `DATA` array (~250 lines), add hook call
- `apps/web/src/components/Manufacturers/index.tsx` — remove `DATA` array (~290 lines), add hook call
- `apps/web/src/components/MidiControllers/index.tsx` — remove `DATA` array (~250 lines), add hook call
- `apps/web/src/components/Pedalboards/index.tsx` — remove `DATA` array (~300 lines), add hook call
- `apps/web/src/components/Utilities/index.tsx` — remove `DATA` array (~250 lines), add hook call

### Phase 4: Dynamic Filter Options

Currently, filter dropdown options (like effect types and materials) are derived from the hardcoded `DATA` arrays at module load time:

```typescript
const EFFECT_TYPES = ['All', ...new Set(DATA.map(d => d.effect_type).filter(Boolean))].sort();
```

With API-fetched data, these must be computed after the data arrives. Move these computations into `useMemo` hooks inside the component, derived from the `data` returned by `useApiData`:

```typescript
const effectTypes = useMemo(
  () => ['All', ...new Set(data.map(d => d.effect_type).filter((t): t is string => t !== null))].sort(),
  [data]
);
```

The `filters` array itself then needs to be memoized too, since its `options` reference changes when data changes.

**Affected components:** Pedals (effect types), Pedalboards (materials), Utilities (utility types). Manufacturers and MidiControllers use static filter options ('All'/'Active'/'Defunct', etc.) so they don't need this change.

### Phase 5: Webpack Dev Server Proxy (Optional)

To avoid CORS issues in development, configure the webpack dev server to proxy API requests to the Spring Boot backend. This eliminates the need for CORS config on the API and avoids hardcoding `localhost:8081` in the frontend.

**File:** `apps/web/webpack.development.js`

```javascript
devServer: {
  // ... existing config ...
  proxy: {
    '/api': 'http://localhost:8081',
  },
},
```

With this, the frontend calls `/api/pedals` (relative URL) and webpack proxies it to `http://localhost:8081/api/pedals`. The `REACT_APP_API_BASE_URL` env var would then be empty or `/` in development. In production, it would point to the deployed API host.

---

## Implementation Order

1. Fix API gaps (add `dataReliability`, `instructionManual` to DTOs)
2. Create `apps/web/.env` entry for `REACT_APP_API_BASE_URL`
3. Create `apps/web/src/types/api.ts` (API response types)
4. Create `apps/web/src/services/api.ts` (fetch client)
5. Create `apps/web/src/utils/transformers.ts` (DTO → display type mappers)
6. Create `apps/web/src/hooks/useApiData.ts` (generic fetch hook)
7. Add `loading` / `error` props to `DataTable`
8. Update entity components one at a time (Manufacturers → Pedals → MidiControllers → Pedalboards → Utilities)
9. Configure webpack proxy (optional)
10. Build and verify

---

## New Files

| File | Purpose |
|------|---------|
| `apps/web/src/types/api.ts` | TypeScript interfaces matching API JSON responses |
| `apps/web/src/services/api.ts` | Typed fetch functions for each endpoint |
| `apps/web/src/utils/transformers.ts` | Map API responses to frontend display types |
| `apps/web/src/hooks/useApiData.ts` | Generic data-fetching hook with loading/error states |

## Modified Files

| File | Change |
|------|--------|
| `apps/web/src/components/DataTable/index.tsx` | Add `loading` and `error` props |
| `apps/web/src/components/DataTable/index.scss` | Add loading/error state styles |
| `apps/web/src/components/Pedals/index.tsx` | Remove ~250 lines of hardcoded data, add hook |
| `apps/web/src/components/Manufacturers/index.tsx` | Remove ~290 lines of hardcoded data, add hook |
| `apps/web/src/components/MidiControllers/index.tsx` | Remove ~250 lines of hardcoded data, add hook |
| `apps/web/src/components/Pedalboards/index.tsx` | Remove ~300 lines of hardcoded data, add hook |
| `apps/web/src/components/Utilities/index.tsx` | Remove ~250 lines of hardcoded data, add hook |
| `apps/web/.env` | Add `REACT_APP_API_BASE_URL` |
| `apps/web/.env.example` | Add `REACT_APP_API_BASE_URL` |
| `apps/web/webpack.development.js` | Add proxy config (optional) |
| 4 API DTO files | Add missing `dataReliability` and `instructionManual` fields |

## Verification

1. Start the Spring Boot API: `cd apps/api && ./mvnw spring-boot:run`
2. Start the React dev server: `npm run web`
3. Navigate to each view and verify:
   - Loading state renders briefly, then data appears
   - Data matches what the API returns (spot-check a few records)
   - Search, filter, sort, and row expansion all work
   - Error state renders if the API is stopped
4. `npm run web:build` — production build succeeds
