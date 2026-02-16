import { useEffect, useRef } from 'react';
import { WorkbenchRow } from './WorkbenchTable';
import JacksList from '../JacksList';

interface DetailPanelProps {
  row: WorkbenchRow;
  onClose: () => void;
}

const TYPE_TITLES: Record<string, string> = {
  pedal: 'Pedal',
  power_supply: 'Power Supply',
  pedalboard: 'Pedalboard',
  midi_controller: 'MIDI Controller',
  utility: 'Utility',
};

function BoolField({ label, value }: { label: string; value: boolean }) {
  return (
    <div className="detail-panel__field">
      <span className="detail-panel__label">{label}</span>
      <span className={value ? 'bool-yes' : 'bool-no'}>{value ? 'Yes' : 'No'}</span>
    </div>
  );
}

function TextField({ label, value, highlight }: { label: string; value: string | number; highlight?: boolean }) {
  return (
    <div className="detail-panel__field">
      <span className="detail-panel__label">{label}</span>
      <span className={highlight ? 'detail-panel__value--highlight' : ''}>{value}</span>
    </div>
  );
}

function LinkField({ label, url }: { label: string; url: string }) {
  return (
    <div className="detail-panel__field">
      <span className="detail-panel__label">{label}</span>
      <a href={url} target="_blank" rel="noopener noreferrer" className="detail-panel__link">{url}</a>
    </div>
  );
}

function PedalDetails({ d }: { d: Record<string, unknown> }) {
  return (
    <>
      {d.effect_type != null && <TextField label="Effect Type" value={d.effect_type as string} />}
      {d.bypass_type != null && <TextField label="Bypass" value={d.bypass_type as string} />}
      {d.signal_type != null && <TextField label="Signal" value={d.signal_type as string} />}
      {d.circuit_type != null && <TextField label="Circuit" value={d.circuit_type as string} />}
      {d.mono_stereo != null && <TextField label="Mono/Stereo" value={d.mono_stereo as string} />}
      {d.color_options != null && <TextField label="Colors" value={d.color_options as string} />}
      <BoolField label="MIDI" value={d.midi_capable as boolean} />
      <TextField label="Presets" value={d.preset_count as number} highlight={(d.preset_count as number) > 0} />
      <BoolField label="Tap Tempo" value={d.has_tap_tempo as boolean} />
      <BoolField label="Battery" value={d.battery_capable as boolean} />
      <BoolField label="Software Editor" value={d.has_software_editor as boolean} />
      {d.product_page != null && <LinkField label="Product Page" url={d.product_page as string} />}
      {d.instruction_manual != null && <LinkField label="Manual" url={d.instruction_manual as string} />}
    </>
  );
}

function PowerSupplyDetails({ d }: { d: Record<string, unknown> }) {
  return (
    <>
      {d.supply_type != null && <TextField label="Type" value={d.supply_type as string} />}
      {d.topology != null && <TextField label="Topology" value={d.topology as string} />}
      {d.input_voltage_range != null && <TextField label="Input Voltage" value={d.input_voltage_range as string} />}
      {d.input_frequency != null && <TextField label="Input Frequency" value={d.input_frequency as string} />}
      <TextField label="Isolated Outputs" value={d.isolated_output_count as number} highlight={(d.isolated_output_count as number) > 0} />
      {d.available_voltages != null && <TextField label="Available Voltages" value={d.available_voltages as string} />}
      <BoolField label="Variable Voltage" value={d.has_variable_voltage as boolean} />
      {d.voltage_range != null && <TextField label="Voltage Range" value={d.voltage_range as string} />}
      {d.mounting_type != null && <TextField label="Mounting" value={d.mounting_type as string} />}
      <BoolField label="Bracket Included" value={d.bracket_included as boolean} />
      <BoolField label="Expandable" value={d.is_expandable as boolean} />
      {d.expansion_port_type != null && <TextField label="Expansion Port" value={d.expansion_port_type as string} />}
      <BoolField label="Battery Powered" value={d.is_battery_powered as boolean} />
      {d.battery_capacity_wh != null && <TextField label="Battery Capacity" value={`${d.battery_capacity_wh} Wh`} highlight />}
      {d.product_page != null && <LinkField label="Product Page" url={d.product_page as string} />}
      {d.instruction_manual != null && <LinkField label="Manual" url={d.instruction_manual as string} />}
    </>
  );
}

function MidiControllerDetails({ d }: { d: Record<string, unknown> }) {
  return (
    <>
      <TextField label="Footswitches" value={d.footswitch_count as number} />
      {d.total_preset_slots != null && <TextField label="Preset Slots" value={d.total_preset_slots as number} />}
      {d.audio_loop_count != null && <TextField label="Audio Loops" value={d.audio_loop_count as number} />}
      <TextField label="Expression Inputs" value={d.expression_input_count as number} highlight={(d.expression_input_count as number) > 0} />
      <TextField label="Aux Switch Inputs" value={d.aux_switch_input_count as number} />
      {d.display_type != null && <TextField label="Display" value={d.display_type as string} />}
      <BoolField label="Per-Switch Displays" value={d.has_per_switch_displays as boolean} />
      <BoolField label="Tuner" value={d.has_tuner as boolean} />
      <BoolField label="Tap Tempo" value={d.has_tap_tempo as boolean} />
      <BoolField label="Setlist Mode" value={d.has_setlist_mode as boolean} />
      <BoolField label="Bluetooth MIDI" value={d.has_bluetooth_midi as boolean} />
      <BoolField label="Software Editor" value={d.software_editor_available as boolean} />
      {d.software_platforms != null && <TextField label="Platforms" value={d.software_platforms as string} />}
      {d.product_page != null && <LinkField label="Product Page" url={d.product_page as string} />}
      {d.instruction_manual != null && <LinkField label="Manual" url={d.instruction_manual as string} />}
    </>
  );
}

function PedalboardDetails({ d }: { d: Record<string, unknown> }) {
  return (
    <>
      {d.usable_width_mm != null && d.usable_depth_mm != null && (
        <TextField label="Usable Area" value={`${d.usable_width_mm} × ${d.usable_depth_mm} mm`} />
      )}
      {d.surface_type != null && <TextField label="Surface" value={d.surface_type as string} />}
      {d.material != null && <TextField label="Material" value={d.material as string} />}
      <BoolField label="Second Tier" value={d.has_second_tier as boolean} />
      <BoolField label="Integrated Power" value={d.has_integrated_power as boolean} />
      <BoolField label="Integrated Patch Bay" value={d.has_integrated_patch_bay as boolean} />
      <BoolField label="Case Included" value={d.case_included as boolean} />
      {d.product_page != null && <LinkField label="Product Page" url={d.product_page as string} />}
      {d.instruction_manual != null && <LinkField label="Manual" url={d.instruction_manual as string} />}
    </>
  );
}

function UtilityDetails({ d }: { d: Record<string, unknown> }) {
  return (
    <>
      {d.utility_type != null && <TextField label="Type" value={d.utility_type as string} />}
      {d.signal_type != null && <TextField label="Signal" value={d.signal_type as string} />}
      {d.bypass_type != null && <TextField label="Bypass" value={d.bypass_type as string} />}
      <BoolField label="Ground Lift" value={d.has_ground_lift as boolean} />
      {d.product_page != null && <LinkField label="Product Page" url={d.product_page as string} />}
      {d.instruction_manual != null && <LinkField label="Manual" url={d.instruction_manual as string} />}
    </>
  );
}

function TypeSpecificDetails({ row }: { row: WorkbenchRow }) {
  const d = row.detail;
  switch (row.product_type) {
    case 'pedal': return <PedalDetails d={d} />;
    case 'power_supply': return <PowerSupplyDetails d={d} />;
    case 'midi_controller': return <MidiControllerDetails d={d} />;
    case 'pedalboard': return <PedalboardDetails d={d} />;
    case 'utility': return <UtilityDetails d={d} />;
  }
}

const DetailPanel = ({ row, onClose }: DetailPanelProps) => {
  const panelRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === 'Escape') onClose();
    };
    document.addEventListener('keydown', handleKeyDown);
    return () => document.removeEventListener('keydown', handleKeyDown);
  }, [onClose]);

  useEffect(() => {
    const handleClickOutside = (e: MouseEvent) => {
      if (panelRef.current && !panelRef.current.contains(e.target as Node)) {
        onClose();
      }
    };
    // Delay adding the listener so the row click that opened the panel doesn't immediately close it
    const timer = setTimeout(() => {
      document.addEventListener('mousedown', handleClickOutside);
    }, 0);
    return () => {
      clearTimeout(timer);
      document.removeEventListener('mousedown', handleClickOutside);
    };
  }, [onClose]);

  return (
    <div className="detail-panel" ref={panelRef}>
      <div className="detail-panel__header">
        <div className="detail-panel__header-text">
          <span className={`type-badge type-badge--${row.product_type}`}>
            {TYPE_TITLES[row.product_type]}
          </span>
          <h2 className="detail-panel__title">{row.manufacturer}</h2>
          <h3 className="detail-panel__subtitle">{row.model}</h3>
        </div>
        <button className="detail-panel__close" onClick={onClose} title="Close" aria-label="Close detail panel">
          {'\u00d7'}
        </button>
      </div>

      <div className="detail-panel__body">
        <div className="detail-panel__section">
          <TypeSpecificDetails row={row} />
        </div>

        {row.jacks.length > 0 && (
          <div className="detail-panel__section">
            <h4 className="detail-panel__section-title">Connections</h4>
            <JacksList jacks={row.jacks} />
          </div>
        )}
      </div>
    </div>
  );
};

export default DetailPanel;
