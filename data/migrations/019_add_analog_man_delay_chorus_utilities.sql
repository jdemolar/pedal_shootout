-- Migration 019: Add Analog Man delay, chorus, and utilities (Manufacturer ID 16)
-- 8 products: ARDX20, Standard Chorus, Mini Chorus, Bi-Chorus, Foot Chorus,
--             AMAZE1, AMAZE0 (discontinued), Buffer Pedal

BEGIN;

-- ============================================================
-- 1. ARDX20 DUAL ANALOG DELAY
-- ============================================================
INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm,
    weight_grams, msrp_cents,
    product_page,
    description, data_reliability
) VALUES (
    16, 1, 'ARDX20',
    TRUE,
    NULL, NULL, NULL,
    NULL, NULL,
    'https://www.analogman.com/delay.htm',
    'Hand-made 100% analog BBD dual-delay. Two independent channels each with delay time (36–600ms), feedback, and level controls. FX loop for inserting effects into delay path. Expression input for delay time control.',
    'Medium'
);

INSERT INTO pedal_details (
    product_id,
    effect_type, signal_type, bypass_type, mono_stereo,
    battery_capable,
    fx_loop_count
) VALUES (
    currval('products_id_seq'),
    'Delay', 'Analog', 'True Bypass', 'Mono',
    TRUE,
    1
);

-- Jacks: power + audio in + audio out + expression in + FX loop send + FX loop return = 6
INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', NULL, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'expression', 'input', '1/4" TS', 'Delay Time');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, group_id)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'FX Loop Send', 'loop_1');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, group_id)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS', 'FX Loop Return', 'loop_1');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'product_page', 'https://www.analogman.com/delay.htm', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'pedal_details', 'effect_type', 'https://www.analogman.com/delay.htm', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'pedal_details', 'bypass_type', 'https://www.analogman.com/delay.htm', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'pedal_details', 'fx_loop_count', 'https://www.buyanalogman.com/Analog_Man_ARDX20_Dual_Analog_Delay_p/am-ardx20.htm', 'manufacturer_website', 'High', '2026-03-21');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 2. STANDARD CHORUS
-- ============================================================
INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm,
    weight_grams, msrp_cents,
    product_page,
    description, data_reliability
) VALUES (
    16, 1, 'Standard Chorus',
    TRUE,
    NULL, NULL, NULL,
    NULL, NULL,
    'https://analogman.com/clone.htm',
    '100% analog chorus using NOS high-voltage Panasonic MN3007 bucket brigade chips. Speed and Depth controls. True bypass since 2000. Optional Deep toggle and Mix/Blend knob. Current draw: <10mA on.',
    'Medium'
);

INSERT INTO pedal_details (
    product_id,
    effect_type, signal_type, bypass_type, mono_stereo,
    battery_capable
) VALUES (
    currval('products_id_seq'),
    'Chorus', 'Analog', 'True Bypass', 'Mono',
    TRUE
);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', 10, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'product_page', 'https://analogman.com/clone.htm', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'pedal_details', 'effect_type', 'https://analogman.com/clone.htm', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'pedal_details', 'bypass_type', 'https://analogman.com/clone.htm', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'pedal_details', 'battery_capable', 'https://www.buyanalogman.com/Analog_Man_Standard_Chorus_p/am-standard-chorus.htm', 'manufacturer_website', 'High', '2026-03-21');

INSERT INTO product_sources (product_id, table_name, field_name, jack_id, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'jacks', 'current_ma',
     (SELECT id FROM jacks WHERE product_id = currval('products_id_seq') AND category = 'power' AND direction = 'input'),
     'https://analogman.com/clone.htm', 'manufacturer_website', '<10mA on', 'High', '2026-03-21');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 3. MINI CHORUS
-- ============================================================
INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm,
    weight_grams, msrp_cents,
    product_page,
    description, data_reliability
) VALUES (
    16, 1, 'Mini Chorus',
    TRUE,
    63.5, 120.7, 38.1,
    NULL, NULL,
    'https://analogman.com/clone.htm',
    '100% analog chorus using NOS high-voltage Panasonic MN3007 bucket brigade chips. Same circuit as Standard Chorus in a smaller enclosure. Speed and Depth controls. Current draw: <10mA on.',
    'Medium'
);

INSERT INTO pedal_details (
    product_id,
    effect_type, signal_type, bypass_type, mono_stereo,
    battery_capable
) VALUES (
    currval('products_id_seq'),
    'Chorus', 'Analog', 'True Bypass', 'Mono',
    TRUE
);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', 10, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'product_page', 'https://analogman.com/clone.htm', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'width_mm', 'https://www.buyanalogman.com/Analog_Man_Mini_Chorus_p/am-mini-chorus.htm', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'depth_mm', 'https://www.buyanalogman.com/Analog_Man_Mini_Chorus_p/am-mini-chorus.htm', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'height_mm', 'https://www.buyanalogman.com/Analog_Man_Mini_Chorus_p/am-mini-chorus.htm', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'pedal_details', 'effect_type', 'https://analogman.com/clone.htm', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'pedal_details', 'bypass_type', 'https://analogman.com/clone.htm', 'manufacturer_website', 'High', '2026-03-21');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 4. BI-CHORUS
-- ============================================================
INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm,
    weight_grams, msrp_cents,
    product_page,
    description, data_reliability
) VALUES (
    16, 1, 'Bi-Chorus',
    TRUE,
    NULL, NULL, NULL,
    NULL, NULL,
    'https://www.buyanalogman.com/Analog_Man_Bi_Chorus_p/AM-Bi-Chorus.htm',
    'Two independent 100% analog chorus circuits (NOS MN3007 BBD chips) in one enclosure. Two sets of Speed and Depth controls allow instant switching between distinct settings.',
    'Medium'
);

INSERT INTO pedal_details (
    product_id,
    effect_type, signal_type, bypass_type, mono_stereo,
    battery_capable
) VALUES (
    currval('products_id_seq'),
    'Chorus', 'Analog', 'True Bypass', 'Mono',
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
    (currval('products_id_seq'), 'products', 'product_page', 'https://www.buyanalogman.com/Analog_Man_Bi_Chorus_p/AM-Bi-Chorus.htm', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'pedal_details', 'effect_type', 'https://www.buyanalogman.com/Analog_Man_Bi_Chorus_p/AM-Bi-Chorus.htm', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'pedal_details', 'bypass_type', 'https://www.buyanalogman.com/Analog_Man_Bi_Chorus_p/AM-Bi-Chorus.htm', 'manufacturer_website', 'High', '2026-03-21');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 5. FOOT CHORUS
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
    16, 1, 'Foot Chorus',
    TRUE,
    NULL, NULL, NULL,
    NULL, NULL,
    'https://www.buyanalogman.com/Analog_Man_Foot_Chorus_p/am-foot-chorus.htm',
    'Analog Man chorus circuit built into a wah-style shell. The rocker pedal controls Speed; side-mounted knob controls Depth. True bypass switch and LED.',
    'Low',
    'Enclosure is a custom wah-style shell; no standard dimensions found. Historical MSRP was $285 but cannot confirm current pricing. Limited documentation available.'
);

INSERT INTO pedal_details (
    product_id,
    effect_type, signal_type, bypass_type, mono_stereo
) VALUES (
    currval('products_id_seq'),
    'Chorus', 'Analog', 'True Bypass', 'Mono'
);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', NULL, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'product_page', 'https://www.buyanalogman.com/Analog_Man_Foot_Chorus_p/am-foot-chorus.htm', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'pedal_details', 'effect_type', 'https://analogman.com/clone.htm', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'pedal_details', 'bypass_type', 'https://analogman.com/clone.htm', 'manufacturer_website', 'High', '2026-03-21');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 6. AMAZE1 (Tap Tempo / Modulation Controller) — Utility
-- ============================================================
INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm,
    weight_grams, msrp_cents,
    product_page,
    description, data_reliability
) VALUES (
    16, 5, 'AMAZE1',
    TRUE,
    117.5, 57.2, 44.5,
    NULL, NULL,
    'https://www.buyanalogman.com/Analog_Man_AMAZE1_Analog_Delay_Tap_Tempo_and_Modul_p/am-amaze1.htm',
    'Tap tempo and modulation controller for the Analog Man ARDX20 Dual Analog Delay. 8 banks of programmable delay times with modulation settings per preset. Connects via stereo (TRS) cable. Current draw: ~30mA.',
    'Medium'
);

INSERT INTO utility_details (
    product_id,
    utility_type, is_active, signal_type
) VALUES (
    currval('products_id_seq'),
    'Tap Tempo', TRUE, 'Analog'
);

-- Jacks: power + 2x TRS control (to/from delay) + 1x TRS function/expression = 4
INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', 30, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'aux', 'output', '1/4" TRS', 'Control Out (to delay)');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'aux', 'input', '1/4" TRS', 'Control In (from delay)');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'aux', 'input', '1/4" TRS', 'Function/Expression');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'product_page', 'https://www.buyanalogman.com/Analog_Man_AMAZE1_Analog_Delay_Tap_Tempo_and_Modul_p/am-amaze1.htm', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'width_mm', 'https://www.buyanalogman.com/Analog_Man_AMAZE1_Analog_Delay_Tap_Tempo_and_Modul_p/am-amaze1.htm', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'depth_mm', 'https://www.buyanalogman.com/Analog_Man_AMAZE1_Analog_Delay_Tap_Tempo_and_Modul_p/am-amaze1.htm', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'height_mm', 'https://www.buyanalogman.com/Analog_Man_AMAZE1_Analog_Delay_Tap_Tempo_and_Modul_p/am-amaze1.htm', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'utility_details', 'utility_type', 'https://www.buyanalogman.com/Analog_Man_AMAZE1_Analog_Delay_Tap_Tempo_and_Modul_p/am-amaze1.htm', 'manufacturer_website', 'High', '2026-03-21');

INSERT INTO product_sources (product_id, table_name, field_name, jack_id, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'jacks', 'current_ma',
     (SELECT id FROM jacks WHERE product_id = currval('products_id_seq') AND category = 'power' AND direction = 'input'),
     'https://www.buyanalogman.com/Analog_Man_AMAZE1_Analog_Delay_Tap_Tempo_and_Modul_p/am-amaze1.htm', 'manufacturer_website', '~30mA', 'High', '2026-03-21');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 7. AMAZE0 (Discontinued) — Utility
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
    16, 5, 'AMAZE0',
    FALSE,
    NULL, NULL, NULL,
    NULL, NULL,
    'https://www.buyanalogman.com/Analog_Man_AMAZE0_Analog_Delay_Tap_Tempo_and_Modul_p/am-amaze0.htm',
    'Tap tempo and modulation controller for the Analog Man ARDX20 Dual Analog Delay. Predecessor to the AMAZE1. Discontinued in 2015.',
    'Low',
    'Discontinued 2015; replaced by AMAZE1 in 2017. Minimal technical specs available.'
);

INSERT INTO utility_details (
    product_id,
    utility_type, is_active, signal_type
) VALUES (
    currval('products_id_seq'),
    'Tap Tempo', TRUE, 'Analog'
);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', NULL, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'aux', 'output', '1/4" TRS', 'Control Out (to delay)');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'aux', 'input', '1/4" TRS', 'Control In (from delay)');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'product_page', 'https://www.buyanalogman.com/Analog_Man_AMAZE0_Analog_Delay_Tap_Tempo_and_Modul_p/am-amaze0.htm', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'utility_details', 'utility_type', 'https://www.buyanalogman.com/Analog_Man_AMAZE0_Analog_Delay_Tap_Tempo_and_Modul_p/am-amaze0.htm', 'manufacturer_website', 'High', '2026-03-21');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 8. BUFFER PEDAL — Utility
-- ============================================================
INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm,
    weight_grams, msrp_cents,
    product_page,
    description, data_reliability
) VALUES (
    16, 5, 'Buffer Pedal',
    TRUE,
    NULL, NULL, NULL,
    NULL, NULL,
    'https://www.buyanalogman.com/Analog_Man_Buffer_Pedal_p/am-buffer-pedal.htm',
    'Single-stage transistor buffer with JRC 4558D op-amp output stage. Input impedance 510K ohms (same as original Tube Screamer). Works at 9V–18V+ for more headroom. Includes reverse polarity protection.',
    'Medium'
);

INSERT INTO utility_details (
    product_id,
    utility_type, is_active, signal_type
) VALUES (
    currval('products_id_seq'),
    'Buffer', TRUE, 'Analog'
);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', NULL, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'product_page', 'https://www.buyanalogman.com/Analog_Man_Buffer_Pedal_p/am-buffer-pedal.htm', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'utility_details', 'utility_type', 'https://www.buyanalogman.com/Analog_Man_Buffer_Pedal_p/am-buffer-pedal.htm', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'utility_details', 'is_active', 'https://www.analogman.com/buffer.htm', 'manufacturer_website', 'High', '2026-03-21');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

COMMIT;
