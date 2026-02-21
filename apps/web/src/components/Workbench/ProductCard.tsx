import { Group, Rect, Text } from 'react-konva';
import Konva from 'konva';
import { ProductType } from '../../context/WorkbenchContext';
import { ReactNode } from 'react';

/** Color scheme per product type, matching the existing .type-badge SCSS colors */
const TYPE_COLORS: Record<ProductType, { fill: string; stroke: string; text: string }> = {
  pedal:           { fill: '#1a2a1a', stroke: '#2a3a2a', text: '#6aaa6a' },
  power_supply:    { fill: '#2a2a1a', stroke: '#3a3a2a', text: '#aaaa5a' },
  pedalboard:      { fill: '#1a1a2a', stroke: '#2a2a3a', text: '#6a6aaa' },
  midi_controller: { fill: '#2a1a2a', stroke: '#3a2a3a', text: '#aa6aaa' },
  utility:         { fill: '#1a2a2a', stroke: '#2a3a3a', text: '#6aaaaa' },
};

export const CARD_WIDTH = 140;
export const CARD_HEIGHT = 64;

interface ProductCardProps {
  productType: ProductType;
  manufacturer: string;
  model: string;
  x: number;
  y: number;
  onDragEnd: (x: number, y: number) => void;
  onClick?: () => void;
  selected?: boolean;
  children?: ReactNode;
  /** Override card height (e.g., taller for supply cards with many ports) */
  cardHeight?: number;
}

/**
 * A draggable product card rendered on the Konva canvas.
 * Shows manufacturer name, model, and a colored border based on product type.
 */
const ProductCard = ({
  productType,
  manufacturer,
  model,
  x,
  y,
  onDragEnd,
  onClick,
  selected = false,
  children,
  cardHeight,
}: ProductCardProps) => {
  const colors = TYPE_COLORS[productType] || TYPE_COLORS.pedal;
  const height = cardHeight ?? CARD_HEIGHT;

  return (
    <Group
      x={x}
      y={y}
      draggable
      onDragEnd={(e: Konva.KonvaEventObject<DragEvent>) => {
        onDragEnd(e.target.x(), e.target.y());
      }}
      onClick={onClick}
      onTap={onClick}
    >
      {/* Card background */}
      <Rect
        width={CARD_WIDTH}
        height={height}
        fill={colors.fill}
        stroke={selected ? '#e0e0e0' : colors.stroke}
        strokeWidth={selected ? 2 : 1}
        cornerRadius={4}
        shadowColor={selected ? '#e0e0e0' : undefined}
        shadowBlur={selected ? 6 : 0}
        shadowOpacity={selected ? 0.3 : 0}
      />
      {/* Manufacturer */}
      <Text
        x={8}
        y={8}
        width={CARD_WIDTH - 16}
        text={manufacturer}
        fontSize={11}
        fontFamily="'Helvetica Neue', sans-serif"
        fontStyle="bold"
        fill="#f0f0f0"
        ellipsis
        wrap="none"
      />
      {/* Model */}
      <Text
        x={8}
        y={24}
        width={CARD_WIDTH - 16}
        text={model}
        fontSize={11}
        fontFamily="'SF Mono', 'Fira Code', monospace"
        fill={colors.text}
        ellipsis
        wrap="none"
      />
      {/* Type label */}
      <Text
        x={8}
        y={44}
        width={CARD_WIDTH - 16}
        text={productType.replace(/_/g, ' ')}
        fontSize={9}
        fontFamily="monospace"
        fill="#555"
        textTransform="uppercase"
      />
      {children}
    </Group>
  );
};

export default ProductCard;
