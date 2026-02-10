package com.pedalshootout.api.controller;

import com.pedalshootout.api.dto.PowerBudgetDto;
import com.pedalshootout.api.service.PowerBudgetService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Layer 2 controller: Power Budget.
 *
 *   GET /api/power-budget/calculate?supplyId=X&pedalIds=1,2,3  — check power budget
 *   GET /api/power-budget/supplies-for-pedals?pedalIds=1,2,3   — find compatible supplies
 */
@RestController
@RequestMapping("/api/power-budget")
public class PowerBudgetController {

    private final PowerBudgetService powerBudgetService;

    public PowerBudgetController(PowerBudgetService powerBudgetService) {
        this.powerBudgetService = powerBudgetService;
    }

    @GetMapping("/calculate")
    public ResponseEntity<PowerBudgetDto.CalculationResult> calculate(
            @RequestParam Integer supplyId,
            @RequestParam List<Integer> pedalIds) {
        return powerBudgetService.calculate(supplyId, pedalIds)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/supplies-for-pedals")
    public List<PowerBudgetDto.SupplyMatch> suppliesForPedals(
            @RequestParam List<Integer> pedalIds) {
        return powerBudgetService.findSuppliesForPedals(pedalIds);
    }
}
