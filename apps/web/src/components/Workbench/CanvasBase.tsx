import { useRef, useState, useEffect, ReactNode } from 'react';
import { Stage, Layer, Rect } from 'react-konva';
import Konva from 'konva';

interface CanvasBaseProps {
  children: ReactNode;
  onStageClick?: (e: Konva.KonvaEventObject<MouseEvent>) => void;
  onStageMouseMove?: (e: Konva.KonvaEventObject<MouseEvent>) => void;
  onStageMouseUp?: (e: Konva.KonvaEventObject<MouseEvent>) => void;
}

/**
 * Shared Konva canvas wrapper that auto-sizes to fill its parent container.
 * Renders a dark background layer and a content layer for children.
 */
const CanvasBase = ({ children, onStageClick, onStageMouseMove, onStageMouseUp }: CanvasBaseProps) => {
  const containerRef = useRef<HTMLDivElement>(null);
  const [dimensions, setDimensions] = useState({ width: 800, height: 600 });

  useEffect(() => {
    const container = containerRef.current;
    if (!container) return;

    const updateSize = () => {
      setDimensions({
        width: container.clientWidth,
        height: container.clientHeight,
      });
    };

    updateSize();

    const observer = new ResizeObserver(updateSize);
    observer.observe(container);
    return () => observer.disconnect();
  }, []);

  return (
    <div ref={containerRef} style={{ width: '100%', height: '100%' }}>
      {/* @ts-expect-error react-konva v18 types don't include children prop on Stage */}
      <Stage
        width={dimensions.width}
        height={dimensions.height}
        onClick={onStageClick}
        onMouseMove={onStageMouseMove}
        onMouseUp={onStageMouseUp}
      >
        <Layer>
          <Rect
            x={0}
            y={0}
            width={dimensions.width}
            height={dimensions.height}
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

export default CanvasBase;
