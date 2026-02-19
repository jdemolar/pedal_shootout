package com.pedalshootout.api.entity;

import jakarta.persistence.*;
import java.time.LocalDate;
import java.time.OffsetDateTime;

/**
 * JPA Entity for the products base table.
 *
 * This is the central table — every product (pedal, power supply, pedalboard, etc.)
 * has a row here with shared attributes (dimensions, MSRP, etc.). Type-specific
 * details live in separate detail tables linked via product_id.
 *
 * Key JPA relationship annotations:
 *   @ManyToOne — "many products belong to one manufacturer"
 *     This creates a JOIN when loading: each Product includes its Manufacturer object.
 *   @JoinColumn — specifies which column holds the foreign key
 *   FetchType.LAZY — don't load the related object until it's actually accessed
 *     (performance optimization to avoid loading everything upfront)
 */
@Entity
@Table(name = "products")
public class Product {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "manufacturer_id", nullable = false)
    private Manufacturer manufacturer;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "product_type_id", nullable = false)
    private ProductType productType;

    @Column(nullable = false)
    private String model;

    @Column(name = "color_options")
    private String colorOptions;

    @Column(name = "in_production")
    private Boolean inProduction;

    // Dimensions
    @Column(name = "width_mm")
    private Double widthMm;

    @Column(name = "depth_mm")
    private Double depthMm;

    @Column(name = "height_mm")
    private Double heightMm;

    @Column(name = "weight_grams")
    private Integer weightGrams;

    // Pricing and documentation
    @Column(name = "msrp_cents")
    private Integer msrpCents;

    @Column(name = "product_page")
    private String productPage;

    @Column(name = "instruction_manual")
    private String instructionManual;

    @Column(name = "image_path")
    private String imagePath;

    // Metadata
    private String description;
    private String tags;

    @Column(name = "data_reliability")
    private String dataReliability;

    private String notes;

    @Column(name = "last_researched_at")
    private LocalDate lastResearchedAt;

    @Column(name = "created_at")
    private OffsetDateTime createdAt;

    @Column(name = "updated_at")
    private OffsetDateTime updatedAt;

    public Product() {}

    // --- Getters ---
    public Integer getId() { return id; }
    public Manufacturer getManufacturer() { return manufacturer; }
    public ProductType getProductType() { return productType; }
    public String getModel() { return model; }
    public String getColorOptions() { return colorOptions; }
    public Boolean getInProduction() { return inProduction; }
    public Double getWidthMm() { return widthMm; }
    public Double getDepthMm() { return depthMm; }
    public Double getHeightMm() { return heightMm; }
    public Integer getWeightGrams() { return weightGrams; }
    public Integer getMsrpCents() { return msrpCents; }
    public String getProductPage() { return productPage; }
    public String getInstructionManual() { return instructionManual; }
    public String getImagePath() { return imagePath; }
    public String getDescription() { return description; }
    public String getTags() { return tags; }
    public String getDataReliability() { return dataReliability; }
    public String getNotes() { return notes; }
    public LocalDate getLastResearchedAt() { return lastResearchedAt; }
    public OffsetDateTime getCreatedAt() { return createdAt; }
    public OffsetDateTime getUpdatedAt() { return updatedAt; }
}
