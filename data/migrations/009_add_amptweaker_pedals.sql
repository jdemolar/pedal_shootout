-- =============================================================================
-- MIGRATION 009: Add Amptweaker pedals
-- Manufacturer: Amptweaker (id = 13)
-- Pedals: Tight Drive, Tight Metal, Tight Rock,
--         Tight Metal Pro II, Fat Metal Pro II, Big Rock Pro II,
--         Defizzerator
-- Sources: Full Compass (major_retailer), Amptweaker website (manufacturer_website),
--          Reverb (major_retailer), Premier Guitar (review_site)
-- Researched: 2026-03-21
-- =============================================================================


-- ─── 1. TIGHT DRIVE ──────────────────────────────────────────────────────────
-- Overdrive with SideTrak effects loop; 9-18V operation
-- Dimensions from Full Compass: 2.5 × 4.5 × 1.5 in (W × D × H)

BEGIN;

INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    msrp_cents, product_page, instruction_manual,
    data_reliability
) VALUES (
    13, 1, 'Tight Drive',
    TRUE,
    63.5, 114.3, 38.1, 454,
    18900, 'https://amptweaker.com/product/tight-drive/', 'https://www.fullcompass.com/common/files/90007-TightDriveUserGuide.pdf',
    'Medium'
);

INSERT INTO pedal_details (
    product_id,
    effect_type, signal_type, bypass_type, mono_stereo,
    battery_capable, fx_loop_count
) VALUES (
    currval('products_id_seq'),
    'Gain', 'Analog', 'True Bypass', 'Mono',
    FALSE, 1
);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9-18V', 13, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS', 'Input');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Output');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, group_id)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'FX Loop Send', 'loop_1');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, group_id)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS', 'FX Loop Return', 'loop_1');

INSERT INTO product_sources (product_id, table_name, field_name, value_recorded, source_type, source_url, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'width_mm',          '2.5 x 4.5 x 1.5 in',                                                          'major_retailer', 'https://www.fullcompass.com/', 'Medium', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'depth_mm',          '2.5 x 4.5 x 1.5 in',                                                          'major_retailer', 'https://www.fullcompass.com/', 'Medium', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'height_mm',         '2.5 x 4.5 x 1.5 in',                                                          'major_retailer', 'https://www.fullcompass.com/', 'Medium', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'weight_grams',      '1 lbs',                                                                        'major_retailer', 'https://www.fullcompass.com/', 'Medium', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'msrp_cents',        '$189.00',                                                                      'major_retailer', 'https://reverb.com/',          'Medium', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'product_page',      'https://amptweaker.com/product/tight-drive/',                                  'manufacturer_website', 'https://amptweaker.com/', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'instruction_manual','https://www.fullcompass.com/common/files/90007-TightDriveUserGuide.pdf',       'major_retailer', 'https://www.fullcompass.com/', 'Medium', '2026-03-21');

INSERT INTO product_sources (product_id, table_name, field_name, value_recorded, source_type, source_url, reliability, accessed_at, jack_id)
VALUES (
    currval('products_id_seq'), 'jacks', 'current_ma', '13mA @ 9V', 'major_retailer', 'https://www.fullcompass.com/', 'Medium', '2026-03-21',
    (SELECT id FROM jacks WHERE product_id = currval('products_id_seq') AND category = 'power' AND direction = 'input')
);

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

COMMIT;


-- ─── 2. TIGHT METAL ──────────────────────────────────────────────────────────
-- High-gain distortion with noise gate and SideTrak effects loop; 9-18V
-- Dimensions from Full Compass: 2.7 × 4.65 × 2 in (W × D × H)
-- FX loop inferred from product family (JR models explicitly remove it)

BEGIN;

INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    msrp_cents, product_page, instruction_manual,
    data_reliability,
    notes
) VALUES (
    13, 1, 'Tight Metal',
    TRUE,
    68.6, 118.1, 50.8, 454,
    18000, 'https://amptweaker.com/product/tight-metal/', 'https://www.fullcompass.com/common/files/90005-TightMetalUserGuide.pdf',
    'Medium',
    'FX loop inferred from product family pattern; JR models explicitly remove the SideTrak loop'
);

INSERT INTO pedal_details (
    product_id,
    effect_type, signal_type, bypass_type, mono_stereo,
    battery_capable, fx_loop_count
) VALUES (
    currval('products_id_seq'),
    'Gain', 'Analog', 'True Bypass', 'Mono',
    FALSE, 1
);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9-18V', 13, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS', 'Input');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Output');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, group_id)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'FX Loop Send', 'loop_1');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, group_id)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS', 'FX Loop Return', 'loop_1');

INSERT INTO product_sources (product_id, table_name, field_name, value_recorded, source_type, source_url, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'width_mm',          '2.7 x 4.65 x 2 in',                                                           'major_retailer', 'https://www.fullcompass.com/', 'Medium', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'depth_mm',          '2.7 x 4.65 x 2 in',                                                           'major_retailer', 'https://www.fullcompass.com/', 'Medium', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'height_mm',         '2.7 x 4.65 x 2 in',                                                           'major_retailer', 'https://www.fullcompass.com/', 'Medium', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'weight_grams',      '1 lbs',                                                                        'major_retailer', 'https://www.fullcompass.com/', 'Medium', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'msrp_cents',        '$180.00',                                                                      'major_retailer', 'https://reverb.com/',          'Medium', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'product_page',      'https://amptweaker.com/product/tight-metal/',                                  'manufacturer_website', 'https://amptweaker.com/', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'instruction_manual','https://www.fullcompass.com/common/files/90005-TightMetalUserGuide.pdf',       'major_retailer', 'https://www.fullcompass.com/', 'Medium', '2026-03-21');

INSERT INTO product_sources (product_id, table_name, field_name, value_recorded, source_type, source_url, reliability, accessed_at, jack_id)
VALUES (
    currval('products_id_seq'), 'jacks', 'current_ma', '13mA @ 9V', 'major_retailer', 'https://www.fullcompass.com/', 'Medium', '2026-03-21',
    (SELECT id FROM jacks WHERE product_id = currval('products_id_seq') AND category = 'power' AND direction = 'input')
);

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

COMMIT;


-- ─── 3. TIGHT ROCK ───────────────────────────────────────────────────────────
-- Mid-gain distortion with noise gate and SideTrak effects loop; 9-18V
-- Dimensions same enclosure as Tight Metal per Full Compass

BEGIN;

INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    msrp_cents, product_page,
    data_reliability,
    notes
) VALUES (
    13, 1, 'Tight Rock',
    TRUE,
    68.6, 118.1, 50.8, 454,
    18900, 'https://amptweaker.com/product/tight-rock/',
    'Medium',
    'FX loop inferred from product family pattern; JR models explicitly remove the SideTrak loop. Shares enclosure with Tight Metal.'
);

INSERT INTO pedal_details (
    product_id,
    effect_type, signal_type, bypass_type, mono_stereo,
    battery_capable, fx_loop_count
) VALUES (
    currval('products_id_seq'),
    'Gain', 'Analog', 'True Bypass', 'Mono',
    FALSE, 1
);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9-18V', 13, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS', 'Input');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Output');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, group_id)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'FX Loop Send', 'loop_1');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, group_id)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS', 'FX Loop Return', 'loop_1');

INSERT INTO product_sources (product_id, table_name, field_name, value_recorded, source_type, source_url, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'width_mm',     '2.7 x 4.65 x 2 in', 'major_retailer', 'https://www.fullcompass.com/', 'Medium', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'depth_mm',     '2.7 x 4.65 x 2 in', 'major_retailer', 'https://www.fullcompass.com/', 'Medium', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'height_mm',    '2.7 x 4.65 x 2 in', 'major_retailer', 'https://www.fullcompass.com/', 'Medium', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'weight_grams', '1 lbs',              'major_retailer', 'https://www.fullcompass.com/', 'Medium', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'msrp_cents',   '$189.00',            'major_retailer', 'https://reverb.com/',          'Medium', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'product_page', 'https://amptweaker.com/product/tight-rock/', 'manufacturer_website', 'https://amptweaker.com/', 'High', '2026-03-21');

INSERT INTO product_sources (product_id, table_name, field_name, value_recorded, source_type, source_url, reliability, accessed_at, jack_id)
VALUES (
    currval('products_id_seq'), 'jacks', 'current_ma', '13mA @ 9V', 'major_retailer', 'https://www.fullcompass.com/', 'Medium', '2026-03-21',
    (SELECT id FROM jacks WHERE product_id = currval('products_id_seq') AND category = 'power' AND direction = 'input')
);

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

COMMIT;


-- ─── 4. TIGHT METAL PRO II ───────────────────────────────────────────────────
-- High-gain distortion; large format with DI output, cab sim, headphone out,
-- 3 effects loops (pre/post switchable), DepthFinder, DeFizzerator built in
-- Dimensions from Full Compass/zZounds: 5.63 × 5 × 2.13 in (W × D × H)
-- MSRP: not reliably sourced — retailer prices varied significantly

BEGIN;

INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    msrp_cents, product_page,
    data_reliability
) VALUES (
    13, 1, 'Tight Metal Pro II',
    TRUE,
    143.0, 127.0, 54.1, 1361,
    NULL, 'https://amptweaker.com/product/tight-metal-pro-ii/',
    'Medium'
);

INSERT INTO pedal_details (
    product_id,
    effect_type, signal_type, bypass_type, mono_stereo,
    battery_capable, fx_loop_count
) VALUES (
    currval('products_id_seq'),
    'Gain', 'Analog', 'True Bypass', 'Mono',
    FALSE, 3
);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9-18V', 39, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS', 'Input');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Output');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', 'XLR', 'DI Out');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TRS', 'Headphone Out');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, group_id)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'FX Loop 1 Send', 'loop_1');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, group_id)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS', 'FX Loop 1 Return', 'loop_1');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, group_id)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'FX Loop 2 Send', 'loop_2');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, group_id)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS', 'FX Loop 2 Return', 'loop_2');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, group_id)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'FX Loop 3 Send', 'loop_3');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, group_id)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS', 'FX Loop 3 Return', 'loop_3');

INSERT INTO product_sources (product_id, table_name, field_name, value_recorded, source_type, source_url, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'width_mm',     '5.63 x 5 x 2.13 in', 'major_retailer', 'https://www.fullcompass.com/', 'Medium', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'depth_mm',     '5.63 x 5 x 2.13 in', 'major_retailer', 'https://www.fullcompass.com/', 'Medium', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'height_mm',    '5.63 x 5 x 2.13 in', 'major_retailer', 'https://www.fullcompass.com/', 'Medium', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'weight_grams', '3 lbs',               'major_retailer', 'https://www.fullcompass.com/', 'Medium', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'product_page', 'https://amptweaker.com/product/tight-metal-pro-ii/', 'manufacturer_website', 'https://amptweaker.com/', 'High', '2026-03-21');

INSERT INTO product_sources (product_id, table_name, field_name, value_recorded, source_type, source_url, reliability, accessed_at, jack_id)
VALUES (
    currval('products_id_seq'), 'jacks', 'current_ma', '39mA @ 9V', 'major_retailer', 'https://www.fullcompass.com/', 'Medium', '2026-03-21',
    (SELECT id FROM jacks WHERE product_id = currval('products_id_seq') AND category = 'power' AND direction = 'input')
);

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

COMMIT;


-- ─── 5. FAT METAL PRO II ─────────────────────────────────────────────────────
-- High-gain distortion; same large format enclosure as Tight Metal Pro II
-- Features: DI output, cab sim, headphone out, 3 effects loops, pre/post boost loops

BEGIN;

INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    msrp_cents, product_page,
    data_reliability
) VALUES (
    13, 1, 'Fat Metal Pro II',
    TRUE,
    143.0, 127.0, 54.1, 1361,
    29900, 'https://amptweaker.com/product/fat-metal-pro-ii/',
    'Medium'
);

INSERT INTO pedal_details (
    product_id,
    effect_type, signal_type, bypass_type, mono_stereo,
    battery_capable, fx_loop_count
) VALUES (
    currval('products_id_seq'),
    'Gain', 'Analog', 'True Bypass', 'Mono',
    FALSE, 3
);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9-18V', 39, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS', 'Input');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Output');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', 'XLR', 'DI Out');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TRS', 'Headphone Out');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, group_id)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'FX Loop 1 Send', 'loop_1');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, group_id)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS', 'FX Loop 1 Return', 'loop_1');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, group_id)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'FX Loop 2 Send', 'loop_2');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, group_id)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS', 'FX Loop 2 Return', 'loop_2');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, group_id)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'FX Loop 3 Send', 'loop_3');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, group_id)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS', 'FX Loop 3 Return', 'loop_3');

INSERT INTO product_sources (product_id, table_name, field_name, value_recorded, source_type, source_url, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'width_mm',     '5.63 x 5 x 2.13 in', 'major_retailer', 'https://www.zzounds.com/', 'Medium', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'depth_mm',     '5.63 x 5 x 2.13 in', 'major_retailer', 'https://www.zzounds.com/', 'Medium', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'height_mm',    '5.63 x 5 x 2.13 in', 'major_retailer', 'https://www.zzounds.com/', 'Medium', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'weight_grams', '3 lbs',               'major_retailer', 'https://www.zzounds.com/', 'Medium', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'msrp_cents',   '$299.00',             'major_retailer', 'https://www.zzounds.com/', 'Medium', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'product_page', 'https://amptweaker.com/product/fat-metal-pro-ii/', 'manufacturer_website', 'https://amptweaker.com/', 'High', '2026-03-21');

INSERT INTO product_sources (product_id, table_name, field_name, value_recorded, source_type, source_url, reliability, accessed_at, jack_id)
VALUES (
    currval('products_id_seq'), 'jacks', 'current_ma', '39mA @ 9V', 'major_retailer', 'https://www.zzounds.com/', 'Medium', '2026-03-21',
    (SELECT id FROM jacks WHERE product_id = currval('products_id_seq') AND category = 'power' AND direction = 'input')
);

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

COMMIT;


-- ─── 6. BIG ROCK PRO II ──────────────────────────────────────────────────────
-- Overdrive/distortion; same large format enclosure as other Pro II models
-- Features: DI output, cab sim, headphone out, 3 effects loops, Smooth/Fat switches

BEGIN;

INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    msrp_cents, product_page,
    data_reliability
) VALUES (
    13, 1, 'Big Rock Pro II',
    TRUE,
    143.0, 127.0, 54.1, 1361,
    29900, 'https://amptweaker.com/product/big-rock-pro-ii/',
    'Medium'
);

INSERT INTO pedal_details (
    product_id,
    effect_type, signal_type, bypass_type, mono_stereo,
    battery_capable, fx_loop_count
) VALUES (
    currval('products_id_seq'),
    'Gain', 'Analog', 'True Bypass', 'Mono',
    FALSE, 3
);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9-18V', 39, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS', 'Input');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Output');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', 'XLR', 'DI Out');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TRS', 'Headphone Out');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, group_id)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'FX Loop 1 Send', 'loop_1');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, group_id)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS', 'FX Loop 1 Return', 'loop_1');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, group_id)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'FX Loop 2 Send', 'loop_2');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, group_id)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS', 'FX Loop 2 Return', 'loop_2');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, group_id)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'FX Loop 3 Send', 'loop_3');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, group_id)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS', 'FX Loop 3 Return', 'loop_3');

INSERT INTO product_sources (product_id, table_name, field_name, value_recorded, source_type, source_url, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'width_mm',     '5.63 x 5 x 2.13 in', 'major_retailer', 'https://www.fullcompass.com/', 'Medium', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'depth_mm',     '5.63 x 5 x 2.13 in', 'major_retailer', 'https://www.fullcompass.com/', 'Medium', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'height_mm',    '5.63 x 5 x 2.13 in', 'major_retailer', 'https://www.fullcompass.com/', 'Medium', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'weight_grams', '3 lbs',               'major_retailer', 'https://www.fullcompass.com/', 'Medium', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'msrp_cents',   '$299.00',             'major_retailer', 'https://reverb.com/',          'Medium', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'product_page', 'https://amptweaker.com/product/big-rock-pro-ii/', 'manufacturer_website', 'https://amptweaker.com/', 'High', '2026-03-21');

INSERT INTO product_sources (product_id, table_name, field_name, value_recorded, source_type, source_url, reliability, accessed_at, jack_id)
VALUES (
    currval('products_id_seq'), 'jacks', 'current_ma', '39mA @ 9V', 'major_retailer', 'https://www.fullcompass.com/', 'Medium', '2026-03-21',
    (SELECT id FROM jacks WHERE product_id = currval('products_id_seq') AND category = 'power' AND direction = 'input')
);

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

COMMIT;


-- ─── 7. DEFIZZERATOR ─────────────────────────────────────────────────────────
-- Passive 1-band EQ; removes high-frequency fizz/buzz from distortion pedals
-- No power required. Dimensions from Reverb: 3.7 × 1.5 × 2 in (W × D × H)
-- MSRP not reliably sourced — estimates varied

BEGIN;

INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    msrp_cents, product_page,
    data_reliability
) VALUES (
    13, 1, 'Defizzerator',
    TRUE,
    94.0, 38.1, 50.8, 170,
    NULL, NULL,
    'Medium'
);

INSERT INTO pedal_details (
    product_id,
    effect_type, signal_type, bypass_type, mono_stereo,
    battery_capable, fx_loop_count
) VALUES (
    currval('products_id_seq'),
    'Filter', 'Analog', NULL, 'Mono',
    FALSE, 0
);

-- No power jack (passive device)

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS', 'Input');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Output');

INSERT INTO product_sources (product_id, table_name, field_name, value_recorded, source_type, source_url, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'width_mm',     '3.7 x 1.5 x 2 in', 'major_retailer', 'https://reverb.com/', 'Medium', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'depth_mm',     '3.7 x 1.5 x 2 in', 'major_retailer', 'https://reverb.com/', 'Medium', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'height_mm',    '3.7 x 1.5 x 2 in', 'major_retailer', 'https://reverb.com/', 'Medium', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'weight_grams', '6 oz',              'major_retailer', 'https://reverb.com/', 'Medium', '2026-03-21');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

COMMIT;
