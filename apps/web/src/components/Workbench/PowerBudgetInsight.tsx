import { useState } from 'react';
import { Link } from 'react-router-dom';
import { WorkbenchRow } from './WorkbenchTable';
import { normalizePolarity, normalizeConnector } from '../../utils/powerUtils';
import {
  extractPowerData,
  formatMa,
  getMajorityPolarity,
  getMajorityConnector,
  computeDaisyChainGroups,
  assignPedalsToOutputs,
  buildSupplyLinkUrl,
} from '../../utils/powerAssignment';

interface PowerBudgetInsightProps {
  rows: WorkbenchRow[];
}

const PowerBudgetInsight = ({ rows }: PowerBudgetInsightProps) => {
  const [showAssignments, setShowAssignments] = useState(false);

  const {
    consumers,
    supplies,
    unknownConsumers,
    totalDraw,
    highestDraw,
    totalCapacity,
    status,
    headroom,
    headroomPct,
    uniqueVoltages,
    totalOutputCount,
    allOutputJacks,
  } = extractPowerData(rows);

  // No power consumers at all — nothing to show
  if (consumers.length === 0) return null;

  const highestDrawMa = highestDraw ? (highestDraw.current_ma as number) : null;
  const hasSupply = supplies.length > 0;
  const knownSupplies = supplies.filter(s => s.total_current_ma != null);

  // Build smart link URL
  const supplyLinkUrl = buildSupplyLinkUrl(totalDraw, consumers.length, highestDrawMa, uniqueVoltages);

  // --- Warnings (only when a supply is present) ---
  const warnings: React.ReactNode[] = [];

  if (hasSupply) {
    // 1. Output count warning
    const outputDiff = totalOutputCount - consumers.length;
    if (outputDiff < 0) {
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
      const mismatched = consumers.filter(c => c.polarity != null && normalizePolarity(c.polarity) !== majorityPolarity);
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
      const mismatched = consumers.filter(c => c.connector_type != null && normalizeConnector(c.connector_type) !== majorityConnector);
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

      {/* Port assignments */}
      {hasSupply && consumers.length > 0 && (() => {
        const result = assignPedalsToOutputs(consumers, supplies);
        return (
          <div className="power-budget__assignment">
            <button
              className="power-budget__assignment-toggle"
              onClick={() => setShowAssignments(!showAssignments)}
            >
              {showAssignments ? 'Hide' : 'Show'} port assignments
              <span className="power-budget__assignment-toggle-icon">
                {showAssignments ? '\u25b4' : '\u25be'}
              </span>
            </button>
            {showAssignments && (
              <div className="power-budget__assignment-list">
                {result.assignments.map((a, i) => (
                  <div key={i} className="power-budget__assignment-row">
                    <div className="power-budget__assignment-mapping">
                      <span className="power-budget__assignment-pedal">
                        {a.consumer.manufacturer} {a.consumer.model}
                        {a.consumer.current_ma != null && ` (${formatMa(a.consumer.current_ma)})`}
                      </span>
                      <span className="power-budget__assignment-arrow">{'\u2192'}</span>
                      <span className="power-budget__assignment-port">
                        {a.jack.supplyName}: Output {a.jack.portIndex}
                        {a.jack.voltage && ` (${a.jack.voltage}`}
                        {a.jack.current_ma != null && `, ${formatMa(a.jack.current_ma)}`}
                        {(a.jack.voltage || a.jack.current_ma != null) && ')'}
                      </span>
                    </div>
                    {a.notes.length > 0 && (
                      <div className="power-budget__assignment-notes">
                        {a.notes.map((note, ni) => (
                          <div key={ni} className="power-budget__assignment-note">{note}</div>
                        ))}
                      </div>
                    )}
                  </div>
                ))}
                {result.unassigned.length > 0 && (
                  <div className="power-budget__assignment-unassigned">
                    <div className="power-budget__assignment-unassigned-title">
                      No compatible port found:
                    </div>
                    {result.unassigned.map((c, i) => (
                      <div key={i} className="power-budget__assignment-unassigned-item">
                        {c.manufacturer} {c.model}
                        {c.current_ma != null && ` (${formatMa(c.current_ma)})`}
                        {c.voltage && ` @ ${c.voltage}`}
                      </div>
                    ))}
                  </div>
                )}
              </div>
            )}
          </div>
        );
      })()}
    </div>
  );
};

export default PowerBudgetInsight;
