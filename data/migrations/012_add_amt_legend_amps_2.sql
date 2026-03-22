-- =============================================================================
-- MIGRATION 012: AMT Electronics — Legend Amps II Series (LA-2)
-- Manufacturer: AMT Electronics (id = 14)
-- 10 models: P2, M2, O2, S2, D2, B2, E2, C2, R2, VT2
-- All: two-channel JFET preamp/distortion; 113 × 77 × 55 mm; 9-12V / 6 mA
-- Dimensions from amt-sales.com (Medium — conflict with 110×62×58mm reported elsewhere)
-- Signal type Analog (Medium — JFET circuit, corrected from research report)
-- Bypass type Buffered Bypass (Medium — not explicitly confirmed in sources)
-- Three simultaneous audio outputs: Cab Sim Out, Preamp Out, Drive Out
-- "Sold out" models: in_production = NULL (ambiguous)
-- Shared instruction manual: https://amtelectronics.com/new/manuals/LA2-manual-ENG.pdf
-- Sources: AMT official website, amt-sales.com, LA-2 series manual
-- Researched: 2026-03-21
-- =============================================================================


-- ─── 1. P2 (Peavey 5150/6505) ────────────────────────────────────────────────
BEGIN;

INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm,
    product_page, instruction_manual,
    description, data_reliability
) VALUES (
    14, 1, 'P2',
    TRUE,
    113.0, 77.0, 55.0,
    'https://amtelectronics.com/new/amt-p2/', 'https://amtelectronics.com/new/manuals/LA2-manual-ENG.pdf',
    'Two-channel JFET preamp emulating the Peavey 5150/6505. Clean channel plus overdrive channel. Three simultaneous outputs: cab sim, preamp, and drive.',
    'Medium'
);

INSERT INTO pedal_details (product_id, effect_type, signal_type, bypass_type, mono_stereo, battery_capable, fx_loop_count)
VALUES (currval('products_id_seq'), 'Preamp', 'Analog', 'Buffered Bypass', 'Mono', FALSE, 0);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9-12V', 6, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS', 'Input');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Cab Sim Out');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Preamp Out');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Drive Out');

INSERT INTO product_sources (product_id, table_name, field_name, value_recorded, source_type, source_url, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'width_mm',           '113 × 77 × 55 mm', 'manufacturer_website', 'https://amt-sales.com/', 'Medium', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'depth_mm',           '113 × 77 × 55 mm', 'manufacturer_website', 'https://amt-sales.com/', 'Medium', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'height_mm',          '113 × 77 × 55 mm', 'manufacturer_website', 'https://amt-sales.com/', 'Medium', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'product_page',       'https://amtelectronics.com/new/amt-p2/', 'manufacturer_website', 'https://amtelectronics.com/', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'instruction_manual', 'https://amtelectronics.com/new/manuals/LA2-manual-ENG.pdf', 'manufacturer_manual', 'https://amtelectronics.com/new/manuals/LA2-manual-ENG.pdf', 'High', '2026-03-21');

INSERT INTO product_sources (product_id, table_name, field_name, value_recorded, source_type, source_url, reliability, accessed_at, jack_id)
VALUES (currval('products_id_seq'), 'jacks', 'current_ma', '6 mA', 'manufacturer_manual', 'https://amtelectronics.com/new/manuals/LA2-manual-ENG.pdf', 'Medium', '2026-03-21',
    (SELECT id FROM jacks WHERE product_id = currval('products_id_seq') AND category = 'power' AND direction = 'input'));

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');
COMMIT;


-- ─── 2. M2 (Marshall JCM800) ─────────────────────────────────────────────────
BEGIN;

INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm,
    product_page, instruction_manual,
    description, data_reliability
) VALUES (
    14, 1, 'M2',
    TRUE,
    113.0, 77.0, 55.0,
    'https://amtelectronics.com/new/amt-m2/', 'https://amtelectronics.com/new/manuals/LA2-manual-ENG.pdf',
    'Two-channel JFET preamp emulating the Marshall JCM800. JCM800-style overdrive channel plus clean Fender-style channel. Three simultaneous outputs: cab sim, preamp, and drive.',
    'Medium'
);

INSERT INTO pedal_details (product_id, effect_type, signal_type, bypass_type, mono_stereo, battery_capable, fx_loop_count)
VALUES (currval('products_id_seq'), 'Preamp', 'Analog', 'Buffered Bypass', 'Mono', FALSE, 0);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9-12V', 6, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS', 'Input');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Cab Sim Out');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Preamp Out');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Drive Out');

INSERT INTO product_sources (product_id, table_name, field_name, value_recorded, source_type, source_url, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'width_mm',           '113 × 77 × 55 mm', 'manufacturer_website', 'https://amt-sales.com/', 'Medium', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'depth_mm',           '113 × 77 × 55 mm', 'manufacturer_website', 'https://amt-sales.com/', 'Medium', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'height_mm',          '113 × 77 × 55 mm', 'manufacturer_website', 'https://amt-sales.com/', 'Medium', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'product_page',       'https://amtelectronics.com/new/amt-m2/', 'manufacturer_website', 'https://amtelectronics.com/', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'instruction_manual', 'https://amtelectronics.com/new/manuals/LA2-manual-ENG.pdf', 'manufacturer_manual', 'https://amtelectronics.com/new/manuals/LA2-manual-ENG.pdf', 'High', '2026-03-21');

INSERT INTO product_sources (product_id, table_name, field_name, value_recorded, source_type, source_url, reliability, accessed_at, jack_id)
VALUES (currval('products_id_seq'), 'jacks', 'current_ma', '6 mA', 'manufacturer_manual', 'https://amtelectronics.com/new/manuals/LA2-manual-ENG.pdf', 'Medium', '2026-03-21',
    (SELECT id FROM jacks WHERE product_id = currval('products_id_seq') AND category = 'power' AND direction = 'input'));

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');
COMMIT;


-- ─── 3. O2 (Orange) ──────────────────────────────────────────────────────────
BEGIN;

INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm,
    product_page, instruction_manual,
    description, data_reliability
) VALUES (
    14, 1, 'O2',
    TRUE,
    113.0, 77.0, 55.0,
    'https://amtelectronics.com/new/amt-o2/', 'https://amtelectronics.com/new/manuals/LA2-manual-ENG.pdf',
    'Two-channel JFET preamp emulating Orange amplifier tone. Moderate-gain overdrive with clean boost capability. Three simultaneous outputs: cab sim, preamp, and drive.',
    'Medium'
);

INSERT INTO pedal_details (product_id, effect_type, signal_type, bypass_type, mono_stereo, battery_capable, fx_loop_count)
VALUES (currval('products_id_seq'), 'Preamp', 'Analog', 'Buffered Bypass', 'Mono', FALSE, 0);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9-12V', 6, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS', 'Input');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Cab Sim Out');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Preamp Out');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Drive Out');

INSERT INTO product_sources (product_id, table_name, field_name, value_recorded, source_type, source_url, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'width_mm',           '113 × 77 × 55 mm', 'manufacturer_website', 'https://amt-sales.com/', 'Medium', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'depth_mm',           '113 × 77 × 55 mm', 'manufacturer_website', 'https://amt-sales.com/', 'Medium', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'height_mm',          '113 × 77 × 55 mm', 'manufacturer_website', 'https://amt-sales.com/', 'Medium', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'product_page',       'https://amtelectronics.com/new/amt-o2/', 'manufacturer_website', 'https://amtelectronics.com/', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'instruction_manual', 'https://amtelectronics.com/new/manuals/LA2-manual-ENG.pdf', 'manufacturer_manual', 'https://amtelectronics.com/new/manuals/LA2-manual-ENG.pdf', 'High', '2026-03-21');

INSERT INTO product_sources (product_id, table_name, field_name, value_recorded, source_type, source_url, reliability, accessed_at, jack_id)
VALUES (currval('products_id_seq'), 'jacks', 'current_ma', '6 mA', 'manufacturer_manual', 'https://amtelectronics.com/new/manuals/LA2-manual-ENG.pdf', 'Medium', '2026-03-21',
    (SELECT id FROM jacks WHERE product_id = currval('products_id_seq') AND category = 'power' AND direction = 'input'));

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');
COMMIT;


-- ─── 4. S2 (Soldano) — sold out ──────────────────────────────────────────────
BEGIN;

INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    product_page, instruction_manual,
    description, data_reliability,
    notes
) VALUES (
    14, 1, 'S2',
    NULL,
    113.0, 77.0, 55.0, 319,
    'https://amtelectronics.com/new/amt-s2/', 'https://amtelectronics.com/new/manuals/LA2-manual-ENG.pdf',
    'Two-channel JFET preamp emulating the Soldano amplifier. Five-stage preamp circuit. Three simultaneous outputs: cab sim, preamp, and drive.',
    'Medium',
    'Sold out on amt-sales.com as of 2026-03-21; in_production unknown.'
);

INSERT INTO pedal_details (product_id, effect_type, signal_type, bypass_type, mono_stereo, battery_capable, fx_loop_count)
VALUES (currval('products_id_seq'), 'Preamp', 'Analog', 'Buffered Bypass', 'Mono', FALSE, 0);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9-12V', 6, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS', 'Input');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Cab Sim Out');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Preamp Out');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Drive Out');

INSERT INTO product_sources (product_id, table_name, field_name, value_recorded, source_type, source_url, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'width_mm',           '113 × 77 × 55 mm', 'manufacturer_website', 'https://amt-sales.com/', 'Medium', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'depth_mm',           '113 × 77 × 55 mm', 'manufacturer_website', 'https://amt-sales.com/', 'Medium', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'height_mm',          '113 × 77 × 55 mm', 'manufacturer_website', 'https://amt-sales.com/', 'Medium', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'weight_grams',       '319 g',             'manufacturer_website', 'https://amt-sales.com/', 'High',   '2026-03-21'),
    (currval('products_id_seq'), 'products', 'product_page',       'https://amtelectronics.com/new/amt-s2/', 'manufacturer_website', 'https://amtelectronics.com/', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'instruction_manual', 'https://amtelectronics.com/new/manuals/LA2-manual-ENG.pdf', 'manufacturer_manual', 'https://amtelectronics.com/new/manuals/LA2-manual-ENG.pdf', 'High', '2026-03-21');

INSERT INTO product_sources (product_id, table_name, field_name, value_recorded, source_type, source_url, reliability, accessed_at, jack_id)
VALUES (currval('products_id_seq'), 'jacks', 'current_ma', '6 mA', 'manufacturer_manual', 'https://amtelectronics.com/new/manuals/LA2-manual-ENG.pdf', 'Medium', '2026-03-21',
    (SELECT id FROM jacks WHERE product_id = currval('products_id_seq') AND category = 'power' AND direction = 'input'));

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');
COMMIT;


-- ─── 5. D2 (Diezel) — sold out ───────────────────────────────────────────────
BEGIN;

INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    product_page, instruction_manual,
    description, data_reliability,
    notes
) VALUES (
    14, 1, 'D2',
    NULL,
    113.0, 77.0, 55.0, 313,
    'https://amtelectronics.com/new/amt-d2/', 'https://amtelectronics.com/new/manuals/LA2-manual-ENG.pdf',
    'Two-channel JFET preamp emulating Diezel amplifier response and gain characteristics. Three simultaneous outputs: cab sim, preamp, and drive.',
    'Medium',
    'Sold out on amt-sales.com as of 2026-03-21; in_production unknown.'
);

INSERT INTO pedal_details (product_id, effect_type, signal_type, bypass_type, mono_stereo, battery_capable, fx_loop_count)
VALUES (currval('products_id_seq'), 'Preamp', 'Analog', 'Buffered Bypass', 'Mono', FALSE, 0);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9-12V', 6, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS', 'Input');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Cab Sim Out');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Preamp Out');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Drive Out');

INSERT INTO product_sources (product_id, table_name, field_name, value_recorded, source_type, source_url, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'width_mm',           '113 × 77 × 55 mm', 'manufacturer_website', 'https://amt-sales.com/', 'Medium', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'depth_mm',           '113 × 77 × 55 mm', 'manufacturer_website', 'https://amt-sales.com/', 'Medium', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'height_mm',          '113 × 77 × 55 mm', 'manufacturer_website', 'https://amt-sales.com/', 'Medium', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'weight_grams',       '313 g',             'manufacturer_website', 'https://amt-sales.com/', 'High',   '2026-03-21'),
    (currval('products_id_seq'), 'products', 'product_page',       'https://amtelectronics.com/new/amt-d2/', 'manufacturer_website', 'https://amtelectronics.com/', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'instruction_manual', 'https://amtelectronics.com/new/manuals/LA2-manual-ENG.pdf', 'manufacturer_manual', 'https://amtelectronics.com/new/manuals/LA2-manual-ENG.pdf', 'High', '2026-03-21');

INSERT INTO product_sources (product_id, table_name, field_name, value_recorded, source_type, source_url, reliability, accessed_at, jack_id)
VALUES (currval('products_id_seq'), 'jacks', 'current_ma', '6 mA', 'manufacturer_manual', 'https://amtelectronics.com/new/manuals/LA2-manual-ENG.pdf', 'Medium', '2026-03-21',
    (SELECT id FROM jacks WHERE product_id = currval('products_id_seq') AND category = 'power' AND direction = 'input'));

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');
COMMIT;


-- ─── 6. B2 (Bogner) ──────────────────────────────────────────────────────────
BEGIN;

INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm,
    product_page, instruction_manual,
    description, data_reliability
) VALUES (
    14, 1, 'B2',
    TRUE,
    113.0, 77.0, 55.0,
    'https://amtelectronics.com/new/amt-b2/', 'https://amtelectronics.com/new/manuals/LA2-manual-ENG.pdf',
    'Two-channel JFET preamp emulating the Bogner Sharp Channel with refined high-gain sound. Three simultaneous outputs: cab sim, preamp, and drive.',
    'Medium'
);

INSERT INTO pedal_details (product_id, effect_type, signal_type, bypass_type, mono_stereo, battery_capable, fx_loop_count)
VALUES (currval('products_id_seq'), 'Preamp', 'Analog', 'Buffered Bypass', 'Mono', FALSE, 0);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9-12V', 6, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS', 'Input');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Cab Sim Out');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Preamp Out');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Drive Out');

INSERT INTO product_sources (product_id, table_name, field_name, value_recorded, source_type, source_url, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'width_mm',           '113 × 77 × 55 mm', 'manufacturer_website', 'https://amt-sales.com/', 'Medium', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'depth_mm',           '113 × 77 × 55 mm', 'manufacturer_website', 'https://amt-sales.com/', 'Medium', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'height_mm',          '113 × 77 × 55 mm', 'manufacturer_website', 'https://amt-sales.com/', 'Medium', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'product_page',       'https://amtelectronics.com/new/amt-b2/', 'manufacturer_website', 'https://amtelectronics.com/', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'instruction_manual', 'https://amtelectronics.com/new/manuals/LA2-manual-ENG.pdf', 'manufacturer_manual', 'https://amtelectronics.com/new/manuals/LA2-manual-ENG.pdf', 'High', '2026-03-21');

INSERT INTO product_sources (product_id, table_name, field_name, value_recorded, source_type, source_url, reliability, accessed_at, jack_id)
VALUES (currval('products_id_seq'), 'jacks', 'current_ma', '6 mA', 'manufacturer_manual', 'https://amtelectronics.com/new/manuals/LA2-manual-ENG.pdf', 'Medium', '2026-03-21',
    (SELECT id FROM jacks WHERE product_id = currval('products_id_seq') AND category = 'power' AND direction = 'input'));

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');
COMMIT;


-- ─── 7. E2 (ENGL) — sold out ─────────────────────────────────────────────────
BEGIN;

INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    product_page, instruction_manual,
    description, data_reliability,
    notes
) VALUES (
    14, 1, 'E2',
    NULL,
    113.0, 77.0, 55.0, 316,
    'https://amtelectronics.com/new/amt-e2/', 'https://amtelectronics.com/new/manuals/LA2-manual-ENG.pdf',
    'Two-channel JFET preamp emulating ENGL amplifier overdrive with four preamp stages. Three simultaneous outputs: cab sim, preamp, and drive.',
    'Medium',
    'Sold out on amt-sales.com as of 2026-03-21; in_production unknown.'
);

INSERT INTO pedal_details (product_id, effect_type, signal_type, bypass_type, mono_stereo, battery_capable, fx_loop_count)
VALUES (currval('products_id_seq'), 'Preamp', 'Analog', 'Buffered Bypass', 'Mono', FALSE, 0);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9-12V', 6, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS', 'Input');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Cab Sim Out');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Preamp Out');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Drive Out');

INSERT INTO product_sources (product_id, table_name, field_name, value_recorded, source_type, source_url, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'width_mm',           '113 × 77 × 55 mm', 'manufacturer_website', 'https://amt-sales.com/', 'Medium', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'depth_mm',           '113 × 77 × 55 mm', 'manufacturer_website', 'https://amt-sales.com/', 'Medium', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'height_mm',          '113 × 77 × 55 mm', 'manufacturer_website', 'https://amt-sales.com/', 'Medium', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'weight_grams',       '316 g',             'manufacturer_website', 'https://amt-sales.com/', 'High',   '2026-03-21'),
    (currval('products_id_seq'), 'products', 'product_page',       'https://amtelectronics.com/new/amt-e2/', 'manufacturer_website', 'https://amtelectronics.com/', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'instruction_manual', 'https://amtelectronics.com/new/manuals/LA2-manual-ENG.pdf', 'manufacturer_manual', 'https://amtelectronics.com/new/manuals/LA2-manual-ENG.pdf', 'High', '2026-03-21');

INSERT INTO product_sources (product_id, table_name, field_name, value_recorded, source_type, source_url, reliability, accessed_at, jack_id)
VALUES (currval('products_id_seq'), 'jacks', 'current_ma', '6 mA', 'manufacturer_manual', 'https://amtelectronics.com/new/manuals/LA2-manual-ENG.pdf', 'Medium', '2026-03-21',
    (SELECT id FROM jacks WHERE product_id = currval('products_id_seq') AND category = 'power' AND direction = 'input'));

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');
COMMIT;


-- ─── 8. C2 (Cornford) ────────────────────────────────────────────────────────
BEGIN;

INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    product_page, instruction_manual,
    description, data_reliability
) VALUES (
    14, 1, 'C2',
    TRUE,
    113.0, 77.0, 55.0, 315,
    'https://amtelectronics.com/new/amt-c2/', 'https://amtelectronics.com/new/manuals/LA2-manual-ENG.pdf',
    'Two-channel JFET preamp emulating Cornford amplifier tone. Wide overdrive range from crunch to high gain. Three simultaneous outputs: cab sim, preamp, and drive.',
    'Medium'
);

INSERT INTO pedal_details (product_id, effect_type, signal_type, bypass_type, mono_stereo, battery_capable, fx_loop_count)
VALUES (currval('products_id_seq'), 'Preamp', 'Analog', 'Buffered Bypass', 'Mono', FALSE, 0);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9-12V', 6, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS', 'Input');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Cab Sim Out');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Preamp Out');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Drive Out');

INSERT INTO product_sources (product_id, table_name, field_name, value_recorded, source_type, source_url, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'width_mm',           '113 × 77 × 55 mm', 'manufacturer_website', 'https://amt-sales.com/', 'Medium', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'depth_mm',           '113 × 77 × 55 mm', 'manufacturer_website', 'https://amt-sales.com/', 'Medium', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'height_mm',          '113 × 77 × 55 mm', 'manufacturer_website', 'https://amt-sales.com/', 'Medium', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'weight_grams',       '315 g',             'manufacturer_website', 'https://amt-sales.com/', 'High',   '2026-03-21'),
    (currval('products_id_seq'), 'products', 'product_page',       'https://amtelectronics.com/new/amt-c2/', 'manufacturer_website', 'https://amtelectronics.com/', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'instruction_manual', 'https://amtelectronics.com/new/manuals/LA2-manual-ENG.pdf', 'manufacturer_manual', 'https://amtelectronics.com/new/manuals/LA2-manual-ENG.pdf', 'High', '2026-03-21');

INSERT INTO product_sources (product_id, table_name, field_name, value_recorded, source_type, source_url, reliability, accessed_at, jack_id)
VALUES (currval('products_id_seq'), 'jacks', 'current_ma', '6 mA', 'manufacturer_manual', 'https://amtelectronics.com/new/manuals/LA2-manual-ENG.pdf', 'Medium', '2026-03-21',
    (SELECT id FROM jacks WHERE product_id = currval('products_id_seq') AND category = 'power' AND direction = 'input'));

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');
COMMIT;


-- ─── 9. R2 (Mesa Boogie Rectifier) ───────────────────────────────────────────
-- Product page URL not confirmed; left NULL
BEGIN;

INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm,
    instruction_manual,
    description, data_reliability
) VALUES (
    14, 1, 'R2',
    TRUE,
    113.0, 77.0, 55.0,
    'https://amtelectronics.com/new/manuals/LA2-manual-ENG.pdf',
    'Two-channel JFET preamp emulating the Mesa Boogie Rectifier amplifier series. Three simultaneous outputs: cab sim, preamp, and drive.',
    'Medium'
);

INSERT INTO pedal_details (product_id, effect_type, signal_type, bypass_type, mono_stereo, battery_capable, fx_loop_count)
VALUES (currval('products_id_seq'), 'Preamp', 'Analog', 'Buffered Bypass', 'Mono', FALSE, 0);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9-12V', 6, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS', 'Input');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Cab Sim Out');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Preamp Out');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Drive Out');

INSERT INTO product_sources (product_id, table_name, field_name, value_recorded, source_type, source_url, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'width_mm',           '113 × 77 × 55 mm', 'manufacturer_website', 'https://amt-sales.com/', 'Medium', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'depth_mm',           '113 × 77 × 55 mm', 'manufacturer_website', 'https://amt-sales.com/', 'Medium', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'height_mm',          '113 × 77 × 55 mm', 'manufacturer_website', 'https://amt-sales.com/', 'Medium', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'instruction_manual', 'https://amtelectronics.com/new/manuals/LA2-manual-ENG.pdf', 'manufacturer_manual', 'https://amtelectronics.com/new/manuals/LA2-manual-ENG.pdf', 'High', '2026-03-21');

INSERT INTO product_sources (product_id, table_name, field_name, value_recorded, source_type, source_url, reliability, accessed_at, jack_id)
VALUES (currval('products_id_seq'), 'jacks', 'current_ma', '6 mA', 'manufacturer_manual', 'https://amtelectronics.com/new/manuals/LA2-manual-ENG.pdf', 'Medium', '2026-03-21',
    (SELECT id FROM jacks WHERE product_id = currval('products_id_seq') AND category = 'power' AND direction = 'input'));

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');
COMMIT;


-- ─── 10. VT2 (VHT) — sold out ────────────────────────────────────────────────
BEGIN;

INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    product_page, instruction_manual,
    description, data_reliability,
    notes
) VALUES (
    14, 1, 'VT2',
    NULL,
    113.0, 77.0, 55.0, 314,
    'https://amtelectronics.com/new/amt-vt2/', 'https://amtelectronics.com/new/manuals/LA2-manual-ENG.pdf',
    'Two-channel JFET preamp emulating VHT amplifier lead channels with characteristic roaring overdrive. Three simultaneous outputs: cab sim, preamp, and drive.',
    'Medium',
    'Sold out on amt-sales.com as of 2026-03-21; in_production unknown.'
);

INSERT INTO pedal_details (product_id, effect_type, signal_type, bypass_type, mono_stereo, battery_capable, fx_loop_count)
VALUES (currval('products_id_seq'), 'Preamp', 'Analog', 'Buffered Bypass', 'Mono', FALSE, 0);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9-12V', 6, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS', 'Input');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Cab Sim Out');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Preamp Out');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Drive Out');

INSERT INTO product_sources (product_id, table_name, field_name, value_recorded, source_type, source_url, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'width_mm',           '113 × 77 × 55 mm', 'manufacturer_website', 'https://amt-sales.com/', 'Medium', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'depth_mm',           '113 × 77 × 55 mm', 'manufacturer_website', 'https://amt-sales.com/', 'Medium', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'height_mm',          '113 × 77 × 55 mm', 'manufacturer_website', 'https://amt-sales.com/', 'Medium', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'weight_grams',       '314 g',             'manufacturer_website', 'https://amt-sales.com/', 'High',   '2026-03-21'),
    (currval('products_id_seq'), 'products', 'product_page',       'https://amtelectronics.com/new/amt-vt2/', 'manufacturer_website', 'https://amtelectronics.com/', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'instruction_manual', 'https://amtelectronics.com/new/manuals/LA2-manual-ENG.pdf', 'manufacturer_manual', 'https://amtelectronics.com/new/manuals/LA2-manual-ENG.pdf', 'High', '2026-03-21');

INSERT INTO product_sources (product_id, table_name, field_name, value_recorded, source_type, source_url, reliability, accessed_at, jack_id)
VALUES (currval('products_id_seq'), 'jacks', 'current_ma', '6 mA', 'manufacturer_manual', 'https://amtelectronics.com/new/manuals/LA2-manual-ENG.pdf', 'Medium', '2026-03-21',
    (SELECT id FROM jacks WHERE product_id = currval('products_id_seq') AND category = 'power' AND direction = 'input'));

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');
COMMIT;
