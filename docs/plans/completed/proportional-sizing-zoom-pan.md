# Proportional Card Sizing, Zoom/Pan, and Auto-Fit for Workbench Canvas

## Context

The Layout and Power canvas views currently render all products as fixed 140×64 pixel cards with no zoom or pan capability. Users can't see relative pedal sizes, can't zoom in on dense layouts, and can't zoom out to see everything at once. This feature adds:

1. **Proportional card sizing** in the Layout view — cards sized based on real product dimensions (width_mm × depth_mm)
2. **Zoom/pan** in both views — mouse wheel zoom, click-drag pan, pinch-to-zoom on touch
3. **Auto-fit viewport** — zoom/pan to fit all cards on initial load and via a "fit all" button

Proportional sizing applies to Layout view only. Power view keeps fixed-size cards since its port dot positions are tightly coupled to card dimensions.

## Implementation Steps

### Step 1: Viewport state in WorkbenchContext

**File:** `apps/web/src/context/WorkbenchContext.tsx`

Add `viewportStates` to the `Workbench` interface, following the same pattern as `viewPositions`:

```typescript
export interface Workbench {
  // ... existing fields
  viewportStates?: {
    [viewKey: string]: { scale: number; offsetX: number; offsetY: number };
  };
}
```

Add two context methods (mirroring `getViewPositions` / `updateViewPosition`):
- `getViewportState(view: string): { scale: number; offsetX: number; offsetY: number }`
- `updateViewportState(view: string, state: { scale: number; offsetX: number; offsetY: number }): void`

Update `WorkbenchContextType` interface and the `value` memo.

### Step 2: Canvas viewport hook

**New file:** `apps/web/src/hooks/useCanvasViewport.ts`

A custom hook managing zoom/pan state for a named view key.

**State:** `{ scale, offsetX, offsetY }` — initialized from `getViewportState(viewKey)`, defaults to `{ scale: 1, offsetX: 0, offsetY: 0 }`.

**Key functions:**
- `handleWheel(e: KonvaEventObject<WheelEvent>)` — zoom centered on cursor. `newScale = oldScale * (e.evt.deltaY > 0 ? 0.9 : 1.1)`, clamped to [0.15, 4.0]. Adjusts offset to keep cursor point fixed in world space.
- `handlePinch(e: KonvaEventObject<TouchEvent>)` — two-finger zoom centered on midpoint. Track distance between touches, compute scale delta.
- `handleStageDragEnd(e: KonvaEventObject<DragEvent>)` — update offset from Stage position after pan drag.
- `screenToWorld(screenX, screenY)` — `{ x: (screenX - offsetX) / scale, y: (screenY - offsetY) / scale }`
- `worldToScreen(worldX, worldY)` — `{ x: worldX * scale + offsetX, y: worldY * scale + offsetY }`
- `fitAll(bbox, stageWidth, stageHeight)` — compute scale and offset to fit bounding box with padding, update state.
- `zoomIn()` / `zoomOut()` — step zoom by 1.25x / 0.8x centered on viewport center.

**Persistence:** Debounce saves to context (200ms) to avoid excessive localStorage writes during wheel zoom. Save immediately on unmount.

### Step 3: Canvas utilities

**New file:** `apps/web/src/utils/canvasUtils.ts`

```typescript
interface BoundingBox { minX: number; minY: number; maxX: number; maxY: number; }
interface ViewportState { scale: number; offsetX: number; offsetY: number; }

function calculateBoundingBox(
  cards: Array<{ x: number; y: number; width: number; height: number }>
): BoundingBox;

function calculateFitViewport(
  bbox: BoundingBox,
  stageWidth: number,
  stageHeight: number,
  padding?: number,    // default 40
  minScale?: number,   // default 0.15
  maxScale?: number,   // default 2.0
): ViewportState;
```

### Step 4: CanvasBase — zoom/pan support

**File:** `apps/web/src/components/Workbench/CanvasBase.tsx`

Add new props:
```typescript
interface CanvasBaseProps {
  children: ReactNode;
  scale?: number;            // default 1
  offsetX?: number;          // default 0
  offsetY?: number;          // default 0
  onWheel?: (e: Konva.KonvaEventObject<WheelEvent>) => void;
  onTouchMove?: (e: Konva.KonvaEventObject<TouchEvent>) => void;
  onTouchEnd?: (e: Konva.KonvaEventObject<TouchEvent>) => void;
  onStageDragEnd?: (e: Konva.KonvaEventObject<DragEvent>) => void;
  onStageClick?: ...;        // existing
  onStageMouseMove?: ...;    // existing
  onStageMouseUp?: ...;      // existing
}
```

Stage changes:
- Add `scaleX={scale}`, `scaleY={scale}`, `x={offsetX}`, `y={offsetY}`
- Add `draggable` for pan (Konva correctly delegates — child Group drag takes priority over Stage drag)
- Wire `onWheel`, `onTouchMove`, `onTouchEnd`, `onDragEnd` to props
- Background Rect: cover visible area regardless of zoom — position at `(-offsetX/scale, -offsetY/scale)` with size `(stageWidth/scale, stageHeight/scale)`
- Expose `stageWidth` and `stageHeight` via a callback or ref so views can calculate fit-all

Also expose the container dimensions to parent via a callback prop:
```typescript
onDimensionsChange?: (width: number, height: number) => void;
```

### Step 5: Zoom controls component

**New file:** `apps/web/src/components/Workbench/ZoomControls.tsx`

A small floating button group positioned absolute in the bottom-right of the canvas container.

Buttons: **+** (zoom in), **−** (zoom out), **Fit** (fit all)
Displays current zoom percentage (e.g., "75%").

Styled to match existing `workbench__power-action-btn` pattern. Add styles to `apps/web/src/components/Workbench/index.scss`.

### Step 6: ProductCard — variable width support

**File:** `apps/web/src/components/Workbench/ProductCard.tsx`

Add `cardWidth?: number` prop. Use `const width = cardWidth ?? CARD_WIDTH` throughout:
- Background Rect width
- Text element widths: `width - 16` (existing pattern with `CARD_WIDTH - 16`)
- Hide type label row if card height < 55 (avoids text overflow on short cards)

Keep `CARD_WIDTH` and `CARD_HEIGHT` exports unchanged — PowerView still uses them.

### Step 7: LayoutView — proportional sizing + zoom/pan

**File:** `apps/web/src/components/Workbench/LayoutView.tsx`

**Proportional sizing:**
```typescript
const MM_TO_PX = 1.0;  // 1mm = 1 world pixel
const MIN_CARD_WIDTH = 100;
const MIN_CARD_HEIGHT = 50;
const DEFAULT_CARD_WIDTH = 140;
const DEFAULT_CARD_HEIGHT = 64;

function cardDimensions(row: WorkbenchRow): { width: number; height: number } {
  if (row.width_mm != null && row.depth_mm != null) {
    return {
      width: Math.max(row.width_mm * MM_TO_PX, MIN_CARD_WIDTH),
      height: Math.max(row.depth_mm * MM_TO_PX, MIN_CARD_HEIGHT),
    };
  }
  return { width: DEFAULT_CARD_WIDTH, height: DEFAULT_CARD_HEIGHT };
}
```

Mapping: `width_mm` (side-to-side) → card width, `depth_mm` (front-to-back) → card height. This is a top-down view.

**Dynamic grid default positions:** Replace fixed 4-column grid with a flow layout that accounts for variable card sizes. Wrap to next row when cumulative width exceeds a threshold (e.g., 800px). Gap of 20px between cards.

**Zoom/pan integration:**
- Use `useCanvasViewport('layout')` hook
- Pass scale/offset/handlers to CanvasBase
- Pass `cardWidth`/`cardHeight` to each ProductCard
- Auto-fit on first render when no saved viewport exists
- Render `ZoomControls` alongside the canvas

### Step 8: PowerView — zoom/pan only

**File:** `apps/web/src/components/Workbench/PowerView.tsx`

No proportional sizing — cards stay at fixed CARD_WIDTH/CARD_HEIGHT.

**Zoom/pan integration:**
- Use `useCanvasViewport('power')` hook
- Pass scale/offset/handlers to CanvasBase
- Fix `handleStageMouseMove` — convert `stage.getPointerPosition()` to world coords via `screenToWorld` for the connection preview line
- Fix HTML overlays (floating delete button, warning popover) — convert world-coordinate port positions to screen coords via `worldToScreen` for CSS positioning
- Render `ZoomControls`

### Step 9: Build, test, verify

## Files to Create/Modify

| File | Change |
|------|--------|
| `apps/web/src/context/WorkbenchContext.tsx` | Add `viewportStates`, get/update methods |
| `apps/web/src/hooks/useCanvasViewport.ts` | **NEW** — zoom/pan state hook |
| `apps/web/src/utils/canvasUtils.ts` | **NEW** — bounding box, fit-all calculations |
| `apps/web/src/components/Workbench/CanvasBase.tsx` | Add scale/offset/drag/wheel/touch props |
| `apps/web/src/components/Workbench/ZoomControls.tsx` | **NEW** — zoom +/-, fit-all buttons |
| `apps/web/src/components/Workbench/ProductCard.tsx` | Add `cardWidth` prop |
| `apps/web/src/components/Workbench/LayoutView.tsx` | Proportional sizing, dynamic grid, zoom/pan |
| `apps/web/src/components/Workbench/PowerView.tsx` | Zoom/pan, screenToWorld fixes |
| `apps/web/src/components/Workbench/index.scss` | ZoomControls styles |

## Verification

1. `npm run web:build` — no TypeScript errors
2. `npm run web:test` — existing tests pass
3. Manual testing — Layout view:
   - Cards sized proportionally (large pedal = large card, small pedal = small card)
   - Products with unknown dimensions show default size
   - Mouse wheel zooms centered on cursor
   - Click-drag on empty canvas pans
   - Pinch-to-zoom on touch device
   - +/- buttons zoom in/out, "Fit" button fits all cards
   - Zoom level persists across view switches and page refresh
   - Dragging cards still works correctly at all zoom levels
4. Manual testing — Power view:
   - Zoom/pan works same as Layout
   - Connection lines and port dots render correctly at all zoom levels
   - Creating connections works (preview line follows cursor correctly)
   - Floating delete button and warning popover positioned correctly at all zoom levels
