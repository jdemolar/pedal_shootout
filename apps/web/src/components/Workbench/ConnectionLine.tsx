import { Line } from 'react-konva';

const STATUS_COLORS = {
  valid: '#6aaa6a',
  warning: '#d4a55a',
  error: '#cc6060',
};

const ACKNOWLEDGED_COLOR = '#8a7a3a';

interface ConnectionLineProps {
  sourceX: number;
  sourceY: number;
  targetX: number;
  targetY: number;
  status: 'valid' | 'warning' | 'error';
  acknowledged?: boolean;
  onClick?: () => void;
  selected?: boolean;
}

/**
 * A connection line between two port dots on the Power canvas.
 * Renders a cubic bezier curve colored by validation status.
 */
const ConnectionLine = ({
  sourceX,
  sourceY,
  targetX,
  targetY,
  status,
  acknowledged = false,
  onClick,
  selected = false,
}: ConnectionLineProps) => {
  const color = acknowledged ? ACKNOWLEDGED_COLOR : STATUS_COLORS[status];
  const strokeWidth = selected ? 3 : 2;

  // Bezier control point offset — curve bows out horizontally
  const dx = Math.abs(targetX - sourceX) * 0.4;

  return (
    <Line
      points={[sourceX, sourceY, sourceX + dx, sourceY, targetX - dx, targetY, targetX, targetY]}
      stroke={color}
      strokeWidth={strokeWidth}
      bezier
      dash={acknowledged ? [6, 4] : undefined}
      hitStrokeWidth={12}
      onClick={onClick}
      onTap={onClick}
      shadowColor={selected ? color : undefined}
      shadowBlur={selected ? 8 : 0}
      shadowOpacity={selected ? 0.5 : 0}
    />
  );
};

export default ConnectionLine;
