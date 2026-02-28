import { useState, useCallback, useMemo, useEffect } from 'react';
import { Group, Text, Circle } from 'react-konva';
import Konva from 'konva';
import { useWorkbench } from '../../context/WorkbenchContext';
import { MidiConnection, MidiDeviceSettings } from '../../types/connections';
import { WorkbenchRow } from './WorkbenchTable';
import {
  getMidiInputJacks,
  getMidiOutputJacks,
  hasMidiJacks,
  isTrsMidiConnector,
  validateMidiConnection,
  getChainDepth,
} from '../../utils/midiUtils';
import { ConnectionValidation, ConnectionWarning } from '../../utils/connectionValidation';
import { Jack } from '../../utils/transformers';
import { useCanvasViewport } from '../../hooks/useCanvasViewport';
import { calculateBoundingBox } from '../../utils/canvasUtils';
import CanvasBase from './CanvasBase';
import ProductCard, { CARD_WIDTH, CARD_HEIGHT } from './ProductCard';
import ConnectionLine from './ConnectionLine';
import ZoomControls from './ZoomControls';

const VIEW_KEY = 'midi';

const MIDI_PORT_MARGIN = 8;
const MIDI_PORT_Y_TOP = 4;       // output ports (signal exits upward)
const MIDI_PORT_Y_BOTTOM = CARD_HEIGHT - 4;  // input ports (signal enters from below)

const DEFAULT_CENTER_X = 400;
const DEFAULT_BOTTOM_Y = 500;
const DEFAULT_ROW_SPACING = 200;
const DEFAULT_COL_SPACING = 200;

function midiCardWidth(maxPortCount: number): number {
  if (maxPortCount <= 3) return CARD_WIDTH;
  return Math.max(CARD_WIDTH, maxPortCount * 28 + 2 * MIDI_PORT_MARGIN);
}

function portX(index: number, portCount: number, cardWidth: number): number {
  if (portCount <= 1) return cardWidth / 2;
  const usable = cardWidth - 2 * MIDI_PORT_MARGIN;
  return MIDI_PORT_MARGIN + index * usable / (portCount - 1);
}

function portKey(instanceId: string, jackId: number): string {
  return `${instanceId}:${jackId}`;
}

/** Format device settings as a short label for display on the card. */
function formatDeviceSettingsLabel(settings: MidiDeviceSettings): string {
  const parts: string[] = [];
  parts.push(settings.midiChannel === null ? 'Omni' : `Ch ${settings.midiChannel}`);
  if (settings.sendsClock) parts.push('Clock TX');
  if (settings.receivesClock) parts.push('Clock RX');
  return parts.join(' | ');
}

// --- Pending connection state ---

interface PendingMidiConnection {
  jackId: number;
  instanceId: string;
  compositeKey: string;
  direction: 'output' | 'input';
}

interface MidiViewProps {
  rows: WorkbenchRow[];
}

const MidiView = ({ rows }: MidiViewProps) => {
  const {
    getViewPositions,
    updateViewPosition,
    addMidiConnection,
    removeMidiConnection,
    setMidiConnections,
    acknowledgeMidiWarning,
    updateMidiConnection,
    updateMidiDeviceSettings,
    activeWorkbench,
  } = useWorkbench();

  const savedPositions = getViewPositions(VIEW_KEY);
  const connections: MidiConnection[] = activeWorkbench.midiConnections ?? [];
  const deviceSettings = activeWorkbench.midiDeviceSettings ?? {};

  const viewport = useCanvasViewport(VIEW_KEY);
  const [stageDims, setStageDims] = useState({ width: 800, height: 600 });
  const handleDimensionsChange = useCallback((w: number, h: number) => setStageDims({ width: w, height: h }), []);

  // Interaction state
  const [pendingSource, setPendingSource] = useState<PendingMidiConnection | null>(null);
  const [selectedConnectionId, setSelectedConnectionId] = useState<string | null>(null);
  const [mousePos, setMousePos] = useState<{ x: number; y: number } | null>(null);
  const [warningPopover, setWarningPopover] = useState<{ connId: string; warnings: ConnectionWarning[]; x: number; y: number } | null>(null);
  const [editingDeviceId, setEditingDeviceId] = useState<string | null>(null);

  // Rows with MIDI jacks
  const midiRows = useMemo(() => rows.filter(hasMidiJacks), [rows]);
  const missingRows = useMemo(() => rows.filter(r => !hasMidiJacks(r)), [rows]);

  // Separate controllers from other MIDI-capable items
  const controllerRows = useMemo(() => midiRows.filter(r => r.product_type === 'midi_controller'), [midiRows]);
  const otherMidiRows = useMemo(() => midiRows.filter(r => r.product_type !== 'midi_controller'), [midiRows]);

  // Jack lookup
  const jackMap = useMemo(() => {
    const map = new Map<number, Jack>();
    for (const row of rows) for (const jack of row.jacks) map.set(jack.id, jack);
    return map;
  }, [rows]);

  // Card widths per instance (based on max port count)
  const cardWidths = useMemo(() => {
    const map = new Map<string, number>();
    for (const row of midiRows) {
      const outCount = getMidiOutputJacks(row).length;
      const inCount = getMidiInputJacks(row).length;
      const maxPorts = Math.max(outCount, inCount);
      map.set(row.instanceId, midiCardWidth(maxPorts));
    }
    return map;
  }, [midiRows]);

  // Default positions: controllers at bottom, other devices above
  const getDefaultPosition = useCallback((row: WorkbenchRow): { x: number; y: number } => {
    const isController = row.product_type === 'midi_controller';
    if (isController) {
      const idx = controllerRows.indexOf(row);
      const totalWidth = controllerRows.length * DEFAULT_COL_SPACING;
      const startX = DEFAULT_CENTER_X - totalWidth / 2;
      return { x: startX + idx * DEFAULT_COL_SPACING, y: DEFAULT_BOTTOM_Y };
    }
    const idx = otherMidiRows.indexOf(row);
    const totalWidth = otherMidiRows.length * DEFAULT_COL_SPACING;
    const startX = DEFAULT_CENTER_X - totalWidth / 2;
    return { x: startX + idx * DEFAULT_COL_SPACING, y: DEFAULT_BOTTOM_Y - DEFAULT_ROW_SPACING };
  }, [controllerRows, otherMidiRows]);

  const getPosition = useCallback((instanceId: string, fallbackX: number, fallbackY: number) =>
    savedPositions[instanceId] ?? { x: fallbackX, y: fallbackY },
  [savedPositions]);

  // Port positions (world coords) keyed by portKey
  const portPositions = useMemo(() => {
    const map = new Map<string, { x: number; y: number }>();

    for (const row of midiRows) {
      const defPos = getDefaultPosition(row);
      const pos = getPosition(row.instanceId, defPos.x, defPos.y);
      const cw = cardWidths.get(row.instanceId) ?? CARD_WIDTH;
      const outputs = getMidiOutputJacks(row);
      const inputs = getMidiInputJacks(row);

      outputs.forEach((jack, i) => map.set(portKey(row.instanceId, jack.id), {
        x: pos.x + portX(i, outputs.length, cw),
        y: pos.y + MIDI_PORT_Y_TOP,
      }));
      inputs.forEach((jack, i) => map.set(portKey(row.instanceId, jack.id), {
        x: pos.x + portX(i, inputs.length, cw),
        y: pos.y + MIDI_PORT_Y_BOTTOM,
      }));
    }

    return map;
  }, [midiRows, getDefaultPosition, getPosition, cardWidths]);

  // Validate connections
  const connectionValidations = useMemo(() => {
    const map = new Map<string, ConnectionValidation>();
    for (const conn of connections) {
      const srcJack = jackMap.get(conn.sourceJackId);
      const tgtJack = jackMap.get(conn.targetJackId);

      if (srcJack && tgtJack) {
        map.set(conn.id, validateMidiConnection(
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

  // Duplicate channel warnings — scan midiDeviceSettings for devices sharing a channel
  // that are connected to the same source
  const duplicateChannelInstances = useMemo(() => {
    const channelMap = new Map<number, string[]>(); // channel -> instanceIds
    for (const instanceId of Object.keys(deviceSettings)) {
      const ch = deviceSettings[instanceId].midiChannel;
      if (ch !== null) {
        const existing = channelMap.get(ch) || [];
        existing.push(instanceId);
        channelMap.set(ch, existing);
      }
    }
    const dupeInstances = new Set<string>();
    channelMap.forEach((ids) => {
      if (ids.length > 1) ids.forEach(id => dupeInstances.add(id));
    });
    return dupeInstances;
  }, [deviceSettings]);

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
      setEditingDeviceId(null);
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
        const validation = validateMidiConnection(
          srcJack, tgtJack,
          connections, sourceInstanceId, targetInstanceId,
          sourceJackId, targetJackId,
        );

        if (validation.status !== 'error') {
          addMidiConnection({
            sourceJackId, targetJackId,
            sourceInstanceId, targetInstanceId,
            chainIndex: getChainDepth(targetInstanceId, connections),
            trsMidiStandard: null,
          });
        }
      }

      setPendingSource(null);
      setMousePos(null);
    }
  }, [pendingSource, jackMap, connections, addMidiConnection]);

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
      setEditingDeviceId(null);
    }
  }, []);

  const handleConnectionClick = useCallback((connId: string) => {
    const validation = connectionValidations.get(connId);
    const conn = connections.find(c => c.id === connId);
    if (validation && validation.warnings.length > 0 && conn) {
      const srcPos = portPositions.get(portKey(conn.sourceInstanceId, conn.sourceJackId));
      const tgtPos = portPositions.get(portKey(conn.targetInstanceId, conn.targetJackId));
      if (srcPos && tgtPos) {
        setWarningPopover({ connId, warnings: validation.warnings, x: (srcPos.x + tgtPos.x) / 2, y: (srcPos.y + tgtPos.y) / 2 - 30 });
      }
    }
    setSelectedConnectionId(connId);
    setPendingSource(null);
    setEditingDeviceId(null);
  }, [connectionValidations, connections, portPositions]);

  const handleCardDoubleClick = useCallback((instanceId: string) => {
    setEditingDeviceId(prev => prev === instanceId ? null : instanceId);
    setSelectedConnectionId(null);
    setWarningPopover(null);
    setPendingSource(null);
  }, []);

  const handleKeyDown = useCallback((e: KeyboardEvent) => {
    const tag = (e.target as HTMLElement)?.tagName;
    if (tag === 'INPUT' || tag === 'SELECT') return;

    if (e.key === 'Escape') {
      setPendingSource(null);
      setSelectedConnectionId(null);
      setWarningPopover(null);
      setEditingDeviceId(null);
    }

    if ((e.key === 'Delete' || e.key === 'Backspace') && selectedConnectionId) {
      removeMidiConnection(selectedConnectionId);
      setSelectedConnectionId(null);
      setWarningPopover(null);
    }
  }, [selectedConnectionId, removeMidiConnection]);

  useEffect(() => {
    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [handleKeyDown]);

  const handleFitAll = useCallback(() => {
    const cards: Array<{ x: number; y: number; width: number; height: number }> = [];
    for (const row of midiRows) {
      const defPos = getDefaultPosition(row);
      const pos = getPosition(row.instanceId, defPos.x, defPos.y);
      const cw = cardWidths.get(row.instanceId) ?? CARD_WIDTH;
      cards.push({ x: pos.x, y: pos.y, width: cw, height: CARD_HEIGHT });
    }
    if (cards.length === 0) return;
    viewport.fitAll(calculateBoundingBox(cards), stageDims.width, stageDims.height);
  }, [midiRows, getDefaultPosition, getPosition, cardWidths, viewport, stageDims]);

  const pendingSourcePos = pendingSource ? portPositions.get(pendingSource.compositeKey) : null;

  // Check if a connection involves TRS MIDI connectors
  const connHasTrs = useCallback((conn: MidiConnection): boolean => {
    const srcJack = jackMap.get(conn.sourceJackId);
    const tgtJack = jackMap.get(conn.targetJackId);
    return isTrsMidiConnector(srcJack?.connector_type ?? null) || isTrsMidiConnector(tgtJack?.connector_type ?? null);
  }, [jackMap]);

  if (rows.length === 0) {
    return <div className="workbench__canvas-placeholder">Your workbench is empty. Add products from the catalog views.</div>;
  }

  if (midiRows.length === 0) {
    return <div className="workbench__canvas-placeholder">No items with MIDI jacks in this workbench.</div>;
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
        {midiRows.map((row) => {
          const defPos = getDefaultPosition(row);
          const pos = getPosition(row.instanceId, defPos.x, defPos.y);
          const cw = cardWidths.get(row.instanceId) ?? CARD_WIDTH;
          const outputs = getMidiOutputJacks(row);
          const inputs = getMidiInputJacks(row);
          const settings = deviceSettings[row.instanceId];
          const isDupe = duplicateChannelInstances.has(row.instanceId);

          return (
            <ProductCard
              key={row.instanceId}
              productType={row.product_type}
              manufacturer={row.manufacturer}
              model={row.model}
              x={pos.x} y={pos.y}
              cardWidth={cw}
              onDragEnd={(x, y) => handleDragEnd(row.instanceId, x, y)}
              onDblClick={() => handleCardDoubleClick(row.instanceId)}
            >
              {/* Device settings label below model name */}
              {settings && (
                <Text
                  x={4} y={CARD_HEIGHT / 2 + 6}
                  width={cw - 8}
                  text={formatDeviceSettingsLabel(settings)}
                  fontSize={8} fontFamily="monospace"
                  fill={isDupe ? '#d4a55a' : '#8a8aaa'}
                  align="center" listening={false}
                />
              )}
              {/* Output ports at top */}
              {outputs.map((jack, i) => {
                const key = portKey(row.instanceId, jack.id);
                const px = portX(i, outputs.length, cw);
                return (
                  <Group key={key}>
                    <Circle
                      x={px} y={MIDI_PORT_Y_TOP}
                      radius={5}
                      fill={pendingSource?.compositeKey === key ? '#fff' : '#aa6aaa'}
                      stroke="#aa6aaa" strokeWidth={1}
                      onClick={() => handlePortClick(row.instanceId, jack.id, 'output')}
                      onTap={() => handlePortClick(row.instanceId, jack.id, 'output')}
                    />
                    {outputs.length <= 2 && (
                      <Text
                        x={px - 20} y={MIDI_PORT_Y_TOP - 14}
                        width={40}
                        text={jack.jack_name ?? 'Out'}
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
                return (
                  <Group key={key}>
                    <Circle
                      x={px} y={MIDI_PORT_Y_BOTTOM}
                      radius={5}
                      fill={pendingSource?.compositeKey === key ? '#fff' : '#6a6aaa'}
                      stroke="#6a6aaa" strokeWidth={1}
                      onClick={() => handlePortClick(row.instanceId, jack.id, 'input')}
                      onTap={() => handlePortClick(row.instanceId, jack.id, 'input')}
                    />
                    {inputs.length <= 2 && (
                      <Text
                        x={px - 20} y={MIDI_PORT_Y_BOTTOM + 6}
                        width={40}
                        text={jack.jack_name ?? 'In'}
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

      {/* Missing MIDI jacks warning */}
      {missingRows.length > 0 && (
        <div className="workbench__audio-missing">
          <span className="workbench__audio-missing-title">
            {missingRows.length} item{missingRows.length !== 1 ? 's' : ''} not shown — no MIDI jack data:
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
              if (window.confirm(`Clear all ${connections.length} MIDI connection${connections.length === 1 ? '' : 's'}?`)) {
                setMidiConnections([]);
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

      {/* Device settings popover (double-click a card) */}
      {editingDeviceId && (() => {
        const row = midiRows.find(r => r.instanceId === editingDeviceId);
        if (!row) return null;
        const defPos = getDefaultPosition(row);
        const pos = getPosition(row.instanceId, defPos.x, defPos.y);
        const cw = cardWidths.get(row.instanceId) ?? CARD_WIDTH;
        const screenPos = viewport.worldToScreen(pos.x + cw + 8, pos.y);
        const settings = deviceSettings[editingDeviceId] ?? { midiChannel: null, sendsClock: false, receivesClock: false };
        const isDupe = duplicateChannelInstances.has(editingDeviceId);

        return (
          <div
            className="workbench__midi-badge"
            style={{ position: 'absolute', left: screenPos.x, top: screenPos.y }}
          >
            <div className="workbench__midi-badge-row">
              <span className="workbench__midi-badge-label">Channel:</span>
              <select
                value={settings.midiChannel === null ? '' : String(settings.midiChannel)}
                onChange={e => {
                  const val = e.target.value;
                  updateMidiDeviceSettings(editingDeviceId, { midiChannel: val === '' ? null : Number(val) });
                }}
              >
                <option value="">Omni</option>
                {Array.from({ length: 16 }, (_, i) => (
                  <option key={i + 1} value={String(i + 1)}>{i + 1}</option>
                ))}
              </select>
              {isDupe && <span style={{ color: '#d4a55a', fontSize: 10 }}>Duplicate</span>}
            </div>
            <div className="workbench__midi-badge-row">
              <label style={{ display: 'flex', alignItems: 'center', gap: 4, cursor: 'pointer' }}>
                <input
                  type="checkbox"
                  checked={settings.sendsClock}
                  onChange={e => updateMidiDeviceSettings(editingDeviceId, { sendsClock: e.target.checked })}
                />
                <span className="workbench__midi-badge-label">Sends Clock</span>
              </label>
            </div>
            <div className="workbench__midi-badge-row">
              <label style={{ display: 'flex', alignItems: 'center', gap: 4, cursor: 'pointer' }}>
                <input
                  type="checkbox"
                  checked={settings.receivesClock}
                  onChange={e => updateMidiDeviceSettings(editingDeviceId, { receivesClock: e.target.checked })}
                />
                <span className="workbench__midi-badge-label">Receives Clock</span>
              </label>
            </div>
          </div>
        );
      })()}

      {/* Connection badge (simplified — TRS standard + delete only) */}
      {selectedConnectionId && (() => {
        const conn = connections.find(c => c.id === selectedConnectionId);
        if (!conn) return null;
        const srcPos = portPositions.get(portKey(conn.sourceInstanceId, conn.sourceJackId));
        const tgtPos = portPositions.get(portKey(conn.targetInstanceId, conn.targetJackId));
        if (!srcPos || !tgtPos) return null;
        const mid = viewport.worldToScreen((srcPos.x + tgtPos.x) / 2, (srcPos.y + tgtPos.y) / 2);
        const showTrs = connHasTrs(conn);

        return (
          <div
            className="workbench__midi-badge"
            style={{ position: 'absolute', left: mid.x + 20, top: mid.y - 40 }}
          >
            {showTrs && (
              <div className="workbench__midi-badge-row">
                <span className="workbench__midi-badge-label">TRS:</span>
                <select
                  value={conn.trsMidiStandard ?? ''}
                  onChange={e => {
                    const val = e.target.value;
                    updateMidiConnection(conn.id, {
                      trsMidiStandard: val === '' ? null : val as MidiConnection['trsMidiStandard'],
                    });
                  }}
                >
                  <option value="">Unknown</option>
                  <option value="TRS-A">TRS-A</option>
                  <option value="TRS-B">TRS-B</option>
                  <option value="tip-active">Tip Active</option>
                  <option value="ring-active">Ring Active</option>
                </select>
              </div>
            )}
            <button
              className="workbench__power-action-btn workbench__power-action-btn--danger"
              style={{ alignSelf: 'flex-start', marginTop: 4 }}
              onClick={() => { removeMidiConnection(selectedConnectionId); setSelectedConnectionId(null); setWarningPopover(null); }}
            >
              Delete
            </button>
          </div>
        );
      })()}

      {/* Warning popover */}
      {warningPopover && (() => {
        const screenPos = viewport.worldToScreen(warningPopover.x, warningPopover.y);
        return (
          <div className="workbench__power-popover" style={{ position: 'absolute', left: screenPos.x, top: screenPos.y }}>
            <div className="workbench__power-popover-warnings">
              {warningPopover.warnings.map(w => {
                const conn = connections.find(c => c.id === warningPopover.connId);
                const acked = conn?.acknowledgedWarnings?.includes(w.key);
                return (
                  <div key={w.key} className="workbench__power-popover-warning">
                    <span>{w.message}</span>
                    {acked
                      ? <span className="workbench__power-popover-acked">Acknowledged</span>
                      : <button className="workbench__power-popover-btn" onClick={() => acknowledgeMidiWarning(warningPopover.connId, w.key)}>
                          {w.adapterImplication ? 'I have this adapter' : 'Got it'}
                        </button>
                    }
                  </div>
                );
              })}
            </div>
            <button className="workbench__power-popover-btn workbench__power-popover-btn--close" onClick={() => setWarningPopover(null)}>Close</button>
          </div>
        );
      })()}
    </div>
  );
};

export default MidiView;
