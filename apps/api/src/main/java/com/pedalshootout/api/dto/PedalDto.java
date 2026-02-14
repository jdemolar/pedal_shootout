package com.pedalshootout.api.dto;

import com.pedalshootout.api.entity.PedalDetail;
import com.pedalshootout.api.entity.Product;

import java.util.List;

/**
 * Full pedal DTO — combines product info, pedal-specific details, and jacks.
 *
 * This is the "cross-table" response shape for GET /api/pedals and GET /api/pedals/{id}.
 * In the database, this data lives across 3 tables (products, pedal_details, jacks).
 * The DTO flattens it into a single JSON object for the frontend.
 */
public record PedalDto(
    // Product fields
    Integer id,
    String model,
    String manufacturerName,
    Integer manufacturerId,
    String colorOptions,
    Boolean inProduction,
    Double widthMm,
    Double depthMm,
    Double heightMm,
    Integer weightGrams,
    String msrpDisplay,
    Integer msrpCents,
    String productPage,
    String instructionManual,
    String imagePath,
    String description,
    String tags,
    String dataReliability,
    // Pedal-specific details (nested object)
    PedalDetailDto pedalDetails,
    // Jacks
    List<JackDto> jacks
) {
    public static PedalDto from(Product p, PedalDetail pd, List<JackDto> jacks) {
        return new PedalDto(
            p.getId(),
            p.getModel(),
            p.getManufacturer().getName(),
            p.getManufacturer().getId(),
            p.getColorOptions(),
            p.getInProduction(),
            p.getWidthMm(),
            p.getDepthMm(),
            p.getHeightMm(),
            p.getWeightGrams(),
            formatMsrp(p.getMsrpCents()),
            p.getMsrpCents(),
            p.getProductPage(),
            p.getInstructionManual(),
            p.getImagePath(),
            p.getDescription(),
            p.getTags(),
            p.getDataReliability(),
            PedalDetailDto.from(pd),
            jacks
        );
    }

    private static String formatMsrp(Integer cents) {
        if (cents == null) return null;
        return String.format("$%d.%02d", cents / 100, cents % 100);
    }
}
