package com.pedalshootout.api.dto;

import com.pedalshootout.api.entity.PedalboardDetail;
import com.pedalshootout.api.entity.Product;

import java.util.List;

public record PedalboardDto(
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
    String dataReliability,
    // Pedalboard-specific
    Double usableWidthMm,
    Double usableDepthMm,
    String surfaceType,
    Double railSpacingMm,
    String material,
    Double tiltAngleDegrees,
    Double underClearanceMm,
    Boolean hasSecondTier,
    Double tier2UsableWidthMm,
    Double tier2UsableDepthMm,
    Double tier2UnderClearanceMm,
    Double tier2HeightMm,
    Boolean hasIntegratedPower,
    Integer integratedPowerProductId,
    Boolean hasIntegratedPatchBay,
    Boolean caseIncluded,
    String caseType,
    Double maxLoadKg,
    List<JackDto> jacks
) {
    public static PedalboardDto from(Product p, PedalboardDetail d, List<JackDto> jacks) {
        return new PedalboardDto(
            p.getId(), p.getModel(), p.getManufacturer().getName(), p.getManufacturer().getId(),
            p.getColorOptions(), p.getInProduction(),
            p.getWidthMm(), p.getDepthMm(), p.getHeightMm(), p.getWeightGrams(),
            formatMsrp(p.getMsrpCents()), p.getMsrpCents(), p.getProductPage(), p.getInstructionManual(), p.getImagePath(),
            p.getDataReliability(),
            d.getUsableWidthMm(), d.getUsableDepthMm(), d.getSurfaceType(), d.getRailSpacingMm(),
            d.getMaterial(), d.getTiltAngleDegrees(), d.getUnderClearanceMm(),
            d.getHasSecondTier(), d.getTier2UsableWidthMm(), d.getTier2UsableDepthMm(),
            d.getTier2UnderClearanceMm(), d.getTier2HeightMm(),
            d.getHasIntegratedPower(), d.getIntegratedPowerProductId(), d.getHasIntegratedPatchBay(),
            d.getCaseIncluded(), d.getCaseType(), d.getMaxLoadKg(),
            jacks
        );
    }

    private static String formatMsrp(Integer cents) {
        if (cents == null) return null;
        return String.format("$%d.%02d", cents / 100, cents % 100);
    }
}
