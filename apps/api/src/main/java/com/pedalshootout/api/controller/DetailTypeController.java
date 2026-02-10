package com.pedalshootout.api.controller;

import com.pedalshootout.api.dto.*;
import com.pedalshootout.api.service.DetailTypeService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * REST controller for all detail-type endpoints (power supplies, pedalboards,
 * MIDI controllers, utilities, plugs).
 *
 * Each product type follows the same pattern:
 *   GET /api/{type}       — list all
 *   GET /api/{type}/{id}  — single with full details + jacks
 *
 * Note: We use separate @GetMapping methods rather than a generic approach
 * because each type has different DTO shapes and different query parameters.
 * In Spring, explicit is preferred over clever.
 */
@RestController
@RequestMapping("/api")
public class DetailTypeController {

    private final DetailTypeService service;

    public DetailTypeController(DetailTypeService service) {
        this.service = service;
    }

    // --- Power Supplies ---

    @GetMapping("/power-supplies")
    public List<PowerSupplyDto> getAllPowerSupplies() {
        return service.findAllPowerSupplies();
    }

    @GetMapping("/power-supplies/{id}")
    public ResponseEntity<PowerSupplyDto> getPowerSupplyById(@PathVariable Integer id) {
        return service.findPowerSupplyById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    // --- Pedalboards ---

    @GetMapping("/pedalboards")
    public List<PedalboardDto> getAllPedalboards() {
        return service.findAllPedalboards();
    }

    @GetMapping("/pedalboards/{id}")
    public ResponseEntity<PedalboardDto> getPedalboardById(@PathVariable Integer id) {
        return service.findPedalboardById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    // --- MIDI Controllers ---

    @GetMapping("/midi-controllers")
    public List<MidiControllerDto> getAllMidiControllers() {
        return service.findAllMidiControllers();
    }

    @GetMapping("/midi-controllers/{id}")
    public ResponseEntity<MidiControllerDto> getMidiControllerById(@PathVariable Integer id) {
        return service.findMidiControllerById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    // --- Utilities ---

    @GetMapping("/utilities")
    public List<UtilityDto> getAllUtilities(
            @RequestParam(required = false) String utilityType) {
        return service.findAllUtilities(utilityType);
    }

    @GetMapping("/utilities/{id}")
    public ResponseEntity<UtilityDto> getUtilityById(@PathVariable Integer id) {
        return service.findUtilityById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    // --- Plugs ---

    @GetMapping("/plugs")
    public List<PlugDto> getAllPlugs() {
        return service.findAllPlugs();
    }

    @GetMapping("/plugs/{id}")
    public ResponseEntity<PlugDto> getPlugById(@PathVariable Integer id) {
        return service.findPlugById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }
}
