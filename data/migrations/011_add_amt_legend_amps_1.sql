-- =============================================================================
-- MIGRATION 011: AMT Electronics — Legend Amps I Series (LA-1)
-- Manufacturer: AMT Electronics (id = 14)
-- 8 models: P-1, M-1, S-1, B-1, E-1, F-1, R-1, V-1
-- All: JFET preamp emulators; 113 × 74 × 54 mm; 9-12V / 6 mA / True Bypass / Analog
-- "Sold out" models: in_production = NULL (ambiguous — out of stock vs. discontinued)
-- F-1 and V-1 have serial FX loops; built-in power hub jacks omitted (connector type unknown)
-- Sources: AMT official website, amt-sales.com, manufacturer manuals
-- Researched: 2026-03-21
-- =============================================================================


-- ─── 1. P-1 (Peavey 5150) ────────────────────────────────────────────────────
BEGIN;

INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    product_page, instruction_manual,
    description, data_reliability,
    notes
) VALUES (
    14, 1, 'P-1',
    NULL,
    113.0, 74.0, 54.0, 275,
    'https://amtelectronics.com/new/amt-p1/', 'https://amtelectronics.com/new/manuals/LA-P1-manual-ENG.pdf',
    'Single-channel JFET preamp emulating the Peavey 5150. Two simultaneous outputs: direct amp out and cab-simulated out.',
    'High',
    'Sold out on amt-sales.com as of 2026-03-21; in_production unknown — may be discontinued or temporarily out of stock.'
);

INSERT INTO pedal_details (product_id, effect_type, signal_type, bypass_type, mono_stereo, battery_capable, fx_loop_count)
VALUES (currval('products_id_seq'), 'Preamp', 'Analog', 'True Bypass', 'Mono', FALSE, 0);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9-12V', 6, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS', 'Input');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Direct Amp Out');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Cab Sim Out');

INSERT INTO product_sources (product_id, table_name, field_name, value_recorded, source_type, source_url, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'width_mm',           '113 × 74 × 54 mm',                                                    'manufacturer_website', 'https://amt-sales.com/', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'depth_mm',           '113 × 74 × 54 mm',                                                    'manufacturer_website', 'https://amt-sales.com/', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'height_mm',          '113 × 74 × 54 mm',                                                    'manufacturer_website', 'https://amt-sales.com/', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'weight_grams',       '275 g',                                                               'manufacturer_website', 'https://amt-sales.com/', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'product_page',       'https://amtelectronics.com/new/amt-p1/',                              'manufacturer_website', 'https://amtelectronics.com/', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'instruction_manual', 'https://amtelectronics.com/new/manuals/LA-P1-manual-ENG.pdf',         'manufacturer_manual',  'https://amtelectronics.com/new/manuals/LA-P1-manual-ENG.pdf', 'High', '2026-03-21');

INSERT INTO product_sources (product_id, table_name, field_name, value_recorded, source_type, source_url, reliability, accessed_at, jack_id)
VALUES (currval('products_id_seq'), 'jacks', 'current_ma', '6 mA (4 mA power-saving mode)', 'manufacturer_manual', 'https://amtelectronics.com/new/manuals/LA-P1-manual-ENG.pdf', 'High', '2026-03-21',
    (SELECT id FROM jacks WHERE product_id = currval('products_id_seq') AND category = 'power' AND direction = 'input'));

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');
COMMIT;


-- ─── 2. M-1 (Marshall JCM-800) ───────────────────────────────────────────────
BEGIN;

INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    product_page, instruction_manual,
    description, data_reliability,
    notes
) VALUES (
    14, 1, 'M-1',
    NULL,
    113.0, 74.0, 54.0, 268,
    'https://amtelectronics.com/new/amt-m1/', 'https://amtelectronics.com/new/manuals/LA-M1-manual-ENG.pdf',
    'Single-channel JFET preamp emulating the Marshall JCM-800. Two simultaneous outputs: direct amp out and cab-simulated out.',
    'High',
    'Sold out on amt-sales.com as of 2026-03-21; in_production unknown.'
);

INSERT INTO pedal_details (product_id, effect_type, signal_type, bypass_type, mono_stereo, battery_capable, fx_loop_count)
VALUES (currval('products_id_seq'), 'Preamp', 'Analog', 'True Bypass', 'Mono', FALSE, 0);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9-12V', 6, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS', 'Input');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Direct Amp Out');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Cab Sim Out');

INSERT INTO product_sources (product_id, table_name, field_name, value_recorded, source_type, source_url, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'width_mm',           '113 × 74 × 54 mm',                                                    'manufacturer_website', 'https://amt-sales.com/', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'depth_mm',           '113 × 74 × 54 mm',                                                    'manufacturer_website', 'https://amt-sales.com/', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'height_mm',          '113 × 74 × 54 mm',                                                    'manufacturer_website', 'https://amt-sales.com/', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'weight_grams',       '268 g',                                                               'manufacturer_website', 'https://amt-sales.com/', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'product_page',       'https://amtelectronics.com/new/amt-m1/',                              'manufacturer_website', 'https://amtelectronics.com/', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'instruction_manual', 'https://amtelectronics.com/new/manuals/LA-M1-manual-ENG.pdf',         'manufacturer_manual',  'https://amtelectronics.com/new/manuals/LA-M1-manual-ENG.pdf', 'High', '2026-03-21');

INSERT INTO product_sources (product_id, table_name, field_name, value_recorded, source_type, source_url, reliability, accessed_at, jack_id)
VALUES (currval('products_id_seq'), 'jacks', 'current_ma', '6 mA (4 mA power-saving mode)', 'manufacturer_manual', 'https://amtelectronics.com/new/manuals/LA-M1-manual-ENG.pdf', 'High', '2026-03-21',
    (SELECT id FROM jacks WHERE product_id = currval('products_id_seq') AND category = 'power' AND direction = 'input'));

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');
COMMIT;


-- ─── 3. S-1 (Soldano) ────────────────────────────────────────────────────────
BEGIN;

INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    product_page, instruction_manual,
    description, data_reliability,
    notes
) VALUES (
    14, 1, 'S-1',
    NULL,
    113.0, 74.0, 54.0, 275,
    'https://amtelectronics.com/new/amt-s1/', 'https://amtelectronics.com/new/manuals/LA-S1-manual-ENG.pdf',
    'Single-channel JFET preamp emulating the high-gain Soldano amplifier. Two simultaneous outputs: direct amp out and cab-simulated out.',
    'High',
    'Sold out on amt-sales.com as of 2026-03-21; in_production unknown.'
);

INSERT INTO pedal_details (product_id, effect_type, signal_type, bypass_type, mono_stereo, battery_capable, fx_loop_count)
VALUES (currval('products_id_seq'), 'Preamp', 'Analog', 'True Bypass', 'Mono', FALSE, 0);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9-12V', 6, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS', 'Input');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Direct Amp Out');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Cab Sim Out');

INSERT INTO product_sources (product_id, table_name, field_name, value_recorded, source_type, source_url, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'width_mm',           '113 × 74 × 54 mm',                                                    'manufacturer_website', 'https://amt-sales.com/', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'depth_mm',           '113 × 74 × 54 mm',                                                    'manufacturer_website', 'https://amt-sales.com/', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'height_mm',          '113 × 74 × 54 mm',                                                    'manufacturer_website', 'https://amt-sales.com/', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'weight_grams',       '275 g',                                                               'manufacturer_website', 'https://amt-sales.com/', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'product_page',       'https://amtelectronics.com/new/amt-s1/',                              'manufacturer_website', 'https://amtelectronics.com/', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'instruction_manual', 'https://amtelectronics.com/new/manuals/LA-S1-manual-ENG.pdf',         'manufacturer_manual',  'https://amtelectronics.com/new/manuals/LA-S1-manual-ENG.pdf', 'High', '2026-03-21');

INSERT INTO product_sources (product_id, table_name, field_name, value_recorded, source_type, source_url, reliability, accessed_at, jack_id)
VALUES (currval('products_id_seq'), 'jacks', 'current_ma', '6 mA (4 mA power-saving mode)', 'manufacturer_manual', 'https://amtelectronics.com/new/manuals/LA-S1-manual-ENG.pdf', 'High', '2026-03-21',
    (SELECT id FROM jacks WHERE product_id = currval('products_id_seq') AND category = 'power' AND direction = 'input'));

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');
COMMIT;


-- ─── 4. B-1 (Bogner Sharp Channel) ───────────────────────────────────────────
BEGIN;

INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm,
    product_page, instruction_manual,
    description, data_reliability
) VALUES (
    14, 1, 'B-1',
    TRUE,
    113.0, 74.0, 54.0,
    'https://amtelectronics.com/new/amt-b1/', 'https://amtelectronics.com/new/manuals/LA-B1-manual-ENG.pdf',
    'Single-channel JFET preamp emulating the Bogner Sharp Channel. Two simultaneous outputs: direct amp out and cab-simulated out.',
    'High'
);

INSERT INTO pedal_details (product_id, effect_type, signal_type, bypass_type, mono_stereo, battery_capable, fx_loop_count)
VALUES (currval('products_id_seq'), 'Preamp', 'Analog', 'True Bypass', 'Mono', FALSE, 0);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9-12V', 6, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS', 'Input');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Direct Amp Out');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Cab Sim Out');

INSERT INTO product_sources (product_id, table_name, field_name, value_recorded, source_type, source_url, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'width_mm',           '113 × 74 × 54 mm',                                                    'manufacturer_website', 'https://amt-sales.com/', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'depth_mm',           '113 × 74 × 54 mm',                                                    'manufacturer_website', 'https://amt-sales.com/', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'height_mm',          '113 × 74 × 54 mm',                                                    'manufacturer_website', 'https://amt-sales.com/', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'product_page',       'https://amtelectronics.com/new/amt-b1/',                              'manufacturer_website', 'https://amtelectronics.com/', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'instruction_manual', 'https://amtelectronics.com/new/manuals/LA-B1-manual-ENG.pdf',         'manufacturer_manual',  'https://amtelectronics.com/new/manuals/LA-B1-manual-ENG.pdf', 'High', '2026-03-21');

INSERT INTO product_sources (product_id, table_name, field_name, value_recorded, source_type, source_url, reliability, accessed_at, jack_id)
VALUES (currval('products_id_seq'), 'jacks', 'current_ma', '6 mA (4 mA power-saving mode)', 'manufacturer_manual', 'https://amtelectronics.com/new/manuals/LA-B1-manual-ENG.pdf', 'High', '2026-03-21',
    (SELECT id FROM jacks WHERE product_id = currval('products_id_seq') AND category = 'power' AND direction = 'input'));

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');
COMMIT;


-- ─── 5. E-1 (ENGL Fireball) ──────────────────────────────────────────────────
BEGIN;

INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    product_page, instruction_manual,
    description, data_reliability,
    notes
) VALUES (
    14, 1, 'E-1',
    NULL,
    113.0, 74.0, 54.0, 269,
    'https://amtelectronics.com/new/amt-e1/', 'https://amtelectronics.com/new/manuals/LA-E1-manual-ENG.pdf',
    'Single-channel JFET preamp emulating the ENGL Fireball lead channel. Two simultaneous outputs: direct amp out and cab-simulated out.',
    'High',
    'Sold out on amt-sales.com as of 2026-03-21; in_production unknown.'
);

INSERT INTO pedal_details (product_id, effect_type, signal_type, bypass_type, mono_stereo, battery_capable, fx_loop_count)
VALUES (currval('products_id_seq'), 'Preamp', 'Analog', 'True Bypass', 'Mono', FALSE, 0);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9-12V', 6, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS', 'Input');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Direct Amp Out');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Cab Sim Out');

INSERT INTO product_sources (product_id, table_name, field_name, value_recorded, source_type, source_url, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'width_mm',           '113 × 74 × 54 mm',                                                    'manufacturer_website', 'https://amt-sales.com/', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'depth_mm',           '113 × 74 × 54 mm',                                                    'manufacturer_website', 'https://amt-sales.com/', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'height_mm',          '113 × 74 × 54 mm',                                                    'manufacturer_website', 'https://amt-sales.com/', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'weight_grams',       '269 g',                                                               'manufacturer_website', 'https://amt-sales.com/', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'product_page',       'https://amtelectronics.com/new/amt-e1/',                              'manufacturer_website', 'https://amtelectronics.com/', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'instruction_manual', 'https://amtelectronics.com/new/manuals/LA-E1-manual-ENG.pdf',         'manufacturer_manual',  'https://amtelectronics.com/new/manuals/LA-E1-manual-ENG.pdf', 'High', '2026-03-21');

INSERT INTO product_sources (product_id, table_name, field_name, value_recorded, source_type, source_url, reliability, accessed_at, jack_id)
VALUES (currval('products_id_seq'), 'jacks', 'current_ma', '6 mA (4 mA power-saving mode)', 'manufacturer_manual', 'https://amtelectronics.com/new/manuals/LA-E1-manual-ENG.pdf', 'High', '2026-03-21',
    (SELECT id FROM jacks WHERE product_id = currval('products_id_seq') AND category = 'power' AND direction = 'input'));

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');
COMMIT;


-- ─── 6. F-1 (Fender Twin) — has serial FX loop + built-in power hub ──────────
-- Power hub output connector type unknown; those jacks omitted
BEGIN;

INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    product_page, instruction_manual,
    description, data_reliability,
    notes
) VALUES (
    14, 1, 'F-1',
    NULL,
    113.0, 74.0, 54.0, 292,
    'https://amtelectronics.com/new/amt-f1/', 'https://amtelectronics.com/new/manuals/LA-F1-manual-ENG.pdf',
    'Single-channel JFET preamp emulating the Fender Twin. Features serial FX loop and built-in 9-12V power hub for chaining effects.',
    'High',
    'Sold out on amt-sales.com as of 2026-03-21; in_production unknown. Power hub output connector type not confirmed — those jacks not entered.'
);

INSERT INTO pedal_details (product_id, effect_type, signal_type, bypass_type, mono_stereo, battery_capable, fx_loop_count)
VALUES (currval('products_id_seq'), 'Preamp', 'Analog', 'True Bypass', 'Mono', FALSE, 1);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9-12V', 6, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS', 'Input');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Direct Amp Out');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Cab Sim Out');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, group_id)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'FX Loop Send', 'loop_1');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, group_id)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS', 'FX Loop Return', 'loop_1');

INSERT INTO product_sources (product_id, table_name, field_name, value_recorded, source_type, source_url, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'width_mm',           '113 × 74 × 54 mm',                                                    'manufacturer_website', 'https://amt-sales.com/', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'depth_mm',           '113 × 74 × 54 mm',                                                    'manufacturer_website', 'https://amt-sales.com/', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'height_mm',          '113 × 74 × 54 mm',                                                    'manufacturer_website', 'https://amt-sales.com/', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'weight_grams',       '292 g',                                                               'manufacturer_website', 'https://amt-sales.com/', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'product_page',       'https://amtelectronics.com/new/amt-f1/',                              'manufacturer_website', 'https://amtelectronics.com/', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'instruction_manual', 'https://amtelectronics.com/new/manuals/LA-F1-manual-ENG.pdf',         'manufacturer_manual',  'https://amtelectronics.com/new/manuals/LA-F1-manual-ENG.pdf', 'High', '2026-03-21');

INSERT INTO product_sources (product_id, table_name, field_name, value_recorded, source_type, source_url, reliability, accessed_at, jack_id)
VALUES (currval('products_id_seq'), 'jacks', 'current_ma', '6 mA (4 mA power-saving mode)', 'manufacturer_manual', 'https://amtelectronics.com/new/manuals/LA-F1-manual-ENG.pdf', 'High', '2026-03-21',
    (SELECT id FROM jacks WHERE product_id = currval('products_id_seq') AND category = 'power' AND direction = 'input'));

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');
COMMIT;


-- ─── 7. R-1 (Mesa Boogie Triple Rectifier) ───────────────────────────────────
BEGIN;

INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    product_page, instruction_manual,
    description, data_reliability,
    notes
) VALUES (
    14, 1, 'R-1',
    NULL,
    113.0, 74.0, 54.0, 269,
    'https://amtelectronics.com/new/amt-r1/', 'https://amtelectronics.com/new/manuals/LA-R1-manual-ENG.pdf',
    'Single-channel JFET preamp emulating the Mesa Boogie Triple Rectifier. Two simultaneous outputs: direct amp out and cab-simulated out.',
    'High',
    'Sold out on amt-sales.com as of 2026-03-21; in_production unknown.'
);

INSERT INTO pedal_details (product_id, effect_type, signal_type, bypass_type, mono_stereo, battery_capable, fx_loop_count)
VALUES (currval('products_id_seq'), 'Preamp', 'Analog', 'True Bypass', 'Mono', FALSE, 0);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9-12V', 6, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS', 'Input');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Direct Amp Out');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Cab Sim Out');

INSERT INTO product_sources (product_id, table_name, field_name, value_recorded, source_type, source_url, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'width_mm',           '113 × 74 × 54 mm',                                                    'manufacturer_website', 'https://amt-sales.com/', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'depth_mm',           '113 × 74 × 54 mm',                                                    'manufacturer_website', 'https://amt-sales.com/', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'height_mm',          '113 × 74 × 54 mm',                                                    'manufacturer_website', 'https://amt-sales.com/', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'weight_grams',       '269 g',                                                               'manufacturer_website', 'https://amt-sales.com/', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'product_page',       'https://amtelectronics.com/new/amt-r1/',                              'manufacturer_website', 'https://amtelectronics.com/', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'instruction_manual', 'https://amtelectronics.com/new/manuals/LA-R1-manual-ENG.pdf',         'manufacturer_manual',  'https://amtelectronics.com/new/manuals/LA-R1-manual-ENG.pdf', 'High', '2026-03-21');

INSERT INTO product_sources (product_id, table_name, field_name, value_recorded, source_type, source_url, reliability, accessed_at, jack_id)
VALUES (currval('products_id_seq'), 'jacks', 'current_ma', '6 mA (4 mA power-saving mode)', 'manufacturer_manual', 'https://amtelectronics.com/new/manuals/LA-R1-manual-ENG.pdf', 'High', '2026-03-21',
    (SELECT id FROM jacks WHERE product_id = currval('products_id_seq') AND category = 'power' AND direction = 'input'));

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');
COMMIT;


-- ─── 8. V-1 (VOX AC30) — has serial FX loop + Channel Send/Return + power hub ─
-- Channel Send/Return and power hub output connector types unknown; those jacks omitted
BEGIN;

INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm,
    product_page, instruction_manual,
    description, data_reliability,
    notes
) VALUES (
    14, 1, 'V-1',
    TRUE,
    113.0, 74.0, 54.0,
    'https://amtelectronics.com/new/amt-v1/', 'https://amtelectronics.com/new/manuals/LA-V1-color-manual-ENG.pdf',
    'Single-channel JFET preamp emulating the VOX AC30. Features serial FX loop, Channel Send/Return for multi-unit linking, and built-in 9-12V power hub.',
    'High',
    'Channel Send/Return and power hub output connector types not confirmed — those jacks not entered.'
);

INSERT INTO pedal_details (product_id, effect_type, signal_type, bypass_type, mono_stereo, battery_capable, fx_loop_count)
VALUES (currval('products_id_seq'), 'Preamp', 'Analog', 'True Bypass', 'Mono', FALSE, 1);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9-12V', 6, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS', 'Input');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Direct Amp Out');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Cab Sim Out');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, group_id)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'FX Loop Send', 'loop_1');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, group_id)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS', 'FX Loop Return', 'loop_1');

INSERT INTO product_sources (product_id, table_name, field_name, value_recorded, source_type, source_url, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'width_mm',           '113 × 74 × 54 mm',                                                                   'manufacturer_website', 'https://amt-sales.com/', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'depth_mm',           '113 × 74 × 54 mm',                                                                   'manufacturer_website', 'https://amt-sales.com/', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'height_mm',          '113 × 74 × 54 mm',                                                                   'manufacturer_website', 'https://amt-sales.com/', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'product_page',       'https://amtelectronics.com/new/amt-v1/',                                             'manufacturer_website', 'https://amtelectronics.com/', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'instruction_manual', 'https://amtelectronics.com/new/manuals/LA-V1-color-manual-ENG.pdf',                  'manufacturer_manual',  'https://amtelectronics.com/new/manuals/LA-V1-color-manual-ENG.pdf', 'High', '2026-03-21');

INSERT INTO product_sources (product_id, table_name, field_name, value_recorded, source_type, source_url, reliability, accessed_at, jack_id)
VALUES (currval('products_id_seq'), 'jacks', 'current_ma', '6 mA (4 mA power-saving mode)', 'manufacturer_manual', 'https://amtelectronics.com/new/manuals/LA-V1-color-manual-ENG.pdf', 'High', '2026-03-21',
    (SELECT id FROM jacks WHERE product_id = currval('products_id_seq') AND category = 'power' AND direction = 'input'));

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');
COMMIT;
