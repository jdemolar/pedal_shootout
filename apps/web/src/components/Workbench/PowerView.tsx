import { useState, useCallback, useMemo, useEffect } from 'react';
import { useWorkbench, PowerConnection } from '../../context/WorkbenchContext';
import { WorkbenchRow } from './WorkbenchTable';
import {
  extractPowerData,
  getPowerInputJack,
  getPowerOutputJacks,
  assignPedalsToOutputs,
} from '../../utils/powerAssignment';
import { validateConnection, ConnectionValidation } from '../../utils/powerUtils';
import { Jack } from '../../utils/transformers';
import CanvasBase from './CanvasBase';
import ProductCard, { CARD_WIDTH, CARD_HEIGHT } from './ProductCard';
import PortDot from './PortDot';
import ConnectionLine from './ConnectionLine';
import Konva from 'konva';

const VIEW_KEY = 'power';

const PORT_SPACING = 18;
const PORT_HEIGHT_EXTRA = PORT_SPACING;
const PORT_START_Y = CARD_HEIGHT - 10;

const SUPPLY_X = 40;
const CONSUMER_X = 500;
const VERTICAL_GAP = 20;

interface PowerViewProps {
  rows: WorkbenchRow[];
}

function supplyCardHeight(outputCount: number): number {
  if (outputCount <= 0) return CARD_HEIGHT;
  return CARD_HEIGHT + outputCount * PORT_HEIGHT_EXTRA;
}

/** Composite key for uniquely identifying a port on a specific instance */
function portKey(instanceId: string, jackId: number): string {
  return `${instanceId}:${jackId}`;
}

/** Local interaction state for connection creation */
interface PendingConnection {
  jackId: number;
  instanceId: string;
  compositeKey: string;
  direction: 'output' | 'input';
}

const PowerView = ({ rows }: PowerViewProps) => {
  const {
    getViewPositions,
    updateViewPosition,
    addPowerConnection,
    removePowerConnection,
    setPowerConnections,
    acknowledgeWarning,
    activeWorkbench,
  } = useWorkbench();

  const savedPositions = getViewPositions(VIEW_KEY);
  const powerData = extractPowerData(rows);
  const connections = activeWorkbench.powerConnections ?? [];

  // Interaction state
  const [pendingSource, setPendingSource] = useState<PendingConnection | null>(null);
  const [selectedConnectionId, setSelectedConnectionId] = useState<string | null>(null);
  const [mousePos, setMousePos] = useState<{ x: number; y: number } | null>(null);
  const [warningPopover, setWarningPopover] = useState<{
    connId: string;
    warnings: string[];
    x: number;
    y: number;
  } | null>(null);

  // Build lookups
  const rowMap = useMemo(() => {
    const map = new Map<string, WorkbenchRow>();
    for (const row of rows) map.set(row.instanceId, row);
    return map;
  }, [rows]);

  // Jack lookup: jackId → Jack object (jack data is the same regardless of instance)
  const jackMap = useMemo(() => {
    const map = new Map<number, Jack>();
    for (const row of rows) {
      for (const jack of row.jacks) {
        map.set(jack.id, jack);
      }
    }
    return map;
  }, [rows]);

  // Supply and consumer position data — keyed by instanceId
  const supplyEntries = useMemo(() => {
    let y = VERTICAL_GAP;
    return powerData.supplies.map((supply) => {
      const row = rowMap.get(supply.instanceId);
      const outputJacks = row ? getPowerOutputJacks(row) : [];
      const entry = { instanceId: supply.instanceId, productId: supply.productId, x: SUPPLY_X, y, outputJacks };
      y += supplyCardHeight(outputJacks.length) + VERTICAL_GAP;
      return entry;
    });
  }, [powerData.supplies, rowMap]);

  const consumerEntries = useMemo(() => {
    let y = VERTICAL_GAP;
    return powerData.consumers.map((consumer) => {
      const row = rowMap.get(consumer.instanceId);
      const inputJack = row ? getPowerInputJack(row) : undefined;
      const entry = { instanceId: consumer.instanceId, productId: consumer.productId, x: CONSUMER_X, y, inputJack };
      y += CARD_HEIGHT + VERTICAL_GAP;
      return entry;
    });
  }, [powerData.consumers, rowMap]);

  const getPosition = useCallback((instanceId: string, fallbackX: number, fallbackY: number) => {
    const saved = savedPositions[instanceId];
    if (saved) return saved;
    return { x: fallbackX, y: fallbackY };
  }, [savedPositions]);

  // Port absolute position lookup — keyed by composite key (instanceId:jackId)
  const portPositions = useMemo(() => {
    const map = new Map<string, { x: number; y: number }>();

    for (const entry of supplyEntries) {
      const pos = getPosition(entry.instanceId, entry.x, entry.y);
      entry.outputJacks.forEach((jack, i) => {
        map.set(portKey(entry.instanceId, jack.id), {
          x: pos.x + CARD_WIDTH - 2,
          y: pos.y + PORT_START_Y + i * PORT_SPACING,
        });
      });
    }

    for (const entry of consumerEntries) {
      if (!entry.inputJack) continue;
      const pos = getPosition(entry.instanceId, entry.x, entry.y);
      map.set(portKey(entry.instanceId, entry.inputJack.id), {
        x: pos.x + 2,
        y: pos.y + CARD_HEIGHT / 2,
      });
    }

    return map;
  }, [supplyEntries, consumerEntries, getPosition]);

  // Compute total current on each output port (for daisy-chain validation)
  // Keyed by composite key (instanceId:jackId)
  const currentByOutput = useMemo(() => {
    const map = new Map<string, number>();
    for (const conn of connections) {
      const inputJack = jackMap.get(conn.targetJackId);
      const currentMa = inputJack?.current_ma ?? 0;
      const key = portKey(conn.sourceInstanceId, conn.sourceJackId);
      map.set(key, (map.get(key) ?? 0) + currentMa);
    }
    return map;
  }, [connections, jackMap]);

  // Validate each connection
  const connectionValidations = useMemo(() => {
    const map = new Map<string, ConnectionValidation>();
    for (const conn of connections) {
      const outputJack = jackMap.get(conn.sourceJackId);
      const inputJack = jackMap.get(conn.targetJackId);
      if (outputJack && inputJack) {
        const key = portKey(conn.sourceInstanceId, conn.sourceJackId);
        map.set(conn.id, validateConnection(
          outputJack,
          inputJack,
          currentByOutput.get(key),
        ));
      } else {
        map.set(conn.id, { status: 'valid', warnings: [] });
      }
    }
    return map;
  }, [connections, jackMap, currentByOutput]);

  const handleDragEnd = (instanceId: string, x: number, y: number) => {
    updateViewPosition(VIEW_KEY, instanceId, x, y);
  };

  // --- Connection interaction ---

  /** Creates a port click handler scoped to a specific instance */
  const makePortClickHandler = useCallback((instanceId: string) => (jackId: number) => {
    const jack = jackMap.get(jackId);
    if (!jack) return;

    const direction = jack.direction === 'output' ? 'output' as const : 'input' as const;
    const key = portKey(instanceId, jackId);

    if (!pendingSource) {
      // First click — start pending connection
      setPendingSource({ jackId, instanceId, compositeKey: key, direction });
      setMousePos(null);
      setSelectedConnectionId(null);
      setWarningPopover(null);
    } else if (pendingSource.compositeKey === key) {
      // Clicked same port — cancel
      setPendingSource(null);
      setMousePos(null);
    } else {
      // Second click — attempt connection
      if (pendingSource.direction === direction) {
        // Can't connect output→output or input→input
        setPendingSource(null);
        setMousePos(null);
        return;
      }

      const sourceJackId = direction === 'input' ? pendingSource.jackId : jackId;
      const targetJackId = direction === 'input' ? jackId : pendingSource.jackId;
      const sourceInstanceId = direction === 'input' ? pendingSource.instanceId : instanceId;
      const targetInstanceId = direction === 'input' ? instanceId : pendingSource.instanceId;

      addPowerConnection({
        sourceJackId,
        targetJackId,
        sourceInstanceId,
        targetInstanceId,
      });
      setPendingSource(null);
      setMousePos(null);
    }
  }, [pendingSource, jackMap, addPowerConnection]);

  // Track mouse position for preview line (only while a connection is pending)
  const handleStageMouseMove = useCallback((e: Konva.KonvaEventObject<MouseEvent>) => {
    if (!pendingSource) return;
    const stage = e.target.getStage();
    if (stage) {
      const pos = stage.getPointerPosition();
      if (pos) setMousePos({ x: pos.x, y: pos.y });
    }
  }, [pendingSource]);

  const handleStageClick = useCallback((e: Konva.KonvaEventObject<MouseEvent>) => {
    // Click on empty canvas — deselect and cancel pending
    if (e.target === e.target.getStage()) {
      setPendingSource(null);
      setSelectedConnectionId(null);
      setWarningPopover(null);
    }
  }, []);

  const handleConnectionClick = useCallback((connId: string) => {
    const validation = connectionValidations.get(connId);
    const conn = connections.find(c => c.id === connId);

    if (validation && validation.warnings.length > 0 && conn) {
      // Show warning popover
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
  }, [connectionValidations, connections, portPositions]);

  const handleKeyDown = useCallback((e: KeyboardEvent) => {
    if ((e.key === 'Delete' || e.key === 'Backspace') && selectedConnectionId) {
      removePowerConnection(selectedConnectionId);
      setSelectedConnectionId(null);
      setWarningPopover(null);
    }
    if (e.key === 'Escape') {
      setPendingSource(null);
      setSelectedConnectionId(null);
      setWarningPopover(null);
    }
  }, [selectedConnectionId, removePowerConnection]);

  // Register keyboard listener
  useEffect(() => {
    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [handleKeyDown]);

  // Auto-assign
  const handleAutoAssign = useCallback(() => {
    if (connections.length > 0 && !window.confirm('Replace existing connections?')) {
      return;
    }

    const result = assignPedalsToOutputs(powerData.consumers, powerData.supplies);
    const newConnections: PowerConnection[] = result.assignments.map((a) => {
      // Find the consumer's power input jack
      const consumerRow = rowMap.get(a.consumer.instanceId);
      const inputJack = consumerRow ? getPowerInputJack(consumerRow) : undefined;

      return {
        id: crypto.randomUUID(),
        sourceJackId: a.jack.id,
        targetJackId: inputJack?.id ?? 0,
        sourceInstanceId: a.jack.supplyInstanceId,
        targetInstanceId: a.consumer.instanceId,
      };
    }).filter(c => c.targetJackId !== 0);

    setPowerConnections(newConnections);
    setSelectedConnectionId(null);
    setWarningPopover(null);
  }, [connections, powerData, rowMap, setPowerConnections]);

  if (rows.length === 0) {
    return (
      <div className="workbench__canvas-placeholder">
        Your workbench is empty. Add products from the catalog views.
      </div>
    );
  }

  if (powerData.consumers.length === 0 && powerData.supplies.length === 0) {
    return (
      <div className="workbench__canvas-placeholder">
        No power supplies or powered products in this workbench.
      </div>
    );
  }

  // Pending source port position for preview line
  const pendingSourcePos = pendingSource ? portPositions.get(pendingSource.compositeKey) : null;

  return (
    <div style={{ position: 'relative', width: '100%', height: '100%' }}>
      <CanvasBase
        onStageClick={handleStageClick}
        onStageMouseMove={handleStageMouseMove}
      >
        {/* Connection lines */}
        {connections.map((conn) => {
          const sourcePos = portPositions.get(portKey(conn.sourceInstanceId, conn.sourceJackId));
          const targetPos = portPositions.get(portKey(conn.targetInstanceId, conn.targetJackId));
          if (!sourcePos || !targetPos) return null;

          const validation = connectionValidations.get(conn.id) ?? { status: 'valid' as const, warnings: [] };
          const isAcknowledged = (conn.acknowledgedWarnings?.length ?? 0) > 0 &&
            validation.warnings.every(w => conn.acknowledgedWarnings?.includes(w));

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
              onClick={() => handleConnectionClick(conn.id)}
            />
          );
        })}

        {/* Preview line while creating connection */}
        {pendingSource && pendingSourcePos && mousePos && (
          <ConnectionLine
            sourceX={pendingSourcePos.x}
            sourceY={pendingSourcePos.y}
            targetX={mousePos.x}
            targetY={mousePos.y}
            status="valid"
          />
        )}

        {/* Supply cards with output port dots */}
        {supplyEntries.map((entry) => {
          const supply = powerData.supplies.find(s => s.instanceId === entry.instanceId)!;
          const pos = getPosition(entry.instanceId, entry.x, entry.y);
          const onPortClick = makePortClickHandler(entry.instanceId);

          return (
            <ProductCard
              key={entry.instanceId}
              productType="power_supply"
              manufacturer={supply.manufacturer}
              model={supply.model}
              x={pos.x}
              y={pos.y}
              onDragEnd={(x, y) => handleDragEnd(entry.instanceId, x, y)}
              cardHeight={supplyCardHeight(entry.outputJacks.length)}
            >
              {entry.outputJacks.map((jack, i) => {
                const label = [
                  jack.voltage ?? '?V',
                  jack.current_ma != null ? `${jack.current_ma}mA` : '',
                ].filter(Boolean).join(' ');
                const key = portKey(entry.instanceId, jack.id);

                return (
                  <PortDot
                    key={key}
                    x={CARD_WIDTH - 2}
                    y={PORT_START_Y + i * PORT_SPACING}
                    jackId={jack.id}
                    label={label}
                    direction="output"
                    isolated={jack.is_isolated !== false}
                    color={pendingSource?.compositeKey === key ? '#fff' : '#6aaa6a'}
                    onClick={onPortClick}
                  />
                );
              })}
            </ProductCard>
          );
        })}

        {/* Consumer cards with power input port dot */}
        {consumerEntries.map((entry) => {
          const consumer = powerData.consumers.find(c => c.instanceId === entry.instanceId)!;
          const pos = getPosition(entry.instanceId, entry.x, entry.y);
          const onPortClick = makePortClickHandler(entry.instanceId);

          return (
            <ProductCard
              key={entry.instanceId}
              productType={rowMap.get(entry.instanceId)?.product_type ?? 'pedal'}
              manufacturer={consumer.manufacturer}
              model={consumer.model}
              x={pos.x}
              y={pos.y}
              onDragEnd={(x, y) => handleDragEnd(entry.instanceId, x, y)}
            >
              {entry.inputJack && (() => {
                const key = portKey(entry.instanceId, entry.inputJack!.id);
                return (
                  <PortDot
                    x={2}
                    y={CARD_HEIGHT / 2}
                    jackId={entry.inputJack!.id}
                    label={[
                      consumer.voltage ?? '?V',
                      consumer.current_ma != null ? `${consumer.current_ma}mA` : '',
                    ].filter(Boolean).join(' ')}
                    direction="input"
                    color={pendingSource?.compositeKey === key ? '#fff' : '#6a6aaa'}
                    onClick={onPortClick}
                  />
                );
              })()}
            </ProductCard>
          );
        })}
      </CanvasBase>

      {/* Canvas action buttons */}
      <div className="workbench__power-actions">
        {powerData.supplies.length > 0 && powerData.consumers.length > 0 && (
          <button
            className="workbench__power-action-btn"
            onClick={handleAutoAssign}
            title="Automatically assign pedals to power supply outputs"
          >
            Auto-assign
          </button>
        )}
        {connections.length > 0 && (
          <button
            className="workbench__power-action-btn workbench__power-action-btn--danger"
            onClick={() => {
              if (window.confirm(`Clear all ${connections.length} connection${connections.length === 1 ? '' : 's'}?`)) {
                setPowerConnections([]);
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

      {/* Floating delete button for selected connection */}
      {selectedConnectionId && (() => {
        const conn = connections.find(c => c.id === selectedConnectionId);
        if (!conn) return null;
        const srcPos = portPositions.get(portKey(conn.sourceInstanceId, conn.sourceJackId));
        const tgtPos = portPositions.get(portKey(conn.targetInstanceId, conn.targetJackId));
        if (!srcPos || !tgtPos) return null;
        return (
          <button
            className="workbench__power-delete-btn"
            style={{
              position: 'absolute',
              left: (srcPos.x + tgtPos.x) / 2,
              top: (srcPos.y + tgtPos.y) / 2,
            }}
            title="Delete connection"
            onClick={() => {
              removePowerConnection(selectedConnectionId);
              setSelectedConnectionId(null);
              setWarningPopover(null);
            }}
          >
            ×
          </button>
        );
      })()}

      {/* Warning popover */}
      {warningPopover && (
        <div
          className="workbench__power-popover"
          style={{
            position: 'absolute',
            left: warningPopover.x,
            top: warningPopover.y,
          }}
        >
          <div className="workbench__power-popover-warnings">
            {warningPopover.warnings.map((w, i) => (
              <div key={i} className="workbench__power-popover-warning">{w}</div>
            ))}
          </div>
          <button
            className="workbench__power-popover-btn"
            onClick={() => {
              for (const w of warningPopover.warnings) {
                acknowledgeWarning(warningPopover.connId, w);
              }
              setWarningPopover(null);
            }}
          >
            I have this adapter
          </button>
          <button
            className="workbench__power-popover-btn workbench__power-popover-btn--close"
            onClick={() => setWarningPopover(null)}
          >
            Close
          </button>
        </div>
      )}
    </div>
  );
};

export default PowerView;
