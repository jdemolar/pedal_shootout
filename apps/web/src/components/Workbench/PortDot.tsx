import { useState } from 'react';
import { Circle, Text, Group } from 'react-konva';
import Konva from 'konva';

interface PortDotProps {
  x: number;
  y: number;
  jackId: number;
  label: string;
  direction: 'output' | 'input';
  color?: string;
  isolated?: boolean;
  onMouseDown?: (jackId: number, e: Konva.KonvaEventObject<MouseEvent>) => void;
  onClick?: (jackId: number) => void;
  onMouseEnter?: (jackId: number) => void;
  onMouseLeave?: () => void;
}

const DOT_RADIUS = 6;
const HOVER_RADIUS = 8;

/**
 * A small clickable port circle rendered on a ProductCard.
 * Output dots sit on the right side of supply cards.
 * Input dots sit on the left side of consumer cards.
 */
const PortDot = ({
  x,
  y,
  jackId,
  label,
  direction,
  color = '#6aaa6a',
  isolated = true,
  onMouseDown,
  onClick,
  onMouseEnter,
  onMouseLeave,
}: PortDotProps) => {
  const [hovered, setHovered] = useState(false);
  const radius = hovered ? HOVER_RADIUS : DOT_RADIUS;

  const isOutput = direction === 'output';
  const labelX = isOutput ? DOT_RADIUS + 6 : -(DOT_RADIUS + 6);
  const labelAlign = isOutput ? 'left' : 'right';

  return (
    <Group x={x} y={y}>
      <Circle
        radius={radius}
        fill={isolated ? color : undefined}
        stroke={color}
        strokeWidth={isolated ? 1 : 2}
        onMouseEnter={() => {
          setHovered(true);
          onMouseEnter?.(jackId);
        }}
        onMouseLeave={() => {
          setHovered(false);
          onMouseLeave?.();
        }}
        onMouseDown={(e: Konva.KonvaEventObject<MouseEvent>) => {
          onMouseDown?.(jackId, e);
        }}
        onClick={() => onClick?.(jackId)}
        onTap={() => onClick?.(jackId)}
      />
      <Text
        x={isOutput ? labelX : labelX - 100}
        y={-5}
        width={100}
        text={label}
        fontSize={9}
        fontFamily="monospace"
        fill="#999"
        align={labelAlign}
        listening={false}
      />
    </Group>
  );
};

export default PortDot;
