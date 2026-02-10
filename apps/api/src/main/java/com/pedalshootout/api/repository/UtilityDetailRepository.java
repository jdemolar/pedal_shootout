package com.pedalshootout.api.repository;

import com.pedalshootout.api.entity.UtilityDetail;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface UtilityDetailRepository extends JpaRepository<UtilityDetail, Integer> {

    List<UtilityDetail> findByUtilityType(String utilityType);
}
