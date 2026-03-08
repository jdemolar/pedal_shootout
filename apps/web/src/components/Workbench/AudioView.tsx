import { useState, useCallback, useMemo, useEffect, useRef } from 'react';
import { Group, Rect, Text, Circle } from 'react-konva';
import Konva from 'konva';
import { useWorkbench } from '../../context/WorkbenchContext';
import { AudioConnection, VirtualNode, VirtualNodeType, AudioPlaceholder, VirtualJackSpec } from '../../types/connections';
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
// Ports start just below the card's text content area (type label is at y=44)
const AUDIO_PORT_START_Y = CARD_HEIGHT - 4;
const AUDIO_PORT_EXTRA = PORT_SPACING;

const VIRTUAL_NODE_WIDTH = 100;
const VIRTUAL_NODE_HEIGHT = 48;

const DEFAULT_AMP_X = 40;
const DEFAULT_ITEM_X_START = 200;
const DEFAULT_ITEM_X_STEP = 200;
const DEFAULT_CENTER_Y = 180;

function audioCardHeight(inputCount: number, outputCount: number): number {
  const portCount = Math.max(inputCount, outputCount);
  if (portCount <= 1) return CARD_HEIGHT;
  return CARD_HEIGHT + (portCount - 1) * AUDIO_PORT_EXTRA;
}

function portKey(instanceId: string, jackId: number | string): string {
  return `${instanceId}:${jackId}`;
}

// --- Placeholder presets ---

function generateId(): string {
  if (typeof crypto !== 'undefined' && typeof crypto.randomUUID === 'function') {
    return crypto.randomUUID();
  }
  return Date.now().toString(36) + Math.random().toString(36).substring(2);
}

function makePlaceholderJack(
  instanceId: string,
  direction: 'input' | 'output',
  index: number,
  label: string,
  connectorType = '1/4" TS',
  group_id: string | null = null,
): VirtualJackSpec {
  return {
    virtualJackId: `placeholder:${instanceId}:${direction}-${index}`,
    direction,
    connectorType,
    label,
    group_id,
  };
}

const PLACEHOLDER_PRESETS: Array<{
  label: string;
  description: string;
  build: (instanceId: string) => VirtualJackSpec[];
}> = [
  {
    label: 'Mono pedal',
    description: '1× TS out, 1× TS in',
    build: (id) => [
      makePlaceholderJack(id, 'output', 0, 'Out'),
      makePlaceholderJack(id, 'input', 0, 'In'),
    ],
  },
  {
    label: 'Stereo pedal',
    description: '2× TS out (L/R), 2× TS in (L/R)',
    build: (id) => {
      const outGroup = generateId();
      const inGroup = generateId();
      return [
        makePlaceholderJack(id, 'output', 0, 'Out L', '1/4" TS', outGroup),
        makePlaceholderJack(id, 'output', 1, 'Out R', '1/4" TS', outGroup),
        makePlaceholderJack(id, 'input', 0, 'In L', '1/4" TS', inGroup),
        makePlaceholderJack(id, 'input', 1, 'In R', '1/4" TS', inGroup),
      ];
    },
  },
  {
    label: 'Mono in / Stereo out',
    description: '2× TS out (L/R), 1× TS in',
    build: (id) => {
      const outGroup = generateId();
      return [
        makePlaceholderJack(id, 'output', 0, 'Out L', '1/4" TS', outGroup),
        makePlaceholderJack(id, 'output', 1, 'Out R', '1/4" TS', outGroup),
        makePlaceholderJack(id, 'input', 0, 'In'),
      ];
    },
  },
  {
    label: 'Mono FX loop',
    description: '1× TS out, 1× TS in, send + return',
    build: (id) => [
      makePlaceholderJack(id, 'output', 0, 'Out'),
      makePlaceholderJack(id, 'output', 1, 'FX Send'),
      makePlaceholderJack(id, 'input', 0, 'In'),
      makePlaceholderJack(id, 'input', 1, 'FX Return'),
    ],
  },
  {
    label: 'Stereo FX loop',
    description: '2× TS out, 2× TS in, send + return',
    build: (id) => {
      const outGroup = generateId();
      const inGroup = generateId();
      return [
        makePlaceholderJack(id, 'output', 0, 'Out L', '1/4" TS', outGroup),
        makePlaceholderJack(id, 'output', 1, 'Out R', '1/4" TS', outGroup),
        makePlaceholderJack(id, 'output', 2, 'FX Send'),
        makePlaceholderJack(id, 'input', 0, 'In L', '1/4" TS', inGroup),
        makePlaceholderJack(id, 'input', 1, 'In R', '1/4" TS', inGroup),
        makePlaceholderJack(id, 'input', 2, 'FX Return'),
      ];
    },
  },
];

// --- Additional virtual node presets ---

const ADDITIONAL_NODE_PRESETS: Array<{
  label: string;
  nodeType: VirtualNodeType;
  virtualJackId: (n: number) => string;
  connectorType: string;
}> = [
  { label: 'Amp',           nodeType: 'secondary_amp_input', virtualJackId: (n) => `virtual-jack:amp2-in-${n}`,    connectorType: '1/4" TS' },
  { label: 'FRFR / Speaker', nodeType: 'frfr_input',          virtualJackId: (n) => `virtual-jack:frfr-in-${n}`,   connectorType: '1/4" TS' },
  { label: 'Direct Out (FOH)', nodeType: 'direct_output',     virtualJackId: (n) => `virtual-jack:direct-out-${n}`, connectorType: 'XLR' },
  { label: 'Tuner Out',     nodeType: 'tuner_output',         virtualJackId: (n) => `virtual-jack:tuner-out-${n}`,  connectorType: '1/4" TS' },
];

// --- Virtual jack for validation ---

function virtualJackData(connectorType: string) {
  return { connector_type: connectorType, group_id: null as string | null, impedance_ohms: null as number | null };
}

// --- Pending connection state ---

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
  screenX: number;
  screenY: number;
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
    setVirtualNodes,
    addVirtualNode,
    removeVirtualNode,
    addAudioPlaceholder,
    removeAudioPlaceholder,
    updateAudioPlaceholderLabel,
    activeWorkbench,
  } = useWorkbench();

  const savedPositions = getViewPositions(VIEW_KEY);
  const connections: AudioConnection[] = activeWorkbench.audioConnections ?? [];
  const virtualNodes: VirtualNode[] = activeWorkbench.virtualNodes ?? [];
  const placeholders: AudioPlaceholder[] = activeWorkbench.audioPlaceholders ?? [];

  const viewport = useCanvasViewport(VIEW_KEY);
  const [stageDims, setStageDims] = useState({ width: 800, height: 600 });
  const handleDimensionsChange = useCallback((w: number, h: number) => setStageDims({ width: w, height: h }), []);

  // Auto-init default virtual nodes on first mount
  useEffect(() => {
    if (!activeWorkbench.virtualNodes || activeWorkbench.virtualNodes.length === 0) {
      setVirtualNodes([
        { instanceId: 'virtual:guitar-1', nodeType: 'guitar_input',  label: 'Guitar', virtualJackId: 'virtual-jack:guitar-out', connectorType: '1/4" TS' },
        { instanceId: 'virtual:amp-1',    nodeType: 'amp_input',     label: 'Amp',    virtualJackId: 'virtual-jack:amp-in',    connectorType: '1/4" TS' },
      ]);
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  // Interaction state
  const [pendingSource, setPendingSource] = useState<PendingConnection | null>(null);
  const [selectedConnectionId, setSelectedConnectionId] = useState<string | null>(null);
  const [selectedInstanceId, setSelectedInstanceId] = useState<string | null>(null); // for placeholders/nodes
  const [mousePos, setMousePos] = useState<{ x: number; y: number } | null>(null);
  const [warningPopover, setWarningPopover] = useState<{ connId: string; warnings: ConnectionWarning[]; x: number; y: number } | null>(null);
  const [stereoPrompt, setStereoPrompt] = useState<StereoPrompt | null>(null);
  const [editingId, setEditingId] = useState<string | null>(null);
  const [editingLabel, setEditingLabel] = useState('');
  const editInputRef = useRef<HTMLInputElement>(null);
  const [showPlaceholderMenu, setShowPlaceholderMenu] = useState(false);
  const [showNodeMenu, setShowNodeMenu] = useState(false);

  useEffect(() => {
    if (editingId && editInputRef.current) {
      editInputRef.current.focus();
      editInputRef.current.select();
    }
  }, [editingId]);

  // Rows with audio jacks
  const audioRows = useMemo(() => rows.filter(hasAudioJacks), [rows]);
  const missingRows = useMemo(() => rows.filter(r => !hasAudioJacks(r)), [rows]);

  // Jack lookup
  const jackMap = useMemo(() => {
    const map = new Map<number, Jack>();
    for (const row of rows) for (const jack of row.jacks) map.set(jack.id, jack);
    return map;
  }, [rows]);

  const rowMap = useMemo(() => {
    const map = new Map<string, WorkbenchRow>();
    for (const row of rows) map.set(row.instanceId, row);
    return map;
  }, [rows]);

  // Default layout positions for audio rows
  const audioRowEntries = useMemo(() =>
    audioRows.map((row, i) => ({
      instanceId: row.instanceId,
      row,
      defaultX: DEFAULT_ITEM_X_START + i * DEFAULT_ITEM_X_STEP,
      defaultY: DEFAULT_CENTER_Y,
    })),
  [audioRows]);

  // Default positions for placeholders (to the right of real items)
  const placeholderEntries = useMemo(() =>
    placeholders.map((p, i) => ({
      placeholder: p,
      defaultX: DEFAULT_ITEM_X_START + (audioRows.length + i) * DEFAULT_ITEM_X_STEP,
      defaultY: DEFAULT_CENTER_Y,
    })),
  [placeholders, audioRows.length]);

  const getPosition = useCallback((instanceId: string, fallbackX: number, fallbackY: number) =>
    savedPositions[instanceId] ?? { x: fallbackX, y: fallbackY },
  [savedPositions]);

  const numAudio = audioRows.length;
  const numPlaceholders = placeholders.length;

  // Virtual node default positions
  const getVirtualNodeDefault = useCallback((node: VirtualNode): { x: number; y: number } => {
    const isSource = node.nodeType === 'guitar_input';
    if (isSource) {
      return { x: DEFAULT_ITEM_X_START + (numAudio + numPlaceholders) * DEFAULT_ITEM_X_STEP + 40, y: DEFAULT_CENTER_Y };
    }
    return { x: DEFAULT_AMP_X, y: DEFAULT_CENTER_Y };
  }, [numAudio, numPlaceholders]);

  // Port positions (world coords) keyed by portKey
  const portPositions = useMemo(() => {
    const map = new Map<string, { x: number; y: number }>();

    // Real product cards
    for (const entry of audioRowEntries) {
      const pos = getPosition(entry.instanceId, entry.defaultX, entry.defaultY);
      const outputs = getAudioOutputJacks(entry.row);
      const inputs  = getAudioInputJacks(entry.row);
      outputs.forEach((jack, i) => map.set(portKey(entry.instanceId, jack.id), {
        x: pos.x + 2,
        y: pos.y + AUDIO_PORT_START_Y + i * PORT_SPACING,
      }));
      inputs.forEach((jack, i) => map.set(portKey(entry.instanceId, jack.id), {
        x: pos.x + CARD_WIDTH - 2,
        y: pos.y + AUDIO_PORT_START_Y + i * PORT_SPACING,
      }));
    }

    // Placeholder cards
    for (const entry of placeholderEntries) {
      const pos = getPosition(entry.placeholder.instanceId, entry.defaultX, entry.defaultY);
      const outputs = entry.placeholder.jacks.filter(j => j.direction === 'output');
      const inputs  = entry.placeholder.jacks.filter(j => j.direction === 'input');
      outputs.forEach((jack, i) => map.set(portKey(entry.placeholder.instanceId, jack.virtualJackId), {
        x: pos.x + 2,
        y: pos.y + AUDIO_PORT_START_Y + i * PORT_SPACING,
      }));
      inputs.forEach((jack, i) => map.set(portKey(entry.placeholder.instanceId, jack.virtualJackId), {
        x: pos.x + CARD_WIDTH - 2,
        y: pos.y + AUDIO_PORT_START_Y + i * PORT_SPACING,
      }));
    }

    // Virtual nodes
    for (const node of virtualNodes) {
      const def = getVirtualNodeDefault(node);
      const pos = getPosition(node.instanceId, def.x, def.y);
      const isSource = node.nodeType === 'guitar_input';
      map.set(portKey(node.instanceId, node.virtualJackId), {
        x: isSource ? pos.x + 2 : pos.x + VIRTUAL_NODE_WIDTH - 2,
        y: pos.y + VIRTUAL_NODE_HEIGHT / 2,
      });
    }

    return map;
  }, [audioRowEntries, placeholderEntries, virtualNodes, getPosition, getVirtualNodeDefault]);

  // Validate connections
  const connectionValidations = useMemo(() => {
    const map = new Map<string, ConnectionValidation>();
    for (const conn of connections) {
      const srcIsVirtual = typeof conn.sourceJackId === 'string';
      const tgtIsVirtual = typeof conn.targetJackId === 'string';

      const srcNode = srcIsVirtual ? virtualNodes.find(n => n.virtualJackId === conn.sourceJackId) : null;
      const tgtNode = tgtIsVirtual ? virtualNodes.find(n => n.virtualJackId === conn.targetJackId) : null;

      // Also check placeholder jacks
      const findPlaceholderJack = (id: string | number): VirtualJackSpec | undefined => {
        for (const p of placeholders) {
          const j = p.jacks.find(j => j.virtualJackId === id);
          if (j) return j;
        }
        return undefined;
      };

      const srcJack = srcIsVirtual
        ? (srcNode ? virtualJackData(srcNode.connectorType) : (findPlaceholderJack(conn.sourceJackId) ? virtualJackData(findPlaceholderJack(conn.sourceJackId)!.connectorType) : null))
        : (jackMap.get(conn.sourceJackId as number) ?? null);
      const tgtJack = tgtIsVirtual
        ? (tgtNode ? virtualJackData(tgtNode.connectorType) : (findPlaceholderJack(conn.targetJackId) ? virtualJackData(findPlaceholderJack(conn.targetJackId)!.connectorType) : null))
        : (jackMap.get(conn.targetJackId as number) ?? null);

      if (srcJack && tgtJack) {
        map.set(conn.id, validateAudioConnection(
          srcJack, tgtJack,
          conn.signalMode, conn.signalMode,
          connections.filter(c => c.id !== conn.id),
          conn.sourceInstanceId, conn.targetInstanceId,
          conn.sourceJackId, conn.targetJackId,
          jackMap,
        ));
      } else {
        map.set(conn.id, { status: 'valid' as const, warnings: [] });
      }
    }
    return map;
  }, [connections, virtualNodes, placeholders, jackMap]);

  const handleDragEnd = useCallback((instanceId: string, x: number, y: number) => {
    updateViewPosition(VIEW_KEY, instanceId, x, y);
  }, [updateViewPosition]);

  const getSignalMode = useCallback((jack: Jack, row: WorkbenchRow): 'mono' | 'stereo' => {
    if (!jack.group_id) return 'mono';
    return getStereoPartner(jack, row.jacks) ? 'stereo' : 'mono';
  }, []);

  // --- Connection interaction ---

  const handlePortClick = useCallback((instanceId: string, jackId: number | string, direction: 'output' | 'input') => {
    const key = portKey(instanceId, jackId);
    setSelectedInstanceId(null);

    if (!pendingSource) {
      setPendingSource({ jackId, instanceId, compositeKey: key, direction });
      setMousePos(null);
      setSelectedConnectionId(null);
      setWarningPopover(null);
      setStereoPrompt(null);
    } else if (pendingSource.compositeKey === key) {
      setPendingSource(null);
      setMousePos(null);
    } else if (pendingSource.direction === direction) {
      // Same direction — swap pending to new port
      setPendingSource({ jackId, instanceId, compositeKey: key, direction });
      setMousePos(null);
    } else {
      const sourceJackId = direction === 'input' ? pendingSource.jackId : jackId;
      const targetJackId = direction === 'input' ? jackId : pendingSource.jackId;
      const sourceInstanceId = direction === 'input' ? pendingSource.instanceId : instanceId;
      const targetInstanceId = direction === 'input' ? instanceId : pendingSource.instanceId;

      // Check stereo: real jacks with a stereo partner, or placeholder jacks with a group_id partner
      const srcJack = typeof sourceJackId === 'number' ? jackMap.get(sourceJackId) : null;
      const tgtJack = typeof targetJackId === 'number' ? jackMap.get(targetJackId) : null;
      const srcRow = rowMap.get(sourceInstanceId);
      const tgtRow = rowMap.get(targetInstanceId);
      const placeholderHasStereoPartner = (id: number | string, instanceId: string): boolean => {
        if (typeof id !== 'string') return false;
        const p = placeholders.find(pl => pl.instanceId === instanceId);
        if (!p) return false;
        const spec = p.jacks.find(j => j.virtualJackId === id);
        if (!spec || !spec.group_id) return false;
        return p.jacks.some(j => j.virtualJackId !== id && j.group_id === spec.group_id);
      };
      const srcHasStereo =
        (srcJack && srcRow && srcJack.group_id !== null && !!getStereoPartner(srcJack, srcRow.jacks)) ||
        placeholderHasStereoPartner(sourceJackId, sourceInstanceId);
      const tgtHasStereo =
        (tgtJack && tgtRow && tgtJack.group_id !== null && !!getStereoPartner(tgtJack, tgtRow.jacks)) ||
        placeholderHasStereoPartner(targetJackId, targetInstanceId);

      if (srcHasStereo && tgtHasStereo) {
        const srcPos = portPositions.get(portKey(sourceInstanceId, sourceJackId));
        const tgtPos = portPositions.get(portKey(targetInstanceId, targetJackId));
        const midWorld = srcPos && tgtPos ? { x: (srcPos.x + tgtPos.x) / 2, y: (srcPos.y + tgtPos.y) / 2 } : { x: 0, y: 0 };
        const midScreen = viewport.worldToScreen(midWorld.x, midWorld.y);
        setStereoPrompt({ sourceJackId, sourceInstanceId, targetJackId, targetInstanceId, screenX: midScreen.x, screenY: midScreen.y - 40 });
        setPendingSource(null);
        setMousePos(null);
      } else {
        createConnection(sourceJackId, sourceInstanceId, targetJackId, targetInstanceId, 'mono', null);
        setPendingSource(null);
        setMousePos(null);
      }
    }
  }, [pendingSource, jackMap, rowMap, portPositions, viewport, placeholders]);

  const createConnection = useCallback((
    sourceJackId: number | string, sourceInstanceId: string,
    targetJackId: number | string, targetInstanceId: string,
    signalMode: 'mono' | 'stereo',
    stereoPairConnectionId: string | null,
  ) => {
    addAudioConnection({
      sourceJackId, targetJackId, sourceInstanceId, targetInstanceId,
      orderIndex: connections.length,
      parallelPathId: null, fxLoopGroupId: null,
      signalMode, stereoPairConnectionId, waypoints: [],
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

      const findPlaceholderPartner = (id: number | string, instanceId: string): VirtualJackSpec | undefined => {
        if (typeof id !== 'string') return undefined;
        const p = placeholders.find(pl => pl.instanceId === instanceId);
        if (!p) return undefined;
        const spec = p.jacks.find(j => j.virtualJackId === id);
        if (!spec || !spec.group_id) return undefined;
        return p.jacks.find(j => j.virtualJackId !== id && j.group_id === spec.group_id);
      };
      const srcPlaceholderPartner = findPlaceholderPartner(sourceJackId, sourceInstanceId);
      const tgtPlaceholderPartner = findPlaceholderPartner(targetJackId, targetInstanceId);

      createConnection(sourceJackId, sourceInstanceId, targetJackId, targetInstanceId, 'stereo', null);
      if (srcPartner && tgtPartner) {
        createConnection(srcPartner.id, sourceInstanceId, tgtPartner.id, targetInstanceId, 'stereo', null);
      } else if (srcPlaceholderPartner && tgtPlaceholderPartner) {
        createConnection(srcPlaceholderPartner.virtualJackId, sourceInstanceId, tgtPlaceholderPartner.virtualJackId, targetInstanceId, 'stereo', null);
      }
    } else {
      createConnection(sourceJackId, sourceInstanceId, targetJackId, targetInstanceId, 'mono', null);
    }
    setStereoPrompt(null);
  }, [stereoPrompt, jackMap, rowMap, placeholders, createConnection]);

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
      setSelectedInstanceId(null);
      setWarningPopover(null);
      setStereoPrompt(null);
      setShowPlaceholderMenu(false);
      setShowNodeMenu(false);
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
    setSelectedInstanceId(null);
    setPendingSource(null);
    setStereoPrompt(null);
  }, [connectionValidations, connections, portPositions]);

  const handleKeyDown = useCallback((e: KeyboardEvent) => {
    const tag = (e.target as HTMLElement)?.tagName;
    if (tag === 'INPUT') return;

    if (e.key === 'Escape') {
      setPendingSource(null);
      setSelectedConnectionId(null);
      setSelectedInstanceId(null);
      setWarningPopover(null);
      setStereoPrompt(null);
      setShowPlaceholderMenu(false);
      setShowNodeMenu(false);
    }

    if (e.key === 'Delete' || e.key === 'Backspace') {
      if (selectedConnectionId) {
        removeAudioConnection(selectedConnectionId);
        setSelectedConnectionId(null);
        setWarningPopover(null);
      } else if (selectedInstanceId) {
        // Remove placeholder or additional virtual node (not the default guitar/amp)
        const isPlaceholder = placeholders.some(p => p.instanceId === selectedInstanceId);
        const isDefaultNode = selectedInstanceId === 'virtual:guitar-1' || selectedInstanceId === 'virtual:amp-1';

        if (isPlaceholder) {
          removeAudioPlaceholder(selectedInstanceId);
          setAudioConnections(connections.filter(c =>
            c.sourceInstanceId !== selectedInstanceId && c.targetInstanceId !== selectedInstanceId,
          ));
          setSelectedInstanceId(null);
        } else if (!isDefaultNode) {
          removeVirtualNode(selectedInstanceId);
          setAudioConnections(connections.filter(c =>
            c.sourceInstanceId !== selectedInstanceId && c.targetInstanceId !== selectedInstanceId,
          ));
          setSelectedInstanceId(null);
        }
      }
    }
  }, [selectedConnectionId, selectedInstanceId, connections, placeholders, removeAudioConnection, removeAudioPlaceholder, removeVirtualNode, setAudioConnections]);

  useEffect(() => {
    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [handleKeyDown]);

  // Label editing commit
  const commitLabel = useCallback((id: string, label: string) => {
    if (!label.trim()) return;
    const isPlaceholder = placeholders.some(p => p.instanceId === id);
    if (isPlaceholder) {
      updateAudioPlaceholderLabel(id, label.trim());
    } else {
      // Virtual node rename — update the node's label
      const updatedNodes = virtualNodes.map(n => n.instanceId === id ? { ...n, label: label.trim() } : n);
      setVirtualNodes(updatedNodes);
    }
    setEditingId(null);
  }, [placeholders, virtualNodes, updateAudioPlaceholderLabel, setVirtualNodes]);

  const handleFitAll = useCallback(() => {
    const cards: Array<{ x: number; y: number; width: number; height: number }> = [];
    for (const entry of audioRowEntries) {
      const pos = getPosition(entry.instanceId, entry.defaultX, entry.defaultY);
      const outs = getAudioOutputJacks(entry.row).length;
      const ins = getAudioInputJacks(entry.row).length;
      cards.push({ x: pos.x, y: pos.y, width: CARD_WIDTH, height: audioCardHeight(ins, outs) });
    }
    for (const entry of placeholderEntries) {
      const pos = getPosition(entry.placeholder.instanceId, entry.defaultX, entry.defaultY);
      const outs = entry.placeholder.jacks.filter(j => j.direction === 'output').length;
      const ins  = entry.placeholder.jacks.filter(j => j.direction === 'input').length;
      cards.push({ x: pos.x, y: pos.y, width: CARD_WIDTH, height: audioCardHeight(ins, outs) });
    }
    for (const node of virtualNodes) {
      const def = getVirtualNodeDefault(node);
      const pos = getPosition(node.instanceId, def.x, def.y);
      cards.push({ x: pos.x, y: pos.y, width: VIRTUAL_NODE_WIDTH, height: VIRTUAL_NODE_HEIGHT });
    }
    if (cards.length === 0) return;
    viewport.fitAll(calculateBoundingBox(cards), stageDims.width, stageDims.height);
  }, [audioRowEntries, placeholderEntries, virtualNodes, getPosition, getVirtualNodeDefault, viewport, stageDims]);

  const pendingSourcePos = pendingSource ? portPositions.get(pendingSource.compositeKey) : null;

  if (rows.length === 0) {
    return <div className="workbench__canvas-placeholder">Your workbench is empty. Add products from the catalog views.</div>;
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

        {/* Real product cards */}
        {audioRowEntries.map((entry) => {
          const pos = getPosition(entry.instanceId, entry.defaultX, entry.defaultY);
          const outputs = getAudioOutputJacks(entry.row);
          const inputs  = getAudioInputJacks(entry.row);
          const cardH = audioCardHeight(inputs.length, outputs.length);
          return (
            <ProductCard
              key={entry.instanceId}
              productType={entry.row.product_type}
              manufacturer={entry.row.manufacturer}
              model={entry.row.model}
              x={pos.x} y={pos.y}
              cardHeight={cardH}
              onDragEnd={(x, y) => handleDragEnd(entry.instanceId, x, y)}
            >
              {outputs.map((jack, i) => {
                const key = portKey(entry.instanceId, jack.id);
                const mode = getSignalMode(jack, entry.row);
                return (
                  <PortDot
                    key={key}
                    x={2} y={AUDIO_PORT_START_Y + i * PORT_SPACING}
                    jackId={jack.id}
                    label={jack.jack_name ?? (mode === 'stereo' ? 'Out (L/R)' : 'Out')}
                    direction="output"
                    color={pendingSource?.compositeKey === key ? '#fff' : '#6aaa6a'}
                    onClick={() => handlePortClick(entry.instanceId, jack.id, 'output')}
                  />
                );
              })}
              {inputs.map((jack, i) => {
                const key = portKey(entry.instanceId, jack.id);
                const mode = getSignalMode(jack, entry.row);
                return (
                  <PortDot
                    key={key}
                    x={CARD_WIDTH - 2} y={AUDIO_PORT_START_Y + i * PORT_SPACING}
                    jackId={jack.id}
                    label={jack.jack_name ?? (mode === 'stereo' ? 'In (L/R)' : 'In')}
                    direction="input"
                    color={pendingSource?.compositeKey === key ? '#fff' : '#6a6aaa'}
                    onClick={() => handlePortClick(entry.instanceId, jack.id, 'input')}
                  />
                );
              })}
            </ProductCard>
          );
        })}

        {/* Placeholder cards */}
        {placeholderEntries.map(({ placeholder, defaultX, defaultY }) => {
          const pos = getPosition(placeholder.instanceId, defaultX, defaultY);
          const outputs = placeholder.jacks.filter(j => j.direction === 'output');
          const inputs  = placeholder.jacks.filter(j => j.direction === 'input');
          const cardH = audioCardHeight(inputs.length, outputs.length);
          const isSelected = selectedInstanceId === placeholder.instanceId;
          return (
            <ProductCard
              key={placeholder.instanceId}
              productType="pedal"
              manufacturer=""
              model={placeholder.label}
              x={pos.x} y={pos.y}
              cardHeight={cardH}
              selected={isSelected}
              onDragEnd={(x, y) => handleDragEnd(placeholder.instanceId, x, y)}
              onClick={() => setSelectedInstanceId(placeholder.instanceId)}
              onDblClick={() => { setEditingId(placeholder.instanceId); setEditingLabel(placeholder.label); }}
            >
              {outputs.map((jack, i) => {
                const key = portKey(placeholder.instanceId, jack.virtualJackId);
                return (
                  <PortDot
                    key={key}
                    x={2} y={AUDIO_PORT_START_Y + i * PORT_SPACING}
                    jackId={jack.virtualJackId as unknown as number}
                    label={jack.label}
                    direction="output"
                    color={pendingSource?.compositeKey === key ? '#fff' : '#6aaa6a'}
                    onClick={() => handlePortClick(placeholder.instanceId, jack.virtualJackId, 'output')}
                  />
                );
              })}
              {inputs.map((jack, i) => {
                const key = portKey(placeholder.instanceId, jack.virtualJackId);
                return (
                  <PortDot
                    key={key}
                    x={CARD_WIDTH - 2} y={AUDIO_PORT_START_Y + i * PORT_SPACING}
                    jackId={jack.virtualJackId as unknown as number}
                    label={jack.label}
                    direction="input"
                    color={pendingSource?.compositeKey === key ? '#fff' : '#6a6aaa'}
                    onClick={() => handlePortClick(placeholder.instanceId, jack.virtualJackId, 'input')}
                  />
                );
              })}
            </ProductCard>
          );
        })}

        {/* Virtual node cards */}
        {virtualNodes.map((node) => {
          const def = getVirtualNodeDefault(node);
          const pos = getPosition(node.instanceId, def.x, def.y);
          const isSource = node.nodeType === 'guitar_input';
          const portX = isSource ? 2 : VIRTUAL_NODE_WIDTH - 2;
          const portDir: 'output' | 'input' = isSource ? 'output' : 'input';
          const pKey = portKey(node.instanceId, node.virtualJackId);
          const isSelected = selectedInstanceId === node.instanceId;
          const isDefault = node.instanceId === 'virtual:guitar-1' || node.instanceId === 'virtual:amp-1';

          return (
            <Group
              key={node.instanceId}
              x={pos.x} y={pos.y}
              draggable
              onClick={() => !isDefault && setSelectedInstanceId(node.instanceId)}
              onTap={() => !isDefault && setSelectedInstanceId(node.instanceId)}
              onDragEnd={(e: Konva.KonvaEventObject<DragEvent>) => handleDragEnd(node.instanceId, e.target.x(), e.target.y())}
            >
              <Rect
                width={VIRTUAL_NODE_WIDTH} height={VIRTUAL_NODE_HEIGHT}
                fill="#1a2a2a"
                stroke={isSelected ? '#6adada' : '#3a7070'}
                strokeWidth={isSelected ? 2 : 1}
                cornerRadius={4}
              />
              <Text
                x={8} y={10}
                width={VIRTUAL_NODE_WIDTH - 16}
                text={node.label}
                fontSize={12}
                fontFamily="'SF Mono', 'Fira Code', monospace"
                fill="#6adada"
                align="center"
                onDblClick={() => { setEditingId(node.instanceId); setEditingLabel(node.label); }}
                onDblTap={() => { setEditingId(node.instanceId); setEditingLabel(node.label); }}
              />
              <Text
                x={8} y={28}
                width={VIRTUAL_NODE_WIDTH - 16}
                text={node.connectorType}
                fontSize={9} fontFamily="monospace" fill="#555"
                align="center" listening={false}
              />
              <Circle
                x={portX} y={VIRTUAL_NODE_HEIGHT / 2}
                radius={6}
                fill={pendingSource?.compositeKey === pKey ? '#fff' : '#6adada'}
                stroke="#6adada" strokeWidth={1}
                onClick={() => handlePortClick(node.instanceId, node.virtualJackId, portDir)}
                onTap={() => handlePortClick(node.instanceId, node.virtualJackId, portDir)}
              />
            </Group>
          );
        })}
      </CanvasBase>

      {/* Inline label editor (virtual nodes + placeholders) */}
      {editingId && (() => {
        const node = virtualNodes.find(n => n.instanceId === editingId);
        const placeholder = placeholders.find(p => p.instanceId === editingId);
        const currentLabel = node?.label ?? placeholder?.label ?? '';
        let worldX = 0, worldY = 0;
        if (node) {
          const def = getVirtualNodeDefault(node);
          const pos = getPosition(editingId, def.x, def.y);
          worldX = pos.x + 8; worldY = pos.y + 8;
        } else if (placeholder) {
          const entry = placeholderEntries.find(e => e.placeholder.instanceId === editingId);
          if (entry) {
            const pos = getPosition(editingId, entry.defaultX, entry.defaultY);
            worldX = pos.x + 8; worldY = pos.y + 24;
          }
        }
        const screen = viewport.worldToScreen(worldX, worldY);
        return (
          <input
            ref={editInputRef}
            style={{
              position: 'absolute', left: screen.x, top: screen.y,
              width: (VIRTUAL_NODE_WIDTH - 16) * viewport.scale,
              fontSize: 12 * viewport.scale,
              background: '#1a2a2a', color: '#6adada',
              border: '1px solid #3a7070', borderRadius: 2, padding: '2px 4px',
            }}
            value={editingLabel !== '' ? editingLabel : currentLabel}
            onChange={e => setEditingLabel(e.target.value)}
            onKeyDown={e => {
              if (e.key === 'Enter') commitLabel(editingId, editingLabel);
              if (e.key === 'Escape') setEditingId(null);
            }}
            onBlur={() => commitLabel(editingId, editingLabel)}
          />
        );
      })()}

      {/* Stereo pair prompt */}
      {stereoPrompt && (
        <div className="workbench__audio-prompt" style={{ position: 'absolute', left: stereoPrompt.screenX, top: stereoPrompt.screenY }}>
          <span className="workbench__audio-prompt-msg">Connect as stereo pair?</span>
          <button className="workbench__power-action-btn" onClick={() => handleStereoConfirm(true)}>Yes</button>
          <button className="workbench__power-action-btn" onClick={() => handleStereoConfirm(false)}>Just this jack</button>
          <button className="workbench__power-action-btn" onClick={() => setStereoPrompt(null)}>Cancel</button>
        </div>
      )}

      {/* Missing audio jacks warning */}
      {missingRows.length > 0 && (
        <div className="workbench__audio-missing">
          <span className="workbench__audio-missing-title">
            {missingRows.length} item{missingRows.length !== 1 ? 's' : ''} not shown — no audio jack data:
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
        {/* Add placeholder dropdown */}
        <div style={{ position: 'relative', display: 'inline-block' }}>
          <button
            className="workbench__power-action-btn"
            onClick={() => { setShowPlaceholderMenu(v => !v); setShowNodeMenu(false); }}
          >
            + Add placeholder ▾
          </button>
          {showPlaceholderMenu && (
            <div className="workbench__audio-menu">
              {PLACEHOLDER_PRESETS.map(preset => (
                <button
                  key={preset.label}
                  className="workbench__audio-menu-item"
                  onClick={() => {
                    const instanceId = `placeholder:${generateId()}`;
                    addAudioPlaceholder({ instanceId, label: preset.label, jacks: preset.build(instanceId) });
                    setShowPlaceholderMenu(false);
                  }}
                >
                  <span>{preset.label}</span>
                  <span className="workbench__audio-menu-desc">{preset.description}</span>
                </button>
              ))}
            </div>
          )}
        </div>

        {/* Add virtual node dropdown */}
        <div style={{ position: 'relative', display: 'inline-block' }}>
          <button
            className="workbench__power-action-btn"
            onClick={() => { setShowNodeMenu(v => !v); setShowPlaceholderMenu(false); }}
          >
            + Add node ▾
          </button>
          {showNodeMenu && (
            <div className="workbench__audio-menu">
              {ADDITIONAL_NODE_PRESETS.map(preset => {
                const existingCount = virtualNodes.filter(n => n.nodeType === preset.nodeType).length;
                return (
                  <button
                    key={preset.label}
                    className="workbench__audio-menu-item"
                    onClick={() => {
                      const instanceId = `virtual:${preset.nodeType}-${existingCount + 1}`;
                      addVirtualNode({
                        instanceId,
                        nodeType: preset.nodeType,
                        label: preset.label,
                        virtualJackId: preset.virtualJackId(existingCount + 1),
                        connectorType: preset.connectorType,
                      });
                      setShowNodeMenu(false);
                    }}
                  >
                    {preset.label}
                  </button>
                );
              })}
            </div>
          )}
        </div>

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
        const mid = viewport.worldToScreen((srcPos.x + tgtPos.x) / 2, (srcPos.y + tgtPos.y) / 2);
        return (
          <button
            className="workbench__power-delete-btn"
            style={{ position: 'absolute', left: mid.x, top: mid.y }}
            onClick={() => { removeAudioConnection(selectedConnectionId); setSelectedConnectionId(null); setWarningPopover(null); }}
          >×</button>
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
                      : <button className="workbench__power-popover-btn" onClick={() => acknowledgeAudioWarning(warningPopover.connId, w.key)}>
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

export default AudioView;
