/**
 * Power budget calculation utilities.
 * Extracted from PowerBudgetInsight.tsx for reuse in the Power canvas view.
 */

import { Jack } from './transformers';
import { normalizePolarity, normalizeConnector, voltagesCompatible } from './powerUtils';
import {
  PowerConsumer,
  PowerSupplyInfo,
  TaggedOutputJack,
  PortAssignment,
  AssignmentResult,
  DaisyChainGroup,
  PowerBudgetData,
} from '../types/power';

// Re-export types for convenience
export type {
  PowerConsumer,
  PowerSupplyInfo,
  TaggedOutputJack,
  PortAssignment,
  AssignmentResult,
  DaisyChainGroup,
  PowerBudgetData,
};

/** Rows must have this shape — matches WorkbenchRow from WorkbenchTable */
interface PowerRow {
  id: number;
  product_type: string;
  manufacturer: string;
  model: string;
  jacks: Jack[];
  detail: Record<string, unknown>;
}

export function getPowerInputJack(row: PowerRow): Jack | undefined {
  return row.jacks.find(j => j.category === 'power' && j.direction === 'input');
}

export function getPowerOutputJacks(row: PowerRow): Jack[] {
  return row.jacks.filter(j => j.category === 'power' && j.direction === 'output');
}

export function formatMa(ma: number): string {
  return `${ma.toLocaleString()}mA`;
}

/** Find the majority polarity among supply output jacks (normalized) */
export function getMajorityPolarity(jacks: Jack[]): string | null {
  const counts: Record<string, number> = {};
  for (const j of jacks) {
    if (j.polarity) {
      const norm = normalizePolarity(j.polarity);
      counts[norm] = (counts[norm] || 0) + 1;
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

/** Find the majority connector type among supply output jacks (normalized) */
export function getMajorityConnector(jacks: Jack[]): string | null {
  const counts: Record<string, number> = {};
  for (const j of jacks) {
    if (j.connector_type) {
      const norm = normalizeConnector(j.connector_type);
      counts[norm] = (counts[norm] || 0) + 1;
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

/**
 * When the supply has fewer outputs than pedals, identify groups of
 * electrically compatible pedals that could share an output via daisy-chain.
 */
export function computeDaisyChainGroups(
  consumers: PowerConsumer[],
  outputJacks: Jack[],
): DaisyChainGroup[] {
  const eligible = consumers.filter(
    c => c.current_ma != null && c.voltage != null && c.polarity != null && c.connector_type != null,
  );

  const groupMap = new Map<string, PowerConsumer[]>();
  for (const c of eligible) {
    const key = `${c.voltage}|${c.polarity}|${c.connector_type}`;
    const arr = groupMap.get(key);
    if (arr) arr.push(c);
    else groupMap.set(key, [c]);
  }

  const groups: DaisyChainGroup[] = [];
  for (const [key, members] of Array.from(groupMap)) {
    if (members.length < 2) continue;
    const [voltage, polarity, connector_type] = key.split('|');
    const combinedMa = members.reduce((sum: number, c: PowerConsumer) => sum + (c.current_ma as number), 0);

    const matchingOutputs = outputJacks.filter(j => j.voltage != null && voltagesCompatible(j.voltage, voltage));
    const maxOutputMa = matchingOutputs.length > 0
      ? Math.max(...matchingOutputs.map(j => j.current_ma ?? 0))
      : null;

    if (maxOutputMa != null && combinedMa <= maxOutputMa) {
      groups.push({ voltage, polarity, connector_type, consumers: members, combined_ma: combinedMa, max_output_ma: maxOutputMa });
    }
  }

  return groups;
}

/**
 * Greedy assignment: sort consumers by highest current draw (most constrained first),
 * then assign each to the best compatible output jack.
 */
export function assignPedalsToOutputs(
  consumers: PowerConsumer[],
  supplies: PowerSupplyInfo[],
): AssignmentResult {
  const availableJacks: TaggedOutputJack[] = [];
  for (const supply of supplies) {
    supply.output_jacks.forEach((jack, idx) => {
      availableJacks.push({
        ...jack,
        supplyName: `${supply.manufacturer} ${supply.model}`,
        supplyProductId: supply.productId,
        portIndex: idx + 1,
      });
    });
  }

  const sorted = [...consumers].sort((a, b) => (b.current_ma ?? 0) - (a.current_ma ?? 0));

  const assigned = new Set<number>();
  const assignments: PortAssignment[] = [];
  const unassigned: PowerConsumer[] = [];

  for (const consumer of sorted) {
    type Candidate = { jack: TaggedOutputJack; score: number; notes: string[] };
    const candidates: Candidate[] = [];

    for (const jack of availableJacks) {
      if (assigned.has(jack.id)) continue;

      if (consumer.voltage != null && jack.voltage != null) {
        if (!voltagesCompatible(jack.voltage, consumer.voltage)) continue;
      }

      if (consumer.current_ma != null && jack.current_ma != null) {
        if (jack.current_ma < consumer.current_ma) continue;
      }

      let score = 0;
      const notes: string[] = [];

      if (jack.is_isolated) score += 100;

      if (consumer.voltage != null && jack.voltage != null) {
        if (voltagesCompatible(jack.voltage, consumer.voltage)) score += 50;
      }

      if (consumer.polarity != null && jack.polarity != null) {
        if (normalizePolarity(consumer.polarity) === normalizePolarity(jack.polarity)) {
          score += 30;
        } else {
          notes.push(`Needs polarity adapter (${consumer.polarity} pedal, ${jack.polarity} output)`);
        }
      }

      if (consumer.connector_type != null && jack.connector_type != null) {
        if (normalizeConnector(consumer.connector_type) === normalizeConnector(jack.connector_type)) {
          score += 20;
        } else {
          notes.push(`Needs connector adapter (${consumer.connector_type} pedal, ${jack.connector_type} output)`);
        }
      }

      if (consumer.current_ma != null && jack.current_ma != null) {
        const headroom = jack.current_ma - consumer.current_ma;
        score += Math.max(0, 10 - Math.floor(headroom / 100));
      }

      candidates.push({ jack, score, notes });
    }

    if (candidates.length > 0) {
      candidates.sort((a, b) => b.score - a.score);
      const best = candidates[0];
      assigned.add(best.jack.id);
      assignments.push({ consumer, jack: best.jack, notes: best.notes });
    } else {
      unassigned.push(consumer);
    }
  }

  return { assignments, unassigned };
}

/** Build the "See all compatible power supplies" link URL */
export function buildSupplyLinkUrl(
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

/**
 * Extract and compute all power budget data from workbench rows.
 * Pure function — no React dependencies.
 */
export function extractPowerData(rows: PowerRow[]): PowerBudgetData {
  const consumers: PowerConsumer[] = [];
  const supplies: PowerSupplyInfo[] = [];

  for (const row of rows) {
    if (row.product_type === 'power_supply') {
      supplies.push({
        productId: row.id,
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
          productId: row.id,
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

  const knownConsumers = consumers.filter(c => c.current_ma != null);
  const unknownConsumers = consumers.filter(c => c.current_ma == null);
  const totalDraw = knownConsumers.reduce((sum, c) => sum + (c.current_ma as number), 0);
  const highestDraw = knownConsumers.length > 0
    ? knownConsumers.reduce((max, c) => (c.current_ma as number) > (max.current_ma as number) ? c : max)
    : null;

  const uniqueVoltages = Array.from(
    new Set(consumers.map(c => c.voltage).filter((v): v is string => v != null))
  ).sort();

  const totalCapacity = supplies.reduce((sum, s) => sum + (s.total_current_ma ?? 0), 0);
  const hasSupply = supplies.length > 0;

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

  const totalOutputCount = supplies.reduce((sum, s) => sum + (s.total_output_count ?? 0), 0);
  const allOutputJacks = supplies.flatMap(s => s.output_jacks);

  return {
    consumers,
    supplies,
    knownConsumers,
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
  };
}
