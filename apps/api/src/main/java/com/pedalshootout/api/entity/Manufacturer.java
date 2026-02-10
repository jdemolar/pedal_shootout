package com.pedalshootout.api.entity;

import jakarta.persistence.*;
import java.time.OffsetDateTime;

/**
 * JPA Entity — maps to the "manufacturers" table in PostgreSQL.
 *
 * An entity is a Java class where each instance = one row in the database,
 * and each field = one column. JPA (Java Persistence API) handles the mapping
 * between Java objects and SQL tables via annotations.
 *
 * Key annotations:
 *   @Entity     — marks this class as a database-mapped object
 *   @Table      — specifies the exact table name (otherwise JPA guesses from class name)
 *   @Id         — marks the primary key field
 *   @Column     — maps a field to a specific column (optional if names match)
 */
@Entity
@Table(name = "manufacturers")
public class Manufacturer {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(nullable = false, unique = true)
    private String name;

    private String country;
    private String founded;
    private String status;
    private String specialty;
    private String website;
    private String notes;

    @Column(name = "updated_at")
    private OffsetDateTime updatedAt;

    // Default constructor required by JPA (it creates objects via reflection)
    public Manufacturer() {}

    // --- Getters ---
    // JPA and Jackson (JSON serializer) both use getters to read field values.

    public Integer getId() { return id; }
    public String getName() { return name; }
    public String getCountry() { return country; }
    public String getFounded() { return founded; }
    public String getStatus() { return status; }
    public String getSpecialty() { return specialty; }
    public String getWebsite() { return website; }
    public String getNotes() { return notes; }
    public OffsetDateTime getUpdatedAt() { return updatedAt; }
}
