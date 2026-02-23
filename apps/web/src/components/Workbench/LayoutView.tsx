import { useState, useCallback, useEffect, useRef, useMemo } from 'react';
import { useWorkbench, CardTransform } from '../../context/WorkbenchContext';
import { WorkbenchRow } from './WorkbenchTable';
import { useCanvasViewport } from '../../hooks/useCanvasViewport';
import { calculateBoundingBox } from '../../utils/canvasUtils';
import CanvasBase from './CanvasBase';
import ProductCard, { CARD_WIDTH, CARD_HEIGHT } from './ProductCard';
import ZoomControls from './ZoomControls';
import Konva from 'konva';

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
  const { getViewPositions, updateViewPosition, updateCardTransform } = useWorkbench();
  const savedPositions = getViewPositions(VIEW_KEY);

  const viewport = useCanvasViewport(VIEW_KEY);
  const [stageDims, setStageDims] = useState({ width: 800, height: 600 });
  const hasAutoFit = useRef(false);
  const [selectedId, setSelectedId] = useState<string | null>(null);

  const handleDimensionsChange = useCallback((width: number, height: number) => {
    setStageDims({ width, height });
  }, []);

  // Compute flow-layout default positions for cards without saved positions
  const flowDefaults = computeFlowPositions(rows);

  const getPosition = (instanceId: string): CardTransform => {
    const saved = savedPositions[instanceId];
    if (saved) return saved;
    const flow = flowDefaults.get(instanceId) || { x: FLOW_OFFSET_X, y: FLOW_OFFSET_Y };
    return { x: flow.x, y: flow.y };
  };

  const handleDragEnd = (instanceId: string, x: number, y: number) => {
    updateViewPosition(VIEW_KEY, instanceId, x, y);
  };

  const handleStageClick = useCallback((e: Konva.KonvaEventObject<MouseEvent>) => {
    if (e.target === e.target.getStage()) {
      setSelectedId(null);
    }
  }, []);

  // Sort rows by zIndex for render order (lower zIndex renders first = behind)
  const sortedRows = useMemo(() => {
    return [...rows].sort((a, b) => {
      const zA = savedPositions[a.instanceId]?.zIndex ?? 0;
      const zB = savedPositions[b.instanceId]?.zIndex ?? 0;
      return zA - zB;
    });
  }, [rows, savedPositions]);

  // Keyboard shortcuts
  const handleKeyDown = useCallback((e: KeyboardEvent) => {
    if (!selectedId) return;
    // Ignore when typing in an input
    if (e.target instanceof HTMLInputElement || e.target instanceof HTMLTextAreaElement) return;

    // Ensure current position is persisted (may be from flow defaults, not yet saved)
    const pos = getPosition(selectedId);

    if (e.key === 'r' || e.key === 'R') {
      e.preventDefault();
      const current = pos.rotation ?? 0;
      const delta = e.shiftKey ? -90 : 90;
      const next = ((current + delta) % 360 + 360) % 360;
      updateCardTransform(VIEW_KEY, selectedId, { x: pos.x, y: pos.y, rotation: next });
    } else if (e.key === ']') {
      e.preventDefault();
      const maxZ = rows.reduce((max, row) => Math.max(max, savedPositions[row.instanceId]?.zIndex ?? 0), 0);
      updateCardTransform(VIEW_KEY, selectedId, { x: pos.x, y: pos.y, zIndex: maxZ + 1 });
    } else if (e.key === '[') {
      e.preventDefault();
      const minZ = rows.reduce((min, row) => Math.min(min, savedPositions[row.instanceId]?.zIndex ?? 0), 0);
      updateCardTransform(VIEW_KEY, selectedId, { x: pos.x, y: pos.y, zIndex: minZ - 1 });
    } else if (e.key === 'Escape') {
      setSelectedId(null);
    }
  }, [selectedId, savedPositions, rows, updateCardTransform]);

  useEffect(() => {
    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [handleKeyDown]);

  // Deselect if the selected card is removed
  useEffect(() => {
    if (selectedId && !rows.some(r => r.instanceId === selectedId)) {
      setSelectedId(null);
    }
  }, [rows, selectedId]);

  // Auto-fit on first render when no saved viewport exists
  useEffect(() => {
    if (hasAutoFit.current || rows.length === 0) return;
    // Only auto-fit if the viewport is at default (no saved state)
    const saved = viewport.scale === 1 && viewport.offsetX === 0 && viewport.offsetY === 0;
    if (!saved) { hasAutoFit.current = true; return; }

    const cards = rows.map(row => {
      const pos = getPosition(row.instanceId);
      const dims = cardDimensions(row);
      return { x: pos.x, y: pos.y, width: dims.width, height: dims.height, rotation: pos.rotation ?? 0 };
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
      return { x: pos.x, y: pos.y, width: dims.width, height: dims.height, rotation: pos.rotation ?? 0 };
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
        onStageClick={handleStageClick}
        onDimensionsChange={handleDimensionsChange}
      >
        {sortedRows.map((row) => {
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
              rotation={pos.rotation ?? 0}
              selected={selectedId === row.instanceId}
              onClick={() => setSelectedId(row.instanceId)}
              onDragEnd={(x, y) => handleDragEnd(row.instanceId, x, y)}
            />
          );
        })}
      </CanvasBase>

      {selectedId && (
        <div className="workbench__canvas-hints">
          <kbd>R</kbd> rotate
          <kbd>⇧R</kbd> reverse
          <kbd>]</kbd> front
          <kbd>[</kbd> back
          <kbd>Esc</kbd> deselect
        </div>
      )}

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
