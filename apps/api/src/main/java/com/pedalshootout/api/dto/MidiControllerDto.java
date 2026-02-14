package com.pedalshootout.api.dto;

import com.pedalshootout.api.entity.MidiControllerDetail;
import com.pedalshootout.api.entity.Product;

import java.util.List;

public record MidiControllerDto(
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
    // MIDI controller-specific
    Integer footswitchCount,
    String footswitchType,
    Boolean hasLedIndicators,
    String ledColorOptions,
    Integer bankCount,
    Integer presetsPerBank,
    Integer totalPresetSlots,
    Boolean hasDisplay,
    String displayType,
    String displaySize,
    Integer expressionInputCount,
    Integer midiChannels,
    Boolean supportsMidiClock,
    Boolean supportsSysex,
    Boolean softwareEditorAvailable,
    String softwarePlatforms,
    Boolean onDeviceProgramming,
    Boolean isFirmwareUpdatable,
    String configFormat,
    Boolean configFormatDocumented,
    Boolean hasTuner,
    Boolean hasTapTempo,
    Boolean hasSetlistMode,
    Boolean hasPerSwitchDisplays,
    Integer auxSwitchInputCount,
    Boolean hasUsbHost,
    Boolean hasBluetoothMidi,
    Integer audioLoopCount,
    Boolean hasReorderableLoops,
    String loopBypassType,
    Boolean hasParallelRouting,
    Boolean hasGaplessSwitching,
    Boolean hasSpillover,
    List<JackDto> jacks
) {
    public static MidiControllerDto from(Product p, MidiControllerDetail d, List<JackDto> jacks) {
        return new MidiControllerDto(
            p.getId(), p.getModel(), p.getManufacturer().getName(), p.getManufacturer().getId(),
            p.getColorOptions(), p.getInProduction(),
            p.getWidthMm(), p.getDepthMm(), p.getHeightMm(), p.getWeightGrams(),
            formatMsrp(p.getMsrpCents()), p.getMsrpCents(), p.getProductPage(), p.getInstructionManual(), p.getImagePath(),
            p.getDataReliability(),
            d.getFootswitchCount(), d.getFootswitchType(), d.getHasLedIndicators(), d.getLedColorOptions(),
            d.getBankCount(), d.getPresetsPerBank(), d.getTotalPresetSlots(),
            d.getHasDisplay(), d.getDisplayType(), d.getDisplaySize(),
            d.getExpressionInputCount(), d.getMidiChannels(),
            d.getSupportsMidiClock(), d.getSupportsSysex(),
            d.getSoftwareEditorAvailable(), d.getSoftwarePlatforms(),
            d.getOnDeviceProgramming(), d.getIsFirmwareUpdatable(),
            d.getConfigFormat(), d.getConfigFormatDocumented(),
            d.getHasTuner(), d.getHasTapTempo(), d.getHasSetlistMode(), d.getHasPerSwitchDisplays(),
            d.getAuxSwitchInputCount(), d.getHasUsbHost(), d.getHasBluetoothMidi(),
            d.getAudioLoopCount(), d.getHasReorderableLoops(), d.getLoopBypassType(),
            d.getHasParallelRouting(), d.getHasGaplessSwitching(), d.getHasSpillover(),
            jacks
        );
    }

    private static String formatMsrp(Integer cents) {
        if (cents == null) return null;
        return String.format("$%d.%02d", cents / 100, cents % 100);
    }
}
