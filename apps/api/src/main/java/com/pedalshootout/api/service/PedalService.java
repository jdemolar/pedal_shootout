package com.pedalshootout.api.service;

import com.pedalshootout.api.dto.JackDto;
import com.pedalshootout.api.dto.PedalDto;
import com.pedalshootout.api.entity.PedalDetail;
import com.pedalshootout.api.repository.JackRepository;
import com.pedalshootout.api.repository.PedalDetailRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

/**
 * Service for pedal-specific operations.
 *
 * This is where the "cross-table join" happens for pedals:
 * it combines data from products (via PedalDetail.getProduct()),
 * pedal_details, and jacks into a single PedalDto.
 */
@Service
@Transactional(readOnly = true)
public class PedalService {

    private final PedalDetailRepository pedalDetailRepository;
    private final JackRepository jackRepository;

    public PedalService(PedalDetailRepository pedalDetailRepository,
                        JackRepository jackRepository) {
        this.pedalDetailRepository = pedalDetailRepository;
        this.jackRepository = jackRepository;
    }

    /** Get all pedals with their details and jacks. */
    public List<PedalDto> findAll(String effectType) {
        List<PedalDetail> pedals;
        if (effectType != null && !effectType.isBlank()) {
            pedals = pedalDetailRepository.findByEffectType(effectType);
        } else {
            pedals = pedalDetailRepository.findAll();
        }
        return pedals.stream()
                .map(this::toDto)
                .toList();
    }

    /** Get a single pedal by product ID. */
    public Optional<PedalDto> findById(Integer productId) {
        return pedalDetailRepository.findById(productId)
                .map(this::toDto);
    }

    private PedalDto toDto(PedalDetail pd) {
        List<JackDto> jacks = jackRepository.findByProductId(pd.getProductId()).stream()
                .map(JackDto::from)
                .toList();
        return PedalDto.from(pd.getProduct(), pd, jacks);
    }
}
