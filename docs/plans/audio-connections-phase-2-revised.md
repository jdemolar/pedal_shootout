# Phase 2 (Revised): Audio Connections View

**Status:** Pending implementation
**Branch:** `audio-connections-phase-2-revised`
**Created:** 2026-02-25
**Supersedes:** `docs/plans/audio-connections-phase-2.md` (closed PR #52)
**Design reference:** `docs/plans/connections-and-cabling.md`

## What Changed from the Original Plan

The original plan was implemented and reviewed (PR #52, closed). Three problems were identified:

1. **Waypoint editing UI removed** — waypoints are physical cable routing and only make sense overlaid on a layout view with accurate jack positions per enclosure. The audio view is a signal chain schematic; waypoints add no value here. The `waypoints` field on `AudioConnection` and the `waypoints` prop on `ConnectionLine` are retained for future use (see `docs/plans/audio-cable-routing-waypoints.md`), but no UI is exposed in AudioView.

2. **Port label / card text overlap** — `PORT_START_Y = 12` placed port dots in the manufacturer text area. Fixed by positioning ports below the card text region using an extended card height (same pattern as PowerView's supply cards).

3. **Missing audio jacks** — some workbench items have no audio jack data yet. Instead of hiding them silently, AudioView now shows a per-item warning list. Additionally, users can add **placeholder items** — configurable virtual pedals with chosen jack configurations — so planning can proceed before all gear is entered.

Everything else (types, utils, context additions, ViewNav, Workbench/index wiring, tests) carries over from the original plan unchanged.

---

## Files to Create

| File | Purpose |
|---|---|
| `apps/web/src/types/connections.ts` | `AudioConnection`, `VirtualNode`, `AudioPlaceholder`, `VirtualJackSpec`, `RouteWaypoint`, plus MIDI/Control stubs |
| `apps/web/src/utils/audioUtils.ts` | Jack helpers + `validateAudioConnection` (unchanged from original) |
| `apps/web/src/components/Workbench/AudioView.tsx` | Revised canvas component |
| `apps/web/src/__tests__/utils/audioUtils.test.ts` | Tests (identical to original — all 23 pass) |

## Files to Modify

| File | Change |
|---|---|
| `apps/web/src/utils/transformers.ts` | Add `group_id` to `Jack` + `transformJack` (unchanged) |
| `apps/web/src/context/WorkbenchContext.tsx` | Add `audioConnections`, `virtualNodes`, `audioPlaceholders` + CRUD methods |
| `apps/web/src/components/Workbench/ConnectionLine.tsx` | Add `waypoints` prop (passive, no editing UI wired) |
| `apps/web/src/components/Workbench/ViewNav.tsx` | Enable audio tab |
| `apps/web/src/components/Workbench/index.tsx` | Import AudioView, add `case 'audio':` |

---

## Step 1: `types/connections.ts`

Same as original plan except:
- Add `AudioPlaceholder` and `VirtualJackSpec` types
- `VirtualNode.nodeType` expanded with additional endpoint types

```typescript
export interface RouteWaypoint { x: number; y: number; }

export interface AudioConnection {
  id: string;
  sourceJackId: number | string;   // number for real jacks, string for virtual/placeholder
  targetJackId: number | string;
  sourceInstanceId: string;
  targetInstanceId: string;
  acknowledgedWarnings?: string[];
  orderIndex: number;
  parallelPathId: string | null;
  fxLoopGroupId: string | null;
  signalMode: 'mono' | 'stereo';
  stereoPairConnectionId: string | null;
  waypoints: RouteWaypoint[];      // always [] in AudioView; reserved for Layout cable routing
}

export type VirtualNodeType =
  | 'guitar_input'
  | 'amp_input' | 'amp_fx_send' | 'amp_fx_return'
  | 'secondary_amp_input'
  | 'frfr_input'
  | 'direct_output'          // FOH / audio interface send
  | 'tuner_output';

export interface VirtualNode {
  instanceId: string;       // e.g. 'virtual:guitar-1'
  nodeType: VirtualNodeType;
  label: string;            // user-editable
  virtualJackId: string;    // e.g. 'virtual-jack:guitar-out'
  connectorType: string;    // '1/4" TS', 'XLR', etc.
}

/** A single configurable jack on a placeholder item */
export interface VirtualJackSpec {
  virtualJackId: string;   // e.g. 'placeholder:inst-x:out-0'
  direction: 'input' | 'output';
  connectorType: string;
  label: string;
  group_id: string | null; // non-null links this jack to its stereo partner
}

/** A user-defined placeholder item with configurable jack layout, for planning
 *  signal chains before all gear is entered in the database. */
export interface AudioPlaceholder {
  instanceId: string;     // e.g. 'placeholder:uuid'
  label: string;          // user-editable, e.g. 'Reverb pedal'
  jacks: VirtualJackSpec[];
}

// Stubs for Phases 3–4
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

### Placeholder presets

AudioView exposes a dropdown/menu to add a placeholder with a preset configuration. Presets:

| Label | Jacks |
|---|---|
| Mono pedal | 1× TS out, 1× TS in |
| Stereo pedal | 2× TS out (L/R paired), 2× TS in (L/R paired) |
| Mono in / Stereo out | 1× TS out-L, 1× TS out-R, 1× TS in |
| Mono FX loop | 1× TS out, 1× TS in, 1× FX send (TS out), 1× FX return (TS in) |
| Stereo FX loop | 2× TS out, 2× TS in, 1× FX send, 1× FX return |

Group IDs for stereo pairs: generate a UUID per pair, shared between the two jacks.

---

## Step 2: `transformers.ts`

Identical to original plan — add `group_id: string | null` to `Jack` interface and `group_id: dto.groupId` to `transformJack`.

---

## Step 3: `audioUtils.ts`

Identical to original plan. No changes needed.

---

## Step 4: `WorkbenchContext.tsx`

Same as original plan plus `audioPlaceholders`.

**`Workbench` interface additions:**
```typescript
audioConnections?: AudioConnection[];
virtualNodes?: VirtualNode[];
audioPlaceholders?: AudioPlaceholder[];
```

**`WorkbenchContextType` additions** (same as original, plus placeholder CRUD):
```typescript
addAudioConnection: (conn: Omit<AudioConnection, 'id'>) => void;
removeAudioConnection: (connId: string) => void;
setAudioConnections: (conns: AudioConnection[]) => void;
acknowledgeAudioWarning: (connId: string, warningKey: string) => void;
updateAudioConnectionWaypoints: (connId: string, waypoints: RouteWaypoint[]) => void;

addVirtualNode: (node: VirtualNode) => void;
removeVirtualNode: (instanceId: string) => void;
setVirtualNodes: (nodes: VirtualNode[]) => void;

addAudioPlaceholder: (placeholder: AudioPlaceholder) => void;
removeAudioPlaceholder: (instanceId: string) => void;
updateAudioPlaceholderLabel: (instanceId: string, label: string) => void;
```

All follow the `updateStore(prev => updateActiveWorkbench(prev, wb => ...))` pattern.

---

## Step 5: `ConnectionLine.tsx`

Add `waypoints` prop (passive — no editing interaction wired from AudioView):

```typescript
waypoints?: RouteWaypoint[];
```

Rendering: when `waypoints` is non-empty, render a Konva `Line` polyline through `[sx, sy, wp0.x, wp0.y, ..., tx, ty]` (no `bezier`). When absent or empty, render existing bezier. No `onDblClick` needed in this phase.

---

## Step 6: `AudioView.tsx`

### Port positioning fix

The original plan put ports at `PORT_START_Y = 12`, which overlaps the manufacturer text (y=8). Fix: extend the card height for audio rows based on the number of ports, and position ports starting at the bottom of the base card content area.

```typescript
const PORT_SPACING = 18;
const AUDIO_PORT_START_Y = CARD_HEIGHT - 4;  // just below the card's text content
const AUDIO_PORT_EXTRA = PORT_SPACING;

function audioCardHeight(inputCount: number, outputCount: number): number {
  const portCount = Math.max(inputCount, outputCount);
  if (portCount <= 1) return CARD_HEIGHT;
  return CARD_HEIGHT + (portCount - 1) * AUDIO_PORT_EXTRA;
}
```

Ports are placed at `y = AUDIO_PORT_START_Y + i * PORT_SPACING` within the card group. This positions the first port dot near the bottom of the card's existing content, with additional ports extending below (inside the extended card area).

Output ports: `x = 2` (left edge — signal flows right-to-left so output is on the left)
Input ports: `x = CARD_WIDTH - 2` (right edge)

### Missing data warnings

After rendering the canvas, display a fixed HTML panel (not a Konva overlay) listing workbench items that were not rendered because they have no audio jacks:

```
⚠ 3 items not shown — no audio jack data:
  · Boss DD-8
  · Strymon Zuma
  · Walrus Audio Mako Series D1
```

Position: bottom-left of the canvas container, above the action buttons. Only shown when `missingItems.length > 0`.

```typescript
const missingItems = rows.filter(r => !hasAudioJacks(r));
```

### Placeholder items

Placeholder items are rendered on the canvas identically to real product cards (using `ProductCard` with `productType='pedal'`), except:
- `manufacturer` = `''` (empty — `ProductCard` renders the manufacturer line as blank)
- `model` = `placeholder.label`
- Port dots from `placeholder.jacks` using the same left/right positioning as real audio jacks

Placeholders are draggable; positions saved under their `instanceId` via `updateViewPosition`.

**"Add placeholder" UI:** a dropdown button in the toolbar:
```
[+ Add placeholder ▾]
  ─ Mono pedal
  ─ Stereo pedal
  ─ Mono in / Stereo out
  ─ Mono FX loop
  ─ Stereo FX loop
```

Clicking a preset calls `addAudioPlaceholder` with the generated `AudioPlaceholder`. The new placeholder's default position is near the center of the current viewport.

**Label editing:** double-click a placeholder card → HTML `<input>` overlay (same pattern as virtual node label editing) → `updateAudioPlaceholderLabel`.

**Removing a placeholder:** `Delete`/`Backspace` when a placeholder card is selected (selected state tracked alongside connection selection). Any connections to/from that placeholder's jacks are also removed via `setAudioConnections`.

### Additional virtual node types

The "Add virtual node" UI is a dropdown in the toolbar:
```
[+ Add node ▾]
  ─ Second Amp
  ─ FRFR / Speaker
  ─ Direct Out (FOH)
  ─ Tuner Out
```

`guitar_input` and `amp_input` nodes are auto-created on first mount (unchanged). Additional nodes are added on demand and can be removed (delete while selected).

Guitar node: output jack on left side.
Amp / FRFR / Direct / Tuner nodes: input jack on right side.
Amp FX send/return: two jacks (send = output on left, return = input on right).

### Connection flow (unchanged from original)

- Click output port → `setPendingSource`; preview line follows mouse
- Click input port → if both have `group_id` and partner → stereo pair prompt; else direct create
- Clicking same direction: swap pending to new port
- ESC: cancel pending; Delete/Backspace: remove selected connection

### Port key (unchanged)

```typescript
function portKey(instanceId: string, jackId: number | string): string {
  return `${instanceId}:${jackId}`;
}
```

Works for real jack IDs (number), virtual node jack IDs (string `'virtual-jack:...'`), and placeholder jack IDs (string `'placeholder:...'`).

### Toolbar

```
[+ Add placeholder ▾]  [+ Add node ▾]  [Clear all]  [Zoom controls]
```

"Clear all" removes all `audioConnections` (not placeholders or virtual nodes). `window.confirm` guard.

### Empty state

If no rows have audio jacks AND there are no audio placeholders (virtual guitar/amp nodes are always present so the canvas is never truly empty):
```
No items with audio connections in this workbench.
Add a placeholder to start planning your signal chain.
```

---

## Step 7: `ViewNav.tsx`

`{ key: 'audio', label: 'Audio', enabled: true }` — unchanged from original.

---

## Step 8: `Workbench/index.tsx`

Identical to original plan.

---

## Step 9: `audioUtils.test.ts`

Identical to original plan — all 23 tests, unchanged. `audioUtils.ts` itself is unchanged so no new tests needed.

---

## Port Layout Reference (updated)

```
AudioView card — ports below text content, extending card downward if needed:

  RIGHT EDGE (x = CARD_WIDTH - 2)         LEFT EDGE (x = 2)
  ┌─────────────────────────────────────────────────────────┐
  │  Manufacturer                                           │  ← y=8
  │  Model                                                  │  ← y=24
  │  type                                                   │  ← y=44
  │                                                         │
  ●─ In 1                                       Out 1 ─────●│  ← y = CARD_HEIGHT - 4
  ●─ In 2                                       Out 2 ─────●│  ← y = CARD_HEIGHT - 4 + PORT_SPACING
  └─────────────────────────────────────────────────────────┘
    (card height extended to fit port count)

Virtual node — Guitar:                  Virtual node — Amp:
  ┌────────────┐                                 ┌────────────┐
  │   Guitar   ●── output (left)  input ──●      │    Amp     │
  └────────────┘                                 └────────────┘

Placeholder card — rendered same as product card:
  ┌─────────────────────────────────────────────────────────┐
  │  (blank)                                                │
  │  Reverb pedal                              [dblclick    │
  │  pedal                                      to rename]  │
  │                                                         │
  ●─ In                                          Out ───────●
  └─────────────────────────────────────────────────────────┘
```

---

## Verification Checklist

1. `npm run web:test` — all 42 tests pass (23 audioUtils + existing 19)
2. `npm run web:build` — clean TypeScript compile
3. Manual: Audio tab is clickable
4. Manual: Items with audio jacks appear with port dots below the text content (no overlap)
5. Manual: Items without audio jacks appear in the warning list, not on the canvas
6. Manual: Guitar + Amp virtual nodes auto-appear
7. Manual: Click output → preview line → click input → connection created
8. Manual: Stereo pair prompt appears when both jacks have group_id
9. Manual: Warning popover + acknowledge button works on mismatched connections
10. Manual: ESC cancels; Delete removes selected connection
11. Manual: "Add placeholder → Stereo pedal" adds a draggable card with 4 port dots
12. Manual: Double-click placeholder label → rename inline
13. Manual: Select placeholder + Delete → removes card and its connections
14. Manual: "Add node → Second Amp" adds a second amp virtual node
15. Manual: Fit-all centers all cards
16. Manual: Positions survive page refresh (localStorage persistence)
