-- Migration 016: Add 'Tap Tempo' to utility_type CHECK constraint
-- Needed for Analog Man AMAZE1 and AMAZE0 tap tempo controller pedals

BEGIN;

ALTER TABLE utility_details DROP CONSTRAINT utility_details_utility_type_check;

ALTER TABLE utility_details ADD CONSTRAINT utility_details_utility_type_check
    CHECK (utility_type IN (
        'DI Box', 'Reamp Box', 'Buffer', 'Splitter', 'A/B Box', 'A/B/Y Box',
        'Tuner', 'Volume Pedal', 'Expression Pedal', 'Noise Gate',
        'Power Conditioner', 'Signal Router', 'Impedance Matcher',
        'Headphone Amp', 'Mixer', 'Junction Box', 'Patch Bay',
        'Mute Switch', 'Amp Switcher', 'Load Box', 'Line Level Converter',
        'Tap Tempo', 'Other'
    ));

COMMIT;
