import { useState, useCallback, useEffect, useRef } from 'react';
import { useWorkbench } from '../../context/WorkbenchContext';
import { WorkbenchRow } from './WorkbenchTable';
import { useCanvasViewport } from '../../hooks/useCanvasViewport';
import { calculateBoundingBox } from '../../utils/canvasUtils';
import CanvasBase from './CanvasBase';
import ProductCard, { CARD_WIDTH, CARD_HEIGHT } from './ProductCard';
import ZoomControls from './ZoomControls';

const VIEW_KEY = 'layout';

/** 1mm = 1 world pixel. Cards are sized proportionally to real dimensions. */
const MM_TO_PX = 1.0;
const MIN_CARD_WIDTH = 100;
const MIN_CARD_HEIGHT = 50;
const DEFAULT_CARD_WIDTH = CARD_WIDTH;   // 140
const DEFAULT_CARD_HEIGHT = CARD_HEIGHT; // 64

/** Flow layout constants for default positions */
const FLOW_MAX_WIDTH = 800;
const FLOW_GAP = 20;
const FLOW_OFFSET_X = 20;
const FLOW_OFFSET_Y = 20;

/** Compute card dimensions from product's real-world size (top-down view). */
function cardDimensions(row: WorkbenchRow): { width: number; height: number } {
  if (row.width_mm != null && row.depth_mm != null) {
    return {
      width: Math.max(row.width_mm * MM_TO_PX, MIN_CARD_WIDTH),
      height: Math.max(row.depth_mm * MM_TO_PX, MIN_CARD_HEIGHT),
    };
  }
  return { width: DEFAULT_CARD_WIDTH, height: DEFAULT_CARD_HEIGHT };
}

/**
 * Compute default flow-layout positions for cards with variable sizes.
 * Wraps to a new row when cumulative width exceeds FLOW_MAX_WIDTH.
 */
function computeFlowPositions(
  rows: WorkbenchRow[],
): Map<string, { x: number; y: number }> {
  const map = new Map<string, { x: number; y: number }>();
  let cursorX = FLOW_OFFSET_X;
  let cursorY = FLOW_OFFSET_Y;
  let rowHeight = 0;

  for (const row of rows) {
    const dims = cardDimensions(row);

    // Wrap to next row if this card exceeds the max width
    if (cursorX + dims.width > FLOW_MAX_WIDTH + FLOW_OFFSET_X && cursorX > FLOW_OFFSET_X) {
      cursorX = FLOW_OFFSET_X;
      cursorY += rowHeight + FLOW_GAP;
      rowHeight = 0;
    }

    map.set(row.instanceId, { x: cursorX, y: cursorY });
    cursorX += dims.width + FLOW_GAP;
    rowHeight = Math.max(rowHeight, dims.height);
  }

  return map;
}

interface LayoutViewProps {
  rows: WorkbenchRow[];
}

const LayoutView = ({ rows }: LayoutViewProps) => {
  const { getViewPositions, updateViewPosition } = useWorkbench();
  const savedPositions = getViewPositions(VIEW_KEY);

  const viewport = useCanvasViewport(VIEW_KEY);
  const [stageDims, setStageDims] = useState({ width: 800, height: 600 });
  const hasAutoFit = useRef(false);

  const handleDimensionsChange = useCallback((width: number, height: number) => {
    setStageDims({ width, height });
  }, []);

  // Compute flow-layout default positions for cards without saved positions
  const flowDefaults = computeFlowPositions(rows);

  const getPosition = (instanceId: string) => {
    const saved = savedPositions[instanceId];
    if (saved) return saved;
    return flowDefaults.get(instanceId) || { x: FLOW_OFFSET_X, y: FLOW_OFFSET_Y };
  };

  const handleDragEnd = (instanceId: string, x: number, y: number) => {
    updateViewPosition(VIEW_KEY, instanceId, x, y);
  };

  // Auto-fit on first render when no saved viewport exists
  useEffect(() => {
    if (hasAutoFit.current || rows.length === 0) return;
    // Only auto-fit if the viewport is at default (no saved state)
    const saved = viewport.scale === 1 && viewport.offsetX === 0 && viewport.offsetY === 0;
    if (!saved) { hasAutoFit.current = true; return; }

    const cards = rows.map(row => {
      const pos = getPosition(row.instanceId);
      const dims = cardDimensions(row);
      return { x: pos.x, y: pos.y, width: dims.width, height: dims.height };
    });

    const bbox = calculateBoundingBox(cards);
    viewport.fitAll(bbox, stageDims.width, stageDims.height);
    hasAutoFit.current = true;
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [rows.length, stageDims.width, stageDims.height]);

  const handleFitAll = useCallback(() => {
    const cards = rows.map(row => {
      const pos = getPosition(row.instanceId);
      const dims = cardDimensions(row);
      return { x: pos.x, y: pos.y, width: dims.width, height: dims.height };
    });
    const bbox = calculateBoundingBox(cards);
    viewport.fitAll(bbox, stageDims.width, stageDims.height);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [rows, savedPositions, stageDims, viewport.fitAll]);

  if (rows.length === 0) {
    return (
      <div className="workbench__canvas-placeholder">
        Your workbench is empty. Add products from the catalog views.
      </div>
    );
  }

  return (
    <div style={{ position: 'relative', width: '100%', height: '100%' }}>
      <CanvasBase
        scale={viewport.scale}
        offsetX={viewport.offsetX}
        offsetY={viewport.offsetY}
        onWheel={viewport.handleWheel}
        onTouchMove={viewport.handleTouchMove}
        onTouchEnd={viewport.handleTouchEnd}
        onStageDragEnd={viewport.handleStageDragEnd}
        onDimensionsChange={handleDimensionsChange}
      >
        {rows.map((row) => {
          const pos = getPosition(row.instanceId);
          const dims = cardDimensions(row);
          return (
            <ProductCard
              key={row.instanceId}
              productType={row.product_type}
              manufacturer={row.manufacturer}
              model={row.model}
              x={pos.x}
              y={pos.y}
              cardWidth={dims.width}
              cardHeight={dims.height}
              onDragEnd={(x, y) => handleDragEnd(row.instanceId, x, y)}
            />
          );
        })}
      </CanvasBase>

      <ZoomControls
        scale={viewport.scale}
        onZoomIn={() => viewport.zoomIn(stageDims.width, stageDims.height)}
        onZoomOut={() => viewport.zoomOut(stageDims.width, stageDims.height)}
        onFitAll={handleFitAll}
      />
    </div>
  );
};

export default LayoutView;
