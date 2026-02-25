# Phase 2: Audio Connections View

**Status:** Pending implementation
**Branch:** `audio-connections-phase-2`
**Created:** 2026-02-25
**Design reference:** `docs/plans/connections-and-cabling.md`

## Overview

Implements the Audio Connections canvas view where users wire audio signal flow between pedals and virtual endpoint nodes (guitar input, amp input). Follows the PowerView pattern (`components/Workbench/PowerView.tsx`) but adapts for:

- Right-to-left signal flow (input ports on right side of card, output ports on left)
- Multiple audio jacks per device stacked vertically
- Stereo pair handling (two parallel connections for a L/R pair)
- Cable routing waypoints (bend points on connection lines)
- Virtual nodes for guitar and amp endpoints

Phase 1 (structured validation types) is complete and merged. `ConnectionWarning` and `ConnectionValidation` live in `utils/connectionValidation.ts` and are ready to use.

---

## Files to Create

| File | Purpose |
|---|---|
| `apps/web/src/types/connections.ts` | `AudioConnection`, `VirtualNode`, `VirtualNodeType`, `RouteWaypoint`, plus `MidiConnection`/`ControlConnection` stubs |
| `apps/web/src/utils/audioUtils.ts` | Jack filtering helpers + `validateAudioConnection()` |
| `apps/web/src/components/Workbench/AudioView.tsx` | Canvas component (mirrors PowerView structure) |
| `apps/web/src/__tests__/utils/audioUtils.test.ts` | Unit tests for audioUtils |

## Files to Modify

| File | Change |
|---|---|
| `apps/web/src/utils/transformers.ts` | Add `group_id` to `Jack` interface + `transformJack` mapping |
| `apps/web/src/context/WorkbenchContext.tsx` | Add `audioConnections`/`virtualNodes` to `Workbench` interface + CRUD methods |
| `apps/web/src/components/Workbench/ConnectionLine.tsx` | Add optional `waypoints` prop + `onDblClick` callback |
| `apps/web/src/components/Workbench/ViewNav.tsx` | `enabled: false` → `enabled: true` for the `'audio'` tab |
| `apps/web/src/components/Workbench/index.tsx` | Import `AudioView`, add `case 'audio':` to `renderActiveView()` |

---

## Step-by-Step Implementation

### Step 1: `types/connections.ts`

New file. Defines all connection category types.

```typescript
export interface RouteWaypoint { x: number; y: number; }

export interface AudioConnection {
  id: string;
  sourceJackId: number | string;   // number for real jacks, string for virtual (e.g. 'virtual-jack:guitar-out')
  targetJackId: number | string;
  sourceInstanceId: string;
  targetInstanceId: string;
  acknowledgedWarnings?: string[];
  orderIndex: number;
  parallelPathId: string | null;
  fxLoopGroupId: string | null;
  signalMode: 'mono' | 'stereo';
  stereoPairConnectionId: string | null;
  waypoints: RouteWaypoint[];
}

export type VirtualNodeType =
  | 'guitar_input' | 'amp_input' | 'amp_fx_send' | 'amp_fx_return'
  | 'secondary_amp_input' | 'direct_output' | 'tuner_output';

export interface VirtualNode {
  instanceId: string;       // e.g. 'virtual:guitar-1'
  nodeType: VirtualNodeType;
  label: string;            // user-editable
  virtualJackId: string;    // e.g. 'virtual-jack:guitar-out'
  connectorType: string;    // default '1/4" TS'
}

// Stubs for Phases 3–4 (defined but unused until MIDI/Control views)
export interface MidiConnection {
  id: string;
  sourceJackId: number;
  targetJackId: number;
  sourceInstanceId: string;
  targetInstanceId: string;
  acknowledgedWarnings?: string[];
  midiChannel: number | null;
  routesMidiClock: boolean;
}

export interface ControlConnection {
  id: string;
  sourceJackId: number;
  targetJackId: number;
  sourceInstanceId: string;
  targetInstanceId: string;
  acknowledgedWarnings?: string[];
  controlType: 'expression' | 'aux_switch' | 'cv' | 'other';
  polarityNormal: boolean;
}
```

---

### Step 2: `transformers.ts` — add `group_id`

`JackApiResponse` already has `groupId: string | null` (confirmed in `types/api.ts` line 21). The `Jack` interface and `transformJack` function do not map it yet.

Add to `Jack` interface:
```typescript
group_id: string | null;
```

Add to `transformJack` return object:
```typescript
group_id: dto.groupId,
```

---

### Step 3: `audioUtils.ts`

New file. Provides jack helpers and connection validation.

**Jack filtering helpers** — straightforward filter functions:

```typescript
export function getAudioInputJacks(row: { jacks: Jack[] }): Jack[]
  // filter: category === 'audio' && direction === 'input'

export function getAudioOutputJacks(row: { jacks: Jack[] }): Jack[]
  // filter: category === 'audio' && direction === 'output'

export function hasAudioJacks(row: { jacks: Jack[] }): boolean
  // true if any jack has category === 'audio'

export function getStereoPartner(jack: Jack, allJacks: Jack[]): Jack | undefined
  // finds the other jack sharing the same non-null group_id among allJacks
  // returns undefined if jack.group_id is null or no partner exists
```

**`validateAudioConnection()`** — returns a `ConnectionValidation`. Rules (keys follow `audio:rule-name` convention):

| Rule key | Severity | Condition | `adapterImplication`? |
|---|---|---|---|
| `audio:connector-mismatch` | `warning` | `sourceJack.connector_type !== targetJack.connector_type` (both non-null) | yes |
| `audio:mono-to-stereo` | `warning` | sourceSignalMode `'mono'` + targetSignalMode `'stereo'` | no |
| `audio:stereo-to-mono` | `warning` | sourceSignalMode `'stereo'` + targetSignalMode `'mono'` | no |
| `audio:impedance-mismatch` | `warning` | both jacks have `impedance_ohms`, and `target / source > 100` | no |
| `audio:circular-connection` | `error` | `wouldCreateCycle()` returns true | no |

`status` is `'error'` if any warning has severity `'error'`, `'warning'` if any warning, else `'valid'`.

**`wouldCreateCycle()`** — internal helper, exported for testing. BFS/DFS over `existingConnections` treating `sourceInstanceId → targetInstanceId` as directed edges. Returns true if `targetInstanceId` can already reach `sourceInstanceId` (i.e., adding the new edge would close a loop).

**Deriving `signalMode`** before calling: AudioView computes `signalMode` from the jack — `'stereo'` if `group_id` is non-null and a stereo partner exists in the same row's jacks, otherwise `'mono'`.

---

### Step 4: `WorkbenchContext.tsx`

**`Workbench` interface additions:**
```typescript
audioConnections?: AudioConnection[];
virtualNodes?: VirtualNode[];
```

Import `AudioConnection`, `VirtualNode`, `RouteWaypoint` from `../types/connections`.

**`WorkbenchContextType` additions:**
```typescript
addAudioConnection: (conn: Omit<AudioConnection, 'id'>) => void;
removeAudioConnection: (connId: string) => void;
setAudioConnections: (conns: AudioConnection[]) => void;
acknowledgeAudioWarning: (connId: string, warningKey: string) => void;
updateAudioConnectionWaypoints: (connId: string, waypoints: RouteWaypoint[]) => void;
addVirtualNode: (node: VirtualNode) => void;
removeVirtualNode: (instanceId: string) => void;
setVirtualNodes: (nodes: VirtualNode[]) => void;
```

All implementations use the same `updateStore(prev => updateActiveWorkbench(prev, wb => ...))` pattern as the existing power connection methods. Add all new callbacks to the `useMemo` dependency array for `value`.

---

### Step 5: `ConnectionLine.tsx` — waypoints

Add optional props:
```typescript
waypoints?: RouteWaypoint[];
onDblClick?: () => void;
```

Rendering logic:
- **No waypoints (or empty array):** render existing bezier curve — no change to current behavior
- **Waypoints present:** render as a Konva `Line` with `points` array built by flattening start → each waypoint → end: `[sx, sy, wp0.x, wp0.y, ..., tx, ty]`. No `bezier` prop on polyline variant.
- Wire `onDblClick` to both `onDblClick` and `onDblTap` on the Konva Line element (both variants).

---

### Step 6: `AudioView.tsx`

Canvas component following the PowerView structure. Key differences from PowerView:

**Signal flow direction:** right-to-left.
- Output ports (send audio out of device): positioned at `x ≈ 2` (left side of card)
- Input ports (receive audio into device): positioned at `x ≈ CARD_WIDTH - 2` (right side of card)
- Port vertical spacing: `PORT_SPACING = 18` (same constant as PowerView)

**Default positions (first render, no saved positions):**
```
guitar virtual node: x = CANVAS_WIDTH - VIRTUAL_NODE_WIDTH - 40, y = center
items with audio jacks: spread horizontally right-to-left, 200px spacing
amp virtual node: x = 40, y = center
```

**Virtual node cards** — simple Konva `Group` (not `ProductCard`):
- Rounded rect with a distinct muted-teal background color
- Label text (user-editable: dblclick → small HTML `<input>` overlay positioned via `viewport.worldToScreen`)
- Single port dot (guitar node: output on left; amp node: input on right)
- Draggable; position saved under their `instanceId` using `updateViewPosition(VIEW_KEY, ...)`

**Auto-init virtual nodes:**
```typescript
useEffect(() => {
  if (!activeWorkbench.virtualNodes || activeWorkbench.virtualNodes.length === 0) {
    setVirtualNodes([
      { instanceId: 'virtual:guitar-1', nodeType: 'guitar_input', label: 'Guitar',
        virtualJackId: 'virtual-jack:guitar-out', connectorType: '1/4" TS' },
      { instanceId: 'virtual:amp-1', nodeType: 'amp_input', label: 'Amp',
        virtualJackId: 'virtual-jack:amp-in', connectorType: '1/4" TS' },
    ]);
  }
}, []);
```

**Port key** — accepts `jackId: number | string` (toString for both):
```typescript
function portKey(instanceId: string, jackId: number | string): string {
  return `${instanceId}:${jackId}`;
}
```

**Pending connection state:**
```typescript
interface PendingConnection {
  jackId: number | string;
  instanceId: string;
  compositeKey: string;
  direction: 'output' | 'input';
}
```

**Connection creation flow:**
1. Click output port → `setPendingSource`
2. Click input port → check if both jacks have `group_id` → show stereo pair prompt OR create directly
3. ESC cancels pending

**Stereo pair prompt** — HTML overlay (absolute positioned), appears after selecting source and target:
- "Connect as stereo pair?" with [Yes] and [Just this jack] buttons
- "Yes": create primary connection (signalMode `'stereo'`) + find stereo partners via `getStereoPartner()` → create second connection with `stereoPairConnectionId = primaryId`
- "Just this jack": single connection, `stereoPairConnectionId = null`, `signalMode = 'mono'`
- If either jack has no `group_id`: skip prompt entirely

**Waypoint interaction:**
- **Add:** dblclick on `ConnectionLine` (via `onDblClick`) → get Konva stage pointer position → `viewport.screenToWorld()` → insert new waypoint at nearest segment index → `updateAudioConnectionWaypoints`
- **Move:** when connection selected, render draggable Konva `Circle` at each waypoint; `onDragEnd` updates waypoints array
- **Remove:** dblclick on waypoint circle → remove that index → `updateAudioConnectionWaypoints`

**Warning popover:** same HTML overlay structure as PowerView's popover. Uses `acknowledgeAudioWarning`.

**Toolbar:** zoom controls (`ZoomControls` component, same as PowerView) + fit-all + "Clear all" button (with `window.confirm`).

**Empty state:**
```
"No items with audio connections in this workbench."
```
Shown when workbench has no rows with audio jacks (and after virtual nodes have been set, which always exist).

**VIEW_KEY:** `'audio'` — all `updateViewPosition` / `getViewPositions` / `updateViewportState` calls use this key.

---

### Step 7: `ViewNav.tsx`

Change:
```typescript
{ key: 'audio', label: 'Audio', enabled: false },
```
to:
```typescript
{ key: 'audio', label: 'Audio', enabled: true },
```

---

### Step 8: `Workbench/index.tsx`

Add import:
```typescript
import AudioView from './AudioView';
```

Add case to `renderActiveView()` switch:
```typescript
case 'audio':
  return (
    <div className="workbench__content workbench__content--canvas">
      <AudioView rows={rows} />
    </div>
  );
```

---

### Step 9: `audioUtils.test.ts`

New file at `apps/web/src/__tests__/utils/audioUtils.test.ts`.

Test cases (must pass with 100% coverage threshold):

| Test | Description |
|---|---|
| `getAudioInputJacks` | returns only `category='audio' direction='input'` jacks |
| `getAudioOutputJacks` | returns only `category='audio' direction='output'` jacks |
| `hasAudioJacks` | false for power-only row; true for row with audio jacks |
| `getStereoPartner` | returns partner jack with same group_id; undefined if no group_id |
| `getStereoPartner` | undefined if group_id set but no matching partner |
| `validateAudioConnection` — valid | status `'valid'`, no warnings |
| `validateAudioConnection` — connector mismatch | warning with `adapterImplication` |
| `validateAudioConnection` — mono→stereo | warning, no `adapterImplication` |
| `validateAudioConnection` — stereo→mono | warning, no `adapterImplication` |
| `validateAudioConnection` — impedance mismatch | warning when both jacks have `impedance_ohms` |
| `validateAudioConnection` — null connector types | no connector-mismatch warning |
| `wouldCreateCycle` | false for new unconnected items |
| `wouldCreateCycle` | true when adding connection would close a loop |

---

## Port Layout Reference

```
AudioView card (right-to-left signal flow):

  RIGHT SIDE (x = CARD_WIDTH - 2)     LEFT SIDE (x = 2)
  ┌──────────────────────────────────────────────────┐
  │  [In 1] ●                         ● [Out 1]      │
  │  [In 2] ●                         ● [Out 2]      │
  └──────────────────────────────────────────────────┘

Virtual node — Guitar (right side of canvas):
  ┌────────────┐
  │   Guitar   │ ● output (left)
  └────────────┘

Virtual node — Amp (left side of canvas):
         input ● ┌────────────┐
                  │    Amp     │
                  └────────────┘
```

---

## Verification Checklist

1. `npm run web:test` — all tests pass including new audioUtils tests
2. `npm run web:build` — compiles cleanly (no TypeScript errors)
3. Manual: Workbench → Audio tab is now clickable (not greyed out)
4. Manual: items with audio jacks appear on canvas with L/R port dots
5. Manual: guitar and amp virtual nodes appear automatically
6. Manual: click output port → preview line follows mouse → click input port → connection created
7. Manual: stereo jack pair triggers stereo pair prompt
8. Manual: connection warning popover appears; acknowledge button works
9. Manual: double-click connection line → waypoint added, draggable, double-click to remove
10. Manual: ESC cancels pending; Delete/Backspace removes selected connection
11. Manual: fit-all button centers all items on canvas
12. Manual: drag virtual node → position saved, survives page refresh

---

## Key Decisions / Open Questions

- **Virtual jack IDs as strings:** `sourceJackId`/`targetJackId` are typed as `number | string` in `AudioConnection` to handle virtual nodes (`'virtual-jack:guitar-out'`). The `portKey` function accepts `number | string`. This differs from `PowerConnection` which is always `number`.
- **Virtual nodes always auto-created:** On first mount, guitar + amp nodes are inserted if not already present. User can rename labels; removing virtual nodes is not exposed in the UI in Phase 2.
- **`MidiConnection` and `ControlConnection`:** defined as stubs in `types/connections.ts` for Phase 3/4; not wired into context or views yet.
- **No shopping list integration in Phase 2:** cable type derivation (from connector types + signal mode) is deferred to the unified shopping list phase.
