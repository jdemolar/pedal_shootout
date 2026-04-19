-- Migration 028: Add Area 51 products (Manufacturer ID 21) — 7 products
-- Area 51 Tube Audio Designs, Newaygo MI, USA. Small boutique operation; 1-2 month lead times.
-- All pedals hand-wired using Switchcraft jacks, vintage-style components, hand-wound inductors.
--
-- Products:
--   Pedals (6): Standard Wah, Clone Wah, All Options Wah, Fuzzwah, Fuzz, The Alienist
--   Utility (1): The Box (buffer)
--
-- Data gaps shared across all products:
--   - width_mm, depth_mm, height_mm: not published by manufacturer
--   - weight_grams: not published by manufacturer
--   - current_ma: not published by manufacturer
--   - instruction_manual: no PDFs found
--   - MSRP: confirmed only for Standard Wah ($229.95), The Alienist ($269.00), The Box ($149.95)
--     Clone Wah, All Options, Fuzzwah, Fuzz left as NULL (no official MSRP found)
--
-- Jack configuration note: audio jacks (1x in, 1x out, 1/4" TS) are inferred from product
-- type and manufacturer descriptions. Not sourced from a manual or spec sheet.
-- Inserted at Medium reliability with explanatory notes.

BEGIN;

-- ============================================================
-- 1. STANDARD WAH
-- Area 51's flagship wah. Icar 100k pot, hand-wound inductor,
-- 316-PP footswitch. Area 51 voicing (lower range than Vox).
-- ============================================================
INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    msrp_cents, product_page, instruction_manual,
    description, data_reliability
) VALUES (
    21, 1, 'Standard Wah',
    TRUE,
    NULL, NULL, NULL, NULL,
    22995, 'https://www.area51tubeaudiodesigns.com/standard_wah.html', NULL,
    'Hand-wired true bypass wah with Area 51 voicing (lower sweep range than vintage Vox). Icar 100k pot and hand-wound inductor.',
    'Medium'
);

INSERT INTO pedal_details (product_id, effect_type, signal_type, bypass_type, mono_stereo, battery_capable)
VALUES (currval('products_id_seq'), 'Wah', 'Analog', 'True Bypass', 'Mono', TRUE);

-- Power input (9V, current draw unknown; inferred from product type)
INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', NULL, 'Center Negative');

-- Audio jacks inferred from product type and manufacturer descriptions
INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products',      'msrp_cents',   'https://www.area51tubeaudiodesigns.com/standard_wah.html', 'manufacturer_website', '$229.95',     'Medium', '2026-04-18'),
    (currval('products_id_seq'), 'pedal_details', 'effect_type',  'https://www.area51tubeaudiodesigns.com/standard_wah.html', 'manufacturer_website', 'Wah',         'Medium', '2026-04-18'),
    (currval('products_id_seq'), 'pedal_details', 'bypass_type',  'https://www.area51tubeaudiodesigns.com/standard_wah.html', 'manufacturer_website', 'True Bypass', 'Medium', '2026-04-18');

INSERT INTO product_sources (product_id, table_name, field_name, jack_id, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'jacks', 'voltage', currval('jacks_id_seq') - 2, 'https://www.area51tubeaudiodesigns.com/standard_wah.html', 'manufacturer_website', '9V DC', 'Medium', '2026-04-18');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 2. CLONE WAH (CLYDE McCOY CLONE)
-- Modern reproduction of 1960s Clyde McCoy wah. Aluminum cast
-- housing (lighter than modern zinc), vintage-layout board,
-- hand-tuned inductor, selected transistors, Icar taper pot.
-- Supports 9-14V (no tone change with battery vs. supply).
-- ============================================================
INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    msrp_cents, product_page, instruction_manual,
    description, data_reliability
) VALUES (
    21, 1, 'Clone Wah',
    TRUE,
    NULL, NULL, NULL, NULL,
    NULL, 'http://www.area51tubeaudiodesigns.com/clone_mccoy_wah.html', NULL,
    'Hand-wired reproduction of the 1960s Clyde McCoy wah. Aluminum cast housing, vintage-layout circuit board, hand-tuned inductor, and selected transistors. Supports 9–14V.',
    'Medium'
);

INSERT INTO pedal_details (product_id, effect_type, signal_type, bypass_type, mono_stereo, battery_capable)
VALUES (currval('products_id_seq'), 'Wah', 'Analog', 'True Bypass', 'Mono', TRUE);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9-14V', NULL, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'pedal_details', 'effect_type',  'http://www.area51tubeaudiodesigns.com/clone_mccoy_wah.html', 'manufacturer_website', 'Wah',         'Medium', '2026-04-18'),
    (currval('products_id_seq'), 'pedal_details', 'bypass_type',  'http://www.area51tubeaudiodesigns.com/clone_mccoy_wah.html', 'manufacturer_website', 'True Bypass', 'Medium', '2026-04-18');

INSERT INTO product_sources (product_id, table_name, field_name, jack_id, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'jacks', 'voltage', currval('jacks_id_seq') - 2, 'http://www.area51tubeaudiodesigns.com/clone_mccoy_wah.html', 'manufacturer_website', '9-14V DC', 'Medium', '2026-04-18');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 3. ALL OPTIONS WAH (Rev 10a)
-- All Standard Wah tones plus: Input level/impedance control,
-- Q control (sweep sharpness), Growl control (low-end gain),
-- 5-position Range switch (throaty, Area 51, Vintage Italy,
-- grey Vox, Zeppelin tones). Bypass is user-selectable
-- (true bypass or buffered) via internal switch.
-- ============================================================
INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    msrp_cents, product_page, instruction_manual,
    description, data_reliability
) VALUES (
    21, 1, 'All Options Wah',
    TRUE,
    NULL, NULL, NULL, NULL,
    NULL, 'http://www.area51tubeaudiodesigns.com/all_options_wah.html', NULL,
    'Hand-wired wah with selectable bypass mode and extended controls: input impedance, Q (sweep sharpness), Growl (low-end gain), and a 5-position Range switch covering five classic wah voicings.',
    'Medium'
);

INSERT INTO pedal_details (product_id, effect_type, signal_type, bypass_type, mono_stereo, battery_capable)
VALUES (currval('products_id_seq'), 'Wah', 'Analog', 'Both', 'Mono', TRUE);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', NULL, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'pedal_details', 'effect_type',  'http://www.area51tubeaudiodesigns.com/all_options_wah.html', 'manufacturer_website', 'Wah',                       'Medium', '2026-04-18'),
    (currval('products_id_seq'), 'pedal_details', 'bypass_type',  'http://www.area51tubeaudiodesigns.com/all_options_wah.html', 'manufacturer_website', 'Selectable True/Buffered', 'Medium', '2026-04-18');

INSERT INTO product_sources (product_id, table_name, field_name, jack_id, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'jacks', 'voltage', currval('jacks_id_seq') - 2, 'http://www.area51tubeaudiodesigns.com/all_options_wah.html', 'manufacturer_website', '9V DC', 'Medium', '2026-04-18');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 4. FUZZWAH
-- Wah circuit with bypassable fuzz gain stage. Fuzz drives amp
-- preamp and smooths wah sweep. Can produce subtle shifts or
-- massive wah/fuzz combos depending on treadle position.
-- Classified as Wah (primary circuit); fuzz is an additive stage.
-- ============================================================
INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    msrp_cents, product_page, instruction_manual,
    description, data_reliability
) VALUES (
    21, 1, 'Fuzzwah',
    TRUE,
    NULL, NULL, NULL, NULL,
    NULL, 'http://www.area51tubeaudiodesigns.com/fuzzwah.html', NULL,
    'Hand-wired wah with a bypassable fuzz gain stage. The fuzz circuit drives the amp preamp and smooths the wah sweep — from subtle tonal shifts to massive wah/fuzz combinations depending on treadle position.',
    'Medium'
);

INSERT INTO pedal_details (product_id, effect_type, signal_type, bypass_type, mono_stereo, battery_capable)
VALUES (currval('products_id_seq'), 'Wah', 'Analog', 'True Bypass', 'Mono', TRUE);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', NULL, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'pedal_details', 'effect_type',  'http://www.area51tubeaudiodesigns.com/fuzzwah.html', 'manufacturer_website', 'Wah/Fuzz',    'Medium', '2026-04-18'),
    (currval('products_id_seq'), 'pedal_details', 'bypass_type',  'http://www.area51tubeaudiodesigns.com/fuzzwah.html', 'manufacturer_website', 'True Bypass', 'Medium', '2026-04-18');

INSERT INTO product_sources (product_id, table_name, field_name, jack_id, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'jacks', 'voltage', currval('jacks_id_seq') - 2, 'http://www.area51tubeaudiodesigns.com/fuzzwah.html', 'manufacturer_website', '9V DC', 'Medium', '2026-04-18');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 5. FUZZ
-- Silicon fuzz with germanium character. Uses silicon transistors
-- for stability while targeting germanium tone. Controls: Level,
-- Fuzz. Blue LED. No tone change between battery and DC supply.
-- ============================================================
INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    msrp_cents, product_page, instruction_manual,
    description, data_reliability
) VALUES (
    21, 1, 'Fuzz',
    TRUE,
    NULL, NULL, NULL, NULL,
    NULL, 'http://www.area51tubeaudiodesigns.com/fuzz.html', NULL,
    'Silicon fuzz designed to capture germanium tone and character while avoiding germanium instability. Controls: Level and Fuzz.',
    'Medium'
);

INSERT INTO pedal_details (product_id, effect_type, signal_type, bypass_type, mono_stereo, battery_capable)
VALUES (currval('products_id_seq'), 'Fuzz', 'Analog', 'True Bypass', 'Mono', TRUE);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', NULL, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'pedal_details', 'effect_type',  'http://www.area51tubeaudiodesigns.com/fuzz.html', 'manufacturer_website', 'Fuzz',        'Medium', '2026-04-18'),
    (currval('products_id_seq'), 'pedal_details', 'bypass_type',  'http://www.area51tubeaudiodesigns.com/fuzz.html', 'manufacturer_website', 'True Bypass', 'Medium', '2026-04-18');

INSERT INTO product_sources (product_id, table_name, field_name, jack_id, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'jacks', 'voltage', currval('jacks_id_seq') - 2, 'http://www.area51tubeaudiodesigns.com/fuzz.html', 'manufacturer_website', '9V DC', 'Medium', '2026-04-18');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 6. THE ALIENIST (VOICING BOOST)
-- 6-position voicing selector. Switchable NOS germanium (low-gain)
-- or silicon (higher-gain) transistors visible through glass lens
-- with fade lighting. Resonant filter circuit. Switchcraft #11 jacks
-- (vintage Fender amp spec). Supports 9-14V.
-- ============================================================
INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    msrp_cents, product_page, instruction_manual,
    description, data_reliability
) VALUES (
    21, 1, 'The Alienist',
    TRUE,
    NULL, NULL, NULL, NULL,
    26900, 'http://www.area51tubeaudiodesigns.com/alienist.html', NULL,
    'Hand-wired voicing boost with a 6-position voicing selector, switchable NOS germanium or silicon transistors (visible through a glass lens with fade lighting), and a resonant filter circuit. Supports 9–14V.',
    'Medium'
);

INSERT INTO pedal_details (product_id, effect_type, signal_type, bypass_type, mono_stereo, battery_capable)
VALUES (currval('products_id_seq'), 'Gain', 'Analog', 'True Bypass', 'Mono', TRUE);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9-14V', NULL, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products',      'msrp_cents',   'http://www.area51tubeaudiodesigns.com/alienist.html', 'manufacturer_website', '$269.00',     'Medium', '2026-04-18'),
    (currval('products_id_seq'), 'pedal_details', 'effect_type',  'http://www.area51tubeaudiodesigns.com/alienist.html', 'manufacturer_website', 'Boost/Gain',  'Medium', '2026-04-18'),
    (currval('products_id_seq'), 'pedal_details', 'bypass_type',  'http://www.area51tubeaudiodesigns.com/alienist.html', 'manufacturer_website', 'True Bypass', 'Medium', '2026-04-18');

INSERT INTO product_sources (product_id, table_name, field_name, jack_id, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'jacks', 'voltage', currval('jacks_id_seq') - 2, 'http://www.area51tubeaudiodesigns.com/alienist.html', 'manufacturer_website', '9-14V DC', 'Medium', '2026-04-18');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 7. THE BOX (UNITY BUFFER)
-- Opamp-based transparent buffer. Output level trimpot.
-- True bypass via slide switch. Drives long cables due to
-- low output impedance. Switchcraft #11 jacks.
-- Gold hammertone powder coat finish. Hand-wired in USA.
-- Utility product (product_type_id = 5).
-- ============================================================
INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    msrp_cents, product_page, instruction_manual,
    description, data_reliability
) VALUES (
    21, 5, 'The Box',
    TRUE,
    NULL, NULL, NULL, NULL,
    14995, 'http://www.area51tubeaudiodesigns.com/thebox.html', NULL,
    'Hand-wired opamp-based unity buffer. Low-noise and transparent. Output level trimpot. True bypass via slide switch. Drives long cable runs due to low output impedance.',
    'Medium'
);

INSERT INTO utility_details (
    product_id, utility_type, is_active, signal_type, bypass_type,
    has_ground_lift, has_pad, pad_db,
    tuning_display_type, tuning_accuracy_cents, polyphonic_tuning,
    sweep_type, has_tuner_out, has_minimum_volume, has_polarity_switch,
    power_handling_watts, has_reactive_load, has_attenuation, attenuation_range_db, has_cab_sim
) VALUES (
    currval('products_id_seq'), 'Buffer', TRUE, 'Analog', 'True Bypass',
    NULL, NULL, NULL,
    NULL, NULL, FALSE,
    NULL, FALSE, FALSE, FALSE,
    NULL, FALSE, FALSE, NULL, FALSE
);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', NULL, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products',       'msrp_cents',   'http://www.area51tubeaudiodesigns.com/thebox.html', 'manufacturer_website', '$149.95',     'Medium', '2026-04-18'),
    (currval('products_id_seq'), 'utility_details', 'utility_type', 'http://www.area51tubeaudiodesigns.com/thebox.html', 'manufacturer_website', 'Buffer',      'Medium', '2026-04-18'),
    (currval('products_id_seq'), 'utility_details', 'bypass_type',  'http://www.area51tubeaudiodesigns.com/thebox.html', 'manufacturer_website', 'True Bypass', 'Medium', '2026-04-18');

INSERT INTO product_sources (product_id, table_name, field_name, jack_id, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'jacks', 'voltage', currval('jacks_id_seq') - 2, 'http://www.area51tubeaudiodesigns.com/thebox.html', 'manufacturer_website', '9V DC', 'Medium', '2026-04-18');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

COMMIT;
