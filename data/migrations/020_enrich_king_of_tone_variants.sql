-- Migration 020: Enrich King of Tone base record and add variants
-- Source: https://www.analogman.com/kingtone.htm (High reliability)
-- Base price: $335. Variants priced at base + add-on fee.
--
-- Products:
--   Update ID 362 — King of Tone (base)
--   New — King of Tone (4-Jack)        $385 ($335 + $50)
--   New — King of Tone (Buffered Bypass) $380 ($335 + $45)
--   New — King of Tone (Second Output)  $345 ($335 + $10)
--   New — King of Tone (Second Power Jack) $350 ($335 + $15)

BEGIN;

-- ============================================================
-- UPDATE: King of Tone base record (ID 362)
-- ============================================================
UPDATE products SET
    msrp_cents      = 33500,
    height_mm       = 38.1,   -- 1.5" body (manufacturer page); previously ~50.8 from review site
    data_reliability = 'High',
    notes = 'Base price $335. Available options (separate product rows for jack/bypass changes): '
         || '4-Jack version (+$50), Buffered Bypass (+$45), Second Output (+$10), Second Power Jack (+$15). '
         || 'Internal options (not separate products): Higher Gain per side (+$10 each), '
         || 'External mode toggle switch on red side (+$50).'
WHERE id = 362;

UPDATE pedal_details SET
    battery_capable = TRUE
WHERE product_id = 362;

-- Update power jack: add current_ma and fix height source
UPDATE jacks SET current_ma = 10
WHERE product_id = 362 AND category = 'power' AND direction = 'input';

-- Update product sources to reflect manufacturer page as source
INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES
    (362, 'products', 'msrp_cents',  'https://www.analogman.com/kingtone.htm', 'manufacturer_website', '$335', 'High', '2026-03-21'),
    (362, 'products', 'height_mm',   'https://www.analogman.com/kingtone.htm', 'manufacturer_website', '1.5 inches', 'High', '2026-03-21'),
    (362, 'products', 'width_mm',    'https://www.analogman.com/kingtone.htm', 'manufacturer_website', '4.75 inches', 'High', '2026-03-21'),
    (362, 'products', 'depth_mm',    'https://www.analogman.com/kingtone.htm', 'manufacturer_website', '3.75 inches', 'High', '2026-03-21'),
    (362, 'pedal_details', 'battery_capable', 'https://www.analogman.com/kingtone.htm', 'manufacturer_website', '~100 hour battery life', 'High', '2026-03-21');

INSERT INTO product_sources (product_id, table_name, field_name, jack_id, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES
    (362, 'jacks', 'current_ma',
     (SELECT id FROM jacks WHERE product_id = 362 AND category = 'power' AND direction = 'input'),
     'https://www.analogman.com/kingtone.htm', 'manufacturer_website', '6–10mA', 'High', '2026-03-21');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = 362;

-- ============================================================
-- NEW: King of Tone (4-Jack)  —  $385
-- ============================================================
-- Two overdrive stages with normalled FX loop insert between them.
-- With nothing in the loop jacks, signal passes through both stages in series
-- (identical to standard). Inserting cables into the loop breaks the chain,
-- enabling effects between stages or fully independent use of each side.
INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm,
    weight_grams, msrp_cents,
    product_page,
    description, data_reliability,
    notes
) VALUES (
    16, 1, 'King of Tone (4-Jack)',
    TRUE,
    120.7, 95.3, 38.1,
    NULL, 38500,
    'https://www.analogman.com/kingtone.htm',
    'King of Tone with normalled 4-jack configuration. An FX loop insert sits between the two overdrive stages: by default both stages run in series with nothing plugged in; inserting cables breaks the chain for effects between stages or fully independent use of each side as a standalone overdrive.',
    'High',
    'Uses normalled (passive) jacks — no bypass switch. Loop is broken only by inserting cables. Each side can also be used as a fully independent overdrive. Add-on cost: +$50 over base King of Tone ($335).'
);

INSERT INTO pedal_details (
    product_id,
    effect_type, signal_type, bypass_type, mono_stereo,
    battery_capable,
    fx_loop_count
) VALUES (
    currval('products_id_seq'),
    'Gain', 'Analog', 'True Bypass', 'Mono',
    TRUE,
    1
);

-- 5 jacks: power + audio in + audio out + FX loop send + FX loop return
INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', 10, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS', 'Input 1');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, group_id)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Output 1', 'loop_1');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, group_id)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS', 'Input 2', 'loop_1');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Output 2');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'msrp_cents', 'https://www.analogman.com/kingtone.htm', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'pedal_details', 'fx_loop_count', 'https://www.analogman.com/kingtone.htm', 'manufacturer_website', 'High', '2026-03-21');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- NEW: King of Tone (Buffered Bypass)  —  $380
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
    16, 1, 'King of Tone (Buffered Bypass)',
    TRUE,
    120.7, 95.3, 38.1,
    NULL, 38000,
    'https://www.analogman.com/kingtone.htm',
    'King of Tone with buffered bypass instead of true bypass. Signal is always buffered regardless of switch position. Battery compartment is eliminated in this configuration.',
    'High',
    'Buffered bypass eliminates the battery compartment — external power supply required. Add-on cost: +$45 over base King of Tone ($335).'
);

INSERT INTO pedal_details (
    product_id,
    effect_type, signal_type, bypass_type, mono_stereo,
    battery_capable
) VALUES (
    currval('products_id_seq'),
    'Gain', 'Analog', 'Buffered Bypass', 'Mono',
    FALSE
);

-- 3 jacks: power + audio in + audio out (no battery)
INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', 10, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'msrp_cents', 'https://www.analogman.com/kingtone.htm', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'pedal_details', 'bypass_type', 'https://www.analogman.com/kingtone.htm', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'pedal_details', 'battery_capable', 'https://www.analogman.com/kingtone.htm', 'manufacturer_website', 'High', '2026-03-21');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- NEW: King of Tone (Second Output)  —  $345
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
    16, 1, 'King of Tone (Second Output)',
    TRUE,
    120.7, 95.3, 38.1,
    NULL, 34500,
    'https://www.analogman.com/kingtone.htm',
    'King of Tone with a second output jack, allowing the signal to be sent to two separate destinations (e.g., two amplifiers) simultaneously.',
    'High',
    'Add-on cost: +$10 over base King of Tone ($335).'
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

-- 4 jacks: power + audio in + 2× audio out
INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', 10, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Output 1');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Output 2');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'msrp_cents', 'https://www.analogman.com/kingtone.htm', 'manufacturer_website', 'High', '2026-03-21');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- NEW: King of Tone (Second Power Jack)  —  $350
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
    16, 1, 'King of Tone (Second Power Jack)',
    TRUE,
    120.7, 95.3, 38.1,
    NULL, 35000,
    'https://www.analogman.com/kingtone.htm',
    'King of Tone with a second power input jack, useful for daisy-chaining power to another pedal or connecting to two independent power supplies.',
    'High',
    'Add-on cost: +$15 over base King of Tone ($335).'
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

-- 4 jacks: 2× power in + audio in + audio out
INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity, jack_name)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', 10, 'Center Negative', 'Power Jack 1');

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity, jack_name)
VALUES (currval('products_id_seq'), 'power', 'output', '2.1mm barrel', '9V', 10, 'Center Negative', 'Power Jack 2');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'msrp_cents', 'https://www.analogman.com/kingtone.htm', 'manufacturer_website', 'High', '2026-03-21');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

COMMIT;
