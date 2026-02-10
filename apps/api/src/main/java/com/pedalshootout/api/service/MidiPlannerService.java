package com.pedalshootout.api.service;

import com.pedalshootout.api.dto.JackDto;
import com.pedalshootout.api.dto.MidiPlannerDto;
import com.pedalshootout.api.entity.Jack;
import com.pedalshootout.api.entity.MidiControllerDetail;
import com.pedalshootout.api.entity.PedalDetail;
import com.pedalshootout.api.entity.Product;
import com.pedalshootout.api.repository.JackRepository;
import com.pedalshootout.api.repository.MidiControllerDetailRepository;
import com.pedalshootout.api.repository.PedalDetailRepository;
import com.pedalshootout.api.repository.ProductRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

/**
 * Layer 2 service: MIDI Planner.
 *
 * Lists all MIDI-capable devices and checks compatibility between
 * a MIDI controller and selected pedals. Compatibility is determined by:
 *   1. Does the pedal have midi_capable = true?
 *   2. Does the pedal have a MIDI input jack?
 *   3. What MIDI capabilities does it support? (PC, CC, Clock, etc.)
 */
@Service
@Transactional(readOnly = true)
public class MidiPlannerService {

    private final MidiControllerDetailRepository midiControllerRepo;
    private final PedalDetailRepository pedalDetailRepo;
    private final ProductRepository productRepository;
    private final JackRepository jackRepository;

    public MidiPlannerService(MidiControllerDetailRepository midiControllerRepo,
                               PedalDetailRepository pedalDetailRepo,
                               ProductRepository productRepository,
                               JackRepository jackRepository) {
        this.midiControllerRepo = midiControllerRepo;
        this.pedalDetailRepo = pedalDetailRepo;
        this.productRepository = productRepository;
        this.jackRepository = jackRepository;
    }

    /** Get all MIDI-capable devices (controllers + MIDI-capable pedals). */
    public List<MidiPlannerDto.MidiDevice> getDevices() {
        List<MidiPlannerDto.MidiDevice> devices = new ArrayList<>();

        // Add all MIDI controllers
        for (MidiControllerDetail mc : midiControllerRepo.findAll()) {
            Product p = mc.getProduct();
            List<JackDto> midiJacks = getMidiJacks(p.getId());
            devices.add(new MidiPlannerDto.MidiDevice(
                p.getId(), p.getModel(), p.getManufacturer().getName(),
                "midi_controller", true, null, null,
                mc.getTotalPresetSlots(), midiJacks
            ));
        }

        // Add MIDI-capable pedals
        for (PedalDetail pd : pedalDetailRepo.findByMidiCapableTrue()) {
            Product p = pd.getProduct();
            List<JackDto> midiJacks = getMidiJacks(p.getId());
            devices.add(new MidiPlannerDto.MidiDevice(
                p.getId(), p.getModel(), p.getManufacturer().getName(),
                "pedal", pd.getMidiCapable(),
                pd.getMidiReceiveCapabilities(), pd.getMidiSendCapabilities(),
                pd.getPresetCount(), midiJacks
            ));
        }

        return devices;
    }

    /** Check MIDI compatibility between a controller and pedals. */
    public Optional<MidiPlannerDto.CompatibilityResult> checkCompatibility(
            Integer controllerId, List<Integer> pedalIds) {

        Optional<MidiControllerDetail> controllerOpt = midiControllerRepo.findById(controllerId);
        if (controllerOpt.isEmpty()) return Optional.empty();

        MidiControllerDetail controller = controllerOpt.get();
        Product controllerProduct = controller.getProduct();

        // Check what MIDI output types the controller has
        List<Jack> controllerMidiOuts = jackRepository.findByProductId(controllerId).stream()
                .filter(j -> j.getCategory().startsWith("MIDI") && "Output".equals(j.getDirection()))
                .toList();

        List<MidiPlannerDto.PedalCompatibility> results = new ArrayList<>();
        int compatible = 0;

        for (Integer pedalId : pedalIds) {
            Optional<PedalDetail> pedalOpt = pedalDetailRepo.findById(pedalId);
            if (pedalOpt.isPresent()) {
                PedalDetail pd = pedalOpt.get();
                Product p = pd.getProduct();
                boolean isMidiCapable = Boolean.TRUE.equals(pd.getMidiCapable());

                // Check if pedal has a MIDI input jack
                List<Jack> pedalMidiIns = jackRepository.findByProductId(pedalId).stream()
                        .filter(j -> j.getCategory().startsWith("MIDI") && "Input".equals(j.getDirection()))
                        .toList();
                boolean hasMidiInput = !pedalMidiIns.isEmpty();

                // Determine connection type
                String connectionType = "None";
                String notes = "";

                if (isMidiCapable && hasMidiInput) {
                    // Match connector types
                    String pedalConnector = pedalMidiIns.get(0).getConnectorType();
                    boolean directMatch = controllerMidiOuts.stream()
                            .anyMatch(j -> j.getConnectorType().equals(pedalConnector));

                    if (directMatch) {
                        connectionType = "Direct (" + pedalConnector + ")";
                    } else if (!controllerMidiOuts.isEmpty()) {
                        connectionType = "Adapter needed";
                        notes = "Controller outputs " + controllerMidiOuts.get(0).getConnectorType()
                                + ", pedal expects " + pedalConnector;
                    }
                    compatible++;
                } else if (isMidiCapable && !hasMidiInput) {
                    connectionType = "USB only";
                    notes = "Pedal is MIDI-capable but has no standard MIDI input jack";
                } else {
                    notes = "Pedal does not support MIDI";
                }

                results.add(new MidiPlannerDto.PedalCompatibility(
                    p.getId(), p.getModel(), p.getManufacturer().getName(),
                    isMidiCapable, pd.getMidiReceiveCapabilities(),
                    hasMidiInput, connectionType, notes
                ));
            }
        }

        String summary = String.format("%d of %d pedals are MIDI-compatible with %s.",
                compatible, pedalIds.size(), controllerProduct.getModel());

        return Optional.of(new MidiPlannerDto.CompatibilityResult(
            controllerId, controllerProduct.getModel(), results, summary
        ));
    }

    private List<JackDto> getMidiJacks(Integer productId) {
        return jackRepository.findByProductId(productId).stream()
                .filter(j -> j.getCategory().startsWith("MIDI"))
                .map(JackDto::from)
                .toList();
    }
}
