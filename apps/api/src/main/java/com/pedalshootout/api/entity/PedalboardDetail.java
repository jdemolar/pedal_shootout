package com.pedalshootout.api.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "pedalboard_details")
public class PedalboardDetail {

    @Id
    @Column(name = "product_id")
    private Integer productId;

    @OneToOne(fetch = FetchType.LAZY)
    @MapsId
    @JoinColumn(name = "product_id")
    private Product product;

    @Column(name = "usable_width_mm")
    private Double usableWidthMm;

    @Column(name = "usable_depth_mm")
    private Double usableDepthMm;

    @Column(name = "surface_type")
    private String surfaceType;

    @Column(name = "rail_spacing_mm")
    private Double railSpacingMm;

    private String material;

    @Column(name = "tilt_angle_degrees")
    private Double tiltAngleDegrees;

    @Column(name = "under_clearance_mm")
    private Double underClearanceMm;

    @Column(name = "has_second_tier")
    private Boolean hasSecondTier;

    @Column(name = "tier2_usable_width_mm")
    private Double tier2UsableWidthMm;

    @Column(name = "tier2_usable_depth_mm")
    private Double tier2UsableDepthMm;

    @Column(name = "tier2_under_clearance_mm")
    private Double tier2UnderClearanceMm;

    @Column(name = "tier2_height_mm")
    private Double tier2HeightMm;

    @Column(name = "has_integrated_power")
    private Boolean hasIntegratedPower;

    @Column(name = "integrated_power_product_id")
    private Integer integratedPowerProductId;

    @Column(name = "has_integrated_patch_bay")
    private Boolean hasIntegratedPatchBay;

    @Column(name = "case_included")
    private Boolean caseIncluded;

    @Column(name = "case_type")
    private String caseType;

    @Column(name = "max_load_kg")
    private Double maxLoadKg;

    public PedalboardDetail() {}

    public Integer getProductId() { return productId; }
    public Product getProduct() { return product; }
    public Double getUsableWidthMm() { return usableWidthMm; }
    public Double getUsableDepthMm() { return usableDepthMm; }
    public String getSurfaceType() { return surfaceType; }
    public Double getRailSpacingMm() { return railSpacingMm; }
    public String getMaterial() { return material; }
    public Double getTiltAngleDegrees() { return tiltAngleDegrees; }
    public Double getUnderClearanceMm() { return underClearanceMm; }
    public Boolean getHasSecondTier() { return hasSecondTier; }
    public Double getTier2UsableWidthMm() { return tier2UsableWidthMm; }
    public Double getTier2UsableDepthMm() { return tier2UsableDepthMm; }
    public Double getTier2UnderClearanceMm() { return tier2UnderClearanceMm; }
    public Double getTier2HeightMm() { return tier2HeightMm; }
    public Boolean getHasIntegratedPower() { return hasIntegratedPower; }
    public Integer getIntegratedPowerProductId() { return integratedPowerProductId; }
    public Boolean getHasIntegratedPatchBay() { return hasIntegratedPatchBay; }
    public Boolean getCaseIncluded() { return caseIncluded; }
    public String getCaseType() { return caseType; }
    public Double getMaxLoadKg() { return maxLoadKg; }
}
