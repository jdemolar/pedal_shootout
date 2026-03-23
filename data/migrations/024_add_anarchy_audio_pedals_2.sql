-- Migration 024: Add Anarchy Audio pedals (Manufacturer ID 17) - Batch 2
-- 7 pedals: Baa Bzz, Chaos Star, Gold Class, F-Bomb, GE Powered Device,
--           Gain of Tones (discontinued), Spring Driver (discontinued)
--
-- Source: https://anarchyaudioaustralia.com/effects/ (manufacturer website)
-- Individual product page URLs not confirmed — product_page left NULL for all.
-- MSRP converted from AUD to USD cents (1 AUD ≈ 0.70 USD, rate as of 2026-03-22).
--
-- Data decisions:
-- - Baa Bzz: effect_type='Fuzz' (Roland Bee Baa-inspired high-gain fuzz)
-- - Chaos Star: effect_type='Fuzz' (self-oscillating synth-style fuzz)
-- - F-Bomb: effect_type='Gain' (compact overdrive/boost — not fuzz)
-- - GE Powered Device: effect_type='Gain' (limited edition germanium booster, only 5 units)
-- - Gold Class: effect_type='Gain' (germanium-powered overdrive/boost/tone shaper)
-- - Gain of Tones: in_production=FALSE (discontinued 2016–2022, replaced by Checkmate)
-- - Spring Driver: in_production=FALSE (discontinued analog spring reverb)
-- - Gold Class, F-Bomb, GE Powered Device: msrp_cents=NULL (no price found in any source)
-- - GE Powered Device: in_production=TRUE (listed on site as current, despite limited run)
--
-- Fields not found for all pedals:
-- - width_mm, depth_mm, height_mm: not listed on manufacturer site or any retailer
-- - weight_grams: not listed on manufacturer site or any retailer
-- - instruction_manual: no manual URLs found
-- - msrp_cents for Gold Class, F-Bomb, GE Powered Device: no price found

BEGIN;

-- ============================================================
-- 1. BAA BZZ
-- ============================================================
INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm,
    weight_grams, msrp_cents,
    product_page,
    description, data_reliability
) VALUES (
    17, 1, 'Baa Bzz',
    TRUE,
    NULL, NULL, NULL,
    NULL, 13900,
    NULL,
    'High-gain fuzz inspired by the Roland Bee Baa.',
    'Medium'
);

INSERT INTO pedal_details (
    product_id,
    effect_type, signal_type, bypass_type, mono_stereo,
    battery_capable
) VALUES (
    currval('products_id_seq'),
    'Fuzz', 'Analog', 'True Bypass', 'Mono',
    FALSE
);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', 10, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'msrp_cents', 'https://anarchyaudioaustralia.com/effects/', 'manufacturer_website', 'High', '2026-03-22'),
    (currval('products_id_seq'), 'pedal_details', 'effect_type', 'https://anarchyaudioaustralia.com/effects/', 'manufacturer_website', 'High', '2026-03-22'),
    (currval('products_id_seq'), 'pedal_details', 'bypass_type', 'https://anarchyaudioaustralia.com/effects/', 'manufacturer_website', 'High', '2026-03-22');

INSERT INTO product_sources (product_id, table_name, field_name, jack_id, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'jacks', 'current_ma',
     (SELECT id FROM jacks WHERE product_id = currval('products_id_seq') AND category = 'power' AND direction = 'input'),
     'https://anarchyaudioaustralia.com/effects/', 'manufacturer_website', '<10mA', 'High', '2026-03-22');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 2. CHAOS STAR
-- ============================================================
INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm,
    weight_grams, msrp_cents,
    product_page,
    description, data_reliability
) VALUES (
    17, 1, 'Chaos Star',
    TRUE,
    NULL, NULL, NULL,
    NULL, 13300,
    NULL,
    'Self-oscillating synth-style fuzz pedal.',
    'Medium'
);

INSERT INTO pedal_details (
    product_id,
    effect_type, signal_type, bypass_type, mono_stereo,
    battery_capable
) VALUES (
    currval('products_id_seq'),
    'Fuzz', 'Analog', 'True Bypass', 'Mono',
    FALSE
);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', 10, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'msrp_cents', 'https://anarchyaudioaustralia.com/effects/', 'manufacturer_website', 'High', '2026-03-22'),
    (currval('products_id_seq'), 'pedal_details', 'effect_type', 'https://anarchyaudioaustralia.com/effects/', 'manufacturer_website', 'High', '2026-03-22'),
    (currval('products_id_seq'), 'pedal_details', 'bypass_type', 'https://anarchyaudioaustralia.com/effects/', 'manufacturer_website', 'High', '2026-03-22');

INSERT INTO product_sources (product_id, table_name, field_name, jack_id, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'jacks', 'current_ma',
     (SELECT id FROM jacks WHERE product_id = currval('products_id_seq') AND category = 'power' AND direction = 'input'),
     'https://anarchyaudioaustralia.com/effects/', 'manufacturer_website', '<10mA', 'High', '2026-03-22');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 3. GOLD CLASS
-- ============================================================
INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm,
    weight_grams, msrp_cents,
    product_page,
    description, data_reliability
) VALUES (
    17, 1, 'Gold Class',
    TRUE,
    NULL, NULL, NULL,
    NULL, NULL,
    NULL,
    'Germanium-powered overdrive, boost, and tone shaper.',
    'Medium'
);

INSERT INTO pedal_details (
    product_id,
    effect_type, signal_type, bypass_type, mono_stereo,
    battery_capable
) VALUES (
    currval('products_id_seq'),
    'Gain', 'Analog', 'True Bypass', 'Mono',
    FALSE
);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', 10, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'pedal_details', 'effect_type', 'https://anarchyaudioaustralia.com/effects/', 'manufacturer_website', 'High', '2026-03-22'),
    (currval('products_id_seq'), 'pedal_details', 'bypass_type', 'https://anarchyaudioaustralia.com/effects/', 'manufacturer_website', 'High', '2026-03-22');

INSERT INTO product_sources (product_id, table_name, field_name, jack_id, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'jacks', 'current_ma',
     (SELECT id FROM jacks WHERE product_id = currval('products_id_seq') AND category = 'power' AND direction = 'input'),
     'https://anarchyaudioaustralia.com/effects/', 'manufacturer_website', '<10mA', 'High', '2026-03-22');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 4. F-BOMB
-- ============================================================
INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm,
    weight_grams, msrp_cents,
    product_page,
    description, data_reliability
) VALUES (
    17, 1, 'F-Bomb',
    TRUE,
    NULL, NULL, NULL,
    NULL, NULL,
    NULL,
    'Compact overdrive and boost pedal.',
    'Medium'
);

INSERT INTO pedal_details (
    product_id,
    effect_type, signal_type, bypass_type, mono_stereo,
    battery_capable
) VALUES (
    currval('products_id_seq'),
    'Gain', 'Analog', 'True Bypass', 'Mono',
    FALSE
);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', 10, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'pedal_details', 'effect_type', 'https://anarchyaudioaustralia.com/effects/', 'manufacturer_website', 'High', '2026-03-22'),
    (currval('products_id_seq'), 'pedal_details', 'bypass_type', 'https://anarchyaudioaustralia.com/effects/', 'manufacturer_website', 'High', '2026-03-22');

INSERT INTO product_sources (product_id, table_name, field_name, jack_id, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'jacks', 'current_ma',
     (SELECT id FROM jacks WHERE product_id = currval('products_id_seq') AND category = 'power' AND direction = 'input'),
     'https://anarchyaudioaustralia.com/effects/', 'manufacturer_website', '<10mA', 'High', '2026-03-22');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 5. GE POWERED DEVICE
-- ============================================================
INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm,
    weight_grams, msrp_cents,
    product_page,
    description, data_reliability,
    notes
) VALUES (
    17, 1, 'GE Powered Device',
    TRUE,
    NULL, NULL, NULL,
    NULL, NULL,
    NULL,
    'Limited edition germanium booster. Only 5 units produced.',
    'Medium',
    'Extremely limited run (5 units). Listed as current on manufacturer site as of 2026-03-22 but likely sold out.'
);

INSERT INTO pedal_details (
    product_id,
    effect_type, signal_type, bypass_type, mono_stereo,
    battery_capable
) VALUES (
    currval('products_id_seq'),
    'Gain', 'Analog', 'True Bypass', 'Mono',
    FALSE
);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', 10, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'pedal_details', 'effect_type', 'https://anarchyaudioaustralia.com/effects/', 'manufacturer_website', 'High', '2026-03-22'),
    (currval('products_id_seq'), 'pedal_details', 'bypass_type', 'https://anarchyaudioaustralia.com/effects/', 'manufacturer_website', 'High', '2026-03-22');

INSERT INTO product_sources (product_id, table_name, field_name, jack_id, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'jacks', 'current_ma',
     (SELECT id FROM jacks WHERE product_id = currval('products_id_seq') AND category = 'power' AND direction = 'input'),
     'https://anarchyaudioaustralia.com/effects/', 'manufacturer_website', '<10mA', 'High', '2026-03-22');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 6. GAIN OF TONES (DISCONTINUED)
-- ============================================================
INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm,
    weight_grams, msrp_cents,
    product_page,
    description, data_reliability
) VALUES (
    17, 1, 'Gain of Tones',
    FALSE,
    NULL, NULL, NULL,
    NULL, NULL,
    NULL,
    'Discontinued overdrive pedal (2016–2022). Replaced by the Checkmate.',
    'Low'
);

INSERT INTO pedal_details (
    product_id,
    effect_type, signal_type, bypass_type, mono_stereo,
    battery_capable
) VALUES (
    currval('products_id_seq'),
    'Gain', 'Analog', 'True Bypass', 'Mono',
    FALSE
);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', NULL, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'pedal_details', 'effect_type', 'https://anarchyaudioaustralia.com/effects/', 'manufacturer_website', 'Medium', '2026-03-22');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 7. SPRING DRIVER (DISCONTINUED)
-- ============================================================
INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm,
    weight_grams, msrp_cents,
    product_page,
    description, data_reliability
) VALUES (
    17, 1, 'Spring Driver',
    FALSE,
    NULL, NULL, NULL,
    NULL, NULL,
    NULL,
    'Discontinued analog spring reverb pedal.',
    'Low'
);

INSERT INTO pedal_details (
    product_id,
    effect_type, signal_type, bypass_type, mono_stereo,
    battery_capable
) VALUES (
    currval('products_id_seq'),
    'Reverb', 'Analog', 'True Bypass', 'Mono',
    FALSE
);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', NULL, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'pedal_details', 'effect_type', 'https://anarchyaudioaustralia.com/effects/', 'manufacturer_website', 'Medium', '2026-03-22');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

COMMIT;
