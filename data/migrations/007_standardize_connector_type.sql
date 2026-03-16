-- Migration 007: Standardize jacks.connector_type values and add CHECK constraint
--
-- 1. Normalizes four naming inconsistencies already in the database:
--    '6.35mm TS'   → '1/4" TS'    (12 rows)
--    '6.35mm TRS'  → '1/4" TRS'   (15 rows)
--    'USB Type B'  → 'USB-B'       (3 rows)
--    'USB Type C'  → 'USB-C'       (4 rows)
--
-- 2. Adds a CHECK constraint to enforce the canonical value list going forward.
--
-- Notes:
--   - '1/4" TS' and '1/4" TRS' are used across multiple categories (audio, expression,
--     aux, midi). The connector_type describes the physical plug; the category field
--     carries the semantic meaning.
--   - '3.5mm TRS' is similarly shared across audio, expression, and midi categories.
--   - 'RCA' is legitimate for Cioks power supply outputs (phono-style DC connectors).
--   - 'XLR Combo' and 'Speakon' are not yet in the database but are included
--     preemptively: XLR Combo for DI/preamp combo jacks, Speakon for load boxes.

BEGIN;

-- Step 1: Normalize existing inconsistent values
UPDATE jacks SET connector_type = '1/4" TS'  WHERE connector_type = '6.35mm TS';
UPDATE jacks SET connector_type = '1/4" TRS' WHERE connector_type = '6.35mm TRS';
UPDATE jacks SET connector_type = 'USB-B'    WHERE connector_type = 'USB Type B';
UPDATE jacks SET connector_type = 'USB-C'    WHERE connector_type = 'USB Type C';

-- Step 2: Add CHECK constraint enforcing the canonical list
ALTER TABLE jacks ADD CONSTRAINT jacks_connector_type_check
CHECK (connector_type IN (
    -- Audio
    '1/4" TS',
    '1/4" TRS',
    '3.5mm TS',
    '3.5mm TRS',
    'XLR',
    'XLR Combo',
    '6-pin XLR',
    'RCA',
    -- MIDI
    '5-pin DIN',
    '7-pin DIN',
    -- Power
    '2.1mm barrel',
    '2.5mm barrel',
    'EIAJ-05',
    'IEC C14',
    'Hardwired',
    -- USB
    'USB-A',
    'USB-B',
    'USB-C',
    'USB Mini',
    'USB Micro',
    -- Speaker/load
    'Speakon'
));

-- Verify: no rows should remain with non-canonical values
SELECT connector_type, COUNT(*) AS count
FROM jacks
GROUP BY connector_type
ORDER BY connector_type;

COMMIT;
