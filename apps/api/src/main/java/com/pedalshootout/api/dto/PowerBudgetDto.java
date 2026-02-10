package com.pedalshootout.api.dto;

import java.util.List;

/**
 * DTOs for power budget Layer 2 endpoints.
 */
public class PowerBudgetDto {

    /** Power draw info for a single pedal. */
    public record PedalPower(
        Integer id,
        String model,
        String manufacturerName,
        String voltage,
        Integer currentMa,
        String polarity
    ) {}

    /** Result of calculating total power draw vs supply capacity. */
    public record CalculationResult(
        Integer supplyId,
        String supplyModel,
        Integer totalCapacityMa,
        Integer totalDrawMa,
        Integer remainingMa,
        boolean withinBudget,
        List<PedalPower> pedals,
        String summary
    ) {}

    /** A power supply that can handle the given pedals. */
    public record SupplyMatch(
        Integer id,
        String model,
        String manufacturerName,
        Integer totalCapacityMa,
        Integer requiredMa,
        Integer headroomMa,
        String msrpDisplay
    ) {}
}
