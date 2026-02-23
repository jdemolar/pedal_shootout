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
 * Supports optional rotation (degrees) per card — when non-zero, the 4 corners
 * are rotated around the card center and the AABB is expanded to contain them.
 */
export function calculateBoundingBox(
  cards: Array<{ x: number; y: number; width: number; height: number; rotation?: number }>,
): BoundingBox {
  if (cards.length === 0) {
    return { minX: 0, minY: 0, maxX: 0, maxY: 0 };
  }

  let minX = Infinity;
  let minY = Infinity;
  let maxX = -Infinity;
  let maxY = -Infinity;

  for (const card of cards) {
    const rot = card.rotation ?? 0;

    if (rot === 0) {
      // Fast path — no rotation
      minX = Math.min(minX, card.x);
      minY = Math.min(minY, card.y);
      maxX = Math.max(maxX, card.x + card.width);
      maxY = Math.max(maxY, card.y + card.height);
    } else {
      // Rotate 4 corners around center and find AABB
      const cx = card.x + card.width / 2;
      const cy = card.y + card.height / 2;
      const rad = (rot * Math.PI) / 180;
      const cos = Math.cos(rad);
      const sin = Math.sin(rad);

      const corners = [
        { dx: -card.width / 2, dy: -card.height / 2 },
        { dx:  card.width / 2, dy: -card.height / 2 },
        { dx:  card.width / 2, dy:  card.height / 2 },
        { dx: -card.width / 2, dy:  card.height / 2 },
      ];

      for (const c of corners) {
        const rx = cx + cos * c.dx - sin * c.dy;
        const ry = cy + sin * c.dx + cos * c.dy;
        minX = Math.min(minX, rx);
        minY = Math.min(minY, ry);
        maxX = Math.max(maxX, rx);
        maxY = Math.max(maxY, ry);
      }
    }
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
