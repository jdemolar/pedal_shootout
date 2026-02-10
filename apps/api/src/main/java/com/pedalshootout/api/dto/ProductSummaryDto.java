package com.pedalshootout.api.dto;

import com.pedalshootout.api.entity.Product;

/**
 * Summary DTO for products in list views.
 *
 * Shows common fields without type-specific details. Used for:
 *   - GET /api/products (list all)
 *   - GET /api/manufacturers/{id}/products
 *
 * Notice how this differs from the entity:
 *   - msrpCents (integer) → msrpDisplay (formatted string like "$99.00")
 *   - manufacturer_id (FK) → manufacturerName (the actual name)
 *   - product_type_id (FK) → productType (the type name string)
 *   - Internal fields (notes, data_reliability) are excluded
 */
public record ProductSummaryDto(
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
    String imagePath
) {
    public static ProductSummaryDto from(Product p) {
        return new ProductSummaryDto(
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
            p.getImagePath()
        );
    }

    private static String formatMsrp(Integer cents) {
        if (cents == null) return null;
        return String.format("$%d.%02d", cents / 100, cents % 100);
    }
}
