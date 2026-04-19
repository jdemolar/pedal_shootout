-- Migration 029: Add Arion products (Manufacturer ID 22) — 32 products
-- Arion (Ueno Kaihatsu Center Ltd.), Sri Lanka/Japan. Founded 1973.
-- Original MIJ models (Prince Tsushinkogyo, 1980s–90s) are discontinued.
-- Sri Lankan reissues (SCH-Z, SCH-ZD) and HU-8500 tuner are current production.
-- SOD-1 and MDI-2 marked discontinued (Medium reliability — Godlyke may carry stock).
--
-- Bypass type: NOT inserted for vintage models — not confirmed by primary sources.
-- MSRP: NULL for all models — no confirmed retail prices found in any source.
-- Bypass and signal routing for stereo pedals inferred from product type (Medium reliability).
--
-- Standard vintage enclosure: 73mm W × 127mm D × 50mm H (confirmed for SCH-1, SPH-1, SOD-1, MCH-2, SCH-ZD).
--
-- Products:
--   Classic analog stereo (discontinued): SCH-1, SAD-1, SFL-1, SPH-1, SRV-1, SOD-1, SAD-3, SFC-1
--   Current analog stereo: SCH-Z, SCH-ZD
--   Gain/distortion (discontinued): SDI-1, MTE-1, MMP-1, SMM-1, MDS-1, DMD-1, MDI-1, MDI-2
--   Modulation (discontinued): MCH-2, MFL-2, SCO-1
--   Filter/EQ (discontinued): SPE-1, MEQ-1, MEQ-2
--   Pitch (discontinued): MOC-1
--   Digital effects (discontinued): DDM-1, DDS-1, DDS-4, DRS-1, DCF-1
--   Utility/tuners: HU-8500 (current), HU-8400 (discontinued)

BEGIN;

-- ============================================================
-- 1. SCH-1 STEREO CHORUS
-- Flagship vintage MIJ analog chorus. MN3207 BBD chip.
-- Most sought-after Arion model; gray-box MIJ versions preferred.
-- ============================================================
INSERT INTO products (manufacturer_id, product_type_id, model, in_production, width_mm, depth_mm, height_mm, weight_grams, msrp_cents, product_page, data_reliability)
VALUES (22, 1, 'SCH-1 Stereo Chorus', FALSE, 73.0, 127.0, 50.0, 330, NULL, NULL, 'Medium');

INSERT INTO pedal_details (product_id, effect_type, signal_type, bypass_type, mono_stereo)
VALUES (currval('products_id_seq'), 'Chorus', 'Analog', NULL, 'Mono In/Stereo Out');

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', 16, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Output 1');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Output 2');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'width_mm',     'https://www.effectsdatabase.com/model/arion/sch1', 'community_database', '73mm',  'Medium', '2026-04-18'),
    (currval('products_id_seq'), 'products', 'depth_mm',     'https://www.effectsdatabase.com/model/arion/sch1', 'community_database', '127mm', 'Medium', '2026-04-18'),
    (currval('products_id_seq'), 'products', 'height_mm',    'https://www.effectsdatabase.com/model/arion/sch1', 'community_database', '50mm',  'Medium', '2026-04-18'),
    (currval('products_id_seq'), 'products', 'weight_grams', 'https://www.effectsdatabase.com/model/arion/sch1', 'community_database', '330g',  'Medium', '2026-04-18');

INSERT INTO product_sources (product_id, table_name, field_name, jack_id, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES (currval('products_id_seq'), 'jacks', 'current_ma', currval('jacks_id_seq') - 3, 'https://www.effectsdatabase.com/model/arion/sch1', 'community_database', '16mA', 'Medium', '2026-04-18');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 2. SAD-1 STEREO ANALOG DELAY
-- BBD-based analog delay (MN3025 chip, 4096-stage).
-- Delay range: 50–300ms. S/N ratio 67dB.
-- ============================================================
INSERT INTO products (manufacturer_id, product_type_id, model, in_production, width_mm, depth_mm, height_mm, weight_grams, msrp_cents, product_page, data_reliability)
VALUES (22, 1, 'SAD-1 Stereo Analog Delay', FALSE, NULL, NULL, NULL, NULL, NULL, NULL, 'Medium');

INSERT INTO pedal_details (product_id, effect_type, signal_type, bypass_type, mono_stereo)
VALUES (currval('products_id_seq'), 'Delay', 'Analog', NULL, 'Mono In/Stereo Out');

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', NULL, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Output 1');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Output 2');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES (currval('products_id_seq'), 'pedal_details', 'effect_type', 'https://www.effectsdatabase.com/model/arion/sad1', 'community_database', 'Analog Delay', 'Medium', '2026-04-18');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 3. SFL-1 STEREO FLANGER
-- Analog stereo flanger. Direct/Stereo output switch.
-- Supports 9V and 12V.
-- ============================================================
INSERT INTO products (manufacturer_id, product_type_id, model, in_production, width_mm, depth_mm, height_mm, weight_grams, msrp_cents, product_page, data_reliability)
VALUES (22, 1, 'SFL-1 Stereo Flanger', FALSE, NULL, NULL, NULL, NULL, NULL, NULL, 'Medium');

INSERT INTO pedal_details (product_id, effect_type, signal_type, bypass_type, mono_stereo)
VALUES (currval('products_id_seq'), 'Flanger', 'Analog', NULL, 'Mono In/Stereo Out');

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', 16, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Output 1');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Output 2');

INSERT INTO product_sources (product_id, table_name, field_name, jack_id, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES (currval('products_id_seq'), 'jacks', 'current_ma', currval('jacks_id_seq') - 3, 'https://www.effectsdatabase.com/model/arion/sfl1', 'community_database', '16mA', 'Medium', '2026-04-18');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 4. SPH-1 STEREO PHASER
-- 4-stage analog phaser (720° phase shift). Switchable mono/stereo.
-- Official Arion page confirmed.
-- ============================================================
INSERT INTO products (manufacturer_id, product_type_id, model, in_production, width_mm, depth_mm, height_mm, weight_grams, msrp_cents, product_page, data_reliability)
VALUES (22, 1, 'SPH-1 Stereo Phaser', FALSE, 73.0, 127.0, 50.0, 325, NULL, 'http://arion-ukc.co.jp/en/effects/sph-1', 'High');

INSERT INTO pedal_details (product_id, effect_type, signal_type, bypass_type, mono_stereo)
VALUES (currval('products_id_seq'), 'Phaser', 'Analog', NULL, 'Mono In/Stereo Out');

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', 17, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Output 1');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Output 2');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'width_mm',     'http://arion-ukc.co.jp/en/effects/sph-1', 'manufacturer_website', '73mm',  'High', '2026-04-18'),
    (currval('products_id_seq'), 'products', 'depth_mm',     'http://arion-ukc.co.jp/en/effects/sph-1', 'manufacturer_website', '127mm', 'High', '2026-04-18'),
    (currval('products_id_seq'), 'products', 'height_mm',    'http://arion-ukc.co.jp/en/effects/sph-1', 'manufacturer_website', '50mm',  'High', '2026-04-18'),
    (currval('products_id_seq'), 'products', 'weight_grams', 'http://arion-ukc.co.jp/en/effects/sph-1', 'manufacturer_website', '325g',  'High', '2026-04-18');

INSERT INTO product_sources (product_id, table_name, field_name, jack_id, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES (currval('products_id_seq'), 'jacks', 'current_ma', currval('jacks_id_seq') - 3, 'http://arion-ukc.co.jp/en/effects/sph-1', 'manufacturer_website', '17mA', 'High', '2026-04-18');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 5. SRV-1 STEREO REVERB
-- All-analog reverb using MN3011 BBD chip. 4 controls.
-- ============================================================
INSERT INTO products (manufacturer_id, product_type_id, model, in_production, width_mm, depth_mm, height_mm, weight_grams, msrp_cents, product_page, data_reliability)
VALUES (22, 1, 'SRV-1 Stereo Reverb', FALSE, NULL, NULL, NULL, NULL, NULL, NULL, 'Medium');

INSERT INTO pedal_details (product_id, effect_type, signal_type, bypass_type, mono_stereo)
VALUES (currval('products_id_seq'), 'Reverb', 'Analog', NULL, 'Mono In/Stereo Out');

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', NULL, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Output 1');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Output 2');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES (currval('products_id_seq'), 'pedal_details', 'effect_type', 'https://www.effectsdatabase.com/model/arion/srv1', 'community_database', 'Analog Reverb (BBD)', 'Medium', '2026-04-18');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 6. SOD-1 STEREO OVERDRIVE
-- Analog OD with Direct/Soft output switch. 6.5mA → 7mA (rounded).
-- Marked discontinued; Godlyke may carry stock (Medium reliability).
-- ============================================================
INSERT INTO products (manufacturer_id, product_type_id, model, in_production, width_mm, depth_mm, height_mm, weight_grams, msrp_cents, product_page, data_reliability, notes)
VALUES (22, 1, 'SOD-1 Stereo Overdrive', FALSE, 73.0, 127.0, 50.0, 313, NULL, NULL, 'Medium', 'Discontinued status Medium reliability — Godlyke Distributing may carry remaining stock.');

INSERT INTO pedal_details (product_id, effect_type, signal_type, bypass_type, mono_stereo)
VALUES (currval('products_id_seq'), 'Gain', 'Analog', NULL, 'Mono In/Stereo Out');

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', 7, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Direct');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Soft');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'width_mm',     'https://www.effectsdatabase.com/model/arion/sod1', 'community_database', '2.87 in', 'Medium', '2026-04-18'),
    (currval('products_id_seq'), 'products', 'depth_mm',     'https://www.effectsdatabase.com/model/arion/sod1', 'community_database', '5.0 in',  'Medium', '2026-04-18'),
    (currval('products_id_seq'), 'products', 'height_mm',    'https://www.effectsdatabase.com/model/arion/sod1', 'community_database', '1.97 in', 'Medium', '2026-04-18'),
    (currval('products_id_seq'), 'products', 'weight_grams', 'https://www.effectsdatabase.com/model/arion/sod1', 'community_database', '0.69 lbs', 'Medium', '2026-04-18');

INSERT INTO product_sources (product_id, table_name, field_name, jack_id, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES (currval('products_id_seq'), 'jacks', 'current_ma', currval('jacks_id_seq') - 3, 'https://www.effectsdatabase.com/model/arion/sod1', 'community_database', '6.5mA', 'Medium', '2026-04-18');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 7. SAD-3 STEREO ANALOG DELAY
-- Updated SAD-1 with noise reduction. Max delay 200ms (vs 300ms).
-- Width 73mm confirmed; full height not found.
-- ============================================================
INSERT INTO products (manufacturer_id, product_type_id, model, in_production, width_mm, depth_mm, height_mm, weight_grams, msrp_cents, product_page, data_reliability)
VALUES (22, 1, 'SAD-3 Stereo Analog Delay', FALSE, 73.0, 127.0, NULL, NULL, NULL, NULL, 'Medium');

INSERT INTO pedal_details (product_id, effect_type, signal_type, bypass_type, mono_stereo)
VALUES (currval('products_id_seq'), 'Delay', 'Analog', NULL, 'Mono In/Stereo Out');

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', 14, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Output 1');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Output 2');

INSERT INTO product_sources (product_id, table_name, field_name, jack_id, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES (currval('products_id_seq'), 'jacks', 'current_ma', currval('jacks_id_seq') - 3, 'https://www.effectsdatabase.com/model/arion/sad3', 'community_database', '14mA', 'Medium', '2026-04-18');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 8. SFC-1 STEREO FAT CHORUS
-- Analog stereo chorus, Japanese manufacture. Less documented
-- than SCH-1. "Fat" indicates fuller chorus character.
-- ============================================================
INSERT INTO products (manufacturer_id, product_type_id, model, in_production, width_mm, depth_mm, height_mm, weight_grams, msrp_cents, product_page, data_reliability)
VALUES (22, 1, 'SFC-1 Stereo Fat Chorus', FALSE, NULL, NULL, NULL, NULL, NULL, NULL, 'Low');

INSERT INTO pedal_details (product_id, effect_type, signal_type, bypass_type, mono_stereo)
VALUES (currval('products_id_seq'), 'Chorus', 'Analog', NULL, 'Mono In/Stereo Out');

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', NULL, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Output 1');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Output 2');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 9. SCH-Z STEREO CHORUS
-- Sri Lankan reissue of SCH-1. Tone knob boosts bass (vs. SCH-1
-- which cuts highs). Volume boost when engaged (fixed in SCH-ZD).
-- Current production.
-- ============================================================
INSERT INTO products (manufacturer_id, product_type_id, model, in_production, width_mm, depth_mm, height_mm, weight_grams, msrp_cents, product_page, data_reliability, notes)
VALUES (22, 1, 'SCH-Z Stereo Chorus', TRUE, NULL, NULL, NULL, NULL, NULL, NULL, 'Medium', 'Sri Lankan reissue of SCH-1. Tone knob boosts bass rather than cutting highs. Volume boost when engaged — addressed in SCH-ZD.');

INSERT INTO pedal_details (product_id, effect_type, signal_type, bypass_type, mono_stereo)
VALUES (currval('products_id_seq'), 'Chorus', 'Analog', NULL, 'Mono In/Stereo Out');

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', NULL, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Output 1');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Output 2');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES (currval('products_id_seq'), 'pedal_details', 'effect_type', 'https://www.effectsdatabase.com/model/arion/schz', 'community_database', 'Chorus', 'Medium', '2026-04-18');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 10. SCH-ZD STEREO CHORUS
-- Further refinement of SCH-Z. Removes volume boost on engagement.
-- More effective chorus on lower range. Current production.
-- ============================================================
INSERT INTO products (manufacturer_id, product_type_id, model, in_production, width_mm, depth_mm, height_mm, weight_grams, msrp_cents, product_page, data_reliability, notes)
VALUES (22, 1, 'SCH-ZD Stereo Chorus', TRUE, 73.0, 127.0, 50.0, 340, NULL, NULL, 'High', 'Refined SCH-Z: removes volume boost on engagement, more effective low-range chorus. Current production Sri Lanka.');

INSERT INTO pedal_details (product_id, effect_type, signal_type, bypass_type, mono_stereo)
VALUES (currval('products_id_seq'), 'Chorus', 'Analog', NULL, 'Mono In/Stereo Out');

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', 12, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Output 1');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Output 2');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'width_mm',     'http://arion-ukc.co.jp/en/effects', 'manufacturer_website', '73mm',  'High', '2026-04-18'),
    (currval('products_id_seq'), 'products', 'depth_mm',     'http://arion-ukc.co.jp/en/effects', 'manufacturer_website', '127mm', 'High', '2026-04-18'),
    (currval('products_id_seq'), 'products', 'height_mm',    'http://arion-ukc.co.jp/en/effects', 'manufacturer_website', '50mm',  'High', '2026-04-18'),
    (currval('products_id_seq'), 'products', 'weight_grams', 'http://arion-ukc.co.jp/en/effects', 'manufacturer_website', '340g',  'High', '2026-04-18');

INSERT INTO product_sources (product_id, table_name, field_name, jack_id, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES (currval('products_id_seq'), 'jacks', 'current_ma', currval('jacks_id_seq') - 3, 'http://arion-ukc.co.jp/en/effects', 'manufacturer_website', '12mA', 'High', '2026-04-18');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 11. SDI-1 STEREO DISTORTION
-- Direct/Soft output switch; output 2 switchable to dry.
-- ============================================================
INSERT INTO products (manufacturer_id, product_type_id, model, in_production, width_mm, depth_mm, height_mm, weight_grams, msrp_cents, product_page, data_reliability)
VALUES (22, 1, 'SDI-1 Stereo Distortion', FALSE, NULL, NULL, NULL, 330, NULL, NULL, 'Medium');

INSERT INTO pedal_details (product_id, effect_type, signal_type, bypass_type, mono_stereo)
VALUES (currval('products_id_seq'), 'Gain', 'Analog', NULL, 'Mono In/Stereo Out');

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', NULL, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Direct');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Soft');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES (currval('products_id_seq'), 'products', 'weight_grams', 'https://www.effectsdatabase.com/model/arion/sdi1', 'community_database', '330g', 'Medium', '2026-04-18');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 12. MTE-1 TUBULATOR
-- TS-808 Tubescreamer-type circuit. Less bass cut than standard TS.
-- Plastic housing. Well-regarded as budget TS alternative.
-- ============================================================
INSERT INTO products (manufacturer_id, product_type_id, model, in_production, width_mm, depth_mm, height_mm, weight_grams, msrp_cents, product_page, data_reliability)
VALUES (22, 1, 'MTE-1 Tubulator', FALSE, NULL, NULL, NULL, NULL, NULL, NULL, 'Medium');

INSERT INTO pedal_details (product_id, effect_type, circuit_type, signal_type, bypass_type, mono_stereo)
VALUES (currval('products_id_seq'), 'Gain', 'Tube Screamer', 'Analog', NULL, 'Mono');

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', NULL, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES (currval('products_id_seq'), 'pedal_details', 'circuit_type', 'https://www.effectsdatabase.com/model/arion/mte1', 'community_database', 'TS-808 style', 'Medium', '2026-04-18');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 13. MMP-1 METAL PLUS
-- Heavy distortion. NEC C157C metal can IC (≈LM301AN).
-- 3 controls: Level, EQ, Grind.
-- ============================================================
INSERT INTO products (manufacturer_id, product_type_id, model, in_production, width_mm, depth_mm, height_mm, weight_grams, msrp_cents, product_page, data_reliability)
VALUES (22, 1, 'MMP-1 Metal Plus', FALSE, NULL, NULL, NULL, NULL, NULL, NULL, 'Low');

INSERT INTO pedal_details (product_id, effect_type, signal_type, bypass_type, mono_stereo)
VALUES (currval('products_id_seq'), 'Gain', 'Analog', NULL, 'Mono');

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', NULL, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 14. SMM-1 STEREO METAL MASTER
-- High-gain distortion. HM-2-style circuit with stereo output.
-- Both MIJ and MISL versions exist.
-- ============================================================
INSERT INTO products (manufacturer_id, product_type_id, model, in_production, width_mm, depth_mm, height_mm, weight_grams, msrp_cents, product_page, data_reliability, notes)
VALUES (22, 1, 'SMM-1 Stereo Metal Master', FALSE, NULL, NULL, NULL, NULL, NULL, NULL, 'Low', 'Both MIJ (Japan) and MISL (Sri Lanka) versions exist with possible sonic differences.');

INSERT INTO pedal_details (product_id, effect_type, signal_type, bypass_type, mono_stereo)
VALUES (currval('products_id_seq'), 'Gain', 'Analog', NULL, 'Mono In/Stereo Out');

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', NULL, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Output 1');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Output 2');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 15. MDS-1 DISTORTION
-- Simple analog distortion. Early versions: silicon clipping;
-- later versions: LED clipping.
-- ============================================================
INSERT INTO products (manufacturer_id, product_type_id, model, in_production, width_mm, depth_mm, height_mm, weight_grams, msrp_cents, product_page, data_reliability)
VALUES (22, 1, 'MDS-1 Distortion', FALSE, NULL, NULL, NULL, NULL, NULL, NULL, 'Low');

INSERT INTO pedal_details (product_id, effect_type, signal_type, bypass_type, mono_stereo)
VALUES (currval('products_id_seq'), 'Gain', 'Analog', NULL, 'Mono');

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', NULL, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 16. DMD-1 DIGITAL METAL DISTORTION
-- Digital metal distortion. Very limited documentation.
-- ============================================================
INSERT INTO products (manufacturer_id, product_type_id, model, in_production, width_mm, depth_mm, height_mm, weight_grams, msrp_cents, product_page, data_reliability)
VALUES (22, 1, 'DMD-1 Digital Metal Distortion', FALSE, NULL, NULL, NULL, NULL, NULL, NULL, 'Low');

INSERT INTO pedal_details (product_id, effect_type, signal_type, bypass_type, mono_stereo)
VALUES (currval('products_id_seq'), 'Gain', 'Digital', NULL, 'Mono');

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', NULL, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 17. MDI-1 TUBE MANIA
-- Tube amp emulation distortion. Limited documentation.
-- ============================================================
INSERT INTO products (manufacturer_id, product_type_id, model, in_production, width_mm, depth_mm, height_mm, weight_grams, msrp_cents, product_page, data_reliability)
VALUES (22, 1, 'MDI-1 Tube Mania', FALSE, NULL, NULL, NULL, NULL, NULL, NULL, 'Low');

INSERT INTO pedal_details (product_id, effect_type, signal_type, bypass_type, mono_stereo)
VALUES (currval('products_id_seq'), 'Gain', 'Analog', NULL, 'Mono');

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', NULL, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 18. MDI-2 BASS DISTORTION
-- Bass distortion with separate dry/wet level controls.
-- Tone control affects wet signal only. Marked discontinued;
-- Godlyke may carry stock (Medium reliability).
-- ============================================================
INSERT INTO products (manufacturer_id, product_type_id, model, in_production, width_mm, depth_mm, height_mm, weight_grams, msrp_cents, product_page, data_reliability, notes)
VALUES (22, 1, 'MDI-2 Bass Distortion', FALSE, NULL, NULL, NULL, NULL, NULL, NULL, 'Medium', 'Discontinued status Medium reliability — Godlyke Distributing may carry remaining stock. Wet/dry blend via separate level controls; tone only affects wet signal.');

INSERT INTO pedal_details (product_id, effect_type, signal_type, bypass_type, mono_stereo)
VALUES (currval('products_id_seq'), 'Gain', 'Analog', NULL, 'Mono');

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', NULL, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 19. MCH-2 BASS CHORUS
-- Analog chorus optimized for bass. Preserves fundamental tone.
-- Full-time delay produces 2+ voices from single bass note.
-- ============================================================
INSERT INTO products (manufacturer_id, product_type_id, model, in_production, width_mm, depth_mm, height_mm, weight_grams, msrp_cents, product_page, data_reliability)
VALUES (22, 1, 'MCH-2 Bass Chorus', FALSE, 73.0, 127.0, 50.0, 310, NULL, NULL, 'High');

INSERT INTO pedal_details (product_id, effect_type, signal_type, bypass_type, mono_stereo)
VALUES (currval('products_id_seq'), 'Chorus', 'Analog', NULL, 'Mono');

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', 13, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products', 'width_mm',     'https://www.effectsdatabase.com/model/arion/mch2', 'community_database', '73mm',  'High', '2026-04-18'),
    (currval('products_id_seq'), 'products', 'depth_mm',     'https://www.effectsdatabase.com/model/arion/mch2', 'community_database', '127mm', 'High', '2026-04-18'),
    (currval('products_id_seq'), 'products', 'height_mm',    'https://www.effectsdatabase.com/model/arion/mch2', 'community_database', '50mm',  'High', '2026-04-18'),
    (currval('products_id_seq'), 'products', 'weight_grams', 'https://www.effectsdatabase.com/model/arion/mch2', 'community_database', '310g',  'High', '2026-04-18');

INSERT INTO product_sources (product_id, table_name, field_name, jack_id, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES (currval('products_id_seq'), 'jacks', 'current_ma', currval('jacks_id_seq') - 2, 'https://www.effectsdatabase.com/model/arion/mch2', 'community_database', '13mA', 'High', '2026-04-18');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 20. MFL-2 BASS FLANGER
-- Bass-specific flanger. Guitar counterpart is SFL-1.
-- Very limited documentation.
-- ============================================================
INSERT INTO products (manufacturer_id, product_type_id, model, in_production, width_mm, depth_mm, height_mm, weight_grams, msrp_cents, product_page, data_reliability)
VALUES (22, 1, 'MFL-2 Bass Flanger', FALSE, NULL, NULL, NULL, NULL, NULL, NULL, 'Low');

INSERT INTO pedal_details (product_id, effect_type, signal_type, bypass_type, mono_stereo)
VALUES (currval('products_id_seq'), 'Flanger', 'Analog', NULL, 'Mono');

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', NULL, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 21. SCO-1 STEREO COMPRESSOR
-- Stereo outputs: standard and "Mellow" (longer attack / direct).
-- Can function as limiter with Sustain at minimum.
-- ============================================================
INSERT INTO products (manufacturer_id, product_type_id, model, in_production, width_mm, depth_mm, height_mm, weight_grams, msrp_cents, product_page, data_reliability)
VALUES (22, 1, 'SCO-1 Stereo Compressor', FALSE, NULL, NULL, NULL, NULL, NULL, NULL, 'Medium');

INSERT INTO pedal_details (product_id, effect_type, signal_type, bypass_type, mono_stereo)
VALUES (currval('products_id_seq'), 'Compression', 'Analog', NULL, 'Mono In/Stereo Out');

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', NULL, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Output');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Mellow');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 22. SPE-1 STEREO PARAMETRIC EQ
-- Parametric EQ with compressor/sustain function. Very limited
-- documentation — frequency bands and control layout not found.
-- ============================================================
INSERT INTO products (manufacturer_id, product_type_id, model, in_production, width_mm, depth_mm, height_mm, weight_grams, msrp_cents, product_page, data_reliability)
VALUES (22, 1, 'SPE-1 Stereo Parametric EQ', FALSE, NULL, NULL, NULL, NULL, NULL, NULL, 'Low');

INSERT INTO pedal_details (product_id, effect_type, signal_type, bypass_type, mono_stereo)
VALUES (currval('products_id_seq'), 'Filter', 'Analog', NULL, 'Mono In/Stereo Out');

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', NULL, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Output 1');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Output 2');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 23. MEQ-1 EQUALIZER
-- 7-band graphic EQ for guitar: 100/200/400/800/1.6k/3.2k/6.4kHz.
-- ±15dB per band.
-- ============================================================
INSERT INTO products (manufacturer_id, product_type_id, model, in_production, width_mm, depth_mm, height_mm, weight_grams, msrp_cents, product_page, data_reliability)
VALUES (22, 1, 'MEQ-1 Equalizer', FALSE, NULL, NULL, NULL, NULL, NULL, NULL, 'Medium');

INSERT INTO pedal_details (product_id, effect_type, signal_type, bypass_type, mono_stereo)
VALUES (currval('products_id_seq'), 'Filter', 'Analog', NULL, 'Mono');

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', NULL, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 24. MEQ-2 BASS EQUALIZER
-- 7-band graphic EQ for bass: 40/80/150/300/600/1.2k/2.4kHz.
-- ±15dB per band.
-- ============================================================
INSERT INTO products (manufacturer_id, product_type_id, model, in_production, width_mm, depth_mm, height_mm, weight_grams, msrp_cents, product_page, data_reliability)
VALUES (22, 1, 'MEQ-2 Bass Equalizer', FALSE, NULL, NULL, NULL, NULL, NULL, NULL, 'Medium');

INSERT INTO pedal_details (product_id, effect_type, signal_type, bypass_type, mono_stereo)
VALUES (currval('products_id_seq'), 'Filter', 'Analog', NULL, 'Mono');

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', NULL, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 25. MOC-1 OCTAVE
-- Analog down-octave generator (-1 and -2 octaves).
-- Well-regarded tracking; input impedance 300kΩ, noise -70dB.
-- ============================================================
INSERT INTO products (manufacturer_id, product_type_id, model, in_production, width_mm, depth_mm, height_mm, weight_grams, msrp_cents, product_page, data_reliability)
VALUES (22, 1, 'MOC-1 Octave', FALSE, NULL, NULL, NULL, NULL, NULL, NULL, 'Medium');

INSERT INTO pedal_details (product_id, effect_type, signal_type, bypass_type, mono_stereo)
VALUES (currval('products_id_seq'), 'Pitch Shifter', 'Analog', NULL, 'Mono');

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', NULL, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES (currval('products_id_seq'), 'pedal_details', 'effect_type', 'https://www.effectsdatabase.com/model/arion/moc1', 'community_database', 'Octave (-1, -2)', 'Medium', '2026-04-18');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 26. DDM-1 DIGITAL DELAY
-- Early digital delay. Switchable Short (60–200ms) / Long
-- (120–400ms) modes. A/D/A conversion, freq response 40Hz–7kHz.
-- ============================================================
INSERT INTO products (manufacturer_id, product_type_id, model, in_production, width_mm, depth_mm, height_mm, weight_grams, msrp_cents, product_page, data_reliability)
VALUES (22, 1, 'DDM-1 Digital Delay', FALSE, NULL, NULL, NULL, NULL, NULL, NULL, 'Medium');

INSERT INTO pedal_details (product_id, effect_type, signal_type, bypass_type, mono_stereo)
VALUES (currval('products_id_seq'), 'Delay', 'Digital', NULL, 'Mono');

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', NULL, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 27. DDS-1 DIGITAL DELAY/SAMPLER
-- Digital delay with phrase sampler capability.
-- 6-position rotary mode switch for delay range selection.
-- ============================================================
INSERT INTO products (manufacturer_id, product_type_id, model, in_production, width_mm, depth_mm, height_mm, weight_grams, msrp_cents, product_page, data_reliability)
VALUES (22, 1, 'DDS-1 Digital Delay/Sampler', FALSE, NULL, NULL, NULL, NULL, NULL, NULL, 'Medium');

INSERT INTO pedal_details (product_id, effect_type, signal_type, bypass_type, mono_stereo)
VALUES (currval('products_id_seq'), 'Delay', 'Digital', NULL, 'Mono');

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', NULL, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 28. DDS-4 DIGITAL DELAY/SAMPLER
-- Presumed update/variant of DDS-1. Very limited documentation.
-- ============================================================
INSERT INTO products (manufacturer_id, product_type_id, model, in_production, width_mm, depth_mm, height_mm, weight_grams, msrp_cents, product_page, data_reliability)
VALUES (22, 1, 'DDS-4 Digital Delay/Sampler', FALSE, NULL, NULL, NULL, NULL, NULL, NULL, 'Low');

INSERT INTO pedal_details (product_id, effect_type, signal_type, bypass_type, mono_stereo)
VALUES (currval('products_id_seq'), 'Delay', 'Digital', NULL, 'Mono');

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', NULL, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 29. DRS-1 STEREO DIGITAL REVERB
-- Digital reverb with stereo output. Very limited documentation.
-- ============================================================
INSERT INTO products (manufacturer_id, product_type_id, model, in_production, width_mm, depth_mm, height_mm, weight_grams, msrp_cents, product_page, data_reliability)
VALUES (22, 1, 'DRS-1 Stereo Digital Reverb', FALSE, NULL, NULL, NULL, NULL, NULL, NULL, 'Low');

INSERT INTO pedal_details (product_id, effect_type, signal_type, bypass_type, mono_stereo)
VALUES (currval('products_id_seq'), 'Reverb', 'Digital', NULL, 'Mono In/Stereo Out');

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', NULL, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Output 1');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Output 2');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 30. DCF-1 DIGITAL CHORUS/FLANGER
-- Dual-mode digital effect: selectable Chorus or Flanger.
-- Classified as 'Other' — no single effect_type fits a
-- switchable dual-mode digital unit.
-- ============================================================
INSERT INTO products (manufacturer_id, product_type_id, model, in_production, width_mm, depth_mm, height_mm, weight_grams, msrp_cents, product_page, data_reliability)
VALUES (22, 1, 'DCF-1 Digital Chorus/Flanger', FALSE, NULL, NULL, NULL, NULL, NULL, NULL, 'Low');

INSERT INTO pedal_details (product_id, effect_type, signal_type, bypass_type, mono_stereo)
VALUES (currval('products_id_seq'), 'Other', 'Digital', NULL, 'Mono');

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', NULL, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 31. HU-8500 STAGE TUNER (UTILITY — current production)
-- Chromatic floor tuner. LED display visible from 6 feet.
-- Tuning accuracy ±1 cent. Calibration 440–445Hz in 1Hz steps.
-- ============================================================
INSERT INTO products (manufacturer_id, product_type_id, model, in_production, width_mm, depth_mm, height_mm, weight_grams, msrp_cents, product_page, data_reliability)
VALUES (22, 5, 'HU-8500 Stage Tuner', TRUE, 73.0, 127.0, 50.0, NULL, NULL, 'http://arion-ukc.co.jp/en/tuner/hu-8500', 'High');

INSERT INTO utility_details (
    product_id, utility_type, is_active, signal_type, bypass_type,
    has_ground_lift, has_pad, pad_db,
    tuning_display_type, tuning_accuracy_cents, polyphonic_tuning,
    sweep_type, has_tuner_out, has_minimum_volume, has_polarity_switch,
    power_handling_watts, has_reactive_load, has_attenuation, attenuation_range_db, has_cab_sim
) VALUES (
    currval('products_id_seq'), 'Tuner', TRUE, 'Analog', NULL,
    NULL, NULL, NULL,
    'LED', 1.0, FALSE,
    NULL, FALSE, FALSE, FALSE,
    NULL, FALSE, FALSE, NULL, FALSE
);

INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '2.1mm barrel', '9V', 40, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products',        'width_mm',             'http://arion-ukc.co.jp/en/tuner/hu-8500', 'manufacturer_website', '73mm',  'High', '2026-04-18'),
    (currval('products_id_seq'), 'products',        'depth_mm',             'http://arion-ukc.co.jp/en/tuner/hu-8500', 'manufacturer_website', '127mm', 'High', '2026-04-18'),
    (currval('products_id_seq'), 'products',        'height_mm',            'http://arion-ukc.co.jp/en/tuner/hu-8500', 'manufacturer_website', '50mm',  'High', '2026-04-18'),
    (currval('products_id_seq'), 'utility_details', 'tuning_accuracy_cents','http://arion-ukc.co.jp/en/tuner/hu-8500', 'manufacturer_website', '±1 cent', 'High', '2026-04-18'),
    (currval('products_id_seq'), 'utility_details', 'tuning_display_type',  'http://arion-ukc.co.jp/en/tuner/hu-8500', 'manufacturer_website', 'LED', 'High', '2026-04-18');

INSERT INTO product_sources (product_id, table_name, field_name, jack_id, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES (currval('products_id_seq'), 'jacks', 'current_ma', currval('jacks_id_seq') - 2, 'http://arion-ukc.co.jp/en/tuner/hu-8500', 'manufacturer_website', '40mA', 'High', '2026-04-18');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

-- ============================================================
-- 32. HU-8400 MICON CHROMATIC TUNER (UTILITY — discontinued)
-- Handheld tabletop chromatic tuner. Needle display.
-- Auto/manual mode. Not a floor pedal — no footswitch or power jack.
-- Range: C1 (32.7Hz) to B6 (1975.53Hz). Accuracy ±1 cent.
-- ============================================================
INSERT INTO products (manufacturer_id, product_type_id, model, in_production, width_mm, depth_mm, height_mm, weight_grams, msrp_cents, product_page, data_reliability, notes)
VALUES (22, 5, 'HU-8400 Micon Chromatic Tuner', FALSE, 145.0, 60.0, 33.0, 190, NULL, NULL, 'High', 'Handheld tabletop tuner — not a floor pedal. No footswitch, no power jack (9V battery). Auto/manual mode.');

INSERT INTO utility_details (
    product_id, utility_type, is_active, signal_type, bypass_type,
    has_ground_lift, has_pad, pad_db,
    tuning_display_type, tuning_accuracy_cents, polyphonic_tuning,
    sweep_type, has_tuner_out, has_minimum_volume, has_polarity_switch,
    power_handling_watts, has_reactive_load, has_attenuation, attenuation_range_db, has_cab_sim
) VALUES (
    currval('products_id_seq'), 'Tuner', TRUE, 'Analog', NULL,
    NULL, NULL, NULL,
    'Needle', 1.0, FALSE,
    NULL, FALSE, FALSE, FALSE,
    NULL, FALSE, FALSE, NULL, FALSE
);

-- No power jack (battery only, no DC input). No audio I/O jacks (acoustic measurement via built-in mic or input).
INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES
    (currval('products_id_seq'), 'products',        'width_mm',             'https://reverb.com/item/15437365-arion-hu-8400-micon-chromatic-tuner-in-original-box-made-in-japan', 'review_site', '145mm', 'High', '2026-04-18'),
    (currval('products_id_seq'), 'products',        'depth_mm',             'https://reverb.com/item/15437365-arion-hu-8400-micon-chromatic-tuner-in-original-box-made-in-japan', 'review_site', '60mm',  'High', '2026-04-18'),
    (currval('products_id_seq'), 'products',        'height_mm',            'https://reverb.com/item/15437365-arion-hu-8400-micon-chromatic-tuner-in-original-box-made-in-japan', 'review_site', '33mm',  'High', '2026-04-18'),
    (currval('products_id_seq'), 'products',        'weight_grams',         'https://reverb.com/item/15437365-arion-hu-8400-micon-chromatic-tuner-in-original-box-made-in-japan', 'review_site', '190g',  'High', '2026-04-18'),
    (currval('products_id_seq'), 'utility_details', 'tuning_accuracy_cents','https://www.effectsdatabase.com/model/arion/hu8400', 'community_database', '±1 cent', 'High', '2026-04-18'),
    (currval('products_id_seq'), 'utility_details', 'tuning_display_type',  'https://www.effectsdatabase.com/model/arion/hu8400', 'community_database', 'Needle', 'High', '2026-04-18');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = currval('products_id_seq');

COMMIT;
