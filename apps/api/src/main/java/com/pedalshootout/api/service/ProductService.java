package com.pedalshootout.api.service;

import com.pedalshootout.api.dto.JackDto;
import com.pedalshootout.api.dto.ProductDetailDto;
import com.pedalshootout.api.dto.ProductSummaryDto;
import com.pedalshootout.api.entity.Product;
import com.pedalshootout.api.repository.JackRepository;
import com.pedalshootout.api.repository.ProductRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

/**
 * Service layer for product operations.
 *
 * @Transactional(readOnly = true) tells Spring to:
 *   1. Open a database transaction for each method call
 *   2. Mark it as read-only (optimizer hint for the database)
 *   3. Keep the JPA session open for the duration (so lazy-loaded relationships work)
 *
 * Without this, accessing product.getManufacturer().getName() would throw a
 * LazyInitializationException because the JPA session closes after the repository call.
 */
@Service
@Transactional(readOnly = true)
public class ProductService {

    private final ProductRepository productRepository;
    private final JackRepository jackRepository;

    public ProductService(ProductRepository productRepository,
                          JackRepository jackRepository) {
        this.productRepository = productRepository;
        this.jackRepository = jackRepository;
    }

    /** Get all products, optionally filtered by product type ID. */
    public List<ProductSummaryDto> findAll(Integer typeId) {
        List<Product> products;
        if (typeId != null) {
            products = productRepository.findByProductTypeId(typeId);
        } else {
            products = productRepository.findAll();
        }
        return products.stream()
                .map(ProductSummaryDto::from)
                .toList();
    }

    /** Get all products by a specific manufacturer. */
    public List<ProductSummaryDto> findByManufacturerId(Integer manufacturerId) {
        return productRepository.findByManufacturerId(manufacturerId).stream()
                .map(ProductSummaryDto::from)
                .toList();
    }

    /** Get a single product with full details and jacks. */
    public Optional<ProductDetailDto> findById(Integer id) {
        return productRepository.findById(id)
                .map(p -> {
                    List<JackDto> jacks = jackRepository.findByProductId(id).stream()
                            .map(JackDto::from)
                            .toList();
                    return ProductDetailDto.from(p, jacks);
                });
    }

    /** Get just the jacks for a product. */
    public List<JackDto> findJacksByProductId(Integer productId) {
        return jackRepository.findByProductId(productId).stream()
                .map(JackDto::from)
                .toList();
    }
}
