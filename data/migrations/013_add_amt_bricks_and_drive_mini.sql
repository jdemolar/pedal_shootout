-- =============================================================================
-- MIGRATION 013: AMT Electronics — Bricks Series + Drive Mini Series
-- Manufacturer: AMT Electronics (id = 14)
-- Bricks (5): M-Lead, P-Lead, D-Lead, O-Bass, R/S-Lead — compact tube preamps
-- Drive Mini (2): C-Drive Mini, B-Drive Mini — compact JFET distortion pedals
--
-- Bricks notes:
--   M-Lead is the only model with confirmed specs (94×63×75mm, 267g, 12V/300mA)
--   P-Lead, D-Lead, O-Bass, R/S-Lead are skeleton records — specs not sourced
--   CTRL A/B connector types not confirmed on any Bricks model — those jacks omitted
--   Power connector type assumed 2.1mm barrel (standard; unconfirmed for 12V variant)
--
-- Drive Mini notes:
--   Specs confirmed from AMT product page (99×54×57mm, 195g, 9-12V/4mA)
--   B-Drive Mini shares enclosure/specs with C-Drive Mini per research
--
-- Sources: AMT official website, amt-sales.com
-- Researched: 2026-03-21
-- =============================================================================


-- ─── BRICKS SERIES ───────────────────────────────────────────────────────────

-- ─── 1. Bricks M-Lead (Marshall JCM800) — confirmed specs ────────────────────
BEGIN;

INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    description, data_reliability,
    notes
) VALUES (
    14, 1, 'Bricks M-Lead',
    TRUE,
    94.0, 63.0, 75.0, 267,
    'Compact single-channel tube preamp emulating the Marshall JCM800. Full control set (Gain, Treble, Mid, Bass, Volume). High anode voltage (+250-300V). Can be used standalone or chained with other Bricks units.',
    'Medium',
    'CTRL A/B connector types not confirmed — those jacks not entered. Power connector type (2.1mm barrel) assumed from product category standard.'
);

INSERT INTO pedal_details (product_id, effect_type, signal_type, bypass_type, mono_stereo, battery_capable, fx_loop_count)
VALUES (currval('products_id_seq'), 'Preamp', 'Analog', NULL, 'Mono', FALSE, 0);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '12V', 300, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS', 'Input');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Preamp Out');

INSERT INTO product_sources (product_id, table_name, field_name, value_recorded, source_type, source_url, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'width_mm',     '94 × 63 × 75 mm', 'manufacturer_website', 'https://amtelectronics.com/', 'Medium', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'depth_mm',     '94 × 63 × 75 mm', 'manufacturer_website', 'https://amtelectronics.com/', 'Medium', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'height_mm',    '94 × 63 × 75 mm', 'manufacturer_website', 'https://amtelectronics.com/', 'Medium', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'weight_grams', '267 g',            'manufacturer_website', 'https://amtelectronics.com/', 'Medium', '2026-03-21');

INSERT INTO product_sources (product_id, table_name, field_name, value_recorded, source_type, source_url, reliability, accessed_at, jack_id)
VALUES (currval('products_id_seq'), 'jacks', 'current_ma', '~300 mA', 'manufacturer_website', 'https://amtelectronics.com/', 'Medium', '2026-03-21',
    (SELECT id FROM jacks WHERE product_id = currval('products_id_seq') AND category = 'power' AND direction = 'input'));

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');
COMMIT;


-- ─── 2. Bricks P-Lead (Peavey 5150/6505) — skeleton record ──────────────────
BEGIN;

INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    description, data_reliability,
    notes
) VALUES (
    14, 1, 'Bricks P-Lead',
    NULL,
    'Compact single-channel tube preamp emulating the Peavey 5150/6505.',
    'Low',
    'Skeleton record — dimensions, weight, and power specs not confirmed from research. CTRL A/B connector types unknown.'
);

INSERT INTO pedal_details (product_id, effect_type, signal_type, bypass_type, mono_stereo, battery_capable, fx_loop_count)
VALUES (currval('products_id_seq'), 'Preamp', 'Analog', NULL, 'Mono', FALSE, 0);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '12V', NULL, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS', 'Input');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Preamp Out');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');
COMMIT;


-- ─── 3. Bricks D-Lead (Diezel) — skeleton record ─────────────────────────────
BEGIN;

INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    description, data_reliability,
    notes
) VALUES (
    14, 1, 'Bricks D-Lead',
    NULL,
    'Compact single-channel tube preamp emulating the Diezel amplifier.',
    'Low',
    'Skeleton record — dimensions, weight, and power specs not confirmed from research. CTRL A/B connector types unknown.'
);

INSERT INTO pedal_details (product_id, effect_type, signal_type, bypass_type, mono_stereo, battery_capable, fx_loop_count)
VALUES (currval('products_id_seq'), 'Preamp', 'Analog', NULL, 'Mono', FALSE, 0);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '12V', NULL, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS', 'Input');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Preamp Out');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');
COMMIT;


-- ─── 4. Bricks O-Bass (Orange AD200 Mark III) — skeleton record ──────────────
BEGIN;

INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    description, data_reliability,
    notes
) VALUES (
    14, 1, 'Bricks O-Bass',
    NULL,
    'Compact single-channel tube preamp emulating the Orange AD200 Mark III bass amplifier.',
    'Low',
    'Skeleton record — dimensions, weight, and power specs not confirmed from research. CTRL A/B connector types unknown.'
);

INSERT INTO pedal_details (product_id, effect_type, signal_type, bypass_type, mono_stereo, battery_capable, fx_loop_count)
VALUES (currval('products_id_seq'), 'Preamp', 'Analog', NULL, 'Mono', FALSE, 0);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '12V', NULL, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS', 'Input');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Preamp Out');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');
COMMIT;


-- ─── 5. Bricks R/S-Lead (Mesa Boogie/Soldano) — product page confirmed ────────
BEGIN;

INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    product_page,
    description, data_reliability,
    notes
) VALUES (
    14, 1, 'Bricks R/S-Lead',
    NULL,
    'https://amtelectronics.com/new/amt-rs-lead/',
    'Compact single-channel tube preamp combining Mesa Boogie red-channel and Soldano drive characteristics.',
    'Low',
    'Skeleton record — dimensions, weight, and power specs not confirmed from research. CTRL A/B connector types unknown.'
);

INSERT INTO pedal_details (product_id, effect_type, signal_type, bypass_type, mono_stereo, battery_capable, fx_loop_count)
VALUES (currval('products_id_seq'), 'Preamp', 'Analog', NULL, 'Mono', FALSE, 0);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '12V', NULL, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS', 'Input');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Preamp Out');

INSERT INTO product_sources (product_id, table_name, field_name, value_recorded, source_type, source_url, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'product_page', 'https://amtelectronics.com/new/amt-rs-lead/', 'manufacturer_website', 'https://amtelectronics.com/', 'High', '2026-03-21');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');
COMMIT;


-- ─── DRIVE MINI SERIES ────────────────────────────────────────────────────────

-- ─── 6. C-Drive Mini (Cornford) ──────────────────────────────────────────────
BEGIN;

INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    product_page,
    description, data_reliability
) VALUES (
    14, 1, 'C-Drive Mini',
    TRUE,
    99.0, 54.0, 57.0, 195,
    'https://amtelectronics.com/new/amt-fx-c-drive-mini/',
    'Compact JFET distortion pedal emulating Cornford amplifier tone. Wide gain range from crunch to high gain. Voice switch (M/F modes).',
    'High'
);

INSERT INTO pedal_details (product_id, effect_type, signal_type, bypass_type, mono_stereo, battery_capable, fx_loop_count)
VALUES (currval('products_id_seq'), 'Gain', 'Analog', 'True Bypass', 'Mono', FALSE, 0);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9-12V', 4, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS', 'Input');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Output');

INSERT INTO product_sources (product_id, table_name, field_name, value_recorded, source_type, source_url, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'width_mm',     '99 × 54 × 57 mm', 'manufacturer_website', 'https://amtelectronics.com/', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'depth_mm',     '99 × 54 × 57 mm', 'manufacturer_website', 'https://amtelectronics.com/', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'height_mm',    '99 × 54 × 57 mm', 'manufacturer_website', 'https://amtelectronics.com/', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'weight_grams', '195 g',            'manufacturer_website', 'https://amtelectronics.com/', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'product_page', 'https://amtelectronics.com/new/amt-fx-c-drive-mini/', 'manufacturer_website', 'https://amtelectronics.com/', 'High', '2026-03-21');

INSERT INTO product_sources (product_id, table_name, field_name, value_recorded, source_type, source_url, reliability, accessed_at, jack_id)
VALUES (currval('products_id_seq'), 'jacks', 'current_ma', '4 mA', 'manufacturer_website', 'https://amtelectronics.com/', 'High', '2026-03-21',
    (SELECT id FROM jacks WHERE product_id = currval('products_id_seq') AND category = 'power' AND direction = 'input'));

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');
COMMIT;


-- ─── 7. B-Drive Mini (Bogner) ────────────────────────────────────────────────
-- Shares enclosure and specs with C-Drive Mini per research
BEGIN;

INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    description, data_reliability,
    notes
) VALUES (
    14, 1, 'B-Drive Mini',
    TRUE,
    99.0, 54.0, 57.0, 195,
    'Compact JFET distortion pedal emulating Bogner amplifier distortion. Voice switch (M/F modes).',
    'Medium',
    'Specs shared with C-Drive Mini per research; product page URL not confirmed.'
);

INSERT INTO pedal_details (product_id, effect_type, signal_type, bypass_type, mono_stereo, battery_capable, fx_loop_count)
VALUES (currval('products_id_seq'), 'Gain', 'Analog', 'True Bypass', 'Mono', FALSE, 0);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9-12V', 4, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS', 'Input');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Output');

INSERT INTO product_sources (product_id, table_name, field_name, value_recorded, source_type, source_url, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'width_mm',     '99 × 54 × 57 mm (shared with C-Drive Mini)', 'manufacturer_website', 'https://amtelectronics.com/', 'Medium', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'depth_mm',     '99 × 54 × 57 mm (shared with C-Drive Mini)', 'manufacturer_website', 'https://amtelectronics.com/', 'Medium', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'height_mm',    '99 × 54 × 57 mm (shared with C-Drive Mini)', 'manufacturer_website', 'https://amtelectronics.com/', 'Medium', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'weight_grams', '195 g (shared with C-Drive Mini)',           'manufacturer_website', 'https://amtelectronics.com/', 'Medium', '2026-03-21');

INSERT INTO product_sources (product_id, table_name, field_name, value_recorded, source_type, source_url, reliability, accessed_at, jack_id)
VALUES (currval('products_id_seq'), 'jacks', 'current_ma', '4 mA (shared with C-Drive Mini)', 'manufacturer_website', 'https://amtelectronics.com/', 'Medium', '2026-03-21',
    (SELECT id FROM jacks WHERE product_id = currval('products_id_seq') AND category = 'power' AND direction = 'input'));

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');
COMMIT;
