-- Migration 021: Add jacks and fill data gaps for all Goodwood Audio utility products
-- Sources: Manufacturer manuals via ManualsLib (High), manufacturer product pages (High),
--          major retailers (Medium), and review sites (Medium).
-- Products: IDs 215–227 (all 13 Goodwood Audio utilities)
-- Gaps filled: jacks for all 13 products; weight_grams (216, 218);
--              msrp_cents (219, 226); product_page (225)

BEGIN;

-- ============================================================
-- 215: TX Interfacer
-- Source: https://www.manualslib.com/manual/1696395/Goodwood-Audio-The-Tx-Interfacer.html
-- 8 jacks: 1 power + 3 audio in + 4 audio out
-- ============================================================
INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (215, 'power', 'input', '2.1mm barrel', '9V', 100, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES
    (215, 'audio', 'input',  '1/4" TS',  'Passive In'),
    (215, 'audio', 'input',  '1/4" TRS', 'Left In'),
    (215, 'audio', 'input',  '1/4" TRS', 'Right In'),
    (215, 'audio', 'output', '1/4" TS',  'Tuner Out'),
    (215, 'audio', 'output', '1/4" TRS', 'Left Out'),
    (215, 'audio', 'output', '1/4" TRS', 'Right Out'),
    (215, 'audio', 'output', '1/4" TRS', 'Phase Out');

INSERT INTO product_sources (product_id, table_name, field_name, jack_id, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES (215, 'jacks', 'current_ma',
    (SELECT id FROM jacks WHERE product_id = 215 AND category = 'power' AND direction = 'input'),
    'https://www.manualslib.com/manual/1696395/Goodwood-Audio-The-Tx-Interfacer.html',
    'manufacturer_manual', '100mA', 'High', '2026-03-21');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = 215;

-- ============================================================
-- 216: TX Underfacer
-- Source: https://www.manualslib.com/manual/1990047/Goodwood-Audio-The-Tx-Underfacer.html
-- 8 jacks: 1 power + 3 audio in + 3 audio out + 1 aux (RMT input)
-- ============================================================
INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (216, 'power', 'input', '2.1mm barrel', '9V', 100, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES
    (216, 'audio', 'input',  '1/4" TS',  'Buffered Input'),
    (216, 'audio', 'input',  '1/4" TRS', 'Left In'),
    (216, 'audio', 'input',  '1/4" TRS', 'Right In'),
    (216, 'audio', 'output', '1/4" TS',  'Tuner Out'),
    (216, 'audio', 'output', '1/4" TRS', 'Left Out'),
    (216, 'audio', 'output', '1/4" TRS', 'Right Out'),
    (216, 'aux',   'input',  '1/4" TRS', 'RMT');

UPDATE products SET weight_grams = 320 WHERE id = 216;

INSERT INTO product_sources (product_id, table_name, field_name, jack_id, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES (216, 'jacks', 'current_ma',
    (SELECT id FROM jacks WHERE product_id = 216 AND category = 'power' AND direction = 'input'),
    'https://www.manualslib.com/manual/1990047/Goodwood-Audio-The-Tx-Underfacer.html',
    'manufacturer_manual', '100mA', 'High', '2026-03-21');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES (216, 'products', 'weight_grams',
    'https://www.manualslib.com/manual/1990047/Goodwood-Audio-The-Tx-Underfacer.html',
    'manufacturer_manual', '320g', 'High', '2026-03-21');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = 216;

-- ============================================================
-- 217: Output TX
-- Source: https://www.manualslib.com/manual/2494057/Goodwood-Audio-Output-Tx.html
-- 5 jacks: 1 power + 2 audio in + 2 audio out
-- ============================================================
INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (217, 'power', 'input', '2.1mm barrel', '9V', 50, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES
    (217, 'audio', 'input',  '1/4" TRS', 'Left In'),
    (217, 'audio', 'input',  '1/4" TRS', 'Right In'),
    (217, 'audio', 'output', '1/4" TRS', 'Left Out'),
    (217, 'audio', 'output', '1/4" TRS', 'Right Out');

INSERT INTO product_sources (product_id, table_name, field_name, jack_id, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES (217, 'jacks', 'current_ma',
    (SELECT id FROM jacks WHERE product_id = 217 AND category = 'power' AND direction = 'input'),
    'https://www.manualslib.com/manual/2494057/Goodwood-Audio-Output-Tx.html',
    'manufacturer_manual', '50mA', 'High', '2026-03-21');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = 217;

-- ============================================================
-- 218: LongLine
-- Source: https://www.manualslib.com/manual/3494393/Goodwood-Audio-Longline.html
-- 7 jacks: 1 power + 2 audio in (TS) + 2 audio out (TS) + 2 XLR out (balanced)
-- ============================================================
INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (218, 'power', 'input', '2.1mm barrel', '9V', 75, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES
    (218, 'audio', 'input',  '1/4" TS',         'Left In'),
    (218, 'audio', 'input',  '1/4" TS',         'Right In'),
    (218, 'audio', 'output', '1/4" TS',         'Left Out'),
    (218, 'audio', 'output', '1/4" TS',         'Right Out'),
    (218, 'audio', 'output', 'XLR', 'Left XLR Out'),
    (218, 'audio', 'output', 'XLR', 'Right XLR Out');

UPDATE products SET weight_grams = 368 WHERE id = 218;

INSERT INTO product_sources (product_id, table_name, field_name, jack_id, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES (218, 'jacks', 'current_ma',
    (SELECT id FROM jacks WHERE product_id = 218 AND category = 'power' AND direction = 'input'),
    'https://www.manualslib.com/manual/3494393/Goodwood-Audio-Longline.html',
    'manufacturer_manual', '75mA', 'High', '2026-03-21');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES (218, 'products', 'weight_grams',
    'https://www.manualslib.com/manual/3494393/Goodwood-Audio-Longline.html',
    'manufacturer_manual', '13oz (368g)', 'High', '2026-03-21');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = 218;

-- ============================================================
-- 219: RCV (passive — no power jack)
-- Source: https://www.guitarsanctuary.com/goodwood-audio-rcv-passive-junction-box/
-- 4 jacks: 2 XLR in (balanced) + 2 audio out (TS)
-- ============================================================
INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES
    (219, 'audio', 'input',  'XLR', 'Left XLR In'),
    (219, 'audio', 'input',  'XLR', 'Right XLR In'),
    (219, 'audio', 'output', '1/4" TS',        'Left Out'),
    (219, 'audio', 'output', '1/4" TS',        'Right Out');

UPDATE products SET msrp_cents = 11900 WHERE id = 219;

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES (219, 'products', 'msrp_cents',
    'https://goodwoodaudio.com/products/rcv',
    'manufacturer_website', '$119.00', 'High', '2026-03-21');

INSERT INTO product_sources (product_id, table_name, field_name, jack_id, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES (219, 'jacks', 'connector_type',
    (SELECT id FROM jacks WHERE product_id = 219 AND jack_name = 'Left XLR In'),
    'https://www.guitarsanctuary.com/goodwood-audio-rcv-passive-junction-box/',
    'review_site', 'XLR balanced inputs, 1/4" TS outputs', 'Medium', '2026-03-21');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = 219;

-- ============================================================
-- 220: Isolator TX
-- Source: https://www.gbmusicandsound.com/product-page/goodwood-audio-isolator-tx
-- 5 jacks: 1 power + 1 audio in + 2 audio out + 1 aux (RMT input)
-- ============================================================
INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (220, 'power', 'input', '2.1mm barrel', '9V', 50, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (220, 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES
    (220, 'audio', 'output', '1/4" TS',  'Output A'),
    (220, 'audio', 'output', '1/4" TS',  'Output B'),
    (220, 'aux',   'input',  '1/4" TRS', 'RMT');

INSERT INTO product_sources (product_id, table_name, field_name, jack_id, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES (220, 'jacks', 'current_ma',
    (SELECT id FROM jacks WHERE product_id = 220 AND category = 'power' AND direction = 'input'),
    'https://www.gbmusicandsound.com/product-page/goodwood-audio-isolator-tx',
    'major_retailer', '50mA', 'Medium', '2026-03-21');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = 220;

-- ============================================================
-- 221: 4-Way Buffered Splitter
-- Source: https://goodwoodaudio.com/products/4-way-buffered-splitter
-- 6 jacks: 1 power (current_ma unknown) + 1 audio in + 4 audio out
-- ============================================================
INSERT INTO jacks (product_id, category, direction, connector_type, voltage, polarity)
VALUES (221, 'power', 'input', '2.1mm barrel', '9V', 'Center Negative');
-- current_ma intentionally NULL — not found in any source

INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES (221, 'audio', 'input', '1/4" TS');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES
    (221, 'audio', 'output', '1/4" TS', 'Output A'),
    (221, 'audio', 'output', '1/4" TS', 'Output B'),
    (221, 'audio', 'output', '1/4" TS', 'Output C'),
    (221, 'audio', 'output', '1/4" TS', 'Dry');

INSERT INTO product_sources (product_id, table_name, field_name, jack_id, source_url, source_type, reliability, accessed_at)
VALUES (221, 'jacks', 'connector_type',
    (SELECT id FROM jacks WHERE product_id = 221 AND category = 'audio' AND direction = 'input'),
    'https://goodwoodaudio.com/products/4-way-buffered-splitter',
    'manufacturer_website', 'High', '2026-03-21');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = 221;

-- ============================================================
-- 222: 3 Channel Stereo Line Mixer
-- Source: https://goodwoodaudio.com/products/3-channel-stereo-line-mixer
-- 10 jacks: 1 power + 6 audio in (3 stereo pairs, TS) + 3 audio out
-- ============================================================
INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (222, 'power', 'input', '2.1mm barrel', '9V', 150, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES
    (222, 'audio', 'input',  '1/4" TS', 'Ch 1 Left In'),
    (222, 'audio', 'input',  '1/4" TS', 'Ch 1 Right In'),
    (222, 'audio', 'input',  '1/4" TS', 'Ch 2 Left In'),
    (222, 'audio', 'input',  '1/4" TS', 'Ch 2 Right In'),
    (222, 'audio', 'input',  '1/4" TS', 'Ch 3 Left In'),
    (222, 'audio', 'input',  '1/4" TS', 'Ch 3 Right In'),
    (222, 'audio', 'output', '1/4" TS', 'Left Out'),
    (222, 'audio', 'output', '1/4" TS', 'Right Out'),
    (222, 'audio', 'output', '1/4" TS', 'Dry Out');

INSERT INTO product_sources (product_id, table_name, field_name, jack_id, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES (222, 'jacks', 'current_ma',
    (SELECT id FROM jacks WHERE product_id = 222 AND category = 'power' AND direction = 'input'),
    'https://goodwoodaudio.com/products/3-channel-stereo-line-mixer',
    'manufacturer_website', '150mA', 'High', '2026-03-21');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = 222;

-- ============================================================
-- 223: Audition
-- Source: https://www.manualslib.com/manual/1637499/Goodwood-Audio-Audition.html
-- 5 jacks: 1 power + 1 audio in + 1 audio out + FX loop send/return (group_id=loop_1)
-- All audio jacks accept both TS (mono) and TRS (stereo) plugs.
-- ============================================================
INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (223, 'power', 'input', '2.1mm barrel', '9V', 1, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, group_id)
VALUES
    (223, 'audio', 'input',  '1/4" TRS', NULL,     NULL),
    (223, 'audio', 'output', '1/4" TRS', NULL,     NULL),
    (223, 'audio', 'output', '1/4" TRS', 'Send',   'loop_1'),
    (223, 'audio', 'input',  '1/4" TRS', 'Return', 'loop_1');

INSERT INTO product_sources (product_id, table_name, field_name, jack_id, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES (223, 'jacks', 'current_ma',
    (SELECT id FROM jacks WHERE product_id = 223 AND category = 'power' AND direction = 'input'),
    'https://www.manualslib.com/manual/1637499/Goodwood-Audio-Audition.html',
    'manufacturer_manual', '1mA', 'High', '2026-03-21');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = 223;

-- ============================================================
-- 224: Buzzkill (passive transformer — no power jack)
-- Source: https://goodwoodaudio.com/products/buzzkill-transformer-isolation
-- 2 jacks: 1 audio in + 1 audio out
-- ============================================================
INSERT INTO jacks (product_id, category, direction, connector_type)
VALUES
    (224, 'audio', 'input',  '1/4" TS'),
    (224, 'audio', 'output', '1/4" TS');

INSERT INTO product_sources (product_id, table_name, field_name, jack_id, source_url, source_type, reliability, accessed_at)
VALUES (224, 'jacks', 'connector_type',
    (SELECT id FROM jacks WHERE product_id = 224 AND category = 'audio' AND direction = 'input'),
    'https://goodwoodaudio.com/products/buzzkill-transformer-isolation',
    'manufacturer_website', 'High', '2026-03-21');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = 224;

-- ============================================================
-- 225: Bass Interfacer
-- Source: https://www.manualslib.com/manual/1432556/Goodwood-Audio-Bass-Interfacer.html
-- 8 jacks: 1 power + 1 audio in + 4 audio out + FX loop send/return (group_id=loop_1)
-- Also fix product_page (was pointing to homepage).
-- ============================================================
INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (225, 'power', 'input', '2.1mm barrel', '9V', 150, 'Center Negative');

INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, group_id)
VALUES
    (225, 'audio', 'input',  '1/4" TS', 'In',        NULL),
    (225, 'audio', 'output', '1/4" TS', 'Clean Out',  NULL),
    (225, 'audio', 'output', '1/4" TS', 'FX Out',     NULL),
    (225, 'audio', 'output', '1/4" TS', 'Main Out',   NULL),
    (225, 'audio', 'output', '1/4" TS', 'Tuner Out',  NULL),
    (225, 'audio', 'output', '1/4" TS', 'FX Send',    'loop_1'),
    (225, 'audio', 'input',  '1/4" TS', 'FX Return',  'loop_1');

UPDATE products SET product_page = 'https://goodwoodaudio.com/products/the-bass-interfacer' WHERE id = 225;

INSERT INTO product_sources (product_id, table_name, field_name, jack_id, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES (225, 'jacks', 'current_ma',
    (SELECT id FROM jacks WHERE product_id = 225 AND category = 'power' AND direction = 'input'),
    'https://www.manualslib.com/manual/1432556/Goodwood-Audio-Bass-Interfacer.html',
    'manufacturer_manual', '150mA', 'High', '2026-03-21');

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES (225, 'products', 'product_page',
    'https://goodwoodaudio.com/products/the-bass-interfacer',
    'manufacturer_website', 'https://goodwoodaudio.com/products/the-bass-interfacer', 'High', '2026-03-21');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = 225;

-- ============================================================
-- 226: RMT (remote footswitch — powered via TRS cable from Underfacer/Isolator)
-- Source: https://goodwoodaudio.com/products/rmt
-- 1 jack: aux output (TRS — carries control signal to TX Underfacer or Isolator TX)
-- ============================================================
INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
VALUES (226, 'aux', 'output', '1/4" TRS', 'RMT Out');

UPDATE products SET msrp_cents = 3900 WHERE id = 226;

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES (226, 'products', 'msrp_cents',
    'https://goodwoodaudio.com/products/rmt',
    'manufacturer_website', '$39.00', 'High', '2026-03-21');

INSERT INTO product_sources (product_id, table_name, field_name, jack_id, source_url, source_type, reliability, accessed_at)
VALUES (226, 'jacks', 'connector_type',
    (SELECT id FROM jacks WHERE product_id = 226 AND category = 'aux' AND direction = 'output'),
    'https://goodwoodaudio.com/products/rmt',
    'manufacturer_website', 'High', '2026-03-21');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = 226;

-- ============================================================
-- 227: LIFT 12" (mechanical pedal riser — no electrical connections)
-- ============================================================
UPDATE products SET last_researched_at = CURRENT_DATE WHERE id = 227;

COMMIT;
