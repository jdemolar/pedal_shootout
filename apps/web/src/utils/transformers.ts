import {
  PedalApiResponse,
  ManufacturerApiResponse,
  MidiControllerApiResponse,
  PedalboardApiResponse,
  UtilityApiResponse,
  JackApiResponse,
} from '../types/api';

function extractPowerVoltage(jacks: JackApiResponse[]): string | null {
  const powerJack = jacks.find(j => j.category === 'power' && j.direction === 'input');
  return powerJack?.voltage ?? null;
}

function extractPowerCurrentMa(jacks: JackApiResponse[]): number | null {
  const powerJack = jacks.find(j => j.category === 'power' && j.direction === 'input');
  return powerJack?.currentMa ?? null;
}

export function transformPedal(dto: PedalApiResponse) {
  return {
    id: dto.id,
    manufacturer: dto.manufacturerName,
    model: dto.model,
    effect_type: dto.pedalDetails?.effectType ?? null,
    in_production: dto.inProduction,
    width_mm: dto.widthMm,
    depth_mm: dto.depthMm,
    height_mm: dto.heightMm,
    weight_grams: dto.weightGrams,
    msrp_cents: dto.msrpCents,
    product_page: dto.productPage,
    instruction_manual: dto.instructionManual,
    image_path: dto.imagePath,
    color_options: dto.colorOptions,
    data_reliability: dto.dataReliability as 'High' | 'Medium' | 'Low' | null,
    bypass_type: dto.pedalDetails?.bypassType ?? null,
    signal_type: dto.pedalDetails?.signalType ?? null,
    circuit_type: dto.pedalDetails?.circuitType ?? null,
    mono_stereo: dto.pedalDetails?.monoStereo ?? null,
    preset_count: dto.pedalDetails?.presetCount ?? 0,
    midi_capable: dto.pedalDetails?.midiCapable ?? false,
    has_tap_tempo: dto.pedalDetails?.hasTapTempo ?? false,
    battery_capable: dto.pedalDetails?.batteryCapable ?? false,
    has_software_editor: dto.pedalDetails?.hasSoftwareEditor ?? false,
    power_voltage: extractPowerVoltage(dto.jacks),
    power_current_ma: extractPowerCurrentMa(dto.jacks),
  };
}

export function transformManufacturer(dto: ManufacturerApiResponse) {
  return {
    id: dto.id,
    name: dto.name,
    country: dto.country,
    founded: dto.founded,
    status: dto.status as 'Active' | 'Defunct' | 'Discontinued' | 'Unknown',
    specialty: dto.specialty,
    website: dto.website,
    notes: null as string | null,
    updated_at: null as string | null,
    product_count: dto.productCount,
  };
}

export function transformMidiController(dto: MidiControllerApiResponse) {
  return {
    id: dto.id,
    manufacturer: dto.manufacturerName,
    model: dto.model,
    in_production: dto.inProduction,
    width_mm: dto.widthMm,
    depth_mm: dto.depthMm,
    height_mm: dto.heightMm,
    weight_grams: dto.weightGrams,
    msrp_cents: dto.msrpCents,
    product_page: dto.productPage,
    instruction_manual: dto.instructionManual,
    data_reliability: dto.dataReliability as 'High' | 'Medium' | 'Low' | null,
    footswitch_count: dto.footswitchCount,
    total_preset_slots: dto.totalPresetSlots,
    audio_loop_count: dto.audioLoopCount,
    expression_input_count: dto.expressionInputCount,
    aux_switch_input_count: dto.auxSwitchInputCount,
    has_display: dto.hasDisplay,
    display_type: dto.displayType,
    has_per_switch_displays: dto.hasPerSwitchDisplays,
    has_tuner: dto.hasTuner,
    has_tap_tempo: dto.hasTapTempo,
    has_setlist_mode: dto.hasSetlistMode,
    has_bluetooth_midi: dto.hasBluetoothMidi,
    software_editor_available: dto.softwareEditorAvailable,
    software_platforms: dto.softwarePlatforms,
    power_voltage: extractPowerVoltage(dto.jacks),
    power_current_ma: extractPowerCurrentMa(dto.jacks),
  };
}

export function transformPedalboard(dto: PedalboardApiResponse) {
  return {
    id: dto.id,
    manufacturer: dto.manufacturerName,
    model: dto.model,
    in_production: dto.inProduction,
    width_mm: dto.widthMm,
    depth_mm: dto.depthMm,
    height_mm: dto.heightMm,
    weight_grams: dto.weightGrams,
    msrp_cents: dto.msrpCents,
    product_page: dto.productPage,
    instruction_manual: dto.instructionManual,
    data_reliability: dto.dataReliability as 'High' | 'Medium' | 'Low' | null,
    usable_width_mm: dto.usableWidthMm,
    usable_depth_mm: dto.usableDepthMm,
    surface_type: dto.surfaceType,
    material: dto.material,
    has_second_tier: dto.hasSecondTier,
    has_integrated_power: dto.hasIntegratedPower,
    has_integrated_patch_bay: dto.hasIntegratedPatchBay,
    case_included: dto.caseIncluded,
  };
}

export function transformUtility(dto: UtilityApiResponse) {
  return {
    id: dto.id,
    manufacturer: dto.manufacturerName,
    model: dto.model,
    in_production: dto.inProduction,
    width_mm: dto.widthMm,
    depth_mm: dto.depthMm,
    height_mm: dto.heightMm,
    weight_grams: dto.weightGrams,
    msrp_cents: dto.msrpCents,
    product_page: dto.productPage,
    instruction_manual: dto.instructionManual,
    data_reliability: dto.dataReliability as 'High' | 'Medium' | 'Low' | null,
    utility_type: dto.utilityType,
    is_active: dto.isActive,
    signal_type: dto.signalType,
    bypass_type: dto.bypassType,
    has_ground_lift: dto.hasGroundLift,
  };
}
