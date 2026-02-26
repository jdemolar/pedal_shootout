# Audio Cable Routing Waypoints

**Status:** Deferred — infrastructure exists, UI not exposed
**Created:** 2026-02-25

## What This Is

A hideable overlay on the **Layout view** that lets users draw audio cable routes between pedals using bend-point waypoints. This is distinct from the **Audio schematic view**, which shows signal chain topology without caring about physical cable paths.

Cable routing waypoints are useful for:
- Estimating cable lengths (waypoint path length × 1.2 slack ≈ cable length needed)
- Visualizing how cables run across a physical pedalboard
- Generating a cable shopping list with accurate lengths

## Why It's Deferred

To route cables realistically, port dots must be placed where the actual jack sockets are on the physical enclosure — e.g., input on the right side, output on the left. The current Layout view places port dots at arbitrary card positions (center-left for power input). Without per-pedal jack position data, cable paths would be misleading.

The Audio schematic view is a separate flow-diagram view where layout doesn't matter, so waypoints there add no value and were removed.

## Existing Infrastructure (already implemented)

These are already in the codebase and just need to be wired back up:

| Item | Location | Notes |
|---|---|---|
| `AudioConnection.waypoints` | `types/connections.ts` | `RouteWaypoint[]` field on every AudioConnection |
| `RouteWaypoint` type | `types/connections.ts` | `{ x: number; y: number }` |
| `ConnectionLine` waypoints prop | `components/Workbench/ConnectionLine.tsx` | Renders polyline when waypoints present, bezier when absent |
| `updateAudioConnectionWaypoints` | `WorkbenchContext.tsx` | CRUD method, already wired into context |

## What Still Needs to Be Built

### 1. Jack position data per product

The database needs a way to record where each jack physically sits on the enclosure. Options:
- `jacks.position` column already exists (currently stores e.g. `'left'`, `'right'`, `'top'`, `'bottom'`, `'front'`) — could be used to infer a relative x/y offset on the card
- Alternatively, a `jacks.position_x_pct` / `jacks.position_y_pct` pair (0.0–1.0, relative to enclosure face) would give precise placement

### 2. Port dot placement in Layout view

Today, Layout view cards don't show port dots at all. To support cable routing:
- Port dots need to appear on Layout view cards, positioned according to jack position data
- The `ProductCard` rotation feature (already implemented) makes this non-trivial — port dot world positions need to account for card rotation

### 3. Waypoint editing UI (same as what was removed from AudioView)

- **Add waypoint:** double-click a connection line → get world position → insert at nearest segment
- **Move waypoint:** when connection selected, render draggable `Circle` at each waypoint; drag to reposition
- **Remove waypoint:** double-click a waypoint circle

All of this logic was written in `AudioView.tsx` (`handleConnectionDblClick`, waypoint circles in the render) and can be ported to the Layout view overlay. It was removed from AudioView only — `ConnectionLine.tsx` still supports it.

### 4. Toggle UI

A "Show cable routing" toggle button in the Layout view toolbar. When off: no connection lines drawn. When on: audio (and optionally MIDI/control) connections rendered as waypointed lines over the layout.

### 5. Length estimation

With waypoints defined:
```
path_length = sum of segment lengths through [sourcePort, ...waypoints, targetPort]
cable_length = path_length × 1.2  // 20% slack
```
Surface this in the unified shopping list (future feature).

## Relationship to Other Features

- **Unified shopping list** — cable lengths from waypoints feed into length estimates on the shopping list
- **Layout view** — this feature lives here, not in the Audio schematic view
- **Audio schematic view** — deliberately has no waypoints; `AudioConnection.waypoints` will always be `[]` for connections created there
