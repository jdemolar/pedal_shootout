-- =============================================================================
-- Migration 031: Add Aroma / Tom's Line Engineering products (manufacturer ID 23)
-- =============================================================================
-- 11 products:
--   6 discontinued standard-format pedals (ABR-1, ABS-1, AMD-1, AOD-1, ACH-1, ADL-1)
--   5 current mini pedals (ALP-3S, AHOR-3, AMC-3, ACH-3, ARE-3)
-- All sourced from major retailers and community databases (Medium reliability)
-- No official manufacturer product pages found; Aroma operates primarily as a
-- distributor/rebrander of Tom's Line Engineering designs.
-- =============================================================================

BEGIN;

-- ─── 1. ABR-1 Booster ────────────────────────────────────────────────────────
-- Note: Source reported "115×73×48mm" AND "11.5×6.6×4.7cm" — inconsistent.
-- Using cm-converted values (115×66×47mm) as consistent with similar models.

INSERT INTO products (
    manufacturer_id, product_type_id, model,
    color_options, in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    msrp_cents, product_page, instruction_manual,
    description, tags, data_reliability, notes
) VALUES (
    23, 1, 'ABR-1',
    NULL, FALSE,
    115.0, 66.0, 47.0, 235,
    NULL, NULL, NULL,
    'Analog boost pedal with low and high tone controls and ultra-low noise op-amp circuit.',
    'boost,gain,analog,true-bypass,discontinued',
    'Medium', 'Dimensions sourced as 11.5×6.6×4.7cm; mm spec from same source was inconsistent — used cm conversion.'
);

INSERT INTO pedal_details (product_id, effect_type, signal_type, bypass_type, mono_stereo)
VALUES (currval('products_id_seq'), 'Gain', 'Analog', 'True Bypass', 'Mono');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, position)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS', 'Input', 'right');

INSERT INTO product_sources (product_id, jack_id, table_name, field_name, value_recorded, source_url, source_type, reliability)
VALUES (currval('products_id_seq'), currval('jacks_id_seq'), 'jacks', 'connector_type', '1/4" TS', 'https://www.tomtop.com/p-i438.html', 'major_retailer', 'Medium');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, position)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Output', 'left');

INSERT INTO product_sources (product_id, jack_id, table_name, field_name, value_recorded, source_url, source_type, reliability)
VALUES (currval('products_id_seq'), currval('jacks_id_seq'), 'jacks', 'connector_type', '1/4" TS', 'https://www.tomtop.com/p-i438.html', 'major_retailer', 'Medium');

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', 6, 'Center Negative');

INSERT INTO product_sources (product_id, jack_id, table_name, field_name, value_recorded, source_url, source_type, reliability)
VALUES (currval('products_id_seq'), currval('jacks_id_seq'), 'jacks', 'current_ma', '5.5mA', 'https://www.tomtop.com/p-i438.html', 'major_retailer', 'Medium');

INSERT INTO product_sources (product_id, jack_id, table_name, field_name, value_recorded, source_url, source_type, reliability)
VALUES
    (currval('products_id_seq'), NULL, 'products', 'width_mm', '11.5cm', 'https://www.tomtop.com/p-i438.html', 'major_retailer', 'Medium'),
    (currval('products_id_seq'), NULL, 'products', 'depth_mm', '6.6cm', 'https://www.tomtop.com/p-i438.html', 'major_retailer', 'Medium'),
    (currval('products_id_seq'), NULL, 'products', 'height_mm', '4.7cm', 'https://www.tomtop.com/p-i438.html', 'major_retailer', 'Medium'),
    (currval('products_id_seq'), NULL, 'products', 'weight_grams', '235g', 'https://www.tomtop.com/p-i438.html', 'major_retailer', 'Medium'),
    (currval('products_id_seq'), NULL, 'pedal_details', 'effect_type', 'Boost', 'https://www.tomtop.com/p-i438.html', 'major_retailer', 'Medium');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ─── 2. ABS-1 Blues Distortion ───────────────────────────────────────────────

INSERT INTO products (
    manufacturer_id, product_type_id, model,
    color_options, in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    msrp_cents, product_page, instruction_manual,
    description, tags, data_reliability, notes
) VALUES (
    23, 1, 'ABS-1',
    NULL, FALSE,
    115.0, 73.0, 48.0, 270,
    NULL, NULL, NULL,
    'Analog blues distortion with tube-simulation circuit and FET transistors for warm, responsive drive.',
    'blues,distortion,gain,analog,true-bypass,discontinued',
    'Medium', NULL
);

INSERT INTO pedal_details (product_id, effect_type, signal_type, bypass_type, mono_stereo)
VALUES (currval('products_id_seq'), 'Gain', 'Analog', 'True Bypass', 'Mono');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, position)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS', 'Input', 'right');

INSERT INTO product_sources (product_id, jack_id, table_name, field_name, value_recorded, source_url, source_type, reliability)
VALUES (currval('products_id_seq'), currval('jacks_id_seq'), 'jacks', 'connector_type', '1/4" TS', 'https://reverb.com/item/6540295-aroma-abs-1-blues-effects-pedal', 'review_site', 'Medium');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, position)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Output', 'left');

INSERT INTO product_sources (product_id, jack_id, table_name, field_name, value_recorded, source_url, source_type, reliability)
VALUES (currval('products_id_seq'), currval('jacks_id_seq'), 'jacks', 'connector_type', '1/4" TS', 'https://reverb.com/item/6540295-aroma-abs-1-blues-effects-pedal', 'review_site', 'Medium');

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', 6, 'Center Negative');

INSERT INTO product_sources (product_id, jack_id, table_name, field_name, value_recorded, source_url, source_type, reliability)
VALUES (currval('products_id_seq'), currval('jacks_id_seq'), 'jacks', 'current_ma', '6.2mA', 'https://reverb.com/item/6540295-aroma-abs-1-blues-effects-pedal', 'review_site', 'Medium');

INSERT INTO product_sources (product_id, jack_id, table_name, field_name, value_recorded, source_url, source_type, reliability)
VALUES
    (currval('products_id_seq'), NULL, 'products', 'width_mm', '115mm', 'https://reverb.com/item/6540295-aroma-abs-1-blues-effects-pedal', 'review_site', 'Medium'),
    (currval('products_id_seq'), NULL, 'products', 'depth_mm', '73mm', 'https://reverb.com/item/6540295-aroma-abs-1-blues-effects-pedal', 'review_site', 'Medium'),
    (currval('products_id_seq'), NULL, 'products', 'height_mm', '48mm', 'https://reverb.com/item/6540295-aroma-abs-1-blues-effects-pedal', 'review_site', 'Medium'),
    (currval('products_id_seq'), NULL, 'products', 'weight_grams', '270g', 'https://reverb.com/item/6540295-aroma-abs-1-blues-effects-pedal', 'review_site', 'Medium'),
    (currval('products_id_seq'), NULL, 'pedal_details', 'effect_type', 'Blues Distortion', 'https://reverb.com/item/6540295-aroma-abs-1-blues-effects-pedal', 'review_site', 'Medium');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ─── 3. AMD-1 Metal Distortion ───────────────────────────────────────────────

INSERT INTO products (
    manufacturer_id, product_type_id, model,
    color_options, in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    msrp_cents, product_page, instruction_manual,
    description, tags, data_reliability, notes
) VALUES (
    23, 1, 'AMD-1',
    NULL, FALSE,
    115.0, 65.0, 50.0, 238,
    NULL, NULL, NULL,
    'Analog metal distortion with tube-simulation circuit and FET transistors.',
    'metal,distortion,gain,analog,true-bypass,discontinued',
    'Medium', NULL
);

INSERT INTO pedal_details (product_id, effect_type, signal_type, bypass_type, mono_stereo)
VALUES (currval('products_id_seq'), 'Gain', 'Analog', 'True Bypass', 'Mono');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, position)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS', 'Input', 'right');

INSERT INTO product_sources (product_id, jack_id, table_name, field_name, value_recorded, source_url, source_type, reliability)
VALUES (currval('products_id_seq'), currval('jacks_id_seq'), 'jacks', 'connector_type', '1/4" TS', 'https://www.amazon.com/dp/B00SYG1CPO', 'major_retailer', 'Medium');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, position)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Output', 'left');

INSERT INTO product_sources (product_id, jack_id, table_name, field_name, value_recorded, source_url, source_type, reliability)
VALUES (currval('products_id_seq'), currval('jacks_id_seq'), 'jacks', 'connector_type', '1/4" TS', 'https://www.amazon.com/dp/B00SYG1CPO', 'major_retailer', 'Medium');

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', 6, 'Center Negative');

INSERT INTO product_sources (product_id, jack_id, table_name, field_name, value_recorded, source_url, source_type, reliability)
VALUES (currval('products_id_seq'), currval('jacks_id_seq'), 'jacks', 'current_ma', '5.5mA', 'https://www.amazon.com/dp/B00SYG1CPO', 'major_retailer', 'Medium');

INSERT INTO product_sources (product_id, jack_id, table_name, field_name, value_recorded, source_url, source_type, reliability)
VALUES
    (currval('products_id_seq'), NULL, 'products', 'width_mm', '11.5cm', 'https://www.amazon.com/dp/B00SYG1CPO', 'major_retailer', 'Medium'),
    (currval('products_id_seq'), NULL, 'products', 'depth_mm', '6.5cm', 'https://www.amazon.com/dp/B00SYG1CPO', 'major_retailer', 'Medium'),
    (currval('products_id_seq'), NULL, 'products', 'height_mm', '5cm', 'https://www.amazon.com/dp/B00SYG1CPO', 'major_retailer', 'Medium'),
    (currval('products_id_seq'), NULL, 'products', 'weight_grams', '238g', 'https://www.amazon.com/dp/B00SYG1CPO', 'major_retailer', 'Medium'),
    (currval('products_id_seq'), NULL, 'pedal_details', 'effect_type', 'Metal Distortion', 'https://www.amazon.com/dp/B00SYG1CPO', 'major_retailer', 'Medium');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ─── 4. AOD-1 Overdrive/Distortion ───────────────────────────────────────────
-- current_ma not specified in any source; left NULL

INSERT INTO products (
    manufacturer_id, product_type_id, model,
    color_options, in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    msrp_cents, product_page, instruction_manual,
    description, tags, data_reliability, notes
) VALUES (
    23, 1, 'AOD-1',
    NULL, FALSE,
    115.0, 70.0, 50.0, 270,
    NULL, NULL, NULL,
    'Analog overdrive and distortion with tube-simulation circuit and FET transistors.',
    'overdrive,distortion,gain,analog,true-bypass,discontinued',
    'Medium', NULL
);

INSERT INTO pedal_details (product_id, effect_type, signal_type, bypass_type, mono_stereo)
VALUES (currval('products_id_seq'), 'Gain', 'Analog', 'True Bypass', 'Mono');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, position)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS', 'Input', 'right');

INSERT INTO product_sources (product_id, jack_id, table_name, field_name, value_recorded, source_url, source_type, reliability)
VALUES (currval('products_id_seq'), currval('jacks_id_seq'), 'jacks', 'connector_type', '1/4" TS', 'https://reverb.com/item/6540005-aroma-aod-1-overdrive-distortion-effects-pedal', 'review_site', 'Medium');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, position)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Output', 'left');

INSERT INTO product_sources (product_id, jack_id, table_name, field_name, value_recorded, source_url, source_type, reliability)
VALUES (currval('products_id_seq'), currval('jacks_id_seq'), 'jacks', 'connector_type', '1/4" TS', 'https://reverb.com/item/6540005-aroma-aod-1-overdrive-distortion-effects-pedal', 'review_site', 'Medium');

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', NULL, 'Center Negative');

INSERT INTO product_sources (product_id, jack_id, table_name, field_name, value_recorded, source_url, source_type, reliability)
VALUES
    (currval('products_id_seq'), NULL, 'products', 'width_mm', '115mm', 'https://reverb.com/item/6540005-aroma-aod-1-overdrive-distortion-effects-pedal', 'review_site', 'Medium'),
    (currval('products_id_seq'), NULL, 'products', 'depth_mm', '70mm', 'https://reverb.com/item/6540005-aroma-aod-1-overdrive-distortion-effects-pedal', 'review_site', 'Medium'),
    (currval('products_id_seq'), NULL, 'products', 'height_mm', '50mm', 'https://reverb.com/item/6540005-aroma-aod-1-overdrive-distortion-effects-pedal', 'review_site', 'Medium'),
    (currval('products_id_seq'), NULL, 'products', 'weight_grams', '270g', 'https://reverb.com/item/6540005-aroma-aod-1-overdrive-distortion-effects-pedal', 'review_site', 'Medium'),
    (currval('products_id_seq'), NULL, 'pedal_details', 'effect_type', 'Overdrive/Distortion', 'https://reverb.com/item/6540005-aroma-aod-1-overdrive-distortion-effects-pedal', 'review_site', 'Medium');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ─── 5. ACH-1 Chorus ─────────────────────────────────────────────────────────

INSERT INTO products (
    manufacturer_id, product_type_id, model,
    color_options, in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    msrp_cents, product_page, instruction_manual,
    description, tags, data_reliability, notes
) VALUES (
    23, 1, 'ACH-1',
    NULL, FALSE,
    115.0, 66.0, 47.0, 237,
    NULL, NULL, NULL,
    'Analog chorus with depth, speed, and volume controls.',
    'chorus,analog,true-bypass,discontinued',
    'Medium', NULL
);

INSERT INTO pedal_details (product_id, effect_type, signal_type, bypass_type, mono_stereo)
VALUES (currval('products_id_seq'), 'Chorus', 'Analog', 'True Bypass', 'Mono');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, position)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS', 'Input', 'right');

INSERT INTO product_sources (product_id, jack_id, table_name, field_name, value_recorded, source_url, source_type, reliability)
VALUES (currval('products_id_seq'), currval('jacks_id_seq'), 'jacks', 'connector_type', '1/4" TS', 'https://www.ammoon.com/p-i437.html', 'major_retailer', 'Medium');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, position)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Output', 'left');

INSERT INTO product_sources (product_id, jack_id, table_name, field_name, value_recorded, source_url, source_type, reliability)
VALUES (currval('products_id_seq'), currval('jacks_id_seq'), 'jacks', 'connector_type', '1/4" TS', 'https://www.ammoon.com/p-i437.html', 'major_retailer', 'Medium');

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', 6, 'Center Negative');

INSERT INTO product_sources (product_id, jack_id, table_name, field_name, value_recorded, source_url, source_type, reliability)
VALUES (currval('products_id_seq'), currval('jacks_id_seq'), 'jacks', 'current_ma', '5.5mA', 'https://www.ammoon.com/p-i437.html', 'major_retailer', 'Medium');

INSERT INTO product_sources (product_id, jack_id, table_name, field_name, value_recorded, source_url, source_type, reliability)
VALUES
    (currval('products_id_seq'), NULL, 'products', 'width_mm', '11.5cm', 'https://www.ammoon.com/p-i437.html', 'major_retailer', 'Medium'),
    (currval('products_id_seq'), NULL, 'products', 'depth_mm', '6.6cm', 'https://www.ammoon.com/p-i437.html', 'major_retailer', 'Medium'),
    (currval('products_id_seq'), NULL, 'products', 'height_mm', '4.7cm', 'https://www.ammoon.com/p-i437.html', 'major_retailer', 'Medium'),
    (currval('products_id_seq'), NULL, 'products', 'weight_grams', '237g', 'https://www.ammoon.com/p-i437.html', 'major_retailer', 'Medium'),
    (currval('products_id_seq'), NULL, 'pedal_details', 'effect_type', 'Chorus', 'https://www.ammoon.com/p-i437.html', 'major_retailer', 'Medium');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ─── 6. ADL-1 Delay ──────────────────────────────────────────────────────────

INSERT INTO products (
    manufacturer_id, product_type_id, model,
    color_options, in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    msrp_cents, product_page, instruction_manual,
    description, tags, data_reliability, notes
) VALUES (
    23, 1, 'ADL-1',
    NULL, FALSE,
    115.0, 65.0, 50.0, 270,
    NULL, NULL, NULL,
    'Digital delay with 50–400ms range and time, feedback, and level controls.',
    'delay,digital,true-bypass,discontinued',
    'Medium', NULL
);

INSERT INTO pedal_details (product_id, effect_type, signal_type, bypass_type, mono_stereo)
VALUES (currval('products_id_seq'), 'Delay', 'Digital', 'True Bypass', 'Mono');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, position)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS', 'Input', 'right');

INSERT INTO product_sources (product_id, jack_id, table_name, field_name, value_recorded, source_url, source_type, reliability)
VALUES (currval('products_id_seq'), currval('jacks_id_seq'), 'jacks', 'connector_type', '1/4" TS', 'https://www.tomtop.com/p-i694.html', 'major_retailer', 'Medium');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, position)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Output', 'left');

INSERT INTO product_sources (product_id, jack_id, table_name, field_name, value_recorded, source_url, source_type, reliability)
VALUES (currval('products_id_seq'), currval('jacks_id_seq'), 'jacks', 'connector_type', '1/4" TS', 'https://www.tomtop.com/p-i694.html', 'major_retailer', 'Medium');

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', 23, 'Center Negative');

INSERT INTO product_sources (product_id, jack_id, table_name, field_name, value_recorded, source_url, source_type, reliability)
VALUES (currval('products_id_seq'), currval('jacks_id_seq'), 'jacks', 'current_ma', '23mA', 'https://www.tomtop.com/p-i694.html', 'major_retailer', 'Medium');

INSERT INTO product_sources (product_id, jack_id, table_name, field_name, value_recorded, source_url, source_type, reliability)
VALUES
    (currval('products_id_seq'), NULL, 'products', 'width_mm', '11.5cm', 'https://www.tomtop.com/p-i694.html', 'major_retailer', 'Medium'),
    (currval('products_id_seq'), NULL, 'products', 'depth_mm', '6.5cm', 'https://www.tomtop.com/p-i694.html', 'major_retailer', 'Medium'),
    (currval('products_id_seq'), NULL, 'products', 'height_mm', '5cm', 'https://www.tomtop.com/p-i694.html', 'major_retailer', 'Medium'),
    (currval('products_id_seq'), NULL, 'products', 'weight_grams', '270g', 'https://www.tomtop.com/p-i694.html', 'major_retailer', 'Medium'),
    (currval('products_id_seq'), NULL, 'pedal_details', 'effect_type', 'Delay', 'https://www.tomtop.com/p-i694.html', 'major_retailer', 'Medium');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ─── 7. ALP-3S Looper ────────────────────────────────────────────────────────
-- Current product. "Plus" revision of ALP-3 with USB interface and 3 tracks.
-- current_ma not specified in source (<20mA stated but no precise figure found).

INSERT INTO products (
    manufacturer_id, product_type_id, model,
    color_options, in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    msrp_cents, product_page, instruction_manual,
    description, tags, data_reliability, notes
) VALUES (
    23, 1, 'ALP-3S',
    NULL, TRUE,
    94.0, 42.0, 48.0, 135,
    NULL, NULL, NULL,
    'Three-track looper with 30 minutes per track, unlimited overdub, and USB Micro interface for track import/export.',
    'looper,digital,true-bypass,usb,mini',
    'Medium', NULL
);

INSERT INTO pedal_details (product_id, effect_type, signal_type, bypass_type, mono_stereo)
VALUES (currval('products_id_seq'), 'Looper', 'Digital', 'True Bypass', 'Mono');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, position)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS', 'Input', 'right');

INSERT INTO product_sources (product_id, jack_id, table_name, field_name, value_recorded, source_url, source_type, reliability)
VALUES (currval('products_id_seq'), currval('jacks_id_seq'), 'jacks', 'connector_type', '1/4" TS', 'https://reverb.com/item/78415562-aroma-alp-3s-loop-looper-plus-pedal-free-cable', 'review_site', 'Medium');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, position)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Output', 'left');

INSERT INTO product_sources (product_id, jack_id, table_name, field_name, value_recorded, source_url, source_type, reliability)
VALUES (currval('products_id_seq'), currval('jacks_id_seq'), 'jacks', 'connector_type', '1/4" TS', 'https://reverb.com/item/78415562-aroma-alp-3s-loop-looper-plus-pedal-free-cable', 'review_site', 'Medium');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, position)
VALUES (currval('products_id_seq'), 'usb', 'bidirectional', 'USB Micro', 'USB', 'top');

INSERT INTO product_sources (product_id, jack_id, table_name, field_name, value_recorded, source_url, source_type, reliability)
VALUES (currval('products_id_seq'), currval('jacks_id_seq'), 'jacks', 'connector_type', 'USB Micro', 'https://reverb.com/item/78415562-aroma-alp-3s-loop-looper-plus-pedal-free-cable', 'review_site', 'Medium');

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', NULL, 'Center Negative');

INSERT INTO product_sources (product_id, jack_id, table_name, field_name, value_recorded, source_url, source_type, reliability)
VALUES
    (currval('products_id_seq'), NULL, 'products', 'width_mm', '94mm', 'https://reverb.com/item/78415562-aroma-alp-3s-loop-looper-plus-pedal-free-cable', 'review_site', 'Medium'),
    (currval('products_id_seq'), NULL, 'products', 'depth_mm', '42mm', 'https://reverb.com/item/78415562-aroma-alp-3s-loop-looper-plus-pedal-free-cable', 'review_site', 'Medium'),
    (currval('products_id_seq'), NULL, 'products', 'height_mm', '48mm', 'https://reverb.com/item/78415562-aroma-alp-3s-loop-looper-plus-pedal-free-cable', 'review_site', 'Medium'),
    (currval('products_id_seq'), NULL, 'products', 'weight_grams', '135g', 'https://reverb.com/item/78415562-aroma-alp-3s-loop-looper-plus-pedal-free-cable', 'review_site', 'Medium'),
    (currval('products_id_seq'), NULL, 'pedal_details', 'effect_type', 'Looper', 'https://reverb.com/item/78415562-aroma-alp-3s-loop-looper-plus-pedal-free-cable', 'review_site', 'Medium');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ─── 8. AHOR-3 Holy War Metal Distortion ─────────────────────────────────────

INSERT INTO products (
    manufacturer_id, product_type_id, model,
    color_options, in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    msrp_cents, product_page, instruction_manual,
    description, tags, data_reliability, notes
) VALUES (
    23, 1, 'AHOR-3',
    NULL, TRUE,
    92.0, 38.0, 32.0, 133,
    NULL, NULL, NULL,
    'Analog metal distortion in mini format with two voicing modes (Extreme and Classic).',
    'metal,distortion,gain,analog,true-bypass,mini',
    'Medium', NULL
);

INSERT INTO pedal_details (product_id, effect_type, signal_type, bypass_type, mono_stereo)
VALUES (currval('products_id_seq'), 'Gain', 'Analog', 'True Bypass', 'Mono');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, position)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS', 'Input', 'right');

INSERT INTO product_sources (product_id, jack_id, table_name, field_name, value_recorded, source_url, source_type, reliability)
VALUES (currval('products_id_seq'), currval('jacks_id_seq'), 'jacks', 'connector_type', '1/4" TS', 'https://www.amazon.com/dp/B01447KF9A', 'major_retailer', 'Medium');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, position)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Output', 'left');

INSERT INTO product_sources (product_id, jack_id, table_name, field_name, value_recorded, source_url, source_type, reliability)
VALUES (currval('products_id_seq'), currval('jacks_id_seq'), 'jacks', 'connector_type', '1/4" TS', 'https://www.amazon.com/dp/B01447KF9A', 'major_retailer', 'Medium');

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', 20, 'Center Negative');

INSERT INTO product_sources (product_id, jack_id, table_name, field_name, value_recorded, source_url, source_type, reliability)
VALUES (currval('products_id_seq'), currval('jacks_id_seq'), 'jacks', 'current_ma', '20mA', 'https://www.amazon.com/dp/B01447KF9A', 'major_retailer', 'Medium');

INSERT INTO product_sources (product_id, jack_id, table_name, field_name, value_recorded, source_url, source_type, reliability)
VALUES
    (currval('products_id_seq'), NULL, 'products', 'width_mm', '92mm', 'https://www.amazon.com/dp/B01447KF9A', 'major_retailer', 'Medium'),
    (currval('products_id_seq'), NULL, 'products', 'depth_mm', '38mm', 'https://www.amazon.com/dp/B01447KF9A', 'major_retailer', 'Medium'),
    (currval('products_id_seq'), NULL, 'products', 'height_mm', '32mm', 'https://www.amazon.com/dp/B01447KF9A', 'major_retailer', 'Medium'),
    (currval('products_id_seq'), NULL, 'products', 'weight_grams', '133g', 'https://www.amazon.com/dp/B01447KF9A', 'major_retailer', 'Medium'),
    (currval('products_id_seq'), NULL, 'pedal_details', 'effect_type', 'Metal Distortion', 'https://www.amazon.com/dp/B01447KF9A', 'major_retailer', 'Medium');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ─── 9. AMC-3 Manic High Gain Distortion ─────────────────────────────────────
-- current_ma not specified in source; left NULL

INSERT INTO products (
    manufacturer_id, product_type_id, model,
    color_options, in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    msrp_cents, product_page, instruction_manual,
    description, tags, data_reliability, notes
) VALUES (
    23, 1, 'AMC-3',
    NULL, TRUE,
    92.0, 38.0, 32.0, 133,
    NULL, NULL, NULL,
    'Analog high-gain distortion in mini format with three voicing modes (Soft, Tense, Normal).',
    'distortion,gain,analog,true-bypass,mini',
    'Medium', NULL
);

INSERT INTO pedal_details (product_id, effect_type, signal_type, bypass_type, mono_stereo)
VALUES (currval('products_id_seq'), 'Gain', 'Analog', 'True Bypass', 'Mono');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, position)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS', 'Input', 'right');

INSERT INTO product_sources (product_id, jack_id, table_name, field_name, value_recorded, source_url, source_type, reliability)
VALUES (currval('products_id_seq'), currval('jacks_id_seq'), 'jacks', 'connector_type', '1/4" TS', 'https://www.amazon.com/dp/B01447KFCC', 'major_retailer', 'Medium');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, position)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Output', 'left');

INSERT INTO product_sources (product_id, jack_id, table_name, field_name, value_recorded, source_url, source_type, reliability)
VALUES (currval('products_id_seq'), currval('jacks_id_seq'), 'jacks', 'connector_type', '1/4" TS', 'https://www.amazon.com/dp/B01447KFCC', 'major_retailer', 'Medium');

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', NULL, 'Center Negative');

INSERT INTO product_sources (product_id, jack_id, table_name, field_name, value_recorded, source_url, source_type, reliability)
VALUES
    (currval('products_id_seq'), NULL, 'products', 'width_mm', '92mm', 'https://www.amazon.com/dp/B01447KFCC', 'major_retailer', 'Medium'),
    (currval('products_id_seq'), NULL, 'products', 'depth_mm', '38mm', 'https://www.amazon.com/dp/B01447KFCC', 'major_retailer', 'Medium'),
    (currval('products_id_seq'), NULL, 'products', 'height_mm', '32mm', 'https://www.amazon.com/dp/B01447KFCC', 'major_retailer', 'Medium'),
    (currval('products_id_seq'), NULL, 'products', 'weight_grams', '133g', 'https://www.amazon.com/dp/B01447KFCC', 'major_retailer', 'Medium'),
    (currval('products_id_seq'), NULL, 'pedal_details', 'effect_type', 'High Gain Distortion', 'https://www.amazon.com/dp/B01447KFCC', 'major_retailer', 'Medium');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ─── 10. ACH-3 Chorus ────────────────────────────────────────────────────────
-- current_ma: user decision to leave NULL (not found in sources)

INSERT INTO products (
    manufacturer_id, product_type_id, model,
    color_options, in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    msrp_cents, product_page, instruction_manual,
    description, tags, data_reliability, notes
) VALUES (
    23, 1, 'ACH-3',
    NULL, TRUE,
    92.0, 38.0, 32.0, 133,
    NULL, NULL, NULL,
    'Analog chorus in mini format with depth, speed, and volume controls.',
    'chorus,analog,true-bypass,mini',
    'Medium', NULL
);

INSERT INTO pedal_details (product_id, effect_type, signal_type, bypass_type, mono_stereo)
VALUES (currval('products_id_seq'), 'Chorus', 'Analog', 'True Bypass', 'Mono');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, position)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS', 'Input', 'right');

INSERT INTO product_sources (product_id, jack_id, table_name, field_name, value_recorded, source_url, source_type, reliability)
VALUES (currval('products_id_seq'), currval('jacks_id_seq'), 'jacks', 'connector_type', '1/4" TS', 'https://www.effectsdatabase.com/model/tomsline/mini/ach3', 'community_database', 'Medium');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, position)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Output', 'left');

INSERT INTO product_sources (product_id, jack_id, table_name, field_name, value_recorded, source_url, source_type, reliability)
VALUES (currval('products_id_seq'), currval('jacks_id_seq'), 'jacks', 'connector_type', '1/4" TS', 'https://www.effectsdatabase.com/model/tomsline/mini/ach3', 'community_database', 'Medium');

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', NULL, 'Center Negative');

INSERT INTO product_sources (product_id, jack_id, table_name, field_name, value_recorded, source_url, source_type, reliability)
VALUES
    (currval('products_id_seq'), NULL, 'products', 'width_mm', '92mm', 'https://www.effectsdatabase.com/model/tomsline/mini/ach3', 'community_database', 'Medium'),
    (currval('products_id_seq'), NULL, 'products', 'depth_mm', '38mm', 'https://www.effectsdatabase.com/model/tomsline/mini/ach3', 'community_database', 'Medium'),
    (currval('products_id_seq'), NULL, 'products', 'height_mm', '32mm', 'https://www.effectsdatabase.com/model/tomsline/mini/ach3', 'community_database', 'Medium'),
    (currval('products_id_seq'), NULL, 'products', 'weight_grams', '133g', 'https://www.effectsdatabase.com/model/tomsline/mini/ach3', 'community_database', 'Medium'),
    (currval('products_id_seq'), NULL, 'pedal_details', 'effect_type', 'Chorus', 'https://www.effectsdatabase.com/model/tomsline/mini/ach3', 'community_database', 'Medium');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ─── 11. ARE-3 Roto Engine Rotary Speaker Simulator ──────────────────────────
-- Dimensions per user decision: 90 × 38 × 48 mm (from pedalplayground.com)

INSERT INTO products (
    manufacturer_id, product_type_id, model,
    color_options, in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    msrp_cents, product_page, instruction_manual,
    description, tags, data_reliability, notes
) VALUES (
    23, 1, 'ARE-3',
    NULL, TRUE,
    90.0, 38.0, 48.0, 133,
    NULL, NULL, NULL,
    'Digital rotary speaker simulator in mini format with three modes: Phaser, Vibe, and Chorus.',
    'rotary,digital,true-bypass,mini',
    'Medium', NULL
);

INSERT INTO pedal_details (product_id, effect_type, signal_type, bypass_type, mono_stereo)
VALUES (currval('products_id_seq'), 'Rotary', 'Digital', 'True Bypass', 'Mono');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, position)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS', 'Input', 'right');

INSERT INTO product_sources (product_id, jack_id, table_name, field_name, value_recorded, source_url, source_type, reliability)
VALUES (currval('products_id_seq'), currval('jacks_id_seq'), 'jacks', 'connector_type', '1/4" TS', 'https://www.effectsdatabase.com/model/tomsline/mini/are3', 'community_database', 'Medium');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, position)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Output', 'left');

INSERT INTO product_sources (product_id, jack_id, table_name, field_name, value_recorded, source_url, source_type, reliability)
VALUES (currval('products_id_seq'), currval('jacks_id_seq'), 'jacks', 'connector_type', '1/4" TS', 'https://www.effectsdatabase.com/model/tomsline/mini/are3', 'community_database', 'Medium');

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', 17, 'Center Negative');

INSERT INTO product_sources (product_id, jack_id, table_name, field_name, value_recorded, source_url, source_type, reliability)
VALUES (currval('products_id_seq'), currval('jacks_id_seq'), 'jacks', 'current_ma', '17mA', 'https://www.effectsdatabase.com/model/tomsline/mini/are3', 'community_database', 'Medium');

INSERT INTO product_sources (product_id, jack_id, table_name, field_name, value_recorded, source_url, source_type, reliability)
VALUES
    (currval('products_id_seq'), NULL, 'products', 'width_mm', '90mm', 'https://www.effectsdatabase.com/model/tomsline/mini/are3', 'community_database', 'Medium'),
    (currval('products_id_seq'), NULL, 'products', 'depth_mm', '38mm', 'https://www.effectsdatabase.com/model/tomsline/mini/are3', 'community_database', 'Medium'),
    (currval('products_id_seq'), NULL, 'products', 'height_mm', '48mm', 'https://www.effectsdatabase.com/model/tomsline/mini/are3', 'community_database', 'Medium'),
    (currval('products_id_seq'), NULL, 'products', 'weight_grams', '133g', 'https://www.effectsdatabase.com/model/tomsline/mini/are3', 'community_database', 'Medium'),
    (currval('products_id_seq'), NULL, 'pedal_details', 'effect_type', 'Rotary', 'https://www.effectsdatabase.com/model/tomsline/mini/are3', 'community_database', 'Medium');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

COMMIT;
