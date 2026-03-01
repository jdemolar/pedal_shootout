import { useState, useEffect, useCallback, useMemo } from 'react';
import { WorkbenchItem, ProductType, useWorkbench } from '../../context/WorkbenchContext';
import { api } from '../../services/api';
import { formatMsrp, formatDimensions } from '../../utils/formatters';
import {
  transformPedal,
  transformPowerSupply,
  transformMidiController,
  transformPedalboard,
  transformUtility,
  Jack,
} from '../../utils/transformers';
import { computeShoppingList, ShoppingList } from '../../utils/shoppingListUtils';

export interface WorkbenchRow {
  id: number;
  instanceId: string;
  product_type: ProductType;
  manufacturer: string;
  model: string;
  width_mm: number | null;
  depth_mm: number | null;
  height_mm: number | null;
  weight_grams: number | null;
  msrp_cents: number | null;
  in_production: boolean;
  jacks: Jack[];
  // Full transformed data for the detail panel
  detail: Record<string, unknown>;
  // Quantity and instance tracking (populated by useWorkbenchProducts)
  quantity: number;
  instanceIds: string[];
}

const TYPE_LABELS: Record<ProductType, string> = {
  pedal: 'Pedal',
  power_supply: 'PSU',
  pedalboard: 'Pedalboard',
  midi_controller: 'MIDI Controller',
  utility: 'Utility',
};

interface FetchedProduct {
  id: number;
  product_type: ProductType;
  manufacturer: string;
  model: string;
  width_mm: number | null;
  depth_mm: number | null;
  height_mm: number | null;
  weight_grams: number | null;
  msrp_cents: number | null;
  in_production: boolean;
  jacks: Jack[];
  detail: Record<string, unknown>;
}

async function fetchProductData(productId: number, productType: ProductType): Promise<FetchedProduct | null> {
  try {
    switch (productType) {
      case 'pedal': {
        const raw = await api.getPedal(productId);
        const t = transformPedal(raw);
        return { id: t.id, product_type: 'pedal', manufacturer: t.manufacturer, model: t.model, width_mm: t.width_mm, depth_mm: t.depth_mm, height_mm: t.height_mm, weight_grams: t.weight_grams, msrp_cents: t.msrp_cents, in_production: t.in_production, jacks: t.jacks, detail: t as unknown as Record<string, unknown> };
      }
      case 'power_supply': {
        const raw = await api.getPowerSupply(productId);
        const t = transformPowerSupply(raw);
        return { id: t.id, product_type: 'power_supply', manufacturer: t.manufacturer, model: t.model, width_mm: t.width_mm, depth_mm: t.depth_mm, height_mm: t.height_mm, weight_grams: t.weight_grams, msrp_cents: t.msrp_cents, in_production: t.in_production, jacks: t.jacks, detail: t as unknown as Record<string, unknown> };
      }
      case 'midi_controller': {
        const raw = await api.getMidiController(productId);
        const t = transformMidiController(raw);
        return { id: t.id, product_type: 'midi_controller', manufacturer: t.manufacturer, model: t.model, width_mm: t.width_mm, depth_mm: t.depth_mm, height_mm: t.height_mm, weight_grams: t.weight_grams, msrp_cents: t.msrp_cents, in_production: t.in_production, jacks: t.jacks, detail: t as unknown as Record<string, unknown> };
      }
      case 'pedalboard': {
        const raw = await api.getPedalboard(productId);
        const t = transformPedalboard(raw);
        return { id: t.id, product_type: 'pedalboard', manufacturer: t.manufacturer, model: t.model, width_mm: t.width_mm, depth_mm: t.depth_mm, height_mm: t.height_mm, weight_grams: t.weight_grams, msrp_cents: t.msrp_cents, in_production: t.in_production, jacks: t.jacks, detail: t as unknown as Record<string, unknown> };
      }
      case 'utility': {
        const raw = await api.getUtility(productId);
        const t = transformUtility(raw);
        return { id: t.id, product_type: 'utility', manufacturer: t.manufacturer, model: t.model, width_mm: t.width_mm, depth_mm: t.depth_mm, height_mm: t.height_mm, weight_grams: t.weight_grams, msrp_cents: t.msrp_cents, in_production: t.in_production, jacks: t.jacks, detail: t as unknown as Record<string, unknown> };
      }
    }
  } catch {
    return null;
  }
}

type CableSortField = 'category' | 'label' | 'quantity';
type SortDir = 'asc' | 'desc';

function CableTable({ shoppingList }: { shoppingList: ShoppingList }) {
  const [sortField, setSortField] = useState<CableSortField>('category');
  const [sortDir, setSortDir] = useState<SortDir>('asc');

  if (shoppingList.cables.length === 0) return null;

  const handleSort = (field: CableSortField) => {
    if (sortField === field) {
      setSortDir(prev => (prev === 'asc' ? 'desc' : 'asc'));
    } else {
      setSortField(field);
      setSortDir('asc');
    }
  };

  const sortIndicator = (field: CableSortField) =>
    sortField === field ? (sortDir === 'asc' ? ' \u25b2' : ' \u25bc') : '';

  const sorted = [...shoppingList.cables].sort((a, b) => {
    const dir = sortDir === 'asc' ? 1 : -1;
    switch (sortField) {
      case 'category': return dir * a.category.localeCompare(b.category);
      case 'label': return dir * a.label.localeCompare(b.label);
      case 'quantity': return dir * (a.quantity - b.quantity);
      default: return 0;
    }
  });

  const { totalCables, totalCustomCables } = shoppingList.summary;

  return (
    <div className="workbench__cables-section">
      <div className="workbench__cables-header">Cables &amp; Adapters</div>
      <table className="workbench__table">
        <thead>
          <tr>
            <th
              className="workbench__th workbench__th--sortable"
              style={{ width: 100, textAlign: 'center', cursor: 'pointer' }}
              onClick={() => handleSort('category')}
            >
              Category{sortIndicator('category')}
            </th>
            <th
              className="workbench__th workbench__th--sortable"
              style={{ cursor: 'pointer' }}
              onClick={() => handleSort('label')}
            >
              Description{sortIndicator('label')}
            </th>
            <th
              className="workbench__th workbench__th--sortable"
              style={{ width: 50, textAlign: 'center', cursor: 'pointer' }}
              onClick={() => handleSort('quantity')}
            >
              Qty{sortIndicator('quantity')}
            </th>
            <th className="workbench__th" style={{ width: 280 }}>Notes</th>
          </tr>
        </thead>
        <tbody>
          {sorted.map((cable, i) => (
            <tr key={`${cable.category}-${cable.sourceConnectorType}-${cable.targetConnectorType}`} className={`workbench__row ${i % 2 === 0 ? 'even' : 'odd'}`}>
              <td className="workbench__td" style={{ textAlign: 'center' }}>
                <span className={`cable-badge cable-badge--${cable.category}`}>
                  {cable.category === 'midi' ? 'MIDI' : cable.category.charAt(0).toUpperCase() + cable.category.slice(1)}
                </span>
              </td>
              <td className="workbench__td">
                <span style={{ color: '#d0d0d0' }}>
                  {cable.label}
                  {cable.requiresCustomCable && (
                    <span className="cable-custom-flag" title="Custom cable or adapter needed"> *</span>
                  )}
                </span>
              </td>
              <td className="workbench__td" style={{ textAlign: 'center' }}>
                <span style={{ color: cable.quantity > 1 ? '#6abf7b' : '#888', fontFamily: 'monospace', fontSize: '12px' }}>
                  {cable.quantity > 1 ? `\u00d7 ${cable.quantity}` : '\u00d7 1'}
                </span>
              </td>
              <td className="workbench__td">
                {cable.notes.length > 0 && (
                  <span style={{ color: '#aa8844', fontSize: '11px' }}>
                    {cable.notes.join('; ')}
                  </span>
                )}
              </td>
            </tr>
          ))}
        </tbody>
      </table>
      <div className="workbench__cables-totals">
        {totalCables} cable{totalCables !== 1 ? 's' : ''}
        {totalCustomCables > 0 && ` (${totalCustomCables} custom)`}
      </div>
    </div>
  );
}

interface WorkbenchTableProps {
  onRowClick: (row: WorkbenchRow) => void;
  rows: WorkbenchRow[];
  loading: boolean;
  error: string | null;
}

const WorkbenchTableView = ({ onRowClick, rows, loading, error }: WorkbenchTableProps) => {
  const { activeWorkbench, removeAllInstances } = useWorkbench();

  const shoppingList = useMemo(() => {
    const jackMap = new Map<number, Jack>();
    for (const row of rows) {
      for (const jack of row.jacks) {
        jackMap.set(jack.id, jack);
      }
    }
    return computeShoppingList(
      activeWorkbench.powerConnections ?? [],
      activeWorkbench.audioConnections ?? [],
      activeWorkbench.midiConnections ?? [],
      activeWorkbench.controlConnections ?? [],
      jackMap,
    );
  }, [activeWorkbench, rows]);

  if (loading) {
    return <div className="workbench__loading">Loading workbench products...</div>;
  }

  if (error) {
    return <div className="workbench__error">Failed to load products: {error}</div>;
  }

  if (rows.length === 0) {
    return <div className="workbench__empty">Your workbench is empty. Add products from the catalog views.</div>;
  }

  return (
    <div className="workbench__table-wrapper">
      <table className="workbench__table">
        <thead>
          <tr>
            <th className="workbench__th" style={{ width: 160 }}>Manufacturer</th>
            <th className="workbench__th" style={{ width: 200 }}>Model</th>
            <th className="workbench__th" style={{ width: 50, textAlign: 'center' }}>Qty</th>
            <th className="workbench__th" style={{ width: 120, textAlign: 'center' }}>Type</th>
            <th className="workbench__th" style={{ width: 160, textAlign: 'center' }}>Dimensions</th>
            <th className="workbench__th" style={{ width: 90, textAlign: 'right' }}>MSRP</th>
            <th className="workbench__th" style={{ width: 80, textAlign: 'right' }}>Weight</th>
            <th className="workbench__th" style={{ width: 80, textAlign: 'center' }}>Status</th>
            <th className="workbench__th" style={{ width: 40 }} />
          </tr>
        </thead>
        <tbody>
          {rows.map((row, i) => (
            <tr
              key={row.id}
              className={`workbench__row ${i % 2 === 0 ? 'even' : 'odd'}`}
              onClick={() => onRowClick(row)}
            >
              <td className="workbench__td">
                <span style={{ color: '#f0f0f0', fontSize: '12.5px', fontWeight: 600, fontFamily: "'Helvetica Neue', sans-serif" }}>
                  {row.manufacturer}
                </span>
              </td>
              <td className="workbench__td">
                <span style={{ color: '#d0d0d0' }}>{row.model}</span>
              </td>
              <td className="workbench__td" style={{ textAlign: 'center' }}>
                <span style={{ color: row.quantity > 1 ? '#6abf7b' : '#888', fontFamily: 'monospace', fontSize: '12px' }}>
                  {row.quantity > 1 ? `\u00d7 ${row.quantity}` : '\u00d7 1'}
                </span>
              </td>
              <td className="workbench__td" style={{ textAlign: 'center' }}>
                <span className={`type-badge type-badge--${row.product_type}`}>
                  {TYPE_LABELS[row.product_type]}
                </span>
              </td>
              <td className="workbench__td" style={{ textAlign: 'center' }}>
                {row.width_mm != null && row.depth_mm != null && row.height_mm != null
                  ? formatDimensions(row.width_mm, row.depth_mm, row.height_mm)
                  : <span className="null-value">{'\u2014'}</span>
                }
              </td>
              <td className="workbench__td" style={{ textAlign: 'right' }}>
                {row.msrp_cents != null
                  ? formatMsrp(row.msrp_cents)
                  : <span className="null-value">{'\u2014'}</span>
                }
              </td>
              <td className="workbench__td" style={{ textAlign: 'right' }}>
                {row.weight_grams != null
                  ? `${(row.weight_grams / 1000).toFixed(2)} kg`
                  : <span className="null-value">{'\u2014'}</span>
                }
              </td>
              <td className="workbench__td" style={{ textAlign: 'center' }}>
                <span className={`status-badge status-badge--${row.in_production ? 'in-production' : 'discontinued'}`}>
                  {row.in_production ? 'Active' : 'Disc.'}
                </span>
              </td>
              <td className="workbench__td" style={{ textAlign: 'center' }}>
                <button
                  className="workbench__remove-btn"
                  onClick={e => { e.stopPropagation(); removeAllInstances(row.id); }}
                  title="Remove all from workbench"
                  aria-label="Remove all from workbench"
                >
                  {'\u00d7'}
                </button>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
      <CableTable shoppingList={shoppingList} />
    </div>
  );
};

// Hook to fetch and manage workbench product data
export function useWorkbenchProducts() {
  const { activeWorkbench } = useWorkbench();
  const [rows, setRows] = useState<WorkbenchRow[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const fetchAll = useCallback(async (items: WorkbenchItem[]) => {
    if (items.length === 0) {
      setRows([]);
      setLoading(false);
      return;
    }

    setLoading(true);
    setError(null);

    try {
      // Deduplicate by productId — fetch each unique product once
      const uniqueItems = new Map<number, WorkbenchItem>();
      for (const item of items) {
        if (!uniqueItems.has(item.productId)) {
          uniqueItems.set(item.productId, item);
        }
      }

      const fetchPromises = Array.from(uniqueItems.values()).map(
        item => fetchProductData(item.productId, item.productType)
      );
      const fetched = await Promise.all(fetchPromises);

      // Build a lookup of productId → fetched data
      const productDataMap = new Map<number, FetchedProduct>();
      for (const result of fetched) {
        if (result) productDataMap.set(result.id, result);
      }

      // Compute quantity and instanceIds per productId
      const instancesByProduct = new Map<number, string[]>();
      for (const item of items) {
        const list = instancesByProduct.get(item.productId) || [];
        list.push(item.instanceId);
        instancesByProduct.set(item.productId, list);
      }

      // Build per-instance rows
      const allRows: WorkbenchRow[] = [];
      for (const item of items) {
        const data = productDataMap.get(item.productId);
        if (!data) continue;
        const instanceIds = instancesByProduct.get(item.productId) || [];
        allRows.push({
          ...data,
          instanceId: item.instanceId,
          quantity: instanceIds.length,
          instanceIds,
        });
      }

      setRows(allRows);

      const failedCount = items.length - allRows.length;
      if (failedCount > 0) {
        setError(`${failedCount} product${failedCount === 1 ? '' : 's'} could not be loaded (may have been removed from the database).`);
      }
    } catch {
      setError('Failed to load workbench products.');
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    fetchAll(activeWorkbench.items);
  }, [activeWorkbench.items, fetchAll]);

  // Grouped rows: one per unique productId, for the list view
  const groupedRows = useMemo(() => {
    const seen = new Map<number, WorkbenchRow>();
    for (const row of rows) {
      if (!seen.has(row.id)) {
        seen.set(row.id, row);
      }
    }
    return Array.from(seen.values());
  }, [rows]);

  return { rows, groupedRows, loading, error };
}

export default WorkbenchTableView;
