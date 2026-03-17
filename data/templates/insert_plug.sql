-- =============================================================================
-- INSERT TEMPLATE: PLUG
-- =============================================================================
-- Product type ID: 6
--
-- Usage: Fill in all {{placeholder}} values with researched data.
-- For unknown/unfound values, use NULL (not 0 or empty string).
-- Wrap the entire insert in a transaction so all tables succeed or fail together.
--
-- Plugs are physical cable connectors (patch, instrument, power, MIDI, USB) used
-- for layout planning — specifically to model how much space a plug occupies on
-- a pedalboard. They do NOT have jacks (they ARE a connector, not a product with
-- ports). Dimensional data is the primary purpose of this product type.
--
-- Key measurements:
--   plug_width_mm  — width of plug housing, parallel to the pedal face
--   plug_depth_mm  — how far the plug protrudes from the jack (perpendicular to pedal face)
--   plug_height_mm — height of plug housing, vertical
--
-- Before running: verify the manufacturer exists with:
--   SELECT id, name FROM manufacturers WHERE name ILIKE '%{{manufacturer_name}}%';
-- =============================================================================

BEGIN;

-- ─── MANUFACTURER (uncomment if new) ────────────────────────────────────────
-- INSERT INTO manufacturers (name, country, founded, status, specialty, website, notes)
-- VALUES (
--     '{{manufacturer_name}}',
--     '{{country}}',
--     '{{founded}}',
--     '{{status}}',                -- 'Active', 'Defunct', 'Discontinued', 'Unknown'
--     '{{specialty}}',
--     '{{website}}',
--     '{{notes}}'
-- );

-- ─── PRODUCT ────────────────────────────────────────────────────────────────
INSERT INTO products (
    manufacturer_id, product_type_id, model,
    color_options, in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    msrp_cents, product_page, instruction_manual,
    description, tags, data_reliability, notes
) VALUES (
    {{manufacturer_id}},            -- FK to manufacturers.id
    6,                              -- product_type_id = plug
    '{{model}}',                    -- e.g., 'Solderless Right Angle 1/4" TS'
    {{color_options}},              -- e.g., 'Black, Silver' or NULL
    {{in_production}},              -- TRUE or FALSE
    {{width_mm}},                   -- overall plug+cable-exit width in mm or NULL
    {{depth_mm}},                   -- overall depth from jack face in mm or NULL
    {{height_mm}},                  -- overall height in mm or NULL
    {{weight_grams}},               -- grams or NULL (often not published)
    {{msrp_cents}},                 -- cents or NULL — price per plug, not per pack
    {{product_page}},               -- URL or NULL
    {{instruction_manual}},         -- URL or NULL (rarely exists for plugs)
    {{description}},                -- e.g., 'Low-profile right-angle patch cable plug' or NULL
    {{tags}},                       -- e.g., 'solderless, right-angle, patch' or NULL
    '{{data_reliability}}',         -- 'High', 'Medium', or 'Low'
    {{notes}}                       -- Internal data curation notes or NULL
);

-- ─── PLUG DETAILS ───────────────────────────────────────────────────────────
INSERT INTO plug_details (
    product_id,
    plug_type, connector_type,
    is_right_angle, is_pancake,
    plug_width_mm, plug_depth_mm, plug_height_mm,
    cable_exit_direction,
    is_solderless, housing_material, has_locking_mechanism
) VALUES (
    currval('products_id_seq'),
    '{{plug_type}}',                -- REQUIRED: 'patch', 'instrument', 'power', 'midi', 'usb'
    '{{connector_type}}',           -- REQUIRED: use canonical values where applicable (see below)
                                    -- Audio/instrument: '1/4" TS', '1/4" TRS', 'XLR', '3.5mm TS', '3.5mm TRS', '3.5mm TRRS'
                                    -- Power: '2.1mm barrel', '2.5mm barrel', 'EIAJ-05', 'IEC C14'
                                    -- MIDI: '5-pin DIN', '7-pin DIN', '3.5mm TRS'
                                    -- USB: 'USB-A', 'USB-B', 'USB-C', 'USB Mini', 'USB Micro'
    {{is_right_angle}},             -- TRUE if plug exits at 90° angle to jack
    {{is_pancake}},                 -- TRUE if flat/low-profile design
    {{plug_width_mm}},              -- width of plug housing in mm or NULL
    {{plug_depth_mm}},              -- how far plug protrudes from jack in mm or NULL
    {{plug_height_mm}},             -- height of plug housing in mm or NULL
    {{cable_exit_direction}},       -- 'straight', 'up', 'down', 'side' or NULL
    {{is_solderless}},              -- TRUE for solderless systems (Evidence Audio, Lava, etc.)
    {{housing_material}},           -- 'Metal', 'Plastic' or NULL
    {{has_locking_mechanism}}       -- TRUE if has twist-lock or other secure connection
);

-- ─── PRODUCT COMPATIBILITY (uncomment if applicable) ────────────────────────
-- Use this to record known compatibility with specific cable systems or products.
-- INSERT INTO product_compatibility (product_a_id, product_b_id, compatibility_type, notes, source, verified)
-- VALUES (
--     currval('products_id_seq'),
--     {{related_product_id}},
--     '{{compatibility_type}}',    -- 'Accessory', 'Replacement'
--     '{{compatibility_notes}}',
--     '{{compatibility_source}}',
--     {{verified}}
-- );

-- ─── UPDATE RESEARCH TIMESTAMP ───────────────────────────────────────────────
UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

COMMIT;
