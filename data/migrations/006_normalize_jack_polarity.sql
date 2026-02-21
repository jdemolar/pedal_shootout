-- Migration 006: Normalize jacks.polarity to title-case format
-- Converts legacy lowercase-hyphenated values to canonical title-case:
--   'center-negative' → 'Center Negative'
--   'center-positive' → 'Center Positive'
--
-- The schema comment (gear_postgres.sql line 95) documents the canonical values as:
--   'Center Negative', 'Center Positive', 'N/A'

UPDATE jacks SET polarity = 'Center Negative' WHERE polarity = 'center-negative';
UPDATE jacks SET polarity = 'Center Positive' WHERE polarity = 'center-positive';
