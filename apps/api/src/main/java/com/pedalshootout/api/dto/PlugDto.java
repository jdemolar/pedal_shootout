package com.pedalshootout.api.dto;

import com.pedalshootout.api.entity.PlugDetail;
import com.pedalshootout.api.entity.Product;

import java.util.List;

public record PlugDto(
    Integer id,
    String model,
    String manufacturerName,
    Integer manufacturerId,
    String colorOptions,
    Boolean inProduction,
    String msrpDisplay,
    Integer msrpCents,
    String productPage,
    String imagePath,
    // Plug-specific
    String plugType,
    String connectorType,
    Boolean isRightAngle,
    Boolean isPancake,
    Double plugWidthMm,
    Double plugDepthMm,
    Double plugHeightMm,
    String cableExitDirection,
    Boolean isSolderless,
    String housingMaterial,
    Boolean hasLockingMechanism,
    List<JackDto> jacks
) {
    public static PlugDto from(Product p, PlugDetail d, List<JackDto> jacks) {
        return new PlugDto(
            p.getId(), p.getModel(), p.getManufacturer().getName(), p.getManufacturer().getId(),
            p.getColorOptions(), p.getInProduction(),
            formatMsrp(p.getMsrpCents()), p.getMsrpCents(), p.getProductPage(), p.getImagePath(),
            d.getPlugType(), d.getConnectorType(), d.getIsRightAngle(), d.getIsPancake(),
            d.getPlugWidthMm(), d.getPlugDepthMm(), d.getPlugHeightMm(),
            d.getCableExitDirection(), d.getIsSolderless(), d.getHousingMaterial(), d.getHasLockingMechanism(),
            jacks
        );
    }

    private static String formatMsrp(Integer cents) {
        if (cents == null) return null;
        return String.format("$%d.%02d", cents / 100, cents % 100);
    }
}
