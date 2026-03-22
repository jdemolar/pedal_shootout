-- Migration 014: Add ARC Effects pedals (Manufacturer ID 20)
-- 6 pedals: Klone V2, Soothsayer, Big Green, Gamut, Crimson King, Shepherd
-- All analog, all mono, all currently in production
-- ARC Effects is a boutique handmade pedal manufacturer based in Upstate New York
--
-- Data decisions:
-- - Klone V2 bypass: 'Buffered Bypass' (Medium) — Klon Centaur circuit is inherently buffered
-- - Klone V2 MSRP: NULL — no confirmed retail price found
-- - Soothsayer MSRP: 14500 ($145, Medium — Equipboard)
-- - Soothsayer dims: width=93mm, depth=119mm (reported width × height likely width × depth), height=NULL
-- - Big Green MSRP: NULL — "$210+" found but no exact figure
-- - height_mm: NULL for Big Green, Gamut, Crimson King, Shepherd (enclosure width×depth stated but not height)
-- - Shepherd: all dimensions NULL; battery_capable = FALSE (unconfirmed)
-- - current_ma: NULL for all (not published)
-- - weight_grams: NULL for all (not published)
-- - instruction_manual: NULL for all (no PDFs found)

BEGIN;

-- ============================================================
-- 1. KLONE V2
-- ============================================================
INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm,
    weight_grams, msrp_cents,
    product_page,
    description, data_reliability
) VALUES (
    20, 1, 'Klone V2',
    TRUE,
    118.6, 93.5, 30.0,
    NULL, NULL,
    'http://www.arceffects.com/klone-v2',
    'Faithful recreation of the original Klon Centaur circuit with exact part-for-part values. Features internal DIP switch for bass boost and isolated 9V power input.',
    'Medium'
);

INSERT INTO pedal_details (
    product_id,
    effect_type, signal_type, bypass_type, mono_stereo,
    battery_capable
) VALUES (
    currval('products_id_seq'),
    'Gain', 'Analog', 'Buffered Bypass', 'Mono',
    TRUE
);

-- Jacks: power + audio in + audio out = 3
INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity, is_isolated)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', NULL, 'Center Negative', TRUE);

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS');

-- Sources
INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'product_page', 'http://www.arceffects.com/klone-v2', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'width_mm', 'https://www.effectsdatabase.com/model/arceffects/klone/v2', 'community_database', 'Medium', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'depth_mm', 'https://www.effectsdatabase.com/model/arceffects/klone/v2', 'community_database', 'Medium', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'height_mm', 'https://www.effectsdatabase.com/model/arceffects/klone/v2', 'community_database', 'Medium', '2026-03-21'),
    (currval('products_id_seq'), 'pedal_details', 'effect_type', 'http://www.arceffects.com/klone-v2', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'pedal_details', 'bypass_type', 'https://equipboard.com/items/arc-effects-klone-v2', 'review_site', 'Medium', '2026-03-21'),
    (currval('products_id_seq'), 'pedal_details', 'battery_capable', 'http://www.arceffects.com/klone-v2', 'manufacturer_website', 'High', '2026-03-21');

INSERT INTO product_sources (product_id, table_name, field_name, jack_id, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'jacks', 'voltage',
     (SELECT id FROM jacks WHERE product_id = currval('products_id_seq') AND category = 'power' AND direction = 'input'),
     'http://www.arceffects.com/klone-v2', 'manufacturer_website', '9V DC', 'High', '2026-03-21');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 2. SOOTHSAYER
-- ============================================================
INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm,
    weight_grams, msrp_cents,
    product_page,
    description, data_reliability
) VALUES (
    20, 1, 'Soothsayer',
    TRUE,
    93.0, 119.0, NULL,
    NULL, 14500,
    'http://www.arceffects.com/soothsayer',
    'RAT-circuit-based distortion with LM308 chip, four clipping options (classic, boutique, open, turbo LED), and internally switched hi/low gain modes. No ceramic or electrolytic capacitors in signal path.',
    'Medium'
);

INSERT INTO pedal_details (
    product_id,
    effect_type, signal_type, bypass_type, mono_stereo,
    battery_capable
) VALUES (
    currval('products_id_seq'),
    'Gain', 'Analog', 'True Bypass', 'Mono',
    TRUE
);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', NULL, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'product_page', 'http://www.arceffects.com/soothsayer', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'width_mm', 'http://www.arceffects.com/soothsayer', 'manufacturer_website', 'Medium', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'depth_mm', 'http://www.arceffects.com/soothsayer', 'manufacturer_website', 'Medium', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'msrp_cents', 'https://equipboard.com/items/arc-effects-soothsayer', 'review_site', 'Medium', '2026-03-21'),
    (currval('products_id_seq'), 'pedal_details', 'effect_type', 'http://www.arceffects.com/soothsayer', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'pedal_details', 'bypass_type', 'http://www.arceffects.com/soothsayer', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'pedal_details', 'battery_capable', 'http://www.arceffects.com/soothsayer', 'manufacturer_website', 'High', '2026-03-21');

INSERT INTO product_sources (product_id, table_name, field_name, jack_id, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'jacks', 'voltage',
     (SELECT id FROM jacks WHERE product_id = currval('products_id_seq') AND category = 'power' AND direction = 'input'),
     'http://www.arceffects.com/soothsayer', 'manufacturer_website', '9V DC', 'High', '2026-03-21');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 3. BIG GREEN
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
    20, 1, 'Big Green',
    TRUE,
    88.9, 127.0, NULL,
    NULL, NULL,
    'http://arc-effects.com/big-green',
    'Based on the classic "S" Tall Font Green Russian Big Muff. Features external toggle for 3 mid voicings (stock scooped, flat, boosted) and internal DIP switches for diode lift. Custom 18-gauge steel enclosure.',
    'Medium',
    'MSRP: only "$210+" range found, no exact price confirmed. height_mm unknown — enclosure given as 3.5" × 5" (width × depth only).'
);

INSERT INTO pedal_details (
    product_id,
    effect_type, signal_type, bypass_type, mono_stereo,
    battery_capable
) VALUES (
    currval('products_id_seq'),
    'Fuzz', 'Analog', 'True Bypass', 'Mono',
    TRUE
);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', NULL, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'product_page', 'http://arc-effects.com/big-green', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'width_mm', 'http://arc-effects.com/big-green', 'manufacturer_website', 'Medium', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'depth_mm', 'http://arc-effects.com/big-green', 'manufacturer_website', 'Medium', '2026-03-21'),
    (currval('products_id_seq'), 'pedal_details', 'effect_type', 'http://arc-effects.com/big-green', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'pedal_details', 'bypass_type', 'http://arc-effects.com/big-green', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'pedal_details', 'battery_capable', 'http://arc-effects.com/big-green', 'manufacturer_website', 'High', '2026-03-21');

INSERT INTO product_sources (product_id, table_name, field_name, jack_id, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'jacks', 'voltage',
     (SELECT id FROM jacks WHERE product_id = currval('products_id_seq') AND category = 'power' AND direction = 'input'),
     'http://arc-effects.com/big-green', 'manufacturer_website', '9V DC', 'High', '2026-03-21');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 4. GAMUT
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
    20, 1, 'Gamut',
    TRUE,
    88.9, 127.0, NULL,
    NULL, 18000,
    'http://arc-effects.com/gamut',
    'Germanium treble booster/full-range boost with NOS paper-in-oil capacitors. Range knob sweeps from classic treble booster to full-range. Modern voltage converter allows daisy-chaining with standard 9V supplies.',
    'High',
    'height_mm unknown — enclosure given as 3.5" × 5" (width × depth only).'
);

INSERT INTO pedal_details (
    product_id,
    effect_type, signal_type, bypass_type, mono_stereo,
    battery_capable
) VALUES (
    currval('products_id_seq'),
    'Gain', 'Analog', 'True Bypass', 'Mono',
    TRUE
);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', NULL, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'product_page', 'http://arc-effects.com/gamut', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'msrp_cents', 'http://arc-effects.com/gamut', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'width_mm', 'http://arc-effects.com/gamut', 'manufacturer_website', 'Medium', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'depth_mm', 'http://arc-effects.com/gamut', 'manufacturer_website', 'Medium', '2026-03-21'),
    (currval('products_id_seq'), 'pedal_details', 'effect_type', 'http://arc-effects.com/gamut', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'pedal_details', 'bypass_type', 'http://arc-effects.com/gamut', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'pedal_details', 'battery_capable', 'http://arc-effects.com/gamut', 'manufacturer_website', 'High', '2026-03-21');

INSERT INTO product_sources (product_id, table_name, field_name, jack_id, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'jacks', 'voltage',
     (SELECT id FROM jacks WHERE product_id = currval('products_id_seq') AND category = 'power' AND direction = 'input'),
     'http://arc-effects.com/gamut', 'manufacturer_website', '9V DC', 'High', '2026-03-21');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 5. CRIMSON KING
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
    20, 1, 'Crimson King',
    TRUE,
    88.9, 127.0, NULL,
    NULL, 17900,
    'http://www.arceffects.com/crimson-king',
    'Modern take on the rare Burns/Baldwin Buzzaround ("Buzz" fuzz) favored by Robert Fripp. Three matched germanium transistors, top-quality axial components. Sound spans Bender-type to high-gain territory.',
    'Medium',
    'height_mm unknown — enclosure given as 3.5" × 5" (width × depth only). MSRP from Equipboard (Medium).'
);

INSERT INTO pedal_details (
    product_id,
    effect_type, signal_type, bypass_type, mono_stereo,
    battery_capable
) VALUES (
    currval('products_id_seq'),
    'Fuzz', 'Analog', 'True Bypass', 'Mono',
    TRUE
);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', NULL, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'product_page', 'http://www.arceffects.com/crimson-king', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'msrp_cents', 'https://equipboard.com/items/arc-effects-crimson-king', 'review_site', 'Medium', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'width_mm', 'http://www.arceffects.com/crimson-king', 'manufacturer_website', 'Medium', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'depth_mm', 'http://www.arceffects.com/crimson-king', 'manufacturer_website', 'Medium', '2026-03-21'),
    (currval('products_id_seq'), 'pedal_details', 'effect_type', 'http://www.arceffects.com/crimson-king', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'pedal_details', 'bypass_type', 'http://www.arceffects.com/crimson-king', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'pedal_details', 'battery_capable', 'http://www.arceffects.com/crimson-king', 'manufacturer_website', 'High', '2026-03-21');

INSERT INTO product_sources (product_id, table_name, field_name, jack_id, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'jacks', 'voltage',
     (SELECT id FROM jacks WHERE product_id = currval('products_id_seq') AND category = 'power' AND direction = 'input'),
     'http://www.arceffects.com/crimson-king', 'manufacturer_website', '9V DC', 'High', '2026-03-21');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 6. SHEPHERD
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
    20, 1, 'Shepherd',
    TRUE,
    NULL, NULL, NULL,
    NULL, 29900,
    'http://arc-effects.com/shepherd',
    'Based on a gained-out 1973 "Violet Ram''s Head" Big Muff. External toggle for 3 mid-frequency settings (boosted, flat, stock scooped). Responsive attack, singing sustain, and individual note articulation.',
    'Medium',
    'All dimensions unknown. MSRP from Eddie''s Guitars (Medium). Battery capability not confirmed.'
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
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', NULL, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'product_page', 'http://arc-effects.com/shepherd', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'msrp_cents', 'https://eddiesguitars.com/product/effects/types-of-guitar-pedals/fuzz-pedals/arc-shepherd/', 'major_retailer', 'Medium', '2026-03-21'),
    (currval('products_id_seq'), 'pedal_details', 'effect_type', 'http://arc-effects.com/shepherd', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'pedal_details', 'bypass_type', 'http://arc-effects.com/shepherd', 'manufacturer_website', 'High', '2026-03-21');

INSERT INTO product_sources (product_id, table_name, field_name, jack_id, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'jacks', 'voltage',
     (SELECT id FROM jacks WHERE product_id = currval('products_id_seq') AND category = 'power' AND direction = 'input'),
     'http://arc-effects.com/shepherd', 'manufacturer_website', '9V DC', 'High', '2026-03-21');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

COMMIT;
