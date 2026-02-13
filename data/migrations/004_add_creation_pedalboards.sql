-- Migration 004: Add Creation Music Company and all pedalboard models
-- Source: creationmusiccompany.com product pages (High reliability)
-- Products: Aero series (6), Elevation series (5), The Board (1)

BEGIN;

-- ============================================================
-- MANUFACTURER
-- ============================================================

INSERT INTO manufacturers (name, country, founded, status, specialty, website, updated_at)
VALUES (
    'Creation Music Company',
    'USA',
    '2009',
    'Active',
    'Lightweight aluminum pedalboards and riser systems',
    'https://creationmusiccompany.com',
    NOW()
);

-- ============================================================
-- PRODUCTS (Pedalboards)
-- ============================================================

-- AERO SERIES (flat, minimal profile)

-- 1. Aero 18 LITE
INSERT INTO products (
    manufacturer_id, product_type_id, model, in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    msrp_cents, product_page, instruction_manual, data_reliability
)
SELECT id, 3, 'Aero 18 LITE', TRUE,
    457.0, 178.0, 30.0, 272,
    13999,
    'https://creationmusiccompany.com/products/v3-aero-18-lite-pedalboard',
    NULL,
    'High'
FROM manufacturers WHERE name = 'Creation Music Company';

-- 2. Aero 18
INSERT INTO products (
    manufacturer_id, product_type_id, model, in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    msrp_cents, product_page, instruction_manual, data_reliability
)
SELECT id, 3, 'Aero 18', TRUE,
    457.0, 318.0, 30.0, 363,
    16999,
    'https://creationmusiccompany.com/products/aero-18-pedalboard',
    NULL,
    'High'
FROM manufacturers WHERE name = 'Creation Music Company';

-- 3. Aero 24
INSERT INTO products (
    manufacturer_id, product_type_id, model, in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    msrp_cents, product_page, instruction_manual, data_reliability
)
SELECT id, 3, 'Aero 24', TRUE,
    610.0, 318.0, 30.0, 589,
    18999,
    'https://creationmusiccompany.com/products/aero-24-pedalboard',
    NULL,
    'High'
FROM manufacturers WHERE name = 'Creation Music Company';

-- 4. Aero 24+
INSERT INTO products (
    manufacturer_id, product_type_id, model, in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    msrp_cents, product_page, instruction_manual, data_reliability
)
SELECT id, 3, 'Aero 24+', TRUE,
    610.0, 406.0, 30.0, 589,
    20999,
    'https://creationmusiccompany.com/products/aero-24-pedalboard-1',
    NULL,
    'High'
FROM manufacturers WHERE name = 'Creation Music Company';

-- 5. Aero 28
INSERT INTO products (
    manufacturer_id, product_type_id, model, in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    msrp_cents, product_page, instruction_manual, data_reliability
)
SELECT id, 3, 'Aero 28', TRUE,
    711.0, 356.0, 30.0, 589,
    21999,
    'https://creationmusiccompany.com/products/aero-28-pedalboard-1',
    NULL,
    'High'
FROM manufacturers WHERE name = 'Creation Music Company';

-- 6. Aero 32+
INSERT INTO products (
    manufacturer_id, product_type_id, model, in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    msrp_cents, product_page, instruction_manual, data_reliability
)
SELECT id, 3, 'Aero 32+', TRUE,
    813.0, 406.0, 30.0, 907,
    23999,
    'https://creationmusiccompany.com/products/aero-32-pedalboard',
    NULL,
    'High'
FROM manufacturers WHERE name = 'Creation Music Company';

-- ELEVATION SERIES (angled, with underside space)

-- 7. Elevation 18
INSERT INTO products (
    manufacturer_id, product_type_id, model, in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    msrp_cents, product_page, instruction_manual, data_reliability
)
SELECT id, 3, 'Elevation 18', TRUE,
    457.0, 318.0, 98.0, 907,
    26999,
    'https://creationmusiccompany.com/products/elevation-18',
    NULL,
    'High'
FROM manufacturers WHERE name = 'Creation Music Company';

-- 8. Elevation 24
INSERT INTO products (
    manufacturer_id, product_type_id, model, in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    msrp_cents, product_page, instruction_manual, data_reliability
)
SELECT id, 3, 'Elevation 24', TRUE,
    610.0, 318.0, 98.0, 907,
    29999,
    'https://creationmusiccompany.com/products/v3-elevation-24-pedalboard',
    NULL,
    'High'
FROM manufacturers WHERE name = 'Creation Music Company';

-- 9. Elevation 24+
INSERT INTO products (
    manufacturer_id, product_type_id, model, in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    msrp_cents, product_page, instruction_manual, data_reliability
)
SELECT id, 3, 'Elevation 24+', TRUE,
    610.0, 406.0, 98.0, 907,
    31999,
    'https://creationmusiccompany.com/products/v3-elevation-24-pedalboard-1',
    NULL,
    'High'
FROM manufacturers WHERE name = 'Creation Music Company';

-- 10. Elevation 28
INSERT INTO products (
    manufacturer_id, product_type_id, model, in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    msrp_cents, product_page, instruction_manual, data_reliability
)
SELECT id, 3, 'Elevation 28', TRUE,
    711.0, 356.0, 98.0, 1089,
    32999,
    'https://creationmusiccompany.com/products/v3-elevation-28-pedalboard',
    NULL,
    'High'
FROM manufacturers WHERE name = 'Creation Music Company';

-- 11. Elevation 32+
INSERT INTO products (
    manufacturer_id, product_type_id, model, in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    msrp_cents, product_page, instruction_manual, data_reliability
)
SELECT id, 3, 'Elevation 32+', TRUE,
    813.0, 406.0, 98.0, 1451,
    36999,
    'https://creationmusiccompany.com/products/v3-elevation-32-pedalboard',
    NULL,
    'High'
FROM manufacturers WHERE name = 'Creation Music Company';

-- BUDGET LINE

-- 12. The Board (Standard Sizes - note: available in 6 sizes)
INSERT INTO products (
    manufacturer_id, product_type_id, model, in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    msrp_cents, product_page, instruction_manual, data_reliability
)
SELECT id, 3, 'The Board (Standard Sizes)', TRUE,
    NULL, NULL, 19.0, NULL,
    4999,
    'https://creationmusiccompany.com/products/the-board-standard-sized',
    NULL,
    'High'
FROM manufacturers WHERE name = 'Creation Music Company';

-- ============================================================
-- PEDALBOARD DETAILS
-- ============================================================

-- Aero 18 LITE
INSERT INTO pedalboard_details (
    product_id,
    usable_width_mm, usable_depth_mm,
    surface_type, material,
    has_second_tier,
    has_integrated_power, has_integrated_patch_bay,
    case_included
)
SELECT p.id,
    457.0, 178.0,
    'Solid Flat', 'Aluminum',
    FALSE,
    FALSE, FALSE,
    FALSE
FROM products p
JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'Creation Music Company' AND p.model = 'Aero 18 LITE';

-- Aero 18
INSERT INTO pedalboard_details (
    product_id,
    usable_width_mm, usable_depth_mm,
    surface_type, material,
    has_second_tier,
    has_integrated_power, has_integrated_patch_bay,
    case_included
)
SELECT p.id,
    457.0, 318.0,
    'Solid Flat', 'Aluminum',
    FALSE,
    FALSE, FALSE,
    FALSE
FROM products p
JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'Creation Music Company' AND p.model = 'Aero 18';

-- Aero 24
INSERT INTO pedalboard_details (
    product_id,
    usable_width_mm, usable_depth_mm,
    surface_type, material,
    has_second_tier,
    has_integrated_power, has_integrated_patch_bay,
    case_included
)
SELECT p.id,
    610.0, 318.0,
    'Solid Flat', 'Aluminum',
    FALSE,
    FALSE, FALSE,
    FALSE
FROM products p
JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'Creation Music Company' AND p.model = 'Aero 24';

-- Aero 24+
INSERT INTO pedalboard_details (
    product_id,
    usable_width_mm, usable_depth_mm,
    surface_type, material,
    has_second_tier,
    has_integrated_power, has_integrated_patch_bay,
    case_included
)
SELECT p.id,
    610.0, 406.0,
    'Solid Flat', 'Aluminum',
    FALSE,
    FALSE, FALSE,
    FALSE
FROM products p
JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'Creation Music Company' AND p.model = 'Aero 24+';

-- Aero 28
INSERT INTO pedalboard_details (
    product_id,
    usable_width_mm, usable_depth_mm,
    surface_type, material,
    has_second_tier,
    has_integrated_power, has_integrated_patch_bay,
    case_included
)
SELECT p.id,
    711.0, 356.0,
    'Solid Flat', 'Aluminum',
    FALSE,
    FALSE, FALSE,
    FALSE
FROM products p
JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'Creation Music Company' AND p.model = 'Aero 28';

-- Aero 32+
INSERT INTO pedalboard_details (
    product_id,
    usable_width_mm, usable_depth_mm,
    surface_type, material,
    has_second_tier,
    has_integrated_power, has_integrated_patch_bay,
    case_included
)
SELECT p.id,
    813.0, 406.0,
    'Solid Flat', 'Aluminum',
    FALSE,
    FALSE, FALSE,
    FALSE
FROM products p
JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'Creation Music Company' AND p.model = 'Aero 32+';

-- Elevation 18
INSERT INTO pedalboard_details (
    product_id,
    usable_width_mm, usable_depth_mm,
    surface_type, material,
    has_second_tier,
    has_integrated_power, has_integrated_patch_bay,
    case_included
)
SELECT p.id,
    457.0, 318.0,
    'Solid Flat', 'Aluminum',
    FALSE,
    FALSE, FALSE,
    FALSE
FROM products p
JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'Creation Music Company' AND p.model = 'Elevation 18';

-- Elevation 24
INSERT INTO pedalboard_details (
    product_id,
    usable_width_mm, usable_depth_mm,
    surface_type, material,
    has_second_tier,
    has_integrated_power, has_integrated_patch_bay,
    case_included
)
SELECT p.id,
    610.0, 318.0,
    'Solid Flat', 'Aluminum',
    FALSE,
    FALSE, FALSE,
    FALSE
FROM products p
JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'Creation Music Company' AND p.model = 'Elevation 24';

-- Elevation 24+
INSERT INTO pedalboard_details (
    product_id,
    usable_width_mm, usable_depth_mm,
    surface_type, material,
    has_second_tier,
    has_integrated_power, has_integrated_patch_bay,
    case_included
)
SELECT p.id,
    610.0, 406.0,
    'Solid Flat', 'Aluminum',
    FALSE,
    FALSE, FALSE,
    FALSE
FROM products p
JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'Creation Music Company' AND p.model = 'Elevation 24+';

-- Elevation 28
INSERT INTO pedalboard_details (
    product_id,
    usable_width_mm, usable_depth_mm,
    surface_type, material,
    has_second_tier,
    has_integrated_power, has_integrated_patch_bay,
    case_included
)
SELECT p.id,
    711.0, 356.0,
    'Solid Flat', 'Aluminum',
    FALSE,
    FALSE, FALSE,
    FALSE
FROM products p
JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'Creation Music Company' AND p.model = 'Elevation 28';

-- Elevation 32+
INSERT INTO pedalboard_details (
    product_id,
    usable_width_mm, usable_depth_mm,
    surface_type, material,
    has_second_tier,
    has_integrated_power, has_integrated_patch_bay,
    case_included
)
SELECT p.id,
    813.0, 406.0,
    'Solid Flat', 'Aluminum',
    FALSE,
    FALSE, FALSE,
    FALSE
FROM products p
JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'Creation Music Company' AND p.model = 'Elevation 32+';

-- The Board (Standard Sizes)
INSERT INTO pedalboard_details (
    product_id,
    usable_width_mm, usable_depth_mm,
    surface_type, material,
    has_second_tier,
    has_integrated_power, has_integrated_patch_bay,
    case_included
)
SELECT p.id,
    NULL, NULL,
    'Solid Flat', 'Phenolic birch plywood',
    FALSE,
    FALSE, FALSE,
    FALSE
FROM products p
JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'Creation Music Company' AND p.model = 'The Board (Standard Sizes)';

COMMIT;
