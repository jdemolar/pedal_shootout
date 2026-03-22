-- Migration 017: Add Analog Man fuzz and boost pedals (Manufacturer ID 16)
-- 9 pedals: Sun Face, Peppermint, Sun Bender MK1.5, Sun Bender MK-IV, Astro Tone,
--           Sun Lion, Beano Boost, Bad Bob Booster, Bad Bob Booster Mini
--
-- Data decisions:
-- - Power jacks included for all (optional on fuzz pedals per user instruction)
-- - Sun Lion effect_type: 'Gain' (user decision — boost + fuzz combo)
-- - All fuzz pedals battery_capable = TRUE (battery is primary power source)
-- - Peppermint width_mm: NULL (only one questionable 70mm metric found, omitted)
-- - MSRP: NULL for all (no confirmed USD pricing found)
-- - product_page: analogman.com info pages used where available

BEGIN;

-- ============================================================
-- 1. SUN FACE FUZZ
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
    16, 1, 'Sun Face Fuzz',
    TRUE,
    NULL, NULL, NULL,
    NULL, NULL,
    'https://www.analogman.com/fuzzface.htm',
    'Hand-wired Fuzz Face-based fuzz pedal available with germanium (NKT275, 2SB175, RCA, and others) or silicon (BC183, BC108C) transistors. Internal clean trim pot standard. Sundial knob option available.',
    'Medium',
    'Power jack is an optional add-on at order time; battery is the default power source. Positive ground circuit — requires isolated power supply if power jack used.'
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
    (currval('products_id_seq'), 'products', 'product_page', 'https://www.analogman.com/fuzzface.htm', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'pedal_details', 'effect_type', 'https://www.analogman.com/fuzzface.htm', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'pedal_details', 'bypass_type', 'https://www.analogman.com/fuzzface.htm', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'pedal_details', 'battery_capable', 'https://www.analogman.com/fuzzface.htm', 'manufacturer_website', 'High', '2026-03-21');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 2. PEPPERMINT FUZZ
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
    16, 1, 'Peppermint Fuzz',
    TRUE,
    NULL, NULL, NULL,
    NULL, NULL,
    'https://analogman.com/pepper.htm',
    'High-gain germanium fuzz with Fuzz Face-derived architecture. Controls: Fuzz, Volume, Tone. Positive ground circuit — requires isolated power supply if power jack used.',
    'Medium',
    'Power jack is an optional add-on at order time; battery is the default power source.'
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
    (currval('products_id_seq'), 'products', 'product_page', 'https://analogman.com/pepper.htm', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'pedal_details', 'effect_type', 'https://analogman.com/pepper.htm', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'pedal_details', 'bypass_type', 'https://analogman.com/pepper.htm', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'pedal_details', 'battery_capable', 'https://analogman.com/pepper.htm', 'manufacturer_website', 'High', '2026-03-21');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 3. SUN BENDER MK1.5 FUZZ
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
    16, 1, 'Sun Bender MK1.5',
    TRUE,
    58.7, 109.5, NULL,
    NULL, NULL,
    'https://www.buyanalogman.com/Analog_Man_Sun_Bender_MK1_5_p/am-sunbendermk1.5.htm',
    'Two-transistor Tone Bender MK1.5 clone with NOS germanium transistors. Controls: Volume, Fuzz, Bias trim pot. Input jack on right side disconnects battery when unplugged.',
    'Medium',
    'Power jack is an optional add-on; battery is default. height_mm unknown — MXR/1590B enclosure (58.7 × 109.5mm) but height not found in sources.'
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
    (currval('products_id_seq'), 'products', 'product_page', 'https://www.buyanalogman.com/Analog_Man_Sun_Bender_MK1_5_p/am-sunbendermk1.5.htm', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'width_mm', 'https://www.buyanalogman.com/Analog_Man_Sun_Bender_MK1_5_p/am-sunbendermk1.5.htm', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'depth_mm', 'https://www.buyanalogman.com/Analog_Man_Sun_Bender_MK1_5_p/am-sunbendermk1.5.htm', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'pedal_details', 'effect_type', 'https://www.buyanalogman.com/Analog_Man_Sun_Bender_MK1_5_p/am-sunbendermk1.5.htm', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'pedal_details', 'bypass_type', 'https://www.buyanalogman.com/Analog_Man_Sun_Bender_MK1_5_p/am-sunbendermk1.5.htm', 'manufacturer_website', 'High', '2026-03-21');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 4. SUN BENDER MK-IV FUZZ
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
    16, 1, 'Sun Bender MK-IV',
    TRUE,
    58.7, 109.5, NULL,
    NULL, NULL,
    'https://www.buyanalogman.com/Analog_Man_Sun_Bender_MK_IV_p/am-sunbendermkiv.htm',
    'Three-transistor germanium Tone Bender clone (Sola Sound/Colorsound VOX Tonebender). Built with NOS parts: 1x NKT Red Dot + 2x Russian transistors. More saturated 1970s sound. Internal bias trim pot.',
    'Medium',
    'Power jack is an optional add-on; battery is default. height_mm unknown.'
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
    (currval('products_id_seq'), 'products', 'product_page', 'https://www.buyanalogman.com/Analog_Man_Sun_Bender_MK_IV_p/am-sunbendermkiv.htm', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'width_mm', 'https://www.buyanalogman.com/Analog_Man_Sun_Bender_MK_IV_p/am-sunbendermkiv.htm', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'depth_mm', 'https://www.buyanalogman.com/Analog_Man_Sun_Bender_MK_IV_p/am-sunbendermkiv.htm', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'pedal_details', 'effect_type', 'https://www.buyanalogman.com/Analog_Man_Sun_Bender_MK_IV_p/am-sunbendermkiv.htm', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'pedal_details', 'bypass_type', 'https://www.buyanalogman.com/Analog_Man_Sun_Bender_MK_IV_p/am-sunbendermkiv.htm', 'manufacturer_website', 'High', '2026-03-21');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 5. ASTRO TONE FUZZ
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
    16, 1, 'Astro Tone Fuzz',
    TRUE,
    NULL, NULL, NULL,
    NULL, NULL,
    'https://www.analogman.com/astrotone.htm',
    'Silicon fuzz based on the 1966–68 Sam Ash Fuzzz Boxx / Astro Tone Fuzz. Not affected by temperature like germanium circuits. Top-mounted I/O. Current draw: <1mA off, ~3mA on.',
    'Medium',
    'Power jack is an optional add-on; battery is default. Dimensions not found in sources.'
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
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', 3, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'product_page', 'https://www.analogman.com/astrotone.htm', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'pedal_details', 'effect_type', 'https://www.analogman.com/astrotone.htm', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'pedal_details', 'bypass_type', 'https://www.analogman.com/astrotone.htm', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'pedal_details', 'battery_capable', 'https://www.analogman.com/astrotone.htm', 'manufacturer_website', 'High', '2026-03-21');

INSERT INTO product_sources (product_id, table_name, field_name, jack_id, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'jacks', 'current_ma',
     (SELECT id FROM jacks WHERE product_id = currval('products_id_seq') AND category = 'power' AND direction = 'input'),
     'https://www.analogman.com/astrotone.htm', 'manufacturer_website', '~3mA on', 'High', '2026-03-21');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 6. SUN LION
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
    16, 1, 'Sun Lion',
    TRUE,
    120.7, 95.3, 54.0,
    NULL, NULL,
    'https://www.analogman.com/sunlion.htm',
    'Dual pedal combining Beano Boost (Dallas Rangemaster treble booster) and Sun Face Fuzz in one enclosure. Two independent 3PDT footswitches. Multiple germanium transistor options. Sundial knob option available. Current draw: ~8mA both circuits on.',
    'Medium',
    'Power jack is an optional add-on; battery is default. height_mm is approximate (1.5" base + switch height ~2.125" total).'
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
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', 8, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'product_page', 'https://www.analogman.com/sunlion.htm', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'width_mm', 'https://www.analogman.com/sunlion.htm', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'depth_mm', 'https://www.analogman.com/sunlion.htm', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'height_mm', 'https://www.analogman.com/sunlion.htm', 'manufacturer_website', 'Medium', '2026-03-21'),
    (currval('products_id_seq'), 'pedal_details', 'effect_type', 'https://www.analogman.com/sunlion.htm', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'pedal_details', 'bypass_type', 'https://www.analogman.com/sunlion.htm', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'pedal_details', 'battery_capable', 'https://www.analogman.com/sunlion.htm', 'manufacturer_website', 'High', '2026-03-21');

INSERT INTO product_sources (product_id, table_name, field_name, jack_id, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'jacks', 'current_ma',
     (SELECT id FROM jacks WHERE product_id = currval('products_id_seq') AND category = 'power' AND direction = 'input'),
     'https://www.analogman.com/sunlion.htm', 'manufacturer_website', '~8mA both circuits on', 'High', '2026-03-21');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 7. BEANO BOOST
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
    16, 1, 'Beano Boost',
    TRUE,
    63.5, 120.7, 38.1,
    NULL, NULL,
    'https://www.analogman.com/beano.htm',
    'Dallas Rangemaster treble booster clone using NOS germanium transistors. 3-way tone switch: treble boost, mid boost, full-range boost. Current draw: ~5mA on, <0.2mA off. Mini Beano and Silicon variants available.',
    'Medium',
    'Power jack is an optional add-on (Boss/Ibanez/Voodoo Lab compatible); battery is default.'
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
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', 5, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'product_page', 'https://www.analogman.com/beano.htm', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'width_mm', 'https://www.analogman.com/beano.htm', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'depth_mm', 'https://www.analogman.com/beano.htm', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'height_mm', 'https://www.analogman.com/beano.htm', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'pedal_details', 'effect_type', 'https://www.analogman.com/beano.htm', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'pedal_details', 'bypass_type', 'https://www.analogman.com/beano.htm', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'pedal_details', 'battery_capable', 'https://www.analogman.com/beano.htm', 'manufacturer_website', 'High', '2026-03-21');

INSERT INTO product_sources (product_id, table_name, field_name, jack_id, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'jacks', 'current_ma',
     (SELECT id FROM jacks WHERE product_id = currval('products_id_seq') AND category = 'power' AND direction = 'input'),
     'https://www.analogman.com/beano.htm', 'manufacturer_website', '~5mA on', 'High', '2026-03-21');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 8. BAD BOB BOOSTER (STANDARD)
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
    16, 1, 'Bad Bob Booster',
    TRUE,
    58.7, 109.5, NULL,
    NULL, NULL,
    'https://www.analogman.com/badbob.htm',
    'JFET mu-amp Class A boost (>20dB) in MXR-sized enclosure. No IC chips. Current draw: <1mA off, <3mA on. Can run up to 18V for more headroom. Optional Drive knob (added late 2018) for variable compression.',
    'Medium',
    'height_mm unknown — MXR/1590B enclosure (58.7 × 109.5mm) but height not found in sources.'
);

INSERT INTO pedal_details (
    product_id,
    effect_type, signal_type, bypass_type, mono_stereo,
    battery_capable
) VALUES (
    currval('products_id_seq'),
    'Gain', 'Analog', 'True Bypass', 'Mono',
    FALSE
);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', 3, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'product_page', 'https://www.analogman.com/badbob.htm', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'width_mm', 'https://www.analogman.com/badbob.htm', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'depth_mm', 'https://www.analogman.com/badbob.htm', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'pedal_details', 'effect_type', 'https://www.analogman.com/badbob.htm', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'pedal_details', 'bypass_type', 'https://www.analogman.com/badbob.htm', 'manufacturer_website', 'High', '2026-03-21');

INSERT INTO product_sources (product_id, table_name, field_name, jack_id, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'jacks', 'current_ma',
     (SELECT id FROM jacks WHERE product_id = currval('products_id_seq') AND category = 'power' AND direction = 'input'),
     'https://www.analogman.com/badbob.htm', 'manufacturer_website', '<3mA on', 'High', '2026-03-21');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 9. BAD BOB BOOSTER MINI
-- ============================================================
INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm,
    weight_grams, msrp_cents,
    product_page,
    description, data_reliability
) VALUES (
    16, 1, 'Bad Bob Booster Mini',
    TRUE,
    38.1, 88.9, 31.8,
    NULL, NULL,
    'https://www.analogman.com/badbob.htm',
    'Compact version of the Bad Bob Booster. Same JFET mu-amp Class A circuit in a smaller 1.5" × 3.5" enclosure.',
    'Medium'
);

INSERT INTO pedal_details (
    product_id,
    effect_type, signal_type, bypass_type, mono_stereo,
    battery_capable
) VALUES (
    currval('products_id_seq'),
    'Gain', 'Analog', 'True Bypass', 'Mono',
    FALSE
);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', 3, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'product_page', 'https://www.analogman.com/badbob.htm', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'width_mm', 'https://www.analogman.com/badbob.htm', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'depth_mm', 'https://www.analogman.com/badbob.htm', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'height_mm', 'https://www.analogman.com/badbob.htm', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'pedal_details', 'effect_type', 'https://www.analogman.com/badbob.htm', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'pedal_details', 'bypass_type', 'https://www.analogman.com/badbob.htm', 'manufacturer_website', 'High', '2026-03-21');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

COMMIT;
