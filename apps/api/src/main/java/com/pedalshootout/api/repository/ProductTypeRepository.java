package com.pedalshootout.api.repository;

import com.pedalshootout.api.entity.ProductType;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

/**
 * Repository for the product_types reference table.
 * Small table (6 rows) — mostly used for lookups and the /api/product-types endpoint.
 */
public interface ProductTypeRepository extends JpaRepository<ProductType, Integer> {

    Optional<ProductType> findByTypeName(String typeName);
}
