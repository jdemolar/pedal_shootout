package com.pedalshootout.api.service;

import com.pedalshootout.api.dto.ManufacturerDto;
import com.pedalshootout.api.entity.Manufacturer;
import com.pedalshootout.api.repository.ManufacturerRepository;
import com.pedalshootout.api.repository.ProductRepository;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

/**
 * Service layer for manufacturer business logic.
 *
 * The service sits between the controller (HTTP) and repository (database).
 * It's where you put logic that doesn't belong in either:
 *   - Transforming entities into DTOs
 *   - Combining data from multiple repositories
 *   - Applying business rules
 *
 * @Service tells Spring to create a single instance of this class (a "bean")
 * and make it available for injection into controllers.
 *
 * Constructor injection: Spring sees the constructor parameters are repository
 * types, finds the beans it already created for those, and passes them in.
 * This is like dependency injection in Angular or NestJS.
 */
@Service
public class ManufacturerService {

    private final ManufacturerRepository manufacturerRepository;
    private final ProductRepository productRepository;

    public ManufacturerService(ManufacturerRepository manufacturerRepository,
                                ProductRepository productRepository) {
        this.manufacturerRepository = manufacturerRepository;
        this.productRepository = productRepository;
    }

    /** Get all manufacturers, optionally filtered by name search. */
    public List<ManufacturerDto> findAll(String search) {
        List<Manufacturer> manufacturers;
        if (search != null && !search.isBlank()) {
            manufacturers = manufacturerRepository.findByNameContainingIgnoreCase(search);
        } else {
            manufacturers = manufacturerRepository.findAll();
        }
        return manufacturers.stream()
                .map(m -> ManufacturerDto.from(m, productRepository.countByManufacturerId(m.getId())))
                .toList();
    }

    /** Get a single manufacturer by ID, including their product count. */
    public Optional<ManufacturerDto> findById(Integer id) {
        return manufacturerRepository.findById(id)
                .map(m -> {
                    long count = productRepository.countByManufacturerId(id);
                    return ManufacturerDto.from(m, count);
                });
    }
}
