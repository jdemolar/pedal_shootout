-- Migration 023: Add Anarchy Audio pedals (Manufacturer ID 17) - Batch 1
-- 7 pedals: Checkmate, Reignmaker, Hereafter, Aftermath, Flutterby, Girt, Deadwoods
--
-- Source: https://anarchyaudioaustralia.com/effects/ (manufacturer website)
-- Individual product page URLs not confirmed — product_page left NULL for all.
-- MSRP converted from AUD to USD cents (1 AUD ≈ 0.70 USD, rate as of 2026-03-22).
--
-- Data decisions:
-- - Hereafter: signal_type='Hybrid', bypass_type='Buffered Bypass', has_spillover=TRUE, has_analog_dry_through=TRUE
-- - Aftermath: signal_type='Hybrid', has_analog_dry_through=TRUE (digital glitch + analog dry path)
-- - Aftermath: effect_type='Other' (glitch modulation/delay hybrid — no closer match in schema)
-- - Flutterby: expression jack added (TRS, confirmed from product listing)
-- - Checkmate: circuit_type='Bluesbreaker' (described as Bluesbreaker/King of Tone style)
-- - Deadwoods: effect_type='Fuzz' (square-wave chainsaw fuzz, HM-2/FY-2 inspired)
-- - Reignmaker: effect_type='Gain' (high-gain distortion with 3-band EQ — not fuzz)
-- - current_ma values from manufacturer website: most <10mA; Reignmaker/Flutterby <20mA; Hereafter/Aftermath 35mA
--
-- Fields not found for all pedals:
-- - width_mm, depth_mm, height_mm: not listed on manufacturer site or any retailer
-- - weight_grams: not listed on manufacturer site or any retailer
-- - instruction_manual: no manual URLs found

BEGIN;

-- ============================================================
-- 1. CHECKMATE
-- ============================================================
INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm,
    weight_grams, msrp_cents,
    product_page,
    description, data_reliability
) VALUES (
    17, 1, 'Checkmate',
    TRUE,
    NULL, NULL, NULL,
    NULL, 16800,
    NULL,
    'Bluesbreaker/King of Tone style overdrive, boost, and distortion pedal. Successor to the Gain of Tones. Hand-wired.',
    'Medium'
);

INSERT INTO pedal_details (
    product_id,
    effect_type, circuit_type, signal_type, bypass_type, mono_stereo,
    battery_capable
) VALUES (
    currval('products_id_seq'),
    'Gain', 'Bluesbreaker', 'Analog', 'True Bypass', 'Mono',
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
    (currval('products_id_seq'), 'pedal_details', 'circuit_type', 'https://anarchyaudioaustralia.com/effects/', 'manufacturer_website', 'High', '2026-03-22'),
    (currval('products_id_seq'), 'pedal_details', 'bypass_type', 'https://anarchyaudioaustralia.com/effects/', 'manufacturer_website', 'High', '2026-03-22');

INSERT INTO product_sources (product_id, table_name, field_name, jack_id, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'jacks', 'current_ma',
     (SELECT id FROM jacks WHERE product_id = currval('products_id_seq') AND category = 'power' AND direction = 'input'),
     'https://anarchyaudioaustralia.com/effects/', 'manufacturer_website', '<10mA', 'High', '2026-03-22');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 2. REIGNMAKER
-- ============================================================
INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm,
    weight_grams, msrp_cents,
    product_page,
    description, data_reliability
) VALUES (
    17, 1, 'Reignmaker',
    TRUE,
    NULL, NULL, NULL,
    NULL, 16100,
    NULL,
    'High-gain distortion pedal with 3-band EQ. Hand-wired analog circuit.',
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
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', 20, 'Center Negative');

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
     'https://anarchyaudioaustralia.com/effects/', 'manufacturer_website', '<20mA', 'High', '2026-03-22');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 3. HEREAFTER
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
    17, 1, 'Hereafter',
    TRUE,
    NULL, NULL, NULL,
    NULL, 20900,
    NULL,
    'Dual-mode ambient delay/chorus pedal with analog dry path and spillover tails. Hybrid signal path.',
    'Medium',
    'Analog dry path with buffered bypass; spillover/trails enabled.'
);

INSERT INTO pedal_details (
    product_id,
    effect_type, signal_type, bypass_type, mono_stereo,
    has_analog_dry_through, has_spillover,
    battery_capable
) VALUES (
    currval('products_id_seq'),
    'Delay', 'Hybrid', 'Buffered Bypass', 'Mono',
    TRUE, TRUE,
    FALSE
);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', 35, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'msrp_cents', 'https://anarchyaudioaustralia.com/effects/', 'manufacturer_website', 'High', '2026-03-22'),
    (currval('products_id_seq'), 'pedal_details', 'effect_type', 'https://anarchyaudioaustralia.com/effects/', 'manufacturer_website', 'High', '2026-03-22'),
    (currval('products_id_seq'), 'pedal_details', 'signal_type', 'https://anarchyaudioaustralia.com/effects/', 'manufacturer_website', 'High', '2026-03-22'),
    (currval('products_id_seq'), 'pedal_details', 'bypass_type', 'https://anarchyaudioaustralia.com/effects/', 'manufacturer_website', 'High', '2026-03-22'),
    (currval('products_id_seq'), 'pedal_details', 'has_analog_dry_through', 'https://anarchyaudioaustralia.com/effects/', 'manufacturer_website', 'High', '2026-03-22'),
    (currval('products_id_seq'), 'pedal_details', 'has_spillover', 'https://anarchyaudioaustralia.com/effects/', 'manufacturer_website', 'High', '2026-03-22');

INSERT INTO product_sources (product_id, table_name, field_name, jack_id, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'jacks', 'current_ma',
     (SELECT id FROM jacks WHERE product_id = currval('products_id_seq') AND category = 'power' AND direction = 'input'),
     'https://anarchyaudioaustralia.com/effects/', 'manufacturer_website', '35mA', 'High', '2026-03-22');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 4. AFTERMATH
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
    17, 1, 'Aftermath',
    TRUE,
    NULL, NULL, NULL,
    NULL, 20200,
    NULL,
    'Glitch modulation/delay hybrid pedal with analog dry path.',
    'Medium',
    'Hybrid signal path with analog dry through and digital glitch processing.'
);

INSERT INTO pedal_details (
    product_id,
    effect_type, signal_type, bypass_type, mono_stereo,
    has_analog_dry_through,
    battery_capable
) VALUES (
    currval('products_id_seq'),
    'Other', 'Hybrid', 'True Bypass', 'Mono',
    TRUE,
    FALSE
);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', 35, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'msrp_cents', 'https://anarchyaudioaustralia.com/effects/', 'manufacturer_website', 'High', '2026-03-22'),
    (currval('products_id_seq'), 'pedal_details', 'effect_type', 'https://anarchyaudioaustralia.com/effects/', 'manufacturer_website', 'High', '2026-03-22'),
    (currval('products_id_seq'), 'pedal_details', 'signal_type', 'https://anarchyaudioaustralia.com/effects/', 'manufacturer_website', 'High', '2026-03-22'),
    (currval('products_id_seq'), 'pedal_details', 'bypass_type', 'https://anarchyaudioaustralia.com/effects/', 'manufacturer_website', 'High', '2026-03-22'),
    (currval('products_id_seq'), 'pedal_details', 'has_analog_dry_through', 'https://anarchyaudioaustralia.com/effects/', 'manufacturer_website', 'High', '2026-03-22');

INSERT INTO product_sources (product_id, table_name, field_name, jack_id, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'jacks', 'current_ma',
     (SELECT id FROM jacks WHERE product_id = currval('products_id_seq') AND category = 'power' AND direction = 'input'),
     'https://anarchyaudioaustralia.com/effects/', 'manufacturer_website', '35mA', 'High', '2026-03-22');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 5. FLUTTERBY
-- ============================================================
INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm,
    weight_grams, msrp_cents,
    product_page,
    description, data_reliability
) VALUES (
    17, 1, 'Flutterby',
    TRUE,
    NULL, NULL, NULL,
    NULL, 15300,
    NULL,
    'Vintage optical tremolo with three waveform options and expression pedal input.',
    'Medium'
);

INSERT INTO pedal_details (
    product_id,
    effect_type, signal_type, bypass_type, mono_stereo,
    battery_capable
) VALUES (
    currval('products_id_seq'),
    'Tremolo', 'Analog', 'True Bypass', 'Mono',
    FALSE
);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', 20, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'expression', 'input', '1/4" TRS');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'msrp_cents', 'https://anarchyaudioaustralia.com/effects/', 'manufacturer_website', 'High', '2026-03-22'),
    (currval('products_id_seq'), 'pedal_details', 'effect_type', 'https://anarchyaudioaustralia.com/effects/', 'manufacturer_website', 'High', '2026-03-22'),
    (currval('products_id_seq'), 'pedal_details', 'bypass_type', 'https://anarchyaudioaustralia.com/effects/', 'manufacturer_website', 'High', '2026-03-22');

INSERT INTO product_sources (product_id, table_name, field_name, jack_id, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'jacks', 'current_ma',
     (SELECT id FROM jacks WHERE product_id = currval('products_id_seq') AND category = 'power' AND direction = 'input'),
     'https://anarchyaudioaustralia.com/effects/', 'manufacturer_website', '<20mA', 'High', '2026-03-22'),
    (currval('products_id_seq'), 'jacks', 'connector_type',
     (SELECT id FROM jacks WHERE product_id = currval('products_id_seq') AND category = 'expression' AND direction = 'input'),
     'https://anarchyaudioaustralia.com/effects/', 'manufacturer_website', 'TRS', 'High', '2026-03-22');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 6. GIRT
-- ============================================================
INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm,
    weight_grams, msrp_cents,
    product_page,
    description, data_reliability
) VALUES (
    17, 1, 'Girt',
    TRUE,
    NULL, NULL, NULL,
    NULL, 16800,
    NULL,
    'Multi-mode pedal covering boost, overdrive, and fuzz voices.',
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
-- 7. DEADWOODS
-- ============================================================
INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm,
    weight_grams, msrp_cents,
    product_page,
    description, data_reliability
) VALUES (
    17, 1, 'Deadwoods',
    TRUE,
    NULL, NULL, NULL,
    NULL, 15400,
    NULL,
    'Square-wave chainsaw fuzz inspired by HM-2 and FY-2 circuits.',
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

COMMIT;
