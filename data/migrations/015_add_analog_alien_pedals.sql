-- Migration 015: Add Analog Alien pedals/utilities (Manufacturer ID 15)
-- 9 pedals + 2 utilities (EPi, Alien Switcher) — 11 products total
-- Handcrafted all-analog pedals made in Long Island, New York
--
-- Data decisions:
-- - Alien Tone Dragon effect_type: 'Gain' (user decision — boost + OD/fuzz + EQ circuit)
-- - JWDC effect_type: 'Multi Effects' (user decision — compressor + amp sim)
-- - EPi: product_type_id=5 utility, utility_type='Signal Router' (user decision)
-- - Alien Switcher: product_type_id=5 utility, utility_type='A/B Box' (user decision)
-- - Alien Switcher in_production: NULL (production status unknown)
-- - MSRP NULL for: Alien Tone Dragon (EUR only), Alien Twister, FuzzBubble-45, Rumble Seat (only estimate found), Alien Switcher
-- - Double Classic Comp model name: current name used; former name noted in products.notes
-- - battery_capable=FALSE for any pedal where not explicitly confirmed (Power Pack)
-- - Alien Twister current_ma=36 (max draw 35.6mA from manual, all circuits engaged)
-- - EPi power voltage: NULL (not specified in sources)

BEGIN;

-- ============================================================
-- 1. ALIEN TONE DRAGON (ATD)
-- ============================================================
INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm,
    weight_grams, msrp_cents,
    product_page,
    description, data_reliability
) VALUES (
    15, 1, 'Alien Tone Dragon',
    TRUE,
    146.1, 120.7, 38.1,
    NULL, NULL,
    'https://analogalien.com/product/alien-tone-dragon-atd-pedal/',
    'All-analog multi-circuit pedal combining Clean Boost, Overdrive/Fuzz, and Active 3-Band Tone Circuit. Each section is independently bypassable. 9V DC, 25mA.',
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
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', 25, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'product_page', 'https://analogalien.com/product/alien-tone-dragon-atd-pedal/', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'width_mm', 'https://analogalien.com/product/alien-tone-dragon-atd-pedal/', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'depth_mm', 'https://analogalien.com/product/alien-tone-dragon-atd-pedal/', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'height_mm', 'https://analogalien.com/product/alien-tone-dragon-atd-pedal/', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'pedal_details', 'effect_type', 'https://analogalien.com/product/alien-tone-dragon-atd-pedal/', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'pedal_details', 'bypass_type', 'https://analogalien.com/product/alien-tone-dragon-atd-pedal/', 'manufacturer_website', 'High', '2026-03-21');

INSERT INTO product_sources (product_id, table_name, field_name, jack_id, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'jacks', 'current_ma',
     (SELECT id FROM jacks WHERE product_id = currval('products_id_seq') AND category = 'power' AND direction = 'input'),
     'https://analogalien.com/product/alien-tone-dragon-atd-pedal/', 'manufacturer_website', '25mA', 'High', '2026-03-21');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 2. ALIEN TWISTER
-- ============================================================
INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm,
    weight_grams, msrp_cents,
    product_page, instruction_manual,
    description, data_reliability
) VALUES (
    15, 1, 'Alien Twister',
    TRUE,
    NULL, NULL, NULL,
    NULL, NULL,
    'https://analogalien.com/product/alien-twister-fuzz-buffer-pedal/',
    'https://analogalien.com/wp-content/uploads/2019/05/MANUAL_TWISTER.pdf',
    'All-analog Fuzz/Distortion/Overdrive with integrated switchable buffer. Variable current draw depending on engaged circuits (8.9–35.6mA). Requires external power supply.',
    'Medium'
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
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', 36, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'product_page', 'https://analogalien.com/product/alien-twister-fuzz-buffer-pedal/', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'instruction_manual', 'https://analogalien.com/wp-content/uploads/2019/05/MANUAL_TWISTER.pdf', 'manufacturer_manual', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'pedal_details', 'effect_type', 'https://analogalien.com/product/alien-twister-fuzz-buffer-pedal/', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'pedal_details', 'bypass_type', 'https://analogalien.com/product/alien-twister-fuzz-buffer-pedal/', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'pedal_details', 'battery_capable', 'https://analogalien.com/wp-content/uploads/2019/05/MANUAL_TWISTER.pdf', 'manufacturer_manual', 'High', '2026-03-21');

INSERT INTO product_sources (product_id, table_name, field_name, jack_id, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'jacks', 'current_ma',
     (SELECT id FROM jacks WHERE product_id = currval('products_id_seq') AND category = 'power' AND direction = 'input'),
     'https://analogalien.com/wp-content/uploads/2019/05/MANUAL_TWISTER.pdf', 'manufacturer_manual', '35.6mA max (all circuits on)', 'High', '2026-03-21');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 3. FUZZBUBBLE-45
-- ============================================================
INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm,
    weight_grams, msrp_cents,
    product_page,
    description, data_reliability
) VALUES (
    15, 1, 'FuzzBubble-45',
    TRUE,
    NULL, NULL, NULL,
    NULL, NULL,
    'https://analogalien.com/product/fuzzbubble-45-overdrive-fuzz-pedal/',
    'Vintage-inspired dual Overdrive/Fuzz with separate circuits for each effect. All-analog, true bypass. 9V battery included. Input level control.',
    'Medium'
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
    (currval('products_id_seq'), 'products', 'product_page', 'https://analogalien.com/product/fuzzbubble-45-overdrive-fuzz-pedal/', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'pedal_details', 'effect_type', 'https://analogalien.com/product/fuzzbubble-45-overdrive-fuzz-pedal/', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'pedal_details', 'bypass_type', 'https://analogalien.com/product/fuzzbubble-45-overdrive-fuzz-pedal/', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'pedal_details', 'battery_capable', 'https://analogalien.com/product/fuzzbubble-45-overdrive-fuzz-pedal/', 'manufacturer_website', 'High', '2026-03-21');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 4. RUMBLE SEAT
-- ============================================================
INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm,
    weight_grams, msrp_cents,
    product_page, instruction_manual,
    description, data_reliability
) VALUES (
    15, 1, 'Rumble Seat',
    TRUE,
    NULL, NULL, NULL,
    NULL, NULL,
    'https://analogalien.com/product/rumble-seat-overdrive-delay-reverb-pedal/',
    'https://www.analogalien.com/wp-content/uploads/2019/05/MANUAL_RUMBLE_SEAT.pdf',
    'All-analog multi-effects pedal combining Overdrive, Delay (25–650ms), and Reverb. Each section independently bypassable. Includes 1 Spot power supply.',
    'Medium'
);

INSERT INTO pedal_details (
    product_id,
    effect_type, signal_type, bypass_type, mono_stereo,
    battery_capable
) VALUES (
    currval('products_id_seq'),
    'Multi Effects', 'Analog', 'True Bypass', 'Mono',
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
    (currval('products_id_seq'), 'products', 'product_page', 'https://analogalien.com/product/rumble-seat-overdrive-delay-reverb-pedal/', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'instruction_manual', 'https://www.analogalien.com/wp-content/uploads/2019/05/MANUAL_RUMBLE_SEAT.pdf', 'manufacturer_manual', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'pedal_details', 'effect_type', 'https://analogalien.com/product/rumble-seat-overdrive-delay-reverb-pedal/', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'pedal_details', 'bypass_type', 'https://analogalien.com/product/rumble-seat-overdrive-delay-reverb-pedal/', 'manufacturer_website', 'High', '2026-03-21');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 5. ALIEN BASS STATION (ABS)
-- ============================================================
INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm,
    weight_grams, msrp_cents,
    product_page, instruction_manual,
    description, data_reliability
) VALUES (
    15, 1, 'Alien Bass Station',
    TRUE,
    146.1, 120.7, 38.1,
    NULL, 39900,
    'https://analogalien.com/product/alien-bass-station-compressor-amp-simulator-gamma-fuzz-bass-pedal/',
    'https://analogalien.com/wp-content/uploads/2019/05/MANUAL_ALIEN_BASS_STATION.pdf',
    'Bass-specific multi-effects combining Limiter/Compressor, Amp Generator (Ampeg B-15 inspired), and Gamma Fuzz. All-analog. Each section independently bypassable.',
    'Medium'
);

INSERT INTO pedal_details (
    product_id,
    effect_type, signal_type, bypass_type, mono_stereo,
    battery_capable
) VALUES (
    currval('products_id_seq'),
    'Multi Effects', 'Analog', 'True Bypass', 'Mono',
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
    (currval('products_id_seq'), 'products', 'product_page', 'https://analogalien.com/product/alien-bass-station-compressor-amp-simulator-gamma-fuzz-bass-pedal/', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'instruction_manual', 'https://analogalien.com/wp-content/uploads/2019/05/MANUAL_ALIEN_BASS_STATION.pdf', 'manufacturer_manual', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'width_mm', 'https://analogalien.com/product/alien-bass-station-compressor-amp-simulator-gamma-fuzz-bass-pedal/', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'depth_mm', 'https://analogalien.com/product/alien-bass-station-compressor-amp-simulator-gamma-fuzz-bass-pedal/', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'height_mm', 'https://analogalien.com/product/alien-bass-station-compressor-amp-simulator-gamma-fuzz-bass-pedal/', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'msrp_cents', 'https://www.sweetwater.com/store/detail/ABStation--analog-alien-alien-bass-station-abs-compressor-amp-generator-fuzz-bass-pedal', 'major_retailer', 'Medium', '2026-03-21'),
    (currval('products_id_seq'), 'pedal_details', 'effect_type', 'https://analogalien.com/product/alien-bass-station-compressor-amp-simulator-gamma-fuzz-bass-pedal/', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'pedal_details', 'bypass_type', 'https://analogalien.com/product/alien-bass-station-compressor-amp-simulator-gamma-fuzz-bass-pedal/', 'manufacturer_website', 'High', '2026-03-21');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 6. BUCKET SEAT
-- ============================================================
INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm,
    weight_grams, msrp_cents,
    product_page, instruction_manual,
    description, data_reliability
) VALUES (
    15, 1, 'Bucket Seat',
    TRUE,
    NULL, NULL, NULL,
    NULL, 19900,
    'https://analogalien.com/product/bucket-seat-overdrive-pedal/',
    'https://analogalien.com/wp-content/uploads/2019/05/MANUAL_BUCKET_SEAT.pdf',
    'British amp-style overdrive inspired by a 1969 Marshall Plexi. All-analog. Same circuit as the overdrive section in the Rumble Seat. Runs on battery or external supply.',
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
    (currval('products_id_seq'), 'products', 'product_page', 'https://analogalien.com/product/bucket-seat-overdrive-pedal/', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'instruction_manual', 'https://analogalien.com/wp-content/uploads/2019/05/MANUAL_BUCKET_SEAT.pdf', 'manufacturer_manual', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'msrp_cents', 'https://www.sweetwater.com/store/detail/BucketSeat--analog-alien-bucket-seat-overdrive-pedal', 'major_retailer', 'Medium', '2026-03-21'),
    (currval('products_id_seq'), 'pedal_details', 'effect_type', 'https://analogalien.com/product/bucket-seat-overdrive-pedal/', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'pedal_details', 'bypass_type', 'https://analogalien.com/product/bucket-seat-overdrive-pedal/', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'pedal_details', 'battery_capable', 'https://analogalien.com/product/bucket-seat-overdrive-pedal/', 'manufacturer_website', 'High', '2026-03-21');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 7. DOUBLE CLASSIC COMP (DCC)
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
    15, 1, 'Double Classic Comp',
    TRUE,
    NULL, NULL, NULL,
    800, 19900,
    'https://analogalien.com/product/alien-comp-compressor-pedal/',
    'All-analog compressor extracted from the Joe Walsh Double Classic circuit. Adjustable ratio 2:1 to 10:1. Can also function as a clean boost. Runs on battery or external supply.',
    'Medium',
    'Previously sold as "Alien Comp". Rebranded to Double Classic Comp (DCC) after the Joe Walsh Double Classic was released.'
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
    (currval('products_id_seq'), 'products', 'product_page', 'https://analogalien.com/product/alien-comp-compressor-pedal/', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'weight_grams', 'https://www.tonepedia.com/catalog/effects-and-pedals/compression-and-sustain/alien-comp/', 'review_site', 'Medium', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'msrp_cents', 'https://www.sweetwater.com/store/detail/AlienComp--analog-alien-alien-comp-compressor-pedal', 'major_retailer', 'Medium', '2026-03-21'),
    (currval('products_id_seq'), 'pedal_details', 'effect_type', 'https://analogalien.com/product/alien-comp-compressor-pedal/', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'pedal_details', 'bypass_type', 'https://analogalien.com/product/alien-comp-compressor-pedal/', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'pedal_details', 'battery_capable', 'https://analogalien.com/product/alien-comp-compressor-pedal/', 'manufacturer_website', 'High', '2026-03-21');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 8. JOE WALSH DOUBLE CLASSIC (JWDC)
-- ============================================================
INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm,
    weight_grams, msrp_cents,
    product_page,
    description, data_reliability
) VALUES (
    15, 1, 'Joe Walsh Double Classic',
    TRUE,
    146.0, 120.7, 38.1,
    800, 29900,
    'https://analogalien.com/product/joe-walsh-double-classic-compressor-overdrive-pedal/',
    'Joe Walsh''s first signature pedal combining his Compressor circuit and Classic Amp (tube amp emulation) circuit. Pre/Post switch for signal routing. All-analog.',
    'Medium'
);

INSERT INTO pedal_details (
    product_id,
    effect_type, signal_type, bypass_type, mono_stereo,
    battery_capable
) VALUES (
    currval('products_id_seq'),
    'Multi Effects', 'Analog', 'True Bypass', 'Mono',
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
    (currval('products_id_seq'), 'products', 'product_page', 'https://analogalien.com/product/joe-walsh-double-classic-compressor-overdrive-pedal/', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'width_mm', 'https://www.amazon.com/Joe-Walsh-Double-Classic-Compressor/dp/B01G43M8QA', 'major_retailer', 'Medium', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'depth_mm', 'https://www.amazon.com/Joe-Walsh-Double-Classic-Compressor/dp/B01G43M8QA', 'major_retailer', 'Medium', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'height_mm', 'https://www.amazon.com/Joe-Walsh-Double-Classic-Compressor/dp/B01G43M8QA', 'major_retailer', 'Medium', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'weight_grams', 'https://www.amazon.com/Joe-Walsh-Double-Classic-Compressor/dp/B01G43M8QA', 'major_retailer', 'Medium', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'msrp_cents', 'https://www.sweetwater.com/store/detail/JWDC--analog-alien-joe-walsh-double-classic-compressor-overdrive-pedal', 'major_retailer', 'Medium', '2026-03-21'),
    (currval('products_id_seq'), 'pedal_details', 'effect_type', 'https://analogalien.com/product/joe-walsh-double-classic-compressor-overdrive-pedal/', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'pedal_details', 'bypass_type', 'https://analogalien.com/product/joe-walsh-double-classic-compressor-overdrive-pedal/', 'manufacturer_website', 'High', '2026-03-21');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 9. POWER PACK
-- ============================================================
INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm,
    weight_grams, msrp_cents,
    product_page,
    description, data_reliability
) VALUES (
    15, 1, 'Power Pack',
    TRUE,
    146.1, 120.7, 38.1,
    NULL, 15900,
    'https://analogalien.com/product/power-pack-clean-boost-pedal/',
    'All-analog clean boost with buffered input. Works with both guitar and bass. Wide frequency response.',
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
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', NULL, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'product_page', 'https://analogalien.com/product/power-pack-clean-boost-pedal/', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'width_mm', 'https://analogalien.com/product/power-pack-clean-boost-pedal/', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'depth_mm', 'https://analogalien.com/product/power-pack-clean-boost-pedal/', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'height_mm', 'https://analogalien.com/product/power-pack-clean-boost-pedal/', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'msrp_cents', 'https://www.sweetwater.com/store/detail/PowerPackBoost--analog-alien-power-pack-clean-boost-pedal', 'major_retailer', 'Medium', '2026-03-21'),
    (currval('products_id_seq'), 'pedal_details', 'effect_type', 'https://analogalien.com/product/power-pack-clean-boost-pedal/', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'pedal_details', 'bypass_type', 'https://analogalien.com/product/power-pack-clean-boost-pedal/', 'manufacturer_website', 'High', '2026-03-21');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 10. EPi (EFFECTS PEDAL INTERFACE) — Utility
-- ============================================================
INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm,
    weight_grams, msrp_cents,
    product_page, instruction_manual,
    description, data_reliability
) VALUES (
    15, 5, 'EPi',
    TRUE,
    NULL, NULL, NULL,
    NULL, 34900,
    'https://analogalien.com/product/epi-effects-pedal-interface/',
    'https://www.analogalien.com/wp-content/uploads/2018/12/ANALOG_ALIEN_EPI_TECH_MANUAL-2-1.pdf',
    'Effects Pedal Interface for recording pedal signals directly into a DAW or tape. Dual FX send/return loops, balanced XLR output, RCA line I/O, Hi-Z combo input, and auto impedance/voltage adjustment.',
    'Medium'
);

INSERT INTO utility_details (
    product_id,
    utility_type, is_active, signal_type
) VALUES (
    currval('products_id_seq'),
    'Signal Router', TRUE, 'Analog'
);

-- EPi jacks: power + Hi-Z combo in + RCA line in + XLR balanced out + RCA unbalanced out + 1/4" thru + 1/4" buffered out + 2x loop send + 2x loop return = 11 jacks
INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', NULL, NULL, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'input', 'XLR Combo', 'Hi-Z Input');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'input', 'RCA', 'Line In');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', 'XLR', 'Balanced Out');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', 'RCA', 'Unbalanced Out');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Thru');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Buffered Guitar Out');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, group_id)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'FX Loop A Send', 'loop_1');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, group_id)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS', 'FX Loop A Return', 'loop_1');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, group_id)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'FX Loop B Send', 'loop_2');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, group_id)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS', 'FX Loop B Return', 'loop_2');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'product_page', 'https://analogalien.com/product/epi-effects-pedal-interface/', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'instruction_manual', 'https://www.analogalien.com/wp-content/uploads/2018/12/ANALOG_ALIEN_EPI_TECH_MANUAL-2-1.pdf', 'manufacturer_manual', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'products', 'msrp_cents', 'https://analogalien.com/product/epi-effects-pedal-interface/', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'utility_details', 'utility_type', 'https://analogalien.com/product/epi-effects-pedal-interface/', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'utility_details', 'is_active', 'https://www.analogalien.com/wp-content/uploads/2018/12/ANALOG_ALIEN_EPI_TECH_MANUAL-2-1.pdf', 'manufacturer_manual', 'High', '2026-03-21');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 11. ALIEN SWITCHER — Utility
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
    15, 5, 'Alien Switcher',
    NULL,
    NULL, NULL, NULL,
    NULL, NULL,
    'https://analogalien.com/alien-switcher/',
    'Relay-based silent switching between guitar and microphone signals. Separate signal paths for each. Requires 9V external power supply (Boss PSA compatible).',
    'Low',
    'Production status unknown — limited availability suggests possible discontinuation. All dimensions and MSRP unknown.'
);

INSERT INTO utility_details (
    product_id,
    utility_type, is_active, signal_type
) VALUES (
    currval('products_id_seq'),
    'A/B Box', TRUE, 'Analog'
);

-- Alien Switcher jacks: power + 2 audio inputs + 2 audio outputs = 5 jacks
INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', NULL, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS', 'Guitar In');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS', 'Mic In');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Guitar Out');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Mic Out');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'product_page', 'https://analogalien.com/alien-switcher/', 'manufacturer_website', 'High', '2026-03-21'),
    (currval('products_id_seq'), 'utility_details', 'utility_type', 'https://analogalien.com/alien-switcher/', 'manufacturer_website', 'High', '2026-03-21');

INSERT INTO product_sources (product_id, table_name, field_name, jack_id, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'jacks', 'voltage',
     (SELECT id FROM jacks WHERE product_id = currval('products_id_seq') AND category = 'power' AND direction = 'input'),
     'https://analogalien.com/alien-switcher/', 'manufacturer_website', '9V DC (Boss PSA compatible)', 'High', '2026-03-21');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

COMMIT;
