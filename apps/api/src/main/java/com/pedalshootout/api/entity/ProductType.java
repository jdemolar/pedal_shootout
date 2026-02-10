package com.pedalshootout.api.entity;

import jakarta.persistence.*;

/**
 * JPA Entity for the product_types reference table.
 *
 * This is a small "enum-like" table with fixed IDs:
 *   1=pedal, 2=power_supply, 3=pedalboard, 4=midi_controller, 5=utility, 6=plug
 *
 * Note: Unlike manufacturers, product_types uses a fixed integer PK (not IDENTITY),
 * so we don't use @GeneratedValue here.
 */
@Entity
@Table(name = "product_types")
public class ProductType {

    @Id
    private Integer id;

    @Column(name = "type_name", nullable = false, unique = true)
    private String typeName;

    private String description;

    public ProductType() {}

    public Integer getId() { return id; }
    public String getTypeName() { return typeName; }
    public String getDescription() { return description; }
}
