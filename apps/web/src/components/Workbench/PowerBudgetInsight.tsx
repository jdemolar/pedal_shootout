import { Link } from 'react-router-dom';
import { WorkbenchRow } from './WorkbenchTable';

interface PowerBudgetInsightProps {
  rows: WorkbenchRow[];
}

interface PowerConsumer {
  manufacturer: string;
  model: string;
  current_ma: number | null;
}

interface PowerSupply {
  manufacturer: string;
  model: string;
  total_current_ma: number | null;
}

function getPowerConsumption(row: WorkbenchRow): number | null {
  const powerJack = row.jacks.find(j => j.category === 'power' && j.direction === 'input');
  return powerJack?.current_ma ?? null;
}

function getPowerCapacity(row: WorkbenchRow): number | null {
  return (row.detail.total_current_ma as number) ?? null;
}

function formatMa(ma: number): string {
  return `${ma.toLocaleString()}mA`;
}

const PowerBudgetInsight = ({ rows }: PowerBudgetInsightProps) => {
  // Separate consumers from suppliers
  const consumers: PowerConsumer[] = [];
  const supplies: PowerSupply[] = [];

  for (const row of rows) {
    if (row.product_type === 'power_supply') {
      supplies.push({
        manufacturer: row.manufacturer,
        model: row.model,
        total_current_ma: getPowerCapacity(row),
      });
    } else {
      // Any non-PSU product with a power input jack is a consumer
      const currentMa = getPowerConsumption(row);
      if (currentMa != null || row.jacks.some(j => j.category === 'power' && j.direction === 'input')) {
        consumers.push({
          manufacturer: row.manufacturer,
          model: row.model,
          current_ma: currentMa,
        });
      }
    }
  }

  // No power consumers at all — nothing to show
  if (consumers.length === 0) return null;

  const knownConsumers = consumers.filter(c => c.current_ma != null);
  const unknownConsumers = consumers.filter(c => c.current_ma == null);
  const totalDraw = knownConsumers.reduce((sum, c) => sum + (c.current_ma as number), 0);
  const highestDraw = knownConsumers.length > 0
    ? knownConsumers.reduce((max, c) => (c.current_ma as number) > (max.current_ma as number) ? c : max)
    : null;

  const totalCapacity = supplies.reduce((sum, s) => sum + (s.total_current_ma ?? 0), 0);
  const hasSupply = supplies.length > 0;
  const knownSupplies = supplies.filter(s => s.total_current_ma != null);

  // Determine state
  let status: 'no-supply' | 'insufficient' | 'sufficient';
  if (!hasSupply) {
    status = 'no-supply';
  } else if (totalCapacity < totalDraw) {
    status = 'insufficient';
  } else {
    status = 'sufficient';
  }

  const headroom = totalCapacity - totalDraw;
  const headroomPct = totalCapacity > 0 ? Math.round((headroom / totalCapacity) * 100) : 0;

  return (
    <div className="power-budget">
      <div className="power-budget__header">
        <span className="power-budget__icon">{'\u26a1'}</span>
        <span className="power-budget__title">Power Budget</span>
        {status === 'no-supply' && (
          <span className="power-budget__status power-budget__status--none">{'\u2014'}</span>
        )}
        {status === 'insufficient' && (
          <span className="power-budget__status power-budget__status--warn">{'\u26a0\ufe0f'} Insufficient</span>
        )}
        {status === 'sufficient' && (
          <span className="power-budget__status power-budget__status--ok">{'\u2713'} OK</span>
        )}
      </div>

      {/* Total draw */}
      <div className="power-budget__draw">
        Your {consumers.length} device{consumers.length !== 1 ? 's' : ''} draw{consumers.length === 1 ? 's' : ''} {formatMa(totalDraw)} total.
      </div>

      {unknownConsumers.length > 0 && (
        <div className="power-budget__unknown">
          {unknownConsumers.length} device{unknownConsumers.length !== 1 ? 's' : ''} with unknown draw
        </div>
      )}

      {highestDraw && (
        <div className="power-budget__detail">
          Highest: {highestDraw.manufacturer} {highestDraw.model} ({formatMa(highestDraw.current_ma as number)})
        </div>
      )}

      {/* State-specific content */}
      {status === 'no-supply' && (
        <div className="power-budget__prompt">
          <p>No power supply in workbench.</p>
          <Link to="/power-supplies" className="power-budget__link">
            Find power supplies {'\u2192'}
          </Link>
        </div>
      )}

      {status === 'insufficient' && (
        <>
          <div className="power-budget__deficit">
            {supplies.length === 1 ? (
              <>Your {supplies[0].manufacturer} {supplies[0].model} provides {formatMa(totalCapacity)}.</>
            ) : (
              <>Combined supply capacity: {formatMa(totalCapacity)}.</>
            )}
            <br />
            <span className="power-budget__deficit-amount">
              {formatMa(Math.abs(headroom))} short
            </span>
          </div>
          {supplies.length > 1 && (
            <div className="power-budget__breakdown">
              {knownSupplies.map((s, i) => (
                <div key={i} className="power-budget__breakdown-item">
                  {s.manufacturer} {s.model}: {formatMa(s.total_current_ma as number)}
                </div>
              ))}
            </div>
          )}
          <Link to="/power-supplies" className="power-budget__link">
            Find additional power supplies {'\u2192'}
          </Link>
        </>
      )}

      {status === 'sufficient' && (
        <>
          {supplies.length === 1 ? (
            <div className="power-budget__capacity">
              Your {supplies[0].manufacturer} {supplies[0].model} provides {formatMa(totalCapacity)}.
              <br />
              <span className="power-budget__headroom">
                {formatMa(headroom)} headroom ({headroomPct}%)
              </span>
            </div>
          ) : (
            <>
              <div className="power-budget__capacity">
                Combined supply capacity: {formatMa(totalCapacity)}.
                <br />
                <span className="power-budget__headroom">
                  {formatMa(headroom)} headroom ({headroomPct}%)
                </span>
              </div>
              <div className="power-budget__breakdown">
                {knownSupplies.map((s, i) => (
                  <div key={i} className="power-budget__breakdown-item">
                    {s.manufacturer} {s.model}: {formatMa(s.total_current_ma as number)}
                  </div>
                ))}
              </div>
            </>
          )}
        </>
      )}
    </div>
  );
};

export default PowerBudgetInsight;
