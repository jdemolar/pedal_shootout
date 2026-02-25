import { Line } from 'react-konva';
import Konva from 'konva';
import { RouteWaypoint } from '../../types/connections';

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
  onDblClick?: (e: Konva.KonvaEventObject<MouseEvent>) => void;
  selected?: boolean;
  waypoints?: RouteWaypoint[];
}

/**
 * A connection line between two port dots on a canvas view.
 * Renders a cubic bezier curve (no waypoints) or a polyline (with waypoints),
 * colored by validation status.
 */
const ConnectionLine = ({
  sourceX,
  sourceY,
  targetX,
  targetY,
  status,
  acknowledged = false,
  onClick,
  onDblClick,
  selected = false,
  waypoints,
}: ConnectionLineProps) => {
  const color = acknowledged ? ACKNOWLEDGED_COLOR : STATUS_COLORS[status];
  const strokeWidth = selected ? 3 : 2;

  const commonProps = {
    stroke: color,
    strokeWidth,
    dash: acknowledged ? [6, 4] : undefined,
    hitStrokeWidth: 12,
    onClick,
    onTap: onClick,
    onDblClick,
    onDblTap: onDblClick,
    shadowColor: selected ? color : undefined,
    shadowBlur: selected ? 8 : 0,
    shadowOpacity: selected ? 0.5 : 0,
  };

  if (waypoints && waypoints.length > 0) {
    // Polyline through all waypoints
    const pts: number[] = [sourceX, sourceY];
    for (const wp of waypoints) {
      pts.push(wp.x, wp.y);
    }
    pts.push(targetX, targetY);
    return <Line points={pts} {...commonProps} />;
  }

  // Bezier control point offset — curve bows out horizontally
  const dx = Math.abs(targetX - sourceX) * 0.4;
  return (
    <Line
      points={[sourceX, sourceY, sourceX + dx, sourceY, targetX - dx, targetY, targetX, targetY]}
      bezier
      {...commonProps}
    />
  );
};

export default ConnectionLine;
