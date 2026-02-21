# Data Provenance: `product_sources` Table

## Context

The database stores gear specifications but has no systematic record of where each data point came from. The existing `data_reliability` column on `products` is a single blunt rating for the entire product, and the `notes` field is unstructured. As the project grows toward crowdsourced data — where multiple users and even manufacturers might submit values for the same fields — we need per-field, per-source provenance tracking.

This plan adds a `product_sources` table that records, for each populated field on each product, which source provided the data, what value was observed, and how reliable that source is. This enables per-field reliability auditing, discrepancy detection between sources, and a foundation for future crowdsourced data workflows.

---

## Schema

```sql
CREATE TABLE product_sources (
    id              INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    product_id      INTEGER NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    jack_id         INTEGER REFERENCES jacks(id) ON DELETE CASCADE,
    table_name      TEXT NOT NULL CHECK (table_name IN (
        'products', 'pedal_details', 'power_supply_details',
        'pedalboard_details', 'midi_controller_details',
        'utility_details', 'plug_details', 'jacks'
    )),
    field_name      TEXT NOT NULL,
    value_recorded  TEXT,
    source_url      TEXT,
    source_type     TEXT NOT NULL CHECK (source_type IN (
        'manufacturer_website', 'manufacturer_manual', 'manufacturer_direct',
        'major_retailer', 'community_database', 'review_site',
        'user_submission', 'other'
    )),
    reliability     TEXT NOT NULL CHECK (reliability IN ('High', 'Medium', 'Low')),
    accessed_at     DATE NOT NULL DEFAULT CURRENT_DATE,
    notes           TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CHECK (
        (table_name = 'jacks' AND jack_id IS NOT NULL)
        OR (table_name != 'jacks' AND jack_id IS NULL)
    )
);

CREATE INDEX idx_product_sources_product ON product_sources(product_id);
CREATE INDEX idx_product_sources_field ON product_sources(field_name);
CREATE INDEX idx_product_sources_reliability ON product_sources(reliability);
```

**Column explanations:**

| Column | Purpose |
|---|---|
| `product_id` | The product this source entry pertains to. Always populated. |
| `jack_id` | FK to `jacks.id`. Only populated when `table_name = 'jacks'` — identifies which specific jack the source covers. NULL for all other tables (which are 1:1 with products). |
| `table_name` | Which table the field lives in. CHECK-constrained to valid table names. |
| `field_name` | The exact column name from that table (e.g., `current_ma`, `bypass_type`, `weight_grams`). |
| `value_recorded` | The value the source reported, stored as TEXT regardless of the column's actual type. Enables discrepancy detection when multiple sources report different values. |
| `source_url` | URL of the source. Nullable — manufacturer-direct submissions or physical measurements won't have URLs. |
| `source_type` | Categorizes the source. CHECK-constrained. Includes `manufacturer_direct` and `user_submission` for future crowdsourcing. |
| `reliability` | How trustworthy this source is, using the same 'High'/'Medium'/'Low' scale as `data_reliability`. |
| `accessed_at` | When the source was consulted. Defaults to today. |
| `notes` | Per-entry notes — discrepancies, caveats, measurement conditions, etc. |

**Key constraint:** The CHECK ensures `jack_id` is populated if and only if `table_name = 'jacks'`. This prevents ambiguous entries where a jack field isn't tied to a specific jack.

---

## Add `last_researched_at` to `products`

```sql
ALTER TABLE products ADD COLUMN last_researched_at DATE;
```

A convenience column for quickly identifying stale records without querying `product_sources`. Set to the current date whenever a research pass is completed for a product.

---

## Example Queries

```sql
-- Per-field reliability for a specific product
SELECT table_name, field_name, MAX(reliability) AS best_reliability
FROM product_sources
WHERE product_id = 105
GROUP BY table_name, field_name;

-- Products with no High-reliability source for current_ma
SELECT DISTINCT p.id, m.name, p.model
FROM products p
JOIN manufacturers m ON p.manufacturer_id = m.id
LEFT JOIN product_sources ps
    ON ps.product_id = p.id AND ps.field_name = 'current_ma' AND ps.reliability = 'High'
WHERE ps.id IS NULL
  AND EXISTS (SELECT 1 FROM jacks j WHERE j.product_id = p.id AND j.category = 'power');

-- Fields with conflicting values across sources
SELECT product_id, table_name, field_name,
       array_agg(DISTINCT value_recorded) AS conflicting_values,
       count(DISTINCT value_recorded) AS conflict_count
FROM product_sources
GROUP BY product_id, table_name, field_name
HAVING count(DISTINCT value_recorded) > 1;

-- Products never researched or not researched in 6+ months
SELECT id, model, last_researched_at
FROM products
WHERE last_researched_at IS NULL
   OR last_researched_at < CURRENT_DATE - INTERVAL '6 months';
```

---

## Files to Modify

### 1. Schema: `data/schema/gear_postgres.sql`
- Add `CREATE TABLE product_sources` with all columns, constraints, and indexes
- Add `last_researched_at DATE` column to `products` table definition

### 2. Flyway migration: `apps/api/src/main/resources/db/migration/V1__create_product_sources.sql`
- Create the `product_sources` table
- ALTER `products` to add `last_researched_at`
- Flyway is already configured with `baseline-on-migrate: true` in `application.yml`
- This will be the first Flyway migration, and the `db/migration/` directory needs to be created

### 3. Spring Boot entity: `apps/api/src/main/java/com/pedalshootout/api/entity/ProductSource.java`
- New JPA entity mapping to `product_sources`
- `@ManyToOne` relationship to `Product` and nullable `@ManyToOne` to `Jack`
- Follow existing patterns from `Jack.java` (IDENTITY generation, explicit `@Column` names, lazy fetching)

### 4. JPA update: `apps/api/src/main/java/com/pedalshootout/api/entity/Product.java`
- Add `lastResearchedAt` field with `@Column(name = "last_researched_at")`

### 5. CLAUDE.md
- Add `product_sources` to the Schema Overview section
- Add data entry instructions: when researching a product, write `product_sources` entries for each field populated, using the exact column name as `field_name`
- Document `field_name` conventions: use the column name from the table specified in `table_name`
- Document `value_recorded` convention: store the value exactly as the source reports it (e.g., "300mA" or "300"), before any unit conversion
- Add `product_sources` to the Required Fields table

### 6. NOT in scope (intentionally deferred)
- No API endpoints for `product_sources` — this is a data-curation table, not user-facing (yet)
- No DTO or repository for `product_sources` — not needed until API exposure
- No frontend changes
- No backfilling existing products — that's a separate task after the schema is in place

---

## Verification

1. **Flyway migration**: Start the API server (`cd apps/api && ./mvnw spring-boot:run`) — Flyway should apply V1 automatically and Hibernate validate should pass
2. **Schema check**: `psql` into the database and verify the table exists with correct columns and constraints
3. **Test the CHECK constraint**: Insert a row with `table_name = 'jacks'` and `jack_id = NULL` — should fail. Insert with `table_name = 'pedal_details'` and `jack_id = <some id>` — should also fail.
4. **Test CASCADE**: Delete a jack that has `product_sources` rows referencing it — the source rows should be deleted automatically
5. **Compile check**: `cd apps/api && ./mvnw compile -q` — no errors from the new entity
6. **Web build**: `cd apps/web && npm run build` — should be unaffected (no frontend changes)
