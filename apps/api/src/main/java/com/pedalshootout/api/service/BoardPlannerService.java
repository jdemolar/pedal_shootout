package com.pedalshootout.api.service;

import com.pedalshootout.api.dto.*;
import com.pedalshootout.api.entity.PedalboardDetail;
import com.pedalshootout.api.entity.Product;
import com.pedalshootout.api.repository.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

/**
 * Layer 2 service: Board Planner.
 *
 * This is where the "smart" cross-table logic lives. It combines data from
 * pedalboards, pedals, and power supplies to help users plan their pedalboard layout.
 *
 * The fit-check uses a simple area comparison — it sums each pedal's footprint
 * (width × depth) and compares to the board's usable area. This is a rough estimate
 * since it doesn't account for pedal placement/packing, but it gives a quick
 * "will these even fit?" sanity check.
 */
@Service
@Transactional(readOnly = true)
public class BoardPlannerService {

    private final PedalboardDetailRepository pedalboardRepo;
    private final PedalDetailRepository pedalDetailRepo;
    private final PowerSupplyDetailRepository powerSupplyRepo;
    private final ProductRepository productRepository;
    private final JackRepository jackRepository;

    public BoardPlannerService(PedalboardDetailRepository pedalboardRepo,
                                PedalDetailRepository pedalDetailRepo,
                                PowerSupplyDetailRepository powerSupplyRepo,
                                ProductRepository productRepository,
                                JackRepository jackRepository) {
        this.pedalboardRepo = pedalboardRepo;
        this.pedalDetailRepo = pedalDetailRepo;
        this.powerSupplyRepo = powerSupplyRepo;
        this.productRepository = productRepository;
        this.jackRepository = jackRepository;
    }

    private List<JackDto> jacksFor(Integer productId) {
        return jackRepository.findByProductId(productId).stream()
                .map(JackDto::from)
                .toList();
    }

    /** Get all components needed for board planning. */
    public BoardPlannerDto.Components getComponents() {
        List<PedalboardDto> boards = pedalboardRepo.findAll().stream()
                .map(d -> PedalboardDto.from(d.getProduct(), d, jacksFor(d.getProductId())))
                .toList();

        List<PowerSupplyDto> supplies = powerSupplyRepo.findAll().stream()
                .map(d -> PowerSupplyDto.from(d.getProduct(), d, jacksFor(d.getProductId())))
                .toList();

        List<PedalDto> pedals = pedalDetailRepo.findAll().stream()
                .map(d -> PedalDto.from(d.getProduct(), d, jacksFor(d.getProductId())))
                .toList();

        return new BoardPlannerDto.Components(boards, supplies, pedals);
    }

    /** Check if given pedals fit on a specific board (area comparison). */
    public Optional<BoardPlannerDto.FitCheckResult> fitCheck(Integer boardId, List<Integer> pedalIds) {
        Optional<PedalboardDetail> boardOpt = pedalboardRepo.findById(boardId);
        if (boardOpt.isEmpty()) {
            return Optional.empty();
        }

        PedalboardDetail board = boardOpt.get();
        Product boardProduct = board.getProduct();
        Double boardWidth = board.getUsableWidthMm();
        Double boardDepth = board.getUsableDepthMm();

        // If usable dimensions aren't set, fall back to external dimensions
        if (boardWidth == null) boardWidth = boardProduct.getWidthMm();
        if (boardDepth == null) boardDepth = boardProduct.getDepthMm();

        if (boardWidth == null || boardDepth == null) {
            return Optional.of(new BoardPlannerDto.FitCheckResult(
                boardId, boardProduct.getModel(),
                null, null, 0.0, 0.0, false,
                List.of(), "Board dimensions unknown — cannot check fit."
            ));
        }

        double boardArea = boardWidth * boardDepth;
        double totalPedalArea = 0;
        List<BoardPlannerDto.PedalFootprint> footprints = new ArrayList<>();

        for (Integer pedalId : pedalIds) {
            Optional<Product> pedalOpt = productRepository.findById(pedalId);
            if (pedalOpt.isPresent()) {
                Product pedal = pedalOpt.get();
                double w = pedal.getWidthMm() != null ? pedal.getWidthMm() : 0;
                double d = pedal.getDepthMm() != null ? pedal.getDepthMm() : 0;
                totalPedalArea += w * d;
                footprints.add(new BoardPlannerDto.PedalFootprint(
                    pedal.getId(), pedal.getModel(), pedal.getManufacturer().getName(),
                    pedal.getWidthMm(), pedal.getDepthMm(), pedal.getHeightMm()
                ));
            }
        }

        boolean fits = totalPedalArea <= boardArea;
        String summary = fits
                ? String.format("Pedals use %.0f of %.0f mm² (%.0f%% of board area).",
                    totalPedalArea, boardArea, (totalPedalArea / boardArea) * 100)
                : String.format("Pedals need %.0f mm² but board only has %.0f mm² — over by %.0f mm².",
                    totalPedalArea, boardArea, totalPedalArea - boardArea);

        return Optional.of(new BoardPlannerDto.FitCheckResult(
            boardId, boardProduct.getModel(),
            boardWidth, boardDepth,
            totalPedalArea, boardArea, fits,
            footprints, summary
        ));
    }
}
