-- Migration 022: Add is_balanced column to jacks
--
-- connector_type describes the physical connector shape; is_balanced describes
-- the signal topology. They are orthogonal — a 1/4" TRS jack can carry a
-- balanced line signal (pro audio) or unbalanced stereo (headphones/guitar).
--
-- Values:
--   TRUE  — confirmed balanced signal path
--   FALSE — confirmed unbalanced
--   NULL  — unknown or not applicable
--
-- Backfill rules applied here:
--   TS connectors (1/4" TS, 3.5mm TS) are unbalanced by definition — a TS
--   plug only has tip + sleeve (no dedicated return conductor for balanced use).
--
-- Known balanced jacks set explicitly:
--   Products 218 (LongLine) XLR outputs — balanced send to PA/desk
--   Product  219 (RCV)      XLR inputs  — balanced receive from PA/desk

BEGIN;

ALTER TABLE jacks ADD COLUMN is_balanced BOOLEAN;

-- Backfill: TS connectors are always unbalanced
UPDATE jacks SET is_balanced = FALSE
WHERE connector_type IN ('1/4" TS', '3.5mm TS');

-- Backfill: known balanced XLR jacks
UPDATE jacks SET is_balanced = TRUE
WHERE product_id = 218 AND connector_type = 'XLR';  -- LongLine XLR balanced outputs

UPDATE jacks SET is_balanced = TRUE
WHERE product_id = 219 AND connector_type = 'XLR';  -- RCV XLR balanced inputs

COMMIT;
