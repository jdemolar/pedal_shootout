# Fix N+1 Query Performance (Refactors #2 & #3)

## Context

The Spring Boot API has two N+1 query patterns flagged as Critical in `docs/plans/refactoring-opportunities.md`:

- **#2 — ManufacturerService:** `findAll()` fetches all manufacturers (1 query), then calls `productRepository.countByManufacturerId()` per manufacturer (N queries). With 232 manufacturers, that's 233 queries instead of 2.

- **#3 — Jack queries in PedalService & DetailTypeService:** Every `findAll*()` method fetches detail rows (1 query), then calls `jackRepository.findByProductId()` per product (N queries). PedalService does this for 104 pedals; DetailTypeService does it for power supplies, pedalboards, MIDI controllers, utilities, and plugs.

The `findById()` methods also call these per-item, but since they only fetch one item, they do 2 queries total — not an N+1 problem. Those stay unchanged.

## Approach

Add batch query methods to the repositories, then update the services to pre-fetch in bulk and look up from a Map.

## Files to Modify

### Refactor #2 — Manufacturer product counts

#### 1. `apps/api/src/main/java/com/pedalshootout/api/repository/ProductRepository.java`

Add a JPQL query that returns grouped counts:

```java
@Query("SELECT p.manufacturer.id, COUNT(p) FROM Product p GROUP BY p.manufacturer.id")
List<Object[]> countGroupedByManufacturerId();
```

#### 2. `apps/api/src/main/java/com/pedalshootout/api/service/ManufacturerService.java`

Update `findAll()` to batch-fetch counts:

```java
public List<ManufacturerDto> findAll(String search) {
    List<Manufacturer> manufacturers;
    if (search != null && !search.isBlank()) {
        manufacturers = manufacturerRepository.findByNameContainingIgnoreCase(search);
    } else {
        manufacturers = manufacturerRepository.findAll();
    }

    // Batch: 1 query for all counts instead of N
    Map<Integer, Long> countsByManufacturer = productRepository.countGroupedByManufacturerId()
            .stream()
            .collect(Collectors.toMap(
                    row -> (Integer) row[0],
                    row -> (Long) row[1]
            ));

    return manufacturers.stream()
            .map(m -> ManufacturerDto.from(m, countsByManufacturer.getOrDefault(m.getId(), 0L)))
            .toList();
}
```

`findById()` stays unchanged — it only does 2 queries total.

---

### Refactor #3 — Batch jack fetching

#### 3. `apps/api/src/main/java/com/pedalshootout/api/repository/JackRepository.java`

Add a batch query:

```java
List<Jack> findByProductIdIn(List<Integer> productIds);
```

Spring Data JPA derives this automatically as `SELECT * FROM jacks WHERE product_id IN (...)`.

#### 4. `apps/api/src/main/java/com/pedalshootout/api/service/DetailTypeService.java`

Add a `jacksForAll()` batch method alongside the existing `jacksFor()`:

```java
private Map<Integer, List<JackDto>> jacksForAll(List<Integer> productIds) {
    return jackRepository.findByProductIdIn(productIds).stream()
            .collect(Collectors.groupingBy(
                    Jack::getProductId,
                    Collectors.mapping(JackDto::from, Collectors.toList())
            ));
}
```

Update each `findAll*()` method to:
1. Collect product IDs from the detail list
2. Call `jacksForAll()` once
3. Look up per-product jacks from the Map

Keep `jacksFor()` for the `findById()` methods — they fetch a single product and don't have an N+1 problem.

The 5 `findAll*()` methods to update: `findAllPowerSupplies`, `findAllPedalboards`, `findAllMidiControllers`, `findAllUtilities`, `findAllPlugs`.

#### 5. `apps/api/src/main/java/com/pedalshootout/api/service/PedalService.java`

Same pattern — extract product IDs, batch-fetch jacks, look up from Map:

```java
public List<PedalDto> findAll(String effectType) {
    List<PedalDetail> pedals;
    if (effectType != null && !effectType.isBlank()) {
        pedals = pedalDetailRepository.findByEffectType(effectType);
    } else {
        pedals = pedalDetailRepository.findAll();
    }

    List<Integer> productIds = pedals.stream().map(PedalDetail::getProductId).toList();
    Map<Integer, List<JackDto>> jacksByProduct = jacksForAll(productIds);

    return pedals.stream()
            .map(pd -> PedalDto.from(pd.getProduct(), pd,
                    jacksByProduct.getOrDefault(pd.getProductId(), List.of())))
            .toList();
}
```

`findById()` stays unchanged.

---

### Tests

The only existing API test is the context-loads smoke test — no service-level tests exist to update or break.

## Verification

1. `cd apps/api && ./mvnw compile -q` — no compilation errors
2. `cd apps/api && ./mvnw test` — smoke test passes
3. Start the API (`./mvnw spring-boot:run`) and manually verify:
   - `GET http://localhost:8081/api/manufacturers` returns correct `productCount` values
   - `GET http://localhost:8081/api/pedals` returns pedals with correct `jacks` arrays
   - `GET http://localhost:8081/api/power-supplies` returns power supplies with correct `jacks` arrays
4. Check off items #2 and #3 in `docs/plans/refactoring-opportunities.md`
5. Move this plan to `docs/plans/completed/`
