-- =============================================================================
-- INSERT TEMPLATE: PEDALBOARD
-- =============================================================================
-- Product type ID: 3
--
-- Usage: Fill in all {{placeholder}} values with researched data.
-- For unknown/unfound values, use NULL (not 0 or empty string).
-- Wrap the entire insert in a transaction so all tables succeed or fail together.
--
-- Note: Pedalboards typically have NO jacks unless they have an integrated
-- patch bay. The products table dimensions are the EXTERNAL dimensions;
-- usable_width_mm/usable_depth_mm in pedalboard_details are the INTERNAL
-- mounting surface dimensions.
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
    3,                              -- product_type_id = pedalboard
    '{{model}}',
    {{color_options}},
    {{in_production}},
    {{width_mm}},                   -- EXTERNAL width
    {{depth_mm}},                   -- EXTERNAL depth
    {{height_mm}},                  -- EXTERNAL height
    {{weight_grams}},
    {{msrp_cents}},
    {{product_page}},
    {{instruction_manual}},
    {{description}},
    {{tags}},
    '{{data_reliability}}',
    {{notes}}
);

-- ─── PEDALBOARD DETAILS ─────────────────────────────────────────────────────
INSERT INTO pedalboard_details (
    product_id,
    -- Surface
    usable_width_mm, usable_depth_mm, surface_type, rail_spacing_mm,
    -- Construction
    material, tilt_angle_degrees,
    -- Clearance
    under_clearance_mm,
    -- Second tier
    has_second_tier, tier2_usable_width_mm, tier2_usable_depth_mm,
    tier2_under_clearance_mm, tier2_height_mm,
    -- Integrated features
    has_integrated_power, integrated_power_product_id, has_integrated_patch_bay,
    -- Case
    case_included, case_type,
    -- Load
    max_load_kg
) VALUES (
    currval('products_id_seq'),
    -- Surface
    {{usable_width_mm}},            -- INTERNAL mounting width or NULL
    {{usable_depth_mm}},            -- INTERNAL mounting depth or NULL
    '{{surface_type}}',             -- 'Loop Velcro', 'Hook Velcro', 'Bare Rails', 'Perforated', 'Solid Flat', 'Other'
    {{rail_spacing_mm}},            -- Gap between rails (edge to edge) or NULL
    -- Construction
    {{material}},                   -- e.g., 'Aluminum', 'Steel', 'Wood' or NULL
    {{tilt_angle_degrees}},         -- Tilt angle or NULL
    -- Clearance
    {{under_clearance_mm}},         -- Space below for power supply or NULL
    -- Second tier
    {{has_second_tier}},            -- TRUE/FALSE (default FALSE)
    {{tier2_usable_width_mm}},      -- or NULL
    {{tier2_usable_depth_mm}},      -- or NULL
    {{tier2_under_clearance_mm}},   -- or NULL
    {{tier2_height_mm}},            -- or NULL
    -- Integrated features
    {{has_integrated_power}},       -- TRUE/FALSE (default FALSE)
    {{integrated_power_product_id}},-- FK to products.id or NULL
    {{has_integrated_patch_bay}},   -- TRUE/FALSE (default FALSE)
    -- Case
    {{case_included}},              -- TRUE/FALSE (default FALSE)
    {{case_type}},                  -- 'Soft Case', 'Hard Case', 'Flight Case', 'Gig Bag', 'None' or NULL
    -- Load
    {{max_load_kg}}                 -- Max weight capacity or NULL
);

-- ─── JACKS (only if integrated patch bay) ───────────────────────────────────

-- Uncomment if the pedalboard has an integrated patch bay / junction box:
-- INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, position)
-- VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS', 'Input', 'back');
-- INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, position)
-- VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Output', 'back');

-- ─── PRODUCT COMPATIBILITY (uncomment if applicable) ────────────────────────
-- Pedalboards commonly have mounting compatibility with specific power supplies:
-- INSERT INTO product_compatibility (product_a_id, product_b_id, compatibility_type, notes, source, verified)
-- VALUES (
--     currval('products_id_seq'),
--     {{power_supply_product_id}},
--     'Mounting',
--     '{{compatibility_notes}}',   -- e.g., 'Fits under board with included bracket'
--     '{{compatibility_source}}',
--     {{verified}}
-- );

COMMIT;
