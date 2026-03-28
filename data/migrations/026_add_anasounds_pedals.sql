-- Migration 026: Add Anasounds pedals and utilities (Manufacturer ID 18) — 23 products
-- Assembled versions only; kit versions (Ego Driver, Blues Believer, Feed Me MK3,
-- Tape Preamp, Spinner, Sliver) are excluded.
-- EUR prices converted to USD at 1.08 USD/EUR (rate as of 2026-03-27).
-- Current draw (mA) sourced from manufacturer manuals where documented; NULL otherwise.
--
-- Pedals (20): Savage MkII, Cerberus, High Voltage, Ego Driver, Blues Believer, Sandman,
--   Freq Up (discontinued), Feed Me MK3, Bitoun Fuzz, Crankled Bitoun Fuzz, Full Story,
--   Ages, Sliver, Utopia (discontinued), Utopia MK2, Utopia Deluxe, Element, La Grotte,
--   Lazy Comp, Tape Preamp
-- Utilities (3): Spinner, Bumper, Squicher
--
-- Data gaps shared across most products (see individual sections for specifics):
-- - weight_grams: not documented on manufacturer site or major retailers
-- - color_options: single-finish assumed; no documented variants unless noted
-- - tags: not assigned in this migration

BEGIN;

-- ============================================================
-- 1. SAVAGE MkII
-- Dimensions and weight from Savage manual PDF.
-- Current draw 22.9mA from manual (stored as integer: 23mA).
-- MSRP: no confirmed USD price found.
-- ============================================================
INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm,
    weight_grams, msrp_cents,
    product_page, instruction_manual,
    description, data_reliability
) VALUES (
    18, 1, 'Savage MkII',
    TRUE,
    140, 70, 50,
    450, NULL,
    'https://anasounds.com/produit/savage/',
    'https://anasounds.com/wp-content/uploads/2017/06/Savage-EN.pdf',
    'Two-channel analog overdrive with independent boost and drive stages.',
    'High'
);

INSERT INTO pedal_details (
    product_id,
    effect_type, signal_type, bypass_type, mono_stereo
) VALUES (
    currval('products_id_seq'),
    'Gain', 'Analog', 'True Bypass', 'Mono'
);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', 23, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'width_mm', 'https://anasounds.com/wp-content/uploads/2017/06/Savage-EN.pdf', 'manufacturer_manual', '14 cm', 'High', '2026-03-27'),
    (currval('products_id_seq'), 'products', 'depth_mm', 'https://anasounds.com/wp-content/uploads/2017/06/Savage-EN.pdf', 'manufacturer_manual', '7 cm', 'High', '2026-03-27'),
    (currval('products_id_seq'), 'products', 'height_mm', 'https://anasounds.com/wp-content/uploads/2017/06/Savage-EN.pdf', 'manufacturer_manual', '5 cm', 'High', '2026-03-27'),
    (currval('products_id_seq'), 'products', 'weight_grams', 'https://anasounds.com/wp-content/uploads/2017/06/Savage-EN.pdf', 'manufacturer_manual', '0.45 kg', 'High', '2026-03-27'),
    (currval('products_id_seq'), 'pedal_details', 'effect_type', 'https://anasounds.com/produit/savage/', 'manufacturer_website', 'Overdrive', 'High', '2026-03-27'),
    (currval('products_id_seq'), 'pedal_details', 'bypass_type', 'https://anasounds.com/produit/savage/', 'manufacturer_website', 'True Bypass', 'High', '2026-03-27');

INSERT INTO product_sources (product_id, table_name, field_name, jack_id, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'jacks', 'current_ma',
     (SELECT id FROM jacks WHERE product_id = currval('products_id_seq') AND category = 'power' AND direction = 'input'),
     'https://anasounds.com/wp-content/uploads/2017/06/Savage-EN.pdf', 'manufacturer_manual', '22.9mA', 'High', '2026-03-27');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 2. CERBERUS
-- Multi-mode overdrive with 3 clipping options.
-- Manual PDF confirmed; dimensions not found.
-- ============================================================
INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm,
    weight_grams, msrp_cents,
    product_page, instruction_manual,
    description, data_reliability
) VALUES (
    18, 1, 'Cerberus',
    TRUE,
    NULL, NULL, NULL,
    NULL, NULL,
    'https://anasounds.com/products/origins-pedals/cerberus/',
    'https://anasounds.com/wp-content/uploads/2017/06/Cerberus-EN.pdf',
    'Analog overdrive with three selectable clipping options for a range of gain textures.',
    'Medium'
);

INSERT INTO pedal_details (
    product_id,
    effect_type, signal_type, bypass_type, mono_stereo
) VALUES (
    currval('products_id_seq'),
    'Gain', 'Analog', 'True Bypass', 'Mono'
);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'pedal_details', 'effect_type', 'https://anasounds.com/products/origins-pedals/cerberus/', 'manufacturer_website', 'High', '2026-03-27'),
    (currval('products_id_seq'), 'pedal_details', 'bypass_type', 'https://anasounds.com/products/origins-pedals/cerberus/', 'manufacturer_website', 'High', '2026-03-27');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 3. HIGH VOLTAGE
-- Plexi-voiced distortion pedal.
-- Manual is French-language only; dimensions not found.
-- ============================================================
INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm,
    weight_grams, msrp_cents,
    product_page, instruction_manual,
    description, data_reliability
) VALUES (
    18, 1, 'High Voltage',
    TRUE,
    NULL, NULL, NULL,
    NULL, NULL,
    'https://anasounds.com/produit/high-voltage-gold/',
    'https://anasounds.com/wp-content/uploads/2018/05/noticehighvoltagefr.pdf',
    'Analog Plexi-voiced distortion pedal. Instruction manual is French-language only.',
    'Medium'
);

INSERT INTO pedal_details (
    product_id,
    effect_type, signal_type, bypass_type, mono_stereo
) VALUES (
    currval('products_id_seq'),
    'Gain', 'Analog', 'True Bypass', 'Mono'
);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'pedal_details', 'effect_type', 'https://anasounds.com/produit/high-voltage-gold/', 'manufacturer_website', 'High', '2026-03-27'),
    (currval('products_id_seq'), 'pedal_details', 'bypass_type', 'https://anasounds.com/produit/high-voltage-gold/', 'manufacturer_website', 'High', '2026-03-27');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 4. EGO DRIVER (assembled version)
-- Mid-boost overdrive. Part of the FX Teacher educational series.
-- MSRP $129 confirmed from anasounds.com.
-- ============================================================
INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm,
    weight_grams, msrp_cents,
    color_options,
    product_page, instruction_manual,
    description, data_reliability
) VALUES (
    18, 1, 'Ego Driver',
    TRUE,
    NULL, NULL, NULL,
    NULL, 12900,
    'Black',
    'https://anasounds.com/ego-driver/',
    'https://www.manualslib.com/manual/3159872/Anasounds-Fx-Teacher-Ego-Driver.html',
    'Mid-boost analog overdrive. Part of the Anasounds FX Teacher educational pedal series.',
    'Medium'
);

INSERT INTO pedal_details (
    product_id,
    effect_type, signal_type, bypass_type, mono_stereo
) VALUES (
    currval('products_id_seq'),
    'Gain', 'Analog', 'True Bypass', 'Mono'
);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'msrp_cents', 'https://anasounds.com/ego-driver/', 'manufacturer_website', '$129', 'High', '2026-03-27'),
    (currval('products_id_seq'), 'pedal_details', 'effect_type', 'https://anasounds.com/ego-driver/', 'manufacturer_website', 'Mid-Boost Overdrive', 'High', '2026-03-27'),
    (currval('products_id_seq'), 'pedal_details', 'bypass_type', 'https://anasounds.com/ego-driver/', 'manufacturer_website', 'True Bypass', 'High', '2026-03-27');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 5. BLUES BELIEVER (assembled version)
-- Bluesbreaker-voiced overdrive. Part of the FX Teacher series.
-- MSRP not found; dimensions not found.
-- ============================================================
INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm,
    weight_grams, msrp_cents,
    product_page, instruction_manual,
    description, data_reliability
) VALUES (
    18, 1, 'Blues Believer',
    TRUE,
    NULL, NULL, NULL,
    NULL, NULL,
    'https://anasounds.com/produit/blues-believer-assembled-version/',
    'https://anasounds.com/blues-believer-user-manual/',
    'Bluesbreaker-voiced analog overdrive. Part of the Anasounds FX Teacher educational pedal series.',
    'Medium'
);

INSERT INTO pedal_details (
    product_id,
    effect_type, circuit_type, signal_type, bypass_type, mono_stereo
) VALUES (
    currval('products_id_seq'),
    'Gain', 'Bluesbreaker', 'Analog', 'True Bypass', 'Mono'
);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'pedal_details', 'effect_type', 'https://anasounds.com/produit/blues-believer-assembled-version/', 'manufacturer_website', 'High', '2026-03-27'),
    (currval('products_id_seq'), 'pedal_details', 'circuit_type', 'https://anasounds.com/produit/blues-believer-assembled-version/', 'manufacturer_website', 'High', '2026-03-27'),
    (currval('products_id_seq'), 'pedal_details', 'bypass_type', 'https://anasounds.com/produit/blues-believer-assembled-version/', 'manufacturer_website', 'High', '2026-03-27');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 6. SANDMAN
-- Dual overdrive combining Savage MkI and Ego Driver circuits.
-- Limited edition (300 units). MSRP not confirmed.
-- ============================================================
INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm,
    weight_grams, msrp_cents,
    product_page, instruction_manual,
    description, data_reliability
) VALUES (
    18, 1, 'Sandman',
    TRUE,
    NULL, NULL, NULL,
    NULL, NULL,
    'https://anasounds.com/produit/sandman/',
    'https://anasounds.com/anasounds-sandman-user-manual/',
    'Dual analog overdrive combining the Savage MkI and Ego Driver circuits in a single enclosure. Limited edition (300 units).',
    'Medium'
);

INSERT INTO pedal_details (
    product_id,
    effect_type, signal_type, bypass_type, mono_stereo
) VALUES (
    currval('products_id_seq'),
    'Gain', 'Analog', 'True Bypass', 'Mono'
);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'pedal_details', 'effect_type', 'https://anasounds.com/produit/sandman/', 'manufacturer_website', 'High', '2026-03-27'),
    (currval('products_id_seq'), 'pedal_details', 'bypass_type', 'https://anasounds.com/produit/sandman/', 'manufacturer_website', 'High', '2026-03-27');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 7. FREQ UP (DISCONTINUED)
-- Boost/overdrive. Discontinued; no MSRP or dimensions found.
-- Manual is French-language only.
-- ============================================================
INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm,
    weight_grams, msrp_cents,
    product_page, instruction_manual,
    description, data_reliability
) VALUES (
    18, 1, 'Freq Up',
    FALSE,
    NULL, NULL, NULL,
    NULL, NULL,
    'https://anasounds.com/produit/freq-up/',
    'https://anasounds.com/wp-content/uploads/manuals/FreqUp-FR.pdf',
    'Discontinued analog boost/overdrive pedal. Instruction manual is French-language only.',
    'Medium'
);

INSERT INTO pedal_details (
    product_id,
    effect_type, signal_type, bypass_type, mono_stereo
) VALUES (
    currval('products_id_seq'),
    'Gain', 'Analog', 'True Bypass', 'Mono'
);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'pedal_details', 'effect_type', 'https://anasounds.com/produit/freq-up/', 'manufacturer_website', 'High', '2026-03-27'),
    (currval('products_id_seq'), 'pedal_details', 'bypass_type', 'https://anasounds.com/produit/freq-up/', 'manufacturer_website', 'High', '2026-03-27');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 8. FEED ME MK3 (assembled version)
-- Silicon fuzz. Part of the FX Teacher educational series.
-- MSRP and dimensions not found.
-- ============================================================
INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm,
    weight_grams, msrp_cents,
    product_page, instruction_manual,
    description, data_reliability
) VALUES (
    18, 1, 'Feed Me MK3',
    TRUE,
    NULL, NULL, NULL,
    NULL, NULL,
    'https://anasounds.com/products/origins-pedals/feed-me/',
    'https://anasounds.com/feed-me-fx-teacher-user-manual/',
    'Silicon fuzz. Part of the Anasounds FX Teacher educational pedal series.',
    'Medium'
);

INSERT INTO pedal_details (
    product_id,
    effect_type, signal_type, bypass_type, mono_stereo
) VALUES (
    currval('products_id_seq'),
    'Fuzz', 'Analog', 'True Bypass', 'Mono'
);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'pedal_details', 'effect_type', 'https://anasounds.com/products/origins-pedals/feed-me/', 'manufacturer_website', 'High', '2026-03-27'),
    (currval('products_id_seq'), 'pedal_details', 'bypass_type', 'https://anasounds.com/products/origins-pedals/feed-me/', 'manufacturer_website', 'High', '2026-03-27');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 9. BITOUN FUZZ
-- Dual fuzz combining Fuzz Face and Superfuzz circuits.
-- Dimensions (13×6.7×5.7 cm) and weight (360g) confirmed from manufacturer.
-- Current draw 24.4mA confirmed from manufacturer (stored as 24mA).
-- MSRP not confirmed.
-- ============================================================
INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm,
    weight_grams, msrp_cents,
    product_page, instruction_manual,
    description, data_reliability
) VALUES (
    18, 1, 'Bitoun Fuzz',
    TRUE,
    130, 67, 57,
    360, NULL,
    'https://anasounds.com/products/origins-pedals/bitoun-fuzz/',
    NULL,
    'Dual-circuit analog fuzz combining Fuzz Face and Superfuzz voices in a single enclosure.',
    'High'
);

INSERT INTO pedal_details (
    product_id,
    effect_type, signal_type, bypass_type, mono_stereo
) VALUES (
    currval('products_id_seq'),
    'Fuzz', 'Analog', 'True Bypass', 'Mono'
);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', 24, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'width_mm', 'https://anasounds.com/products/origins-pedals/bitoun-fuzz/', 'manufacturer_website', '13 cm', 'High', '2026-03-27'),
    (currval('products_id_seq'), 'products', 'depth_mm', 'https://anasounds.com/products/origins-pedals/bitoun-fuzz/', 'manufacturer_website', '6.7 cm', 'High', '2026-03-27'),
    (currval('products_id_seq'), 'products', 'height_mm', 'https://anasounds.com/products/origins-pedals/bitoun-fuzz/', 'manufacturer_website', '5.7 cm', 'High', '2026-03-27'),
    (currval('products_id_seq'), 'products', 'weight_grams', 'https://anasounds.com/products/origins-pedals/bitoun-fuzz/', 'manufacturer_website', '0.36 kg', 'High', '2026-03-27'),
    (currval('products_id_seq'), 'pedal_details', 'effect_type', 'https://anasounds.com/products/origins-pedals/bitoun-fuzz/', 'manufacturer_website', 'Fuzz', 'High', '2026-03-27'),
    (currval('products_id_seq'), 'pedal_details', 'bypass_type', 'https://anasounds.com/products/origins-pedals/bitoun-fuzz/', 'manufacturer_website', 'True Bypass', 'High', '2026-03-27');

INSERT INTO product_sources (product_id, table_name, field_name, jack_id, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'jacks', 'current_ma',
     (SELECT id FROM jacks WHERE product_id = currval('products_id_seq') AND category = 'power' AND direction = 'input'),
     'https://anasounds.com/products/origins-pedals/bitoun-fuzz/', 'manufacturer_website', '24.4mA', 'High', '2026-03-27');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 10. CRANKLED BITOUN FUZZ
-- Enhanced dual fuzz, limited edition (50 units worldwide).
-- Relay Bypass confirmed from Premier Guitar review.
-- MSRP $249 confirmed from Premier Guitar review.
-- Dimensions not found.
-- ============================================================
INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm,
    weight_grams, msrp_cents,
    product_page, instruction_manual,
    description, data_reliability
) VALUES (
    18, 1, 'Crankled Bitoun Fuzz',
    TRUE,
    NULL, NULL, NULL,
    NULL, 24900,
    'https://anasounds.com/produit/crankled-bitoun-fuzz/',
    NULL,
    'Enhanced dual-circuit fuzz based on the Bitoun Fuzz with relay bypass. Limited edition (50 units worldwide).',
    'Medium'
);

INSERT INTO pedal_details (
    product_id,
    effect_type, signal_type, bypass_type, mono_stereo
) VALUES (
    currval('products_id_seq'),
    'Fuzz', 'Analog', 'Relay Bypass', 'Mono'
);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'msrp_cents', 'https://www.premierguitar.com/anasounds-unveils-the-crankled-bitoun-fuzz', 'review_site', '$249', 'Medium', '2026-03-27'),
    (currval('products_id_seq'), 'pedal_details', 'effect_type', 'https://anasounds.com/produit/crankled-bitoun-fuzz/', 'manufacturer_website', 'Fuzz', 'High', '2026-03-27'),
    (currval('products_id_seq'), 'pedal_details', 'bypass_type', 'https://www.premierguitar.com/anasounds-unveils-the-crankled-bitoun-fuzz', 'review_site', 'Relay Bypass', 'Medium', '2026-03-27');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 11. FULL STORY
-- Modular dual fuzz with 7 swappable Big Muff circuit boards.
-- Dimensions (14.5×12.7×5.8 cm) confirmed from manufacturer.
-- Current draw 124mA confirmed from manufacturer manual.
-- MSRP not confirmed.
-- ============================================================
INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm,
    weight_grams, msrp_cents,
    product_page, instruction_manual,
    description, data_reliability
) VALUES (
    18, 1, 'Full Story',
    TRUE,
    145, 127, 58,
    NULL, NULL,
    'https://anasounds.com/produit/full-story-anasounds/',
    'https://anasounds.com/full-story-origins-user-manual/',
    'Modular dual-channel fuzz with 7 swappable Big Muff circuit boards covering major Muff eras.',
    'High'
);

INSERT INTO pedal_details (
    product_id,
    effect_type, circuit_type, signal_type, bypass_type, mono_stereo
) VALUES (
    currval('products_id_seq'),
    'Fuzz', 'Big Muff', 'Analog', 'True Bypass', 'Mono'
);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', 124, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'width_mm', 'https://anasounds.com/produit/full-story-anasounds/', 'manufacturer_website', '14.5 cm', 'High', '2026-03-27'),
    (currval('products_id_seq'), 'products', 'depth_mm', 'https://anasounds.com/produit/full-story-anasounds/', 'manufacturer_website', '12.7 cm', 'High', '2026-03-27'),
    (currval('products_id_seq'), 'products', 'height_mm', 'https://anasounds.com/produit/full-story-anasounds/', 'manufacturer_website', '5.8 cm', 'High', '2026-03-27'),
    (currval('products_id_seq'), 'pedal_details', 'effect_type', 'https://anasounds.com/produit/full-story-anasounds/', 'manufacturer_website', 'Fuzz', 'High', '2026-03-27'),
    (currval('products_id_seq'), 'pedal_details', 'circuit_type', 'https://anasounds.com/produit/full-story-anasounds/', 'manufacturer_website', 'Big Muff', 'High', '2026-03-27'),
    (currval('products_id_seq'), 'pedal_details', 'bypass_type', 'https://anasounds.com/produit/full-story-anasounds/', 'manufacturer_website', 'True Bypass', 'High', '2026-03-27');

INSERT INTO product_sources (product_id, table_name, field_name, jack_id, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'jacks', 'current_ma',
     (SELECT id FROM jacks WHERE product_id = currval('products_id_seq') AND category = 'power' AND direction = 'input'),
     'https://anasounds.com/full-story-origins-user-manual/', 'manufacturer_manual', '124mA', 'High', '2026-03-27');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 12. AGES
-- Harmonic tremolo with 7 LFO waveform modes and tap tempo.
-- Hybrid signal type: analog signal path, digital LFO control.
-- preset_count=0: the 7 LFO modes are built-in waveform options, not user presets.
-- Has 3.5mm TRS input on back panel for Spinner expression pedal.
-- MSRP and dimensions not found.
-- ============================================================
INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm,
    weight_grams, msrp_cents,
    product_page, instruction_manual,
    description, data_reliability
) VALUES (
    18, 1, 'Ages',
    TRUE,
    NULL, NULL, NULL,
    NULL, NULL,
    'https://anasounds.com/produit/ages-harmonic-tremolo/',
    NULL,
    'Harmonic tremolo with 7 LFO waveform modes and tap tempo. Analog signal path with digital LFO control. Compatible with the Spinner expression pedal.',
    'Medium'
);

INSERT INTO pedal_details (
    product_id,
    effect_type, signal_type, bypass_type, mono_stereo,
    has_tap_tempo, preset_count
) VALUES (
    currval('products_id_seq'),
    'Tremolo', 'Hybrid', 'True Bypass', 'Mono',
    TRUE, 0
);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS');

-- 3.5mm TRS input on rear panel for connecting the Spinner expression pedal
INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'expression', 'input', '3.5mm TRS', 'Spinner Input');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'pedal_details', 'effect_type', 'https://anasounds.com/produit/ages-harmonic-tremolo/', 'manufacturer_website', 'High', '2026-03-27'),
    (currval('products_id_seq'), 'pedal_details', 'bypass_type', 'https://anasounds.com/produit/ages-harmonic-tremolo/', 'manufacturer_website', 'High', '2026-03-27');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'pedal_details', 'has_tap_tempo', 'https://anasounds.com/produit/ages-harmonic-tremolo/', 'manufacturer_website', 'TRUE', 'High', '2026-03-27');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 13. SLIVER (assembled version)
-- Optical tremolo with digital modulation and tap tempo.
-- Hybrid signal type: analog signal path, digital modulation.
-- MSRP and dimensions not found.
-- ============================================================
INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm,
    weight_grams, msrp_cents,
    product_page, instruction_manual,
    description, data_reliability
) VALUES (
    18, 1, 'Sliver',
    TRUE,
    NULL, NULL, NULL,
    NULL, NULL,
    'https://anasounds.com/produit/optical-tremolo-kit-version/',
    NULL,
    'Optical tremolo with tap tempo. Analog signal path with digital modulation control.',
    'Medium'
);

INSERT INTO pedal_details (
    product_id,
    effect_type, signal_type, bypass_type, mono_stereo,
    has_tap_tempo
) VALUES (
    currval('products_id_seq'),
    'Tremolo', 'Hybrid', 'True Bypass', 'Mono',
    TRUE
);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'pedal_details', 'effect_type', 'https://anasounds.com/produit/optical-tremolo-kit-version/', 'manufacturer_website', 'High', '2026-03-27'),
    (currval('products_id_seq'), 'pedal_details', 'bypass_type', 'https://anasounds.com/produit/optical-tremolo-kit-version/', 'manufacturer_website', 'High', '2026-03-27');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'pedal_details', 'has_tap_tempo', 'https://anasounds.com/produit/optical-tremolo-kit-version/', 'manufacturer_website', 'TRUE', 'High', '2026-03-27');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 14. UTOPIA (DISCONTINUED)
-- Original single PT2399 analog delay. Superseded by Utopia MK2.
-- Manual PDF confirmed; dimensions not found.
-- ============================================================
INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm,
    weight_grams, msrp_cents,
    product_page, instruction_manual,
    description, data_reliability
) VALUES (
    18, 1, 'Utopia',
    FALSE,
    NULL, NULL, NULL,
    NULL, NULL,
    'https://anasounds.com/produit/utopia/',
    'https://anasounds.com/wp-content/uploads/2017/06/Utopia-EN.pdf',
    'Discontinued single PT2399 analog delay with modulation. Superseded by the Utopia MK2.',
    'Medium'
);

INSERT INTO pedal_details (
    product_id,
    effect_type, signal_type, bypass_type, mono_stereo
) VALUES (
    currval('products_id_seq'),
    'Delay', 'Analog', 'True Bypass', 'Mono'
);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'pedal_details', 'effect_type', 'https://anasounds.com/produit/utopia/', 'manufacturer_website', 'High', '2026-03-27'),
    (currval('products_id_seq'), 'pedal_details', 'bypass_type', 'https://anasounds.com/produit/utopia/', 'manufacturer_website', 'High', '2026-03-27');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 15. UTOPIA MK2
-- Compact single PT2399 analog delay.
-- MSRP €229 EUR converted to USD at 1.08: $247 (24700 cents).
-- Dimensions not found despite "compact" description.
-- A White Limited Edition variant is documented; standard color unknown.
-- ============================================================
INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm,
    weight_grams, msrp_cents,
    product_page, instruction_manual,
    description, data_reliability
) VALUES (
    18, 1, 'Utopia MK2',
    TRUE,
    NULL, NULL, NULL,
    NULL, 24700,
    'https://anasounds.com/produit/utopia-mk2/',
    'https://anasounds.com/utopia-mk2-user-manual/',
    'Compact single PT2399 analog delay with modulation. Available in a White Limited Edition variant.',
    'Medium'
);

INSERT INTO pedal_details (
    product_id,
    effect_type, signal_type, bypass_type, mono_stereo
) VALUES (
    currval('products_id_seq'),
    'Delay', 'Analog', 'True Bypass', 'Mono'
);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'msrp_cents', 'https://anasounds.com/produit/utopia-mk2/', 'manufacturer_website', '€229 EUR (converted to USD at 1.08)', 'Medium', '2026-03-27'),
    (currval('products_id_seq'), 'pedal_details', 'effect_type', 'https://anasounds.com/produit/utopia-mk2/', 'manufacturer_website', 'Delay', 'High', '2026-03-27'),
    (currval('products_id_seq'), 'pedal_details', 'bypass_type', 'https://anasounds.com/produit/utopia-mk2/', 'manufacturer_website', 'True Bypass', 'High', '2026-03-27');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 16. UTOPIA DELUXE
-- Dual PT2399 analog delay with tap tempo.
-- Current draw 150mA confirmed from manufacturer manual.
-- MSRP and dimensions not found.
-- ============================================================
INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm,
    weight_grams, msrp_cents,
    product_page, instruction_manual,
    description, data_reliability
) VALUES (
    18, 1, 'Utopia Deluxe',
    TRUE,
    NULL, NULL, NULL,
    NULL, NULL,
    'https://anasounds.com/produit/utopia-deluxe/',
    'https://anasounds.com/utopia-dlx-user-manual/',
    'Dual PT2399 analog delay with modulation, tap tempo, and expanded control set.',
    'Medium'
);

INSERT INTO pedal_details (
    product_id,
    effect_type, signal_type, bypass_type, mono_stereo,
    has_tap_tempo
) VALUES (
    currval('products_id_seq'),
    'Delay', 'Analog', 'True Bypass', 'Mono',
    TRUE
);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', 150, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'pedal_details', 'effect_type', 'https://anasounds.com/produit/utopia-deluxe/', 'manufacturer_website', 'High', '2026-03-27'),
    (currval('products_id_seq'), 'pedal_details', 'bypass_type', 'https://anasounds.com/produit/utopia-deluxe/', 'manufacturer_website', 'High', '2026-03-27');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'pedal_details', 'has_tap_tempo', 'https://anasounds.com/produit/utopia-deluxe/', 'manufacturer_website', 'TRUE', 'High', '2026-03-27');

INSERT INTO product_sources (product_id, table_name, field_name, jack_id, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'jacks', 'current_ma',
     (SELECT id FROM jacks WHERE product_id = currval('products_id_seq') AND category = 'power' AND direction = 'input'),
     'https://anasounds.com/utopia-dlx-user-manual/', 'manufacturer_manual', '150mA', 'High', '2026-03-27');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 17. ELEMENT
-- Spring reverb with interchangeable reverb tanks.
-- Dimensions (12.5×6.5×5.7 cm) confirmed from manufacturer.
-- RCA jacks on rear panel for tank connection (send + return).
-- MSRP and weight not found.
-- ============================================================
INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm,
    weight_grams, msrp_cents,
    product_page, instruction_manual,
    description, data_reliability
) VALUES (
    18, 1, 'Element',
    TRUE,
    125, 65, 57,
    NULL, NULL,
    'https://anasounds.com/produit/element-reverb/',
    NULL,
    'Analog spring reverb with interchangeable reverb tanks. RCA jacks on rear panel for tank connection.',
    'Medium'
);

INSERT INTO pedal_details (
    product_id,
    effect_type, signal_type, bypass_type, mono_stereo
) VALUES (
    currval('products_id_seq'),
    'Reverb', 'Analog', 'True Bypass', 'Mono'
);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS');

-- RCA jacks for interchangeable spring reverb tank (rear panel)
INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'aux', 'output', 'RCA', 'Tank Send');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'aux', 'input', 'RCA', 'Tank Return');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'width_mm', 'https://anasounds.com/produit/element-reverb/', 'manufacturer_website', '12.5 cm', 'Medium', '2026-03-27'),
    (currval('products_id_seq'), 'products', 'depth_mm', 'https://anasounds.com/produit/element-reverb/', 'manufacturer_website', '6.5 cm', 'Medium', '2026-03-27'),
    (currval('products_id_seq'), 'products', 'height_mm', 'https://anasounds.com/produit/element-reverb/', 'manufacturer_website', '5.7 cm', 'Medium', '2026-03-27'),
    (currval('products_id_seq'), 'pedal_details', 'effect_type', 'https://anasounds.com/produit/element-reverb/', 'manufacturer_website', 'Spring Reverb', 'High', '2026-03-27'),
    (currval('products_id_seq'), 'pedal_details', 'bypass_type', 'https://anasounds.com/produit/element-reverb/', 'manufacturer_website', 'True Bypass', 'High', '2026-03-27');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 18. LA GROTTE
-- Analog spring reverb. Collaboration with Third Man Hardware.
-- Dimensions (15×12.3×6.2 cm) confirmed.
-- MSRP $300 USD confirmed from Guitar.com review.
-- Has a separate dry signal output in addition to the main (wet/blend) output.
-- ============================================================
INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm,
    weight_grams, msrp_cents,
    product_page, instruction_manual,
    description, data_reliability
) VALUES (
    18, 1, 'La Grotte',
    TRUE,
    150, 123, 62,
    NULL, 30000,
    'https://anasounds.com/produit/la-grotte/',
    'https://anasounds.com/la-grotte-user-manual/',
    'Analog spring reverb developed in collaboration with Third Man Hardware. Features a separate dry signal output alongside the main wet/blend output.',
    'Medium'
);

INSERT INTO pedal_details (
    product_id,
    effect_type, signal_type, bypass_type, mono_stereo
) VALUES (
    currval('products_id_seq'),
    'Reverb', 'Analog', 'True Bypass', 'Mono'
);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

-- Main output (wet/blend)
INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS');

-- Separate dry signal output
INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Dry Out');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'width_mm', 'https://anasounds.com/produit/la-grotte/', 'manufacturer_website', '15 cm', 'High', '2026-03-27'),
    (currval('products_id_seq'), 'products', 'depth_mm', 'https://anasounds.com/produit/la-grotte/', 'manufacturer_website', '12.3 cm', 'High', '2026-03-27'),
    (currval('products_id_seq'), 'products', 'height_mm', 'https://anasounds.com/produit/la-grotte/', 'manufacturer_website', '6.2 cm', 'High', '2026-03-27'),
    (currval('products_id_seq'), 'products', 'msrp_cents', 'https://guitar.com/reviews/effects-pedal/hands-on-anasounds-third-man-hardware-la-grotte-review/', 'review_site', '$300', 'Medium', '2026-03-27'),
    (currval('products_id_seq'), 'pedal_details', 'effect_type', 'https://anasounds.com/produit/la-grotte/', 'manufacturer_website', 'Spring Reverb', 'High', '2026-03-27'),
    (currval('products_id_seq'), 'pedal_details', 'bypass_type', 'https://anasounds.com/produit/la-grotte/', 'manufacturer_website', 'True Bypass', 'High', '2026-03-27');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 19. LAZY COMP
-- Optical compressor.
-- Dimensions (14×7×5 cm) and weight (450g) confirmed from manufacturer.
-- Current draw 8.6mA confirmed from manufacturer (stored as 9mA).
-- MSRP not confirmed.
-- ============================================================
INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm,
    weight_grams, msrp_cents,
    product_page, instruction_manual,
    description, data_reliability
) VALUES (
    18, 1, 'Lazy Comp',
    TRUE,
    140, 70, 50,
    450, NULL,
    'https://anasounds.com/products/origins-pedals/lazy-comp/',
    NULL,
    'Optical compressor with a transparent, musical response.',
    'High'
);

INSERT INTO pedal_details (
    product_id,
    effect_type, signal_type, bypass_type, mono_stereo
) VALUES (
    currval('products_id_seq'),
    'Compression', 'Analog', 'True Bypass', 'Mono'
);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', 9, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'width_mm', 'https://anasounds.com/products/origins-pedals/lazy-comp/', 'manufacturer_website', '14 cm', 'High', '2026-03-27'),
    (currval('products_id_seq'), 'products', 'depth_mm', 'https://anasounds.com/products/origins-pedals/lazy-comp/', 'manufacturer_website', '7 cm', 'High', '2026-03-27'),
    (currval('products_id_seq'), 'products', 'height_mm', 'https://anasounds.com/products/origins-pedals/lazy-comp/', 'manufacturer_website', '5 cm', 'High', '2026-03-27'),
    (currval('products_id_seq'), 'products', 'weight_grams', 'https://anasounds.com/products/origins-pedals/lazy-comp/', 'manufacturer_website', '0.45 kg', 'High', '2026-03-27'),
    (currval('products_id_seq'), 'pedal_details', 'effect_type', 'https://anasounds.com/products/origins-pedals/lazy-comp/', 'manufacturer_website', 'Optical Compressor', 'High', '2026-03-27'),
    (currval('products_id_seq'), 'pedal_details', 'bypass_type', 'https://anasounds.com/products/origins-pedals/lazy-comp/', 'manufacturer_website', 'True Bypass', 'High', '2026-03-27');

INSERT INTO product_sources (product_id, table_name, field_name, jack_id, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'jacks', 'current_ma',
     (SELECT id FROM jacks WHERE product_id = currval('products_id_seq') AND category = 'power' AND direction = 'input'),
     'https://anasounds.com/products/origins-pedals/lazy-comp/', 'manufacturer_website', '8.6mA', 'High', '2026-03-27');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 20. TAPE PREAMP (assembled version)
-- JFET preamp. Part of the FX Teacher educational series.
-- MSRP and dimensions not found.
-- ============================================================
INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm,
    weight_grams, msrp_cents,
    product_page, instruction_manual,
    description, data_reliability
) VALUES (
    18, 1, 'Tape Preamp',
    TRUE,
    NULL, NULL, NULL,
    NULL, NULL,
    'https://anasounds.com/tape-preamp/',
    'https://anasounds.com/fx-teacher-tape-preamp-user-manual/',
    'JFET analog preamp. Part of the Anasounds FX Teacher educational pedal series.',
    'Medium'
);

INSERT INTO pedal_details (
    product_id,
    effect_type, signal_type, bypass_type, mono_stereo
) VALUES (
    currval('products_id_seq'),
    'Preamp', 'Analog', 'True Bypass', 'Mono'
);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'pedal_details', 'effect_type', 'https://anasounds.com/tape-preamp/', 'manufacturer_website', 'High', '2026-03-27'),
    (currval('products_id_seq'), 'pedal_details', 'bypass_type', 'https://anasounds.com/tape-preamp/', 'manufacturer_website', 'High', '2026-03-27');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 21. SPINNER (assembled version) — UTILITY
-- Magnetically-controlled expression pedal with rotating wheel mechanism.
-- Passive device (no power required for core expression function).
-- Outputs: 1/4" TRS expression output; 3.5mm TRS mini jack for Ages connection.
-- All dimensions and MSRP not found.
-- ============================================================
INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm,
    weight_grams, msrp_cents,
    product_page, instruction_manual,
    description, data_reliability
) VALUES (
    18, 5, 'Spinner',
    TRUE,
    NULL, NULL, NULL,
    NULL, NULL,
    'https://anasounds.com/produit/spinner-expression-pedal/',
    NULL,
    'Passive expression pedal with a magnetically-controlled rotating wheel. Compatible with the Ages harmonic tremolo via rear-panel 3.5mm connection.',
    'Medium'
);

INSERT INTO utility_details (
    product_id,
    utility_type, is_active, signal_type
) VALUES (
    currval('products_id_seq'),
    'Expression Pedal', FALSE, 'Analog'
);

-- Standard 1/4" TRS expression output
INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'expression', 'output', '1/4" TRS');

-- 3.5mm TRS mini jack output for direct connection to Ages rear panel
INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'expression', 'output', '3.5mm TRS', 'Ages Connection');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'utility_details', 'utility_type', 'https://anasounds.com/produit/spinner-expression-pedal/', 'manufacturer_website', 'High', '2026-03-27');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 22. BUMPER — UTILITY
-- Active JFET adaptive resonance buffer. Always-on (no bypass switch).
-- All dimensions and MSRP not found.
-- ============================================================
INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm,
    weight_grams, msrp_cents,
    product_page, instruction_manual,
    description, data_reliability
) VALUES (
    18, 5, 'Bumper',
    TRUE,
    NULL, NULL, NULL,
    NULL, NULL,
    'https://anasounds.com/produit/bumper/',
    'https://anasounds.com/wp-content/uploads/manuals/Bumper-FR.pdf',
    'Active analog buffer with adaptive resonance control. Always-on (no bypass switch). Instruction manual is French-language only.',
    'Medium'
);

INSERT INTO utility_details (
    product_id,
    utility_type, is_active, signal_type
) VALUES (
    currval('products_id_seq'),
    'Buffer', TRUE, 'Analog'
);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'utility_details', 'utility_type', 'https://anasounds.com/produit/bumper/', 'manufacturer_website', 'High', '2026-03-27'),
    (currval('products_id_seq'), 'utility_details', 'is_active', 'https://anasounds.com/produit/bumper/', 'manufacturer_website', 'High', '2026-03-27');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 23. SQUICHER — UTILITY
-- Passive footswitch/amp channel switcher.
-- Very limited information available; most fields NULL.
-- ============================================================
INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm,
    weight_grams, msrp_cents,
    product_page, instruction_manual,
    description, data_reliability
) VALUES (
    18, 5, 'Squicher',
    TRUE,
    NULL, NULL, NULL,
    NULL, NULL,
    'https://anasounds.com/produit/squicher-simple-switcher/',
    NULL,
    'Passive footswitch utility for amp channel switching or simple on/off control.',
    'Medium'
);

INSERT INTO utility_details (
    product_id,
    utility_type, is_active, signal_type
) VALUES (
    currval('products_id_seq'),
    'Amp Switcher', FALSE, 'Analog'
);

-- Footswitch control output (standard 1/4" TS, tip-sleeve switching)
INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'utility_details', 'utility_type', 'https://anasounds.com/produit/squicher-simple-switcher/', 'manufacturer_website', 'High', '2026-03-27');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

COMMIT;
