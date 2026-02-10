package com.pedalshootout.api.repository;

import com.pedalshootout.api.entity.PedalDetail;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

/**
 * Repository for pedal_details table.
 *
 * findAll() returns all pedal details. To get the full pedal view (product + details + jacks),
 * the PedalService combines data from this repository with ProductRepository and JackRepository.
 */
public interface PedalDetailRepository extends JpaRepository<PedalDetail, Integer> {

    List<PedalDetail> findByEffectType(String effectType);

    List<PedalDetail> findByMidiCapableTrue();
}
