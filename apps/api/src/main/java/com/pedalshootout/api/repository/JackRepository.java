package com.pedalshootout.api.repository;

import com.pedalshootout.api.entity.Jack;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

/**
 * Repository for the jacks table.
 *
 * findByProductId(5) → SELECT * FROM jacks WHERE product_id = 5
 * findByProductIdAndCategory(5, "Power Input") → ... WHERE product_id = 5 AND category = 'Power Input'
 */
public interface JackRepository extends JpaRepository<Jack, Integer> {

    List<Jack> findByProductId(Integer productId);

    List<Jack> findByProductIdAndCategory(Integer productId, String category);

    List<Jack> findByProductIdAndDirection(Integer productId, String direction);
}
