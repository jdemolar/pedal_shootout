-- Migration 027: Add Animals Pedal products (Manufacturer ID 19) — 21 products
-- All specs sourced from Animals Pedal USA official store (animalspedal.us) — High reliability.
-- Current draw (mA) rounded to nearest integer where fractional values were found.
-- Missing current draw for Major Overdrive, Rover Fuzz, Rust Rod Fuzz — stored as NULL.
--
-- Pedals (20): 1927 Home Run King Comp., Angel Bear Face Fuzz, Bath Time Reverb,
--   Car Crush Chorus/Vibe, Dawn Ocean Meditation Booster, Diamond Peak Hybrid Over Drive,
--   Double Spy Mission is Impossible Filter, Fishing Is As Fun As Fuzz,
--   I Was A Wolf In The Forest Distortion, In Oct 3 Foxes talking of dreamy Fuzz,
--   Major Overdrive, Push & Pull Distortion, Relaxing Walrus Delay, Rover Fuzz,
--   Rust Rod Fuzz, Sunday Afternoon Is Infinity Bender, Surfing Bear Overdrive,
--   Surfing Polar Bear Bass Overdrive (BJF Mod), Tioga Road Cycling Distortion,
--   Vintage Van Driving is Very Fun
-- Utility (1): Firewood Acoustic D.I. MKII
--
-- Standard footprint (most pedals): 64 × 112 × 50 mm
-- Exceptions: Angel Bear Face Fuzz (64×108×49mm), Dawn Ocean Booster (64×112×46mm),
--             Firewood Acoustic D.I. MKII (100×122×57mm)
--
-- Collaboration notes:
--   Skreddy Pedals (Marc Ahlfs): Angel Bear Face Fuzz, Major Overdrive, Rover Fuzz, Rust Rod Fuzz
--   BJFe (Björn Juhl): Surfing Polar Bear Bass Overdrive (BJF Mod)

BEGIN;

-- ============================================================
-- 1. 1927 HOME RUN KING COMP.
-- Compressor; 17.5mA draw rounded to 18mA.
-- ============================================================
INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    msrp_cents, product_page,
    description, data_reliability
) VALUES (
    19, 1, '1927 Home Run King Comp.',
    TRUE,
    64.0, 112.0, 50.0, 378,
    12899, 'https://animalspedal.us/products/animals-pedal-1927-home-run-king-comp',
    'Analog compressor with a dynamic LED level indicator.',
    'High'
);

INSERT INTO pedal_details (product_id, effect_type, signal_type, bypass_type, mono_stereo, battery_capable)
VALUES (currval('products_id_seq'), 'Compression', 'Analog', 'True Bypass', 'Mono', TRUE);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', 18, 'Center Negative');

INSERT INTO product_sources (product_id, table_name, field_name, jack_id, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES (currval('products_id_seq'), 'jacks', 'current_ma', currval('jacks_id_seq'),
        'https://animalspedal.us/products/animals-pedal-1927-home-run-king-comp',
        'manufacturer_website', '17.5mA', 'High', '2026-04-08');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'width_mm',      'https://animalspedal.us/products/animals-pedal-1927-home-run-king-comp', 'manufacturer_website', '64mm',    'High', '2026-04-08'),
    (currval('products_id_seq'), 'products', 'depth_mm',      'https://animalspedal.us/products/animals-pedal-1927-home-run-king-comp', 'manufacturer_website', '112mm',   'High', '2026-04-08'),
    (currval('products_id_seq'), 'products', 'height_mm',     'https://animalspedal.us/products/animals-pedal-1927-home-run-king-comp', 'manufacturer_website', '50mm',    'High', '2026-04-08'),
    (currval('products_id_seq'), 'products', 'weight_grams',  'https://animalspedal.us/products/animals-pedal-1927-home-run-king-comp', 'manufacturer_website', '378g',    'High', '2026-04-08'),
    (currval('products_id_seq'), 'products', 'msrp_cents',    'https://animalspedal.us/products/animals-pedal-1927-home-run-king-comp', 'manufacturer_website', '$128.99', 'High', '2026-04-08'),
    (currval('products_id_seq'), 'pedal_details', 'effect_type',  'https://animalspedal.us/products/animals-pedal-1927-home-run-king-comp', 'manufacturer_website', 'Compressor',   'High', '2026-04-08'),
    (currval('products_id_seq'), 'pedal_details', 'bypass_type',  'https://animalspedal.us/products/animals-pedal-1927-home-run-king-comp', 'manufacturer_website', 'True Bypass',  'High', '2026-04-08');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 2. ANGEL BEAR FACE FUZZ
-- Fuzz Face-style silicon fuzz; Skreddy Pedals collaboration.
-- Slightly smaller footprint: 64×108×49mm. 3.5mA rounded to 4mA.
-- ============================================================
INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    msrp_cents, product_page,
    description, data_reliability, notes
) VALUES (
    19, 1, 'Angel Bear Face Fuzz',
    TRUE,
    64.0, 108.0, 49.0, 380,
    13899, 'https://animalspedal.us/products/ap-skr-abffk',
    'Fuzz Face-style silicon fuzz; a Skreddy Pedals collaboration.',
    'High',
    'Collaboration with Skreddy Pedals (Marc Ahlfs).'
);

INSERT INTO pedal_details (product_id, effect_type, circuit_type, signal_type, bypass_type, mono_stereo, battery_capable)
VALUES (currval('products_id_seq'), 'Fuzz', 'Fuzz Face', 'Analog', 'True Bypass', 'Mono', TRUE);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', 4, 'Center Negative');

INSERT INTO product_sources (product_id, table_name, field_name, jack_id, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES (currval('products_id_seq'), 'jacks', 'current_ma', currval('jacks_id_seq'),
        'https://animalspedal.us/products/ap-skr-abffk',
        'manufacturer_website', '3.5mA', 'High', '2026-04-08');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'width_mm',      'https://animalspedal.us/products/ap-skr-abffk', 'manufacturer_website', '64mm',    'High', '2026-04-08'),
    (currval('products_id_seq'), 'products', 'depth_mm',      'https://animalspedal.us/products/ap-skr-abffk', 'manufacturer_website', '108mm',   'High', '2026-04-08'),
    (currval('products_id_seq'), 'products', 'height_mm',     'https://animalspedal.us/products/ap-skr-abffk', 'manufacturer_website', '49mm',    'High', '2026-04-08'),
    (currval('products_id_seq'), 'products', 'weight_grams',  'https://animalspedal.us/products/ap-skr-abffk', 'manufacturer_website', '380g',    'High', '2026-04-08'),
    (currval('products_id_seq'), 'products', 'msrp_cents',    'https://animalspedal.us/products/ap-skr-abffk', 'manufacturer_website', '$138.99', 'High', '2026-04-08'),
    (currval('products_id_seq'), 'pedal_details', 'effect_type',  'https://animalspedal.us/products/ap-skr-abffk', 'manufacturer_website', 'Fuzz',        'High', '2026-04-08'),
    (currval('products_id_seq'), 'pedal_details', 'bypass_type',  'https://animalspedal.us/products/ap-skr-abffk', 'manufacturer_website', 'True Bypass', 'High', '2026-04-08');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 3. BATH TIME REVERB
-- Digital reverb; 140mA indicates digital processing.
-- ============================================================
INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    msrp_cents, product_page,
    description, data_reliability
) VALUES (
    19, 1, 'Bath Time Reverb',
    TRUE,
    64.0, 112.0, 50.0, 382,
    16499, 'https://animalspedal.us/products/animals-pedal-bath-time-reverb',
    'Digital reverb with lush algorithmic processing.',
    'High'
);

INSERT INTO pedal_details (product_id, effect_type, signal_type, bypass_type, mono_stereo, battery_capable)
VALUES (currval('products_id_seq'), 'Reverb', 'Digital', 'True Bypass', 'Mono', TRUE);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', 140, 'Center Negative');

INSERT INTO product_sources (product_id, table_name, field_name, jack_id, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES (currval('products_id_seq'), 'jacks', 'current_ma', currval('jacks_id_seq'),
        'https://animalspedal.us/products/animals-pedal-bath-time-reverb',
        'manufacturer_website', '140mA', 'High', '2026-04-08');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'width_mm',      'https://animalspedal.us/products/animals-pedal-bath-time-reverb', 'manufacturer_website', '64mm',    'High', '2026-04-08'),
    (currval('products_id_seq'), 'products', 'depth_mm',      'https://animalspedal.us/products/animals-pedal-bath-time-reverb', 'manufacturer_website', '112mm',   'High', '2026-04-08'),
    (currval('products_id_seq'), 'products', 'height_mm',     'https://animalspedal.us/products/animals-pedal-bath-time-reverb', 'manufacturer_website', '50mm',    'High', '2026-04-08'),
    (currval('products_id_seq'), 'products', 'weight_grams',  'https://animalspedal.us/products/animals-pedal-bath-time-reverb', 'manufacturer_website', '382g',    'High', '2026-04-08'),
    (currval('products_id_seq'), 'products', 'msrp_cents',    'https://animalspedal.us/products/animals-pedal-bath-time-reverb', 'manufacturer_website', '$164.99', 'High', '2026-04-08'),
    (currval('products_id_seq'), 'pedal_details', 'effect_type',  'https://animalspedal.us/products/animals-pedal-bath-time-reverb', 'manufacturer_website', 'Reverb',      'High', '2026-04-08'),
    (currval('products_id_seq'), 'pedal_details', 'bypass_type',  'https://animalspedal.us/products/animals-pedal-bath-time-reverb', 'manufacturer_website', 'True Bypass', 'High', '2026-04-08');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 4. CAR CRUSH CHORUS/VIBE
-- Analog chorus with switchable vibrato mode. 5.5mA rounded to 6mA.
-- ============================================================
INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    msrp_cents, product_page,
    description, data_reliability
) VALUES (
    19, 1, 'Car Crush Chorus/Vibe',
    TRUE,
    64.0, 112.0, 50.0, 390,
    12899, 'https://animalspedal.us/products/animals-pedal-car-crush-chorus-vibe',
    'Analog chorus with switchable vibrato mode.',
    'High'
);

INSERT INTO pedal_details (product_id, effect_type, signal_type, bypass_type, mono_stereo, battery_capable)
VALUES (currval('products_id_seq'), 'Chorus', 'Analog', 'True Bypass', 'Mono', TRUE);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', 6, 'Center Negative');

INSERT INTO product_sources (product_id, table_name, field_name, jack_id, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES (currval('products_id_seq'), 'jacks', 'current_ma', currval('jacks_id_seq'),
        'https://animalspedal.us/products/animals-pedal-car-crush-chorus-vibe',
        'manufacturer_website', '5.5mA', 'High', '2026-04-08');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'width_mm',      'https://animalspedal.us/products/animals-pedal-car-crush-chorus-vibe', 'manufacturer_website', '64mm',    'High', '2026-04-08'),
    (currval('products_id_seq'), 'products', 'depth_mm',      'https://animalspedal.us/products/animals-pedal-car-crush-chorus-vibe', 'manufacturer_website', '112mm',   'High', '2026-04-08'),
    (currval('products_id_seq'), 'products', 'height_mm',     'https://animalspedal.us/products/animals-pedal-car-crush-chorus-vibe', 'manufacturer_website', '50mm',    'High', '2026-04-08'),
    (currval('products_id_seq'), 'products', 'weight_grams',  'https://animalspedal.us/products/animals-pedal-car-crush-chorus-vibe', 'manufacturer_website', '390g',    'High', '2026-04-08'),
    (currval('products_id_seq'), 'products', 'msrp_cents',    'https://animalspedal.us/products/animals-pedal-car-crush-chorus-vibe', 'manufacturer_website', '$128.99', 'High', '2026-04-08'),
    (currval('products_id_seq'), 'pedal_details', 'effect_type',  'https://animalspedal.us/products/animals-pedal-car-crush-chorus-vibe', 'manufacturer_website', 'Chorus',      'High', '2026-04-08'),
    (currval('products_id_seq'), 'pedal_details', 'bypass_type',  'https://animalspedal.us/products/animals-pedal-car-crush-chorus-vibe', 'manufacturer_website', 'True Bypass', 'High', '2026-04-08');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 5. DAWN OCEAN MEDITATION BOOSTER
-- Clean boost up to +15dB; 5M ohm input impedance.
-- Slightly shorter: 64×112×46mm.
-- ============================================================
INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    msrp_cents, product_page,
    description, data_reliability
) VALUES (
    19, 1, 'Dawn Ocean Meditation Booster',
    TRUE,
    64.0, 112.0, 46.0, 366,
    13399, 'https://animalspedal.us/products/animals-pedal-dawn-ocean-meditation-booster',
    'Clean boost up to +15dB with a high-impedance (5MΩ) input.',
    'High'
);

INSERT INTO pedal_details (product_id, effect_type, signal_type, bypass_type, mono_stereo, battery_capable)
VALUES (currval('products_id_seq'), 'Gain', 'Analog', 'True Bypass', 'Mono', TRUE);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', 1, 'Center Negative');

INSERT INTO product_sources (product_id, table_name, field_name, jack_id, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES (currval('products_id_seq'), 'jacks', 'current_ma', currval('jacks_id_seq'),
        'https://animalspedal.us/products/animals-pedal-dawn-ocean-meditation-booster',
        'manufacturer_website', '1mA', 'High', '2026-04-08');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'width_mm',      'https://animalspedal.us/products/animals-pedal-dawn-ocean-meditation-booster', 'manufacturer_website', '64mm',    'High', '2026-04-08'),
    (currval('products_id_seq'), 'products', 'depth_mm',      'https://animalspedal.us/products/animals-pedal-dawn-ocean-meditation-booster', 'manufacturer_website', '112mm',   'High', '2026-04-08'),
    (currval('products_id_seq'), 'products', 'height_mm',     'https://animalspedal.us/products/animals-pedal-dawn-ocean-meditation-booster', 'manufacturer_website', '46mm',    'High', '2026-04-08'),
    (currval('products_id_seq'), 'products', 'weight_grams',  'https://animalspedal.us/products/animals-pedal-dawn-ocean-meditation-booster', 'manufacturer_website', '366g',    'High', '2026-04-08'),
    (currval('products_id_seq'), 'products', 'msrp_cents',    'https://animalspedal.us/products/animals-pedal-dawn-ocean-meditation-booster', 'manufacturer_website', '$133.99', 'High', '2026-04-08'),
    (currval('products_id_seq'), 'pedal_details', 'effect_type',  'https://animalspedal.us/products/animals-pedal-dawn-ocean-meditation-booster', 'manufacturer_website', 'Boost/Gain',  'High', '2026-04-08'),
    (currval('products_id_seq'), 'pedal_details', 'bypass_type',  'https://animalspedal.us/products/animals-pedal-dawn-ocean-meditation-booster', 'manufacturer_website', 'True Bypass', 'High', '2026-04-08');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 6. DIAMOND PEAK HYBRID OVER DRIVE
-- Analog OD; "Hybrid" refers to clipping topology, not digital processing.
-- 1mA draw confirms analog circuit.
-- ============================================================
INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    msrp_cents, product_page,
    description, data_reliability
) VALUES (
    19, 1, 'Diamond Peak Hybrid Over Drive',
    TRUE,
    64.0, 112.0, 50.0, 383,
    13899, 'https://animalspedal.us/products/animals-pedal-diamond-peak-hybrid-over-drive',
    'Analog overdrive with a hybrid clipping topology.',
    'High'
);

INSERT INTO pedal_details (product_id, effect_type, signal_type, bypass_type, mono_stereo, battery_capable)
VALUES (currval('products_id_seq'), 'Gain', 'Analog', 'True Bypass', 'Mono', TRUE);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', 1, 'Center Negative');

INSERT INTO product_sources (product_id, table_name, field_name, jack_id, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES (currval('products_id_seq'), 'jacks', 'current_ma', currval('jacks_id_seq'),
        'https://animalspedal.us/products/animals-pedal-diamond-peak-hybrid-over-drive',
        'manufacturer_website', '1mA', 'High', '2026-04-08');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'width_mm',      'https://animalspedal.us/products/animals-pedal-diamond-peak-hybrid-over-drive', 'manufacturer_website', '64mm',    'High', '2026-04-08'),
    (currval('products_id_seq'), 'products', 'depth_mm',      'https://animalspedal.us/products/animals-pedal-diamond-peak-hybrid-over-drive', 'manufacturer_website', '112mm',   'High', '2026-04-08'),
    (currval('products_id_seq'), 'products', 'height_mm',     'https://animalspedal.us/products/animals-pedal-diamond-peak-hybrid-over-drive', 'manufacturer_website', '50mm',    'High', '2026-04-08'),
    (currval('products_id_seq'), 'products', 'weight_grams',  'https://animalspedal.us/products/animals-pedal-diamond-peak-hybrid-over-drive', 'manufacturer_website', '383g',    'High', '2026-04-08'),
    (currval('products_id_seq'), 'products', 'msrp_cents',    'https://animalspedal.us/products/animals-pedal-diamond-peak-hybrid-over-drive', 'manufacturer_website', '$138.99', 'High', '2026-04-08'),
    (currval('products_id_seq'), 'pedal_details', 'effect_type',  'https://animalspedal.us/products/animals-pedal-diamond-peak-hybrid-over-drive', 'manufacturer_website', 'Overdrive',   'High', '2026-04-08'),
    (currval('products_id_seq'), 'pedal_details', 'bypass_type',  'https://animalspedal.us/products/animals-pedal-diamond-peak-hybrid-over-drive', 'manufacturer_website', 'True Bypass', 'High', '2026-04-08');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 7. DOUBLE SPY MISSION IS IMPOSSIBLE FILTER
-- Analog auto-wah / envelope filter.
-- ============================================================
INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    msrp_cents, product_page,
    description, data_reliability
) VALUES (
    19, 1, 'Double Spy Mission is Impossible Filter',
    TRUE,
    64.0, 112.0, 50.0, 379,
    12899, 'https://animalspedal.us/products/animals-pedal-double-spy-mission-is-impossible-filter',
    'Analog auto-wah / envelope filter.',
    'High'
);

INSERT INTO pedal_details (product_id, effect_type, signal_type, bypass_type, mono_stereo, battery_capable)
VALUES (currval('products_id_seq'), 'Filter', 'Analog', 'True Bypass', 'Mono', TRUE);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', 1, 'Center Negative');

INSERT INTO product_sources (product_id, table_name, field_name, jack_id, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES (currval('products_id_seq'), 'jacks', 'current_ma', currval('jacks_id_seq'),
        'https://animalspedal.us/products/animals-pedal-double-spy-mission-is-impossible-filter',
        'manufacturer_website', '1mA', 'High', '2026-04-08');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'width_mm',      'https://animalspedal.us/products/animals-pedal-double-spy-mission-is-impossible-filter', 'manufacturer_website', '64mm',    'High', '2026-04-08'),
    (currval('products_id_seq'), 'products', 'depth_mm',      'https://animalspedal.us/products/animals-pedal-double-spy-mission-is-impossible-filter', 'manufacturer_website', '112mm',   'High', '2026-04-08'),
    (currval('products_id_seq'), 'products', 'height_mm',     'https://animalspedal.us/products/animals-pedal-double-spy-mission-is-impossible-filter', 'manufacturer_website', '50mm',    'High', '2026-04-08'),
    (currval('products_id_seq'), 'products', 'weight_grams',  'https://animalspedal.us/products/animals-pedal-double-spy-mission-is-impossible-filter', 'manufacturer_website', '379g',    'High', '2026-04-08'),
    (currval('products_id_seq'), 'products', 'msrp_cents',    'https://animalspedal.us/products/animals-pedal-double-spy-mission-is-impossible-filter', 'manufacturer_website', '$128.99', 'High', '2026-04-08'),
    (currval('products_id_seq'), 'pedal_details', 'effect_type',  'https://animalspedal.us/products/animals-pedal-double-spy-mission-is-impossible-filter', 'manufacturer_website', 'Filter/Auto-Wah', 'High', '2026-04-08'),
    (currval('products_id_seq'), 'pedal_details', 'bypass_type',  'https://animalspedal.us/products/animals-pedal-double-spy-mission-is-impossible-filter', 'manufacturer_website', 'True Bypass',     'High', '2026-04-08');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 8. FISHING IS AS FUN AS FUZZ
-- Big Muff-style silicon fuzz. 4.5mA rounded to 5mA.
-- ============================================================
INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    msrp_cents, product_page,
    description, data_reliability
) VALUES (
    19, 1, 'Fishing Is As Fun As Fuzz',
    TRUE,
    64.0, 112.0, 50.0, 378,
    11899, 'https://animalspedal.us/products/animals-pedal-fishing-is-as-fun-as-fuzz',
    'Big Muff-style analog fuzz.',
    'High'
);

INSERT INTO pedal_details (product_id, effect_type, circuit_type, signal_type, bypass_type, mono_stereo, battery_capable)
VALUES (currval('products_id_seq'), 'Fuzz', 'Big Muff', 'Analog', 'True Bypass', 'Mono', TRUE);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', 5, 'Center Negative');

INSERT INTO product_sources (product_id, table_name, field_name, jack_id, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES (currval('products_id_seq'), 'jacks', 'current_ma', currval('jacks_id_seq'),
        'https://animalspedal.us/products/animals-pedal-fishing-is-as-fun-as-fuzz',
        'manufacturer_website', '4.5mA', 'High', '2026-04-08');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'width_mm',      'https://animalspedal.us/products/animals-pedal-fishing-is-as-fun-as-fuzz', 'manufacturer_website', '64mm',    'High', '2026-04-08'),
    (currval('products_id_seq'), 'products', 'depth_mm',      'https://animalspedal.us/products/animals-pedal-fishing-is-as-fun-as-fuzz', 'manufacturer_website', '112mm',   'High', '2026-04-08'),
    (currval('products_id_seq'), 'products', 'height_mm',     'https://animalspedal.us/products/animals-pedal-fishing-is-as-fun-as-fuzz', 'manufacturer_website', '50mm',    'High', '2026-04-08'),
    (currval('products_id_seq'), 'products', 'weight_grams',  'https://animalspedal.us/products/animals-pedal-fishing-is-as-fun-as-fuzz', 'manufacturer_website', '378g',    'High', '2026-04-08'),
    (currval('products_id_seq'), 'products', 'msrp_cents',    'https://animalspedal.us/products/animals-pedal-fishing-is-as-fun-as-fuzz', 'manufacturer_website', '$118.99', 'High', '2026-04-08'),
    (currval('products_id_seq'), 'pedal_details', 'effect_type',  'https://animalspedal.us/products/animals-pedal-fishing-is-as-fun-as-fuzz', 'manufacturer_website', 'Fuzz',        'High', '2026-04-08'),
    (currval('products_id_seq'), 'pedal_details', 'bypass_type',  'https://animalspedal.us/products/animals-pedal-fishing-is-as-fun-as-fuzz', 'manufacturer_website', 'True Bypass', 'High', '2026-04-08');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 9. FIREWOOD ACOUSTIC D.I. MKII
-- Active DI box with 3-band EQ and effects loop.
-- Power: 9V DC in (5mA) + DC out thru + 48V phantom via XLR.
-- Utility type; listed as product_type_id = 5.
-- ============================================================
INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    msrp_cents, product_page,
    description, data_reliability, notes
) VALUES (
    19, 5, 'Firewood Acoustic D.I. MKII',
    TRUE,
    100.0, 122.0, 57.0, 400,
    21999, 'https://animalspedal.us/products/firewood-acoustic-di-mkii',
    'Active acoustic DI box with 3-band EQ, effects loop, and balanced XLR output. Powered by 9V DC or 48V phantom power.',
    'High',
    'Has 9V DC in, DC out (power thru), 1/4" TS in, 1/4" TS thru out, XLR balanced out (phantom 48V), FX loop send/return.'
);

INSERT INTO utility_details (
    product_id, utility_type, is_active, signal_type, bypass_type,
    has_ground_lift, has_pad, pad_db
) VALUES (
    currval('products_id_seq'), 'DI Box', TRUE, 'Analog', 'True Bypass',
    NULL, NULL, NULL
);

-- DC power input (9V, 5mA, 2.1mm center-negative)
INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', 5, 'Center Negative');

INSERT INTO product_sources (product_id, table_name, field_name, jack_id, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES (currval('products_id_seq'), 'jacks', 'current_ma', currval('jacks_id_seq'),
        'https://animalspedal.us/products/firewood-acoustic-di-mkii',
        'manufacturer_website', '5mA', 'High', '2026-04-08');

-- DC power thru output (9V, 2.1mm center-negative — powers a second device)
INSERT INTO jacks (product_id, category, direction, connector_type, voltage, polarity)
VALUES (currval('products_id_seq'), 'power', 'output', '2.1mm barrel', '9V', 'Center Negative');

-- Audio: instrument input
INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS', 'Instrument In');

-- Audio: 1/4" unbalanced thru output (to amp)
INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Thru');

-- Audio: XLR balanced output (phantom powered)
INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, is_balanced, power_over_connector, voltage)
VALUES (currval('products_id_seq'), 'audio', 'output', 'XLR', 'XLR Out', TRUE, TRUE, '48V');

-- FX loop send
INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, group_id)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'FX Send', 'fx_loop_1');

-- FX loop return
INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, group_id)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS', 'FX Return', 'fx_loop_1');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'width_mm',       'https://animalspedal.us/products/firewood-acoustic-di-mkii', 'manufacturer_website', '100mm',   'High', '2026-04-08'),
    (currval('products_id_seq'), 'products', 'depth_mm',       'https://animalspedal.us/products/firewood-acoustic-di-mkii', 'manufacturer_website', '122mm',   'High', '2026-04-08'),
    (currval('products_id_seq'), 'products', 'height_mm',      'https://animalspedal.us/products/firewood-acoustic-di-mkii', 'manufacturer_website', '57mm',    'High', '2026-04-08'),
    (currval('products_id_seq'), 'products', 'weight_grams',   'https://animalspedal.us/products/firewood-acoustic-di-mkii', 'manufacturer_website', '400g',    'High', '2026-04-08'),
    (currval('products_id_seq'), 'products', 'msrp_cents',     'https://animalspedal.us/products/firewood-acoustic-di-mkii', 'manufacturer_website', '$219.99', 'High', '2026-04-08'),
    (currval('products_id_seq'), 'utility_details', 'utility_type',  'https://animalspedal.us/products/firewood-acoustic-di-mkii', 'manufacturer_website', 'DI Box',      'High', '2026-04-08'),
    (currval('products_id_seq'), 'utility_details', 'bypass_type',   'https://animalspedal.us/products/firewood-acoustic-di-mkii', 'manufacturer_website', 'True Bypass', 'High', '2026-04-08');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 10. I WAS A WOLF IN THE FOREST DISTORTION
-- ============================================================
INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    msrp_cents, product_page,
    description, data_reliability
) VALUES (
    19, 1, 'I Was A Wolf In The Forest Distortion',
    TRUE,
    64.0, 112.0, 50.0, 379,
    11899, 'https://animalspedal.us/products/animals-pedal-i-was-a-wolf-in-the-forest-distortion',
    'Analog distortion with adjustable gain and tone.',
    'High'
);

INSERT INTO pedal_details (product_id, effect_type, signal_type, bypass_type, mono_stereo, battery_capable)
VALUES (currval('products_id_seq'), 'Gain', 'Analog', 'True Bypass', 'Mono', TRUE);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', 6, 'Center Negative');

INSERT INTO product_sources (product_id, table_name, field_name, jack_id, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES (currval('products_id_seq'), 'jacks', 'current_ma', currval('jacks_id_seq'),
        'https://animalspedal.us/products/animals-pedal-i-was-a-wolf-in-the-forest-distortion',
        'manufacturer_website', '6mA', 'High', '2026-04-08');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'width_mm',      'https://animalspedal.us/products/animals-pedal-i-was-a-wolf-in-the-forest-distortion', 'manufacturer_website', '64mm',    'High', '2026-04-08'),
    (currval('products_id_seq'), 'products', 'depth_mm',      'https://animalspedal.us/products/animals-pedal-i-was-a-wolf-in-the-forest-distortion', 'manufacturer_website', '112mm',   'High', '2026-04-08'),
    (currval('products_id_seq'), 'products', 'height_mm',     'https://animalspedal.us/products/animals-pedal-i-was-a-wolf-in-the-forest-distortion', 'manufacturer_website', '50mm',    'High', '2026-04-08'),
    (currval('products_id_seq'), 'products', 'weight_grams',  'https://animalspedal.us/products/animals-pedal-i-was-a-wolf-in-the-forest-distortion', 'manufacturer_website', '379g',    'High', '2026-04-08'),
    (currval('products_id_seq'), 'products', 'msrp_cents',    'https://animalspedal.us/products/animals-pedal-i-was-a-wolf-in-the-forest-distortion', 'manufacturer_website', '$118.99', 'High', '2026-04-08'),
    (currval('products_id_seq'), 'pedal_details', 'effect_type',  'https://animalspedal.us/products/animals-pedal-i-was-a-wolf-in-the-forest-distortion', 'manufacturer_website', 'Distortion',  'High', '2026-04-08'),
    (currval('products_id_seq'), 'pedal_details', 'bypass_type',  'https://animalspedal.us/products/animals-pedal-i-was-a-wolf-in-the-forest-distortion', 'manufacturer_website', 'True Bypass', 'High', '2026-04-08');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 11. IN OCT, 3 FOXES TALKING OF DREAMY FUZZ
-- Analog octave-up fuzz.
-- ============================================================
INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    msrp_cents, product_page,
    description, data_reliability
) VALUES (
    19, 1, 'In Oct, 3 Foxes talking of dreamy Fuzz',
    TRUE,
    64.0, 112.0, 50.0, 384,
    12899, 'https://animalspedal.us/products/animals-pedal-in-oct-3-foxes-talking-of-dreamy-fuzz',
    'Analog octave-up fuzz.',
    'High'
);

INSERT INTO pedal_details (product_id, effect_type, signal_type, bypass_type, mono_stereo, battery_capable)
VALUES (currval('products_id_seq'), 'Fuzz', 'Analog', 'True Bypass', 'Mono', TRUE);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', 1, 'Center Negative');

INSERT INTO product_sources (product_id, table_name, field_name, jack_id, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES (currval('products_id_seq'), 'jacks', 'current_ma', currval('jacks_id_seq'),
        'https://animalspedal.us/products/animals-pedal-in-oct-3-foxes-talking-of-dreamy-fuzz',
        'manufacturer_website', '1mA', 'High', '2026-04-08');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'width_mm',      'https://animalspedal.us/products/animals-pedal-in-oct-3-foxes-talking-of-dreamy-fuzz', 'manufacturer_website', '64mm',    'High', '2026-04-08'),
    (currval('products_id_seq'), 'products', 'depth_mm',      'https://animalspedal.us/products/animals-pedal-in-oct-3-foxes-talking-of-dreamy-fuzz', 'manufacturer_website', '112mm',   'High', '2026-04-08'),
    (currval('products_id_seq'), 'products', 'height_mm',     'https://animalspedal.us/products/animals-pedal-in-oct-3-foxes-talking-of-dreamy-fuzz', 'manufacturer_website', '50mm',    'High', '2026-04-08'),
    (currval('products_id_seq'), 'products', 'weight_grams',  'https://animalspedal.us/products/animals-pedal-in-oct-3-foxes-talking-of-dreamy-fuzz', 'manufacturer_website', '384g',    'High', '2026-04-08'),
    (currval('products_id_seq'), 'products', 'msrp_cents',    'https://animalspedal.us/products/animals-pedal-in-oct-3-foxes-talking-of-dreamy-fuzz', 'manufacturer_website', '$128.99', 'High', '2026-04-08'),
    (currval('products_id_seq'), 'pedal_details', 'effect_type',  'https://animalspedal.us/products/animals-pedal-in-oct-3-foxes-talking-of-dreamy-fuzz', 'manufacturer_website', 'Octave Fuzz', 'High', '2026-04-08'),
    (currval('products_id_seq'), 'pedal_details', 'bypass_type',  'https://animalspedal.us/products/animals-pedal-in-oct-3-foxes-talking-of-dreamy-fuzz', 'manufacturer_website', 'True Bypass', 'High', '2026-04-08');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 12. MAJOR OVERDRIVE
-- Skreddy Pedals collaboration. Current draw not found — NULL.
-- ============================================================
INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    msrp_cents, product_page,
    description, data_reliability, notes
) VALUES (
    19, 1, 'Major Overdrive',
    TRUE,
    64.0, 112.0, 50.0, 378,
    13899, 'https://animalspedal.us/products/animals-pedal-major-overdrive',
    'Analog overdrive; a Skreddy Pedals collaboration.',
    'High',
    'Collaboration with Skreddy Pedals (Marc Ahlfs). Current draw not documented on product page.'
);

INSERT INTO pedal_details (product_id, effect_type, signal_type, bypass_type, mono_stereo, battery_capable)
VALUES (currval('products_id_seq'), 'Gain', 'Analog', 'True Bypass', 'Mono', TRUE);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', NULL, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'width_mm',      'https://animalspedal.us/products/animals-pedal-major-overdrive', 'manufacturer_website', '64mm',    'High', '2026-04-08'),
    (currval('products_id_seq'), 'products', 'depth_mm',      'https://animalspedal.us/products/animals-pedal-major-overdrive', 'manufacturer_website', '112mm',   'High', '2026-04-08'),
    (currval('products_id_seq'), 'products', 'height_mm',     'https://animalspedal.us/products/animals-pedal-major-overdrive', 'manufacturer_website', '50mm',    'High', '2026-04-08'),
    (currval('products_id_seq'), 'products', 'weight_grams',  'https://animalspedal.us/products/animals-pedal-major-overdrive', 'manufacturer_website', '378g',    'High', '2026-04-08'),
    (currval('products_id_seq'), 'products', 'msrp_cents',    'https://animalspedal.us/products/animals-pedal-major-overdrive', 'manufacturer_website', '$138.99', 'High', '2026-04-08'),
    (currval('products_id_seq'), 'pedal_details', 'effect_type',  'https://animalspedal.us/products/animals-pedal-major-overdrive', 'manufacturer_website', 'Overdrive',   'High', '2026-04-08'),
    (currval('products_id_seq'), 'pedal_details', 'bypass_type',  'https://animalspedal.us/products/animals-pedal-major-overdrive', 'manufacturer_website', 'True Bypass', 'High', '2026-04-08');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 13. PUSH & PULL DISTORTION
-- Very low draw (0.5mA) rounded to 1mA.
-- ============================================================
INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    msrp_cents, product_page,
    description, data_reliability
) VALUES (
    19, 1, 'Push & Pull Distortion',
    TRUE,
    64.0, 112.0, 50.0, 381,
    12899, 'https://animalspedal.us/products/animals-pedal-push-pull-distortion',
    'Analog distortion with very low current draw.',
    'High'
);

INSERT INTO pedal_details (product_id, effect_type, signal_type, bypass_type, mono_stereo, battery_capable)
VALUES (currval('products_id_seq'), 'Gain', 'Analog', 'True Bypass', 'Mono', TRUE);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', 1, 'Center Negative');

INSERT INTO product_sources (product_id, table_name, field_name, jack_id, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES (currval('products_id_seq'), 'jacks', 'current_ma', currval('jacks_id_seq'),
        'https://animalspedal.us/products/animals-pedal-push-pull-distortion',
        'manufacturer_website', '0.5mA', 'High', '2026-04-08');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'width_mm',      'https://animalspedal.us/products/animals-pedal-push-pull-distortion', 'manufacturer_website', '64mm',    'High', '2026-04-08'),
    (currval('products_id_seq'), 'products', 'depth_mm',      'https://animalspedal.us/products/animals-pedal-push-pull-distortion', 'manufacturer_website', '112mm',   'High', '2026-04-08'),
    (currval('products_id_seq'), 'products', 'height_mm',     'https://animalspedal.us/products/animals-pedal-push-pull-distortion', 'manufacturer_website', '50mm',    'High', '2026-04-08'),
    (currval('products_id_seq'), 'products', 'weight_grams',  'https://animalspedal.us/products/animals-pedal-push-pull-distortion', 'manufacturer_website', '381g',    'High', '2026-04-08'),
    (currval('products_id_seq'), 'products', 'msrp_cents',    'https://animalspedal.us/products/animals-pedal-push-pull-distortion', 'manufacturer_website', '$128.99', 'High', '2026-04-08'),
    (currval('products_id_seq'), 'pedal_details', 'effect_type',  'https://animalspedal.us/products/animals-pedal-push-pull-distortion', 'manufacturer_website', 'Distortion',  'High', '2026-04-08'),
    (currval('products_id_seq'), 'pedal_details', 'bypass_type',  'https://animalspedal.us/products/animals-pedal-push-pull-distortion', 'manufacturer_website', 'True Bypass', 'High', '2026-04-08');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 14. RELAXING WALRUS DELAY
-- Digital delay; 35mA confirms DSP. Delay range: 1–500ms.
-- ============================================================
INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    msrp_cents, product_page,
    description, data_reliability
) VALUES (
    19, 1, 'Relaxing Walrus Delay',
    TRUE,
    64.0, 112.0, 50.0, 379,
    11899, 'https://animalspedal.us/products/animals-pedal-relaxing-walrus-delay',
    'Digital delay with 1–500ms range.',
    'High'
);

INSERT INTO pedal_details (product_id, effect_type, signal_type, bypass_type, mono_stereo, battery_capable)
VALUES (currval('products_id_seq'), 'Delay', 'Digital', 'True Bypass', 'Mono', TRUE);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', 35, 'Center Negative');

INSERT INTO product_sources (product_id, table_name, field_name, jack_id, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES (currval('products_id_seq'), 'jacks', 'current_ma', currval('jacks_id_seq'),
        'https://animalspedal.us/products/animals-pedal-relaxing-walrus-delay',
        'manufacturer_website', '35mA', 'High', '2026-04-08');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'width_mm',      'https://animalspedal.us/products/animals-pedal-relaxing-walrus-delay', 'manufacturer_website', '64mm',    'High', '2026-04-08'),
    (currval('products_id_seq'), 'products', 'depth_mm',      'https://animalspedal.us/products/animals-pedal-relaxing-walrus-delay', 'manufacturer_website', '112mm',   'High', '2026-04-08'),
    (currval('products_id_seq'), 'products', 'height_mm',     'https://animalspedal.us/products/animals-pedal-relaxing-walrus-delay', 'manufacturer_website', '50mm',    'High', '2026-04-08'),
    (currval('products_id_seq'), 'products', 'weight_grams',  'https://animalspedal.us/products/animals-pedal-relaxing-walrus-delay', 'manufacturer_website', '379g',    'High', '2026-04-08'),
    (currval('products_id_seq'), 'products', 'msrp_cents',    'https://animalspedal.us/products/animals-pedal-relaxing-walrus-delay', 'manufacturer_website', '$118.99', 'High', '2026-04-08'),
    (currval('products_id_seq'), 'pedal_details', 'effect_type',  'https://animalspedal.us/products/animals-pedal-relaxing-walrus-delay', 'manufacturer_website', 'Delay',       'High', '2026-04-08'),
    (currval('products_id_seq'), 'pedal_details', 'bypass_type',  'https://animalspedal.us/products/animals-pedal-relaxing-walrus-delay', 'manufacturer_website', 'True Bypass', 'High', '2026-04-08');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 15. ROVER FUZZ
-- Skreddy Pedals collaboration. Current draw not found — NULL.
-- ============================================================
INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    msrp_cents, product_page,
    description, data_reliability, notes
) VALUES (
    19, 1, 'Rover Fuzz',
    TRUE,
    64.0, 112.0, 50.0, 375,
    13899, 'https://animalspedal.us/products/animals-pedal-rover-fuzz',
    'Analog fuzz; a Skreddy Pedals collaboration.',
    'High',
    'Collaboration with Skreddy Pedals (Marc Ahlfs). Current draw not documented on product page.'
);

INSERT INTO pedal_details (product_id, effect_type, signal_type, bypass_type, mono_stereo, battery_capable)
VALUES (currval('products_id_seq'), 'Fuzz', 'Analog', 'True Bypass', 'Mono', TRUE);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', NULL, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'width_mm',      'https://animalspedal.us/products/animals-pedal-rover-fuzz', 'manufacturer_website', '64mm',    'High', '2026-04-08'),
    (currval('products_id_seq'), 'products', 'depth_mm',      'https://animalspedal.us/products/animals-pedal-rover-fuzz', 'manufacturer_website', '112mm',   'High', '2026-04-08'),
    (currval('products_id_seq'), 'products', 'height_mm',     'https://animalspedal.us/products/animals-pedal-rover-fuzz', 'manufacturer_website', '50mm',    'High', '2026-04-08'),
    (currval('products_id_seq'), 'products', 'weight_grams',  'https://animalspedal.us/products/animals-pedal-rover-fuzz', 'manufacturer_website', '375g',    'High', '2026-04-08'),
    (currval('products_id_seq'), 'products', 'msrp_cents',    'https://animalspedal.us/products/animals-pedal-rover-fuzz', 'manufacturer_website', '$138.99', 'High', '2026-04-08'),
    (currval('products_id_seq'), 'pedal_details', 'effect_type',  'https://animalspedal.us/products/animals-pedal-rover-fuzz', 'manufacturer_website', 'Fuzz',        'High', '2026-04-08'),
    (currval('products_id_seq'), 'pedal_details', 'bypass_type',  'https://animalspedal.us/products/animals-pedal-rover-fuzz', 'manufacturer_website', 'True Bypass', 'High', '2026-04-08');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 16. RUST ROD FUZZ
-- Ram's Head Big Muff variant; Skreddy Pedals collaboration.
-- Current draw not found — NULL.
-- ============================================================
INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    msrp_cents, product_page,
    description, data_reliability, notes
) VALUES (
    19, 1, 'Rust Rod Fuzz',
    TRUE,
    64.0, 112.0, 50.0, 376,
    13899, 'https://animalspedal.us/products/animals-pedal-rust-rod-fuzz',
    'Ram''s Head Big Muff-variant fuzz; a Skreddy Pedals collaboration.',
    'High',
    'Collaboration with Skreddy Pedals (Marc Ahlfs). Ram''s Head Big Muff variant. Current draw not documented on product page.'
);

INSERT INTO pedal_details (product_id, effect_type, circuit_type, signal_type, bypass_type, mono_stereo, battery_capable)
VALUES (currval('products_id_seq'), 'Fuzz', 'Big Muff', 'Analog', 'True Bypass', 'Mono', TRUE);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', NULL, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'width_mm',      'https://animalspedal.us/products/animals-pedal-rust-rod-fuzz', 'manufacturer_website', '64mm',    'High', '2026-04-08'),
    (currval('products_id_seq'), 'products', 'depth_mm',      'https://animalspedal.us/products/animals-pedal-rust-rod-fuzz', 'manufacturer_website', '112mm',   'High', '2026-04-08'),
    (currval('products_id_seq'), 'products', 'height_mm',     'https://animalspedal.us/products/animals-pedal-rust-rod-fuzz', 'manufacturer_website', '50mm',    'High', '2026-04-08'),
    (currval('products_id_seq'), 'products', 'weight_grams',  'https://animalspedal.us/products/animals-pedal-rust-rod-fuzz', 'manufacturer_website', '376g',    'High', '2026-04-08'),
    (currval('products_id_seq'), 'products', 'msrp_cents',    'https://animalspedal.us/products/animals-pedal-rust-rod-fuzz', 'manufacturer_website', '$138.99', 'High', '2026-04-08'),
    (currval('products_id_seq'), 'pedal_details', 'effect_type',  'https://animalspedal.us/products/animals-pedal-rust-rod-fuzz', 'manufacturer_website', 'Fuzz',        'High', '2026-04-08'),
    (currval('products_id_seq'), 'pedal_details', 'bypass_type',  'https://animalspedal.us/products/animals-pedal-rust-rod-fuzz', 'manufacturer_website', 'True Bypass', 'High', '2026-04-08');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 17. SUNDAY AFTERNOON IS INFINITY BENDER
-- Vintage-style analog fuzz.
-- ============================================================
INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    msrp_cents, product_page,
    description, data_reliability
) VALUES (
    19, 1, 'Sunday Afternoon Is Infinity Bender',
    TRUE,
    64.0, 112.0, 50.0, 378,
    12899, 'https://animalspedal.us/products/animals-pedal-sunday-afternoon-is-infinity-bender',
    'Vintage-style analog fuzz.',
    'High'
);

INSERT INTO pedal_details (product_id, effect_type, signal_type, bypass_type, mono_stereo, battery_capable)
VALUES (currval('products_id_seq'), 'Fuzz', 'Analog', 'True Bypass', 'Mono', TRUE);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', 1, 'Center Negative');

INSERT INTO product_sources (product_id, table_name, field_name, jack_id, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES (currval('products_id_seq'), 'jacks', 'current_ma', currval('jacks_id_seq'),
        'https://animalspedal.us/products/animals-pedal-sunday-afternoon-is-infinity-bender',
        'manufacturer_website', '1mA', 'High', '2026-04-08');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'width_mm',      'https://animalspedal.us/products/animals-pedal-sunday-afternoon-is-infinity-bender', 'manufacturer_website', '64mm',    'High', '2026-04-08'),
    (currval('products_id_seq'), 'products', 'depth_mm',      'https://animalspedal.us/products/animals-pedal-sunday-afternoon-is-infinity-bender', 'manufacturer_website', '112mm',   'High', '2026-04-08'),
    (currval('products_id_seq'), 'products', 'height_mm',     'https://animalspedal.us/products/animals-pedal-sunday-afternoon-is-infinity-bender', 'manufacturer_website', '50mm',    'High', '2026-04-08'),
    (currval('products_id_seq'), 'products', 'weight_grams',  'https://animalspedal.us/products/animals-pedal-sunday-afternoon-is-infinity-bender', 'manufacturer_website', '378g',    'High', '2026-04-08'),
    (currval('products_id_seq'), 'products', 'msrp_cents',    'https://animalspedal.us/products/animals-pedal-sunday-afternoon-is-infinity-bender', 'manufacturer_website', '$128.99', 'High', '2026-04-08'),
    (currval('products_id_seq'), 'pedal_details', 'effect_type',  'https://animalspedal.us/products/animals-pedal-sunday-afternoon-is-infinity-bender', 'manufacturer_website', 'Fuzz',        'High', '2026-04-08'),
    (currval('products_id_seq'), 'pedal_details', 'bypass_type',  'https://animalspedal.us/products/animals-pedal-sunday-afternoon-is-infinity-bender', 'manufacturer_website', 'True Bypass', 'High', '2026-04-08');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 18. SURFING BEAR OVERDRIVE
-- 808-style analog overdrive.
-- ============================================================
INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    msrp_cents, product_page,
    description, data_reliability
) VALUES (
    19, 1, 'Surfing Bear Overdrive',
    TRUE,
    64.0, 112.0, 50.0, 382,
    11899, 'https://animalspedal.us/products/animals-pedal-surfing-bear-overdrive',
    '808-style analog overdrive.',
    'High'
);

INSERT INTO pedal_details (product_id, effect_type, circuit_type, signal_type, bypass_type, mono_stereo, battery_capable)
VALUES (currval('products_id_seq'), 'Gain', 'Tube Screamer', 'Analog', 'True Bypass', 'Mono', TRUE);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', 15, 'Center Negative');

INSERT INTO product_sources (product_id, table_name, field_name, jack_id, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES (currval('products_id_seq'), 'jacks', 'current_ma', currval('jacks_id_seq'),
        'https://animalspedal.us/products/animals-pedal-surfing-bear-overdrive',
        'manufacturer_website', '15mA', 'High', '2026-04-08');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'width_mm',      'https://animalspedal.us/products/animals-pedal-surfing-bear-overdrive', 'manufacturer_website', '64mm',    'High', '2026-04-08'),
    (currval('products_id_seq'), 'products', 'depth_mm',      'https://animalspedal.us/products/animals-pedal-surfing-bear-overdrive', 'manufacturer_website', '112mm',   'High', '2026-04-08'),
    (currval('products_id_seq'), 'products', 'height_mm',     'https://animalspedal.us/products/animals-pedal-surfing-bear-overdrive', 'manufacturer_website', '50mm',    'High', '2026-04-08'),
    (currval('products_id_seq'), 'products', 'weight_grams',  'https://animalspedal.us/products/animals-pedal-surfing-bear-overdrive', 'manufacturer_website', '382g',    'High', '2026-04-08'),
    (currval('products_id_seq'), 'products', 'msrp_cents',    'https://animalspedal.us/products/animals-pedal-surfing-bear-overdrive', 'manufacturer_website', '$118.99', 'High', '2026-04-08'),
    (currval('products_id_seq'), 'pedal_details', 'effect_type',  'https://animalspedal.us/products/animals-pedal-surfing-bear-overdrive', 'manufacturer_website', 'Overdrive',   'High', '2026-04-08'),
    (currval('products_id_seq'), 'pedal_details', 'bypass_type',  'https://animalspedal.us/products/animals-pedal-surfing-bear-overdrive', 'manufacturer_website', 'True Bypass', 'High', '2026-04-08');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 19. SURFING POLAR BEAR BASS OVERDRIVE (BJF MOD)
-- Bass-voiced OD modified by BJFe (Björn Juhl).
-- Distinct impedance from standard Surfing Bear — separate product entry.
-- ============================================================
INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    msrp_cents, product_page,
    description, data_reliability, notes
) VALUES (
    19, 1, 'Surfing Polar Bear Bass Overdrive (BJF Mod)',
    TRUE,
    64.0, 112.0, 50.0, 383,
    13899, 'https://animalspedal.us/products/animals-pedal-surfing-polar-bear-bass-overdrive-mod-by-bjf',
    'Bass-voiced analog overdrive modified by BJFe (Björn Juhl).',
    'High',
    'Collaboration with BJFe (Björn Juhl). Bass-specific voicing with different impedance from standard Surfing Bear OD.'
);

INSERT INTO pedal_details (product_id, effect_type, signal_type, bypass_type, mono_stereo, battery_capable)
VALUES (currval('products_id_seq'), 'Gain', 'Analog', 'True Bypass', 'Mono', TRUE);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', 4, 'Center Negative');

INSERT INTO product_sources (product_id, table_name, field_name, jack_id, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES (currval('products_id_seq'), 'jacks', 'current_ma', currval('jacks_id_seq'),
        'https://animalspedal.us/products/animals-pedal-surfing-polar-bear-bass-overdrive-mod-by-bjf',
        'manufacturer_website', '4mA', 'High', '2026-04-08');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'width_mm',      'https://animalspedal.us/products/animals-pedal-surfing-polar-bear-bass-overdrive-mod-by-bjf', 'manufacturer_website', '64mm',    'High', '2026-04-08'),
    (currval('products_id_seq'), 'products', 'depth_mm',      'https://animalspedal.us/products/animals-pedal-surfing-polar-bear-bass-overdrive-mod-by-bjf', 'manufacturer_website', '112mm',   'High', '2026-04-08'),
    (currval('products_id_seq'), 'products', 'height_mm',     'https://animalspedal.us/products/animals-pedal-surfing-polar-bear-bass-overdrive-mod-by-bjf', 'manufacturer_website', '50mm',    'High', '2026-04-08'),
    (currval('products_id_seq'), 'products', 'weight_grams',  'https://animalspedal.us/products/animals-pedal-surfing-polar-bear-bass-overdrive-mod-by-bjf', 'manufacturer_website', '383g',    'High', '2026-04-08'),
    (currval('products_id_seq'), 'products', 'msrp_cents',    'https://animalspedal.us/products/animals-pedal-surfing-polar-bear-bass-overdrive-mod-by-bjf', 'manufacturer_website', '$138.99', 'High', '2026-04-08'),
    (currval('products_id_seq'), 'pedal_details', 'effect_type',  'https://animalspedal.us/products/animals-pedal-surfing-polar-bear-bass-overdrive-mod-by-bjf', 'manufacturer_website', 'Overdrive',   'High', '2026-04-08'),
    (currval('products_id_seq'), 'pedal_details', 'bypass_type',  'https://animalspedal.us/products/animals-pedal-surfing-polar-bear-bass-overdrive-mod-by-bjf', 'manufacturer_website', 'True Bypass', 'High', '2026-04-08');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 20. TIOGA ROAD CYCLING DISTORTION
-- 3-mode clipping selection.
-- ============================================================
INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    msrp_cents, product_page,
    description, data_reliability
) VALUES (
    19, 1, 'Tioga Road Cycling Distortion',
    TRUE,
    64.0, 112.0, 50.0, 385,
    13899, 'https://animalspedal.us/products/animals-pedal-tioga-road-cycling-distortion',
    'Analog distortion with three selectable clipping modes.',
    'High'
);

INSERT INTO pedal_details (product_id, effect_type, signal_type, bypass_type, mono_stereo, battery_capable)
VALUES (currval('products_id_seq'), 'Gain', 'Analog', 'True Bypass', 'Mono', TRUE);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', 1, 'Center Negative');

INSERT INTO product_sources (product_id, table_name, field_name, jack_id, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES (currval('products_id_seq'), 'jacks', 'current_ma', currval('jacks_id_seq'),
        'https://animalspedal.us/products/animals-pedal-tioga-road-cycling-distortion',
        'manufacturer_website', '1mA', 'High', '2026-04-08');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'width_mm',      'https://animalspedal.us/products/animals-pedal-tioga-road-cycling-distortion', 'manufacturer_website', '64mm',    'High', '2026-04-08'),
    (currval('products_id_seq'), 'products', 'depth_mm',      'https://animalspedal.us/products/animals-pedal-tioga-road-cycling-distortion', 'manufacturer_website', '112mm',   'High', '2026-04-08'),
    (currval('products_id_seq'), 'products', 'height_mm',     'https://animalspedal.us/products/animals-pedal-tioga-road-cycling-distortion', 'manufacturer_website', '50mm',    'High', '2026-04-08'),
    (currval('products_id_seq'), 'products', 'weight_grams',  'https://animalspedal.us/products/animals-pedal-tioga-road-cycling-distortion', 'manufacturer_website', '385g',    'High', '2026-04-08'),
    (currval('products_id_seq'), 'products', 'msrp_cents',    'https://animalspedal.us/products/animals-pedal-tioga-road-cycling-distortion', 'manufacturer_website', '$138.99', 'High', '2026-04-08'),
    (currval('products_id_seq'), 'pedal_details', 'effect_type',  'https://animalspedal.us/products/animals-pedal-tioga-road-cycling-distortion', 'manufacturer_website', 'Distortion',  'High', '2026-04-08'),
    (currval('products_id_seq'), 'pedal_details', 'bypass_type',  'https://animalspedal.us/products/animals-pedal-tioga-road-cycling-distortion', 'manufacturer_website', 'True Bypass', 'High', '2026-04-08');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 21. VINTAGE VAN DRIVING IS VERY FUN
-- OD with switchable boost mode.
-- ============================================================
INSERT INTO products (
    manufacturer_id, product_type_id, model,
    in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    msrp_cents, product_page,
    description, data_reliability
) VALUES (
    19, 1, 'Vintage Van Driving is Very Fun',
    TRUE,
    64.0, 112.0, 50.0, 381,
    12899, 'https://animalspedal.us/products/animals-pedal-vintage-van-driving-is-very-fun',
    'Analog overdrive with a switchable boost mode.',
    'High'
);

INSERT INTO pedal_details (product_id, effect_type, signal_type, bypass_type, mono_stereo, battery_capable)
VALUES (currval('products_id_seq'), 'Gain', 'Analog', 'True Bypass', 'Mono', TRUE);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', 6, 'Center Negative');

INSERT INTO product_sources (product_id, table_name, field_name, jack_id, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES (currval('products_id_seq'), 'jacks', 'current_ma', currval('jacks_id_seq'),
        'https://animalspedal.us/products/animals-pedal-vintage-van-driving-is-very-fun',
        'manufacturer_website', '6mA', 'High', '2026-04-08');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'width_mm',      'https://animalspedal.us/products/animals-pedal-vintage-van-driving-is-very-fun', 'manufacturer_website', '64mm',    'High', '2026-04-08'),
    (currval('products_id_seq'), 'products', 'depth_mm',      'https://animalspedal.us/products/animals-pedal-vintage-van-driving-is-very-fun', 'manufacturer_website', '112mm',   'High', '2026-04-08'),
    (currval('products_id_seq'), 'products', 'height_mm',     'https://animalspedal.us/products/animals-pedal-vintage-van-driving-is-very-fun', 'manufacturer_website', '50mm',    'High', '2026-04-08'),
    (currval('products_id_seq'), 'products', 'weight_grams',  'https://animalspedal.us/products/animals-pedal-vintage-van-driving-is-very-fun', 'manufacturer_website', '381g',    'High', '2026-04-08'),
    (currval('products_id_seq'), 'products', 'msrp_cents',    'https://animalspedal.us/products/animals-pedal-vintage-van-driving-is-very-fun', 'manufacturer_website', '$128.99', 'High', '2026-04-08'),
    (currval('products_id_seq'), 'pedal_details', 'effect_type',  'https://animalspedal.us/products/animals-pedal-vintage-van-driving-is-very-fun', 'manufacturer_website', 'Overdrive',   'High', '2026-04-08'),
    (currval('products_id_seq'), 'pedal_details', 'bypass_type',  'https://animalspedal.us/products/animals-pedal-vintage-van-driving-is-very-fun', 'manufacturer_website', 'True Bypass', 'High', '2026-04-08');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

COMMIT;
