package com.pedalshootout.api.repository;

import com.pedalshootout.api.entity.Product;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;

/**
 * Repository for the products table.
 *
 * Spring Data JPA derives SQL from method names:
 *   findByManufacturerId(5)  →  SELECT * FROM products WHERE manufacturer_id = 5
 *   findByProductTypeId(1)   →  SELECT * FROM products WHERE product_type_id = 1
 *   countByManufacturerId(5) →  SELECT COUNT(*) FROM products WHERE manufacturer_id = 5
 */
public interface ProductRepository extends JpaRepository<Product, Integer> {

    List<Product> findByManufacturerId(Integer manufacturerId);

    List<Product> findByProductTypeId(Integer productTypeId);

    long countByManufacturerId(Integer manufacturerId);

    @Query("SELECT p.manufacturer.id, COUNT(p) FROM Product p GROUP BY p.manufacturer.id")
    List<Object[]> countGroupedByManufacturerId();
}
