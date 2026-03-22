-- =============================================================================
-- MIGRATION 010: Add remaining Amptweaker pedals
-- Manufacturer: Amptweaker (id = 13)
-- Pedals: Blues Fuzz JR, Curveball Jr, DepthFinder, Fat Rock (disc.),
--         PressuRizer, SwirlPool, SwirlPool JR, Tight Boost,
--         Tight Drive JR, Tight Drive Pro, Tight Fuzz, Tight Fuzz JR,
--         Tight Metal JR (disc.), Tight Rock JR (disc.)
-- Sources: Full Compass, Reverb, MusicRadar, Premier Guitar, Amptweaker website
-- Researched: 2026-03-21
-- =============================================================================


-- ─── 1. BLUES FUZZ JR ────────────────────────────────────────────────────────
-- Germanium transistor fuzz; Tight attack switch, Boost switch (+10dB),
-- 60s/70s/Now EQ; compact JR enclosure (no effects loop)

BEGIN;

INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    msrp_cents,
    data_reliability
) VALUES (
    13, 1, 'Blues Fuzz JR',
    TRUE,
    17000,
    'Low'
);

INSERT INTO pedal_details (
    product_id,
    effect_type, signal_type, bypass_type, mono_stereo,
    battery_capable, fx_loop_count
) VALUES (
    currval('products_id_seq'),
    'Fuzz', 'Analog', 'True Bypass', 'Mono',
    FALSE, 0
);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9-18V', NULL, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS', 'Input');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Output');

INSERT INTO product_sources (product_id, table_name, field_name, value_recorded, source_type, source_url, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'msrp_cents', '$170.00', 'review_site', 'https://www.musicradar.com/', 'Medium', '2026-03-21');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

COMMIT;


-- ─── 2. CURVEBALL JR ─────────────────────────────────────────────────────────
-- 3-band active parametric EQ; Tight circuit 3-position switch, dual boost modes
-- 9V (slight distortion at max) or 18V (clean headroom)
-- Dimensions not entered — Guitar World source used unusual W×H×D ordering, unverified

BEGIN;

INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    msrp_cents,
    data_reliability
) VALUES (
    13, 1, 'Curveball Jr',
    TRUE,
    NULL,
    'Low'
);

INSERT INTO pedal_details (
    product_id,
    effect_type, signal_type, bypass_type, mono_stereo,
    battery_capable, fx_loop_count
) VALUES (
    currval('products_id_seq'),
    'Filter', 'Analog', 'True Bypass', 'Mono',
    FALSE, 0
);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9-18V', NULL, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS', 'Input');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Output');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

COMMIT;


-- ─── 3. DEPTHFINDER ──────────────────────────────────────────────────────────
-- 2-band active boost-only EQ (Resonance + Presence); mimics power amp damping
-- response, matched to 5150 amp voicing; adapter only (no battery fit)
-- MSRP not entered — base price varies by bundle (no supply / 9V / 18V adapter)

BEGIN;

INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    weight_grams,
    msrp_cents, product_page,
    data_reliability
) VALUES (
    13, 1, 'DepthFinder',
    TRUE,
    170,
    NULL, 'https://amptweaker.com/product/depth-finder/',
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

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9-18V', 4, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS', 'Input');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Output');

INSERT INTO product_sources (product_id, table_name, field_name, value_recorded, source_type, source_url, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'weight_grams', '6 oz',  'review_site', 'https://www.premierguitar.com/', 'Medium', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'product_page', 'https://amptweaker.com/product/depth-finder/', 'manufacturer_website', 'https://amptweaker.com/', 'High', '2026-03-21');

INSERT INTO product_sources (product_id, table_name, field_name, value_recorded, source_type, source_url, reliability, accessed_at, jack_id)
VALUES (
    currval('products_id_seq'), 'jacks', 'current_ma', '4mA', 'review_site', 'https://www.premierguitar.com/', 'Medium', '2026-03-21',
    (SELECT id FROM jacks WHERE product_id = currval('products_id_seq') AND category = 'power' AND direction = 'input')
);

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

COMMIT;


-- ─── 4. FAT ROCK (DISCONTINUED) ──────────────────────────────────────────────
-- Mid-gain distortion; discontinued per Reverb listings
-- Battery capable (9V battery); FX loop not confirmed for this model
-- Dimensions from Reverb listing: 93 × 127 × 51 mm

BEGIN;

INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    msrp_cents,
    data_reliability,
    notes
) VALUES (
    13, 1, 'Fat Rock',
    FALSE,
    93.0, 127.0, 51.0, 900,
    16150,
    'Low',
    'Discontinued. MSRP is last known price from Reverb listings. FX loop presence not confirmed from research.'
);

INSERT INTO pedal_details (
    product_id,
    effect_type, signal_type, bypass_type, mono_stereo,
    battery_capable, fx_loop_count
) VALUES (
    currval('products_id_seq'),
    'Gain', 'Analog', NULL, 'Mono',
    TRUE, 0
);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9-18V', 28, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS', 'Input');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Output');

INSERT INTO product_sources (product_id, table_name, field_name, value_recorded, source_type, source_url, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'width_mm',     '93 x 127 x 51 mm',  'major_retailer', 'https://reverb.com/', 'Low', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'depth_mm',     '93 x 127 x 51 mm',  'major_retailer', 'https://reverb.com/', 'Low', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'height_mm',    '93 x 127 x 51 mm',  'major_retailer', 'https://reverb.com/', 'Low', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'weight_grams', '900 g (31.7 oz)',    'major_retailer', 'https://reverb.com/', 'Low', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'msrp_cents',   '$161.50 (last known)', 'major_retailer', 'https://reverb.com/', 'Low', '2026-03-21');

INSERT INTO product_sources (product_id, table_name, field_name, value_recorded, source_type, source_url, reliability, accessed_at, jack_id)
VALUES (
    currval('products_id_seq'), 'jacks', 'current_ma', '28mA @ 9V', 'major_retailer', 'https://reverb.com/', 'Low', '2026-03-21',
    (SELECT id FROM jacks WHERE product_id = currval('products_id_seq') AND category = 'power' AND direction = 'input')
);

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

COMMIT;


-- ─── 5. PRESSURIZER ──────────────────────────────────────────────────────────
-- VCA compressor with FET output limiter/booster; Bloom switch, Tone control
-- MSRP not entered — Reverb range was $189–$210, too wide to pick a value

BEGIN;

INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    msrp_cents,
    data_reliability
) VALUES (
    13, 1, 'PressuRizer',
    TRUE,
    NULL,
    'Low'
);

INSERT INTO pedal_details (
    product_id,
    effect_type, signal_type, bypass_type, mono_stereo,
    battery_capable, fx_loop_count
) VALUES (
    currval('products_id_seq'),
    'Compression', 'Analog', 'True Bypass', 'Mono',
    FALSE, 0
);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9-18V', NULL, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS', 'Input');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Output');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

COMMIT;


-- ─── 6. SWIRLPOOL ────────────────────────────────────────────────────────────
-- Synchronized tremolo + vibrato circuits (vintage 60s amp style); dual speed
-- switches, tremolo defeat, EFX loop with pre/post, LED-lit knobs
-- Requires 18V: either 2×9V batteries in series or 18VDC adapter

BEGIN;

INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm,
    msrp_cents,
    data_reliability
) VALUES (
    13, 1, 'SwirlPool',
    TRUE,
    142.9, 127.0, 54.0,
    32999,
    'Low'
);

INSERT INTO pedal_details (
    product_id,
    effect_type, signal_type, bypass_type, mono_stereo,
    battery_capable, fx_loop_count
) VALUES (
    currval('products_id_seq'),
    'Multi Effects', 'Analog', 'True Bypass', 'Mono',
    TRUE, 1
);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '18V', NULL, 'Center Negative');

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
    (currval('products_id_seq'), 'products', 'width_mm',     '5.625 x 5 x 2.125 in', 'other', 'https://equipboard.com/', 'Low', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'depth_mm',     '5.625 x 5 x 2.125 in', 'other', 'https://equipboard.com/', 'Low', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'height_mm',    '5.625 x 5 x 2.125 in', 'other', 'https://equipboard.com/', 'Low', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'msrp_cents',   '$329.99',               'major_retailer', 'https://reverb.com/', 'Low', '2026-03-21');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

COMMIT;


-- ─── 7. SWIRLPOOL JR ─────────────────────────────────────────────────────────
-- Compact version of SwirlPool; less than half the width; same core controls
-- FX loop not confirmed for JR model

BEGIN;

INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    weight_grams,
    msrp_cents,
    data_reliability
) VALUES (
    13, 1, 'SwirlPool JR',
    TRUE,
    255,
    NULL,
    'Low'
);

INSERT INTO pedal_details (
    product_id,
    effect_type, signal_type, bypass_type, mono_stereo,
    battery_capable, fx_loop_count
) VALUES (
    currval('products_id_seq'),
    'Multi Effects', 'Analog', NULL, 'Mono',
    FALSE, 0
);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9-18V', NULL, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS', 'Input');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Output');

INSERT INTO product_sources (product_id, table_name, field_name, value_recorded, source_type, source_url, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'weight_grams', '9 oz', 'other', 'https://mmrmagazine.com/', 'Low', '2026-03-21');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

COMMIT;


-- ─── 8. TIGHT BOOST ──────────────────────────────────────────────────────────
-- Clean boost with SideTrak effects loop (pre/post switchable); Parked Wah
-- voicing at mid gain; battery capable

BEGIN;

INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm,
    msrp_cents,
    data_reliability
) VALUES (
    13, 1, 'Tight Boost',
    TRUE,
    95.3, 127.0, 50.8,
    14900,
    'Medium'
);

INSERT INTO pedal_details (
    product_id,
    effect_type, signal_type, bypass_type, mono_stereo,
    battery_capable, fx_loop_count
) VALUES (
    currval('products_id_seq'),
    'Gain', 'Analog', 'True Bypass', 'Mono',
    TRUE, 1
);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9-18V', 26, 'Center Negative');

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
    (currval('products_id_seq'), 'products', 'width_mm',     '3.75 x 5 x 2 in', 'review_site', 'https://www.premierguitar.com/', 'Medium', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'depth_mm',     '3.75 x 5 x 2 in', 'review_site', 'https://www.premierguitar.com/', 'Medium', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'height_mm',    '3.75 x 5 x 2 in', 'review_site', 'https://www.premierguitar.com/', 'Medium', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'msrp_cents',   '$149.00',          'major_retailer', 'https://reverb.com/', 'Medium', '2026-03-21');

INSERT INTO product_sources (product_id, table_name, field_name, value_recorded, source_type, source_url, reliability, accessed_at, jack_id)
VALUES (
    currval('products_id_seq'), 'jacks', 'current_ma', '26mA @ 9V', 'review_site', 'https://www.premierguitar.com/', 'Medium', '2026-03-21',
    (SELECT id FROM jacks WHERE product_id = currval('products_id_seq') AND category = 'power' AND direction = 'input')
);

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

COMMIT;


-- ─── 9. TIGHT DRIVE JR ───────────────────────────────────────────────────────
-- Compact overdrive; no effects loop; noise gate; EQ and voice switches

BEGIN;

INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    msrp_cents,
    data_reliability
) VALUES (
    13, 1, 'Tight Drive JR',
    TRUE,
    NULL,
    'Low'
);

INSERT INTO pedal_details (
    product_id,
    effect_type, signal_type, bypass_type, mono_stereo,
    battery_capable, fx_loop_count
) VALUES (
    currval('products_id_seq'),
    'Gain', 'Analog', 'True Bypass', 'Mono',
    FALSE, 0
);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9-18V', 13, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS', 'Input');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Output');

INSERT INTO product_sources (product_id, table_name, field_name, value_recorded, source_type, source_url, reliability, accessed_at, jack_id)
VALUES (
    currval('products_id_seq'), 'jacks', 'current_ma', '13mA @ 9V', 'review_site', 'https://www.premierguitar.com/', 'Medium', '2026-03-21',
    (SELECT id FROM jacks WHERE product_id = currval('products_id_seq') AND category = 'power' AND direction = 'input')
);

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

COMMIT;


-- ─── 10. TIGHT DRIVE PRO ─────────────────────────────────────────────────────
-- Full-featured overdrive; 2-button, dual boost, 3-band EQ, 3 SideTrak loops

BEGIN;

INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    msrp_cents,
    data_reliability
) VALUES (
    13, 1, 'Tight Drive Pro',
    TRUE,
    NULL,
    'Low'
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
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9-18V', NULL, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS', 'Input');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Output');

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

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

COMMIT;


-- ─── 11. TIGHT FUZZ ──────────────────────────────────────────────────────────
-- Silicon/Germanium switchable fuzz; 60s/70s tone voicing; Edge/Smooth settings;
-- Tight control (pre-gain bass cut). FX loop not confirmed from research.

BEGIN;

INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    msrp_cents,
    data_reliability
) VALUES (
    13, 1, 'Tight Fuzz',
    TRUE,
    22900,
    'Low'
);

INSERT INTO pedal_details (
    product_id,
    effect_type, signal_type, bypass_type, mono_stereo,
    battery_capable, fx_loop_count
) VALUES (
    currval('products_id_seq'),
    'Fuzz', 'Analog', 'True Bypass', 'Mono',
    FALSE, 0
);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9-18V', NULL, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS', 'Input');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Output');

INSERT INTO product_sources (product_id, table_name, field_name, value_recorded, source_type, source_url, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'msrp_cents', '$229.00', 'major_retailer', 'https://reverb.com/', 'Low', '2026-03-21');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

COMMIT;


-- ─── 12. TIGHT FUZZ JR ───────────────────────────────────────────────────────
-- Compact silicon/germanium fuzz; Tight attack switch; 60s/70s/Now EQ settings

BEGIN;

INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    msrp_cents,
    data_reliability
) VALUES (
    13, 1, 'Tight Fuzz JR',
    TRUE,
    17000,
    'Low'
);

INSERT INTO pedal_details (
    product_id,
    effect_type, signal_type, bypass_type, mono_stereo,
    battery_capable, fx_loop_count
) VALUES (
    currval('products_id_seq'),
    'Fuzz', 'Analog', 'True Bypass', 'Mono',
    FALSE, 0
);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9-18V', NULL, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS', 'Input');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Output');

INSERT INTO product_sources (product_id, table_name, field_name, value_recorded, source_type, source_url, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'msrp_cents', '$170.00', 'review_site', 'https://www.musicradar.com/', 'Medium', '2026-03-21');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

COMMIT;


-- ─── 13. TIGHT METAL JR (DISCONTINUED) ───────────────────────────────────────
-- Compact high-gain distortion; no effects loop; noise gate
-- Note: current draw reported as "100mA minimum required" by one source —
-- this appears to be a power supply minimum rating, not actual draw; actual
-- draw not found. Effect type is Gain (high-gain distortion), not Fuzz.

BEGIN;

INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    msrp_cents,
    data_reliability,
    notes
) VALUES (
    13, 1, 'Tight Metal JR',
    FALSE,
    NULL,
    'Low',
    'Discontinued per retailer listings. Current draw noted as "100mA minimum required" by one source — likely a power supply minimum recommendation, not measured draw.'
);

INSERT INTO pedal_details (
    product_id,
    effect_type, signal_type, bypass_type, mono_stereo,
    battery_capable, fx_loop_count
) VALUES (
    currval('products_id_seq'),
    'Gain', 'Analog', NULL, 'Mono',
    FALSE, 0
);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9-18V', NULL, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS', 'Input');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Output');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

COMMIT;


-- ─── 14. TIGHT ROCK JR (DISCONTINUED) ────────────────────────────────────────
-- Compact mid-gain distortion; no effects loop; simplified controls vs. standard

BEGIN;

INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    msrp_cents,
    data_reliability
) VALUES (
    13, 1, 'Tight Rock JR',
    FALSE,
    NULL,
    'Low'
);

INSERT INTO pedal_details (
    product_id,
    effect_type, signal_type, bypass_type, mono_stereo,
    battery_capable, fx_loop_count
) VALUES (
    currval('products_id_seq'),
    'Gain', 'Analog', NULL, 'Mono',
    FALSE, 0
);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9-18V', NULL, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS', 'Input');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Output');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

COMMIT;
