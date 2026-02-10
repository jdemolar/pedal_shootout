package com.pedalshootout.api.dto;

/**
 * DTO (Data Transfer Object) for manufacturer data sent to the frontend.
 *
 * Why not just send the Entity directly? Because:
 *   1. The entity has "notes" (internal) that we don't want to expose
 *   2. We want to add computed fields like "productCount"
 *   3. Decoupling: if the DB schema changes, the API response stays stable
 *
 * A Java "record" is a compact class that's immutable and auto-generates
 * equals(), hashCode(), toString(), and getter methods. It's like a TypeScript
 * interface but enforced at the object level:
 *
 *   TypeScript:  interface ManufacturerDto { id: number; name: string; ... }
 *   Java record: record ManufacturerDto(Integer id, String name, ...) {}
 *
 * Jackson (the JSON library) automatically serializes records to JSON using
 * the field names as keys.
 */
public record ManufacturerDto(
    Integer id,
    String name,
    String country,
    String founded,
    String status,
    String specialty,
    String website,
    long productCount
) {
    /** Factory method to create a DTO from an entity + product count. */
    public static ManufacturerDto from(com.pedalshootout.api.entity.Manufacturer m, long productCount) {
        return new ManufacturerDto(
            m.getId(),
            m.getName(),
            m.getCountry(),
            m.getFounded(),
            m.getStatus(),
            m.getSpecialty(),
            m.getWebsite(),
            productCount
        );
    }

    /** Factory method when product count is not needed (e.g., list views). */
    public static ManufacturerDto from(com.pedalshootout.api.entity.Manufacturer m) {
        return from(m, 0);
    }
}
