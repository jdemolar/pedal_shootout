import { useState, useCallback, useMemo, useEffect } from 'react';
import { Group, Text, Circle } from 'react-konva';
import Konva from 'konva';
import { useWorkbench } from '../../context/WorkbenchContext';
import { ControlConnection } from '../../types/connections';
import { WorkbenchRow } from './WorkbenchTable';
import {
  getControlInputJacks,
  getControlOutputJacks,
  hasControlJacks,
  isTrsConnector,
  inferControlType,
  validateControlConnection,
} from '../../utils/controlUtils';
import { ConnectionValidation, ConnectionWarning } from '../../utils/connectionValidation';
import { Jack } from '../../utils/transformers';
import { useCanvasViewport } from '../../hooks/useCanvasViewport';
import { calculateBoundingBox } from '../../utils/canvasUtils';
import CanvasBase from './CanvasBase';
import ProductCard, { CARD_WIDTH, CARD_HEIGHT } from './ProductCard';
import ConnectionLine from './ConnectionLine';
import ZoomControls from './ZoomControls';

const VIEW_KEY = 'control';

const CONTROL_PORT_MARGIN = 8;
const CONTROL_PORT_Y_TOP = 4;       // output ports (signal exits upward)
const CONTROL_PORT_Y_BOTTOM = CARD_HEIGHT - 4;  // input ports (signal enters from below)

const DEFAULT_CENTER_X = 400;
const DEFAULT_TOP_Y = 100;
const DEFAULT_BOTTOM_Y = 400;
const DEFAULT_COL_SPACING = 200;

const CONTROL_PORT_COLORS: Record<string, string> = {
  expression: '#5aaa8a',  // teal
  aux: '#aa8a5a',         // orange
  cv: '#aaaa5a',          // yellow
};

function getPortColor(jack: Jack): string {
  return CONTROL_PORT_COLORS[jack.category ?? ''] ?? '#888';
}

function controlCardWidth(maxPortCount: number): number {
  if (maxPortCount <= 3) return CARD_WIDTH;
  return Math.max(CARD_WIDTH, maxPortCount * 28 + 2 * CONTROL_PORT_MARGIN);
}

function portX(index: number, portCount: number, cardWidth: number): number {
  if (portCount <= 1) return cardWidth / 2;
  const usable = cardWidth - 2 * CONTROL_PORT_MARGIN;
  return CONTROL_PORT_MARGIN + index * usable / (portCount - 1);
}

function portKey(instanceId: string, jackId: number): string {
  return `${instanceId}:${jackId}`;
}

// --- Pending connection state ---

interface PendingControlConnection {
  jackId: number;
  instanceId: string;
  compositeKey: string;
  direction: 'output' | 'input';
}

interface ControlViewProps {
  rows: WorkbenchRow[];
}

const ControlView = ({ rows }: ControlViewProps) => {
  const {
    getViewPositions,
    updateViewPosition,
    addControlConnection,
    removeControlConnection,
    setControlConnections,
    acknowledgeControlWarning,
    updateControlConnection,
    activeWorkbench,
  } = useWorkbench();

  const savedPositions = getViewPositions(VIEW_KEY);
  const connections: ControlConnection[] = activeWorkbench.controlConnections ?? [];

  const viewport = useCanvasViewport(VIEW_KEY);
  const [stageDims, setStageDims] = useState({ width: 800, height: 600 });
  const handleDimensionsChange = useCallback((w: number, h: number) => setStageDims({ width: w, height: h }), []);

  // Interaction state
  const [pendingSource, setPendingSource] = useState<PendingControlConnection | null>(null);
  const [selectedConnectionId, setSelectedConnectionId] = useState<string | null>(null);
  const [mousePos, setMousePos] = useState<{ x: number; y: number } | null>(null);
  const [warningPopover, setWarningPopover] = useState<{ connId: string; warnings: ConnectionWarning[]; x: number; y: number } | null>(null);

  // Rows with control jacks
  const controlRows = useMemo(() => rows.filter(hasControlJacks), [rows]);
  const missingRows = useMemo(() => rows.filter(r => !hasControlJacks(r)), [rows]);

  // Separate items with outputs (sources) from input-only items (targets)
  const sourceRows = useMemo(() => controlRows.filter(r => getControlOutputJacks(r).length > 0), [controlRows]);
  const targetOnlyRows = useMemo(() => controlRows.filter(r => getControlOutputJacks(r).length === 0), [controlRows]);

  // Jack lookup
  const jackMap = useMemo(() => {
    const map = new Map<number, Jack>();
    for (const row of rows) for (const jack of row.jacks) map.set(jack.id, jack);
    return map;
  }, [rows]);

  // Card widths per instance
  const cardWidths = useMemo(() => {
    const map = new Map<string, number>();
    for (const row of controlRows) {
      const outCount = getControlOutputJacks(row).length;
      const inCount = getControlInputJacks(row).length;
      const maxPorts = Math.max(outCount, inCount);
      map.set(row.instanceId, controlCardWidth(maxPorts));
    }
    return map;
  }, [controlRows]);

  // Default positions: sources at bottom, target-only at top
  const getDefaultPosition = useCallback((row: WorkbenchRow): { x: number; y: number } => {
    const isSource = getControlOutputJacks(row).length > 0;
    if (isSource) {
      const idx = sourceRows.indexOf(row);
      const totalWidth = sourceRows.length * DEFAULT_COL_SPACING;
      const startX = DEFAULT_CENTER_X - totalWidth / 2;
      return { x: startX + idx * DEFAULT_COL_SPACING, y: DEFAULT_BOTTOM_Y };
    }
    const idx = targetOnlyRows.indexOf(row);
    const totalWidth = targetOnlyRows.length * DEFAULT_COL_SPACING;
    const startX = DEFAULT_CENTER_X - totalWidth / 2;
    return { x: startX + idx * DEFAULT_COL_SPACING, y: DEFAULT_TOP_Y };
  }, [sourceRows, targetOnlyRows]);

  const getPosition = useCallback((instanceId: string, fallbackX: number, fallbackY: number) =>
    savedPositions[instanceId] ?? { x: fallbackX, y: fallbackY },
  [savedPositions]);

  // Port positions (world coords)
  const portPositions = useMemo(() => {
    const map = new Map<string, { x: number; y: number }>();

    for (const row of controlRows) {
      const defPos = getDefaultPosition(row);
      const pos = getPosition(row.instanceId, defPos.x, defPos.y);
      const cw = cardWidths.get(row.instanceId) ?? CARD_WIDTH;
      const outputs = getControlOutputJacks(row);
      const inputs = getControlInputJacks(row);

      outputs.forEach((jack, i) => map.set(portKey(row.instanceId, jack.id), {
        x: pos.x + portX(i, outputs.length, cw),
        y: pos.y + CONTROL_PORT_Y_TOP,
      }));
      inputs.forEach((jack, i) => map.set(portKey(row.instanceId, jack.id), {
        x: pos.x + portX(i, inputs.length, cw),
        y: pos.y + CONTROL_PORT_Y_BOTTOM,
      }));
    }

    return map;
  }, [controlRows, getDefaultPosition, getPosition, cardWidths]);

  // Validate connections
  const connectionValidations = useMemo(() => {
    const map = new Map<string, ConnectionValidation>();
    for (const conn of connections) {
      const srcJack = jackMap.get(conn.sourceJackId);
      const tgtJack = jackMap.get(conn.targetJackId);

      if (srcJack && tgtJack) {
        map.set(conn.id, validateControlConnection(
          srcJack, tgtJack,
          connections.filter(c => c.id !== conn.id),
          conn.sourceInstanceId, conn.targetInstanceId,
          conn.sourceJackId, conn.targetJackId,
        ));
      } else {
        map.set(conn.id, { status: 'valid' as const, warnings: [] });
      }
    }
    return map;
  }, [connections, jackMap]);

  const handleDragEnd = useCallback((instanceId: string, x: number, y: number) => {
    updateViewPosition(VIEW_KEY, instanceId, x, y);
  }, [updateViewPosition]);

  // --- Connection interaction ---

  const handlePortClick = useCallback((instanceId: string, jackId: number, direction: 'output' | 'input') => {
    const key = portKey(instanceId, jackId);

    if (!pendingSource) {
      setPendingSource({ jackId, instanceId, compositeKey: key, direction });
      setMousePos(null);
      setSelectedConnectionId(null);
      setWarningPopover(null);
    } else if (pendingSource.compositeKey === key) {
      setPendingSource(null);
      setMousePos(null);
    } else if (pendingSource.direction === direction) {
      // Same direction — swap pending
      setPendingSource({ jackId, instanceId, compositeKey: key, direction });
      setMousePos(null);
    } else {
      const sourceJackId = direction === 'input' ? pendingSource.jackId : jackId;
      const targetJackId = direction === 'input' ? jackId : pendingSource.jackId;
      const sourceInstanceId = direction === 'input' ? pendingSource.instanceId : instanceId;
      const targetInstanceId = direction === 'input' ? instanceId : pendingSource.instanceId;

      const srcJack = jackMap.get(sourceJackId);
      const tgtJack = jackMap.get(targetJackId);

      if (srcJack && tgtJack) {
        const validation = validateControlConnection(
          srcJack, tgtJack,
          connections, sourceInstanceId, targetInstanceId,
          sourceJackId, targetJackId,
        );

        if (validation.status !== 'error') {
          addControlConnection({
            sourceJackId, targetJackId,
            sourceInstanceId, targetInstanceId,
            controlType: inferControlType(tgtJack),
            trsPolarity: null,
          });
        }
      }

      setPendingSource(null);
      setMousePos(null);
    }
  }, [pendingSource, jackMap, connections, addControlConnection]);

  const handleStageMouseMove = useCallback((e: Konva.KonvaEventObject<MouseEvent>) => {
    if (!pendingSource) return;
    const stage = e.target.getStage();
    if (stage) {
      const pos = stage.getPointerPosition();
      if (pos) setMousePos(viewport.screenToWorld(pos.x, pos.y));
    }
  }, [pendingSource, viewport]);

  const handleStageClick = useCallback((e: Konva.KonvaEventObject<MouseEvent>) => {
    if (e.target === e.target.getStage()) {
      setPendingSource(null);
      setSelectedConnectionId(null);
      setWarningPopover(null);
    }
  }, []);

  // Check if a connection involves TRS connectors
  const connHasTrs = useCallback((conn: ControlConnection): boolean => {
    const srcJack = jackMap.get(conn.sourceJackId);
    const tgtJack = jackMap.get(conn.targetJackId);
    return isTrsConnector(srcJack?.connector_type ?? null) || isTrsConnector(tgtJack?.connector_type ?? null);
  }, [jackMap]);

  const handleConnectionClick = useCallback((connId: string) => {
    const validation = connectionValidations.get(connId);
    const conn = connections.find(c => c.id === connId);
    const hasWarnings = validation && validation.warnings.length > 0;
    const hasTrs = conn ? connHasTrs(conn) : false;

    if (conn && (hasWarnings || hasTrs)) {
      const srcPos = portPositions.get(portKey(conn.sourceInstanceId, conn.sourceJackId));
      const tgtPos = portPositions.get(portKey(conn.targetInstanceId, conn.targetJackId));
      if (srcPos && tgtPos) {
        setWarningPopover({
          connId,
          warnings: validation?.warnings ?? [],
          x: (srcPos.x + tgtPos.x) / 2,
          y: (srcPos.y + tgtPos.y) / 2 - 30,
        });
      }
    } else {
      setWarningPopover(null);
    }
    setSelectedConnectionId(connId);
    setPendingSource(null);
  }, [connectionValidations, connections, portPositions, connHasTrs]);

  const handleKeyDown = useCallback((e: KeyboardEvent) => {
    const tag = (e.target as HTMLElement)?.tagName;
    if (tag === 'INPUT' || tag === 'SELECT') return;

    if (e.key === 'Escape') {
      setPendingSource(null);
      setSelectedConnectionId(null);
      setWarningPopover(null);
    }

    if ((e.key === 'Delete' || e.key === 'Backspace') && selectedConnectionId) {
      removeControlConnection(selectedConnectionId);
      setSelectedConnectionId(null);
      setWarningPopover(null);
    }
  }, [selectedConnectionId, removeControlConnection]);

  useEffect(() => {
    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [handleKeyDown]);

  const handleFitAll = useCallback(() => {
    const cards: Array<{ x: number; y: number; width: number; height: number }> = [];
    for (const row of controlRows) {
      const defPos = getDefaultPosition(row);
      const pos = getPosition(row.instanceId, defPos.x, defPos.y);
      const cw = cardWidths.get(row.instanceId) ?? CARD_WIDTH;
      cards.push({ x: pos.x, y: pos.y, width: cw, height: CARD_HEIGHT });
    }
    if (cards.length === 0) return;
    viewport.fitAll(calculateBoundingBox(cards), stageDims.width, stageDims.height);
  }, [controlRows, getDefaultPosition, getPosition, cardWidths, viewport, stageDims]);

  const pendingSourcePos = pendingSource ? portPositions.get(pendingSource.compositeKey) : null;

  if (rows.length === 0) {
    return <div className="workbench__canvas-placeholder">Your workbench is empty. Add products from the catalog views.</div>;
  }

  if (controlRows.length === 0) {
    return <div className="workbench__canvas-placeholder">No items with control jacks (expression, aux, CV) in this workbench.</div>;
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
        onStageMouseMove={handleStageMouseMove}
        onDimensionsChange={handleDimensionsChange}
      >
        {/* Connection lines */}
        {connections.map((conn) => {
          const srcPos = portPositions.get(portKey(conn.sourceInstanceId, conn.sourceJackId));
          const tgtPos = portPositions.get(portKey(conn.targetInstanceId, conn.targetJackId));
          if (!srcPos || !tgtPos) return null;
          const validation = connectionValidations.get(conn.id) ?? { status: 'valid' as const, warnings: [] };
          const isAcked = (conn.acknowledgedWarnings?.length ?? 0) > 0 &&
            validation.warnings.every(w => conn.acknowledgedWarnings?.includes(w.key));
          return (
            <ConnectionLine
              key={conn.id}
              sourceX={srcPos.x} sourceY={srcPos.y}
              targetX={tgtPos.x} targetY={tgtPos.y}
              status={validation.status}
              acknowledged={isAcked}
              selected={selectedConnectionId === conn.id}
              onClick={() => handleConnectionClick(conn.id)}
            />
          );
        })}

        {/* Preview line */}
        {pendingSource && pendingSourcePos && mousePos && (
          <ConnectionLine
            sourceX={pendingSourcePos.x} sourceY={pendingSourcePos.y}
            targetX={mousePos.x} targetY={mousePos.y}
            status="valid"
          />
        )}

        {/* Product cards */}
        {controlRows.map((row) => {
          const defPos = getDefaultPosition(row);
          const pos = getPosition(row.instanceId, defPos.x, defPos.y);
          const cw = cardWidths.get(row.instanceId) ?? CARD_WIDTH;
          const outputs = getControlOutputJacks(row);
          const inputs = getControlInputJacks(row);

          return (
            <ProductCard
              key={row.instanceId}
              productType={row.product_type}
              manufacturer={row.manufacturer}
              model={row.model}
              x={pos.x} y={pos.y}
              cardWidth={cw}
              onDragEnd={(x, y) => handleDragEnd(row.instanceId, x, y)}
            >
              {/* Output ports at top */}
              {outputs.map((jack, i) => {
                const key = portKey(row.instanceId, jack.id);
                const px = portX(i, outputs.length, cw);
                const color = getPortColor(jack);
                return (
                  <Group key={key}>
                    <Circle
                      x={px} y={CONTROL_PORT_Y_TOP}
                      radius={5}
                      fill={pendingSource?.compositeKey === key ? '#fff' : color}
                      stroke={color} strokeWidth={1}
                      onClick={() => handlePortClick(row.instanceId, jack.id, 'output')}
                      onTap={() => handlePortClick(row.instanceId, jack.id, 'output')}
                    />
                    {outputs.length <= 3 && (
                      <Text
                        x={px - 25} y={CONTROL_PORT_Y_TOP - 14}
                        width={50}
                        text={jack.jack_name ?? jack.category ?? 'Out'}
                        fontSize={8} fontFamily="monospace" fill="#666"
                        align="center" listening={false}
                      />
                    )}
                  </Group>
                );
              })}
              {/* Input ports at bottom */}
              {inputs.map((jack, i) => {
                const key = portKey(row.instanceId, jack.id);
                const px = portX(i, inputs.length, cw);
                const color = getPortColor(jack);
                return (
                  <Group key={key}>
                    <Circle
                      x={px} y={CONTROL_PORT_Y_BOTTOM}
                      radius={5}
                      fill={pendingSource?.compositeKey === key ? '#fff' : color}
                      stroke={color} strokeWidth={1}
                      onClick={() => handlePortClick(row.instanceId, jack.id, 'input')}
                      onTap={() => handlePortClick(row.instanceId, jack.id, 'input')}
                    />
                    {inputs.length <= 3 && (
                      <Text
                        x={px - 25} y={CONTROL_PORT_Y_BOTTOM + 6}
                        width={50}
                        text={jack.jack_name ?? jack.category ?? 'In'}
                        fontSize={8} fontFamily="monospace" fill="#666"
                        align="center" listening={false}
                      />
                    )}
                  </Group>
                );
              })}
            </ProductCard>
          );
        })}
      </CanvasBase>

      {/* Missing control jacks warning */}
      {missingRows.length > 0 && (
        <div className="workbench__audio-missing">
          <span className="workbench__audio-missing-title">
            {missingRows.length} item{missingRows.length !== 1 ? 's' : ''} not shown — no control jack data:
          </span>
          <ul className="workbench__audio-missing-list">
            {missingRows.map(r => (
              <li key={r.instanceId}>{r.manufacturer} {r.model}</li>
            ))}
          </ul>
        </div>
      )}

      {/* Toolbar */}
      <div className="workbench__power-actions">
        {connections.length > 0 && (
          <button
            className="workbench__power-action-btn workbench__power-action-btn--danger"
            onClick={() => {
              if (window.confirm(`Clear all ${connections.length} control connection${connections.length === 1 ? '' : 's'}?`)) {
                setControlConnections([]);
                setSelectedConnectionId(null);
                setWarningPopover(null);
              }
            }}
          >
            Clear all
          </button>
        )}
      </div>

      <ZoomControls
        scale={viewport.scale}
        onZoomIn={() => viewport.zoomIn(stageDims.width, stageDims.height)}
        onZoomOut={() => viewport.zoomOut(stageDims.width, stageDims.height)}
        onFitAll={handleFitAll}
      />

      {/* Floating delete button for selected connection */}
      {selectedConnectionId && (() => {
        const conn = connections.find(c => c.id === selectedConnectionId);
        if (!conn) return null;
        const srcPos = portPositions.get(portKey(conn.sourceInstanceId, conn.sourceJackId));
        const tgtPos = portPositions.get(portKey(conn.targetInstanceId, conn.targetJackId));
        if (!srcPos || !tgtPos) return null;
        const midScreen = viewport.worldToScreen((srcPos.x + tgtPos.x) / 2, (srcPos.y + tgtPos.y) / 2);
        return (
          <button
            className="workbench__power-delete-btn"
            style={{ position: 'absolute', left: midScreen.x, top: midScreen.y }}
            title="Delete connection"
            onClick={() => {
              removeControlConnection(selectedConnectionId);
              setSelectedConnectionId(null);
              setWarningPopover(null);
            }}
          >
            &times;
          </button>
        );
      })()}

      {/* Combined warning + polarity popover */}
      {warningPopover && (() => {
        const conn = connections.find(c => c.id === warningPopover.connId);
        if (!conn) return null;
        const showTrs = connHasTrs(conn);
        if (warningPopover.warnings.length === 0 && !showTrs) return null;
        const screenPos = viewport.worldToScreen(warningPopover.x, warningPopover.y);
        return (
          <div className="workbench__power-popover" style={{ position: 'absolute', left: screenPos.x, top: screenPos.y }}>
            {warningPopover.warnings.length > 0 && (
              <div className="workbench__power-popover-warnings">
                {warningPopover.warnings.map(w => {
                  const acked = conn.acknowledgedWarnings?.includes(w.key);
                  return (
                    <div key={w.key} className="workbench__power-popover-warning">
                      <span>{w.message}</span>
                      {acked
                        ? <span className="workbench__power-popover-acked">Acknowledged</span>
                        : <button className="workbench__power-popover-btn" onClick={() => acknowledgeControlWarning(warningPopover.connId, w.key)}>
                            {w.adapterImplication ? 'I have this adapter' : 'Got it'}
                          </button>
                      }
                    </div>
                  );
                })}
              </div>
            )}
            {showTrs && (
              <div className="workbench__midi-badge-row" style={{ marginTop: warningPopover.warnings.length > 0 ? 8 : 0 }}>
                <span className="workbench__midi-badge-label">Polarity:</span>
                <select
                  value={conn.trsPolarity ?? ''}
                  onChange={e => {
                    const val = e.target.value;
                    updateControlConnection(conn.id, {
                      trsPolarity: val === '' ? null : val as ControlConnection['trsPolarity'],
                    });
                  }}
                >
                  <option value="">Unknown</option>
                  <option value="tip-active">Tip Active</option>
                  <option value="ring-active">Ring Active</option>
                </select>
              </div>
            )}
            <button className="workbench__power-popover-btn workbench__power-popover-btn--close" onClick={() => setWarningPopover(null)}>Close</button>
          </div>
        );
      })()}
    </div>
  );
};

export default ControlView;
