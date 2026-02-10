package com.pedalshootout.api.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "utility_details")
public class UtilityDetail {

    @Id
    @Column(name = "product_id")
    private Integer productId;

    @OneToOne(fetch = FetchType.LAZY)
    @MapsId
    @JoinColumn(name = "product_id")
    private Product product;

    @Column(name = "utility_type", nullable = false)
    private String utilityType;

    @Column(name = "is_active")
    private Boolean isActive;

    @Column(name = "signal_type")
    private String signalType;

    @Column(name = "bypass_type")
    private String bypassType;

    @Column(name = "has_ground_lift")
    private Boolean hasGroundLift;

    @Column(name = "has_pad")
    private Boolean hasPad;

    @Column(name = "pad_db")
    private Integer padDb;

    @Column(name = "tuning_display_type")
    private String tuningDisplayType;

    @Column(name = "tuning_accuracy_cents")
    private Double tuningAccuracyCents;

    @Column(name = "polyphonic_tuning")
    private Boolean polyphonicTuning;

    @Column(name = "sweep_type")
    private String sweepType;

    @Column(name = "has_tuner_out")
    private Boolean hasTunerOut;

    @Column(name = "has_minimum_volume")
    private Boolean hasMinimumVolume;

    @Column(name = "has_polarity_switch")
    private Boolean hasPolaritySwitch;

    @Column(name = "power_handling_watts")
    private Integer powerHandlingWatts;

    @Column(name = "has_reactive_load")
    private Boolean hasReactiveLoad;

    @Column(name = "has_attenuation")
    private Boolean hasAttenuation;

    @Column(name = "attenuation_range_db")
    private String attenuationRangeDb;

    @Column(name = "has_cab_sim")
    private Boolean hasCabSim;

    public UtilityDetail() {}

    public Integer getProductId() { return productId; }
    public Product getProduct() { return product; }
    public String getUtilityType() { return utilityType; }
    public Boolean getIsActive() { return isActive; }
    public String getSignalType() { return signalType; }
    public String getBypassType() { return bypassType; }
    public Boolean getHasGroundLift() { return hasGroundLift; }
    public Boolean getHasPad() { return hasPad; }
    public Integer getPadDb() { return padDb; }
    public String getTuningDisplayType() { return tuningDisplayType; }
    public Double getTuningAccuracyCents() { return tuningAccuracyCents; }
    public Boolean getPolyphonicTuning() { return polyphonicTuning; }
    public String getSweepType() { return sweepType; }
    public Boolean getHasTunerOut() { return hasTunerOut; }
    public Boolean getHasMinimumVolume() { return hasMinimumVolume; }
    public Boolean getHasPolaritySwitch() { return hasPolaritySwitch; }
    public Integer getPowerHandlingWatts() { return powerHandlingWatts; }
    public Boolean getHasReactiveLoad() { return hasReactiveLoad; }
    public Boolean getHasAttenuation() { return hasAttenuation; }
    public String getAttenuationRangeDb() { return attenuationRangeDb; }
    public Boolean getHasCabSim() { return hasCabSim; }
}
