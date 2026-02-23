# Plan: Rotation and Z-Index for Layout View Cards

## Context

Product cards on the Layout canvas can be dragged but not rotated or reordered in depth. For pedalboard layout planning, users need to rotate pedals (e.g., turn a pedal sideways to fit) and control which card renders on top when cards overlap. These are todo items "Make objects rotateable" and "Enable objects to be sent forward or back on z-axis".

Both features apply to **LayoutView only** — PowerView uses fixed port-position offsets for connection lines, and rotation/z-ordering would break those calculations without significant rework.

## Files to modify

1. **`apps/web/src/context/WorkbenchContext.tsx`** — Extend position storage type, add `updateCardTransform` method
2. **`apps/web/src/components/Workbench/ProductCard.tsx`** — Add `rotation` prop with nested inner Group for center-pivot rotation
3. **`apps/web/src/components/Workbench/LayoutView.tsx`** — Add card selection, keyboard handlers, z-index sort, rotation passing, keyboard hints overlay
4. **`apps/web/src/utils/canvasUtils.ts`** — Rotation-aware bounding box for fit-all
5. **`apps/web/src/components/Workbench/index.scss`** — Keyboard hints overlay styles

## Implementation

### 1. Extend position storage (`WorkbenchContext.tsx`)

Change the position value type from `{ x: number; y: number }` to a named interface:

```typescript
export interface CardTransform {
  x: number;
  y: number;
  rotation?: number;  // degrees (0, 90, 180, 270). Default 0.
  zIndex?: number;    // layer order. Higher = on top. Default 0.
}
```

Update `ViewPositions`, `getViewPositions` return type, and `updateViewPosition` to use `CardTransform`. Existing localStorage data is backward-compatible since `rotation` and `zIndex` are optional.

Add a new `updateCardTransform(view, instanceId, patch: Partial<CardTransform>)` method that merges a partial update into the existing transform. This avoids overwriting rotation/zIndex on every drag-end (which only passes x/y). Expose it from the context.

Keep `updateViewPosition(view, instanceId, x, y)` as-is for drag-end calls — it only sets x/y and preserves existing rotation/zIndex by merging.

### 2. Add rotation to ProductCard (`ProductCard.tsx`)

Add `rotation?: number` prop. Use a **nested inner Group** for center-pivot rotation so the outer Group's `(x, y)` stays as top-left corner (backward-compatible with saved positions):

```
<Group x={x} y={y} draggable ...>        ← outer: position + drag
  <Group                                   ← inner: rotation around center
    rotation={rotation ?? 0}
    offsetX={width / 2}
    offsetY={height / 2}
    x={width / 2}
    y={height / 2}
  >
    <Rect .../> <Text .../> {children}
  </Group>
</Group>
```

The inner Group translates to center, sets offset to center, then rotates — producing center-pivot rotation. The outer Group is unaffected, so drag and position work identically to before.

### 3. Add selection + keyboard controls to LayoutView (`LayoutView.tsx`)

**Card selection:** Add `selectedId` state. Pass `selected` and `onClick` to each ProductCard. Add `onStageClick` to CanvasBase to deselect when clicking empty canvas.

**Keyboard shortcuts** (via `useEffect` + `keydown` listener, same pattern as PowerView):
- **R** — Rotate selected card +90 degrees
- **Shift+R** — Rotate selected card -90 degrees
- **]** — Bring to front (set zIndex to max + 1)
- **[** — Send to back (set zIndex to min - 1)
- **Escape** — Deselect
- **Delete/Backspace** — No action (avoid accidental deletion)

**Z-index rendering order:** Sort rows by `zIndex` (from saved positions) before mapping to `<ProductCard>`. Lower zIndex renders first (behind).

**Pass rotation:** Read `savedPositions[instanceId]?.rotation ?? 0` and pass to ProductCard.

**Keyboard hints overlay:** When a card is selected, show a small HTML bar at the top of the canvas with available shortcuts (R rotate, ] front, [ back, Esc deselect). Style as a translucent bar with `pointer-events: none`.

### 4. Rotation-aware bounding box (`canvasUtils.ts`)

Extend `calculateBoundingBox` to accept optional `rotation` on each card. When rotation is non-zero, compute the 4 rotated corners around the card center and expand the bounding box to contain them. When rotation is 0, use the fast path (current logic). Update both call sites in LayoutView to pass rotation.

### 5. Keyboard hints styles (`index.scss`)

Add `.workbench__canvas-hints` — positioned absolute at top-center, translucent dark background, monospace font, small text, `pointer-events: none`.

## What does NOT change

- **PowerView** — No rotation or z-index support (port positions depend on fixed card geometry)
- **CanvasBase** — Already supports `onStageClick`, no changes needed
- **WorkbenchItem** — Has an unused `rotation` field from Phase 2 planning; leave it as-is (positions are stored in `viewPositions`, not `WorkbenchItem`)

## Verification

1. `npm run web:build` — compilation passes
2. `npm run web:test` — all tests pass
3. Manual testing:
   - Click a card in Layout view → card shows selected state (border highlight)
   - Press R → card rotates 90 degrees, visually pivoting around center
   - Press R repeatedly → cycles through 0, 90, 180, 270
   - Press Shift+R → rotates in the opposite direction
   - Press ] → selected card renders on top of overlapping cards
   - Press [ → selected card renders behind overlapping cards
   - Drag a rotated card → card moves normally, rotation preserved
   - Fit-all (zoom controls) → correctly fits rotated cards
   - Refresh page → rotation and z-index persist from localStorage
   - PowerView → unaffected, no rotation controls available
