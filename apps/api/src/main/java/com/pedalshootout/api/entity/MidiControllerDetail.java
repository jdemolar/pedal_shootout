package com.pedalshootout.api.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "midi_controller_details")
public class MidiControllerDetail {

    @Id
    @Column(name = "product_id")
    private Integer productId;

    @OneToOne(fetch = FetchType.LAZY)
    @MapsId
    @JoinColumn(name = "product_id")
    private Product product;

    @Column(name = "footswitch_count")
    private Integer footswitchCount;

    @Column(name = "footswitch_type")
    private String footswitchType;

    @Column(name = "has_led_indicators")
    private Boolean hasLedIndicators;

    @Column(name = "led_color_options")
    private String ledColorOptions;

    @Column(name = "bank_count")
    private Integer bankCount;

    @Column(name = "presets_per_bank")
    private Integer presetsPerBank;

    @Column(name = "total_preset_slots")
    private Integer totalPresetSlots;

    @Column(name = "has_display")
    private Boolean hasDisplay;

    @Column(name = "display_type")
    private String displayType;

    @Column(name = "display_size")
    private String displaySize;

    @Column(name = "expression_input_count")
    private Integer expressionInputCount;

    @Column(name = "midi_channels")
    private Integer midiChannels;

    @Column(name = "supports_midi_clock")
    private Boolean supportsMidiClock;

    @Column(name = "supports_sysex")
    private Boolean supportsSysex;

    @Column(name = "software_editor_available")
    private Boolean softwareEditorAvailable;

    @Column(name = "software_platforms")
    private String softwarePlatforms;

    @Column(name = "on_device_programming")
    private Boolean onDeviceProgramming;

    @Column(name = "is_firmware_updatable")
    private Boolean isFirmwareUpdatable;

    @Column(name = "config_format")
    private String configFormat;

    @Column(name = "config_format_documented")
    private Boolean configFormatDocumented;

    @Column(name = "has_tuner")
    private Boolean hasTuner;

    @Column(name = "has_tap_tempo")
    private Boolean hasTapTempo;

    @Column(name = "has_setlist_mode")
    private Boolean hasSetlistMode;

    @Column(name = "has_per_switch_displays")
    private Boolean hasPerSwitchDisplays;

    @Column(name = "aux_switch_input_count")
    private Integer auxSwitchInputCount;

    @Column(name = "has_usb_host")
    private Boolean hasUsbHost;

    @Column(name = "has_bluetooth_midi")
    private Boolean hasBluetoothMidi;

    @Column(name = "audio_loop_count")
    private Integer audioLoopCount;

    @Column(name = "has_reorderable_loops")
    private Boolean hasReorderableLoops;

    @Column(name = "loop_bypass_type")
    private String loopBypassType;

    @Column(name = "has_parallel_routing")
    private Boolean hasParallelRouting;

    @Column(name = "has_gapless_switching")
    private Boolean hasGaplessSwitching;

    @Column(name = "has_spillover")
    private Boolean hasSpillover;

    public MidiControllerDetail() {}

    public Integer getProductId() { return productId; }
    public Product getProduct() { return product; }
    public Integer getFootswitchCount() { return footswitchCount; }
    public String getFootswitchType() { return footswitchType; }
    public Boolean getHasLedIndicators() { return hasLedIndicators; }
    public String getLedColorOptions() { return ledColorOptions; }
    public Integer getBankCount() { return bankCount; }
    public Integer getPresetsPerBank() { return presetsPerBank; }
    public Integer getTotalPresetSlots() { return totalPresetSlots; }
    public Boolean getHasDisplay() { return hasDisplay; }
    public String getDisplayType() { return displayType; }
    public String getDisplaySize() { return displaySize; }
    public Integer getExpressionInputCount() { return expressionInputCount; }
    public Integer getMidiChannels() { return midiChannels; }
    public Boolean getSupportsMidiClock() { return supportsMidiClock; }
    public Boolean getSupportsSysex() { return supportsSysex; }
    public Boolean getSoftwareEditorAvailable() { return softwareEditorAvailable; }
    public String getSoftwarePlatforms() { return softwarePlatforms; }
    public Boolean getOnDeviceProgramming() { return onDeviceProgramming; }
    public Boolean getIsFirmwareUpdatable() { return isFirmwareUpdatable; }
    public String getConfigFormat() { return configFormat; }
    public Boolean getConfigFormatDocumented() { return configFormatDocumented; }
    public Boolean getHasTuner() { return hasTuner; }
    public Boolean getHasTapTempo() { return hasTapTempo; }
    public Boolean getHasSetlistMode() { return hasSetlistMode; }
    public Boolean getHasPerSwitchDisplays() { return hasPerSwitchDisplays; }
    public Integer getAuxSwitchInputCount() { return auxSwitchInputCount; }
    public Boolean getHasUsbHost() { return hasUsbHost; }
    public Boolean getHasBluetoothMidi() { return hasBluetoothMidi; }
    public Integer getAudioLoopCount() { return audioLoopCount; }
    public Boolean getHasReorderableLoops() { return hasReorderableLoops; }
    public String getLoopBypassType() { return loopBypassType; }
    public Boolean getHasParallelRouting() { return hasParallelRouting; }
    public Boolean getHasGaplessSwitching() { return hasGaplessSwitching; }
    public Boolean getHasSpillover() { return hasSpillover; }
}
