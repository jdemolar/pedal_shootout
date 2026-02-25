import { useState, useCallback, useMemo, useEffect, useRef } from 'react';
import { Group, Rect, Text, Circle } from 'react-konva';
import Konva from 'konva';
import { useWorkbench } from '../../context/WorkbenchContext';
import { AudioConnection, VirtualNode } from '../../types/connections';
import { WorkbenchRow } from './WorkbenchTable';
import {
  getAudioInputJacks,
  getAudioOutputJacks,
  hasAudioJacks,
  getStereoPartner,
  validateAudioConnection,
} from '../../utils/audioUtils';
import { ConnectionValidation, ConnectionWarning } from '../../utils/connectionValidation';
import { Jack } from '../../utils/transformers';
import { useCanvasViewport } from '../../hooks/useCanvasViewport';
import { calculateBoundingBox } from '../../utils/canvasUtils';
import CanvasBase from './CanvasBase';
import ProductCard, { CARD_WIDTH, CARD_HEIGHT } from './ProductCard';
import PortDot from './PortDot';
import ConnectionLine from './ConnectionLine';
import ZoomControls from './ZoomControls';

const VIEW_KEY = 'audio';

const PORT_SPACING = 18;
const PORT_START_Y = 12;

const VIRTUAL_NODE_WIDTH = 100;
const VIRTUAL_NODE_HEIGHT = 48;

// Guitar on right, amp on left — right-to-left signal flow
const DEFAULT_AMP_X = 40;
const DEFAULT_ITEM_X_START = 240;
const DEFAULT_ITEM_X_STEP = 200;
const DEFAULT_GUITAR_X = (n: number) => DEFAULT_ITEM_X_START + n * DEFAULT_ITEM_X_STEP + 40;
const DEFAULT_CENTER_Y = 200;

/** Composite key for a port on a specific instance */
function portKey(instanceId: string, jackId: number | string): string {
  return `${instanceId}:${jackId}`;
}

/** Virtual jack for a virtual node treated as a real audio jack for validation */
function virtualJack(connectorType: string) {
  return {
    connector_type: connectorType,
    group_id: null as string | null,
    impedance_ohms: null as number | null,
  };
}

interface PendingConnection {
  jackId: number | string;
  instanceId: string;
  compositeKey: string;
  direction: 'output' | 'input';
}

interface StereoPrompt {
  sourceJackId: number | string;
  sourceInstanceId: string;
  targetJackId: number | string;
  targetInstanceId: string;
  x: number; // screen coords
  y: number;
}

interface AudioViewProps {
  rows: WorkbenchRow[];
}

const AudioView = ({ rows }: AudioViewProps) => {
  const {
    getViewPositions,
    updateViewPosition,
    addAudioConnection,
    removeAudioConnection,
    setAudioConnections,
    acknowledgeAudioWarning,
    updateAudioConnectionWaypoints,
    setVirtualNodes,
    activeWorkbench,
  } = useWorkbench();

  const savedPositions = getViewPositions(VIEW_KEY);
  const connections: AudioConnection[] = activeWorkbench.audioConnections ?? [];
  const virtualNodes: VirtualNode[] = activeWorkbench.virtualNodes ?? [];

  const viewport = useCanvasViewport(VIEW_KEY);
  const [stageDims, setStageDims] = useState({ width: 800, height: 600 });

  const handleDimensionsChange = useCallback((width: number, height: number) => {
    setStageDims({ width, height });
  }, []);

  // Auto-init virtual nodes (guitar + amp) on first mount
  useEffect(() => {
    if (!activeWorkbench.virtualNodes || activeWorkbench.virtualNodes.length === 0) {
      setVirtualNodes([
        {
          instanceId: 'virtual:guitar-1',
          nodeType: 'guitar_input',
          label: 'Guitar',
          virtualJackId: 'virtual-jack:guitar-out',
          connectorType: '1/4" TS',
        },
        {
          instanceId: 'virtual:amp-1',
          nodeType: 'amp_input',
          label: 'Amp',
          virtualJackId: 'virtual-jack:amp-in',
          connectorType: '1/4" TS',
        },
      ]);
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  // Interaction state
  const [pendingSource, setPendingSource] = useState<PendingConnection | null>(null);
  const [selectedConnectionId, setSelectedConnectionId] = useState<string | null>(null);
  const [mousePos, setMousePos] = useState<{ x: number; y: number } | null>(null);
  const [warningPopover, setWarningPopover] = useState<{
    connId: string;
    warnings: ConnectionWarning[];
    x: number;
    y: number;
  } | null>(null);
  const [stereoPrompt, setStereoPrompt] = useState<StereoPrompt | null>(null);
  const [editingNodeId, setEditingNodeId] = useState<string | null>(null);
  const [editingNodeLabel, setEditingNodeLabel] = useState('');
  const editInputRef = useRef<HTMLInputElement>(null);

  // Rows that have audio jacks
  const audioRows = useMemo(() => rows.filter(hasAudioJacks), [rows]);

  // Jack lookup by id
  const jackMap = useMemo(() => {
    const map = new Map<number, Jack>();
    for (const row of rows) {
      for (const jack of row.jacks) {
        map.set(jack.id, jack);
      }
    }
    return map;
  }, [rows]);

  // Row lookup by instanceId
  const rowMap = useMemo(() => {
    const map = new Map<string, WorkbenchRow>();
    for (const row of rows) map.set(row.instanceId, row);
    return map;
  }, [rows]);

  // Default positions for audio rows
  const audioRowEntries = useMemo(() => {
    return audioRows.map((row, i) => ({
      instanceId: row.instanceId,
      row,
      defaultX: DEFAULT_ITEM_X_START + i * DEFAULT_ITEM_X_STEP,
      defaultY: DEFAULT_CENTER_Y,
    }));
  }, [audioRows]);

  const getPosition = useCallback((instanceId: string, fallbackX: number, fallbackY: number) => {
    return savedPositions[instanceId] ?? { x: fallbackX, y: fallbackY };
  }, [savedPositions]);

  // Port absolute positions (world coords) — keyed by portKey
  const portPositions = useMemo(() => {
    const map = new Map<string, { x: number; y: number }>();

    // Real product cards
    for (const entry of audioRowEntries) {
      const pos = getPosition(entry.instanceId, entry.defaultX, entry.defaultY);
      const inputJacks = getAudioInputJacks(entry.row);
      const outputJacks = getAudioOutputJacks(entry.row);

      // Outputs on left (x ≈ 2), inputs on right (x ≈ CARD_WIDTH - 2)
      outputJacks.forEach((jack, i) => {
        map.set(portKey(entry.instanceId, jack.id), {
          x: pos.x + 2,
          y: pos.y + PORT_START_Y + i * PORT_SPACING,
        });
      });
      inputJacks.forEach((jack, i) => {
        map.set(portKey(entry.instanceId, jack.id), {
          x: pos.x + CARD_WIDTH - 2,
          y: pos.y + PORT_START_Y + i * PORT_SPACING,
        });
      });
    }

    // Virtual nodes
    const numAudio = audioRows.length;
    virtualNodes.forEach((node) => {
      const isGuitar = node.nodeType === 'guitar_input';
      const fallbackX = isGuitar
        ? DEFAULT_GUITAR_X(numAudio)
        : DEFAULT_AMP_X;
      const pos = getPosition(node.instanceId, fallbackX, DEFAULT_CENTER_Y);
      // Guitar: output on left side; Amp: input on right side
      const portX = isGuitar
        ? pos.x + 2
        : pos.x + VIRTUAL_NODE_WIDTH - 2;
      map.set(portKey(node.instanceId, node.virtualJackId), {
        x: portX,
        y: pos.y + VIRTUAL_NODE_HEIGHT / 2,
      });
    });

    return map;
  }, [audioRowEntries, virtualNodes, getPosition, audioRows.length]);

  // Validate connections
  const connectionValidations = useMemo(() => {
    const map = new Map<string, ConnectionValidation>();
    for (const conn of connections) {
      const isSourceVirtual = typeof conn.sourceJackId === 'string';
      const isTargetVirtual = typeof conn.targetJackId === 'string';

      const sourceNode = isSourceVirtual
        ? virtualNodes.find(n => n.virtualJackId === conn.sourceJackId)
        : null;
      const targetNode = isTargetVirtual
        ? virtualNodes.find(n => n.virtualJackId === conn.targetJackId)
        : null;

      const sourceJackData = isSourceVirtual && sourceNode
        ? virtualJack(sourceNode.connectorType)
        : jackMap.get(conn.sourceJackId as number) ?? null;
      const targetJackData = isTargetVirtual && targetNode
        ? virtualJack(targetNode.connectorType)
        : jackMap.get(conn.targetJackId as number) ?? null;

      if (sourceJackData && targetJackData) {
        map.set(conn.id, validateAudioConnection(
          sourceJackData,
          targetJackData,
          conn.signalMode,
          conn.signalMode,
          connections.filter(c => c.id !== conn.id),
          conn.sourceInstanceId,
          conn.targetInstanceId,
        ));
      } else {
        map.set(conn.id, { status: 'valid' as const, warnings: [] });
      }
    }
    return map;
  }, [connections, virtualNodes, jackMap]);

  const handleDragEnd = useCallback((instanceId: string, x: number, y: number) => {
    updateViewPosition(VIEW_KEY, instanceId, x, y);
  }, [updateViewPosition]);

  // Derive signal mode for a real jack
  const getSignalMode = useCallback((jack: Jack, row: WorkbenchRow): 'mono' | 'stereo' => {
    if (!jack.group_id) return 'mono';
    const partner = getStereoPartner(jack, row.jacks);
    return partner ? 'stereo' : 'mono';
  }, []);

  // --- Connection interaction ---

  const handlePortClick = useCallback((instanceId: string, jackId: number | string, direction: 'output' | 'input') => {
    const key = portKey(instanceId, jackId);

    if (!pendingSource) {
      setPendingSource({ jackId, instanceId, compositeKey: key, direction });
      setMousePos(null);
      setSelectedConnectionId(null);
      setWarningPopover(null);
      setStereoPrompt(null);
    } else if (pendingSource.compositeKey === key) {
      // Clicked same port — cancel
      setPendingSource(null);
      setMousePos(null);
    } else if (pendingSource.direction === direction) {
      // Same direction — swap pending to new port
      setPendingSource({ jackId, instanceId, compositeKey: key, direction });
      setMousePos(null);
    } else {
      // Valid pair — determine source (output) and target (input)
      const sourceJackId = direction === 'input' ? pendingSource.jackId : jackId;
      const targetJackId = direction === 'input' ? jackId : pendingSource.jackId;
      const sourceInstanceId = direction === 'input' ? pendingSource.instanceId : instanceId;
      const targetInstanceId = direction === 'input' ? instanceId : pendingSource.instanceId;

      // Check if both are real jacks with group_id for stereo prompt
      const sourceJack = typeof sourceJackId === 'number' ? jackMap.get(sourceJackId) : null;
      const targetJack = typeof targetJackId === 'number' ? jackMap.get(targetJackId) : null;
      const sourceRow = rowMap.get(sourceInstanceId);
      const targetRow = rowMap.get(targetInstanceId);
      const sourceHasStereo = sourceJack && sourceRow
        ? sourceJack.group_id !== null && !!getStereoPartner(sourceJack, sourceRow.jacks)
        : false;
      const targetHasStereo = targetJack && targetRow
        ? targetJack.group_id !== null && !!getStereoPartner(targetJack, targetRow.jacks)
        : false;

      if (sourceHasStereo && targetHasStereo) {
        // Show stereo prompt at midpoint (screen coords)
        const srcPos = portPositions.get(portKey(sourceInstanceId, sourceJackId));
        const tgtPos = portPositions.get(portKey(targetInstanceId, targetJackId));
        const midWorld = srcPos && tgtPos
          ? { x: (srcPos.x + tgtPos.x) / 2, y: (srcPos.y + tgtPos.y) / 2 }
          : { x: stageDims.width / 2, y: stageDims.height / 2 };
        const midScreen = viewport.worldToScreen(midWorld.x, midWorld.y);

        setStereoPrompt({
          sourceJackId,
          sourceInstanceId,
          targetJackId,
          targetInstanceId,
          x: midScreen.x,
          y: midScreen.y - 40,
        });
        setPendingSource(null);
        setMousePos(null);
      } else {
        createConnection(sourceJackId, sourceInstanceId, targetJackId, targetInstanceId, 'mono', null);
        setPendingSource(null);
        setMousePos(null);
      }
    }
  }, [pendingSource, jackMap, rowMap, portPositions, viewport, stageDims]);

  const createConnection = useCallback((
    sourceJackId: number | string,
    sourceInstanceId: string,
    targetJackId: number | string,
    targetInstanceId: string,
    signalMode: 'mono' | 'stereo',
    stereoPairConnectionId: string | null,
  ) => {
    addAudioConnection({
      sourceJackId,
      targetJackId,
      sourceInstanceId,
      targetInstanceId,
      orderIndex: connections.length,
      parallelPathId: null,
      fxLoopGroupId: null,
      signalMode,
      stereoPairConnectionId,
      waypoints: [],
    });
  }, [addAudioConnection, connections.length]);

  const handleStereoConfirm = useCallback((asStereo: boolean) => {
    if (!stereoPrompt) return;
    const { sourceJackId, sourceInstanceId, targetJackId, targetInstanceId } = stereoPrompt;

    if (asStereo) {
      const srcJack = typeof sourceJackId === 'number' ? jackMap.get(sourceJackId) : null;
      const tgtJack = typeof targetJackId === 'number' ? jackMap.get(targetJackId) : null;
      const srcRow = rowMap.get(sourceInstanceId);
      const tgtRow = rowMap.get(targetInstanceId);
      const srcPartner = srcJack && srcRow ? getStereoPartner(srcJack, srcRow.jacks) : undefined;
      const tgtPartner = tgtJack && tgtRow ? getStereoPartner(tgtJack, tgtRow.jacks) : undefined;

      const primaryId = crypto.randomUUID ? crypto.randomUUID() : `${Date.now()}-primary`;
      addAudioConnection({
        sourceJackId,
        targetJackId,
        sourceInstanceId,
        targetInstanceId,
        orderIndex: connections.length,
        parallelPathId: null,
        fxLoopGroupId: null,
        signalMode: 'stereo',
        stereoPairConnectionId: null,
        waypoints: [],
      });

      if (srcPartner && tgtPartner) {
        addAudioConnection({
          sourceJackId: srcPartner.id,
          targetJackId: tgtPartner.id,
          sourceInstanceId,
          targetInstanceId,
          orderIndex: connections.length + 1,
          parallelPathId: null,
          fxLoopGroupId: null,
          signalMode: 'stereo',
          stereoPairConnectionId: primaryId,
          waypoints: [],
        });
      }
    } else {
      createConnection(sourceJackId, sourceInstanceId, targetJackId, targetInstanceId, 'mono', null);
    }

    setStereoPrompt(null);
  }, [stereoPrompt, jackMap, rowMap, addAudioConnection, connections.length, createConnection]);

  // Mouse tracking for preview line
  const handleStageMouseMove = useCallback((e: Konva.KonvaEventObject<MouseEvent>) => {
    if (!pendingSource) return;
    const stage = e.target.getStage();
    if (stage) {
      const pos = stage.getPointerPosition();
      if (pos) {
        const world = viewport.screenToWorld(pos.x, pos.y);
        setMousePos(world);
      }
    }
  }, [pendingSource, viewport]);

  const handleStageClick = useCallback((e: Konva.KonvaEventObject<MouseEvent>) => {
    if (e.target === e.target.getStage()) {
      setPendingSource(null);
      setSelectedConnectionId(null);
      setWarningPopover(null);
      setStereoPrompt(null);
    }
  }, []);

  const handleConnectionClick = useCallback((connId: string) => {
    const validation = connectionValidations.get(connId);
    const conn = connections.find(c => c.id === connId);

    if (validation && validation.warnings.length > 0 && conn) {
      const sourcePos = portPositions.get(portKey(conn.sourceInstanceId, conn.sourceJackId));
      const targetPos = portPositions.get(portKey(conn.targetInstanceId, conn.targetJackId));
      if (sourcePos && targetPos) {
        setWarningPopover({
          connId,
          warnings: validation.warnings,
          x: (sourcePos.x + targetPos.x) / 2,
          y: (sourcePos.y + targetPos.y) / 2 - 30,
        });
      }
    }

    setSelectedConnectionId(connId);
    setPendingSource(null);
    setStereoPrompt(null);
  }, [connectionValidations, connections, portPositions]);

  // Add waypoint on dblclick of a connection line
  const handleConnectionDblClick = useCallback((connId: string, e: Konva.KonvaEventObject<MouseEvent>) => {
    const conn = connections.find(c => c.id === connId);
    if (!conn) return;

    const stage = (e.target as Konva.Node).getStage();
    if (!stage) return;
    const pos = stage.getPointerPosition();
    if (!pos) return;
    const world = viewport.screenToWorld(pos.x, pos.y);

    // Insert at nearest segment
    const pts = buildConnectionPoints(conn);
    let minDist = Infinity;
    let insertIdx = conn.waypoints.length;
    for (let i = 0; i < pts.length - 1; i++) {
      const ax = pts[i].x, ay = pts[i].y;
      const bx = pts[i + 1].x, by = pts[i + 1].y;
      const mx = (ax + bx) / 2, my = (ay + by) / 2;
      const d = Math.hypot(world.x - mx, world.y - my);
      if (d < minDist) { minDist = d; insertIdx = i; }
    }

    const newWaypoints = [...conn.waypoints];
    newWaypoints.splice(insertIdx, 0, { x: world.x, y: world.y });
    updateAudioConnectionWaypoints(connId, newWaypoints);
  }, [connections, viewport, updateAudioConnectionWaypoints]);

  // Build the sequence of points for a connection (start → waypoints → end)
  function buildConnectionPoints(conn: AudioConnection): Array<{ x: number; y: number }> {
    const src = portPositions.get(portKey(conn.sourceInstanceId, conn.sourceJackId));
    const tgt = portPositions.get(portKey(conn.targetInstanceId, conn.targetJackId));
    if (!src || !tgt) return [];
    return [src, ...conn.waypoints, tgt];
  }

  const handleKeyDown = useCallback((e: KeyboardEvent) => {
    if ((e.key === 'Delete' || e.key === 'Backspace') && selectedConnectionId && !editingNodeId) {
      removeAudioConnection(selectedConnectionId);
      setSelectedConnectionId(null);
      setWarningPopover(null);
    }
    if (e.key === 'Escape') {
      setPendingSource(null);
      setSelectedConnectionId(null);
      setWarningPopover(null);
      setStereoPrompt(null);
      setEditingNodeId(null);
    }
  }, [selectedConnectionId, editingNodeId, removeAudioConnection]);

  useEffect(() => {
    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [handleKeyDown]);

  // Focus edit input when it appears
  useEffect(() => {
    if (editingNodeId && editInputRef.current) {
      editInputRef.current.focus();
      editInputRef.current.select();
    }
  }, [editingNodeId]);

  const handleFitAll = useCallback(() => {
    const cards: Array<{ x: number; y: number; width: number; height: number }> = [];

    for (const entry of audioRowEntries) {
      const pos = getPosition(entry.instanceId, entry.defaultX, entry.defaultY);
      cards.push({ x: pos.x, y: pos.y, width: CARD_WIDTH, height: CARD_HEIGHT });
    }

    const numAudio = audioRows.length;
    for (const node of virtualNodes) {
      const isGuitar = node.nodeType === 'guitar_input';
      const fallbackX = isGuitar ? DEFAULT_GUITAR_X(numAudio) : DEFAULT_AMP_X;
      const pos = getPosition(node.instanceId, fallbackX, DEFAULT_CENTER_Y);
      cards.push({ x: pos.x, y: pos.y, width: VIRTUAL_NODE_WIDTH, height: VIRTUAL_NODE_HEIGHT });
    }

    if (cards.length === 0) return;
    const bbox = calculateBoundingBox(cards);
    viewport.fitAll(bbox, stageDims.width, stageDims.height);
  }, [audioRowEntries, virtualNodes, getPosition, audioRows.length, viewport, stageDims]);

  const pendingSourcePos = pendingSource ? portPositions.get(pendingSource.compositeKey) : null;

  const numAudio = audioRows.length;

  if (rows.length === 0) {
    return (
      <div className="workbench__canvas-placeholder">
        Your workbench is empty. Add products from the catalog views.
      </div>
    );
  }

  if (audioRows.length === 0 && virtualNodes.length === 0) {
    return (
      <div className="workbench__canvas-placeholder">
        No items with audio connections in this workbench.
      </div>
    );
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
          const sourcePos = portPositions.get(portKey(conn.sourceInstanceId, conn.sourceJackId));
          const targetPos = portPositions.get(portKey(conn.targetInstanceId, conn.targetJackId));
          if (!sourcePos || !targetPos) return null;

          const validation = connectionValidations.get(conn.id) ?? { status: 'valid' as const, warnings: [] };
          const isAcknowledged = (conn.acknowledgedWarnings?.length ?? 0) > 0 &&
            validation.warnings.every(w => conn.acknowledgedWarnings?.includes(w.key));

          return (
            <ConnectionLine
              key={conn.id}
              sourceX={sourcePos.x}
              sourceY={sourcePos.y}
              targetX={targetPos.x}
              targetY={targetPos.y}
              status={validation.status}
              acknowledged={isAcknowledged}
              selected={selectedConnectionId === conn.id}
              waypoints={conn.waypoints}
              onClick={() => handleConnectionClick(conn.id)}
              onDblClick={(e) => handleConnectionDblClick(conn.id, e)}
            />
          );
        })}

        {/* Waypoint circles for selected connection */}
        {selectedConnectionId && (() => {
          const conn = connections.find(c => c.id === selectedConnectionId);
          if (!conn || conn.waypoints.length === 0) return null;
          return conn.waypoints.map((wp, idx) => (
            <Circle
              key={`wp-${conn.id}-${idx}`}
              x={wp.x}
              y={wp.y}
              radius={5}
              fill="#d4a55a"
              stroke="#fff"
              strokeWidth={1}
              draggable
              onDragEnd={(e: Konva.KonvaEventObject<DragEvent>) => {
                const newWaypoints = [...conn.waypoints];
                newWaypoints[idx] = { x: e.target.x(), y: e.target.y() };
                updateAudioConnectionWaypoints(conn.id, newWaypoints);
              }}
              onDblClick={() => {
                const newWaypoints = conn.waypoints.filter((_, i) => i !== idx);
                updateAudioConnectionWaypoints(conn.id, newWaypoints);
              }}
              onDblTap={() => {
                const newWaypoints = conn.waypoints.filter((_, i) => i !== idx);
                updateAudioConnectionWaypoints(conn.id, newWaypoints);
              }}
            />
          ));
        })()}

        {/* Preview line while creating a connection */}
        {pendingSource && pendingSourcePos && mousePos && (
          <ConnectionLine
            sourceX={pendingSourcePos.x}
            sourceY={pendingSourcePos.y}
            targetX={mousePos.x}
            targetY={mousePos.y}
            status="valid"
          />
        )}

        {/* Product cards with audio port dots */}
        {audioRowEntries.map((entry) => {
          const pos = getPosition(entry.instanceId, entry.defaultX, entry.defaultY);
          const inputJacks = getAudioInputJacks(entry.row);
          const outputJacks = getAudioOutputJacks(entry.row);

          return (
            <ProductCard
              key={entry.instanceId}
              productType={entry.row.product_type}
              manufacturer={entry.row.manufacturer}
              model={entry.row.model}
              x={pos.x}
              y={pos.y}
              onDragEnd={(x, y) => handleDragEnd(entry.instanceId, x, y)}
            >
              {/* Output jacks — left side (x ≈ 2) */}
              {outputJacks.map((jack, i) => {
                const key = portKey(entry.instanceId, jack.id);
                const signalMode = getSignalMode(jack, entry.row);
                return (
                  <PortDot
                    key={key}
                    x={2}
                    y={PORT_START_Y + i * PORT_SPACING}
                    jackId={jack.id}
                    label={jack.jack_name ?? (signalMode === 'stereo' ? 'Out (L/R)' : 'Out')}
                    direction="output"
                    color={pendingSource?.compositeKey === key ? '#fff' : '#6aaa6a'}
                    onClick={() => handlePortClick(entry.instanceId, jack.id, 'output')}
                  />
                );
              })}

              {/* Input jacks — right side (x ≈ CARD_WIDTH - 2) */}
              {inputJacks.map((jack, i) => {
                const key = portKey(entry.instanceId, jack.id);
                const signalMode = getSignalMode(jack, entry.row);
                return (
                  <PortDot
                    key={key}
                    x={CARD_WIDTH - 2}
                    y={PORT_START_Y + i * PORT_SPACING}
                    jackId={jack.id}
                    label={jack.jack_name ?? (signalMode === 'stereo' ? 'In (L/R)' : 'In')}
                    direction="input"
                    color={pendingSource?.compositeKey === key ? '#fff' : '#6a6aaa'}
                    onClick={() => handlePortClick(entry.instanceId, jack.id, 'input')}
                  />
                );
              })}
            </ProductCard>
          );
        })}

        {/* Virtual node cards */}
        {virtualNodes.map((node) => {
          const isGuitar = node.nodeType === 'guitar_input';
          const fallbackX = isGuitar ? DEFAULT_GUITAR_X(numAudio) : DEFAULT_AMP_X;
          const pos = getPosition(node.instanceId, fallbackX, DEFAULT_CENTER_Y);
          const portX = isGuitar ? 2 : VIRTUAL_NODE_WIDTH - 2;
          const portDirection = isGuitar ? 'output' : 'input';
          const portKey_ = portKey(node.instanceId, node.virtualJackId);

          return (
            <Group
              key={node.instanceId}
              x={pos.x}
              y={pos.y}
              draggable
              onDragEnd={(e: Konva.KonvaEventObject<DragEvent>) => {
                handleDragEnd(node.instanceId, e.target.x(), e.target.y());
              }}
            >
              <Rect
                width={VIRTUAL_NODE_WIDTH}
                height={VIRTUAL_NODE_HEIGHT}
                fill="#1a2a2a"
                stroke="#3a7070"
                strokeWidth={1}
                cornerRadius={4}
              />
              <Text
                x={8}
                y={10}
                width={VIRTUAL_NODE_WIDTH - 16}
                text={node.label}
                fontSize={12}
                fontFamily="'SF Mono', 'Fira Code', monospace"
                fill="#6adada"
                align="center"
                onDblClick={() => {
                  setEditingNodeId(node.instanceId);
                  setEditingNodeLabel(node.label);
                }}
                onDblTap={() => {
                  setEditingNodeId(node.instanceId);
                  setEditingNodeLabel(node.label);
                }}
              />
              <Text
                x={8}
                y={28}
                width={VIRTUAL_NODE_WIDTH - 16}
                text={node.connectorType}
                fontSize={9}
                fontFamily="monospace"
                fill="#555"
                align="center"
                listening={false}
              />
              {/* Port dot */}
              <Circle
                x={portX}
                y={VIRTUAL_NODE_HEIGHT / 2}
                radius={6}
                fill={pendingSource?.compositeKey === portKey_ ? '#fff' : '#6adada'}
                stroke="#6adada"
                strokeWidth={1}
                onClick={() => handlePortClick(node.instanceId, node.virtualJackId, portDirection)}
                onTap={() => handlePortClick(node.instanceId, node.virtualJackId, portDirection)}
              />
            </Group>
          );
        })}
      </CanvasBase>

      {/* Inline label editor for virtual nodes */}
      {editingNodeId && (() => {
        const node = virtualNodes.find(n => n.instanceId === editingNodeId);
        if (!node) return null;
        const isGuitar = node.nodeType === 'guitar_input';
        const fallbackX = isGuitar ? DEFAULT_GUITAR_X(numAudio) : DEFAULT_AMP_X;
        const pos = getPosition(editingNodeId, fallbackX, DEFAULT_CENTER_Y);
        const screenPos = viewport.worldToScreen(pos.x + 8, pos.y + 8);
        return (
          <input
            ref={editInputRef}
            style={{
              position: 'absolute',
              left: screenPos.x,
              top: screenPos.y,
              width: (VIRTUAL_NODE_WIDTH - 16) * viewport.scale,
              fontSize: 12 * viewport.scale,
              background: '#1a2a2a',
              color: '#6adada',
              border: '1px solid #3a7070',
              borderRadius: 2,
              padding: '2px 4px',
            }}
            value={editingNodeLabel}
            onChange={e => setEditingNodeLabel(e.target.value)}
            onKeyDown={e => {
              if (e.key === 'Enter' || e.key === 'Escape') {
                if (e.key === 'Enter' && editingNodeLabel.trim()) {
                  const updatedNodes = virtualNodes.map(n =>
                    n.instanceId === editingNodeId
                      ? { ...n, label: editingNodeLabel.trim() }
                      : n,
                  );
                  setVirtualNodes(updatedNodes);
                }
                setEditingNodeId(null);
              }
            }}
            onBlur={() => {
              if (editingNodeLabel.trim()) {
                const updatedNodes = virtualNodes.map(n =>
                  n.instanceId === editingNodeId
                    ? { ...n, label: editingNodeLabel.trim() }
                    : n,
                );
                setVirtualNodes(updatedNodes);
              }
              setEditingNodeId(null);
            }}
          />
        );
      })()}

      {/* Stereo pair prompt */}
      {stereoPrompt && (
        <div
          className="workbench__audio-prompt"
          style={{ position: 'absolute', left: stereoPrompt.x, top: stereoPrompt.y }}
        >
          <span className="workbench__audio-prompt-msg">Connect as stereo pair?</span>
          <button
            className="workbench__power-action-btn"
            onClick={() => handleStereoConfirm(true)}
          >
            Yes
          </button>
          <button
            className="workbench__power-action-btn"
            onClick={() => handleStereoConfirm(false)}
          >
            Just this jack
          </button>
          <button
            className="workbench__power-action-btn"
            onClick={() => setStereoPrompt(null)}
          >
            Cancel
          </button>
        </div>
      )}

      {/* Canvas action buttons */}
      <div className="workbench__power-actions">
        {connections.length > 0 && (
          <button
            className="workbench__power-action-btn workbench__power-action-btn--danger"
            onClick={() => {
              if (window.confirm(`Clear all ${connections.length} connection${connections.length === 1 ? '' : 's'}?`)) {
                setAudioConnections([]);
                setSelectedConnectionId(null);
                setWarningPopover(null);
              }
            }}
            title="Remove all connections"
          >
            Clear all
          </button>
        )}
      </div>

      {/* Zoom controls */}
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
        const midWorld = { x: (srcPos.x + tgtPos.x) / 2, y: (srcPos.y + tgtPos.y) / 2 };
        const midScreen = viewport.worldToScreen(midWorld.x, midWorld.y);
        return (
          <button
            className="workbench__power-delete-btn"
            style={{ position: 'absolute', left: midScreen.x, top: midScreen.y }}
            title="Delete connection"
            onClick={() => {
              removeAudioConnection(selectedConnectionId);
              setSelectedConnectionId(null);
              setWarningPopover(null);
            }}
          >
            ×
          </button>
        );
      })()}

      {/* Warning popover */}
      {warningPopover && (() => {
        const screenPos = viewport.worldToScreen(warningPopover.x, warningPopover.y);
        return (
          <div
            className="workbench__power-popover"
            style={{ position: 'absolute', left: screenPos.x, top: screenPos.y }}
          >
            <div className="workbench__power-popover-warnings">
              {warningPopover.warnings.map((w) => {
                const conn = connections.find(c => c.id === warningPopover.connId);
                const alreadyAcked = conn?.acknowledgedWarnings?.includes(w.key);
                return (
                  <div key={w.key} className="workbench__power-popover-warning">
                    <span>{w.message}</span>
                    {alreadyAcked ? (
                      <span className="workbench__power-popover-acked">Acknowledged</span>
                    ) : (
                      <button
                        className="workbench__power-popover-btn"
                        onClick={() => acknowledgeAudioWarning(warningPopover.connId, w.key)}
                      >
                        {w.adapterImplication ? 'I have this adapter' : 'Got it'}
                      </button>
                    )}
                  </div>
                );
              })}
            </div>
            <button
              className="workbench__power-popover-btn workbench__power-popover-btn--close"
              onClick={() => setWarningPopover(null)}
            >
              Close
            </button>
          </div>
        );
      })()}
    </div>
  );
};

export default AudioView;
