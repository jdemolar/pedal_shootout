package com.pedalshootout.api.controller;

import com.pedalshootout.api.dto.ManufacturerDto;
import com.pedalshootout.api.dto.ProductSummaryDto;
import com.pedalshootout.api.service.ManufacturerService;
import com.pedalshootout.api.service.ProductService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * REST controller for manufacturer endpoints.
 *
 * @RestController combines two annotations:
 *   - @Controller: Marks this as a Spring MVC controller (handles HTTP requests)
 *   - @ResponseBody: Return values are serialized to JSON automatically
 *     (without this, Spring would try to find an HTML template)
 *
 * @RequestMapping("/api/manufacturers") sets the base URL path for all methods
 * in this class. Each method then adds to this base path.
 *
 * This is like an Express router:
 *   const router = express.Router();
 *   router.get('/', getAllManufacturers);
 *   router.get('/:id', getManufacturerById);
 *   app.use('/api/manufacturers', router);
 */
@RestController
@RequestMapping("/api/manufacturers")
public class ManufacturerController {

    private final ManufacturerService manufacturerService;
    private final ProductService productService;

    public ManufacturerController(ManufacturerService manufacturerService,
                                   ProductService productService) {
        this.manufacturerService = manufacturerService;
        this.productService = productService;
    }

    /**
     * GET /api/manufacturers
     * Optional query param: ?search=boss
     *
     * @RequestParam binds a URL query parameter to a method argument.
     * "required = false" means the param is optional (like ?search= in Express).
     */
    @GetMapping
    public List<ManufacturerDto> getAll(@RequestParam(required = false) String search) {
        return manufacturerService.findAll(search);
    }

    /**
     * GET /api/manufacturers/{id}
     *
     * @PathVariable extracts the {id} from the URL path — like req.params.id in Express.
     *
     * ResponseEntity lets us control the HTTP status code:
     *   - 200 OK with the manufacturer data if found
     *   - 404 Not Found if the ID doesn't exist
     */
    @GetMapping("/{id}")
    public ResponseEntity<ManufacturerDto> getById(@PathVariable Integer id) {
        return manufacturerService.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    /**
     * GET /api/manufacturers/{id}/products
     * Returns all products made by this manufacturer.
     */
    @GetMapping("/{id}/products")
    public ResponseEntity<List<ProductSummaryDto>> getProducts(@PathVariable Integer id) {
        List<ProductSummaryDto> products = productService.findByManufacturerId(id);
        if (products.isEmpty()) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok(products);
    }
}
