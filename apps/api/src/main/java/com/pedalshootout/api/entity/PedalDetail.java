package com.pedalshootout.api.entity;

import jakarta.persistence.*;

/**
 * JPA Entity for pedal_details — the pedal-specific extension of products.
 *
 * This uses a "shared primary key" pattern: the product_id column is BOTH the
 * primary key and a foreign key to products. This means there's a strict 1:1
 * relationship — one pedal_details row for each product that is a pedal.
 *
 * @OneToOne with @MapsId tells JPA: "my primary key IS the foreign key to Product."
 * This is the JPA way to express Class Table Inheritance without using JPA's
 * built-in inheritance strategies (which are more complex than we need).
 */
@Entity
@Table(name = "pedal_details")
public class PedalDetail {

    @Id
    @Column(name = "product_id")
    private Integer productId;

    @OneToOne(fetch = FetchType.LAZY)
    @MapsId
    @JoinColumn(name = "product_id")
    private Product product;

    // Classification
    @Column(name = "effect_type")
    private String effectType;

    @Column(name = "circuit_type")
    private String circuitType;

    @Column(name = "circuit_routing_options")
    private String circuitRoutingOptions;

    // Signal characteristics
    @Column(name = "signal_type")
    private String signalType;

    @Column(name = "bypass_type")
    private String bypassType;

    @Column(name = "mono_stereo")
    private String monoStereo;

    @Column(name = "audio_mix")
    private String audioMix;

    @Column(name = "has_analog_dry_through")
    private Boolean hasAnalogDryThrough;

    @Column(name = "has_spillover")
    private Boolean hasSpillover;

    // Digital specs
    @Column(name = "sample_rate_khz")
    private Integer sampleRateKhz;

    @Column(name = "bit_depth")
    private Integer bitDepth;

    @Column(name = "latency_ms")
    private Double latencyMs;

    // Capabilities
    @Column(name = "preset_count")
    private Integer presetCount;

    @Column(name = "has_tap_tempo")
    private Boolean hasTapTempo;

    // MIDI
    @Column(name = "midi_capable")
    private Boolean midiCapable;

    @Column(name = "midi_receive_capabilities")
    private String midiReceiveCapabilities;

    @Column(name = "midi_send_capabilities")
    private String midiSendCapabilities;

    // Software
    @Column(name = "has_software_editor")
    private Boolean hasSoftwareEditor;

    @Column(name = "software_platforms")
    private String softwarePlatforms;

    @Column(name = "is_firmware_updatable")
    private Boolean isFirmwareUpdatable;

    @Column(name = "has_usb_audio")
    private Boolean hasUsbAudio;

    // Power
    @Column(name = "battery_capable")
    private Boolean batteryCapable;

    // Effects loops
    @Column(name = "fx_loop_count")
    private Integer fxLoopCount;

    @Column(name = "has_reorderable_loops")
    private Boolean hasReorderableLoops;

    public PedalDetail() {}

    // --- Getters ---
    public Integer getProductId() { return productId; }
    public Product getProduct() { return product; }
    public String getEffectType() { return effectType; }
    public String getCircuitType() { return circuitType; }
    public String getCircuitRoutingOptions() { return circuitRoutingOptions; }
    public String getSignalType() { return signalType; }
    public String getBypassType() { return bypassType; }
    public String getMonoStereo() { return monoStereo; }
    public String getAudioMix() { return audioMix; }
    public Boolean getHasAnalogDryThrough() { return hasAnalogDryThrough; }
    public Boolean getHasSpillover() { return hasSpillover; }
    public Integer getSampleRateKhz() { return sampleRateKhz; }
    public Integer getBitDepth() { return bitDepth; }
    public Double getLatencyMs() { return latencyMs; }
    public Integer getPresetCount() { return presetCount; }
    public Boolean getHasTapTempo() { return hasTapTempo; }
    public Boolean getMidiCapable() { return midiCapable; }
    public String getMidiReceiveCapabilities() { return midiReceiveCapabilities; }
    public String getMidiSendCapabilities() { return midiSendCapabilities; }
    public Boolean getHasSoftwareEditor() { return hasSoftwareEditor; }
    public String getSoftwarePlatforms() { return softwarePlatforms; }
    public Boolean getIsFirmwareUpdatable() { return isFirmwareUpdatable; }
    public Boolean getHasUsbAudio() { return hasUsbAudio; }
    public Boolean getBatteryCapable() { return batteryCapable; }
    public Integer getFxLoopCount() { return fxLoopCount; }
    public Boolean getHasReorderableLoops() { return hasReorderableLoops; }
}
