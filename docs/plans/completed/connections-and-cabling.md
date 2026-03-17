# Connections & Cabling Design Document

**Status:** Design
**Created:** 2026-02-23

## Context

Building a pedalboard requires planning dozens of connections — audio signal paths, power cables, MIDI chains, expression/aux cables — and then buying or building the right cables for each. This is one of the most complex and error-prone parts of board building, especially when dealing with:

- Stereo signal paths that split/merge
- Connector mismatches requiring adapter cables (e.g., 5-pin DIN to 3.5mm TRS MIDI)
- 1/4" TRS wiring variations (TIP/RING assignment differs by manufacturer)
- 5-pin DIN connector configurations and power-over-MIDI requirements
- Polarity differences on expression pedals
- TRS-A vs TRS-B MIDI standards
- FX loop routing through the amp
- Direct output routing (FOH, FRFR speakers, audio interfaces)

This design document covers the complete connections architecture: data model, per-category views (Audio, MIDI, Control), a shopping list that synthesizes everything into a cable/adapter bill of materials, and backend tables for future cloud save.

**Scope:** Design only — no implementation in this plan. Implementation will follow in phased plans.

---

## Design Decisions (Confirmed)

| Decision | Choice | Rationale |
|---|---|---|
| Connection storage | Separate arrays per category | Matches existing `powerConnections[]` pattern; clean type safety per category; no migration needed |
| Cable types | Derived from jacks + signal mode | Connector types plus signal mode determine cable type (see section 6.5). No cable types lookup table needed. |
| Shopping list location | Integrated into List tab table | Cables and adapters appear as rows alongside products in a unified shopping manifest. |
| Cable length estimation | Derive from layout + 20% slack + user override | Smart defaults with escape hatch. Disclaimer about estimation accuracy. |
| Adapter handling | Warning system (like power view) | Options: "adapter cable" (noted on shopping list), "add a utility" (links to catalog), "dismiss" |
| Audio topology | Full (parallel, Y-split, FX loops, stereo) | Covers complex rigs from day one |
| MIDI metadata | Channels, clock routing | Physical connection metadata only. PC/CC mapping is a future MIDI spec sheet feature, not a connection property. |
| Control metadata | Expression ranges, polarity, aux assignments, CV | Same approach — capture what the user needs to configure |
| Backend design | JSONB blob (for future cloud save) | Workbench state is loaded/saved whole — no need for normalized tables. Requires user accounts. |
| Cable routing | User-defined waypoints | Users add bend points to connection lines for realistic routing. Improves length estimation accuracy. |
| Signal flow direction | Right-to-left | Matches pedal convention (input on right, output on left) |

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
  waypoints: Array<{ x: number; y: number }>;  // Cable routing bend points (layout coords, mm)
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
  | 'direct_output'        // FOH, FRFR speaker, audio interface
  | 'tuner_output';        // Always-on tuner split

export interface VirtualNode {
  instanceId: string;        // Prefixed with 'virtual:' to distinguish
  nodeType: VirtualNodeType;
  label: string;             // User-editable, e.g., "Fender Twin"
  virtualJackId: string;     // e.g., 'virtual-jack:guitar-out' — string to avoid collision with real jacks.id
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

The audio view renders the signal chain as a right-to-left directed graph on a Konva canvas (reusing `CanvasBase`, `ProductCard`, `ConnectionLine`, `PortDot`, `ZoomControls`). This matches pedal convention where input is on the right and output is on the left.

- `guitar_input` virtual node at far right
- Pedals arranged right-to-left by `orderIndex`
- Parallel paths offset vertically (same `orderIndex`, different `parallelPathId`)
- FX loop sections visually grouped (dashed boundary or subtle background)
- `amp_input` / `direct_output` virtual node at far left

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
| Stereo output -> mono input | Warning | "Stereo output to mono input — signal may be summed or lose one channel" |
| Impedance mismatch (if data available) | Warning | "Impedance mismatch: {source} to {target}" |
| Circular connection | Error | "Connection creates a circular signal path" |
| Unconnected audio jack | Info | "Unconnected audio {input/output} on {product}" |

**Reuse:** Follow `powerUtils.ts` pattern (`validateConnection` function returning `{ status, warnings }`). Extend `ConnectionValidation` to include structured warnings (see section 5).

---

## 3. MIDI View

### 3.1 Canvas Layout

- MIDI controller(s) at bottom center
- Connected devices above, arranged by `chainIndex`
- Topology auto-detected from connection graph: if one device's outputs fan out to multiple targets, render as a hub layout. If connections form a linear sequence, render as a chain. This is purely about the visual topology — a MIDI controller with multiple outputs naturally renders as a hub.

### 3.2 Channel & Clock UI

Each connection line shows a badge with MIDI channel. Click to edit:
- Channel dropdown (1-16 or Omni)
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

- **Expression:** TRS or TS cable from expression pedal to target's expression input jack (cable type determined by the jacks on both ends)
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
  estimatedLengthMm: number | null;   // From layout + 20% slack
  overrideLengthMm: number | null;    // User override
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
    estimatedTotalLengthMm: number;
  };
  lengthDisclaimer: string;
}
```

### 6.2 Cable Routing Waypoints

Connection lines in the Layout view support user-defined waypoints — draggable intermediate points that let users model realistic cable routing paths between pedals. Cables don't run in straight lines on a pedalboard; they wind between pedals, follow rails, and route through cable channels.

Each connection stores an ordered array of waypoints:
```typescript
export interface RouteWaypoint {
  x: number;  // mm, in layout coordinate space
  y: number;
}
```

Users can:
- Double-click a connection line to add a waypoint
- Drag waypoints to bend the cable path
- Double-click a waypoint to remove it

### 6.3 Cable Length Estimation Algorithm

```
For each connection:
  1. Look up source and target instance positions from layout view positions
  2. If either position is missing -> length = null ("Place items in Layout view for estimates")
  3. Estimate jack position relative to card using jack.position field (Top/Left/Right/Bottom)
  4. If waypoints exist: sum the segment distances (jack -> wp1 -> wp2 -> ... -> jack)
  5. If no waypoints: compute Euclidean distance between jack world positions
  6. Layout coordinates are 1:1 with mm
  7. Add 20% routing slack (multiply by 1.2)
  8. Round to nearest 50 mm
  9. Clamp minimum to 150 mm
```

### 6.4 Unified Shopping List Table

Cables, adapters, and accessories appear as rows in the same table as products — they are all items the user needs to acquire. The List tab becomes a unified shopping manifest.

Each row in the table has:
- **Type** — Product, Cable, or Adapter (filterable)
- **Category** — Audio, Power, MIDI, Control (filterable)
- **Description** — e.g., "1/4" TS patch cable", "Strymon BigSky", "5-pin DIN to 3.5mm TRS-A adapter"
- **Qty** — Number needed
- **Est. Length** — For cables only (from layout waypoints + 20% slack, in mm). Editable for user override.
- **Have** — Checkbox (user marks items they already own)
- **Price** — MSRP for products, blank for cables/adapters (user can fill in)
- **Notes** — Warnings, adapter implications, etc.

Summary row at bottom shows totals: items needed, items owned, estimated total cable length, estimated total cost.

```
+------+----------+----------------------------------+-----+---------+------+--------+-------+
| Type | Category | Description                      | Qty | Est. mm | Have | Price  | Notes |
+------+----------+----------------------------------+-----+---------+------+--------+-------+
| Prod | —        | Strymon BigSky                   |  1  |    —    |  [x] | $479   |       |
| Prod | —        | Boss DD-500                      |  1  |    —    |  [ ] | $349   |       |
| Cable| Audio    | 1/4" TS patch cable              |  8  | 150-300 |  [ ] |        |       |
| Cable| Audio    | 1/4" TS to 1/4" TRS             |  2  |   200   |  [ ] |        |  [!]  |
| Cable| Audio    | 1/4" TS instrument cable         |  2  |  3000   |  [ ] |        |       |
| Cable| Power    | 2.1mm barrel DC cable            |  6  | 250-400 |  [ ] |        |       |
| Cable| MIDI     | 5-pin DIN MIDI cable             |  2  |   300   |  [ ] |        |       |
| Cable| Control  | 1/4" TRS expression cable        |  1  |   600   |  [ ] |        |       |
| Adpt | MIDI     | 5-pin DIN to 3.5mm TRS-A adapter |  1  |    —    |  [ ] |        |       |
+------+----------+----------------------------------+-----+---------+------+--------+-------+
| TOTALS: 24 items | 10 needed | ~8.5 m cable | Est. $828                                   |
+------+----------+----------------------------------+-----+---------+------+--------+-------+
| * Lengths are estimates from Layout view routing with 20% slack.                          |
|   Actual lengths may vary. Always buy more cable than you think you need.                 |
+------+----------+----------------------------------+-----+---------+------+--------+-------+
```

[Export CSV] button exports the full table.

### 6.5 Cable Type Derivation

Cable types are derived from the connected jacks' connector types and signal mode — no cable types lookup table is needed, but the derivation logic must handle nuanced cases:

| Source Connector | Target Connector | Signal Mode | Cable Type |
|---|---|---|---|
| 1/4" TS | 1/4" TS | mono | Mono patch cable |
| 1/4" TRS | 1/4" TRS | stereo | Stereo cable |
| 1/4" TRS | 1/4" TRS | mono | Balanced mono cable (e.g., expression) |
| 1/4" TRS | 2x 1/4" TS | stereo | Stereo breakout cable (TRS -> 2x TS) |
| 2x 1/4" TS | 2x 1/4" TS | stereo | 2x mono patch cables (paired) |
| 5-pin DIN | 5-pin DIN | — | 5-pin DIN MIDI cable |
| 3.5mm TRS | 3.5mm TRS | — | 3.5mm TRS MIDI cable |
| 5-pin DIN | 3.5mm TRS | — | Adapter needed (see warnings) |
| 2.1mm barrel | 2.1mm barrel | — | DC power cable |

Key rules:
- **Both connector types AND signal mode are needed** to determine the cable. Two TRS jacks could mean stereo audio, balanced mono, or expression depending on context.
- **Stereo connections between TS jacks** are actually two separate mono cables (paired by `stereoPairConnectionId`).
- **TRS-to-2xTS breakout cables** are a single cable entity on the shopping list even though they serve a stereo pair of connections.
- When the derivation is ambiguous, show an info message asking the user to confirm the cable type.

### 6.6 Adapter UX Flow

When a connector mismatch is detected on any connection:
1. Warning appears on the connection (like existing power warnings)
2. User options:
   - **"Use an adapter cable"** -> acknowledge warning, adapter appears on shopping list
   - **"Add a utility"** -> opens Utilities catalog filtered to relevant type (e.g., MIDI adapter boxes)
   - **"I'll handle it"** -> dismiss warning (still noted on shopping list as "user-managed")

---

## 7. Backend Database Design (Future Cloud Save)

Extracted to standalone plan: [`docs/plans/workbench-cloud-save.md`](workbench-cloud-save.md)

---

## 8. Phased Implementation Roadmap

### Phase 1: Structured Validation Types
- Create shared `utils/connectionValidation.ts` with `ConnectionWarning`, `ConnectionValidation`, `ValidationSeverity` types
- Migrate `powerUtils.ts` to use structured warnings (backward-compatible)
- This gives all subsequent phases a shared validation interface from day one
- **New files:** `utils/connectionValidation.ts`
- **Modified files:** `utils/powerUtils.ts`

### Phase 2: Audio Connections View
- Define `AudioConnection` and `VirtualNode` types
- Add `audioConnections[]` and `virtualNodes[]` to Workbench
- Add context CRUD methods (following `addPowerConnection` pattern)
- Create `utils/audioUtils.ts` with validation (using Phase 1 types)
- Build `AudioView.tsx` (reuse `CanvasBase`, `ProductCard`, `ConnectionLine`, `PortDot`, `ZoomControls`)
- Virtual node rendering and management
- Stereo pair UX
- Cable routing waypoints on connection lines
- Enable Audio tab in `ViewNav.tsx`
- **New files:** `types/connections.ts`, `utils/audioUtils.ts`, `AudioView.tsx`
- **Modified files:** `WorkbenchContext.tsx`, `ViewNav.tsx`, `Workbench/index.tsx`

### Phase 3: MIDI Connections View
- Define `MidiConnection` type
- Add `midiConnections[]` to Workbench + context methods
- Create `utils/midiUtils.ts`
- Build `MidiView.tsx` with chain visualization
- TRS-A/TRS-B detection
- Enable MIDI tab
- **New files:** `utils/midiUtils.ts`, `MidiView.tsx`
- **Modified files:** `WorkbenchContext.tsx`, `ViewNav.tsx`, `Workbench/index.tsx`

### Phase 4: Control Connections View
- Define `ControlConnection` type
- Add `controlConnections[]` to Workbench + context methods
- Create `utils/controlUtils.ts`
- Build `ControlView.tsx`
- Expression polarity detection
- Enable Control tab
- **New files:** `utils/controlUtils.ts`, `ControlView.tsx`
- **Modified files:** `WorkbenchContext.tsx`, `ViewNav.tsx`, `Workbench/index.tsx`

### Phase 5: Unified Shopping List
- Create `utils/shoppingListUtils.ts` with `computeShoppingList()` function
- Cable type derivation logic (section 6.5)
- Cable length estimation from layout waypoints
- Integrate cables/adapters as rows in the List tab table alongside products
- "Have" checkbox, price column, totals row
- User override for cable lengths
- CSV export
- Wire `adapterImplication` flow from validation warnings -> shopping list
- **New files:** `utils/shoppingListUtils.ts`
- **Modified files:** List tab view component

### Phase 6: Backend Persistence (deferred until user accounts exist)
- Extracted to standalone plan: [`docs/plans/workbench-cloud-save.md`](workbench-cloud-save.md)

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
