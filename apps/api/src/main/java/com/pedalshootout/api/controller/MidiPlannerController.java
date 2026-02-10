package com.pedalshootout.api.controller;

import com.pedalshootout.api.dto.MidiPlannerDto;
import com.pedalshootout.api.service.MidiPlannerService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Layer 2 controller: MIDI Planner.
 *
 *   GET /api/midi-planner/devices                                      — all MIDI-capable devices
 *   GET /api/midi-planner/compatibility?controllerId=X&pedalIds=1,2,3  — check MIDI compatibility
 */
@RestController
@RequestMapping("/api/midi-planner")
public class MidiPlannerController {

    private final MidiPlannerService midiPlannerService;

    public MidiPlannerController(MidiPlannerService midiPlannerService) {
        this.midiPlannerService = midiPlannerService;
    }

    @GetMapping("/devices")
    public List<MidiPlannerDto.MidiDevice> getDevices() {
        return midiPlannerService.getDevices();
    }

    @GetMapping("/compatibility")
    public ResponseEntity<MidiPlannerDto.CompatibilityResult> checkCompatibility(
            @RequestParam Integer controllerId,
            @RequestParam List<Integer> pedalIds) {
        return midiPlannerService.checkCompatibility(controllerId, pedalIds)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }
}
