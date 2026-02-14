package com.pedalshootout.api.dto;

import com.pedalshootout.api.entity.Product;
import com.pedalshootout.api.entity.UtilityDetail;

import java.util.List;

public record UtilityDto(
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
    // Utility-specific
    String utilityType,
    Boolean isActive,
    String signalType,
    String bypassType,
    Boolean hasGroundLift,
    Boolean hasPad,
    Integer padDb,
    String tuningDisplayType,
    Double tuningAccuracyCents,
    Boolean polyphonicTuning,
    String sweepType,
    Boolean hasTunerOut,
    Boolean hasMinimumVolume,
    Boolean hasPolaritySwitch,
    Integer powerHandlingWatts,
    Boolean hasReactiveLoad,
    Boolean hasAttenuation,
    String attenuationRangeDb,
    Boolean hasCabSim,
    List<JackDto> jacks
) {
    public static UtilityDto from(Product p, UtilityDetail d, List<JackDto> jacks) {
        return new UtilityDto(
            p.getId(), p.getModel(), p.getManufacturer().getName(), p.getManufacturer().getId(),
            p.getColorOptions(), p.getInProduction(),
            p.getWidthMm(), p.getDepthMm(), p.getHeightMm(), p.getWeightGrams(),
            formatMsrp(p.getMsrpCents()), p.getMsrpCents(), p.getProductPage(), p.getInstructionManual(), p.getImagePath(),
            p.getDataReliability(),
            d.getUtilityType(), d.getIsActive(), d.getSignalType(), d.getBypassType(),
            d.getHasGroundLift(), d.getHasPad(), d.getPadDb(),
            d.getTuningDisplayType(), d.getTuningAccuracyCents(), d.getPolyphonicTuning(),
            d.getSweepType(), d.getHasTunerOut(), d.getHasMinimumVolume(), d.getHasPolaritySwitch(),
            d.getPowerHandlingWatts(), d.getHasReactiveLoad(), d.getHasAttenuation(),
            d.getAttenuationRangeDb(), d.getHasCabSim(),
            jacks
        );
    }

    private static String formatMsrp(Integer cents) {
        if (cents == null) return null;
        return String.format("$%d.%02d", cents / 100, cents % 100);
    }
}
