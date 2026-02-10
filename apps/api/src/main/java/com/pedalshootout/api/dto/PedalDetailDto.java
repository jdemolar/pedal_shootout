package com.pedalshootout.api.dto;

import com.pedalshootout.api.entity.PedalDetail;

/**
 * DTO for pedal-specific detail fields.
 * Nested inside PedalDto alongside the product summary and jacks.
 */
public record PedalDetailDto(
    String effectType,
    String circuitType,
    String circuitRoutingOptions,
    String signalType,
    String bypassType,
    String monoStereo,
    String audioMix,
    Boolean hasAnalogDryThrough,
    Boolean hasSpillover,
    Integer sampleRateKhz,
    Integer bitDepth,
    Double latencyMs,
    Integer presetCount,
    Boolean hasTapTempo,
    Boolean midiCapable,
    String midiReceiveCapabilities,
    String midiSendCapabilities,
    Boolean hasSoftwareEditor,
    String softwarePlatforms,
    Boolean isFirmwareUpdatable,
    Boolean hasUsbAudio,
    Boolean batteryCapable,
    Integer fxLoopCount,
    Boolean hasReorderableLoops
) {
    public static PedalDetailDto from(PedalDetail pd) {
        return new PedalDetailDto(
            pd.getEffectType(),
            pd.getCircuitType(),
            pd.getCircuitRoutingOptions(),
            pd.getSignalType(),
            pd.getBypassType(),
            pd.getMonoStereo(),
            pd.getAudioMix(),
            pd.getHasAnalogDryThrough(),
            pd.getHasSpillover(),
            pd.getSampleRateKhz(),
            pd.getBitDepth(),
            pd.getLatencyMs(),
            pd.getPresetCount(),
            pd.getHasTapTempo(),
            pd.getMidiCapable(),
            pd.getMidiReceiveCapabilities(),
            pd.getMidiSendCapabilities(),
            pd.getHasSoftwareEditor(),
            pd.getSoftwarePlatforms(),
            pd.getIsFirmwareUpdatable(),
            pd.getHasUsbAudio(),
            pd.getBatteryCapable(),
            pd.getFxLoopCount(),
            pd.getHasReorderableLoops()
        );
    }
}
