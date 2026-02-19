-- Add data provenance tracking: product_sources table and last_researched_at column

-- Convenience column for quickly identifying stale records
ALTER TABLE products ADD COLUMN last_researched_at DATE;

-- Per-field, per-source provenance tracking
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
