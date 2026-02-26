# Phase 3: MIDI Connections View

## Context

Phases 1 and 2 are complete and merged to main:

- **Phase 1** — Shared `ConnectionWarning`/`ConnectionValidation` types live in `utils/connectionValidation.ts`; `powerUtils.ts` uses structured warnings.
- **Phase 2** — `AudioView.tsx` is live. `AudioConnection`, `VirtualNode`, `AudioPlaceholder`, `VirtualJackSpec` types exist in `types/connections.ts`. `WorkbenchContext` has audio CRUD methods.

`MidiConnection` and `ControlConnection` are already stub-defined in `types/connections.ts` but incomplete (missing `chainIndex`, `trsMidiStandard`, `carriesClock`). This phase expands the stubs, adds context methods, builds the validation utility, and creates the `MidiView` canvas.

**Reference implementation:** `AudioView.tsx` (1029 lines). Follow its patterns for canvas setup, port dot rendering, connection creation flow, pending state, warning popover, toolbar, and empty state.

**Key RJM PBC/6X note:** The first seeded MIDI controller (`product_id = 189`) has only ONE physical MIDI port — output-only by default. MIDI input requires a Y-cable accessory. The view must handle output-only devices gracefully and not assume every MIDI-capable product has both in and out jacks.

---

## Files to Create

| File | Purpose |
|---|---|
| `apps/web/src/utils/midiUtils.ts` | MIDI jack helpers + `validateMidiConnection()` |
| `apps/web/src/components/Workbench/MidiView.tsx` | MIDI connections canvas |
| `apps/web/src/__tests__/utils/midiUtils.test.ts` | Tests for midiUtils |

## Files to Modify

| File | Change |
|---|---|
| `apps/web/src/types/connections.ts` | Expand `MidiConnection` stub (add `chainIndex`, `trsMidiStandard`, rename `routesMidiClock` → `carriesClock`) |
| `apps/web/src/context/WorkbenchContext.tsx` | Add `midiConnections` to Workbench interface + CRUD methods |
| `apps/web/src/components/Workbench/ViewNav.tsx` | `enabled: false` → `enabled: true` for MIDI tab |
| `apps/web/src/components/Workbench/index.tsx` | Import MidiView, add `case 'midi':` |
| `apps/web/src/components/Workbench/index.scss` | Add `.workbench__midi-*` classes (channel badge, TRS selector) |

---

## Step 1: Expand `MidiConnection` type in `connections.ts`

Replace the stub (lines 52–61) with the full type:

```typescript
export interface MidiConnection {
  id: string;
  sourceJackId: number;
  targetJackId: number;
  sourceInstanceId: string;
  targetInstanceId: string;
  acknowledgedWarnings?: string[];

  // MIDI-specific
  chainIndex: number;                          // Position in daisy chain (0 = first from controller)
  midiChannel: number | null;                  // 1–16, null = omni
  carriesClock: boolean;                       // Whether this connection routes MIDI clock
  trsMidiStandard: 'TRS-A' | 'TRS-B' | null;  // Only for 3.5mm TRS connectors; null = unknown
}
```

No changes needed to `ControlConnection` stub — that's Phase 4.

---

## Step 2: `WorkbenchContext.tsx` — MIDI CRUD methods

### Workbench interface additions
```typescript
midiConnections?: MidiConnection[];
```

Import `MidiConnection` (already imported as part of the connections import if shared; otherwise add it).

### New context methods (exact same pattern as audio methods)
```typescript
addMidiConnection: (conn: Omit<MidiConnection, 'id'>) => void;
removeMidiConnection: (connId: string) => void;
setMidiConnections: (conns: MidiConnection[]) => void;
acknowledgeMidiWarning: (connId: string, warningKey: string) => void;
updateMidiConnection: (connId: string, updates: Partial<Pick<MidiConnection, 'midiChannel' | 'carriesClock' | 'trsMidiStandard'>>) => void;
```

`updateMidiConnection` is new (AudioView didn't need it) — lets the channel badge update individual fields without replacing the entire connection.

Implementations follow the existing `updateStore` → `updateActiveWorkbench` pattern. For example:

```typescript
const updateMidiConnection = useCallback((connId: string, updates: Partial<...>) => {
  updateActiveWorkbench(wb => ({
    ...wb,
    midiConnections: (wb.midiConnections || []).map(c =>
      c.id === connId ? { ...c, ...updates } : c
    ),
  }));
}, [updateActiveWorkbench]);
```

---

## Step 3: `midiUtils.ts`

```typescript
import { Jack } from './transformers';
import { MidiConnection } from '../types/connections';
import { ConnectionValidation, ConnectionWarning } from './connectionValidation';

// Jack filtering helpers
export function getMidiInputJacks(row: { jacks: Jack[] }): Jack[]
  // category === 'midi' && (direction === 'input' || direction === 'bidirectional')

export function getMidiOutputJacks(row: { jacks: Jack[] }): Jack[]
  // category === 'midi' && (direction === 'output' || direction === 'bidirectional')

export function hasMidiJacks(row: { jacks: Jack[] }): boolean
  // any jack with category === 'midi'

// Connector type helpers
export function isTrsMidiConnector(connectorType: string | null): boolean
  // true if connector_type contains '3.5mm' or 'TRS' (case-insensitive)

export function is5PinDinConnector(connectorType: string | null): boolean
  // true if connector_type contains '5-pin' or 'DIN' (case-insensitive)

// Connection validation — returns structured ConnectionValidation
// Rule keys follow 'midi:rule-name' convention:
//
//   midi:circular         → error (adding this would create a cycle in the connection graph)
//   midi:din-to-trs       → warning + adapterImplication (5-pin DIN ↔ 3.5mm TRS mismatch)
//   midi:trs-a-trs-b      → warning + adapterImplication (TRS-A ↔ TRS-B mismatch)
//   midi:clock-conflict   → warning (existingConnections already has carriesClock=true in this chain)
//   midi:long-chain       → info (chain depth > 4)
//
// Note: duplicate-channel warning is checked in MidiView at render time (not at connection
// creation time) because channel assignment happens after the connection is created.
export function validateMidiConnection(
  sourceJack: { connector_type: string | null; jack_name: string | null },
  targetJack: { connector_type: string | null; jack_name: string | null },
  existingConnections: MidiConnection[],
  sourceInstanceId: string,
  targetInstanceId: string,
): ConnectionValidation

// Cycle detection (internal helper, exported for testing)
export function wouldCreateMidiCycle(
  sourceInstanceId: string,
  targetInstanceId: string,
  existingConnections: MidiConnection[],
): boolean

// Chain depth calculation — returns how many hops from the given instanceId
// back to a root node (a node with no MIDI input connections)
export function getChainDepth(
  instanceId: string,
  connections: MidiConnection[],
): number
```

### TRS-A / TRS-B logic

`trsMidiStandard` on the connection is set by the user via the channel badge after creation. During validation, if both source and target jacks are TRS MIDI connectors, the rule `midi:trs-a-trs-b` fires only when the connection already has a standard set on both sides and they differ. If either is null (unknown), fire `midi:trs-unknown` info instead.

Since `trsMidiStandard` isn't a field on `Jack` in the database yet (the `jacks` table has no TRS standard column), the validation operates on the connection-level setting rather than per-jack data.

---

## Step 4: `MidiView.tsx`

### Canvas layout

- **Flow direction:** top-to-bottom — MIDI signal flows from controller down/out to connected devices, then chains further down. MIDI controllers render at **bottom center**; connected devices above arranged by chain depth.
- **Port positions:**
  - MIDI output port: bottom edge of card — `y ≈ CARD_HEIGHT - 4`
  - MIDI input port: top edge of card — `y ≈ 4`
  - Both ports centered horizontally on the card: `x = CARD_WIDTH / 2`
- **Port spacing:** N/A — MIDI devices typically have at most one in + one out + one thru. All ports render at the horizontal center. If multiple ports exist (e.g., a thru alongside an out), offset them horizontally by ±16px.

### Default positions (first render)

```
MIDI controllers: x = center, y = CANVAS_HEIGHT - 180  (bottom)
Other devices: auto-arranged in rows above, 200px spacing
  - Row 1 (chain depth 1): y = CANVAS_HEIGHT - 380
  - Row 2 (chain depth 2): y = CANVAS_HEIGHT - 580
  - Devices at same depth: spread horizontally, centered
```

Positions saved via existing `updateViewPosition` (same `VIEW_KEY = 'midi'` scoping pattern as AudioView).

### Connection creation flow

`PendingMidiConnection` state:
```typescript
interface PendingMidiConnection {
  jackId: number;
  instanceId: string;
  direction: 'output' | 'input';
}
```

1. Click an output port dot → set `pendingSource`
2. Preview line follows mouse (same `ghostLine` pattern as AudioView/PowerView)
3. Click an input port dot → run `validateMidiConnection` → if no errors, call `addMidiConnection` with:
   ```typescript
   {
     sourceJackId, targetJackId,
     sourceInstanceId, targetInstanceId,
     chainIndex: getChainDepth(targetInstanceId, existingConnections),
     midiChannel: null,
     carriesClock: false,
     trsMidiStandard: null,
     acknowledgedWarnings: [],
   }
   ```
4. ESC cancels pending

### Channel badge overlay

When a connection is selected (`selectedConnId`), render an HTML overlay (not Konva) positioned at the screen midpoint of the connection line:

```
┌─────────────────────────────┐
│  MIDI Channel: [Omni ▾]     │
│  [x] Carries MIDI Clock     │
│  TRS Standard: [Unknown ▾]  │  ← only if source or target is TRS MIDI
└─────────────────────────────┘
```

- Channel dropdown: options `['Omni', '1', '2', ... '16']`. Omni maps to `null`.
- Clock checkbox: maps to `carriesClock`.
- TRS Standard: hidden unless `isTrsMidiConnector(sourceJack.connector_type) || isTrsMidiConnector(targetJack.connector_type)`. Options: `['Unknown', 'TRS-A', 'TRS-B']`.
- All changes call `updateMidiConnection(connId, { midiChannel, carriesClock, trsMidiStandard })`.

Overlay positioning: use the same `viewport.worldToScreen()` transform to convert the connection midpoint world coords to screen coords, then position the overlay div with `position: absolute`.

### Warning popover

Same structure as AudioView/PowerView warning popovers. Calls `acknowledgeMidiWarning`.

### Duplicate channel warning (render-time)

After all connections render, compute a map of `{ midiChannel → instanceIds[] }`. For any channel used by more than one device on the same reachable subgraph, highlight those connections with a `warning` color and show the warning in their warning popover.

This is a render-time check, not stored in connection data.

### Toolbar

- Zoom controls (reused `ZoomControls`)
- Fit-all (same `fitAll` pattern as AudioView)
- "Clear all" (button appears when connections exist, with confirm dialog)

### Empty state

```
"No items with MIDI jacks in this workbench."
```

If there ARE MIDI-capable items but no connections yet:
```
"Click a MIDI output port to start connecting. [?] icon with hover tip"
```

---

## Step 5: `ViewNav.tsx`

```typescript
{ key: 'midi', label: 'MIDI', enabled: true },  // was false
```

---

## Step 6: `Workbench/index.tsx`

```typescript
import MidiView from './MidiView';

// in renderActiveView():
case 'midi':
  return (
    <div className="workbench__content workbench__content--canvas">
      <MidiView rows={rows} />
    </div>
  );
```

---

## Step 7: `index.scss` — new MIDI classes

```scss
&__midi-badge {
  position: absolute;
  background: #1e2a2e;
  border: 1px solid #2a4a52;
  border-radius: 6px;
  padding: 8px 12px;
  min-width: 180px;
  display: flex;
  flex-direction: column;
  gap: 8px;
  z-index: 20;
  color: #c0d8e0;
  font-size: 12px;
}

&__midi-badge-row {
  display: flex;
  align-items: center;
  gap: 8px;
}

&__midi-badge-label {
  color: #888;
  white-space: nowrap;
}

&__midi-badge select {
  background: #111;
  border: 1px solid #334;
  color: #c0d8e0;
  border-radius: 3px;
  padding: 2px 4px;
  font-size: 11px;
}
```

---

## Step 8: `midiUtils.test.ts`

- `getMidiInputJacks` — returns only category='midi' direction='input' or 'bidirectional' jacks
- `getMidiOutputJacks` — returns only category='midi' direction='output' or 'bidirectional' jacks
- `hasMidiJacks` — false for audio-only rows, true for rows with midi jacks
- `isTrsMidiConnector` — true for '3.5mm TRS', false for '5-pin DIN', false for null
- `is5PinDinConnector` — true for '5-pin DIN', false for '3.5mm TRS', false for null
- `wouldCreateMidiCycle` — false for new unconnected items
- `wouldCreateMidiCycle` — true when adding connection would close a loop
- `getChainDepth` — returns 0 for a root node (no incoming connections)
- `getChainDepth` — returns 1 for a device one hop from the root
- `validateMidiConnection` — valid returns status 'valid'
- `validateMidiConnection` — 5-pin DIN to 3.5mm TRS → warning + adapterImplication
- `validateMidiConnection` — 3.5mm TRS to 3.5mm TRS (same standard or null) → valid
- `validateMidiConnection` — null connector types handled gracefully (no warning)
- `validateMidiConnection` — circular connection → error
- `validateMidiConnection` — chain depth > 4 → info warning

---

## Verification

1. `npm test` — all tests pass including new midiUtils tests (45 + ~15 new = ~60 total)
2. `npm run web:build` — compiles cleanly (no TypeScript errors)
3. Manual: Workbench → MIDI tab is now clickable
4. Manual: items with MIDI jacks appear on canvas with port dots at top/bottom edges
5. Manual: MIDI controller items render at bottom; other items above
6. Manual: click output port → preview line follows mouse → click input port → connection created
7. Manual: selected connection shows channel badge overlay with channel, clock, and TRS dropdowns
8. Manual: changing channel in badge updates the connection immediately
9. Manual: TRS standard selector appears for 3.5mm TRS connections, hidden for 5-pin DIN
10. Manual: connector mismatch warning appears and acknowledge button works
11. Manual: ESC cancels pending connection
12. Manual: Delete key removes selected connection
13. Manual: "Clear all" with confirm removes all MIDI connections
