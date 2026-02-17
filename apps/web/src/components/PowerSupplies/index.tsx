import { ReactNode, useMemo } from 'react';
import { useSearchParams } from 'react-router-dom';
import DataTable, { ColumnDef, FilterConfig } from '../DataTable';
import { formatMsrp, formatDimensions } from '../../utils/formatters';
import { useApiData } from '../../hooks/useApiData';
import { api } from '../../services/api';
import { transformPowerSupply, Jack } from '../../utils/transformers';
import JacksList from '../JacksList';
import WorkbenchToggle from '../WorkbenchToggle';

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
  jacks: Jack[];
}

/** Parse a numeric URL param, returning null if absent or not a valid number */
function parseIntParam(value: string | null): number | null {
  if (value == null) return null;
  const n = parseInt(value, 10);
  return isNaN(n) ? null : n;
}

/** Check whether a supply offers a given voltage (checks available_voltages string and output jacks) */
function supplyHasVoltage(ps: PowerSupply, voltage: string): boolean {
  // Check the available_voltages summary field (e.g., "9V, 12V, 18V")
  if (ps.available_voltages != null) {
    // Split on comma/space and compare trimmed values
    const listed = ps.available_voltages.split(/[,;]\s*/).map(v => v.trim());
    if (listed.some(v => v === voltage)) return true;
  }
  // Also check individual output jacks
  return ps.jacks.some(
    j => j.category === 'power' && j.direction === 'output' && j.voltage === voltage
  );
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
    <JacksList jacks={ps.jacks} />
  </>
);

const stats = (data: PowerSupply[]) => {
  const inProd = data.filter(ps => ps.in_production).length;
  const totalOutputs = data.reduce((sum, ps) => sum + ps.total_output_count, 0);
  return `${data.length} power supplies \u00b7 ${inProd} in production \u00b7 ${totalOutputs} total outputs`;
};

const PowerSupplies = () => {
  const { data, loading, error } = useApiData(api.getPowerSupplies, transformPowerSupply);
  const [searchParams, setSearchParams] = useSearchParams();

  // Parse all URL param filters
  const minCurrentMa = parseIntParam(searchParams.get('minCurrent'));
  const minOutputs = parseIntParam(searchParams.get('minOutputs'));
  const minOutputCurrent = parseIntParam(searchParams.get('minOutputCurrent'));
  const voltagesParam = searchParams.get('voltages');
  const requiredVoltages = voltagesParam
    ? voltagesParam.split(',').map(v => v.trim()).filter(v => v.length > 0)
    : [];

  const hasAnyUrlFilter = minCurrentMa != null || minOutputs != null
    || minOutputCurrent != null || requiredVoltages.length > 0;

  // Apply URL param filters to the dataset
  const filteredData = useMemo(() => {
    if (!hasAnyUrlFilter) return data;

    return data.filter(ps => {
      // minCurrent: total capacity must meet threshold
      if (minCurrentMa != null && (ps.total_current_ma == null || ps.total_current_ma < minCurrentMa)) {
        return false;
      }
      // minOutputs: must have at least this many outputs
      if (minOutputs != null && ps.total_output_count < minOutputs) {
        return false;
      }
      // minOutputCurrent: at least one output jack must provide this many mA
      if (minOutputCurrent != null) {
        const outputJacks = ps.jacks.filter(j => j.category === 'power' && j.direction === 'output');
        const hasCapableOutput = outputJacks.some(j => j.current_ma != null && j.current_ma >= minOutputCurrent);
        if (!hasCapableOutput) return false;
      }
      // voltages: supply must offer ALL required voltages
      if (requiredVoltages.length > 0) {
        for (const voltage of requiredVoltages) {
          if (!supplyHasVoltage(ps, voltage)) return false;
        }
      }
      return true;
    });
  }, [data, hasAnyUrlFilter, minCurrentMa, minOutputs, minOutputCurrent, requiredVoltages]);

  const supplyTypes = useMemo(
    () => ['All', ...Array.from(new Set(filteredData.map(d => d.supply_type).filter((t): t is string => t !== null))).sort()],
    [filteredData]
  );

  const mountingTypes = useMemo(
    () => ['All', ...Array.from(new Set(filteredData.map(d => d.mounting_type).filter((t): t is string => t !== null))).sort()],
    [filteredData]
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

  const handleClearUrlFilters = () => {
    const next = new URLSearchParams(searchParams);
    next.delete('minCurrent');
    next.delete('minOutputs');
    next.delete('minOutputCurrent');
    next.delete('voltages');
    setSearchParams(next);
  };

  // Build banner text describing all active URL filters
  const bannerParts: string[] = [];
  if (minCurrentMa != null) bannerParts.push(`${minCurrentMa.toLocaleString()}mA+ capacity`);
  if (minOutputs != null) bannerParts.push(`${minOutputs}+ outputs`);
  if (minOutputCurrent != null) bannerParts.push(`${minOutputCurrent}mA+ per output`);
  if (requiredVoltages.length > 0) bannerParts.push(requiredVoltages.join(' + '));

  return (
    <>
      {hasAnyUrlFilter && (
        <div className="data-table__context-banner">
          Showing power supplies with {bannerParts.join(', ')}
          <button className="data-table__context-banner-clear" onClick={handleClearUrlFilters}>
            Clear
          </button>
        </div>
      )}
      <DataTable<PowerSupply>
        title="Power Supply Database"
        entityName="power supply"
        entityNamePlural="power supplies"
        stats={stats}
        data={filteredData}
        columns={columns}
        filters={filters}
        searchFields={['manufacturer', 'model']}
        searchPlaceholder="Search power supplies..."
        renderExpandedRow={renderExpandedRow}
        renderRowAction={ps => <WorkbenchToggle productId={ps.id} productType="power_supply" />}
        defaultSortKey={hasAnyUrlFilter ? 'total_current_ma' : 'manufacturer'}
        defaultSortDir={hasAnyUrlFilter ? -1 : 1}
        loading={loading}
        error={error}
      />
    </>
  );
};

export default PowerSupplies;
