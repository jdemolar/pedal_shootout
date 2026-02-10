package com.pedalshootout.api.dto;

import java.util.List;

/**
 * DTOs for the board planner Layer 2 endpoints.
 *
 * These are "use-case" DTOs — they don't map 1:1 to a table, but instead
 * combine data from multiple tables to support a specific frontend feature.
 */
public class BoardPlannerDto {

    /** Everything the frontend needs for the board layout planner. */
    public record Components(
        List<PedalboardDto> pedalboards,
        List<PowerSupplyDto> powerSupplies,
        List<PedalDto> pedals
    ) {}

    /** A single pedal's footprint for fit checking. */
    public record PedalFootprint(
        Integer id,
        String model,
        String manufacturerName,
        Double widthMm,
        Double depthMm,
        Double heightMm
    ) {}

    /** Result of checking if pedals fit on a board. */
    public record FitCheckResult(
        Integer boardId,
        String boardModel,
        Double boardUsableWidthMm,
        Double boardUsableDepthMm,
        Double totalPedalAreaMm2,
        Double boardAreaMm2,
        boolean fitsByArea,
        List<PedalFootprint> pedals,
        String summary
    ) {}
}
