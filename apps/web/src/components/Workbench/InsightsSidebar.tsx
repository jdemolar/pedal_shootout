import { WorkbenchRow } from './WorkbenchTable';
import { ProductType } from '../../context/WorkbenchContext';
import { formatMsrp } from '../../utils/formatters';
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

const InsightsSidebar = ({ rows }: InsightsSidebarProps) => {
  return (
    <div className="insights">
      <ItemCount rows={rows} />
      <TotalCost rows={rows} />
      <TotalWeight rows={rows} />
      <MidiPedals rows={rows} />
      <PowerBudgetInsight rows={rows} />
    </div>
  );
};

export default InsightsSidebar;
