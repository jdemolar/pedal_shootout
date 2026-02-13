-- Migration 005: Add Goodwood Audio and all utility/accessory products
-- Source: goodwoodaudio.com product pages + ManualsLib (High reliability)
-- Products: 13 standard utilities/accessories (junction boxes, splitters, mixers, etc.)

BEGIN;

-- ============================================================
-- MANUFACTURER
-- ============================================================

INSERT INTO manufacturers (name, country, founded, status, specialty, website, updated_at)
VALUES (
    'Goodwood Audio',
    'Australia',
    '2010',
    'Active',
    'Boutique utility pedals, junction boxes, signal routing, and pedalboard accessories',
    'https://goodwoodaudio.com',
    NOW()
);

-- ============================================================
-- PRODUCTS (Utilities)
-- ============================================================

-- 1. The TX Interfacer
INSERT INTO products (
    manufacturer_id, product_type_id, model, in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    msrp_cents, product_page, instruction_manual, data_reliability
)
SELECT id, 5, 'The TX Interfacer', TRUE,
    73.0, 115.0, 68.0, 325,
    27900,
    'https://goodwoodaudio.com/products/the-tx-interfacer',
    'https://www.manualslib.com/manual/1696395/Goodwood-Audio-The-Tx-Interfacer.html',
    'High'
FROM manufacturers WHERE name = 'Goodwood Audio';

-- 2. The TX Underfacer
INSERT INTO products (
    manufacturer_id, product_type_id, model, in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    msrp_cents, product_page, instruction_manual, data_reliability
)
SELECT id, 5, 'The TX Underfacer', TRUE,
    100.0, 118.0, 34.0, NULL,
    26900,
    'https://goodwoodaudio.com/products/the-tx-underfacer',
    'https://www.manualslib.com/manual/1990047/Goodwood-Audio-The-Tx-Underfacer.html',
    'High'
FROM manufacturers WHERE name = 'Goodwood Audio';

-- 3. Output TX
INSERT INTO products (
    manufacturer_id, product_type_id, model, in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    msrp_cents, product_page, instruction_manual, data_reliability
)
SELECT id, 5, 'Output TX', TRUE,
    66.0, 111.0, 31.0, 200,
    19900,
    'https://goodwoodaudio.com/products/output-tx',
    'https://www.manualslib.com/manual/2494057/Goodwood-Audio-Output-Tx.html',
    'High'
FROM manufacturers WHERE name = 'Goodwood Audio';

-- 4. LongLine
INSERT INTO products (
    manufacturer_id, product_type_id, model, in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    msrp_cents, product_page, instruction_manual, data_reliability
)
SELECT id, 5, 'LongLine', TRUE,
    120.0, 94.0, 34.0, NULL,
    25900,
    'https://goodwoodaudio.com/products/longline',
    'https://www.manualslib.com/manual/3494393/Goodwood-Audio-Longline.html',
    'High'
FROM manufacturers WHERE name = 'Goodwood Audio';

-- 5. RCV (Passive Signal Receiver)
INSERT INTO products (
    manufacturer_id, product_type_id, model, in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    msrp_cents, product_page, instruction_manual, data_reliability
)
SELECT id, 5, 'RCV', TRUE,
    112.0, 61.0, 38.0, NULL,
    11900,
    'https://goodwoodaudio.com/products/rcv',
    NULL,
    'High'
FROM manufacturers WHERE name = 'Goodwood Audio';

-- 6. Isolator TX
INSERT INTO products (
    manufacturer_id, product_type_id, model, in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    msrp_cents, product_page, instruction_manual, data_reliability
)
SELECT id, 5, 'Isolator TX', TRUE,
    66.0, 111.0, 31.0, NULL,
    17500,
    'https://goodwoodaudio.com/products/isolator',
    NULL,
    'High'
FROM manufacturers WHERE name = 'Goodwood Audio';

-- 7. 4-Way Buffered Splitter
INSERT INTO products (
    manufacturer_id, product_type_id, model, in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    msrp_cents, product_page, instruction_manual, data_reliability
)
SELECT id, 5, '4-Way Buffered Splitter', TRUE,
    NULL, NULL, NULL, NULL,
    13900,
    'https://goodwoodaudio.com/products/4-way-buffered-splitter',
    NULL,
    'High'
FROM manufacturers WHERE name = 'Goodwood Audio';

-- 8. 3 Channel Stereo Line Mixer
INSERT INTO products (
    manufacturer_id, product_type_id, model, in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    msrp_cents, product_page, instruction_manual, data_reliability
)
SELECT id, 5, '3 Channel Stereo Line Mixer', TRUE,
    119.0, 94.0, 56.0, NULL,
    44900,
    'https://goodwoodaudio.com/products/3-channel-stereo-line-mixer',
    NULL,
    'High'
FROM manufacturers WHERE name = 'Goodwood Audio';

-- 9. Audition (FX Loop Auditioner)
INSERT INTO products (
    manufacturer_id, product_type_id, model, in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    msrp_cents, product_page, instruction_manual, data_reliability
)
SELECT id, 5, 'Audition', TRUE,
    66.0, 111.0, 31.0, 185,
    7500,
    'https://goodwoodaudio.com/products/audition',
    'https://www.manualslib.com/manual/1637499/Goodwood-Audio-Audition.html',
    'High'
FROM manufacturers WHERE name = 'Goodwood Audio';

-- 10. Buzzkill (Transformer Isolation)
INSERT INTO products (
    manufacturer_id, product_type_id, model, in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    msrp_cents, product_page, instruction_manual, data_reliability
)
SELECT id, 5, 'Buzzkill', TRUE,
    NULL, NULL, NULL, NULL,
    9900,
    'https://goodwoodaudio.com/products/buzzkill-transformer-isolation',
    NULL,
    'High'
FROM manufacturers WHERE name = 'Goodwood Audio';

-- 11. Bass Interfacer
INSERT INTO products (
    manufacturer_id, product_type_id, model, in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    msrp_cents, product_page, instruction_manual, data_reliability
)
SELECT id, 5, 'Bass Interfacer', TRUE,
    73.0, 115.0, 68.0, 335,
    26900,
    'https://goodwoodaudio.com/',
    'https://www.manualslib.com/manual/1432556/Goodwood-Audio-Bass-Interfacer.html',
    'High'
FROM manufacturers WHERE name = 'Goodwood Audio';

-- 12. RMT (Remote Control Switch)
INSERT INTO products (
    manufacturer_id, product_type_id, model, in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    msrp_cents, product_page, instruction_manual, data_reliability
)
SELECT id, 5, 'RMT', TRUE,
    96.0, 39.0, 44.0, 95,
    NULL,
    'https://goodwoodaudio.com/products/rmt',
    'https://www.manualslib.com/manual/2494059/Goodwood-Audio-Rmt.html',
    'High'
FROM manufacturers WHERE name = 'Goodwood Audio';

-- 13. LIFT Adjustable Pedal Riser (12")
INSERT INTO products (
    manufacturer_id, product_type_id, model, in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    msrp_cents, product_page, instruction_manual, data_reliability
)
SELECT id, 5, 'LIFT 12"', TRUE,
    304.8, 127.0, 25.4, NULL,
    13900,
    'https://goodwoodaudio.com/products/lift',
    NULL,
    'High'
FROM manufacturers WHERE name = 'Goodwood Audio';

-- ============================================================
-- UTILITY DETAILS
-- ============================================================

-- The TX Interfacer
INSERT INTO utility_details (
    product_id, utility_type,
    is_active, signal_type, bypass_type,
    has_ground_lift
)
SELECT p.id, 'Junction Box',
    TRUE, 'Analog', 'Buffered',
    TRUE
FROM products p
JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'Goodwood Audio' AND p.model = 'The TX Interfacer';

-- The TX Underfacer
INSERT INTO utility_details (
    product_id, utility_type,
    is_active, signal_type, bypass_type,
    has_ground_lift
)
SELECT p.id, 'Junction Box',
    TRUE, 'Analog', 'Buffered',
    TRUE
FROM products p
JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'Goodwood Audio' AND p.model = 'The TX Underfacer';

-- Output TX
INSERT INTO utility_details (
    product_id, utility_type,
    is_active, signal_type, bypass_type,
    has_ground_lift
)
SELECT p.id, 'Junction Box',
    TRUE, 'Analog', 'Buffered',
    TRUE
FROM products p
JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'Goodwood Audio' AND p.model = 'Output TX';

-- LongLine
INSERT INTO utility_details (
    product_id, utility_type,
    is_active, signal_type, bypass_type,
    has_ground_lift
)
SELECT p.id, 'Line Level Converter',
    TRUE, 'Analog', NULL,
    TRUE
FROM products p
JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'Goodwood Audio' AND p.model = 'LongLine';

-- RCV
INSERT INTO utility_details (
    product_id, utility_type,
    is_active, signal_type, bypass_type,
    has_ground_lift
)
SELECT p.id, 'Line Level Converter',
    FALSE, 'Analog', NULL,
    FALSE
FROM products p
JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'Goodwood Audio' AND p.model = 'RCV';

-- Isolator TX
INSERT INTO utility_details (
    product_id, utility_type,
    is_active, signal_type, bypass_type,
    has_ground_lift
)
SELECT p.id, 'Splitter',
    TRUE, 'Analog', 'Buffered',
    TRUE
FROM products p
JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'Goodwood Audio' AND p.model = 'Isolator TX';

-- 4-Way Buffered Splitter
INSERT INTO utility_details (
    product_id, utility_type,
    is_active, signal_type, bypass_type,
    has_ground_lift
)
SELECT p.id, 'Splitter',
    TRUE, 'Analog', 'Buffered',
    FALSE
FROM products p
JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'Goodwood Audio' AND p.model = '4-Way Buffered Splitter';

-- 3 Channel Stereo Line Mixer
INSERT INTO utility_details (
    product_id, utility_type,
    is_active, signal_type, bypass_type,
    has_ground_lift
)
SELECT p.id, 'Mixer',
    TRUE, 'Analog', NULL,
    FALSE
FROM products p
JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'Goodwood Audio' AND p.model = '3 Channel Stereo Line Mixer';

-- Audition
INSERT INTO utility_details (
    product_id, utility_type,
    is_active, signal_type, bypass_type,
    has_ground_lift
)
SELECT p.id, 'A/B Box',
    TRUE, 'Analog', NULL,
    FALSE
FROM products p
JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'Goodwood Audio' AND p.model = 'Audition';

-- Buzzkill
INSERT INTO utility_details (
    product_id, utility_type,
    is_active, signal_type, bypass_type,
    has_ground_lift
)
SELECT p.id, 'Impedance Matcher',
    FALSE, 'Analog', NULL,
    TRUE
FROM products p
JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'Goodwood Audio' AND p.model = 'Buzzkill';

-- Bass Interfacer
INSERT INTO utility_details (
    product_id, utility_type,
    is_active, signal_type, bypass_type,
    has_ground_lift
)
SELECT p.id, 'Junction Box',
    TRUE, 'Analog', 'Buffered',
    TRUE
FROM products p
JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'Goodwood Audio' AND p.model = 'Bass Interfacer';

-- RMT
INSERT INTO utility_details (
    product_id, utility_type,
    is_active, signal_type, bypass_type,
    has_ground_lift
)
SELECT p.id, 'Mute Switch',
    FALSE, 'Analog', NULL,
    FALSE
FROM products p
JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'Goodwood Audio' AND p.model = 'RMT';

-- LIFT 12"
INSERT INTO utility_details (
    product_id, utility_type,
    is_active, signal_type, bypass_type,
    has_ground_lift
)
SELECT p.id, 'Other',
    FALSE, NULL, NULL,
    FALSE
FROM products p
JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'Goodwood Audio' AND p.model = 'LIFT 12"';

COMMIT;
