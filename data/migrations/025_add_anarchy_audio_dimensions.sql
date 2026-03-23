-- Migration 025: Add dimensions and product_page URLs for Anarchy Audio pedals (Manufacturer ID 17)
-- Source: individual product pages at anarchyaudioaustralia.com/effects/
-- Dimensions format from figcaption: "WIDTHmm x DEPTHmm" (width x depth)
-- height_mm not listed on any product page — remains NULL
--
-- No dimensions found for:
-- - GE Powered Device: page exists but no spec data listed
-- - Gain of Tones: no product page (discontinued, blog post only)
-- - Spring Driver: no product page found

BEGIN;

-- Gold Class: 60mm x 112mm
UPDATE products SET
    width_mm = 60,
    depth_mm = 112,
    product_page = 'https://anarchyaudioaustralia.com/effects/goldclass/'
WHERE manufacturer_id = 17 AND model = 'Gold Class';

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES
    ((SELECT id FROM products WHERE manufacturer_id = 17 AND model = 'Gold Class'), 'products', 'width_mm', 'https://anarchyaudioaustralia.com/effects/goldclass/', 'manufacturer_website', '60mm x 112mm', 'High', '2026-03-22'),
    ((SELECT id FROM products WHERE manufacturer_id = 17 AND model = 'Gold Class'), 'products', 'depth_mm', 'https://anarchyaudioaustralia.com/effects/goldclass/', 'manufacturer_website', '60mm x 112mm', 'High', '2026-03-22'),
    ((SELECT id FROM products WHERE manufacturer_id = 17 AND model = 'Gold Class'), 'products', 'product_page', 'https://anarchyaudioaustralia.com/effects/goldclass/', 'manufacturer_website', 'https://anarchyaudioaustralia.com/effects/goldclass/', 'High', '2026-03-22');

-- Checkmate: 66mm x 122mm
UPDATE products SET
    width_mm = 66,
    depth_mm = 122,
    product_page = 'https://anarchyaudioaustralia.com/effects/checkmate/'
WHERE manufacturer_id = 17 AND model = 'Checkmate';

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES
    ((SELECT id FROM products WHERE manufacturer_id = 17 AND model = 'Checkmate'), 'products', 'width_mm', 'https://anarchyaudioaustralia.com/effects/checkmate/', 'manufacturer_website', '66mm x 122mm', 'High', '2026-03-22'),
    ((SELECT id FROM products WHERE manufacturer_id = 17 AND model = 'Checkmate'), 'products', 'depth_mm', 'https://anarchyaudioaustralia.com/effects/checkmate/', 'manufacturer_website', '66mm x 122mm', 'High', '2026-03-22'),
    ((SELECT id FROM products WHERE manufacturer_id = 17 AND model = 'Checkmate'), 'products', 'product_page', 'https://anarchyaudioaustralia.com/effects/checkmate/', 'manufacturer_website', 'https://anarchyaudioaustralia.com/effects/checkmate/', 'High', '2026-03-22');

-- Reignmaker: 66mm x 122mm
UPDATE products SET
    width_mm = 66,
    depth_mm = 122,
    product_page = 'https://anarchyaudioaustralia.com/effects/reignmaker/'
WHERE manufacturer_id = 17 AND model = 'Reignmaker';

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES
    ((SELECT id FROM products WHERE manufacturer_id = 17 AND model = 'Reignmaker'), 'products', 'width_mm', 'https://anarchyaudioaustralia.com/effects/reignmaker/', 'manufacturer_website', '66mm x 122mm', 'High', '2026-03-22'),
    ((SELECT id FROM products WHERE manufacturer_id = 17 AND model = 'Reignmaker'), 'products', 'depth_mm', 'https://anarchyaudioaustralia.com/effects/reignmaker/', 'manufacturer_website', '66mm x 122mm', 'High', '2026-03-22'),
    ((SELECT id FROM products WHERE manufacturer_id = 17 AND model = 'Reignmaker'), 'products', 'product_page', 'https://anarchyaudioaustralia.com/effects/reignmaker/', 'manufacturer_website', 'https://anarchyaudioaustralia.com/effects/reignmaker/', 'High', '2026-03-22');

-- Hereafter: 120mm x 94mm
UPDATE products SET
    width_mm = 120,
    depth_mm = 94,
    product_page = 'https://anarchyaudioaustralia.com/effects/hereafter/'
WHERE manufacturer_id = 17 AND model = 'Hereafter';

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES
    ((SELECT id FROM products WHERE manufacturer_id = 17 AND model = 'Hereafter'), 'products', 'width_mm', 'https://anarchyaudioaustralia.com/effects/hereafter/', 'manufacturer_website', '120mm x 94mm', 'High', '2026-03-22'),
    ((SELECT id FROM products WHERE manufacturer_id = 17 AND model = 'Hereafter'), 'products', 'depth_mm', 'https://anarchyaudioaustralia.com/effects/hereafter/', 'manufacturer_website', '120mm x 94mm', 'High', '2026-03-22'),
    ((SELECT id FROM products WHERE manufacturer_id = 17 AND model = 'Hereafter'), 'products', 'product_page', 'https://anarchyaudioaustralia.com/effects/hereafter/', 'manufacturer_website', 'https://anarchyaudioaustralia.com/effects/hereafter/', 'High', '2026-03-22');

-- Aftermath: 120mm x 94mm
UPDATE products SET
    width_mm = 120,
    depth_mm = 94,
    product_page = 'https://anarchyaudioaustralia.com/effects/aftermath/'
WHERE manufacturer_id = 17 AND model = 'Aftermath';

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES
    ((SELECT id FROM products WHERE manufacturer_id = 17 AND model = 'Aftermath'), 'products', 'width_mm', 'https://anarchyaudioaustralia.com/effects/aftermath/', 'manufacturer_website', '120mm x 94mm', 'High', '2026-03-22'),
    ((SELECT id FROM products WHERE manufacturer_id = 17 AND model = 'Aftermath'), 'products', 'depth_mm', 'https://anarchyaudioaustralia.com/effects/aftermath/', 'manufacturer_website', '120mm x 94mm', 'High', '2026-03-22'),
    ((SELECT id FROM products WHERE manufacturer_id = 17 AND model = 'Aftermath'), 'products', 'product_page', 'https://anarchyaudioaustralia.com/effects/aftermath/', 'manufacturer_website', 'https://anarchyaudioaustralia.com/effects/aftermath/', 'High', '2026-03-22');

-- Flutterby: 66mm x 122mm
UPDATE products SET
    width_mm = 66,
    depth_mm = 122,
    product_page = 'https://anarchyaudioaustralia.com/effects/flutterby/'
WHERE manufacturer_id = 17 AND model = 'Flutterby';

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES
    ((SELECT id FROM products WHERE manufacturer_id = 17 AND model = 'Flutterby'), 'products', 'width_mm', 'https://anarchyaudioaustralia.com/effects/flutterby/', 'manufacturer_website', '66mm x 122mm', 'High', '2026-03-22'),
    ((SELECT id FROM products WHERE manufacturer_id = 17 AND model = 'Flutterby'), 'products', 'depth_mm', 'https://anarchyaudioaustralia.com/effects/flutterby/', 'manufacturer_website', '66mm x 122mm', 'High', '2026-03-22'),
    ((SELECT id FROM products WHERE manufacturer_id = 17 AND model = 'Flutterby'), 'products', 'product_page', 'https://anarchyaudioaustralia.com/effects/flutterby/', 'manufacturer_website', 'https://anarchyaudioaustralia.com/effects/flutterby/', 'High', '2026-03-22');

-- Girt: 66mm x 122mm
UPDATE products SET
    width_mm = 66,
    depth_mm = 122,
    product_page = 'https://anarchyaudioaustralia.com/effects/girt/'
WHERE manufacturer_id = 17 AND model = 'Girt';

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES
    ((SELECT id FROM products WHERE manufacturer_id = 17 AND model = 'Girt'), 'products', 'width_mm', 'https://anarchyaudioaustralia.com/effects/girt/', 'manufacturer_website', '66mm x 122mm', 'High', '2026-03-22'),
    ((SELECT id FROM products WHERE manufacturer_id = 17 AND model = 'Girt'), 'products', 'depth_mm', 'https://anarchyaudioaustralia.com/effects/girt/', 'manufacturer_website', '66mm x 122mm', 'High', '2026-03-22'),
    ((SELECT id FROM products WHERE manufacturer_id = 17 AND model = 'Girt'), 'products', 'product_page', 'https://anarchyaudioaustralia.com/effects/girt/', 'manufacturer_website', 'https://anarchyaudioaustralia.com/effects/girt/', 'High', '2026-03-22');

-- Deadwoods: 66mm x 122mm (canonical URL: /effects/deadwoods-2/)
UPDATE products SET
    width_mm = 66,
    depth_mm = 122,
    product_page = 'https://anarchyaudioaustralia.com/effects/deadwoods-2/'
WHERE manufacturer_id = 17 AND model = 'Deadwoods';

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES
    ((SELECT id FROM products WHERE manufacturer_id = 17 AND model = 'Deadwoods'), 'products', 'width_mm', 'https://anarchyaudioaustralia.com/effects/deadwoods-2/', 'manufacturer_website', '66mm x 122mm', 'High', '2026-03-22'),
    ((SELECT id FROM products WHERE manufacturer_id = 17 AND model = 'Deadwoods'), 'products', 'depth_mm', 'https://anarchyaudioaustralia.com/effects/deadwoods-2/', 'manufacturer_website', '66mm x 122mm', 'High', '2026-03-22'),
    ((SELECT id FROM products WHERE manufacturer_id = 17 AND model = 'Deadwoods'), 'products', 'product_page', 'https://anarchyaudioaustralia.com/effects/deadwoods-2/', 'manufacturer_website', 'https://anarchyaudioaustralia.com/effects/deadwoods-2/', 'High', '2026-03-22');

-- Baa Bzz: 66mm x 122mm
UPDATE products SET
    width_mm = 66,
    depth_mm = 122,
    product_page = 'https://anarchyaudioaustralia.com/effects/baabzz/'
WHERE manufacturer_id = 17 AND model = 'Baa Bzz';

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES
    ((SELECT id FROM products WHERE manufacturer_id = 17 AND model = 'Baa Bzz'), 'products', 'width_mm', 'https://anarchyaudioaustralia.com/effects/baabzz/', 'manufacturer_website', '66mm x 122mm', 'High', '2026-03-22'),
    ((SELECT id FROM products WHERE manufacturer_id = 17 AND model = 'Baa Bzz'), 'products', 'depth_mm', 'https://anarchyaudioaustralia.com/effects/baabzz/', 'manufacturer_website', '66mm x 122mm', 'High', '2026-03-22'),
    ((SELECT id FROM products WHERE manufacturer_id = 17 AND model = 'Baa Bzz'), 'products', 'product_page', 'https://anarchyaudioaustralia.com/effects/baabzz/', 'manufacturer_website', 'https://anarchyaudioaustralia.com/effects/baabzz/', 'High', '2026-03-22');

-- Chaos Star: 60mm x 112mm
UPDATE products SET
    width_mm = 60,
    depth_mm = 112,
    product_page = 'https://anarchyaudioaustralia.com/effects/chaos-star/'
WHERE manufacturer_id = 17 AND model = 'Chaos Star';

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES
    ((SELECT id FROM products WHERE manufacturer_id = 17 AND model = 'Chaos Star'), 'products', 'width_mm', 'https://anarchyaudioaustralia.com/effects/chaos-star/', 'manufacturer_website', '60mm x 112mm', 'High', '2026-03-22'),
    ((SELECT id FROM products WHERE manufacturer_id = 17 AND model = 'Chaos Star'), 'products', 'depth_mm', 'https://anarchyaudioaustralia.com/effects/chaos-star/', 'manufacturer_website', '60mm x 112mm', 'High', '2026-03-22'),
    ((SELECT id FROM products WHERE manufacturer_id = 17 AND model = 'Chaos Star'), 'products', 'product_page', 'https://anarchyaudioaustralia.com/effects/chaos-star/', 'manufacturer_website', 'https://anarchyaudioaustralia.com/effects/chaos-star/', 'High', '2026-03-22');

-- F-Bomb: 60mm x 112mm
UPDATE products SET
    width_mm = 60,
    depth_mm = 112,
    product_page = 'https://anarchyaudioaustralia.com/effects/f-bomb/'
WHERE manufacturer_id = 17 AND model = 'F-Bomb';

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES
    ((SELECT id FROM products WHERE manufacturer_id = 17 AND model = 'F-Bomb'), 'products', 'width_mm', 'https://anarchyaudioaustralia.com/effects/f-bomb/', 'manufacturer_website', '60mm x 112mm', 'High', '2026-03-22'),
    ((SELECT id FROM products WHERE manufacturer_id = 17 AND model = 'F-Bomb'), 'products', 'depth_mm', 'https://anarchyaudioaustralia.com/effects/f-bomb/', 'manufacturer_website', '60mm x 112mm', 'High', '2026-03-22'),
    ((SELECT id FROM products WHERE manufacturer_id = 17 AND model = 'F-Bomb'), 'products', 'product_page', 'https://anarchyaudioaustralia.com/effects/f-bomb/', 'manufacturer_website', 'https://anarchyaudioaustralia.com/effects/f-bomb/', 'High', '2026-03-22');

-- GE Powered Device: product page confirmed, no dimensions listed
UPDATE products SET
    product_page = 'https://anarchyaudioaustralia.com/effects/ge-powered-device/'
WHERE manufacturer_id = 17 AND model = 'GE Powered Device';

INSERT INTO product_sources (product_id, table_name, field_name, source_url, source_type, value_recorded, reliability, accessed_at)
VALUES
    ((SELECT id FROM products WHERE manufacturer_id = 17 AND model = 'GE Powered Device'), 'products', 'product_page', 'https://anarchyaudioaustralia.com/effects/ge-powered-device/', 'manufacturer_website', 'https://anarchyaudioaustralia.com/effects/ge-powered-device/', 'High', '2026-03-22');

UPDATE products SET last_researched_at = CURRENT_DATE WHERE manufacturer_id = 17;

COMMIT;
