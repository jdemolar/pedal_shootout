import { Link } from 'react-router-dom';
import { WorkbenchRow } from './WorkbenchTable';
import { Jack } from '../../utils/transformers';

interface PowerBudgetInsightProps {
  rows: WorkbenchRow[];
}

interface PowerConsumer {
  manufacturer: string;
  model: string;
  current_ma: number | null;
  voltage: string | null;
  polarity: string | null;
  connector_type: string | null;
}

interface PowerSupplyInfo {
  manufacturer: string;
  model: string;
  total_current_ma: number | null;
  total_output_count: number | null;
  isolated_output_count: number | null;
  supply_type: string | null;
  available_voltages: string | null;
  mounting_type: string | null;
  output_jacks: Jack[];
}

function getPowerInputJack(row: WorkbenchRow): Jack | undefined {
  return row.jacks.find(j => j.category === 'power' && j.direction === 'input');
}

function getPowerOutputJacks(row: WorkbenchRow): Jack[] {
  return row.jacks.filter(j => j.category === 'power' && j.direction === 'output');
}

function formatMa(ma: number): string {
  return `${ma.toLocaleString()}mA`;
}

/** Find the majority polarity among supply output jacks */
function getMajorityPolarity(jacks: Jack[]): string | null {
  const counts: Record<string, number> = {};
  for (const j of jacks) {
    if (j.polarity) {
      counts[j.polarity] = (counts[j.polarity] || 0) + 1;
    }
  }
  let best: string | null = null;
  let bestCount = 0;
  for (const [pol, count] of Object.entries(counts)) {
    if (count > bestCount) {
      best = pol;
      bestCount = count;
    }
  }
  return best;
}

/** Find the majority connector type among supply output jacks */
function getMajorityConnector(jacks: Jack[]): string | null {
  const counts: Record<string, number> = {};
  for (const j of jacks) {
    if (j.connector_type) {
      counts[j.connector_type] = (counts[j.connector_type] || 0) + 1;
    }
  }
  let best: string | null = null;
  let bestCount = 0;
  for (const [ct, count] of Object.entries(counts)) {
    if (count > bestCount) {
      best = ct;
      bestCount = count;
    }
  }
  return best;
}

interface DaisyChainGroup {
  voltage: string;
  polarity: string;
  connector_type: string;
  consumers: PowerConsumer[];
  combined_ma: number;
  max_output_ma: number | null;
}

/**
 * When the supply has fewer outputs than pedals, identify groups of
 * electrically compatible pedals that could share an output via daisy-chain.
 */
function computeDaisyChainGroups(
  consumers: PowerConsumer[],
  outputJacks: Jack[],
): DaisyChainGroup[] {
  // Only consumers with full known power specs can be grouped
  const eligible = consumers.filter(
    c => c.current_ma != null && c.voltage != null && c.polarity != null && c.connector_type != null,
  );

  // Group by (voltage, polarity, connector_type)
  const groupMap = new Map<string, PowerConsumer[]>();
  for (const c of eligible) {
    const key = `${c.voltage}|${c.polarity}|${c.connector_type}`;
    const arr = groupMap.get(key);
    if (arr) arr.push(c);
    else groupMap.set(key, [c]);
  }

  const groups: DaisyChainGroup[] = [];
  for (const [key, members] of Array.from(groupMap)) {
    if (members.length < 2) continue; // need at least 2 to daisy-chain
    const [voltage, polarity, connector_type] = key.split('|');
    const combinedMa = members.reduce((sum: number, c: PowerConsumer) => sum + (c.current_ma as number), 0);

    // Find the highest-capacity output jack that matches this voltage
    const matchingOutputs = outputJacks.filter(j => j.voltage === voltage);
    const maxOutputMa = matchingOutputs.length > 0
      ? Math.max(...matchingOutputs.map(j => j.current_ma ?? 0))
      : null;

    // Only suggest if combined draw fits within an output
    if (maxOutputMa != null && combinedMa <= maxOutputMa) {
      groups.push({ voltage, polarity, connector_type, consumers: members, combined_ma: combinedMa, max_output_ma: maxOutputMa });
    }
  }

  return groups;
}

/** Build the "See all compatible power supplies" link URL */
function buildSupplyLinkUrl(
  totalDraw: number,
  consumerCount: number,
  highestDrawMa: number | null,
  uniqueVoltages: string[],
): string {
  const params = new URLSearchParams();
  if (totalDraw > 0) params.set('minCurrent', String(totalDraw));
  if (consumerCount > 0) params.set('minOutputs', String(consumerCount));
  if (highestDrawMa != null && highestDrawMa > 0) params.set('minOutputCurrent', String(highestDrawMa));
  if (uniqueVoltages.length > 0) params.set('voltages', uniqueVoltages.join(','));
  const qs = params.toString();
  return qs ? `/power-supplies?${qs}` : '/power-supplies';
}

const PowerBudgetInsight = ({ rows }: PowerBudgetInsightProps) => {
  // Separate consumers from suppliers
  const consumers: PowerConsumer[] = [];
  const supplies: PowerSupplyInfo[] = [];

  for (const row of rows) {
    if (row.product_type === 'power_supply') {
      supplies.push({
        manufacturer: row.manufacturer,
        model: row.model,
        total_current_ma: (row.detail.total_current_ma as number) ?? null,
        total_output_count: (row.detail.total_output_count as number) ?? null,
        isolated_output_count: (row.detail.isolated_output_count as number) ?? null,
        supply_type: (row.detail.supply_type as string) ?? null,
        available_voltages: (row.detail.available_voltages as string) ?? null,
        mounting_type: (row.detail.mounting_type as string) ?? null,
        output_jacks: getPowerOutputJacks(row),
      });
    } else {
      const powerJack = getPowerInputJack(row);
      if (powerJack || row.jacks.some(j => j.category === 'power' && j.direction === 'input')) {
        consumers.push({
          manufacturer: row.manufacturer,
          model: row.model,
          current_ma: powerJack?.current_ma ?? null,
          voltage: powerJack?.voltage ?? null,
          polarity: powerJack?.polarity ?? null,
          connector_type: powerJack?.connector_type ?? null,
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
  const highestDrawMa = highestDraw ? (highestDraw.current_ma as number) : null;

  // Unique voltages needed
  const uniqueVoltages = Array.from(
    new Set(consumers.map(c => c.voltage).filter((v): v is string => v != null))
  ).sort();

  const totalCapacity = supplies.reduce((sum, s) => sum + (s.total_current_ma ?? 0), 0);
  const hasSupply = supplies.length > 0;
  const knownSupplies = supplies.filter(s => s.total_current_ma != null);

  // Combined supply stats
  const totalOutputCount = supplies.reduce((sum, s) => sum + (s.total_output_count ?? 0), 0);
  const allOutputJacks = supplies.flatMap(s => s.output_jacks);

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

  // Build smart link URL
  const supplyLinkUrl = buildSupplyLinkUrl(totalDraw, consumers.length, highestDrawMa, uniqueVoltages);

  // --- Warnings (only when a supply is present) ---
  const warnings: React.ReactNode[] = [];

  if (hasSupply) {
    // 1. Output count warning
    const outputDiff = totalOutputCount - consumers.length;
    if (outputDiff < 0) {
      // Fewer outputs than pedals
      const daisyGroups = computeDaisyChainGroups(consumers, allOutputJacks);
      warnings.push(
        <div key="output-count" className="power-budget__warning power-budget__warning--warn">
          <strong>Output count:</strong> You have {consumers.length} device{consumers.length !== 1 ? 's' : ''} but only {totalOutputCount} output{totalOutputCount !== 1 ? 's' : ''} ({Math.abs(outputDiff)} short).
          {daisyGroups.length > 0 && (
            <div className="power-budget__daisy-chain">
              <div className="power-budget__daisy-chain-title">Possible daisy-chain groupings:</div>
              {daisyGroups.map((g, i) => (
                <div key={i} className="power-budget__daisy-chain-group">
                  {g.consumers.map(c => `${c.manufacturer} ${c.model}`).join(' + ')} (combined {formatMa(g.combined_ma)} on {g.voltage})
                </div>
              ))}
              <div className="power-budget__daisy-chain-disclaimer">
                This is only a suggestion — noise issues may still occur from sharing power outputs or using non-isolated power.
              </div>
            </div>
          )}
        </div>
      );
    } else if (outputDiff > 0) {
      warnings.push(
        <div key="output-count" className="power-budget__warning power-budget__warning--info">
          {outputDiff} unused output{outputDiff !== 1 ? 's' : ''} available for future expansion.
        </div>
      );
    }

    // 2. Isolation warning
    const totalIsolated = supplies.reduce((sum, s) => sum + (s.isolated_output_count ?? 0), 0);
    const nonIsolatedCount = totalOutputCount - totalIsolated;
    if (nonIsolatedCount > 0) {
      const supplyLabel = supplies.length === 1
        ? `Your ${supplies[0].manufacturer} ${supplies[0].model} has`
        : 'Your power supplies have';
      warnings.push(
        <div key="isolation" className="power-budget__warning power-budget__warning--info">
          <strong>Isolation:</strong> {supplyLabel} {nonIsolatedCount} non-isolated output{nonIsolatedCount !== 1 ? 's' : ''}. Non-isolated outputs can introduce noise — particularly with digital pedals, though analog pedals may also be affected.
        </div>
      );
    }

    // 3. Polarity mismatch
    const majorityPolarity = getMajorityPolarity(allOutputJacks);
    if (majorityPolarity) {
      const mismatched = consumers.filter(c => c.polarity != null && c.polarity !== majorityPolarity);
      for (const c of mismatched) {
        warnings.push(
          <div key={`polarity-${c.manufacturer}-${c.model}`} className="power-budget__warning power-budget__warning--warn">
            <strong>Polarity:</strong> {c.manufacturer} {c.model} requires {c.polarity} — you may need a polarity-reversal adapter cable.
          </div>
        );
      }
    }

    // 4. Connector type mismatch
    const majorityConnector = getMajorityConnector(allOutputJacks);
    if (majorityConnector) {
      const mismatched = consumers.filter(c => c.connector_type != null && c.connector_type !== majorityConnector);
      for (const c of mismatched) {
        warnings.push(
          <div key={`connector-${c.manufacturer}-${c.model}`} className="power-budget__warning power-budget__warning--warn">
            <strong>Connector:</strong> {c.manufacturer} {c.model} uses a {c.connector_type} connector — you may need an adapter cable.
          </div>
        );
      }
    }

    // 5. Mounting info
    const mountingTypes = supplies
      .map(s => s.mounting_type)
      .filter((m): m is string => m != null);
    if (mountingTypes.length > 0) {
      const unique = Array.from(new Set(mountingTypes));
      warnings.push(
        <div key="mounting" className="power-budget__warning power-budget__warning--neutral">
          <strong>Mounting:</strong> {unique.join(', ')}
        </div>
      );
    }
  }

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
          <Link to={supplyLinkUrl} className="power-budget__link">
            See all compatible power supplies {'\u2192'}
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
          <Link to={supplyLinkUrl} className="power-budget__link">
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

      {/* Warnings */}
      {warnings.length > 0 && (
        <div className="power-budget__warnings">
          {warnings}
        </div>
      )}
    </div>
  );
};

export default PowerBudgetInsight;
