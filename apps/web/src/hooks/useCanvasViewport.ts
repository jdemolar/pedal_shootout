/**
 * Hook for managing canvas zoom/pan state.
 *
 * Provides wheel-to-zoom, pinch-to-zoom, pan-via-drag, fit-all, and
 * coordinate conversion between screen and world space.
 *
 * Viewport state is persisted to WorkbenchContext (and thus localStorage)
 * with a debounce to avoid excessive writes during continuous zoom.
 */

import { useState, useCallback, useRef, useEffect } from 'react';
import Konva from 'konva';
import { useWorkbench } from '../context/WorkbenchContext';
import { BoundingBox, calculateFitViewport } from '../utils/canvasUtils';

const MIN_SCALE = 0.15;
const MAX_SCALE = 4.0;
const ZOOM_FACTOR = 1.1;
const STEP_ZOOM_FACTOR = 1.25;
const SAVE_DEBOUNCE_MS = 200;

export interface CanvasViewport {
  scale: number;
  offsetX: number;
  offsetY: number;
  handleWheel: (e: Konva.KonvaEventObject<WheelEvent>) => void;
  handleTouchMove: (e: Konva.KonvaEventObject<TouchEvent>) => void;
  handleTouchEnd: () => void;
  handleStageDragEnd: (e: Konva.KonvaEventObject<DragEvent>) => void;
  screenToWorld: (screenX: number, screenY: number) => { x: number; y: number };
  worldToScreen: (worldX: number, worldY: number) => { x: number; y: number };
  fitAll: (bbox: BoundingBox, stageWidth: number, stageHeight: number) => void;
  zoomIn: (stageWidth: number, stageHeight: number) => void;
  zoomOut: (stageWidth: number, stageHeight: number) => void;
}

function clampScale(s: number): number {
  return Math.max(MIN_SCALE, Math.min(MAX_SCALE, s));
}

export function useCanvasViewport(viewKey: string): CanvasViewport {
  const { getViewportState, updateViewportState } = useWorkbench();

  const saved = getViewportState(viewKey);
  const [scale, setScale] = useState(saved.scale);
  const [offsetX, setOffsetX] = useState(saved.offsetX);
  const [offsetY, setOffsetY] = useState(saved.offsetY);

  // Track pinch distance for touch zoom
  const lastPinchDist = useRef<number | null>(null);
  const lastPinchCenter = useRef<{ x: number; y: number } | null>(null);

  // Debounced save to context
  const saveTimerRef = useRef<ReturnType<typeof setTimeout> | null>(null);
  const latestState = useRef({ scale, offsetX, offsetY });
  latestState.current = { scale, offsetX, offsetY };

  const scheduleSave = useCallback(() => {
    if (saveTimerRef.current) clearTimeout(saveTimerRef.current);
    saveTimerRef.current = setTimeout(() => {
      updateViewportState(viewKey, latestState.current);
    }, SAVE_DEBOUNCE_MS);
  }, [viewKey, updateViewportState]);

  // Save immediately on unmount
  useEffect(() => {
    return () => {
      if (saveTimerRef.current) clearTimeout(saveTimerRef.current);
      updateViewportState(viewKey, latestState.current);
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const applyZoom = useCallback((
    newScale: number,
    centerX: number,
    centerY: number,
    currentScale: number,
    currentOffsetX: number,
    currentOffsetY: number,
  ) => {
    const clamped = clampScale(newScale);
    // Keep the point under the cursor fixed in world space
    const worldX = (centerX - currentOffsetX) / currentScale;
    const worldY = (centerY - currentOffsetY) / currentScale;
    const newOffsetX = centerX - worldX * clamped;
    const newOffsetY = centerY - worldY * clamped;
    setScale(clamped);
    setOffsetX(newOffsetX);
    setOffsetY(newOffsetY);
    return { scale: clamped, offsetX: newOffsetX, offsetY: newOffsetY };
  }, []);

  const handleWheel = useCallback((e: Konva.KonvaEventObject<WheelEvent>) => {
    e.evt.preventDefault();
    const stage = e.target.getStage();
    if (!stage) return;
    const pointer = stage.getPointerPosition();
    if (!pointer) return;

    const direction = e.evt.deltaY > 0 ? -1 : 1;
    const newScale = latestState.current.scale * (direction > 0 ? ZOOM_FACTOR : 1 / ZOOM_FACTOR);
    applyZoom(
      newScale,
      pointer.x,
      pointer.y,
      latestState.current.scale,
      latestState.current.offsetX,
      latestState.current.offsetY,
    );
    scheduleSave();
  }, [applyZoom, scheduleSave]);

  const handleTouchMove = useCallback((e: Konva.KonvaEventObject<TouchEvent>) => {
    const touches = e.evt.touches;
    if (touches.length !== 2) return;
    e.evt.preventDefault();

    const t0 = touches[0];
    const t1 = touches[1];
    const dist = Math.sqrt((t1.clientX - t0.clientX) ** 2 + (t1.clientY - t0.clientY) ** 2);
    const centerX = (t0.clientX + t1.clientX) / 2;
    const centerY = (t0.clientY + t1.clientY) / 2;

    if (lastPinchDist.current != null && lastPinchCenter.current != null) {
      const delta = dist / lastPinchDist.current;
      const newScale = latestState.current.scale * delta;
      applyZoom(
        newScale,
        lastPinchCenter.current.x,
        lastPinchCenter.current.y,
        latestState.current.scale,
        latestState.current.offsetX,
        latestState.current.offsetY,
      );
      scheduleSave();
    }

    lastPinchDist.current = dist;
    lastPinchCenter.current = { x: centerX, y: centerY };
  }, [applyZoom, scheduleSave]);

  const handleTouchEnd = useCallback(() => {
    lastPinchDist.current = null;
    lastPinchCenter.current = null;
  }, []);

  const handleStageDragEnd = useCallback((e: Konva.KonvaEventObject<DragEvent>) => {
    // Only handle Stage drag, not child Group drags
    const target = e.target;
    if (target !== target.getStage()) return;
    setOffsetX(target.x());
    setOffsetY(target.y());
    scheduleSave();
  }, [scheduleSave]);

  const screenToWorld = useCallback((screenX: number, screenY: number) => ({
    x: (screenX - latestState.current.offsetX) / latestState.current.scale,
    y: (screenY - latestState.current.offsetY) / latestState.current.scale,
  }), []);

  const worldToScreen = useCallback((worldX: number, worldY: number) => ({
    x: worldX * latestState.current.scale + latestState.current.offsetX,
    y: worldY * latestState.current.scale + latestState.current.offsetY,
  }), []);

  const fitAll = useCallback((bbox: BoundingBox, stageWidth: number, stageHeight: number) => {
    const vp = calculateFitViewport(bbox, stageWidth, stageHeight);
    setScale(vp.scale);
    setOffsetX(vp.offsetX);
    setOffsetY(vp.offsetY);
    updateViewportState(viewKey, vp);
  }, [viewKey, updateViewportState]);

  const zoomIn = useCallback((stageWidth: number, stageHeight: number) => {
    const centerX = stageWidth / 2;
    const centerY = stageHeight / 2;
    applyZoom(
      latestState.current.scale * STEP_ZOOM_FACTOR,
      centerX,
      centerY,
      latestState.current.scale,
      latestState.current.offsetX,
      latestState.current.offsetY,
    );
    scheduleSave();
  }, [applyZoom, scheduleSave]);

  const zoomOut = useCallback((stageWidth: number, stageHeight: number) => {
    const centerX = stageWidth / 2;
    const centerY = stageHeight / 2;
    applyZoom(
      latestState.current.scale / STEP_ZOOM_FACTOR,
      centerX,
      centerY,
      latestState.current.scale,
      latestState.current.offsetX,
      latestState.current.offsetY,
    );
    scheduleSave();
  }, [applyZoom, scheduleSave]);

  return {
    scale,
    offsetX,
    offsetY,
    handleWheel,
    handleTouchMove,
    handleTouchEnd,
    handleStageDragEnd,
    screenToWorld,
    worldToScreen,
    fitAll,
    zoomIn,
    zoomOut,
  };
}
