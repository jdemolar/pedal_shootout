package com.pedalshootout.api.entity;

import jakarta.persistence.*;
import java.time.LocalDate;
import java.time.OffsetDateTime;

/**
 * JPA Entity for the product_sources table.
 *
 * Tracks data provenance — where each field value came from, what the source
 * reported, and how reliable that source is. This enables per-field reliability
 * auditing and discrepancy detection when multiple sources report different values.
 *
 * @ManyToOne on product means "many source entries belong to one product."
 * @ManyToOne on jack is nullable — only populated when table_name = 'jacks',
 * identifying which specific jack the source covers.
 */
@Entity
@Table(name = "product_sources")
public class ProductSource {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "product_id", nullable = false)
    private Product product;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "jack_id")
    private Jack jack;

    @Column(name = "table_name", nullable = false)
    private String tableName;

    @Column(name = "field_name", nullable = false)
    private String fieldName;

    @Column(name = "value_recorded")
    private String valueRecorded;

    @Column(name = "source_url")
    private String sourceUrl;

    @Column(name = "source_type", nullable = false)
    private String sourceType;

    @Column(nullable = false)
    private String reliability;

    @Column(name = "accessed_at", nullable = false)
    private LocalDate accessedAt;

    private String notes;

    @Column(name = "created_at", nullable = false)
    private OffsetDateTime createdAt;

    public ProductSource() {}

    // --- Getters ---
    public Integer getId() { return id; }
    public Product getProduct() { return product; }
    public Jack getJack() { return jack; }
    public String getTableName() { return tableName; }
    public String getFieldName() { return fieldName; }
    public String getValueRecorded() { return valueRecorded; }
    public String getSourceUrl() { return sourceUrl; }
    public String getSourceType() { return sourceType; }
    public String getReliability() { return reliability; }
    public LocalDate getAccessedAt() { return accessedAt; }
    public String getNotes() { return notes; }
    public OffsetDateTime getCreatedAt() { return createdAt; }
}
