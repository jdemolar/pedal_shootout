package com.pedalshootout.api.controller;

import com.pedalshootout.api.dto.PedalDto;
import com.pedalshootout.api.service.PedalService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * REST controller for pedal-specific endpoints.
 *
 * These are "Layer 1 detail" endpoints that combine product base data
 * with pedal-specific details and jacks.
 *
 *   GET /api/pedals              — all pedals (filterable by ?effectType=Delay)
 *   GET /api/pedals/{id}         — single pedal with full details + jacks
 */
@RestController
@RequestMapping("/api/pedals")
public class PedalController {

    private final PedalService pedalService;

    public PedalController(PedalService pedalService) {
        this.pedalService = pedalService;
    }

    @GetMapping
    public List<PedalDto> getAll(
            @RequestParam(required = false) String effectType) {
        return pedalService.findAll(effectType);
    }

    @GetMapping("/{id}")
    public ResponseEntity<PedalDto> getById(@PathVariable Integer id) {
        return pedalService.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }
}
