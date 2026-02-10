package com.pedalshootout.api.dto;

import java.util.List;

/**
 * DTOs for MIDI planner Layer 2 endpoints.
 */
public class MidiPlannerDto {

    /** A MIDI-capable device (pedal or controller). */
    public record MidiDevice(
        Integer id,
        String model,
        String manufacturerName,
        String productType,
        Boolean midiCapable,
        String midiReceiveCapabilities,
        String midiSendCapabilities,
        Integer presetCount,
        List<JackDto> midiJacks
    ) {}

    /** Compatibility check between a controller and pedals. */
    public record CompatibilityResult(
        Integer controllerId,
        String controllerModel,
        List<PedalCompatibility> pedals,
        String summary
    ) {}

    /** How compatible a single pedal is with the selected controller. */
    public record PedalCompatibility(
        Integer id,
        String model,
        String manufacturerName,
        boolean midiCapable,
        String midiReceiveCapabilities,
        boolean hasMidiInput,
        String connectionType,
        String notes
    ) {}
}
