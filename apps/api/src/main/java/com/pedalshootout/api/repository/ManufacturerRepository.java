package com.pedalshootout.api.repository;

import com.pedalshootout.api.entity.Manufacturer;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

/**
 * Repository interface for the manufacturers table.
 *
 * This is one of Spring Data JPA's most powerful features: you write an INTERFACE
 * (not a class), and Spring automatically generates the implementation at runtime.
 *
 * JpaRepository<Manufacturer, Integer> means:
 *   - Manufacturer = the entity type
 *   - Integer = the type of the primary key
 *
 * You get these methods for free (no code needed):
 *   - findAll()          → SELECT * FROM manufacturers
 *   - findById(id)       → SELECT * FROM manufacturers WHERE id = ?
 *   - count()            → SELECT COUNT(*) FROM manufacturers
 *   - existsById(id)     → SELECT EXISTS(...)
 *
 * Spring Data also generates queries from method names (called "query derivation"):
 *   - findByNameContainingIgnoreCase("boss")
 *     → SELECT * FROM manufacturers WHERE LOWER(name) LIKE LOWER('%boss%')
 *
 * This replaces writing raw SQL or building query builders manually.
 */
public interface ManufacturerRepository extends JpaRepository<Manufacturer, Integer> {

    /** Find manufacturers whose name contains the search term (case-insensitive). */
    List<Manufacturer> findByNameContainingIgnoreCase(String name);

    /** Find manufacturers by status (e.g., "Active", "Defunct"). */
    List<Manufacturer> findByStatus(String status);
}
