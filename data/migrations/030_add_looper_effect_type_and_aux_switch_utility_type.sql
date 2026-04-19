-- =============================================================================
-- Migration 030: Add 'Looper' effect_type and 'Aux Switch' utility_type
-- =============================================================================
-- Adds two new allowed values to existing CHECK constraints:
--   - 'Looper' to pedal_details.effect_type
--   - 'Aux Switch' to utility_details.utility_type
-- =============================================================================

BEGIN;

-- ─── pedal_details.effect_type ───────────────────────────────────────────────

ALTER TABLE pedal_details DROP CONSTRAINT pedal_details_effect_type_check;

ALTER TABLE pedal_details ADD CONSTRAINT pedal_details_effect_type_check
    CHECK (effect_type IN (
        'Gain', 'Fuzz', 'Compression', 'Delay', 'Reverb',
        'Chorus', 'Flanger', 'Phaser', 'Tremolo', 'Vibrato',
        'Rotary', 'Univibe', 'Ring Modulator',
        'Pitch Shifter', 'Wah', 'Filter', 'EQ',
        'Looper', 'Multi Effects', 'Utility', 'Preamp', 'Amp/Cab Sim', 'Other'
    ));

-- ─── utility_details.utility_type ────────────────────────────────────────────

ALTER TABLE utility_details DROP CONSTRAINT utility_details_utility_type_check;

ALTER TABLE utility_details ADD CONSTRAINT utility_details_utility_type_check
    CHECK (utility_type IN (
        'DI Box', 'Reamp Box', 'Buffer', 'Splitter', 'A/B Box', 'A/B/Y Box',
        'Tuner', 'Volume Pedal', 'Expression Pedal', 'Noise Gate',
        'Power Conditioner', 'Signal Router', 'Impedance Matcher',
        'Headphone Amp', 'Mixer', 'Junction Box', 'Patch Bay',
        'Mute Switch', 'Amp Switcher', 'Load Box', 'Line Level Converter',
        'Tap Tempo', 'Aux Switch', 'Other'
    ));

COMMIT;
