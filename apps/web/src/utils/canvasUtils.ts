/**
 * Canvas viewport utility functions for bounding box and fit-to-view calculations.
 */

export interface BoundingBox {
  minX: number;
  minY: number;
  maxX: number;
  maxY: number;
}

export interface ViewportState {
  scale: number;
  offsetX: number;
  offsetY: number;
}

/**
 * Compute the axis-aligned bounding box around a set of positioned cards.
 */
export function calculateBoundingBox(
  cards: Array<{ x: number; y: number; width: number; height: number }>,
): BoundingBox {
  if (cards.length === 0) {
    return { minX: 0, minY: 0, maxX: 0, maxY: 0 };
  }

  let minX = Infinity;
  let minY = Infinity;
  let maxX = -Infinity;
  let maxY = -Infinity;

  for (const card of cards) {
    minX = Math.min(minX, card.x);
    minY = Math.min(minY, card.y);
    maxX = Math.max(maxX, card.x + card.width);
    maxY = Math.max(maxY, card.y + card.height);
  }

  return { minX, minY, maxX, maxY };
}

/**
 * Compute the scale and offset needed to fit a bounding box within the stage,
 * centered with padding.
 */
export function calculateFitViewport(
  bbox: BoundingBox,
  stageWidth: number,
  stageHeight: number,
  padding = 40,
  minScale = 0.15,
  maxScale = 2.0,
): ViewportState {
  const contentWidth = bbox.maxX - bbox.minX;
  const contentHeight = bbox.maxY - bbox.minY;

  if (contentWidth <= 0 || contentHeight <= 0) {
    return { scale: 1, offsetX: 0, offsetY: 0 };
  }

  const availableWidth = stageWidth - padding * 2;
  const availableHeight = stageHeight - padding * 2;

  const scaleX = availableWidth / contentWidth;
  const scaleY = availableHeight / contentHeight;
  const scale = Math.max(minScale, Math.min(maxScale, Math.min(scaleX, scaleY)));

  // Center the content
  const offsetX = (stageWidth - contentWidth * scale) / 2 - bbox.minX * scale;
  const offsetY = (stageHeight - contentHeight * scale) / 2 - bbox.minY * scale;

  return { scale, offsetX, offsetY };
}
