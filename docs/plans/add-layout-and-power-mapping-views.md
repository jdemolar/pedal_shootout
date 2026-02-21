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
