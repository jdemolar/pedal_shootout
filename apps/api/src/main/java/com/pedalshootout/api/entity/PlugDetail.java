package com.pedalshootout.api.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "plug_details")
public class PlugDetail {

    @Id
    @Column(name = "product_id")
    private Integer productId;

    @OneToOne(fetch = FetchType.LAZY)
    @MapsId
    @JoinColumn(name = "product_id")
    private Product product;

    @Column(name = "plug_type", nullable = false)
    private String plugType;

    @Column(name = "connector_type", nullable = false)
    private String connectorType;

    @Column(name = "is_right_angle")
    private Boolean isRightAngle;

    @Column(name = "is_pancake")
    private Boolean isPancake;

    @Column(name = "plug_width_mm")
    private Double plugWidthMm;

    @Column(name = "plug_depth_mm")
    private Double plugDepthMm;

    @Column(name = "plug_height_mm")
    private Double plugHeightMm;

    @Column(name = "cable_exit_direction")
    private String cableExitDirection;

    @Column(name = "is_solderless")
    private Boolean isSolderless;

    @Column(name = "housing_material")
    private String housingMaterial;

    @Column(name = "has_locking_mechanism")
    private Boolean hasLockingMechanism;

    public PlugDetail() {}

    public Integer getProductId() { return productId; }
    public Product getProduct() { return product; }
    public String getPlugType() { return plugType; }
    public String getConnectorType() { return connectorType; }
    public Boolean getIsRightAngle() { return isRightAngle; }
    public Boolean getIsPancake() { return isPancake; }
    public Double getPlugWidthMm() { return plugWidthMm; }
    public Double getPlugDepthMm() { return plugDepthMm; }
    public Double getPlugHeightMm() { return plugHeightMm; }
    public String getCableExitDirection() { return cableExitDirection; }
    public Boolean getIsSolderless() { return isSolderless; }
    public String getHousingMaterial() { return housingMaterial; }
    public Boolean getHasLockingMechanism() { return hasLockingMechanism; }
}
