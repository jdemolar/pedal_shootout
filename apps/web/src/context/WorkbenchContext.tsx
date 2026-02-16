import { createContext, useContext, useState, useCallback, useMemo, ReactNode } from 'react';

// --- Types ---

export type ProductType = 'pedal' | 'power_supply' | 'pedalboard' | 'midi_controller' | 'utility';

export interface WorkbenchItem {
  productId: number;
  productType: ProductType;
  addedAt: string;
  // Phase 2 (visual layout):
  position?: { x: number; y: number };
  rotation?: number;
}

export interface Workbench {
  id: string;
  name: string;
  items: WorkbenchItem[];
  createdAt: string;
  updatedAt: string;
  // Phase 2 (visual layout):
  boardId?: number;
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
  removeItem: (productId: number) => void;
  isInWorkbench: (productId: number) => boolean;
  clear: () => void;

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
        return parsed;
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
    updateStore(prev => ({
      ...prev,
      workbenches: prev.workbenches.map(wb => {
        if (wb.id !== prev.activeWorkbenchId) return wb;
        // Don't add duplicates
        if (wb.items.some(item => item.productId === productId)) return wb;
        return {
          ...wb,
          items: [...wb.items, { productId, productType, addedAt: new Date().toISOString() }],
          updatedAt: new Date().toISOString(),
        };
      }),
    }));
  }, [updateStore]);

  const removeItem = useCallback((productId: number) => {
    updateStore(prev => ({
      ...prev,
      workbenches: prev.workbenches.map(wb => {
        if (wb.id !== prev.activeWorkbenchId) return wb;
        return {
          ...wb,
          items: wb.items.filter(item => item.productId !== productId),
          updatedAt: new Date().toISOString(),
        };
      }),
    }));
  }, [updateStore]);

  const isInWorkbench = useCallback(
    (productId: number) => activeWorkbench.items.some(item => item.productId === productId),
    [activeWorkbench],
  );

  const clear = useCallback(() => {
    updateStore(prev => ({
      ...prev,
      workbenches: prev.workbenches.map(wb => {
        if (wb.id !== prev.activeWorkbenchId) return wb;
        return { ...wb, items: [], updatedAt: new Date().toISOString() };
      }),
    }));
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
      isInWorkbench,
      clear,
      totalItemCount,
    }),
    [store.workbenches, activeWorkbench, createWorkbench, renameWorkbench, deleteWorkbench, setActiveWorkbench, addItem, removeItem, isInWorkbench, clear, totalItemCount],
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
