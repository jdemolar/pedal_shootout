-- Migration: Import pedals from legacy pedals.db to new gear.db schema
-- Run with: sqlite3 data/local/gear.db < data/migrations/001_migrate_pedals_from_legacy.sql
--
-- Prerequisites:
--   - gear.db created from data/schema/gear.sql
--   - manufacturers already migrated to gear.db
--   - Attach pedals.db to import from

PRAGMA foreign_keys = ON;

-- Attach the legacy database
ATTACH DATABASE 'raw_data/pedals.db' AS legacy;

-- ============================================================================
-- Step 1: Insert into products table
-- ============================================================================

INSERT INTO products (
    manufacturer_id,
    product_type_id,
    model,
    color_options,
    in_production,
    -- Dimensions will be parsed separately
    width_mm,
    depth_mm,
    height_mm,
    msrp_cents,
    product_page,
    instruction_manual,
    data_reliability,
    notes,
    created_at,
    updated_at
)
SELECT
    p.manufacturer_id,
    1,  -- product_type_id = 1 (pedal)
    p.model,
    p.color_options,
    p.in_production,
    -- Parse dimensions: format is typically "W x D x H" in inches
    -- Convert to mm (multiply by 25.4)
    CASE
        WHEN p.dimensions IS NOT NULL AND p.dimensions LIKE '%x%x%'
        THEN ROUND(CAST(TRIM(SUBSTR(p.dimensions, 1, INSTR(p.dimensions, 'x') - 1)) AS REAL) * 25.4, 1)
        ELSE NULL
    END,
    CASE
        WHEN p.dimensions IS NOT NULL AND p.dimensions LIKE '%x%x%'
        THEN ROUND(CAST(TRIM(SUBSTR(
            SUBSTR(p.dimensions, INSTR(p.dimensions, 'x') + 1),
            1,
            INSTR(SUBSTR(p.dimensions, INSTR(p.dimensions, 'x') + 1), 'x') - 1
        )) AS REAL) * 25.4, 1)
        ELSE NULL
    END,
    CASE
        WHEN p.dimensions IS NOT NULL AND p.dimensions LIKE '%x%x%'
        THEN ROUND(CAST(TRIM(REPLACE(REPLACE(SUBSTR(
            SUBSTR(p.dimensions, INSTR(p.dimensions, 'x') + 1),
            INSTR(SUBSTR(p.dimensions, INSTR(p.dimensions, 'x') + 1), 'x') + 1
        ), '"', ''), ' (approx.)', '')) AS REAL) * 25.4, 1)
        ELSE NULL
    END,
    p.msrp_cents,
    p.product_page,
    p.instruction_manual,
    p.data_reliability,
    -- Store original dimensions string in notes for reference
    CASE WHEN p.dimensions IS NOT NULL THEN 'Original dimensions: ' || p.dimensions ELSE NULL END,
    datetime('now'),
    datetime('now')
FROM legacy.pedals p;

-- ============================================================================
-- Step 2: Insert into pedal_details table
-- ============================================================================

INSERT INTO pedal_details (
    product_id,
    effect_type,
    bypass_type,
    mono_stereo,
    midi_capable
)
SELECT
    pr.id,
    -- Map effect_type (Modulation needs to be mapped to specific type or Other)
    CASE p.effect_type
        WHEN 'Modulation' THEN 'Other'  -- Will need manual review to categorize
        ELSE p.effect_type
    END,
    p.bypass_type,
    CASE
        WHEN p.stereo_capable = 1 THEN 'Stereo In/Out'
        ELSE 'Mono'
    END,
    p.midi_capable
FROM legacy.pedals p
JOIN products pr ON pr.model = p.model
    AND pr.manufacturer_id = p.manufacturer_id
    AND pr.product_type_id = 1;

-- ============================================================================
-- Step 3: Create jacks for Audio Inputs
-- ============================================================================

-- Simple mono input
INSERT INTO jacks (product_id, category, direction, jack_name, connector_type)
SELECT
    pr.id,
    'Audio Input',
    'Input',
    'Input',
    '1/4" TS'
FROM legacy.pedals p
JOIN products pr ON pr.model = p.model
    AND pr.manufacturer_id = p.manufacturer_id
    AND pr.product_type_id = 1
WHERE p.inputs LIKE '%Mono%' OR p.inputs LIKE '%mono%' OR p.inputs LIKE '%1/4"%';

-- ============================================================================
-- Step 4: Create jacks for Audio Outputs
-- ============================================================================

-- Simple mono output
INSERT INTO jacks (product_id, category, direction, jack_name, connector_type)
SELECT
    pr.id,
    'Audio Output',
    'Output',
    'Output',
    '1/4" TS'
FROM legacy.pedals p
JOIN products pr ON pr.model = p.model
    AND pr.manufacturer_id = p.manufacturer_id
    AND pr.product_type_id = 1
WHERE p.outputs LIKE '%Mono%' OR p.outputs LIKE '%mono%' OR p.outputs LIKE '%1/4"%';

-- XLR output (if present)
INSERT INTO jacks (product_id, category, direction, jack_name, connector_type)
SELECT
    pr.id,
    'Audio Output',
    'Output',
    'XLR Out',
    'XLR'
FROM legacy.pedals p
JOIN products pr ON pr.model = p.model
    AND pr.manufacturer_id = p.manufacturer_id
    AND pr.product_type_id = 1
WHERE p.outputs LIKE '%XLR%';

-- ============================================================================
-- Step 5: Create jacks for Power Input
-- ============================================================================

INSERT INTO jacks (
    product_id,
    category,
    direction,
    jack_name,
    connector_type,
    voltage,
    current_ma,
    polarity
)
SELECT
    pr.id,
    'Power Input',
    'Input',
    'Power',
    CASE p.power_plug_size
        WHEN '2.1mm' THEN '2.1mm barrel'
        WHEN '2.5mm' THEN '2.5mm barrel'
        ELSE COALESCE(p.power_plug_size, '2.1mm barrel')
    END,
    p.power_voltage,
    p.power_current_ma,
    p.power_polarity
FROM legacy.pedals p
JOIN products pr ON pr.model = p.model
    AND pr.manufacturer_id = p.manufacturer_id
    AND pr.product_type_id = 1
WHERE p.power_voltage IS NOT NULL OR p.power_plug_size IS NOT NULL;

-- ============================================================================
-- Step 6: Create jacks for Expression Input (if present)
-- ============================================================================

INSERT INTO jacks (product_id, category, direction, jack_name, connector_type)
SELECT
    pr.id,
    'Expression',
    'Input',
    'Expression',
    '1/4" TRS'
FROM legacy.pedals p
JOIN products pr ON pr.model = p.model
    AND pr.manufacturer_id = p.manufacturer_id
    AND pr.product_type_id = 1
WHERE p.expression_input > 0 OR p.inputs LIKE '%Expression%';

-- ============================================================================
-- Cleanup
-- ============================================================================

DETACH DATABASE legacy;

-- Verify migration
SELECT 'Products migrated: ' || COUNT(*) FROM products WHERE product_type_id = 1;
SELECT 'Pedal details created: ' || COUNT(*) FROM pedal_details;
SELECT 'Jacks created: ' || COUNT(*) FROM jacks;
