package com.pedalshootout.api.service;

import com.pedalshootout.api.dto.PowerBudgetDto;
import com.pedalshootout.api.entity.Jack;
import com.pedalshootout.api.entity.PowerSupplyDetail;
import com.pedalshootout.api.entity.Product;
import com.pedalshootout.api.repository.JackRepository;
import com.pedalshootout.api.repository.PowerSupplyDetailRepository;
import com.pedalshootout.api.repository.ProductRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

/**
 * Layer 2 service: Power Budget.
 *
 * Calculates total power draw of selected pedals and compares against
 * a power supply's capacity. Also finds compatible supplies for a set of pedals.
 *
 * Power info comes from the jacks table — specifically the "Power Input" jacks
 * on pedals (current_ma = how much the pedal draws) and the total_current_ma
 * on power_supply_details (total capacity).
 */
@Service
@Transactional(readOnly = true)
public class PowerBudgetService {

    private final PowerSupplyDetailRepository powerSupplyRepo;
    private final ProductRepository productRepository;
    private final JackRepository jackRepository;

    public PowerBudgetService(PowerSupplyDetailRepository powerSupplyRepo,
                               ProductRepository productRepository,
                               JackRepository jackRepository) {
        this.powerSupplyRepo = powerSupplyRepo;
        this.productRepository = productRepository;
        this.jackRepository = jackRepository;
    }

    /** Get power draw info for a pedal from its Power Input jack. */
    private PowerBudgetDto.PedalPower getPedalPower(Product pedal) {
        // Find the power input jack for this pedal
        List<Jack> powerJacks = jackRepository.findByProductIdAndCategory(pedal.getId(), "Power Input");
        Jack powerJack = powerJacks.isEmpty() ? null : powerJacks.get(0);

        return new PowerBudgetDto.PedalPower(
            pedal.getId(),
            pedal.getModel(),
            pedal.getManufacturer().getName(),
            powerJack != null ? powerJack.getVoltage() : null,
            powerJack != null ? powerJack.getCurrentMa() : null,
            powerJack != null ? powerJack.getPolarity() : null
        );
    }

    /** Calculate total power draw of pedals vs a supply's capacity. */
    public Optional<PowerBudgetDto.CalculationResult> calculate(Integer supplyId, List<Integer> pedalIds) {
        Optional<PowerSupplyDetail> supplyOpt = powerSupplyRepo.findById(supplyId);
        if (supplyOpt.isEmpty()) return Optional.empty();

        PowerSupplyDetail supply = supplyOpt.get();
        Product supplyProduct = supply.getProduct();
        int totalCapacity = supply.getTotalCurrentMa() != null ? supply.getTotalCurrentMa() : 0;

        List<PowerBudgetDto.PedalPower> pedalPowers = new ArrayList<>();
        int totalDraw = 0;

        for (Integer pedalId : pedalIds) {
            Optional<Product> pedalOpt = productRepository.findById(pedalId);
            if (pedalOpt.isPresent()) {
                PowerBudgetDto.PedalPower pp = getPedalPower(pedalOpt.get());
                pedalPowers.add(pp);
                if (pp.currentMa() != null) {
                    totalDraw += pp.currentMa();
                }
            }
        }

        int remaining = totalCapacity - totalDraw;
        boolean withinBudget = remaining >= 0;

        String summary = withinBudget
                ? String.format("Total draw: %dmA of %dmA capacity (%dmA headroom).",
                    totalDraw, totalCapacity, remaining)
                : String.format("Over budget! Need %dmA but supply only provides %dmA (short by %dmA).",
                    totalDraw, totalCapacity, -remaining);

        return Optional.of(new PowerBudgetDto.CalculationResult(
            supplyId, supplyProduct.getModel(),
            totalCapacity, totalDraw, remaining, withinBudget,
            pedalPowers, summary
        ));
    }

    /** Find all power supplies that can handle the given pedals' total draw. */
    public List<PowerBudgetDto.SupplyMatch> findSuppliesForPedals(List<Integer> pedalIds) {
        // Calculate total draw
        int totalDraw = 0;
        for (Integer pedalId : pedalIds) {
            Optional<Product> pedalOpt = productRepository.findById(pedalId);
            if (pedalOpt.isPresent()) {
                List<Jack> powerJacks = jackRepository.findByProductIdAndCategory(pedalId, "Power Input");
                if (!powerJacks.isEmpty() && powerJacks.get(0).getCurrentMa() != null) {
                    totalDraw += powerJacks.get(0).getCurrentMa();
                }
            }
        }

        int requiredMa = totalDraw;

        // Find supplies with enough capacity
        return powerSupplyRepo.findAll().stream()
                .filter(s -> s.getTotalCurrentMa() != null && s.getTotalCurrentMa() >= requiredMa)
                .map(s -> {
                    Product p = s.getProduct();
                    return new PowerBudgetDto.SupplyMatch(
                        p.getId(), p.getModel(), p.getManufacturer().getName(),
                        s.getTotalCurrentMa(), requiredMa,
                        s.getTotalCurrentMa() - requiredMa,
                        formatMsrp(p.getMsrpCents())
                    );
                })
                .toList();
    }

    private String formatMsrp(Integer cents) {
        if (cents == null) return null;
        return String.format("$%d.%02d", cents / 100, cents % 100);
    }
}
