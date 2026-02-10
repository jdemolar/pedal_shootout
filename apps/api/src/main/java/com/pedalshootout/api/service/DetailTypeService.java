package com.pedalshootout.api.service;

import com.pedalshootout.api.dto.*;
import com.pedalshootout.api.entity.*;
import com.pedalshootout.api.repository.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

/**
 * Service for all detail types except pedals (which has its own service due to
 * more complex filtering needs).
 *
 * Each method follows the same pattern:
 *   1. Fetch all detail rows (or one by ID)
 *   2. For each, get the parent Product and its Jacks
 *   3. Combine into a DTO
 *
 * This is where the "Class Table Inheritance" pattern pays off — the same
 * approach works for every product type.
 */
@Service
@Transactional(readOnly = true)
public class DetailTypeService {

    private final PowerSupplyDetailRepository powerSupplyRepo;
    private final PedalboardDetailRepository pedalboardRepo;
    private final MidiControllerDetailRepository midiControllerRepo;
    private final UtilityDetailRepository utilityRepo;
    private final PlugDetailRepository plugRepo;
    private final JackRepository jackRepository;

    public DetailTypeService(
            PowerSupplyDetailRepository powerSupplyRepo,
            PedalboardDetailRepository pedalboardRepo,
            MidiControllerDetailRepository midiControllerRepo,
            UtilityDetailRepository utilityRepo,
            PlugDetailRepository plugRepo,
            JackRepository jackRepository) {
        this.powerSupplyRepo = powerSupplyRepo;
        this.pedalboardRepo = pedalboardRepo;
        this.midiControllerRepo = midiControllerRepo;
        this.utilityRepo = utilityRepo;
        this.plugRepo = plugRepo;
        this.jackRepository = jackRepository;
    }

    private List<JackDto> jacksFor(Integer productId) {
        return jackRepository.findByProductId(productId).stream()
                .map(JackDto::from)
                .toList();
    }

    // --- Power Supplies ---

    public List<PowerSupplyDto> findAllPowerSupplies() {
        return powerSupplyRepo.findAll().stream()
                .map(d -> PowerSupplyDto.from(d.getProduct(), d, jacksFor(d.getProductId())))
                .toList();
    }

    public Optional<PowerSupplyDto> findPowerSupplyById(Integer id) {
        return powerSupplyRepo.findById(id)
                .map(d -> PowerSupplyDto.from(d.getProduct(), d, jacksFor(d.getProductId())));
    }

    // --- Pedalboards ---

    public List<PedalboardDto> findAllPedalboards() {
        return pedalboardRepo.findAll().stream()
                .map(d -> PedalboardDto.from(d.getProduct(), d, jacksFor(d.getProductId())))
                .toList();
    }

    public Optional<PedalboardDto> findPedalboardById(Integer id) {
        return pedalboardRepo.findById(id)
                .map(d -> PedalboardDto.from(d.getProduct(), d, jacksFor(d.getProductId())));
    }

    // --- MIDI Controllers ---

    public List<MidiControllerDto> findAllMidiControllers() {
        return midiControllerRepo.findAll().stream()
                .map(d -> MidiControllerDto.from(d.getProduct(), d, jacksFor(d.getProductId())))
                .toList();
    }

    public Optional<MidiControllerDto> findMidiControllerById(Integer id) {
        return midiControllerRepo.findById(id)
                .map(d -> MidiControllerDto.from(d.getProduct(), d, jacksFor(d.getProductId())));
    }

    // --- Utilities ---

    public List<UtilityDto> findAllUtilities(String utilityType) {
        List<UtilityDetail> details;
        if (utilityType != null && !utilityType.isBlank()) {
            details = utilityRepo.findByUtilityType(utilityType);
        } else {
            details = utilityRepo.findAll();
        }
        return details.stream()
                .map(d -> UtilityDto.from(d.getProduct(), d, jacksFor(d.getProductId())))
                .toList();
    }

    public Optional<UtilityDto> findUtilityById(Integer id) {
        return utilityRepo.findById(id)
                .map(d -> UtilityDto.from(d.getProduct(), d, jacksFor(d.getProductId())));
    }

    // --- Plugs ---

    public List<PlugDto> findAllPlugs() {
        return plugRepo.findAll().stream()
                .map(d -> PlugDto.from(d.getProduct(), d, jacksFor(d.getProductId())))
                .toList();
    }

    public Optional<PlugDto> findPlugById(Integer id) {
        return plugRepo.findById(id)
                .map(d -> PlugDto.from(d.getProduct(), d, jacksFor(d.getProductId())));
    }
}
