import { useRef, useState, useEffect, ReactNode } from 'react';
import { Stage, Layer, Rect } from 'react-konva';
import Konva from 'konva';

interface CanvasBaseProps {
  children: ReactNode;
  scale?: number;
  offsetX?: number;
  offsetY?: number;
  onStageClick?: (e: Konva.KonvaEventObject<MouseEvent>) => void;
  onStageMouseMove?: (e: Konva.KonvaEventObject<MouseEvent>) => void;
  onStageMouseUp?: (e: Konva.KonvaEventObject<MouseEvent>) => void;
  onWheel?: (e: Konva.KonvaEventObject<WheelEvent>) => void;
  onTouchMove?: (e: Konva.KonvaEventObject<TouchEvent>) => void;
  onTouchEnd?: (e: Konva.KonvaEventObject<TouchEvent>) => void;
  onStageDragEnd?: (e: Konva.KonvaEventObject<DragEvent>) => void;
  onDimensionsChange?: (width: number, height: number) => void;
}

/**
 * Shared Konva canvas wrapper that auto-sizes to fill its parent container.
 * Supports zoom (via scale) and pan (via offset + Stage dragging).
 * Renders a dark background layer and a content layer for children.
 */
const CanvasBase = ({
  children,
  scale = 1,
  offsetX = 0,
  offsetY = 0,
  onStageClick,
  onStageMouseMove,
  onStageMouseUp,
  onWheel,
  onTouchMove,
  onTouchEnd,
  onStageDragEnd,
  onDimensionsChange,
}: CanvasBaseProps) => {
  const containerRef = useRef<HTMLDivElement>(null);
  const [dimensions, setDimensions] = useState({ width: 800, height: 600 });

  useEffect(() => {
    const container = containerRef.current;
    if (!container) return;

    const updateSize = () => {
      const w = container.clientWidth;
      const h = container.clientHeight;
      setDimensions({ width: w, height: h });
      onDimensionsChange?.(w, h);
    };

    updateSize();

    const observer = new ResizeObserver(updateSize);
    observer.observe(container);
    return () => observer.disconnect();
  }, [onDimensionsChange]);

  return (
    <div ref={containerRef} style={{ width: '100%', height: '100%' }}>
      {/* @ts-expect-error react-konva v18 types don't include children prop on Stage */}
      <Stage
        width={dimensions.width}
        height={dimensions.height}
        scaleX={scale}
        scaleY={scale}
        x={offsetX}
        y={offsetY}
        draggable
        onClick={onStageClick}
        onTap={onStageClick}
        onMouseMove={onStageMouseMove}
        onMouseUp={onStageMouseUp}
        onWheel={onWheel}
        onTouchMove={onTouchMove}
        onTouchEnd={onTouchEnd}
        onDragEnd={onStageDragEnd}
      >
        <Layer>
          <Rect
            x={-offsetX / scale}
            y={-offsetY / scale}
            width={dimensions.width / scale}
            height={dimensions.height / scale}
            fill="#111"
          />
        </Layer>
        <Layer>
          {children}
        </Layer>
      </Stage>
    </div>
  );
};

export { CanvasBase as default };
export type { CanvasBaseProps };
