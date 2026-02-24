# Connections & Cabling Design Document

**Status:** Design
**Created:** 2026-02-23

## Context

Building a pedalboard requires planning dozens of connections — audio signal paths, power cables, MIDI chains, expression/aux cables — and then buying or building the right cables for each. This is one of the most complex and error-prone parts of board building, especially when dealing with:

- Stereo signal paths that split/merge
- Connector mismatches requiring adapter cables (e.g., 5-pin DIN to 3.5mm TRS MIDI)
- Polarity differences on expression pedals
- TRS-A vs TRS-B MIDI standards
- FX loop routing through the amp

This design document covers the complete connections architecture: data model, per-category views (Audio, MIDI, Control), a shopping list that synthesizes everything into a cable/adapter bill of materials, and backend tables for future cloud save.

**Scope:** Design only — no implementation in this plan. Implementation will follow in phased plans.

---

## Design Decisions (Confirmed)

| Decision | Choice | Rationale |
|---|---|---|
| Connection storage | Separate arrays per category | Matches existing `powerConnections[]` pattern; clean type safety per category; no migration needed |
| Cable types | Derived from connected jacks | A connection between two jacks with known connector types implies the cable. No cable types table needed. |
| Shopping list location | Collapsible section in List tab | List tab is already the "what do I need?" view. Cable summary belongs there. |
| Cable length estimation | Derive from layout + 20% slack + user override | Smart defaults with escape hatch. Disclaimer about estimation accuracy. |
| Adapter handling | Warning system (like power view) | Options: "adapter cable" (noted on shopping list), "add a utility" (links to catalog), "dismiss" |
| Audio topology | Full (parallel, Y-split, FX loops, stereo) | Covers complex rigs from day one |
| MIDI metadata | Channels, PC/CC, clock routing | Design the model to capture signal metadata, not just physical wiring |
| Control metadata | Expression ranges, polarity, aux assignments, CV | Same approach — capture what the user needs to configure |
| Backend design | Included (for future cloud save) | Ensures frontend model aligns with eventual DB schema |

---

## 1. Frontend Data Model

All new types go in `apps/web/src/types/connections.ts`.

### 1.1 AudioConnection

```typescript
export interface AudioConnection {
  id: string;                          // crypto.randomUUID()
  sourceJackId: number;                // jacks.id (or negative for virtual nodes)
  targetJackId: number;
  sourceInstanceId: string;            // WorkbenchItem.instanceId
  targetInstanceId: string;
  acknowledgedWarnings?: string[];

  // Audio-specific
  orderIndex: number;                  // Position in signal chain (0 = first after guitar)
  parallelPathId: string | null;       // null = main chain; non-null = branch ID
  fxLoopGroupId: string | null;        // Links to jacks.group_id for FX loop association
  signalMode: 'mono' | 'stereo';      // Derived from jacks but can be overridden
  stereoPairConnectionId: string | null; // Links L and R connections as a pair
}
```

**Stereo handling:** A stereo connection is two `AudioConnection` records (L and R) cross-referenced by `stereoPairConnectionId`. This matches the physical reality (two cables) and aligns with the `jacks` table where stereo pedals have separate L/R jack records linked by `group_id`. The UI presents them as a paired operation ("connect stereo pair") while keeping the data model atomic.

### 1.2 MidiConnection

```typescript
export interface MidiConnection {
  id: string;
  sourceJackId: number;
  targetJackId: number;
  sourceInstanceId: string;
  targetInstanceId: string;
  acknowledgedWarnings?: string[];

  // MIDI-specific
  chainIndex: number;                  // Position in daisy chain (0 = first from controller)
  midiChannel: number | null;          // 1-16, null = omni
  programChangeNumber: number | null;  // 0-127
  ccAssignments: Array<{ cc: number; parameter: string }> | null;
  carriesClock: boolean;
  trsMidiStandard: 'TRS-A' | 'TRS-B' | null;  // Only relevant for 3.5mm TRS connectors
}
```

### 1.3 ControlConnection

```typescript
export type ControlConnectionType = 'expression' | 'aux_switch' | 'cv';

export interface ControlConnection {
  id: string;
  sourceJackId: number;
  targetJackId: number;
  sourceInstanceId: string;
  targetInstanceId: string;
  acknowledgedWarnings?: string[];

  // Control-specific
  controlType: ControlConnectionType;
  controlledParameter: string | null;
  rangeMin: number | null;             // 0-127 for expression, volts for CV
  rangeMax: number | null;
  trsPolarity: 'tip-active' | 'ring-active' | null;
  auxSwitchAssignments: string[] | null;  // Per-contact function names
  cvVoltageRange: string | null;
}
```

### 1.4 Virtual Nodes

Audio signal chains start/end at non-product nodes (guitar, amp, FX loop). These are synthetic nodes in the audio view.

```typescript
export type VirtualNodeType =
  | 'guitar_input'
  | 'amp_input'
  | 'amp_fx_send'
  | 'amp_fx_return'
  | 'secondary_amp_input'  // A/B amp setups
  | 'tuner_output';        // Always-on tuner split

export interface VirtualNode {
  instanceId: string;        // Prefixed with 'virtual:' to distinguish
  nodeType: VirtualNodeType;
  label: string;             // User-editable, e.g., "Fender Twin"
  jackId: number;            // Negative integer (-1, -2, ...) to avoid collision with real jacks.id
  connectorType: string;     // Default: '1/4" TS'
}
```

### 1.5 Updated Workbench Interface

```typescript
// In WorkbenchContext.tsx
export interface Workbench {
  id: string;
  name: string;
  items: WorkbenchItem[];
  createdAt: string;
  updatedAt: string;
  boardId?: number;
  viewPositions?: ViewPositions;
  viewportStates?: ViewportStates;

  // Connections (one array per category)
  powerConnections?: PowerConnection[];   // existing
  audioConnections?: AudioConnection[];   // new
  midiConnections?: MidiConnection[];     // new
  controlConnections?: ControlConnection[];  // new

  // Virtual nodes for audio signal chain endpoints
  virtualNodes?: VirtualNode[];           // new
}
```

**File:** `apps/web/src/context/WorkbenchContext.tsx` — add new arrays and CRUD methods following the existing `addPowerConnection` / `removePowerConnection` / `setPowerConnections` / `acknowledgeWarning` pattern.

---

## 2. Audio View

### 2.1 Canvas Layout

The audio view renders the signal chain as a left-to-right directed graph on a Konva canvas (reusing `CanvasBase`, `ProductCard`, `ConnectionLine`, `PortDot`, `ZoomControls`).

- `guitar_input` virtual node at far left
- Pedals arranged left-to-right by `orderIndex`
- Parallel paths offset vertically (same `orderIndex`, different `parallelPathId`)
- FX loop sections visually grouped (dashed boundary or subtle background)
- `amp_input` virtual node at far right

### 2.2 Interaction

Follows the existing PowerView pattern:
1. Click a source audio output port dot
2. Click a target audio input port dot
3. Connection created, validation runs, warnings shown if any

When clicking a jack that belongs to a stereo `group_id`, prompt: "Connect as stereo pair" (creates two linked connections) vs "Connect this jack only."

### 2.3 Validation Rules (`utils/audioUtils.ts`)

| Rule | Severity | Message |
|---|---|---|
| Connector type mismatch | Warning | "Adapter needed: {source type} to {target type}" |
| Mono output -> stereo input (unpaired R) | Warning | "Mono source to stereo input — left channel only" |
| Stereo output -> mono input | Warning | "Stereo output to mono input — signal may be summed" |
| Impedance mismatch (if data available) | Warning | "Impedance mismatch: {source} to {target}" |
| No guitar input node | Error | "Audio chain has no guitar input" |
| No amp output node | Error | "Audio chain has no amp/output destination" |
| Circular connection | Error | "Connection creates a circular signal path" |
| Unconnected audio jack | Info | "Unconnected audio {input/output} on {product}" |

**Reuse:** Follow `powerUtils.ts` pattern (`validateConnection` function returning `{ status, warnings }`). Extend `ConnectionValidation` to include structured warnings (see section 5).

---

## 3. MIDI View

### 3.1 Canvas Layout

- MIDI controller(s) on the left
- Connected devices in chain order by `chainIndex`
- Topology auto-detected: if one device fans out to multiple targets, render as star/hub (MIDI thru box). If linear, render as chain.

### 3.2 Channel Assignment UI

Each connection line shows a badge with MIDI channel. Click to edit:
- Channel dropdown (1-16 or Omni)
- PC number (0-127)
- CC mapping table (add rows: CC#, parameter name)
- Clock toggle

### 3.3 Validation Rules (`utils/midiUtils.ts`)

| Rule | Severity | Message |
|---|---|---|
| TRS-A / TRS-B mismatch | Warning | "TRS MIDI standard mismatch — adapter needed" |
| 5-pin DIN <-> 3.5mm TRS | Warning | "Connector mismatch — 5-pin DIN to 3.5mm TRS adapter needed" |
| Multiple clock sources | Warning | "Multiple MIDI clock sources on this chain" |
| Duplicate MIDI channel | Warning | "Channel {N} used by multiple devices on this chain" |
| Long daisy chain (>4) | Info | "Consider a MIDI thru box for chains longer than 4 devices" |
| TRS standard unknown | Info | "TRS MIDI standard not confirmed for {product}" |

---

## 4. Control View

### 4.1 Connection Types

- **Expression:** TRS cable from expression pedal to target's expression input jack
- **Aux switch:** TRS/TS cable from external footswitch to target's aux input
- **CV:** TS cable carrying control voltage (uncommon but exists — e.g., Chase Bliss, Empress Zoia)

### 4.2 Validation Rules (`utils/controlUtils.ts`)

| Rule | Severity | Message |
|---|---|---|
| TRS polarity mismatch | Warning | "Expression polarity mismatch — may work in reverse" |
| Polarity mismatch + has switch | Info | "Polarity mismatch detected, but {product} has a polarity switch" |
| Expression to non-expression jack | Error | "Cannot connect expression pedal to non-expression input" |
| Aux switch to non-aux jack | Error | "Cannot connect aux switch to non-aux input" |
| Polarity unknown | Info | "TRS polarity not confirmed — verify compatibility" |

---

## 5. Validation & Warnings System

### 5.1 Structured Warnings

Extend the existing `ConnectionValidation` from `powerUtils.ts` into a shared type:

```typescript
// utils/connectionValidation.ts

export type ValidationSeverity = 'error' | 'warning' | 'info';

export interface ConnectionWarning {
  key: string;                      // Stable ID for acknowledgement
  severity: ValidationSeverity;
  message: string;
  adapterImplication?: {            // If this warning means an adapter is needed
    fromConnectorType: string;
    toConnectorType: string;
    description: string;
  };
}

export interface ConnectionValidation {
  status: 'valid' | 'warning' | 'error';
  warnings: ConnectionWarning[];
}
```

Each category validator (`audioUtils.ts`, `midiUtils.ts`, `controlUtils.ts`) returns this type. The existing `powerUtils.ts` would be migrated to use structured warnings in a later phase.

### 5.2 Warning -> Shopping List Flow

When a warning has an `adapterImplication`, the shopping list computation picks it up and generates an `AdapterRequirement`. This means adapter needs propagate automatically — no manual step.

---

## 6. Shopping List

### 6.1 Computed Types

```typescript
// utils/shoppingListUtils.ts

export type CableCategory = 'audio' | 'power' | 'midi' | 'control';

export interface CableRequirement {
  category: CableCategory;
  sourceConnectorType: string;
  targetConnectorType: string;
  needsAdapter: boolean;
  estimatedLengthCm: number | null;   // From layout + 20% slack
  overrideLengthCm: number | null;    // User override
  connectionIds: string[];            // Which connections this serves
  label: string;                      // e.g., '1/4" TS patch cable'
  notes: string[];                    // e.g., 'Polarity reversal needed'
}

export interface AdapterRequirement {
  fromConnectorType: string;
  toConnectorType: string;
  category: CableCategory;
  description: string;                // e.g., '5-pin DIN to 3.5mm TRS-A adapter'
  quantity: number;
  connectionIds: string[];
}

export interface ShoppingList {
  cables: CableRequirement[];
  adapters: AdapterRequirement[];
  summary: {
    totalCables: number;
    totalAdapters: number;
    byCategory: Record<CableCategory, { cables: number; adapters: number }>;
    estimatedTotalLengthM: number;
  };
  lengthDisclaimer: string;
}
```

### 6.2 Cable Length Estimation Algorithm

```
For each connection:
  1. Look up source and target instance positions from layout view positions
  2. If either position is missing -> length = null ("Place items in Layout view for estimates")
  3. Estimate jack position relative to card using jack.position field (Top/Left/Right/Bottom)
  4. Compute Euclidean distance between jack world positions
  5. Convert pixels to mm (1:1 in layout view)
  6. Add 20% routing slack (multiply by 1.2)
  7. Add 2x card height for cables routing under/over the board
  8. Round to nearest 5 cm
  9. Clamp minimum to 15 cm
```

### 6.3 UI in List Tab

Collapsible "Cable & Connector Summary" section below the existing product table:

```
[v] Cable & Connector Summary                    [Export CSV]
+-------------------------------------------------------+
| AUDIO CABLES (12)                                     |
|   8x  1/4" TS patch cable           ~15-30 cm        |
|   2x  1/4" TS to 1/4" TRS          ~20 cm      [!]  |
|   2x  1/4" TS instrument cable      ~3 m              |
|                                                        |
| POWER CABLES (6)                                      |
|   6x  2.1mm barrel DC cable         ~25-40 cm        |
|                                                        |
| MIDI CABLES (3)                                       |
|   2x  5-pin DIN MIDI cable          ~30 cm           |
|   1x  3.5mm TRS MIDI cable          ~20 cm           |
|                                                        |
| CONTROL CABLES (2)                                    |
|   1x  1/4" TRS expression cable     ~60 cm           |
|   1x  1/4" TRS aux switch cable     ~40 cm           |
|                                                        |
| ADAPTERS (2)                                          |
|   1x  Polarity reversal adapter                       |
|   1x  5-pin DIN to 3.5mm TRS-A adapter               |
+-------------------------------------------------------+
| Estimated total cable: ~8.5 m                         |
| * Lengths are estimates from Layout view positions    |
|   with 20% routing slack. Actual lengths may vary.    |
|   Always buy more cable than you think you need.      |
+-------------------------------------------------------+
```

Each cable row is expandable to show which connections it serves and allow length override.

### 6.4 Adapter UX Flow

When a connector mismatch is detected on any connection:
1. Warning appears on the connection (like existing power warnings)
2. User options:
   - **"Use an adapter cable"** -> acknowledge warning, adapter appears on shopping list
   - **"Add a utility"** -> opens Utilities catalog filtered to relevant type (e.g., MIDI adapter boxes)
   - **"I'll handle it"** -> dismiss warning (still noted on shopping list as "user-managed")

---

## 7. Backend Database Design (Future Cloud Save)

### 7.1 New Tables

```sql
-- Workbenches
CREATE TABLE workbenches (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name TEXT NOT NULL,
    board_product_id INTEGER REFERENCES products(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
    -- Future: user_id INTEGER REFERENCES users(id)
);

-- Items on a workbench
CREATE TABLE workbench_items (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    workbench_id INTEGER NOT NULL REFERENCES workbenches(id) ON DELETE CASCADE,
    product_id INTEGER NOT NULL REFERENCES products(id),
    instance_key TEXT NOT NULL,
    added_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(workbench_id, instance_key)
);

-- View positions
CREATE TABLE workbench_view_positions (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    workbench_id INTEGER NOT NULL REFERENCES workbenches(id) ON DELETE CASCADE,
    instance_key TEXT NOT NULL,
    view_mode TEXT NOT NULL,
    x DOUBLE PRECISION NOT NULL,
    y DOUBLE PRECISION NOT NULL,
    rotation INTEGER DEFAULT 0,
    z_index INTEGER DEFAULT 0,
    UNIQUE(workbench_id, instance_key, view_mode)
);

-- Virtual nodes
CREATE TABLE workbench_virtual_nodes (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    workbench_id INTEGER NOT NULL REFERENCES workbenches(id) ON DELETE CASCADE,
    instance_key TEXT NOT NULL,
    node_type TEXT NOT NULL CHECK(node_type IN (
        'guitar_input', 'amp_input', 'amp_fx_send', 'amp_fx_return',
        'secondary_amp_input', 'tuner_output'
    )),
    label TEXT NOT NULL,
    virtual_jack_id INTEGER NOT NULL,
    connector_type TEXT DEFAULT '1/4" TS',
    UNIQUE(workbench_id, instance_key)
);

-- Connections (single table with category discriminator)
CREATE TABLE workbench_connections (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    workbench_id INTEGER NOT NULL REFERENCES workbenches(id) ON DELETE CASCADE,
    category TEXT NOT NULL CHECK(category IN ('power', 'audio', 'midi', 'control')),

    -- Common fields
    source_jack_id INTEGER REFERENCES jacks(id),
    target_jack_id INTEGER REFERENCES jacks(id),
    source_virtual_jack_id INTEGER,
    target_virtual_jack_id INTEGER,
    source_instance_key TEXT NOT NULL,
    target_instance_key TEXT NOT NULL,
    acknowledged_warnings TEXT[],

    -- Audio-specific
    order_index INTEGER,
    parallel_path_id TEXT,
    fx_loop_group_id TEXT,
    signal_mode TEXT CHECK(signal_mode IN ('mono', 'stereo')),
    stereo_pair_connection_id INTEGER REFERENCES workbench_connections(id),

    -- MIDI-specific
    chain_index INTEGER,
    midi_channel INTEGER CHECK(midi_channel BETWEEN 1 AND 16),
    program_change_number INTEGER CHECK(program_change_number BETWEEN 0 AND 127),
    cc_assignments JSONB,
    carries_clock BOOLEAN DEFAULT FALSE,
    trs_midi_standard TEXT CHECK(trs_midi_standard IN ('TRS-A', 'TRS-B')),

    -- Control-specific
    control_type TEXT CHECK(control_type IN ('expression', 'aux_switch', 'cv')),
    controlled_parameter TEXT,
    range_min DOUBLE PRECISION,
    range_max DOUBLE PRECISION,
    trs_polarity TEXT CHECK(trs_polarity IN ('tip-active', 'ring-active')),
    aux_switch_assignments TEXT[],
    cv_voltage_range TEXT,

    CHECK (
        (source_jack_id IS NOT NULL OR source_virtual_jack_id IS NOT NULL)
        AND (target_jack_id IS NOT NULL OR target_virtual_jack_id IS NOT NULL)
    )
);

CREATE INDEX idx_wb_conn_workbench ON workbench_connections(workbench_id);
CREATE INDEX idx_wb_conn_category ON workbench_connections(category);
```

**Rationale for single connections table:** The frontend uses separate arrays for type safety, but the database uses a single table with a category discriminator because: (1) simpler cloud sync (one table to CRUD), (2) the shopping list query can aggregate across all categories without JOINs, (3) category-specific columns are nullable which is fine since they only apply to their category.

---

## 8. Phased Implementation Roadmap

### Phase 1: Audio Connections View
- Define `AudioConnection` and `VirtualNode` types
- Add `audioConnections[]` and `virtualNodes[]` to Workbench
- Add context CRUD methods (following `addPowerConnection` pattern)
- Create `utils/audioUtils.ts` with validation
- Build `AudioView.tsx` (reuse `CanvasBase`, `ProductCard`, `ConnectionLine`, `PortDot`, `ZoomControls`)
- Virtual node rendering and management
- Stereo pair UX
- Enable Audio tab in `ViewNav.tsx`
- **New files:** `types/connections.ts`, `utils/audioUtils.ts`, `AudioView.tsx`
- **Modified files:** `WorkbenchContext.tsx`, `ViewNav.tsx`, `Workbench/index.tsx`

### Phase 2: MIDI Connections View
- Define `MidiConnection` type
- Add `midiConnections[]` to Workbench + context methods
- Create `utils/midiUtils.ts`
- Build `MidiView.tsx` with chain visualization and channel assignment UI
- TRS-A/TRS-B detection
- Enable MIDI tab
- **New files:** `utils/midiUtils.ts`, `MidiView.tsx`
- **Modified files:** `WorkbenchContext.tsx`, `ViewNav.tsx`, `Workbench/index.tsx`

### Phase 3: Control Connections View
- Define `ControlConnection` type
- Add `controlConnections[]` to Workbench + context methods
- Create `utils/controlUtils.ts`
- Build `ControlView.tsx`
- Expression polarity detection
- Enable Control tab
- **New files:** `utils/controlUtils.ts`, `ControlView.tsx`
- **Modified files:** `WorkbenchContext.tsx`, `ViewNav.tsx`, `Workbench/index.tsx`

### Phase 4: Shopping List
- Create `utils/shoppingListUtils.ts` with `computeShoppingList()` function
- Cable length estimation from layout positions
- Create `ShoppingListSection.tsx` component
- Integrate into List tab as collapsible section
- User override for cable lengths
- CSV export
- **New files:** `utils/shoppingListUtils.ts`, `ShoppingListSection.tsx`
- **Modified files:** List tab view component

### Phase 5: Structured Validation Refactor
- Create shared `utils/connectionValidation.ts` with `ConnectionWarning` types
- Migrate `powerUtils.ts` to structured warnings
- Align all four category validators to same interface
- Wire `adapterImplication` flow from warnings -> shopping list

### Phase 6: Backend Database Tables (deferred until cloud save is needed)
- Write migration SQL in `data/migrations/`
- Spring Boot entities, repositories, DTOs, controllers
- Workbench CRUD API endpoints
- localStorage <-> server sync protocol

---

## Critical Files Reference

| File | Role |
|---|---|
| `apps/web/src/context/WorkbenchContext.tsx` | Central state — add new connection arrays + CRUD methods |
| `apps/web/src/components/Workbench/PowerView.tsx` | Reference implementation for all new views |
| `apps/web/src/utils/powerUtils.ts` | Validation pattern to follow (`validateConnection`, `ConnectionValidation`) |
| `apps/web/src/utils/powerAssignment.ts` | Jack filtering pattern (`getPowerInputJack`, `getPowerOutputJacks`) |
| `apps/web/src/components/Workbench/ConnectionLine.tsx` | Reuse for all connection categories |
| `apps/web/src/components/Workbench/PortDot.tsx` | Reuse for all port rendering |
| `apps/web/src/components/Workbench/CanvasBase.tsx` | Reuse as canvas wrapper |
| `apps/web/src/components/Workbench/ViewNav.tsx` | Enable new tabs |
| `data/schema/gear_postgres.sql` | `jacks` table with group_id, connector_type, impedance, position |
