package com.pedalshootout.api.dto;

import com.pedalshootout.api.entity.Product;

import java.util.List;

/**
 * Full product detail DTO — includes all fields plus jacks.
 * Used for GET /api/products/{id} single-product view.
 */
public record ProductDetailDto(
    Integer id,
    String model,
    String manufacturerName,
    Integer manufacturerId,
    String productType,
    Integer productTypeId,
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
    List<JackDto> jacks
) {
    public static ProductDetailDto from(Product p, List<JackDto> jacks) {
        return new ProductDetailDto(
            p.getId(),
            p.getModel(),
            p.getManufacturer().getName(),
            p.getManufacturer().getId(),
            p.getProductType().getTypeName(),
            p.getProductType().getId(),
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
            jacks
        );
    }

    private static String formatMsrp(Integer cents) {
        if (cents == null) return null;
        return String.format("$%d.%02d", cents / 100, cents % 100);
    }
}
