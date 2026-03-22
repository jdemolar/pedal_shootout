-- Migration 018: Add Analog Man overdrive, compression, and filter pedals (Manufacturer ID 16)
-- 10 pedals: Prince of Tone, King of Tone, OG-1, Duke of Tone,
--            Juicer, CompROSSor Small, CompROSSor Large, Mini Bi-Comp,
--            Bi-Comprossor, Block Logo Envelope Filter

BEGIN;

-- ============================================================
-- 1. PRINCE OF TONE
-- ============================================================
INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm,
    weight_grams, msrp_cents,
    product_page,
    description, data_reliability
) VALUES (
    16, 1, 'Prince of Tone',
    TRUE,
    63.5, 114.3, 38.1,
    NULL, NULL,
    'https://www.buyanalogman.com/Analog_Man_Prince_of_Tone_overdrive_pedal_p/ampot.htm',
    'Single-channel version of the King of Tone. 3-position mode switch: OD, Clean, Distortion. Internal DIP switches for Lo-Mid Lift and Turbo modes. Internal treble trim pot. 9V–18V compatible.',
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
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', 6, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'product_page', 'https://www.buyanalogman.com/Analog_Man_Prince_of_Tone_overdrive_pedal_p/ampot.htm', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'width_mm', 'https://www.buyanalogman.com/Analog_Man_Prince_of_Tone_overdrive_pedal_p/ampot.htm', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'depth_mm', 'https://www.buyanalogman.com/Analog_Man_Prince_of_Tone_overdrive_pedal_p/ampot.htm', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'height_mm', 'https://www.buyanalogman.com/Analog_Man_Prince_of_Tone_overdrive_pedal_p/ampot.htm', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'pedal_details', 'effect_type', 'https://www.buyanalogman.com/Analog_Man_Prince_of_Tone_overdrive_pedal_p/ampot.htm', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'pedal_details', 'bypass_type', 'https://www.buyanalogman.com/Analog_Man_Prince_of_Tone_overdrive_pedal_p/ampot.htm', 'manufacturer_website', 'High', '2026-03-21');

INSERT INTO product_sources (product_id, table_name, field_name, jack_id, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'jacks', 'current_ma',
     (SELECT id FROM jacks WHERE product_id = currval('products_id_seq') AND category = 'power' AND direction = 'input'),
     'https://www.buyanalogman.com/Analog_Man_Prince_of_Tone_overdrive_pedal_p/ampot.htm', 'manufacturer_website', '~6mA at 9V', 'High', '2026-03-21');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 2. KING OF TONE
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
    16, 1, 'King of Tone',
    TRUE,
    120.7, 95.3, 50.8,
    NULL, NULL,
    'https://www.analogman.com/kingtone.htm',
    'Dual-channel overdrive. Each channel independently footswitchable. Internal DIP switches for mode selection per channel. 9V–18V compatible. Currently produced with a waiting list.',
    'Medium',
    'MSRP not confirmed from any reliable source — prices vary and are not publicly posted. height_mm approximate (reported ~2" with knobs). Weight ~500g estimated from one source; omitted pending verification.'
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
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', NULL, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'product_page', 'https://www.analogman.com/kingtone.htm', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'width_mm', 'https://www.guitarchalk.com/analog-man-king-of-tone-dimensions/', 'review_site', 'Medium', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'depth_mm', 'https://www.guitarchalk.com/analog-man-king-of-tone-dimensions/', 'review_site', 'Medium', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'height_mm', 'https://www.guitarchalk.com/analog-man-king-of-tone-dimensions/', 'review_site', 'Medium', '2026-03-21'),
    (currval('products_id_seq'), 'pedal_details', 'effect_type', 'https://www.analogman.com/kingtone.htm', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'pedal_details', 'bypass_type', 'https://www.analogman.com/kingtone.htm', 'manufacturer_website', 'High', '2026-03-21');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 3. OG-1
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
    16, 1, 'OG-1',
    TRUE,
    NULL, NULL, NULL,
    NULL, NULL,
    'https://www.buyanalogman.com/Analog_Man_Colby_Amps_OG_1_Overdrive_pedal_p/am-colby-og-1.htm',
    'Tribute to the 1977 Boss OD-1 (first Boss Compact pedal). Built with NOS 40-year-old RC3403ADB chips and 1S2473 diodes. Original Boss DRIVE pots. Asymmetrical clipping. Collaboration with Colby Amps.',
    'Low',
    'Minimal technical specs available in public sources. Power requirements and dimensions not found.'
);

INSERT INTO pedal_details (
    product_id,
    effect_type, signal_type, bypass_type, mono_stereo
) VALUES (
    currval('products_id_seq'),
    'Gain', 'Analog', 'True Bypass', 'Mono'
);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', NULL, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'product_page', 'https://www.buyanalogman.com/Analog_Man_Colby_Amps_OG_1_Overdrive_pedal_p/am-colby-og-1.htm', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'pedal_details', 'effect_type', 'https://www.buyanalogman.com/Analog_Man_Colby_Amps_OG_1_Overdrive_pedal_p/am-colby-og-1.htm', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'pedal_details', 'bypass_type', 'https://www.buyanalogman.com/Analog_Man_Colby_Amps_OG_1_Overdrive_pedal_p/am-colby-og-1.htm', 'manufacturer_website', 'High', '2026-03-21');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 4. DUKE OF TONE
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
    16, 1, 'Duke of Tone',
    TRUE,
    NULL, NULL, NULL,
    NULL, NULL,
    'https://www.buyanalogman.com/Analog_Man_x_MXR_Duke_of_Tone_overdrive_pedal_p/amdot.htm',
    'Collaboration between Analog Man and MXR/Dunlop. Single-channel overdrive with 3-mode switch (OD, Boost, Distortion). 4580D op-amp circuit, same as King of Tone. Internal treble trimpot. 9V DC, 6mA.',
    'Medium',
    'Dimensions not found in sources. Manufactured and distributed by MXR/Dunlop in collaboration with Analog Man.'
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
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', 6, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'product_page', 'https://www.buyanalogman.com/Analog_Man_x_MXR_Duke_of_Tone_overdrive_pedal_p/amdot.htm', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'pedal_details', 'effect_type', 'https://www.jimdunlop.com/mxr-duke-of-tone-overdrive/', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'pedal_details', 'bypass_type', 'https://www.jimdunlop.com/mxr-duke-of-tone-overdrive/', 'manufacturer_website', 'High', '2026-03-21');

INSERT INTO product_sources (product_id, table_name, field_name, jack_id, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'jacks', 'current_ma',
     (SELECT id FROM jacks WHERE product_id = currval('products_id_seq') AND category = 'power' AND direction = 'input'),
     'https://www.jimdunlop.com/mxr-duke-of-tone-overdrive/', 'manufacturer_website', '6mA', 'High', '2026-03-21');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 5. JUICER COMPRESSOR
-- ============================================================
INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm,
    weight_grams, msrp_cents,
    product_page,
    description, data_reliability
) VALUES (
    16, 1, 'Juicer',
    TRUE,
    63.5, 120.7, 38.1,
    NULL, NULL,
    'https://www.analogman.com/os.htm',
    'Dan Armstrong Orange Squeezer clone. NOS 2N5457 transistors, germanium diode, JRC4558 chip. Attack and mix controls. Compresses note attack while bringing up the decay without excess sustain.',
    'Medium'
);

INSERT INTO pedal_details (
    product_id,
    effect_type, signal_type, bypass_type, mono_stereo,
    battery_capable
) VALUES (
    currval('products_id_seq'),
    'Compression', 'Analog', 'True Bypass', 'Mono',
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
    (currval('products_id_seq'), 'products', 'product_page', 'https://www.analogman.com/os.htm', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'width_mm', 'https://www.buyanalogman.com/Analog_Man_Juicer_Compressor_p/am-juicer.htm', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'depth_mm', 'https://www.buyanalogman.com/Analog_Man_Juicer_Compressor_p/am-juicer.htm', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'height_mm', 'https://www.buyanalogman.com/Analog_Man_Juicer_Compressor_p/am-juicer.htm', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'pedal_details', 'effect_type', 'https://www.analogman.com/os.htm', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'pedal_details', 'bypass_type', 'https://www.analogman.com/os.htm', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'pedal_details', 'battery_capable', 'https://www.buyanalogman.com/Analog_Man_Juicer_Compressor_p/am-juicer.htm', 'manufacturer_website', 'High', '2026-03-21');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 6. COMPROSSOR (SMALL)
-- ============================================================
INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm,
    weight_grams, msrp_cents,
    product_page,
    description, data_reliability
) VALUES (
    16, 1, 'CompROSSor Small',
    TRUE,
    63.5, 120.7, 38.1,
    NULL, NULL,
    'https://www.analogman.com/rossmod.htm',
    'Ross/MXR Dynacomp clone in small enclosure. Current draw: 4mA off, 7mA on. 9V–15V DC. Input impedance 500K ohms. Compression ratio adjustable 15–40dB. Attack time 4ms. Decay time 1.2 seconds.',
    'Medium'
);

INSERT INTO pedal_details (
    product_id,
    effect_type, signal_type, bypass_type, mono_stereo,
    battery_capable
) VALUES (
    currval('products_id_seq'),
    'Compression', 'Analog', 'True Bypass', 'Mono',
    TRUE
);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', 7, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'product_page', 'https://www.analogman.com/rossmod.htm', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'width_mm', 'https://www.buyanalogman.com/Analog_Man_CompROSSor_p/am-comp.htm', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'depth_mm', 'https://www.buyanalogman.com/Analog_Man_CompROSSor_p/am-comp.htm', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'height_mm', 'https://www.buyanalogman.com/Analog_Man_CompROSSor_p/am-comp.htm', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'pedal_details', 'effect_type', 'https://www.analogman.com/rossmod.htm', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'pedal_details', 'bypass_type', 'https://www.analogman.com/rossmod.htm', 'manufacturer_website', 'High', '2026-03-21');

INSERT INTO product_sources (product_id, table_name, field_name, jack_id, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'jacks', 'current_ma',
     (SELECT id FROM jacks WHERE product_id = currval('products_id_seq') AND category = 'power' AND direction = 'input'),
     'https://www.analogman.com/comprev.htm', 'manufacturer_website', '4mA off / 7mA on', 'High', '2026-03-21');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 7. COMPROSSOR (LARGE)
-- ============================================================
INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm,
    weight_grams, msrp_cents,
    product_page,
    description, data_reliability
) VALUES (
    16, 1, 'CompROSSor Large',
    TRUE,
    94.0, 119.4, 33.0,
    NULL, NULL,
    'https://www.analogman.com/rossmod.htm',
    'Ross/MXR Dynacomp clone in large enclosure. Same circuit as CompROSSor Small. Current draw: 4mA off, 7mA on. 9V–15V DC. More panel space for controls.',
    'Medium'
);

INSERT INTO pedal_details (
    product_id,
    effect_type, signal_type, bypass_type, mono_stereo,
    battery_capable
) VALUES (
    currval('products_id_seq'),
    'Compression', 'Analog', 'True Bypass', 'Mono',
    TRUE
);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', 7, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'product_page', 'https://www.analogman.com/rossmod.htm', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'width_mm', 'https://www.buyanalogman.com/Analog_Man_Large_Comprossor_p/am-large-comprossor.htm', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'depth_mm', 'https://www.buyanalogman.com/Analog_Man_Large_Comprossor_p/am-large-comprossor.htm', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'height_mm', 'https://www.buyanalogman.com/Analog_Man_Large_Comprossor_p/am-large-comprossor.htm', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'pedal_details', 'effect_type', 'https://www.analogman.com/rossmod.htm', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'pedal_details', 'bypass_type', 'https://www.analogman.com/rossmod.htm', 'manufacturer_website', 'High', '2026-03-21');

INSERT INTO product_sources (product_id, table_name, field_name, jack_id, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'jacks', 'current_ma',
     (SELECT id FROM jacks WHERE product_id = currval('products_id_seq') AND category = 'power' AND direction = 'input'),
     'https://www.analogman.com/comprev.htm', 'manufacturer_website', '4mA off / 7mA on', 'High', '2026-03-21');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 8. MINI BI-COMP
-- ============================================================
INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm,
    weight_grams, msrp_cents,
    product_page,
    description, data_reliability
) VALUES (
    16, 1, 'Mini Bi-Comp',
    TRUE,
    NULL, NULL, NULL,
    NULL, NULL,
    'https://www.buyanalogman.com/Analog_Man_Mini_Bi_Comp_p/am-mini-bi-comp.htm',
    'Compact dual-compressor combining CompROSSor (Ross-based) and Juicer (Orange Squeezer clone). Independent Volume controls per channel. Combined Sustain knob. Current draw: <10mA both on, <4mA both off. Battery life >40 hours.',
    'Medium'
);

INSERT INTO pedal_details (
    product_id,
    effect_type, signal_type, bypass_type, mono_stereo,
    battery_capable
) VALUES (
    currval('products_id_seq'),
    'Compression', 'Analog', 'True Bypass', 'Mono',
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
    (currval('products_id_seq'), 'products', 'product_page', 'https://www.buyanalogman.com/Analog_Man_Mini_Bi_Comp_p/am-mini-bi-comp.htm', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'pedal_details', 'effect_type', 'https://www.buyanalogman.com/Analog_Man_Mini_Bi_Comp_p/am-mini-bi-comp.htm', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'pedal_details', 'bypass_type', 'https://www.buyanalogman.com/Analog_Man_Mini_Bi_Comp_p/am-mini-bi-comp.htm', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'pedal_details', 'battery_capable', 'https://www.buyanalogman.com/Analog_Man_Mini_Bi_Comp_p/am-mini-bi-comp.htm', 'manufacturer_website', 'High', '2026-03-21');

INSERT INTO product_sources (product_id, table_name, field_name, jack_id, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'jacks', 'current_ma',
     (SELECT id FROM jacks WHERE product_id = currval('products_id_seq') AND category = 'power' AND direction = 'input'),
     'https://www.buyanalogman.com/Analog_Man_Mini_Bi_Comp_p/am-mini-bi-comp.htm', 'manufacturer_website', '<10mA both circuits on', 'High', '2026-03-21');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 9. BI-COMPROSSOR
-- ============================================================
INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm,
    weight_grams, msrp_cents,
    product_page,
    description, data_reliability
) VALUES (
    16, 1, 'Bi-Comprossor',
    TRUE,
    NULL, NULL, NULL,
    NULL, NULL,
    'https://www.buyanalogman.com/Analog_Man_Bi_Comprossor_p/am-bicomp.htm',
    'Full-size dual-compressor combining CompROSSor (Ross-based) and Juicer (Orange Squeezer clone) in a larger enclosure than the Mini Bi-Comp. Two independent sets of controls. Current draw: <10mA both on.',
    'Medium'
);

INSERT INTO pedal_details (
    product_id,
    effect_type, signal_type, bypass_type, mono_stereo,
    battery_capable
) VALUES (
    currval('products_id_seq'),
    'Compression', 'Analog', 'True Bypass', 'Mono',
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
    (currval('products_id_seq'), 'products', 'product_page', 'https://www.buyanalogman.com/Analog_Man_Bi_Comprossor_p/am-bicomp.htm', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'pedal_details', 'effect_type', 'https://www.analogman.com/rossmod.htm', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'pedal_details', 'bypass_type', 'https://www.analogman.com/rossmod.htm', 'manufacturer_website', 'High', '2026-03-21');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 10. BLOCK LOGO ENVELOPE FILTER
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
    16, 1, 'Block Logo Envelope Filter',
    TRUE,
    58.7, 109.5, NULL,
    NULL, NULL,
    'https://www.buyanalogman.com/Analog_Man_Block_Logo_Envelope_Filter_Pedal_p/am-blockenvelope.htm',
    'Based on the 1970s MXR envelope filter circuit, built on NOS original MXR boards. Added Emphasis knob and Up/Down switch (Mu-Tron-style sweep direction). Controls: Emph, Thresh, Attack.',
    'Medium',
    'height_mm unknown — MXR/1590B enclosure (58.7 × 109.5mm) but height not found in sources.'
);

INSERT INTO pedal_details (
    product_id,
    effect_type, signal_type, bypass_type, mono_stereo
) VALUES (
    currval('products_id_seq'),
    'Filter', 'Analog', 'True Bypass', 'Mono'
);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', NULL, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'product_page', 'https://www.buyanalogman.com/Analog_Man_Block_Logo_Envelope_Filter_Pedal_p/am-blockenvelope.htm', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'width_mm', 'https://www.buyanalogman.com/Analog_Man_Block_Logo_Envelope_Filter_Pedal_p/am-blockenvelope.htm', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'depth_mm', 'https://www.buyanalogman.com/Analog_Man_Block_Logo_Envelope_Filter_Pedal_p/am-blockenvelope.htm', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'pedal_details', 'effect_type', 'https://www.buyanalogman.com/Analog_Man_Block_Logo_Envelope_Filter_Pedal_p/am-blockenvelope.htm', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'pedal_details', 'bypass_type', 'https://www.buyanalogman.com/Analog_Man_Block_Logo_Envelope_Filter_Pedal_p/am-blockenvelope.htm', 'manufacturer_website', 'High', '2026-03-21');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

COMMIT;
