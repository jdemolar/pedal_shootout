import { ReactNode, useMemo } from 'react';
import DataTable, { ColumnDef, FilterConfig } from '../DataTable';
import { formatMsrp, formatDimensions } from '../../utils/formatters';
import { useApiData } from '../../hooks/useApiData';
import { api } from '../../services/api';
import { transformPowerSupply } from '../../utils/transformers';

interface PowerSupply {
  id: number;
  manufacturer: string;
  model: string;
  in_production: boolean;
  width_mm: number | null;
  depth_mm: number | null;
  height_mm: number | null;
  weight_grams: number | null;
  msrp_cents: number | null;
  product_page: string | null;
  instruction_manual: string | null;
  data_reliability: 'High' | 'Medium' | 'Low' | null;
  // Power supply-specific
  supply_type: string | null;
  topology: string | null;
  input_voltage_range: string | null;
  input_frequency: string | null;
  total_output_count: number;
  total_current_ma: number | null;
  isolated_output_count: number;
  available_voltages: string | null;
  has_variable_voltage: boolean;
  voltage_range: string | null;
  mounting_type: string | null;
  bracket_included: boolean;
  is_expandable: boolean;
  expansion_port_type: string | null;
  is_battery_powered: boolean;
  battery_capacity_wh: number | null;
}

const columns: ColumnDef<PowerSupply>[] = [
  { label: 'Manufacturer', width: 180, sortKey: 'manufacturer',
    render: ps => <span style={{ color: '#f0f0f0', fontSize: '12.5px', fontWeight: 600, fontFamily: "'Helvetica Neue', sans-serif" }}>{ps.manufacturer}</span> },
  { label: 'Model', width: 200, sortKey: 'model',
    render: ps => <span style={{ color: '#d0d0d0' }}>{ps.model}</span> },
  { label: 'Type', width: 120, align: 'center', sortKey: 'supply_type',
    render: ps => ps.supply_type
      ? <>{ps.supply_type}</>
      : <span className="null-value">{'\u2014'}</span> },
  { label: 'Outputs', width: 70, align: 'center', sortKey: 'total_output_count',
    render: ps => <>{ps.total_output_count}</> },
  { label: 'Current', width: 90, align: 'right', sortKey: 'total_current_ma',
    render: ps => ps.total_current_ma != null
      ? <>{ps.total_current_ma}mA</>
      : <span className="null-value">{'\u2014'}</span> },
  { label: 'Mounting', width: 110, align: 'center', sortKey: 'mounting_type',
    render: ps => ps.mounting_type
      ? <>{ps.mounting_type}</>
      : <span className="null-value">{'\u2014'}</span> },
  { label: 'Status', width: 80, align: 'center', sortKey: 'in_production',
    render: ps => (
      <span className={`status-badge status-badge--${ps.in_production ? 'in-production' : 'discontinued'}`}>
        {ps.in_production ? 'Active' : 'Disc.'}
      </span>
    ) },
  { label: 'MSRP', width: 90, align: 'right', sortKey: 'msrp_cents',
    render: ps => ps.msrp_cents != null
      ? <>{formatMsrp(ps.msrp_cents)}</>
      : <span className="null-value">{'\u2014'}</span> },
  { label: 'Dimensions', width: 150, align: 'center',
    render: ps => ps.width_mm != null && ps.depth_mm != null && ps.height_mm != null
      ? <>{formatDimensions(ps.width_mm, ps.depth_mm, ps.height_mm)}</>
      : <span className="null-value">{'\u2014'}</span> },
  { label: 'Reliability', width: 80, align: 'center', sortKey: 'data_reliability',
    render: ps => ps.data_reliability
      ? <span className={`reliability-badge reliability-badge--${ps.data_reliability.toLowerCase()}`}>{ps.data_reliability}</span>
      : <span className="null-value">{'\u2014'}</span> },
];

const renderExpandedRow = (ps: PowerSupply): ReactNode => (
  <>
    {ps.topology != null && (
      <div className="data-table__detail">
        <div className="data-table__detail-label">Topology</div>
        <div className="data-table__detail-value">{ps.topology}</div>
      </div>
    )}
    {ps.input_voltage_range != null && (
      <div className="data-table__detail">
        <div className="data-table__detail-label">Input Voltage Range</div>
        <div className="data-table__detail-value">{ps.input_voltage_range}</div>
      </div>
    )}
    {ps.input_frequency != null && (
      <div className="data-table__detail">
        <div className="data-table__detail-label">Input Frequency</div>
        <div className="data-table__detail-value">{ps.input_frequency}</div>
      </div>
    )}
    <div className="data-table__detail">
      <div className="data-table__detail-label">Isolated Outputs</div>
      <div className="data-table__detail-value data-table__detail-value--highlight">
        {ps.isolated_output_count}
      </div>
    </div>
    {ps.available_voltages != null && (
      <div className="data-table__detail">
        <div className="data-table__detail-label">Available Voltages</div>
        <div className="data-table__detail-value">{ps.available_voltages}</div>
      </div>
    )}
    <div className="data-table__detail">
      <div className="data-table__detail-label">Variable Voltage</div>
      <div className="data-table__detail-value">
        <span className={ps.has_variable_voltage ? 'bool-yes' : 'bool-no'}>{ps.has_variable_voltage ? 'Yes' : 'No'}</span>
      </div>
    </div>
    {ps.voltage_range != null && (
      <div className="data-table__detail">
        <div className="data-table__detail-label">Voltage Range</div>
        <div className="data-table__detail-value">{ps.voltage_range}</div>
      </div>
    )}
    <div className="data-table__detail">
      <div className="data-table__detail-label">Bracket Included</div>
      <div className="data-table__detail-value">
        <span className={ps.bracket_included ? 'bool-yes' : 'bool-no'}>{ps.bracket_included ? 'Yes' : 'No'}</span>
      </div>
    </div>
    <div className="data-table__detail">
      <div className="data-table__detail-label">Expandable</div>
      <div className="data-table__detail-value">
        <span className={ps.is_expandable ? 'bool-yes' : 'bool-no'}>{ps.is_expandable ? 'Yes' : 'No'}</span>
      </div>
    </div>
    {ps.expansion_port_type != null && (
      <div className="data-table__detail">
        <div className="data-table__detail-label">Expansion Port Type</div>
        <div className="data-table__detail-value">{ps.expansion_port_type}</div>
      </div>
    )}
    <div className="data-table__detail">
      <div className="data-table__detail-label">Battery Powered</div>
      <div className="data-table__detail-value">
        <span className={ps.is_battery_powered ? 'bool-yes' : 'bool-no'}>{ps.is_battery_powered ? 'Yes' : 'No'}</span>
      </div>
    </div>
    {ps.battery_capacity_wh != null && (
      <div className="data-table__detail">
        <div className="data-table__detail-label">Battery Capacity</div>
        <div className="data-table__detail-value data-table__detail-value--highlight">
          {ps.battery_capacity_wh} Wh
        </div>
      </div>
    )}
    {ps.weight_grams != null && (
      <div className="data-table__detail">
        <div className="data-table__detail-label">Weight</div>
        <div className="data-table__detail-value data-table__detail-value--highlight">
          {(ps.weight_grams / 1000).toFixed(2)} kg
        </div>
      </div>
    )}
    {ps.product_page != null && (
      <div className="data-table__detail">
        <div className="data-table__detail-label">Product Page</div>
        <div className="data-table__detail-value">
          <a href={ps.product_page} target="_blank" rel="noopener noreferrer" onClick={e => e.stopPropagation()} className="detail-link">
            {ps.product_page}
          </a>
        </div>
      </div>
    )}
    {ps.instruction_manual != null && (
      <div className="data-table__detail">
        <div className="data-table__detail-label">Instruction Manual</div>
        <div className="data-table__detail-value">
          <a href={ps.instruction_manual} target="_blank" rel="noopener noreferrer" onClick={e => e.stopPropagation()} className="detail-link">
            {ps.instruction_manual}
          </a>
        </div>
      </div>
    )}
  </>
);

const stats = (data: PowerSupply[]) => {
  const inProd = data.filter(ps => ps.in_production).length;
  const totalOutputs = data.reduce((sum, ps) => sum + ps.total_output_count, 0);
  return `${data.length} power supplies \u00b7 ${inProd} in production \u00b7 ${totalOutputs} total outputs`;
};

const PowerSupplies = () => {
  const { data, loading, error } = useApiData(api.getPowerSupplies, transformPowerSupply);

  const supplyTypes = useMemo(
    () => ['All', ...Array.from(new Set(data.map(d => d.supply_type).filter((t): t is string => t !== null))).sort()],
    [data]
  );

  const mountingTypes = useMemo(
    () => ['All', ...Array.from(new Set(data.map(d => d.mounting_type).filter((t): t is string => t !== null))).sort()],
    [data]
  );

  const filters: FilterConfig<PowerSupply>[] = useMemo(() => [
    { label: 'Type', options: supplyTypes,
      predicate: (ps, v) => ps.supply_type === v },
    { label: 'Mounting', options: mountingTypes,
      predicate: (ps, v) => ps.mounting_type === v },
    { label: 'Status', options: ['All', 'In Production', 'Discontinued'],
      predicate: (ps, v) => (v === 'In Production') === ps.in_production },
    { label: 'Reliability', options: ['All', 'High', 'Medium', 'Low'],
      predicate: (ps, v) => ps.data_reliability === v },
  ], [supplyTypes, mountingTypes]);

  return (
    <DataTable<PowerSupply>
      title="Power Supply Database"
      entityName="power supply"
      entityNamePlural="power supplies"
      stats={stats}
      data={data}
      columns={columns}
      filters={filters}
      searchFields={['manufacturer', 'model']}
      searchPlaceholder="Search power supplies..."
      renderExpandedRow={renderExpandedRow}
      defaultSortKey="manufacturer"
      loading={loading}
      error={error}
    />
  );
};

export default PowerSupplies;
