-- =============================================================================
-- Migration 032: Add Artec products (manufacturer ID 25)
-- =============================================================================
-- 16 products:
--   11 pedals (SE-7DB, SE-DDB, SE-OE3, SE-BEQ, SE-GEQ, SE-ADL, SE-FLG,
--              SE-VPH, SE-VTM, SE-VCH, CDV-1)
--   5 utilities (SE-NGT, SE-2FS, SE-SWB, VPL-1 + no SE-EQ8/QDD2 per user decision)
--
-- Dimensions convention (user confirmed for SE-FLG, applied to all standard models):
--   width_mm=75.5, height_mm=115.5, depth_mm=47.5
-- Primary source: artecsound.com (High reliability for dimensions, weight, power)
-- Bypass type NULL where not specified in sources.
-- =============================================================================

BEGIN;

-- ─── 1. SE-7DB 70's Drive Blender ────────────────────────────────────────────

INSERT INTO products (
    manufacturer_id, product_type_id, model,
    color_options, in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    msrp_cents, product_page, instruction_manual,
    description, tags, data_reliability, notes
) VALUES (
    25, 1, 'SE-7DB',
    NULL, TRUE,
    75.5, 47.5, 115.5, 290,
    NULL, 'https://artecsound.com/effect/se-7db.htm', NULL,
    'Drive blender combining two classic 70s-style gain circuits with individual blend control.',
    'drive,gain,blend,analog',
    'High', 'Bypass type not specified on manufacturer page — left NULL.'
);

INSERT INTO pedal_details (product_id, effect_type, signal_type, bypass_type, mono_stereo)
VALUES (currval('products_id_seq'), 'Gain', 'Analog', NULL, 'Mono');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, position)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS', 'Input', 'right');

INSERT INTO product_sources (product_id, jack_id, table_name, field_name, value_recorded, source_url, source_type, reliability)
VALUES (currval('products_id_seq'), currval('jacks_id_seq'), 'jacks', 'connector_type', '1/4" TS', 'https://artecsound.com/effect/se-7db.htm', 'manufacturer_website', 'High');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, position)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Output', 'left');

INSERT INTO product_sources (product_id, jack_id, table_name, field_name, value_recorded, source_url, source_type, reliability)
VALUES (currval('products_id_seq'), currval('jacks_id_seq'), 'jacks', 'connector_type', '1/4" TS', 'https://artecsound.com/effect/se-7db.htm', 'manufacturer_website', 'High');

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', 6, 'Center Negative');

INSERT INTO product_sources (product_id, jack_id, table_name, field_name, value_recorded, source_url, source_type, reliability)
VALUES (currval('products_id_seq'), currval('jacks_id_seq'), 'jacks', 'current_ma', '6mA', 'https://artecsound.com/effect/se-7db.htm', 'manufacturer_website', 'High');

INSERT INTO product_sources (product_id, jack_id, table_name, field_name, value_recorded, source_url, source_type, reliability)
VALUES
    (currval('products_id_seq'), NULL, 'products', 'width_mm', '75.5mm', 'https://artecsound.com/effect/se-7db.htm', 'manufacturer_website', 'High'),
    (currval('products_id_seq'), NULL, 'products', 'depth_mm', '47.5mm', 'https://artecsound.com/effect/se-7db.htm', 'manufacturer_website', 'High'),
    (currval('products_id_seq'), NULL, 'products', 'height_mm', '115.5mm', 'https://artecsound.com/effect/se-7db.htm', 'manufacturer_website', 'High'),
    (currval('products_id_seq'), NULL, 'products', 'weight_grams', '290g', 'https://artecsound.com/effect/se-7db.htm', 'manufacturer_website', 'High');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ─── 2. SE-DDB Duo Drive Blender ─────────────────────────────────────────────

INSERT INTO products (
    manufacturer_id, product_type_id, model,
    color_options, in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    msrp_cents, product_page, instruction_manual,
    description, tags, data_reliability, notes
) VALUES (
    25, 1, 'SE-DDB',
    NULL, TRUE,
    75.5, 47.5, 115.5, 290,
    NULL, 'http://artecsound.com/effect/se-ddb.htm', NULL,
    'Dual drive blender combining two gain circuits with blend control for layered tones.',
    'drive,gain,blend,analog',
    'High', 'Bypass type not specified on manufacturer page — left NULL.'
);

INSERT INTO pedal_details (product_id, effect_type, signal_type, bypass_type, mono_stereo)
VALUES (currval('products_id_seq'), 'Gain', 'Analog', NULL, 'Mono');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, position)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS', 'Input', 'right');

INSERT INTO product_sources (product_id, jack_id, table_name, field_name, value_recorded, source_url, source_type, reliability)
VALUES (currval('products_id_seq'), currval('jacks_id_seq'), 'jacks', 'connector_type', '1/4" TS', 'http://artecsound.com/effect/se-ddb.htm', 'manufacturer_website', 'High');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, position)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Output', 'left');

INSERT INTO product_sources (product_id, jack_id, table_name, field_name, value_recorded, source_url, source_type, reliability)
VALUES (currval('products_id_seq'), currval('jacks_id_seq'), 'jacks', 'connector_type', '1/4" TS', 'http://artecsound.com/effect/se-ddb.htm', 'manufacturer_website', 'High');

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', 4, 'Center Negative');

INSERT INTO product_sources (product_id, jack_id, table_name, field_name, value_recorded, source_url, source_type, reliability)
VALUES (currval('products_id_seq'), currval('jacks_id_seq'), 'jacks', 'current_ma', '4mA', 'http://artecsound.com/effect/se-ddb.htm', 'manufacturer_website', 'High');

INSERT INTO product_sources (product_id, jack_id, table_name, field_name, value_recorded, source_url, source_type, reliability)
VALUES
    (currval('products_id_seq'), NULL, 'products', 'width_mm', '75.5mm', 'http://artecsound.com/effect/se-ddb.htm', 'manufacturer_website', 'High'),
    (currval('products_id_seq'), NULL, 'products', 'depth_mm', '47.5mm', 'http://artecsound.com/effect/se-ddb.htm', 'manufacturer_website', 'High'),
    (currval('products_id_seq'), NULL, 'products', 'height_mm', '115.5mm', 'http://artecsound.com/effect/se-ddb.htm', 'manufacturer_website', 'High'),
    (currval('products_id_seq'), NULL, 'products', 'weight_grams', '290g', 'http://artecsound.com/effect/se-ddb.htm', 'manufacturer_website', 'High');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ─── 3. SE-OE3 Acoustic Outboard EQ ─────────────────────────────────────────

INSERT INTO products (
    manufacturer_id, product_type_id, model,
    color_options, in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    msrp_cents, product_page, instruction_manual,
    description, tags, data_reliability, notes
) VALUES (
    25, 1, 'SE-OE3',
    NULL, TRUE,
    75.5, 47.5, 115.5, 320,
    NULL, 'https://artecsound.com/effect/se-oe3.htm', 'https://manuals.plus/artec/se-oe3-acoustic-outboard-eq-manual',
    'Three-band acoustic outboard EQ and preamp with notch filter for feedback control.',
    'eq,preamp,acoustic,analog',
    'High', 'Bypass type not specified on manufacturer page — left NULL.'
);

INSERT INTO pedal_details (product_id, effect_type, signal_type, bypass_type, mono_stereo)
VALUES (currval('products_id_seq'), 'Preamp', 'Analog', NULL, 'Mono');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, position)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS', 'Input', 'right');

INSERT INTO product_sources (product_id, jack_id, table_name, field_name, value_recorded, source_url, source_type, reliability)
VALUES (currval('products_id_seq'), currval('jacks_id_seq'), 'jacks', 'connector_type', '1/4" TS', 'https://artecsound.com/effect/se-oe3.htm', 'manufacturer_website', 'High');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, position)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Output', 'left');

INSERT INTO product_sources (product_id, jack_id, table_name, field_name, value_recorded, source_url, source_type, reliability)
VALUES (currval('products_id_seq'), currval('jacks_id_seq'), 'jacks', 'connector_type', '1/4" TS', 'https://artecsound.com/effect/se-oe3.htm', 'manufacturer_website', 'High');

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', 4, 'Center Negative');

INSERT INTO product_sources (product_id, jack_id, table_name, field_name, value_recorded, source_url, source_type, reliability)
VALUES (currval('products_id_seq'), currval('jacks_id_seq'), 'jacks', 'current_ma', '4mA', 'https://artecsound.com/effect/se-oe3.htm', 'manufacturer_website', 'High');

INSERT INTO product_sources (product_id, jack_id, table_name, field_name, value_recorded, source_url, source_type, reliability)
VALUES
    (currval('products_id_seq'), NULL, 'products', 'width_mm', '75.5mm', 'https://artecsound.com/effect/se-oe3.htm', 'manufacturer_website', 'High'),
    (currval('products_id_seq'), NULL, 'products', 'depth_mm', '47.5mm', 'https://artecsound.com/effect/se-oe3.htm', 'manufacturer_website', 'High'),
    (currval('products_id_seq'), NULL, 'products', 'height_mm', '115.5mm', 'https://artecsound.com/effect/se-oe3.htm', 'manufacturer_website', 'High'),
    (currval('products_id_seq'), NULL, 'products', 'weight_grams', '320g', 'https://artecsound.com/effect/se-oe3.htm', 'manufacturer_website', 'High');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ─── 4. SE-BEQ Bass EQ with Tuner ────────────────────────────────────────────

INSERT INTO products (
    manufacturer_id, product_type_id, model,
    color_options, in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    msrp_cents, product_page, instruction_manual,
    description, tags, data_reliability, notes
) VALUES (
    25, 1, 'SE-BEQ',
    NULL, TRUE,
    75.5, 47.5, 115.5, 290,
    NULL, 'https://artecsound.com/effect/se-beq.htm', NULL,
    '8-band graphic EQ for bass with built-in tuner.',
    'eq,bass,tuner,analog',
    'High', 'Bypass type not specified on manufacturer page — left NULL.'
);

INSERT INTO pedal_details (product_id, effect_type, signal_type, bypass_type, mono_stereo)
VALUES (currval('products_id_seq'), 'EQ', 'Analog', NULL, 'Mono');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, position)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS', 'Input', 'right');

INSERT INTO product_sources (product_id, jack_id, table_name, field_name, value_recorded, source_url, source_type, reliability)
VALUES (currval('products_id_seq'), currval('jacks_id_seq'), 'jacks', 'connector_type', '1/4" TS', 'https://artecsound.com/effect/se-beq.htm', 'manufacturer_website', 'High');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, position)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Output', 'left');

INSERT INTO product_sources (product_id, jack_id, table_name, field_name, value_recorded, source_url, source_type, reliability)
VALUES (currval('products_id_seq'), currval('jacks_id_seq'), 'jacks', 'connector_type', '1/4" TS', 'https://artecsound.com/effect/se-beq.htm', 'manufacturer_website', 'High');

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', 22, 'Center Negative');

INSERT INTO product_sources (product_id, jack_id, table_name, field_name, value_recorded, source_url, source_type, reliability)
VALUES (currval('products_id_seq'), currval('jacks_id_seq'), 'jacks', 'current_ma', '22mA', 'https://artecsound.com/effect/se-beq.htm', 'manufacturer_website', 'High');

INSERT INTO product_sources (product_id, jack_id, table_name, field_name, value_recorded, source_url, source_type, reliability)
VALUES
    (currval('products_id_seq'), NULL, 'products', 'width_mm', '75.5mm', 'https://artecsound.com/effect/se-beq.htm', 'manufacturer_website', 'High'),
    (currval('products_id_seq'), NULL, 'products', 'depth_mm', '47.5mm', 'https://artecsound.com/effect/se-beq.htm', 'manufacturer_website', 'High'),
    (currval('products_id_seq'), NULL, 'products', 'height_mm', '115.5mm', 'https://artecsound.com/effect/se-beq.htm', 'manufacturer_website', 'High'),
    (currval('products_id_seq'), NULL, 'products', 'weight_grams', '290g', 'https://artecsound.com/effect/se-beq.htm', 'manufacturer_website', 'High');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ─── 5. SE-GEQ Guitar EQ with Tuner ──────────────────────────────────────────

INSERT INTO products (
    manufacturer_id, product_type_id, model,
    color_options, in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    msrp_cents, product_page, instruction_manual,
    description, tags, data_reliability, notes
) VALUES (
    25, 1, 'SE-GEQ',
    NULL, TRUE,
    75.5, 47.5, 115.5, 290,
    NULL, 'https://artecsound.com/effect/se-geq.htm', NULL,
    '8-band graphic EQ for guitar with built-in tuner.',
    'eq,guitar,tuner,analog',
    'High', 'Bypass type not specified on manufacturer page — left NULL.'
);

INSERT INTO pedal_details (product_id, effect_type, signal_type, bypass_type, mono_stereo)
VALUES (currval('products_id_seq'), 'EQ', 'Analog', NULL, 'Mono');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, position)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS', 'Input', 'right');

INSERT INTO product_sources (product_id, jack_id, table_name, field_name, value_recorded, source_url, source_type, reliability)
VALUES (currval('products_id_seq'), currval('jacks_id_seq'), 'jacks', 'connector_type', '1/4" TS', 'https://artecsound.com/effect/se-geq.htm', 'manufacturer_website', 'High');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, position)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Output', 'left');

INSERT INTO product_sources (product_id, jack_id, table_name, field_name, value_recorded, source_url, source_type, reliability)
VALUES (currval('products_id_seq'), currval('jacks_id_seq'), 'jacks', 'connector_type', '1/4" TS', 'https://artecsound.com/effect/se-geq.htm', 'manufacturer_website', 'High');

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', 22, 'Center Negative');

INSERT INTO product_sources (product_id, jack_id, table_name, field_name, value_recorded, source_url, source_type, reliability)
VALUES (currval('products_id_seq'), currval('jacks_id_seq'), 'jacks', 'current_ma', '22mA', 'https://artecsound.com/effect/se-geq.htm', 'manufacturer_website', 'High');

INSERT INTO product_sources (product_id, jack_id, table_name, field_name, value_recorded, source_url, source_type, reliability)
VALUES
    (currval('products_id_seq'), NULL, 'products', 'width_mm', '75.5mm', 'https://artecsound.com/effect/se-geq.htm', 'manufacturer_website', 'High'),
    (currval('products_id_seq'), NULL, 'products', 'depth_mm', '47.5mm', 'https://artecsound.com/effect/se-geq.htm', 'manufacturer_website', 'High'),
    (currval('products_id_seq'), NULL, 'products', 'height_mm', '115.5mm', 'https://artecsound.com/effect/se-geq.htm', 'manufacturer_website', 'High'),
    (currval('products_id_seq'), NULL, 'products', 'weight_grams', '290g', 'https://artecsound.com/effect/se-geq.htm', 'manufacturer_website', 'High');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ─── 6. SE-ADL Analog Delay ───────────────────────────────────────────────────

INSERT INTO products (
    manufacturer_id, product_type_id, model,
    color_options, in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    msrp_cents, product_page, instruction_manual,
    description, tags, data_reliability, notes
) VALUES (
    25, 1, 'SE-ADL',
    NULL, TRUE,
    75.5, 47.5, 115.5, 290,
    NULL, 'http://www.artecsound.com/effect/se-adl.htm', NULL,
    'Analog delay with warm, natural repeats and true bypass switching.',
    'delay,analog,true-bypass',
    'High', NULL
);

INSERT INTO pedal_details (product_id, effect_type, signal_type, bypass_type, mono_stereo)
VALUES (currval('products_id_seq'), 'Delay', 'Analog', 'True Bypass', 'Mono');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, position)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS', 'Input', 'right');

INSERT INTO product_sources (product_id, jack_id, table_name, field_name, value_recorded, source_url, source_type, reliability)
VALUES (currval('products_id_seq'), currval('jacks_id_seq'), 'jacks', 'connector_type', '1/4" TS', 'http://www.artecsound.com/effect/se-adl.htm', 'manufacturer_website', 'High');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, position)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Output', 'left');

INSERT INTO product_sources (product_id, jack_id, table_name, field_name, value_recorded, source_url, source_type, reliability)
VALUES (currval('products_id_seq'), currval('jacks_id_seq'), 'jacks', 'connector_type', '1/4" TS', 'http://www.artecsound.com/effect/se-adl.htm', 'manufacturer_website', 'High');

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', 23, 'Center Negative');

INSERT INTO product_sources (product_id, jack_id, table_name, field_name, value_recorded, source_url, source_type, reliability)
VALUES (currval('products_id_seq'), currval('jacks_id_seq'), 'jacks', 'current_ma', '23mA', 'http://www.artecsound.com/effect/se-adl.htm', 'manufacturer_website', 'High');

INSERT INTO product_sources (product_id, jack_id, table_name, field_name, value_recorded, source_url, source_type, reliability)
VALUES
    (currval('products_id_seq'), NULL, 'products', 'width_mm', '75.5mm', 'http://www.artecsound.com/effect/se-adl.htm', 'manufacturer_website', 'High'),
    (currval('products_id_seq'), NULL, 'products', 'depth_mm', '47.5mm', 'http://www.artecsound.com/effect/se-adl.htm', 'manufacturer_website', 'High'),
    (currval('products_id_seq'), NULL, 'products', 'height_mm', '115.5mm', 'http://www.artecsound.com/effect/se-adl.htm', 'manufacturer_website', 'High'),
    (currval('products_id_seq'), NULL, 'products', 'weight_grams', '290g', 'http://www.artecsound.com/effect/se-adl.htm', 'manufacturer_website', 'High');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ─── 7. SE-FLG Vintage Flanger ────────────────────────────────────────────────

INSERT INTO products (
    manufacturer_id, product_type_id, model,
    color_options, in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    msrp_cents, product_page, instruction_manual,
    description, tags, data_reliability, notes
) VALUES (
    25, 1, 'SE-FLG',
    NULL, TRUE,
    75.5, 47.5, 115.5, 260,
    NULL, 'https://artecsound.com/effect/se-flg.htm', NULL,
    'Vintage-voiced flanger with BBD-based analog circuit.',
    'flanger,analog',
    'High', 'Bypass type not specified on manufacturer page — left NULL. Dimensions user-confirmed as 75.5(w) × 115.5(h) × 47.5(d) mm after conflicting source data.'
);

INSERT INTO pedal_details (product_id, effect_type, signal_type, bypass_type, mono_stereo)
VALUES (currval('products_id_seq'), 'Flanger', 'Analog', NULL, 'Mono');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, position)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS', 'Input', 'right');

INSERT INTO product_sources (product_id, jack_id, table_name, field_name, value_recorded, source_url, source_type, reliability)
VALUES (currval('products_id_seq'), currval('jacks_id_seq'), 'jacks', 'connector_type', '1/4" TS', 'https://artecsound.com/effect/se-flg.htm', 'manufacturer_website', 'High');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, position)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Output', 'left');

INSERT INTO product_sources (product_id, jack_id, table_name, field_name, value_recorded, source_url, source_type, reliability)
VALUES (currval('products_id_seq'), currval('jacks_id_seq'), 'jacks', 'connector_type', '1/4" TS', 'https://artecsound.com/effect/se-flg.htm', 'manufacturer_website', 'High');

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', 14, 'Center Negative');

INSERT INTO product_sources (product_id, jack_id, table_name, field_name, value_recorded, source_url, source_type, reliability)
VALUES (currval('products_id_seq'), currval('jacks_id_seq'), 'jacks', 'current_ma', '14mA', 'https://artecsound.com/effect/se-flg.htm', 'manufacturer_website', 'High');

INSERT INTO product_sources (product_id, jack_id, table_name, field_name, value_recorded, source_url, source_type, reliability)
VALUES
    (currval('products_id_seq'), NULL, 'products', 'width_mm', '75.5mm', 'https://artecsound.com/effect/se-flg.htm', 'manufacturer_website', 'High'),
    (currval('products_id_seq'), NULL, 'products', 'depth_mm', '47.5mm', 'https://artecsound.com/effect/se-flg.htm', 'manufacturer_website', 'High'),
    (currval('products_id_seq'), NULL, 'products', 'height_mm', '115.5mm', 'https://artecsound.com/effect/se-flg.htm', 'manufacturer_website', 'High'),
    (currval('products_id_seq'), NULL, 'products', 'weight_grams', '260g', 'https://artecsound.com/effect/se-flg.htm', 'manufacturer_website', 'High');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ─── 8. SE-VPH Vintage Phase Shifter ─────────────────────────────────────────

INSERT INTO products (
    manufacturer_id, product_type_id, model,
    color_options, in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    msrp_cents, product_page, instruction_manual,
    description, tags, data_reliability, notes
) VALUES (
    25, 1, 'SE-VPH',
    NULL, TRUE,
    75.5, 47.5, 115.5, 290,
    NULL, 'http://artecsound.com/effect/se-vph.htm', NULL,
    'Vintage-voiced analog phase shifter.',
    'phaser,analog',
    'High', 'Bypass type not specified on manufacturer page — left NULL.'
);

INSERT INTO pedal_details (product_id, effect_type, signal_type, bypass_type, mono_stereo)
VALUES (currval('products_id_seq'), 'Phaser', 'Analog', NULL, 'Mono');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, position)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS', 'Input', 'right');

INSERT INTO product_sources (product_id, jack_id, table_name, field_name, value_recorded, source_url, source_type, reliability)
VALUES (currval('products_id_seq'), currval('jacks_id_seq'), 'jacks', 'connector_type', '1/4" TS', 'http://artecsound.com/effect/se-vph.htm', 'manufacturer_website', 'High');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, position)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Output', 'left');

INSERT INTO product_sources (product_id, jack_id, table_name, field_name, value_recorded, source_url, source_type, reliability)
VALUES (currval('products_id_seq'), currval('jacks_id_seq'), 'jacks', 'connector_type', '1/4" TS', 'http://artecsound.com/effect/se-vph.htm', 'manufacturer_website', 'High');

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', 14, 'Center Negative');

INSERT INTO product_sources (product_id, jack_id, table_name, field_name, value_recorded, source_url, source_type, reliability)
VALUES (currval('products_id_seq'), currval('jacks_id_seq'), 'jacks', 'current_ma', '14mA', 'http://artecsound.com/effect/se-vph.htm', 'manufacturer_website', 'High');

INSERT INTO product_sources (product_id, jack_id, table_name, field_name, value_recorded, source_url, source_type, reliability)
VALUES
    (currval('products_id_seq'), NULL, 'products', 'width_mm', '75.5mm', 'http://artecsound.com/effect/se-vph.htm', 'manufacturer_website', 'High'),
    (currval('products_id_seq'), NULL, 'products', 'depth_mm', '47.5mm', 'http://artecsound.com/effect/se-vph.htm', 'manufacturer_website', 'High'),
    (currval('products_id_seq'), NULL, 'products', 'height_mm', '115.5mm', 'http://artecsound.com/effect/se-vph.htm', 'manufacturer_website', 'High'),
    (currval('products_id_seq'), NULL, 'products', 'weight_grams', '290g', 'http://artecsound.com/effect/se-vph.htm', 'manufacturer_website', 'High');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ─── 9. SE-VTM Vintage Tremolo ────────────────────────────────────────────────

INSERT INTO products (
    manufacturer_id, product_type_id, model,
    color_options, in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    msrp_cents, product_page, instruction_manual,
    description, tags, data_reliability, notes
) VALUES (
    25, 1, 'SE-VTM',
    NULL, TRUE,
    75.5, 47.5, 115.5, 290,
    NULL, 'http://artecsound.com/effect/se-vtm.htm', NULL,
    'Vintage-voiced analog tremolo with rate and depth controls.',
    'tremolo,analog',
    'High', 'Bypass type not specified on manufacturer page — left NULL.'
);

INSERT INTO pedal_details (product_id, effect_type, signal_type, bypass_type, mono_stereo)
VALUES (currval('products_id_seq'), 'Tremolo', 'Analog', NULL, 'Mono');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, position)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS', 'Input', 'right');

INSERT INTO product_sources (product_id, jack_id, table_name, field_name, value_recorded, source_url, source_type, reliability)
VALUES (currval('products_id_seq'), currval('jacks_id_seq'), 'jacks', 'connector_type', '1/4" TS', 'http://artecsound.com/effect/se-vtm.htm', 'manufacturer_website', 'High');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, position)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Output', 'left');

INSERT INTO product_sources (product_id, jack_id, table_name, field_name, value_recorded, source_url, source_type, reliability)
VALUES (currval('products_id_seq'), currval('jacks_id_seq'), 'jacks', 'connector_type', '1/4" TS', 'http://artecsound.com/effect/se-vtm.htm', 'manufacturer_website', 'High');

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', 8, 'Center Negative');

INSERT INTO product_sources (product_id, jack_id, table_name, field_name, value_recorded, source_url, source_type, reliability)
VALUES (currval('products_id_seq'), currval('jacks_id_seq'), 'jacks', 'current_ma', '8mA', 'http://artecsound.com/effect/se-vtm.htm', 'manufacturer_website', 'High');

INSERT INTO product_sources (product_id, jack_id, table_name, field_name, value_recorded, source_url, source_type, reliability)
VALUES
    (currval('products_id_seq'), NULL, 'products', 'width_mm', '75.5mm', 'http://artecsound.com/effect/se-vtm.htm', 'manufacturer_website', 'High'),
    (currval('products_id_seq'), NULL, 'products', 'depth_mm', '47.5mm', 'http://artecsound.com/effect/se-vtm.htm', 'manufacturer_website', 'High'),
    (currval('products_id_seq'), NULL, 'products', 'height_mm', '115.5mm', 'http://artecsound.com/effect/se-vtm.htm', 'manufacturer_website', 'High'),
    (currval('products_id_seq'), NULL, 'products', 'weight_grams', '290g', 'http://artecsound.com/effect/se-vtm.htm', 'manufacturer_website', 'High');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ─── 10. SE-VCH Vintage Chorus ───────────────────────────────────────────────

INSERT INTO products (
    manufacturer_id, product_type_id, model,
    color_options, in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    msrp_cents, product_page, instruction_manual,
    description, tags, data_reliability, notes
) VALUES (
    25, 1, 'SE-VCH',
    NULL, TRUE,
    75.5, 47.5, 115.5, 290,
    NULL, 'https://artecsound.com/effect/se-vch.htm', NULL,
    'Fully analog vintage chorus with BBD circuit for warm, lush modulation.',
    'chorus,analog',
    'High', 'Bypass type not specified on manufacturer page — left NULL.'
);

INSERT INTO pedal_details (product_id, effect_type, signal_type, bypass_type, mono_stereo)
VALUES (currval('products_id_seq'), 'Chorus', 'Analog', NULL, 'Mono');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, position)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS', 'Input', 'right');

INSERT INTO product_sources (product_id, jack_id, table_name, field_name, value_recorded, source_url, source_type, reliability)
VALUES (currval('products_id_seq'), currval('jacks_id_seq'), 'jacks', 'connector_type', '1/4" TS', 'https://artecsound.com/effect/se-vch.htm', 'manufacturer_website', 'High');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, position)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Output', 'left');

INSERT INTO product_sources (product_id, jack_id, table_name, field_name, value_recorded, source_url, source_type, reliability)
VALUES (currval('products_id_seq'), currval('jacks_id_seq'), 'jacks', 'connector_type', '1/4" TS', 'https://artecsound.com/effect/se-vch.htm', 'manufacturer_website', 'High');

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', 28, 'Center Negative');

INSERT INTO product_sources (product_id, jack_id, table_name, field_name, value_recorded, source_url, source_type, reliability)
VALUES (currval('products_id_seq'), currval('jacks_id_seq'), 'jacks', 'current_ma', '28mA', 'https://artecsound.com/effect/se-vch.htm', 'manufacturer_website', 'High');

INSERT INTO product_sources (product_id, jack_id, table_name, field_name, value_recorded, source_url, source_type, reliability)
VALUES
    (currval('products_id_seq'), NULL, 'products', 'width_mm', '75.5mm', 'https://artecsound.com/effect/se-vch.htm', 'manufacturer_website', 'High'),
    (currval('products_id_seq'), NULL, 'products', 'depth_mm', '47.5mm', 'https://artecsound.com/effect/se-vch.htm', 'manufacturer_website', 'High'),
    (currval('products_id_seq'), NULL, 'products', 'height_mm', '115.5mm', 'https://artecsound.com/effect/se-vch.htm', 'manufacturer_website', 'High'),
    (currval('products_id_seq'), NULL, 'products', 'weight_grams', '290g', 'https://artecsound.com/effect/se-vch.htm', 'manufacturer_website', 'High');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ─── 11. CDV-1 Cool Drive (discontinued) ─────────────────────────────────────
-- Product page URL from manufacturer is "cdw-1.htm" (apparent typo on manufacturer site)

INSERT INTO products (
    manufacturer_id, product_type_id, model,
    color_options, in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    msrp_cents, product_page, instruction_manual,
    description, tags, data_reliability, notes
) VALUES (
    25, 1, 'CDV-1',
    NULL, FALSE,
    93.0, 48.0, 123.0, 360,
    NULL, 'http://artecsound.com/effect/cdw-1.htm', NULL,
    'Vintage overdrive with true bypass and warm, touch-sensitive response.',
    'overdrive,gain,analog,true-bypass,discontinued',
    'High', 'Product page URL slug on manufacturer site reads "cdw-1" (apparent typo). Discontinued per user decision.'
);

INSERT INTO pedal_details (product_id, effect_type, signal_type, bypass_type, mono_stereo)
VALUES (currval('products_id_seq'), 'Gain', 'Analog', 'True Bypass', 'Mono');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, position)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS', 'Input', 'right');

INSERT INTO product_sources (product_id, jack_id, table_name, field_name, value_recorded, source_url, source_type, reliability)
VALUES (currval('products_id_seq'), currval('jacks_id_seq'), 'jacks', 'connector_type', '1/4" TS', 'http://artecsound.com/effect/cdw-1.htm', 'manufacturer_website', 'High');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, position)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Output', 'left');

INSERT INTO product_sources (product_id, jack_id, table_name, field_name, value_recorded, source_url, source_type, reliability)
VALUES (currval('products_id_seq'), currval('jacks_id_seq'), 'jacks', 'connector_type', '1/4" TS', 'http://artecsound.com/effect/cdw-1.htm', 'manufacturer_website', 'High');

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', 12, 'Center Negative');

INSERT INTO product_sources (product_id, jack_id, table_name, field_name, value_recorded, source_url, source_type, reliability)
VALUES (currval('products_id_seq'), currval('jacks_id_seq'), 'jacks', 'current_ma', '12mA', 'http://artecsound.com/effect/cdw-1.htm', 'manufacturer_website', 'High');

INSERT INTO product_sources (product_id, jack_id, table_name, field_name, value_recorded, source_url, source_type, reliability)
VALUES
    (currval('products_id_seq'), NULL, 'products', 'width_mm', '93mm', 'http://artecsound.com/effect/cdw-1.htm', 'manufacturer_website', 'High'),
    (currval('products_id_seq'), NULL, 'products', 'depth_mm', '48mm', 'http://artecsound.com/effect/cdw-1.htm', 'manufacturer_website', 'High'),
    (currval('products_id_seq'), NULL, 'products', 'height_mm', '123mm', 'http://artecsound.com/effect/cdw-1.htm', 'manufacturer_website', 'High'),
    (currval('products_id_seq'), NULL, 'products', 'weight_grams', '360g', 'http://artecsound.com/effect/cdw-1.htm', 'manufacturer_website', 'High');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ─── 12. SE-NGT Noise Gate (utility) ─────────────────────────────────────────

INSERT INTO products (
    manufacturer_id, product_type_id, model,
    color_options, in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    msrp_cents, product_page, instruction_manual,
    description, tags, data_reliability, notes
) VALUES (
    25, 5, 'SE-NGT',
    NULL, TRUE,
    75.5, 47.5, 115.5, 290,
    NULL, 'http://www.artecsound.com/effect/se-ngt.htm', NULL,
    'Active noise gate with true bypass stomp switch.',
    'noise-gate,utility,true-bypass',
    'High', NULL
);

INSERT INTO utility_details (product_id, utility_type, is_active, signal_type, bypass_type)
VALUES (currval('products_id_seq'), 'Noise Gate', TRUE, 'Analog', 'True Bypass');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, position)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS', 'Input', 'right');

INSERT INTO product_sources (product_id, jack_id, table_name, field_name, value_recorded, source_url, source_type, reliability)
VALUES (currval('products_id_seq'), currval('jacks_id_seq'), 'jacks', 'connector_type', '1/4" TS', 'http://www.artecsound.com/effect/se-ngt.htm', 'manufacturer_website', 'High');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, position)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Output', 'left');

INSERT INTO product_sources (product_id, jack_id, table_name, field_name, value_recorded, source_url, source_type, reliability)
VALUES (currval('products_id_seq'), currval('jacks_id_seq'), 'jacks', 'connector_type', '1/4" TS', 'http://www.artecsound.com/effect/se-ngt.htm', 'manufacturer_website', 'High');

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', 11, 'Center Negative');

INSERT INTO product_sources (product_id, jack_id, table_name, field_name, value_recorded, source_url, source_type, reliability)
VALUES (currval('products_id_seq'), currval('jacks_id_seq'), 'jacks', 'current_ma', '11mA', 'http://www.artecsound.com/effect/se-ngt.htm', 'manufacturer_website', 'High');

INSERT INTO product_sources (product_id, jack_id, table_name, field_name, value_recorded, source_url, source_type, reliability)
VALUES
    (currval('products_id_seq'), NULL, 'products', 'width_mm', '75.5mm', 'http://www.artecsound.com/effect/se-ngt.htm', 'manufacturer_website', 'High'),
    (currval('products_id_seq'), NULL, 'products', 'depth_mm', '47.5mm', 'http://www.artecsound.com/effect/se-ngt.htm', 'manufacturer_website', 'High'),
    (currval('products_id_seq'), NULL, 'products', 'height_mm', '115.5mm', 'http://www.artecsound.com/effect/se-ngt.htm', 'manufacturer_website', 'High'),
    (currval('products_id_seq'), NULL, 'products', 'weight_grams', '290g', 'http://www.artecsound.com/effect/se-ngt.htm', 'manufacturer_website', 'High');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ─── 13. SE-2FS 2-Channel Footswitch (utility) ───────────────────────────────
-- Passive device — no power jack. Two 1/4" TS aux output jacks for amp switching.

INSERT INTO products (
    manufacturer_id, product_type_id, model,
    color_options, in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    msrp_cents, product_page, instruction_manual,
    description, tags, data_reliability, notes
) VALUES (
    25, 5, 'SE-2FS',
    NULL, TRUE,
    75.5, 47.5, 115.5, 280,
    NULL, 'https://artecsound.com/effect/se-2fs.htm', NULL,
    'Passive 2-channel footswitch for controlling amplifier channel switching.',
    'footswitch,aux-switch,utility,passive',
    'High', NULL
);

INSERT INTO utility_details (product_id, utility_type, is_active, signal_type)
VALUES (currval('products_id_seq'), 'Aux Switch', FALSE, 'Analog');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, position)
VALUES (currval('products_id_seq'), 'aux', 'output', '1/4" TS', 'Channel A', 'back');

INSERT INTO product_sources (product_id, jack_id, table_name, field_name, value_recorded, source_url, source_type, reliability)
VALUES (currval('products_id_seq'), currval('jacks_id_seq'), 'jacks', 'connector_type', '1/4" TS', 'https://artecsound.com/effect/se-2fs.htm', 'manufacturer_website', 'High');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, position)
VALUES (currval('products_id_seq'), 'aux', 'output', '1/4" TS', 'Channel B', 'back');

INSERT INTO product_sources (product_id, jack_id, table_name, field_name, value_recorded, source_url, source_type, reliability)
VALUES (currval('products_id_seq'), currval('jacks_id_seq'), 'jacks', 'connector_type', '1/4" TS', 'https://artecsound.com/effect/se-2fs.htm', 'manufacturer_website', 'High');

INSERT INTO product_sources (product_id, jack_id, table_name, field_name, value_recorded, source_url, source_type, reliability)
VALUES
    (currval('products_id_seq'), NULL, 'products', 'width_mm', '75.5mm', 'https://artecsound.com/effect/se-2fs.htm', 'manufacturer_website', 'High'),
    (currval('products_id_seq'), NULL, 'products', 'depth_mm', '47.5mm', 'https://artecsound.com/effect/se-2fs.htm', 'manufacturer_website', 'High'),
    (currval('products_id_seq'), NULL, 'products', 'height_mm', '115.5mm', 'https://artecsound.com/effect/se-2fs.htm', 'manufacturer_website', 'High'),
    (currval('products_id_seq'), NULL, 'products', 'weight_grams', '280g', 'https://artecsound.com/effect/se-2fs.htm', 'manufacturer_website', 'High');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ─── 14. SE-SWB A/B Switch Box (utility) ─────────────────────────────────────
-- Passive A/B box. Optional 9V for LED only — power jack omitted; device is
-- passive and should not appear in the power budget.

INSERT INTO products (
    manufacturer_id, product_type_id, model,
    color_options, in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    msrp_cents, product_page, instruction_manual,
    description, tags, data_reliability, notes
) VALUES (
    25, 5, 'SE-SWB',
    NULL, TRUE,
    75.5, 47.5, 115.5, 260,
    NULL, 'http://www.artecsound.com/effect/se-swb.htm', NULL,
    'Passive A/B switch box with true bypass switching; optional 9V power for LED indicator.',
    'a/b-box,utility,true-bypass,passive',
    'High', 'Core function is passive. 9V power input present for optional LED indicator only (4mA when LED active).'
);

INSERT INTO utility_details (product_id, utility_type, is_active, signal_type, bypass_type)
VALUES (currval('products_id_seq'), 'A/B Box', FALSE, 'Analog', 'True Bypass');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, position)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS', 'Input', 'right');

INSERT INTO product_sources (product_id, jack_id, table_name, field_name, value_recorded, source_url, source_type, reliability)
VALUES (currval('products_id_seq'), currval('jacks_id_seq'), 'jacks', 'connector_type', '1/4" TS', 'http://www.artecsound.com/effect/se-swb.htm', 'manufacturer_website', 'High');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, position)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Output A', 'left');

INSERT INTO product_sources (product_id, jack_id, table_name, field_name, value_recorded, source_url, source_type, reliability)
VALUES (currval('products_id_seq'), currval('jacks_id_seq'), 'jacks', 'connector_type', '1/4" TS', 'http://www.artecsound.com/effect/se-swb.htm', 'manufacturer_website', 'High');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, position)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Output B', 'left');

INSERT INTO product_sources (product_id, jack_id, table_name, field_name, value_recorded, source_url, source_type, reliability)
VALUES (currval('products_id_seq'), currval('jacks_id_seq'), 'jacks', 'connector_type', '1/4" TS', 'http://www.artecsound.com/effect/se-swb.htm', 'manufacturer_website', 'High');

INSERT INTO product_sources (product_id, jack_id, table_name, field_name, value_recorded, source_url, source_type, reliability)
VALUES
    (currval('products_id_seq'), NULL, 'products', 'width_mm', '75.5mm', 'http://www.artecsound.com/effect/se-swb.htm', 'manufacturer_website', 'High'),
    (currval('products_id_seq'), NULL, 'products', 'depth_mm', '47.5mm', 'http://www.artecsound.com/effect/se-swb.htm', 'manufacturer_website', 'High'),
    (currval('products_id_seq'), NULL, 'products', 'height_mm', '115.5mm', 'http://www.artecsound.com/effect/se-swb.htm', 'manufacturer_website', 'High'),
    (currval('products_id_seq'), NULL, 'products', 'weight_grams', '260g', 'http://www.artecsound.com/effect/se-swb.htm', 'manufacturer_website', 'High');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ─── 15. VPL-1 Active Volume Pedal (utility) ─────────────────────────────────
-- Active volume pedal with main output and fixed-level tuner output.

INSERT INTO products (
    manufacturer_id, product_type_id, model,
    color_options, in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    msrp_cents, product_page, instruction_manual,
    description, tags, data_reliability, notes
) VALUES (
    25, 5, 'VPL-1',
    NULL, TRUE,
    95.5, 253.0, 74.0, 1200,
    NULL, 'http://www.artecsound.com/effect/vpl-1.htm', NULL,
    'Active volume pedal with main output and fixed-level tuner output.',
    'volume-pedal,utility,active',
    'High', 'Bypass type not specified on manufacturer page — left NULL.'
);

INSERT INTO utility_details (product_id, utility_type, is_active, signal_type, has_tuner_out)
VALUES (currval('products_id_seq'), 'Volume Pedal', TRUE, 'Analog', TRUE);

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, position)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS', 'Input', 'right');

INSERT INTO product_sources (product_id, jack_id, table_name, field_name, value_recorded, source_url, source_type, reliability)
VALUES (currval('products_id_seq'), currval('jacks_id_seq'), 'jacks', 'connector_type', '1/4" TS', 'http://www.artecsound.com/effect/vpl-1.htm', 'manufacturer_website', 'High');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, position)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Output', 'left');

INSERT INTO product_sources (product_id, jack_id, table_name, field_name, value_recorded, source_url, source_type, reliability)
VALUES (currval('products_id_seq'), currval('jacks_id_seq'), 'jacks', 'connector_type', '1/4" TS', 'http://www.artecsound.com/effect/vpl-1.htm', 'manufacturer_website', 'High');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, position)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Tuner Out', 'left');

INSERT INTO product_sources (product_id, jack_id, table_name, field_name, value_recorded, source_url, source_type, reliability)
VALUES (currval('products_id_seq'), currval('jacks_id_seq'), 'jacks', 'connector_type', '1/4" TS', 'http://www.artecsound.com/effect/vpl-1.htm', 'manufacturer_website', 'High');

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', 14, 'Center Negative');

INSERT INTO product_sources (product_id, jack_id, table_name, field_name, value_recorded, source_url, source_type, reliability)
VALUES (currval('products_id_seq'), currval('jacks_id_seq'), 'jacks', 'current_ma', '14mA', 'http://www.artecsound.com/effect/vpl-1.htm', 'manufacturer_website', 'High');

INSERT INTO product_sources (product_id, jack_id, table_name, field_name, value_recorded, source_url, source_type, reliability)
VALUES
    (currval('products_id_seq'), NULL, 'products', 'width_mm', '95.5mm', 'http://www.artecsound.com/effect/vpl-1.htm', 'manufacturer_website', 'High'),
    (currval('products_id_seq'), NULL, 'products', 'depth_mm', '253mm', 'http://www.artecsound.com/effect/vpl-1.htm', 'manufacturer_website', 'High'),
    (currval('products_id_seq'), NULL, 'products', 'height_mm', '74mm', 'http://www.artecsound.com/effect/vpl-1.htm', 'manufacturer_website', 'High'),
    (currval('products_id_seq'), NULL, 'products', 'weight_grams', '1200g', 'http://www.artecsound.com/effect/vpl-1.htm', 'manufacturer_website', 'High');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

COMMIT;
