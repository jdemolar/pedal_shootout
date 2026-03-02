import { useMemo } from 'react';
import { WorkbenchRow } from './WorkbenchTable';
import { ProductType, useWorkbench } from '../../context/WorkbenchContext';
import { formatMsrp } from '../../utils/formatters';
import { Jack } from '../../utils/transformers';
import { computeShoppingList, CableCategory } from '../../utils/shoppingListUtils';
import PowerBudgetInsight from './PowerBudgetInsight';

interface InsightsSidebarProps {
  rows: WorkbenchRow[];
}

const TYPE_LABELS: Record<ProductType, string> = {
  pedal: 'pedal',
  power_supply: 'PSU',
  pedalboard: 'pedalboard',
  midi_controller: 'MIDI controller',
  utility: 'utility',
};

function pluralize(count: number, singular: string): string {
  if (count === 1) return `${count} ${singular}`;
  // Simple pluralization
  if (singular.endsWith('y') && singular !== 'PSU') {
    return `${count} ${singular.slice(0, -1)}ies`;
  }
  return `${count} ${singular}s`;
}

function ItemCount({ rows }: { rows: WorkbenchRow[] }) {
  const counts = new Map<ProductType, number>();
  for (const row of rows) {
    counts.set(row.product_type, (counts.get(row.product_type) || 0) + 1);
  }

  const parts: string[] = [];
  const order: ProductType[] = ['pedal', 'power_supply', 'pedalboard', 'midi_controller', 'utility'];
  for (const type of order) {
    const count = counts.get(type);
    if (count != null && count > 0) {
      parts.push(pluralize(count, TYPE_LABELS[type]));
    }
  }

  return (
    <div className="insights__card">
      <div className="insights__card-label">Items</div>
      <div className="insights__card-value">{rows.length}</div>
      {parts.length > 0 && (
        <div className="insights__card-detail">{parts.join(' \u00b7 ')}</div>
      )}
    </div>
  );
}

function TotalCost({ rows }: { rows: WorkbenchRow[] }) {
  let totalCents = 0;
  let unknownCount = 0;

  for (const row of rows) {
    if (row.msrp_cents != null) {
      totalCents += row.msrp_cents;
    } else {
      unknownCount++;
    }
  }

  return (
    <div className="insights__card">
      <div className="insights__card-label">Total Cost</div>
      <div className="insights__card-value">
        {rows.length === 0 ? '\u2014' : formatMsrp(totalCents)}
      </div>
      {unknownCount > 0 && (
        <div className="insights__card-detail insights__card-detail--warn">
          {unknownCount} unknown
        </div>
      )}
    </div>
  );
}

function TotalWeight({ rows }: { rows: WorkbenchRow[] }) {
  let totalGrams = 0;
  let unknownCount = 0;

  for (const row of rows) {
    if (row.weight_grams != null) {
      totalGrams += row.weight_grams;
    } else {
      unknownCount++;
    }
  }

  const display = rows.length === 0
    ? '\u2014'
    : `${(totalGrams / 1000).toFixed(2)} kg`;

  return (
    <div className="insights__card">
      <div className="insights__card-label">Total Weight</div>
      <div className="insights__card-value">{display}</div>
      {unknownCount > 0 && (
        <div className="insights__card-detail insights__card-detail--warn">
          {unknownCount} unknown
        </div>
      )}
    </div>
  );
}

function MidiPedals({ rows }: { rows: WorkbenchRow[] }) {
  const pedals = rows.filter(r => r.product_type === 'pedal');
  if (pedals.length === 0) return null;

  const midiCount = pedals.filter(r => r.detail.midi_capable === true).length;

  return (
    <div className="insights__card">
      <div className="insights__card-label">MIDI Pedals</div>
      <div className="insights__card-value">
        {midiCount} of {pedals.length}
      </div>
    </div>
  );
}

function CableSummary({ rows }: { rows: WorkbenchRow[] }) {
  const { activeWorkbench } = useWorkbench();

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

  if (shoppingList.summary.totalCables === 0) return null;

  const { totalCables, totalCustomCables, byCategory } = shoppingList.summary;
  const parts: string[] = [];
  const order: CableCategory[] = ['audio', 'power', 'midi', 'control'];
  for (const cat of order) {
    if (byCategory[cat] > 0) {
      const label = cat === 'midi' ? 'MIDI' : cat.charAt(0).toUpperCase() + cat.slice(1);
      parts.push(`${label}: ${byCategory[cat]}`);
    }
  }

  return (
    <div className="insights__card">
      <div className="insights__card-label">Cables</div>
      <div className="insights__card-value">
        {totalCables} cable{totalCables !== 1 ? 's' : ''}
        {totalCustomCables > 0 && ` (${totalCustomCables} custom)`}
      </div>
      {parts.length > 0 && (
        <div className="insights__card-detail">{parts.join(' \u00b7 ')}</div>
      )}
    </div>
  );
}

const InsightsSidebar = ({ rows }: InsightsSidebarProps) => {
  return (
    <div className="insights">
      <ItemCount rows={rows} />
      <TotalCost rows={rows} />
      <TotalWeight rows={rows} />
      <MidiPedals rows={rows} />
      <PowerBudgetInsight rows={rows} />
      <CableSummary rows={rows} />
    </div>
  );
};

export default InsightsSidebar;
