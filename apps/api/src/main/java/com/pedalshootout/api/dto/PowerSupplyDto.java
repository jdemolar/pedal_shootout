package com.pedalshootout.api.dto;

import com.pedalshootout.api.entity.PowerSupplyDetail;
import com.pedalshootout.api.entity.Product;

import java.util.List;

/**
 * Full DTO for power supply — product info + power supply details + jacks (power outputs).
 */
public record PowerSupplyDto(
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
    // Power supply-specific
    String supplyType,
    String topology,
    String inputVoltageRange,
    String inputFrequency,
    Integer totalOutputCount,
    Integer totalCurrentMa,
    Integer isolatedOutputCount,
    String availableVoltages,
    Boolean hasVariableVoltage,
    String voltageRange,
    String mountingType,
    Boolean bracketIncluded,
    Boolean isExpandable,
    String expansionPortType,
    Boolean isBatteryPowered,
    Double batteryCapacityWh,
    // Jacks (power outputs + inputs)
    List<JackDto> jacks
) {
    public static PowerSupplyDto from(Product p, PowerSupplyDetail d, List<JackDto> jacks) {
        return new PowerSupplyDto(
            p.getId(), p.getModel(), p.getManufacturer().getName(), p.getManufacturer().getId(),
            p.getColorOptions(), p.getInProduction(),
            p.getWidthMm(), p.getDepthMm(), p.getHeightMm(), p.getWeightGrams(),
            formatMsrp(p.getMsrpCents()), p.getMsrpCents(), p.getProductPage(), p.getInstructionManual(),
            p.getImagePath(), p.getDataReliability(),
            d.getSupplyType(), d.getTopology(), d.getInputVoltageRange(), d.getInputFrequency(),
            d.getTotalOutputCount(), d.getTotalCurrentMa(), d.getIsolatedOutputCount(),
            d.getAvailableVoltages(), d.getHasVariableVoltage(), d.getVoltageRange(),
            d.getMountingType(), d.getBracketIncluded(), d.getIsExpandable(), d.getExpansionPortType(),
            d.getIsBatteryPowered(), d.getBatteryCapacityWh(),
            jacks
        );
    }

    private static String formatMsrp(Integer cents) {
        if (cents == null) return null;
        return String.format("$%d.%02d", cents / 100, cents % 100);
    }
}
