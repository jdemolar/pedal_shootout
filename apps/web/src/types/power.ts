/**
 * Shared type definitions for power budget calculations.
 * Used by PowerBudgetInsight (sidebar), PowerView (canvas), and powerAssignment utils.
 */

import { Jack } from '../utils/transformers';

export interface PowerConsumer {
  productId: number;
  instanceId: string;
  manufacturer: string;
  model: string;
  current_ma: number | null;
  voltage: string | null;
  polarity: string | null;
  connector_type: string | null;
}

export interface PowerSupplyInfo {
  productId: number;
  instanceId: string;
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

export interface TaggedOutputJack extends Jack {
  supplyName: string;
  supplyProductId: number;
  supplyInstanceId: string;
  portIndex: number;
}

export interface PortAssignment {
  consumer: PowerConsumer;
  jack: TaggedOutputJack;
  notes: string[];
}

export interface AssignmentResult {
  assignments: PortAssignment[];
  unassigned: PowerConsumer[];
}

export interface DaisyChainGroup {
  voltage: string;
  polarity: string;
  connector_type: string;
  consumers: PowerConsumer[];
  combined_ma: number;
  max_output_ma: number | null;
}

export type PowerBudgetStatus = 'no-supply' | 'insufficient' | 'sufficient';

export interface PowerBudgetData {
  consumers: PowerConsumer[];
  supplies: PowerSupplyInfo[];
  knownConsumers: PowerConsumer[];
  unknownConsumers: PowerConsumer[];
  totalDraw: number;
  highestDraw: PowerConsumer | null;
  totalCapacity: number;
  status: PowerBudgetStatus;
  headroom: number;
  headroomPct: number;
  uniqueVoltages: string[];
  totalOutputCount: number;
  allOutputJacks: Jack[];
}
