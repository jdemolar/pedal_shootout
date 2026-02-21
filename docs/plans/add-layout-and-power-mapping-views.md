# Plan: Workbench Canvas Views — Infrastructure + Power + Layout

## Context

The Workbench currently has a single List view (table + insights sidebar). The goal is to add visual canvas-based views for pedalboard planning: a Layout view for physical pedal arrangement and a Power view for interactive power connection mapping. This is the MVP; Audio, MIDI, and Control connection views will follow as separate tasks.

This plan captures all design decisions made during the interview process and defines the scope for implementation.

## Design Decisions

### View architecture
- **Six views total** (MVP builds first three): Layout, Audio, Power, MIDI, Control, List
- Sub-nav below the Workbench header, all views at the same level
- Order reflects importance: visual-first, list as secondary
- Each canvas view has **independent product positions** — physical layout arrangement is different from power routing arrangement, etc.
- List view stays as-is (unified table + insights sidebar)

### Canvas technology
- **Konva.js / react-konva** for all canvas views
- Supports PNG image layering with z-index (future: product images on pedalboard)
- Performant single rasterized surface for many elements
- Built-in drag-and-drop, hit detection, event handling
- Connection lines drawn as Konva `Line`/`Arrow` shapes
- Each view can use separate Konva `Layer`s within a shared `Stage` pattern

### Connection interaction
- **Both drag-to-connect and click-click-connect** supported
- Drag from a supply output port to a pedal power input (or vice versa)
- Click source port, then click target port as an alternative
- Remove connections by clicking/selecting and pressing delete, or a context action

### Daisy-chain / current-doubling
- **Multiple connections to the same port** (no explicit group objects)
- Daisy-chain: drag multiple pedals to the same supply output; tool validates total current
- Current-doubling: drag multiple supply outputs to the same pedal power input
- Visual: lines fan out/in from the shared port

### State persistence
- **localStorage now**, designed as a JSON schema that could drop into a JSONB database column later
- Extends existing `WorkbenchContext` localStorage structure
- Connections data model to be designed during implementation (new JSON schema concepts like a "connections" structure)
- Positions stored per-view per-product per-workbench

### Relationship to PowerBudgetInsight
- **Both coexist** — PowerBudgetInsight stays in the List view sidebar; Power canvas is the full interactive version
- **Auto-assign button** on Power canvas uses existing `assignPedalsToOutputs()` algorithm to seed connections
- Auto-assign on first visit is a future enhancement

### Warnings and validation
- Green/yellow/red connection validation (voltage, current, polarity, connector compatibility)
- **Acknowledgeable warnings** — user can mark yellow warnings as "resolved" (e.g., "I have this adapter")
- Included conversion cables (e.g., Cioks RCA-to-barrel) to be modeled later (see todo)

### Scope boundaries (deferred)
- Adding products from canvas (likely yes, but not for MVP — workbench items only for now)
- Audio, MIDI, Control views (separate tasks after MVP)
- PNG product images (future — start with labeled rectangles/cards)
- Included cable/adapter modeling (future — acknowledgeable warnings are sufficient for now)

## Implementation Scope (MVP)

### 1. Canvas infrastructure
- Install react-konva + konva dependencies
- View mode state in Workbench (which view is active)
- Sub-nav component: `[Layout | Audio | Power | MIDI | Control | List]`
  - Audio, MIDI, Control tabs disabled/grayed with "Coming soon" until implemented
- Shared base canvas component wrapping Konva `Stage` + `Layer`
- Per-view position state in localStorage (extend `WorkbenchContext`)
- Product card rendering on canvas (labeled rectangles with manufacturer + model)
- Drag-to-reposition products on canvas

### 2. Layout view
- Free-form canvas with draggable product cards
- No connections (pure arrangement view)
- Products appear at default positions on first visit
- Positions persist in localStorage per workbench

### 3. Power connection view
- Power supply cards showing individual output ports (labeled with voltage/mA)
- Pedal/consumer cards showing power input port
- Connection creation: drag port-to-port or click-click
- Connection removal
- Real-time validation with color coding (green/yellow/red)
- Acknowledgeable yellow warnings
- Auto-assign button (reuses `assignPedalsToOutputs()` from `PowerBudgetInsight`)
- Voltage/current math for selectable outputs (reuses `effectiveCurrentMa()` from `powerUtils.ts`)
- Connection state persistence in localStorage

## Key Files

### Existing (to modify)
- `apps/web/src/components/Workbench/index.tsx` — Add view mode toggle, conditionally render List vs canvas views
- `apps/web/src/components/Workbench/index.scss` — Sub-nav and canvas view styles
- `apps/web/src/context/WorkbenchContext.tsx` — Extend state with per-view positions + connections
- `apps/web/src/utils/powerUtils.ts` — Reuse existing voltage/current utilities
- `apps/web/src/components/Workbench/PowerBudgetInsight.tsx` — Extract `assignPedalsToOutputs()` to shared utility

### New (to create)
- `apps/web/src/components/Workbench/ViewNav.tsx` — Sub-nav tab component
- `apps/web/src/components/Workbench/CanvasBase.tsx` — Shared Konva Stage/Layer wrapper
- `apps/web/src/components/Workbench/LayoutView.tsx` — Layout canvas view
- `apps/web/src/components/Workbench/PowerView.tsx` — Power connection canvas view
- `apps/web/src/components/Workbench/ProductCard.tsx` — Konva product card (shared across canvas views)
- `apps/web/src/components/Workbench/PortDot.tsx` — Clickable/draggable port indicator on cards
- `apps/web/src/components/Workbench/ConnectionLine.tsx` — Konva line between connected ports

### Reference (read-only)
- `docs/plans/power-mapping-view.md` — Original design notes
- `apps/web/src/components/Workbench/WorkbenchTable.tsx` — Existing list view (stays as-is)
- `apps/web/src/components/Workbench/InsightsSidebar.tsx` — Stays in list view

## Todo items to add to `docs/plans/todo.md`
- Revisit adding products directly from canvas views (likely yes, defer for now)
- Model included conversion cables (e.g., Cioks RCA-to-barrel) in power budgeting and power connections view
- Auto-assign on first visit to Power view (invoke `assignPedalsToOutputs()` automatically when no connections exist)

## Verification
- `npm run web:build` compiles without errors
- `npm run web:test` passes (add tests for new components)
- Sub-nav renders all 6 tabs; Audio/MIDI/Control show "coming soon"
- Layout view: products appear, can be dragged, positions persist across page reload
- Power view: supply outputs and pedal power inputs render with port dots
- Power view: connections can be created (drag and click-click), removed, and persist across reload
- Power view: green/yellow/red validation displays correctly
- Power view: yellow warnings can be acknowledged
- Power view: auto-assign button populates connections using existing algorithm
- List view: unchanged behavior, sidebar insights still work

---

## Implementation Steps

The implementation is organized into 7 sequential steps. Each step builds on the previous one and produces a working, testable state.

### Step 1: Install dependencies and extract shared power types

**Goal:** Add konva/react-konva packages and extract power budget types + algorithms from `PowerBudgetInsight.tsx` into reusable modules.

**Why first:** The Power view needs these extracted utilities, and extracting them without changing behavior is a safe refactor to do early.

**New files:**
- `apps/web/src/types/power.ts` — Shared type definitions
- `apps/web/src/utils/powerAssignment.ts` — Extracted algorithm + helpers

**Types to extract** (from `PowerBudgetInsight.tsx` lines 11–152):
```typescript
// types/power.ts
export interface PowerConsumer {
  productId: number;          // add this — needed for canvas mapping
  manufacturer: string;
  model: string;
  current_ma: number | null;
  voltage: string | null;
  polarity: string | null;
  connector_type: string | null;
}

export interface PowerSupplyInfo {
  productId: number;          // add this — needed for canvas mapping
  manufacturer: string;
  model: string;
  total_current_ma: number | null;
  total_output_count: number | null;
  isolated_output_count: number | null;
  supply_type: string | null;
  available_voltages: string | null;
  mounting_type: string | null;
  output_jacks: Jack[];
}

export interface TaggedOutputJack extends Jack {
  supplyName: string;
  supplyProductId: number;    // add this — needed for canvas mapping
  portIndex: number;
}

export interface PortAssignment {
  consumer: PowerConsumer;
  jack: TaggedOutputJack;
  notes: string[];
}

export interface AssignmentResult {
  assignments: PortAssignment[];
  unassigned: PowerConsumer[];
}

export interface DaisyChainGroup {
  voltage: string;
  polarity: string;
  connector_type: string;
  consumers: PowerConsumer[];
  combined_ma: number;
  max_output_ma: number | null;
}
```

**Functions to extract** (to `utils/powerAssignment.ts`):
- `getPowerInputJack(row)` (line 32)
- `getPowerOutputJacks(row)` (line 36)
- `getMajorityPolarity(jacks)` (line 44)
- `getMajorityConnector(jacks)` (line 65)
- `computeDaisyChainGroups(consumers, outputJacks)` (line 97)
- `assignPedalsToOutputs(consumers, supplies)` (line 158)
- `buildSupplyLinkUrl(totalDraw, consumerCount, highestDrawMa, uniqueVoltages)` (line 251)
- `extractPowerData(rows)` — **new** — consolidates lines 270–339 into a reusable function that returns `{ consumers, supplies, knownConsumers, unknownConsumers, totalDraw, highestDraw, totalCapacity, status, headroom, headroomPct, uniqueVoltages, totalOutputCount, allOutputJacks }`

**Modify:**
- `PowerBudgetInsight.tsx` — Import types + functions from new modules instead of defining inline. Component becomes ~250 lines of pure rendering. No behavior change.

**Install:**
```bash
cd apps/web && npm install konva react-konva
```

**Also install Konva types** (check if `@types/konva` is needed — react-konva ships its own types since v18).

**Verify:** `npm run web:build` passes, `npm run web:test` passes, PowerBudgetInsight behaves identically.

---

### Step 2: Add view mode state and sub-nav component

**Goal:** Add the `[Layout | Audio | Power | MIDI | Control | List]` tab bar and conditional rendering in the Workbench.

**New files:**
- `apps/web/src/components/Workbench/ViewNav.tsx`

**ViewNav component:**
```typescript
export type ViewMode = 'layout' | 'audio' | 'power' | 'midi' | 'control' | 'list';

interface ViewNavProps {
  activeView: ViewMode;
  onViewChange: (view: ViewMode) => void;
}

const VIEW_TABS: { key: ViewMode; label: string; enabled: boolean }[] = [
  { key: 'layout', label: 'Layout', enabled: true },
  { key: 'audio', label: 'Audio', enabled: false },
  { key: 'power', label: 'Power', enabled: true },
  { key: 'midi', label: 'MIDI', enabled: false },
  { key: 'control', label: 'Control', enabled: false },
  { key: 'list', label: 'List', enabled: true },
];
```

Disabled tabs render with muted styling and `title="Coming soon"`. No tooltip library needed — native `title` attribute is sufficient.

**Modify `Workbench/index.tsx`:**
- Add `const [activeView, setActiveView] = useState<ViewMode>('list');`
- Render `<ViewNav>` between header and body
- In body: conditionally render based on `activeView`:
  - `'list'` → existing `<WorkbenchTableView>` + `<InsightsSidebar>` + `<DetailPanel>`
  - `'layout'` → placeholder `<div>Layout view coming soon</div>` (replaced in Step 4)
  - `'power'` → placeholder `<div>Power view coming soon</div>` (replaced in Step 5)
  - Disabled views can't be selected (enforced in ViewNav click handler)

**Modify `Workbench/index.scss`:**
- Add `.workbench__view-nav` styles — horizontal tab bar below header:
  ```scss
  &__view-nav {
    display: flex;
    gap: 0;
    border-bottom: 1px solid #2a2a2a;
    margin-bottom: 0;
    flex-shrink: 0;
  }
  &__view-tab {
    padding: 8px 16px;
    font-size: 11px;
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 0.3px;
    color: #666;
    cursor: pointer;
    border-bottom: 2px solid transparent;
    transition: all 0.15s;
    background: none;
    border-top: none;
    border-left: none;
    border-right: none;
    font-family: monospace;

    &:hover:not(&--disabled) { color: #aaa; }
    &--active { color: #e0e0e0; border-bottom-color: #e0e0e0; }
    &--disabled { color: #444; cursor: default; }
  }
  ```

**Verify:** All 6 tabs render. Layout/Power/List are clickable. Audio/MIDI/Control are grayed out. Switching to List shows existing table. Switching to Layout/Power shows placeholder text.

---

### Step 3: Build canvas infrastructure and localStorage extensions

**Goal:** Create the shared canvas base, product card component, and extend `WorkbenchContext` to store per-view positions.

**New files:**
- `apps/web/src/components/Workbench/CanvasBase.tsx` — Shared Konva `Stage` + `Layer` wrapper
- `apps/web/src/components/Workbench/ProductCard.tsx` — Konva `Group` with `Rect` + `Text` for a product

**localStorage schema extension:**

Currently `WorkbenchStore` is:
```typescript
{ workbenches: Workbench[], activeWorkbenchId: string }
```

Each `Workbench` gains a new optional field:
```typescript
export interface ViewPositions {
  [viewMode: string]: {             // 'layout' | 'power' | 'audio' | 'midi' | 'control'
    [productId: string]: {          // string key for JSON compat
      x: number;
      y: number;
    };
  };
}

export interface PowerConnection {
  id: string;                       // UUID
  sourceJackId: number;             // power output jack ID
  targetJackId: number;             // power input jack ID
  sourceProductId: number;          // supply product ID
  targetProductId: number;          // consumer product ID
  acknowledgedWarnings?: string[];  // warning keys the user has dismissed
}

export interface Workbench {
  // ... existing fields ...
  viewPositions?: ViewPositions;
  powerConnections?: PowerConnection[];
}
```

**New context methods:**
```typescript
// Position management
updateViewPosition: (view: string, productId: number, x: number, y: number) => void;
getViewPositions: (view: string) => Record<string, { x: number; y: number }>;

// Power connection management
addPowerConnection: (conn: Omit<PowerConnection, 'id'>) => void;
removePowerConnection: (connId: string) => void;
setPowerConnections: (conns: PowerConnection[]) => void;
acknowledgeWarning: (connId: string, warningKey: string) => void;
```

**CanvasBase component:**
```typescript
interface CanvasBaseProps {
  width: number;
  height: number;
  children: React.ReactNode;
  onStageClick?: (e: KonvaEventObject<MouseEvent>) => void;
}
```
- Renders `<Stage>` with a background `<Layer>` (dark fill) and a content `<Layer>` for children
- Handles resize via `ResizeObserver` on parent container to fill available space
- Passes stage dimensions up if needed

**ProductCard component (Konva):**
```typescript
interface ProductCardProps {
  row: WorkbenchRow;
  x: number;
  y: number;
  onDragEnd: (productId: number, x: number, y: number) => void;
  onClick?: (productId: number) => void;
  selected?: boolean;
  children?: React.ReactNode;  // For port dots in Power view
}
```
- Renders a Konva `<Group>` containing:
  - `<Rect>` with fill color based on `product_type` (reuse type-badge colors from SCSS)
  - `<Text>` for manufacturer name (top line, bold)
  - `<Text>` for model name (second line)
  - `<Text>` for dimensions if known (bottom line, small, muted)
- Draggable: `draggable={true}`, `onDragEnd` fires position update
- Card size: fixed width (e.g., 140px), height scales with content (~60-80px)

**Color map (matching existing `.type-badge` SCSS colors):**
```typescript
const TYPE_COLORS: Record<ProductType, { fill: string; stroke: string; text: string }> = {
  pedal:           { fill: '#1a2a1a', stroke: '#2a3a2a', text: '#6aaa6a' },
  power_supply:    { fill: '#2a2a1a', stroke: '#3a3a2a', text: '#aaaa5a' },
  pedalboard:      { fill: '#1a1a2a', stroke: '#2a2a3a', text: '#6a6aaa' },
  midi_controller: { fill: '#2a1a2a', stroke: '#3a2a3a', text: '#aa6aaa' },
  utility:         { fill: '#1a2a2a', stroke: '#2a3a3a', text: '#6aaaaa' },
};
```

**Default position calculation:**
When a product has no saved position for a view, assign it a default position in a grid layout:
```typescript
function defaultPosition(index: number, columns: number = 4): { x: number; y: number } {
  const col = index % columns;
  const row = Math.floor(index / columns);
  return { x: 20 + col * 160, y: 20 + row * 100 };
}
```

**Verify:** CanvasBase and ProductCard render correctly in isolation (can test by temporarily mounting in Layout placeholder). Cards are draggable. No position persistence yet (that connects in Step 4).

---

### Step 4: Implement Layout view

**Goal:** Full Layout view — draggable product cards on a free-form canvas with position persistence.

**New files:**
- `apps/web/src/components/Workbench/LayoutView.tsx`

**LayoutView component:**
```typescript
interface LayoutViewProps {
  rows: WorkbenchRow[];
}
```

**Behavior:**
1. Reads saved positions from `workbench.viewPositions?.layout` via context
2. For products with no saved position, assigns default grid position
3. Renders `<CanvasBase>` filling the `.workbench__content` area
4. Renders one `<ProductCard>` per `row` at its position
5. On drag end: calls `updateViewPosition('layout', productId, x, y)` to persist
6. Click on card: could highlight/select (optional for MVP — simple visual feedback)
7. Click on empty canvas: deselect

**Canvas sizing:**
- Uses a `ref` on the parent container + `ResizeObserver` to get available width/height
- Stage fills all available space (no fixed dimensions)

**Wire into `Workbench/index.tsx`:**
- Replace Layout placeholder with `<LayoutView rows={rows} />`
- Layout view doesn't show the sidebar or detail panel (full-width canvas)

**Verify:** Switch to Layout tab. All workbench products appear as cards. Drag a card, reload page — position is preserved. Switch to List and back — positions still correct.

---

### Step 5: Implement Power connection view — cards and ports

**Goal:** Power view rendering — supply cards with output port dots, consumer cards with power input port dots. No connection interaction yet.

**New files:**
- `apps/web/src/components/Workbench/PowerView.tsx`
- `apps/web/src/components/Workbench/PortDot.tsx`

**PortDot component (Konva):**
```typescript
interface PortDotProps {
  x: number;            // relative to parent Group
  y: number;
  jackId: number;
  label: string;        // e.g., "9V 500mA" or "Power In"
  direction: 'output' | 'input';
  color?: string;       // green/yellow/red based on connection status
  onMouseDown?: (jackId: number, e: KonvaEventObject<MouseEvent>) => void;
  onClick?: (jackId: number) => void;
  onMouseEnter?: (jackId: number) => void;
  onMouseLeave?: () => void;
}
```
- Renders a small circle (r=6) with a label to the right/left depending on direction
- Output dots: right side of supply card
- Input dots: left side of consumer card
- Hover: slightly larger circle, brighter color
- Visual: filled circle with 1px stroke

**PowerView component:**
```typescript
interface PowerViewProps {
  rows: WorkbenchRow[];
}
```

**Rendering logic:**
1. Call `extractPowerData(rows)` (from Step 1) to get `consumers[]` and `supplies[]`
2. Read saved positions from `workbench.viewPositions?.power`
3. For products with no position, use a two-column default layout:
   - Supplies on the left (x=40), stacked vertically
   - Consumers on the right (x=400+), stacked vertically
   - Supply cards are taller (more ports to show)
4. Render supply cards:
   - Extended `<ProductCard>` with `<PortDot>` children for each output jack
   - Port dots stacked vertically along the right edge
   - Each labeled with voltage + current_ma (e.g., "9V 500mA")
   - Isolated outputs get a small indicator (filled vs hollow dot)
5. Render consumer cards:
   - `<ProductCard>` with a single `<PortDot>` for the power input jack
   - Port dot on the left edge, labeled with voltage + current_ma requirement
6. Cards are draggable (positions persist like Layout view, but to `viewPositions.power`)

**Verify:** Switch to Power tab. Supplies appear on left with port dots per output. Consumers appear on right with power input dot. Cards are draggable. No connections drawn yet.

---

### Step 6: Implement Power connection view — connections and interaction

**Goal:** Connection drawing, creation (drag + click-click), removal, and validation with color coding.

**New files:**
- `apps/web/src/components/Workbench/ConnectionLine.tsx`

**ConnectionLine component (Konva):**
```typescript
interface ConnectionLineProps {
  sourceX: number;
  sourceY: number;
  targetX: number;
  targetY: number;
  status: 'valid' | 'warning' | 'error';
  acknowledged?: boolean;  // warning was acknowledged
  onClick?: () => void;
  selected?: boolean;
}
```
- Renders a Konva `<Line>` (or `<Arrow>`) between two points
- Color by status: `valid` = `#6aaa6a`, `warning` = `#d4a55a`, `error` = `#cc6060`
- Acknowledged warnings: dashed line, muted yellow
- Selected: thicker stroke, brighter color
- Line path: cubic bezier (use Konva `bezier: true` with tension) for clean curves
- Click on line to select it (for deletion)

**Connection interaction state** (local to PowerView, not in context):
```typescript
interface ConnectionState {
  pendingSource: { jackId: number; productId: number; x: number; y: number } | null;
  hoveredJackId: number | null;
  selectedConnectionId: string | null;
  mousePos: { x: number; y: number } | null;  // for drag preview line
}
```

**Creating connections — drag mode:**
1. `onMouseDown` on a PortDot → set `pendingSource`
2. `onMouseMove` on Stage → draw a preview line from source to cursor
3. `onMouseUp` on a compatible PortDot → create connection via `addPowerConnection()`
4. `onMouseUp` on empty canvas → cancel (clear `pendingSource`)
5. Validation: only allow connecting output→input or input→output (not output→output)

**Creating connections — click-click mode:**
1. Click a PortDot → set `pendingSource`
2. Click another PortDot → if compatible direction, create connection
3. Click same dot or empty canvas → cancel
4. Visual: source dot gets a highlight ring while pending

**Removing connections:**
1. Click a connection line to select it
2. Press Delete/Backspace → calls `removePowerConnection(connId)`
3. Alternative: right-click context (just show a "Remove" option) — or keep it simple with select+delete

**Connection validation** (determines green/yellow/red):
```typescript
function validateConnection(
  outputJack: Jack,
  inputJack: Jack,
): { status: 'valid' | 'warning' | 'error'; warnings: string[] }
```
- **Error (red):** voltage incompatible, insufficient current
- **Warning (yellow):** polarity mismatch (needs reversal cable), connector mismatch (needs adapter)
- **Valid (green):** everything matches

For daisy-chain validation (multiple connections to same output):
- Sum `current_ma` of all consumers connected to that output
- If sum > output's `current_ma`, mark all connections to that output as error
- Recalculate whenever a connection is added/removed

**Acknowledging warnings:**
- Click on a yellow connection line → shows a small popover/tooltip with warning details + "I have this adapter" button
- Clicking "I have this adapter" calls `acknowledgeWarning(connId, warningKey)`
- Acknowledged warnings: line changes to dashed muted yellow, warning icon removed

**Calculating line endpoints:**
Port dots have positions relative to their parent card Group. To get absolute canvas coordinates:
```typescript
function getPortAbsolutePosition(
  cardPosition: { x: number; y: number },
  portRelativePosition: { x: number; y: number },
): { x: number; y: number } {
  return {
    x: cardPosition.x + portRelativePosition.x,
    y: cardPosition.y + portRelativePosition.y,
  };
}
```
Recalculate whenever a card is dragged (positions change).

**Auto-assign button:**
- Floating button in corner of canvas: "Auto-assign"
- Calls `assignPedalsToOutputs(consumers, supplies)` (extracted in Step 1)
- Converts `AssignmentResult` into `PowerConnection[]` and calls `setPowerConnections()`
- If connections already exist, show confirm: "Replace existing connections?"

**Verify:** Create connections by drag and click-click. Lines render with correct colors. Delete connections. Daisy-chain: connect two pedals to same output, see combined current. Auto-assign button populates connections. Yellow warnings can be acknowledged. All connections persist across reload.

---

### Step 7: Tests and cleanup

**Goal:** Add tests for new components and utilities. Clean up any rough edges.

**Test files:**
- `apps/web/src/__tests__/utils/powerAssignment.test.ts`
  - `extractPowerData()` with various row combos
  - `assignPedalsToOutputs()` — sufficient/insufficient/no-supply scenarios
  - `computeDaisyChainGroups()` — grouping logic
  - `validateConnection()` — green/yellow/red cases
- `apps/web/src/__tests__/components/Workbench/ViewNav.test.tsx`
  - Renders all 6 tabs
  - Active tab has correct class
  - Disabled tabs don't fire `onViewChange`
  - Clicking enabled tab fires `onViewChange`
- `apps/web/src/__tests__/components/Workbench/PowerView.test.tsx` (if feasible with Konva in jsdom — may need `jest-canvas-mock` or `canvas` package)

**Note on Konva testing:** Konva requires a canvas implementation in test environments. Options:
- Install `canvas` npm package (native dependency, may be complex on macOS 13)
- Install `jest-canvas-mock` (lighter, mocks Canvas API)
- Alternatively: test the logic/hooks separately from the Konva rendering, and skip Konva-specific render tests

**Cleanup:**
- Ensure PowerBudgetInsight still works identically after refactor
- Verify no regressions in List view
- Check localStorage migration: old workbenches without `viewPositions` or `powerConnections` should work fine (optional fields default to `undefined`)

**Verify:** `npm run web:build` passes. `npm run web:test` passes. Manual end-to-end walkthrough of all views.
