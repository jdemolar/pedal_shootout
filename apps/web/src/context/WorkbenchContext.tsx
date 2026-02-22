import { createContext, useContext, useState, useCallback, useMemo, ReactNode } from 'react';

// --- Types ---

export type ProductType = 'pedal' | 'power_supply' | 'pedalboard' | 'midi_controller' | 'utility';

export interface WorkbenchItem {
  instanceId: string;
  productId: number;
  productType: ProductType;
  addedAt: string;
  // Phase 2 (visual layout):
  position?: { x: number; y: number };
  rotation?: number;
}

/** Per-view position for an item on the canvas. Keyed by instanceId. */
export interface ViewPositions {
  [viewMode: string]: {
    [instanceId: string]: { x: number; y: number };
  };
}

/** A power connection between a supply output jack and a consumer input jack. */
export interface PowerConnection {
  id: string;
  sourceJackId: number;
  targetJackId: number;
  sourceInstanceId: string;
  targetInstanceId: string;
  acknowledgedWarnings?: string[];
}

export interface Workbench {
  id: string;
  name: string;
  items: WorkbenchItem[];
  createdAt: string;
  updatedAt: string;
  // Phase 2 (visual layout):
  boardId?: number;
  // Canvas view data:
  viewPositions?: ViewPositions;
  powerConnections?: PowerConnection[];
}

interface WorkbenchStore {
  workbenches: Workbench[];
  activeWorkbenchId: string;
}

interface WorkbenchContextType {
  // Workbench management
  workbenches: Workbench[];
  activeWorkbench: Workbench;
  createWorkbench: (name: string) => void;
  renameWorkbench: (id: string, name: string) => void;
  deleteWorkbench: (id: string) => void;
  setActiveWorkbench: (id: string) => void;

  // Item operations (operate on active workbench)
  addItem: (productId: number, productType: ProductType) => void;
  removeItem: (instanceId: string) => void;
  removeAllInstances: (productId: number) => void;
  countInWorkbench: (productId: number) => number;
  clear: () => void;

  // Canvas view positions
  updateViewPosition: (view: string, instanceId: string, x: number, y: number) => void;
  getViewPositions: (view: string) => Record<string, { x: number; y: number }>;

  // Power connections
  addPowerConnection: (conn: Omit<PowerConnection, 'id'>) => void;
  removePowerConnection: (connId: string) => void;
  setPowerConnections: (conns: PowerConnection[]) => void;
  acknowledgeWarning: (connId: string, warningKey: string) => void;

  // Aggregate counts
  totalItemCount: number;
}

// --- Constants ---

const STORAGE_KEY = 'pedal_shootout_workbenches';

// --- Helpers ---

function generateId(): string {
  if (typeof crypto !== 'undefined' && typeof crypto.randomUUID === 'function') {
    return crypto.randomUUID();
  }
  // Fallback for environments without crypto.randomUUID
  return Date.now().toString(36) + Math.random().toString(36).substring(2);
}

function createDefaultWorkbench(): Workbench {
  const now = new Date().toISOString();
  return {
    id: generateId(),
    name: 'My Workbench',
    items: [],
    createdAt: now,
    updatedAt: now,
  };
}

function createDefaultStore(): WorkbenchStore {
  const wb = createDefaultWorkbench();
  return {
    workbenches: [wb],
    activeWorkbenchId: wb.id,
  };
}

function migrateStore(store: WorkbenchStore): WorkbenchStore {
  // Add instanceId to any items that don't have one (pre-multi-instance data)
  for (const wb of store.workbenches) {
    for (const item of wb.items) {
      if (!item.instanceId) {
        item.instanceId = generateId();
      }
    }
  }
  return store;
}

function loadStore(): WorkbenchStore {
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    if (raw) {
      const parsed = JSON.parse(raw) as WorkbenchStore;
      if (parsed.workbenches && parsed.workbenches.length > 0 && parsed.activeWorkbenchId) {
        // Ensure activeWorkbenchId points to an existing workbench
        const activeExists = parsed.workbenches.some(wb => wb.id === parsed.activeWorkbenchId);
        if (!activeExists) {
          parsed.activeWorkbenchId = parsed.workbenches[0].id;
        }
        return migrateStore(parsed);
      }
    }
  } catch {
    // Corrupted data — fall through to default
  }
  return createDefaultStore();
}

function saveStore(store: WorkbenchStore): void {
  try {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(store));
  } catch {
    // localStorage full or unavailable — fail silently
  }
}

/** Helper to update only the active workbench within the store */
function updateActiveWorkbench(
  prev: WorkbenchStore,
  updater: (wb: Workbench) => Workbench,
): WorkbenchStore {
  return {
    ...prev,
    workbenches: prev.workbenches.map(wb =>
      wb.id === prev.activeWorkbenchId ? updater(wb) : wb,
    ),
  };
}

// --- Context ---

const WorkbenchContext = createContext<WorkbenchContextType | null>(null);

export function WorkbenchProvider({ children }: { children: ReactNode }) {
  const [store, setStore] = useState<WorkbenchStore>(loadStore);

  const updateStore = useCallback((updater: (prev: WorkbenchStore) => WorkbenchStore) => {
    setStore(prev => {
      const next = updater(prev);
      saveStore(next);
      return next;
    });
  }, []);

  const activeWorkbench = useMemo(
    () => store.workbenches.find(wb => wb.id === store.activeWorkbenchId) ?? store.workbenches[0],
    [store],
  );

  const createWorkbench = useCallback((name: string) => {
    const now = new Date().toISOString();
    const wb: Workbench = {
      id: generateId(),
      name,
      items: [],
      createdAt: now,
      updatedAt: now,
    };
    updateStore(prev => ({
      workbenches: [...prev.workbenches, wb],
      activeWorkbenchId: wb.id,
    }));
  }, [updateStore]);

  const renameWorkbench = useCallback((id: string, name: string) => {
    updateStore(prev => ({
      ...prev,
      workbenches: prev.workbenches.map(wb =>
        wb.id === id ? { ...wb, name, updatedAt: new Date().toISOString() } : wb,
      ),
    }));
  }, [updateStore]);

  const deleteWorkbench = useCallback((id: string) => {
    updateStore(prev => {
      const remaining = prev.workbenches.filter(wb => wb.id !== id);
      // Always keep at least one workbench
      if (remaining.length === 0) {
        const fallback = createDefaultWorkbench();
        return { workbenches: [fallback], activeWorkbenchId: fallback.id };
      }
      return {
        workbenches: remaining,
        activeWorkbenchId: prev.activeWorkbenchId === id ? remaining[0].id : prev.activeWorkbenchId,
      };
    });
  }, [updateStore]);

  const setActiveWorkbench = useCallback((id: string) => {
    updateStore(prev => ({ ...prev, activeWorkbenchId: id }));
  }, [updateStore]);

  const addItem = useCallback((productId: number, productType: ProductType) => {
    updateStore(prev => updateActiveWorkbench(prev, wb => ({
      ...wb,
      items: [...wb.items, { instanceId: generateId(), productId, productType, addedAt: new Date().toISOString() }],
      updatedAt: new Date().toISOString(),
    })));
  }, [updateStore]);

  const removeItem = useCallback((instanceId: string) => {
    updateStore(prev => updateActiveWorkbench(prev, wb => ({
      ...wb,
      items: wb.items.filter(item => item.instanceId !== instanceId),
      updatedAt: new Date().toISOString(),
    })));
  }, [updateStore]);

  const removeAllInstances = useCallback((productId: number) => {
    updateStore(prev => updateActiveWorkbench(prev, wb => ({
      ...wb,
      items: wb.items.filter(item => item.productId !== productId),
      updatedAt: new Date().toISOString(),
    })));
  }, [updateStore]);

  const countInWorkbench = useCallback(
    (productId: number) => activeWorkbench.items.filter(item => item.productId === productId).length,
    [activeWorkbench],
  );

  const clear = useCallback(() => {
    updateStore(prev => updateActiveWorkbench(prev, wb => ({
      ...wb, items: [], updatedAt: new Date().toISOString(),
    })));
  }, [updateStore]);

  // --- Canvas view positions ---

  const updateViewPosition = useCallback((view: string, instanceId: string, x: number, y: number) => {
    updateStore(prev => updateActiveWorkbench(prev, wb => {
      const positions = { ...(wb.viewPositions || {}) };
      positions[view] = { ...(positions[view] || {}), [instanceId]: { x, y } };
      return { ...wb, viewPositions: positions, updatedAt: new Date().toISOString() };
    }));
  }, [updateStore]);

  const getViewPositions = useCallback(
    (view: string): Record<string, { x: number; y: number }> => {
      return activeWorkbench.viewPositions?.[view] || {};
    },
    [activeWorkbench],
  );

  // --- Power connections ---

  const addPowerConnection = useCallback((conn: Omit<PowerConnection, 'id'>) => {
    updateStore(prev => updateActiveWorkbench(prev, wb => ({
      ...wb,
      powerConnections: [...(wb.powerConnections || []), { ...conn, id: generateId() }],
      updatedAt: new Date().toISOString(),
    })));
  }, [updateStore]);

  const removePowerConnection = useCallback((connId: string) => {
    updateStore(prev => updateActiveWorkbench(prev, wb => ({
      ...wb,
      powerConnections: (wb.powerConnections || []).filter(c => c.id !== connId),
      updatedAt: new Date().toISOString(),
    })));
  }, [updateStore]);

  const setPowerConnections = useCallback((conns: PowerConnection[]) => {
    updateStore(prev => updateActiveWorkbench(prev, wb => ({
      ...wb,
      powerConnections: conns,
      updatedAt: new Date().toISOString(),
    })));
  }, [updateStore]);

  const acknowledgeWarning = useCallback((connId: string, warningKey: string) => {
    updateStore(prev => updateActiveWorkbench(prev, wb => ({
      ...wb,
      powerConnections: (wb.powerConnections || []).map(c =>
        c.id === connId
          ? { ...c, acknowledgedWarnings: [...(c.acknowledgedWarnings || []), warningKey] }
          : c,
      ),
      updatedAt: new Date().toISOString(),
    })));
  }, [updateStore]);

  const totalItemCount = useMemo(
    () => activeWorkbench.items.length,
    [activeWorkbench],
  );

  const value = useMemo<WorkbenchContextType>(
    () => ({
      workbenches: store.workbenches,
      activeWorkbench,
      createWorkbench,
      renameWorkbench,
      deleteWorkbench,
      setActiveWorkbench,
      addItem,
      removeItem,
      removeAllInstances,
      countInWorkbench,
      clear,
      updateViewPosition,
      getViewPositions,
      addPowerConnection,
      removePowerConnection,
      setPowerConnections,
      acknowledgeWarning,
      totalItemCount,
    }),
    [store.workbenches, activeWorkbench, createWorkbench, renameWorkbench, deleteWorkbench, setActiveWorkbench, addItem, removeItem, removeAllInstances, countInWorkbench, clear, updateViewPosition, getViewPositions, addPowerConnection, removePowerConnection, setPowerConnections, acknowledgeWarning, totalItemCount],
  );

  return (
    <WorkbenchContext.Provider value={value}>
      {children}
    </WorkbenchContext.Provider>
  );
}

export function useWorkbench(): WorkbenchContextType {
  const ctx = useContext(WorkbenchContext);
  if (!ctx) {
    throw new Error('useWorkbench must be used within a WorkbenchProvider');
  }
  return ctx;
}
