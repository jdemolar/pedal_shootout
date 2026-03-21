-- Migration 008: Add TRS MIDI standard, TRS polarity, pot resistance, and footswitch type to jacks
--
-- These columns close schema gaps identified during Control and MIDI connections development:
--   trs_midi_standard (9.f) — enables auto-detection of TRS-A vs TRS-B in MIDI connections view
--   trs_polarity (9.g)      — enables auto-detection of expression polarity mismatches (tip-active vs ring-active)
--   pot_resistance_ohms (9.h) — enables resistance compatibility warnings (10K vs 25K Ohm expression pedals)
--   footswitch_type (9.i)   — enables aux/toe-switch type validation (momentary vs latching)
--
-- All columns are nullable — only populated for the relevant jack categories.

BEGIN;

ALTER TABLE jacks
    ADD COLUMN trs_midi_standard TEXT
        CHECK (trs_midi_standard IN ('TRS-A', 'TRS-B', 'Tip Active', 'Ring Active')),
    ADD COLUMN trs_polarity TEXT
        CHECK (trs_polarity IN ('tip-active', 'ring-active')),
    ADD COLUMN pot_resistance_ohms INTEGER,
    ADD COLUMN footswitch_type TEXT
        CHECK (footswitch_type IN ('momentary', 'latching'));

COMMIT;
