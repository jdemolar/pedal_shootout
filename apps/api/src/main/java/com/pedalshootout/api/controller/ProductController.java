package com.pedalshootout.api.controller;

import com.pedalshootout.api.dto.JackDto;
import com.pedalshootout.api.dto.ProductDetailDto;
import com.pedalshootout.api.dto.ProductSummaryDto;
import com.pedalshootout.api.entity.ProductType;
import com.pedalshootout.api.repository.ProductTypeRepository;
import com.pedalshootout.api.service.ProductService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * REST controller for product and product-type endpoints.
 *
 * Handles:
 *   GET /api/products              — list all products (filterable by ?typeId=1)
 *   GET /api/products/{id}         — single product with full details + jacks
 *   GET /api/products/{id}/jacks   — just the jacks for a product
 *   GET /api/product-types         — reference data (pedal, power_supply, etc.)
 */
@RestController
@RequestMapping("/api")
public class ProductController {

    private final ProductService productService;
    private final ProductTypeRepository productTypeRepository;

    public ProductController(ProductService productService,
                              ProductTypeRepository productTypeRepository) {
        this.productService = productService;
        this.productTypeRepository = productTypeRepository;
    }

    @GetMapping("/products")
    public List<ProductSummaryDto> getAllProducts(
            @RequestParam(required = false) Integer typeId) {
        return productService.findAll(typeId);
    }

    @GetMapping("/products/{id}")
    public ResponseEntity<ProductDetailDto> getProductById(@PathVariable Integer id) {
        return productService.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/products/{id}/jacks")
    public List<JackDto> getProductJacks(@PathVariable Integer id) {
        return productService.findJacksByProductId(id);
    }

    @GetMapping("/product-types")
    public List<ProductType> getProductTypes() {
        return productTypeRepository.findAll();
    }
}
