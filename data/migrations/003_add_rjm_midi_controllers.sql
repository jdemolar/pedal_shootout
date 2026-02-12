-- Migration 003: Add RJM Music Technology and all current MIDI controllers
-- Source: rjmmusic.com product pages + official PDF manuals (High reliability)
-- Products: Mastermind LT, GT/10, GT/16, GT/22, PBC/6X, PBC/10

BEGIN;

-- ============================================================
-- MANUFACTURER
-- ============================================================

INSERT INTO manufacturers (name, country, founded, status, specialty, website, updated_at)
VALUES (
    'RJM Music Technology',
    'USA',
    '2001',
    'Active',
    'MIDI foot controllers and switching systems',
    'https://www.rjmmusic.com',
    NOW()
);

-- ============================================================
-- PRODUCTS
-- ============================================================

-- 1. Mastermind LT
INSERT INTO products (
    manufacturer_id, product_type_id, model, in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    msrp_cents, product_page, instruction_manual, data_reliability
)
SELECT id, 4, 'Mastermind LT', TRUE,
    292.1, 127.0, 69.85, 862,
    54900,
    'https://www.rjmmusic.com/mastermind-lt/',
    'https://www.rjmmusic.com/download-content/MMLT/Mastermind%20LT%20Manual-3.1.pdf',
    'High'
FROM manufacturers WHERE name = 'RJM Music Technology';

-- 2. Mastermind GT/10
INSERT INTO products (
    manufacturer_id, product_type_id, model, in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    msrp_cents, product_page, instruction_manual, data_reliability
)
SELECT id, 4, 'Mastermind GT/10', TRUE,
    492.76, 205.74, 82.55, 2722,
    149900,
    'https://www.rjmmusic.com/mastermind-gt-10/',
    'https://www.rjmmusic.com/download-content/MMGT/Mastermind%20GT%20Manual-4.3.pdf',
    'High'
FROM manufacturers WHERE name = 'RJM Music Technology';

-- 3. Mastermind GT/16
INSERT INTO products (
    manufacturer_id, product_type_id, model, in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    msrp_cents, product_page, instruction_manual, data_reliability
)
SELECT id, 4, 'Mastermind GT/16', TRUE,
    492.76, 281.94, 82.55, 3629,
    199900,
    'https://www.rjmmusic.com/mastermind-gt-16/',
    'https://www.rjmmusic.com/download-content/MMGT/Mastermind%20GT%20Manual-4.3.pdf',
    'High'
FROM manufacturers WHERE name = 'RJM Music Technology';

-- 4. Mastermind GT/22
INSERT INTO products (
    manufacturer_id, product_type_id, model, in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    msrp_cents, product_page, instruction_manual, data_reliability
)
SELECT id, 4, 'Mastermind GT/22', TRUE,
    492.76, 358.14, 82.55, 4536,
    225000,
    'https://www.rjmmusic.com/mastermind-gt-22/',
    'https://www.rjmmusic.com/download-content/MMGT/Mastermind%20GT%20Manual-4.3.pdf',
    'High'
FROM manufacturers WHERE name = 'RJM Music Technology';

-- 5. Mastermind PBC/6X
INSERT INTO products (
    manufacturer_id, product_type_id, model, in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    msrp_cents, product_page, instruction_manual, data_reliability
)
SELECT id, 4, 'Mastermind PBC/6X', TRUE,
    256.54, 111.76, 60.96, 907,
    89900,
    'https://www.rjmmusic.com/mastermind-pbc-6x/',
    'https://www.rjmmusic.com/download-content/PBC6X/PBC6X%20Manual-4.3.pdf',
    'High'
FROM manufacturers WHERE name = 'RJM Music Technology';

-- 6. Mastermind PBC/10
INSERT INTO products (
    manufacturer_id, product_type_id, model, in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    msrp_cents, product_page, instruction_manual, data_reliability
)
SELECT id, 4, 'Mastermind PBC/10', TRUE,
    444.5, 139.7, 84.58, 1814,
    124900,
    'https://www.rjmmusic.com/mastermind-pbc-2/',
    'https://www.rjmmusic.com/download-content/PBC/PBC%20Manual-4.0.pdf',
    'High'
FROM manufacturers WHERE name = 'RJM Music Technology';

-- ============================================================
-- MIDI CONTROLLER DETAILS
-- ============================================================

-- 1. Mastermind LT
-- 7 footswitches w/ RGB LEDs, 1 expression input, 2 aux switch inputs
-- 768 presets / 1,008 songs / 64 setlists; banks are user-configurable (NULL)
-- USB-B (computer) + USB-A (thumb drive); power accepts center positive OR negative
INSERT INTO midi_controller_details (
    product_id,
    footswitch_count, footswitch_type, has_led_indicators, led_color_options,
    bank_count, presets_per_bank, total_preset_slots,
    has_display, display_type,
    expression_input_count, midi_channels,
    supports_midi_clock, supports_sysex,
    software_editor_available, software_platforms,
    on_device_programming, is_firmware_updatable,
    has_tuner, has_tap_tempo, has_setlist_mode,
    has_per_switch_displays, aux_switch_input_count,
    has_usb_host, has_bluetooth_midi,
    audio_loop_count, has_reorderable_loops
)
SELECT p.id,
    7, 'Momentary', TRUE, 'RGB',
    NULL, NULL, 768,
    TRUE, 'LCD',
    1, 16,
    TRUE, TRUE,
    TRUE, 'macOS, Windows',
    TRUE, TRUE,
    FALSE, TRUE, TRUE,
    FALSE, 2,
    FALSE, FALSE,
    0, FALSE
FROM products p
JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind LT';

-- 2. Mastermind GT/10
-- 10 footswitches each with individual LCD display, 4 expression inputs, 4 aux switch inputs
-- 768 presets / 1,008 songs / 64 setlists
INSERT INTO midi_controller_details (
    product_id,
    footswitch_count, footswitch_type, has_led_indicators, led_color_options,
    bank_count, presets_per_bank, total_preset_slots,
    has_display, display_type,
    expression_input_count, midi_channels,
    supports_midi_clock, supports_sysex,
    software_editor_available, software_platforms,
    on_device_programming, is_firmware_updatable,
    has_tuner, has_tap_tempo, has_setlist_mode,
    has_per_switch_displays, aux_switch_input_count,
    has_usb_host, has_bluetooth_midi,
    audio_loop_count, has_reorderable_loops
)
SELECT p.id,
    10, 'Momentary', TRUE, 'LCD',
    NULL, NULL, 768,
    TRUE, 'LCD',
    4, 16,
    TRUE, TRUE,
    TRUE, 'macOS, Windows',
    TRUE, TRUE,
    FALSE, TRUE, TRUE,
    TRUE, 4,
    FALSE, FALSE,
    0, FALSE
FROM products p
JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind GT/10';

-- 3. Mastermind GT/16
INSERT INTO midi_controller_details (
    product_id,
    footswitch_count, footswitch_type, has_led_indicators, led_color_options,
    bank_count, presets_per_bank, total_preset_slots,
    has_display, display_type,
    expression_input_count, midi_channels,
    supports_midi_clock, supports_sysex,
    software_editor_available, software_platforms,
    on_device_programming, is_firmware_updatable,
    has_tuner, has_tap_tempo, has_setlist_mode,
    has_per_switch_displays, aux_switch_input_count,
    has_usb_host, has_bluetooth_midi,
    audio_loop_count, has_reorderable_loops
)
SELECT p.id,
    16, 'Momentary', TRUE, 'LCD',
    NULL, NULL, 768,
    TRUE, 'LCD',
    4, 16,
    TRUE, TRUE,
    TRUE, 'macOS, Windows',
    TRUE, TRUE,
    FALSE, TRUE, TRUE,
    TRUE, 4,
    FALSE, FALSE,
    0, FALSE
FROM products p
JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind GT/16';

-- 4. Mastermind GT/22
INSERT INTO midi_controller_details (
    product_id,
    footswitch_count, footswitch_type, has_led_indicators, led_color_options,
    bank_count, presets_per_bank, total_preset_slots,
    has_display, display_type,
    expression_input_count, midi_channels,
    supports_midi_clock, supports_sysex,
    software_editor_available, software_platforms,
    on_device_programming, is_firmware_updatable,
    has_tuner, has_tap_tempo, has_setlist_mode,
    has_per_switch_displays, aux_switch_input_count,
    has_usb_host, has_bluetooth_midi,
    audio_loop_count, has_reorderable_loops
)
SELECT p.id,
    22, 'Momentary', TRUE, 'LCD',
    NULL, NULL, 768,
    TRUE, 'LCD',
    4, 16,
    TRUE, TRUE,
    TRUE, 'macOS, Windows',
    TRUE, TRUE,
    FALSE, TRUE, TRUE,
    TRUE, 4,
    FALSE, FALSE,
    0, FALSE
FROM products p
JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind GT/22';

-- 5. Mastermind PBC/6X
-- 7 footswitches, 1 expression input, 2 aux switch inputs
-- 6 switchable audio loops (3 mono, 3 stereo-capable TRS) + 1 buffered insert
-- Matrix switcher enables loop reordering per preset; gapless switching
-- MIDI Out jack doubles as MIDI In+Out via optional Y cable
INSERT INTO midi_controller_details (
    product_id,
    footswitch_count, footswitch_type, has_led_indicators, led_color_options,
    bank_count, presets_per_bank, total_preset_slots,
    has_display, display_type,
    expression_input_count, midi_channels,
    supports_midi_clock, supports_sysex,
    software_editor_available, software_platforms,
    on_device_programming, is_firmware_updatable,
    has_tuner, has_tap_tempo, has_setlist_mode,
    has_per_switch_displays, aux_switch_input_count,
    has_usb_host, has_bluetooth_midi,
    audio_loop_count, has_reorderable_loops,
    loop_bypass_type, has_parallel_routing, has_gapless_switching
)
SELECT p.id,
    7, 'Momentary', TRUE, 'RGB',
    NULL, NULL, 768,
    TRUE, 'LCD',
    1, 16,
    TRUE, TRUE,
    TRUE, 'macOS, Windows',
    TRUE, TRUE,
    TRUE, TRUE, TRUE,
    FALSE, 2,
    FALSE, FALSE,
    6, TRUE,
    'True Bypass', FALSE, TRUE
FROM products p
JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind PBC/6X';

-- 6. Mastermind PBC/10
-- 11 footswitches, 1 expression input, 4 aux switch inputs (2 TRS jacks)
-- 10 audio loops; last 4 can run series or parallel per preset
-- 625 presets / 250 songs / 16 setlists
-- Power: 9V DC / 12V DC / 9V AC (versatile, Voodoo Lab compatible)
INSERT INTO midi_controller_details (
    product_id,
    footswitch_count, footswitch_type, has_led_indicators, led_color_options,
    bank_count, presets_per_bank, total_preset_slots,
    has_display, display_type,
    expression_input_count, midi_channels,
    supports_midi_clock, supports_sysex,
    software_editor_available, software_platforms,
    on_device_programming, is_firmware_updatable,
    has_tuner, has_tap_tempo, has_setlist_mode,
    has_per_switch_displays, aux_switch_input_count,
    has_usb_host, has_bluetooth_midi,
    audio_loop_count, has_reorderable_loops,
    loop_bypass_type, has_parallel_routing, has_gapless_switching
)
SELECT p.id,
    11, 'Momentary', TRUE, 'RGB',
    NULL, NULL, 625,
    TRUE, 'LCD',
    1, 16,
    TRUE, TRUE,
    TRUE, 'macOS, Windows',
    TRUE, TRUE,
    TRUE, TRUE, TRUE,
    FALSE, 4,
    FALSE, FALSE,
    10, FALSE,
    'True Bypass', TRUE, TRUE
FROM products p
JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind PBC/10';

-- ============================================================
-- JACKS
-- ============================================================

-- ----------------------------------------
-- Mastermind LT
-- ----------------------------------------
INSERT INTO jacks (product_id, category, direction, jack_name, connector_type, voltage, current_ma, polarity, function)
SELECT p.id, 'Power Input', 'Input', 'Power', '2.1mm barrel',
    '9-12V DC', 150, NULL,
    'Accepts 9–12V DC center positive or negative; also USB bus-powered via USB-B'
FROM products p JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind LT';

INSERT INTO jacks (product_id, category, direction, jack_name, connector_type, function)
SELECT p.id, 'MIDI Out', 'Output', 'MIDI Out', '5-pin DIN',
    'Sends program changes, control changes, and MIDI clock to connected devices'
FROM products p JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind LT';

INSERT INTO jacks (product_id, category, direction, jack_name, connector_type, function)
SELECT p.id, 'USB', 'Bidirectional', 'USB (Computer)', 'USB-B',
    'Computer connection for MIDI device communication and editor software'
FROM products p JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind LT';

INSERT INTO jacks (product_id, category, direction, jack_name, connector_type, function)
SELECT p.id, 'Aux', 'Output', 'USB (Storage)', 'USB-A',
    'Thumb drive connection for settings backup and firmware updates'
FROM products p JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind LT';

INSERT INTO jacks (product_id, category, direction, jack_name, connector_type, function)
SELECT p.id, 'Expression', 'Input', 'Exp 1', '1/4" TRS',
    'Expression pedal input; accepts linear or log taper, high or low impedance'
FROM products p JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind LT';

-- ----------------------------------------
-- Mastermind GT/10
-- ----------------------------------------
INSERT INTO jacks (product_id, category, direction, jack_name, connector_type, voltage, current_ma, polarity, function)
SELECT p.id, 'Power Input', 'Input', 'Power', '2.1mm barrel',
    '12V DC', 1000, 'Center Positive',
    '12V DC center positive; 7-pin DIN MIDI also carries phantom power as alternative'
FROM products p JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind GT/10';

INSERT INTO jacks (product_id, category, direction, jack_name, connector_type, function)
SELECT p.id, 'MIDI In', 'Input', 'MIDI In', '5-pin DIN',
    'Receives MIDI clock and messages for synchronization and merge'
FROM products p JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind GT/10';

INSERT INTO jacks (product_id, category, direction, jack_name, connector_type, function)
SELECT p.id, 'MIDI Out', 'Output', 'MIDI Out 1', '5-pin DIN',
    'Primary MIDI output for connected devices'
FROM products p JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind GT/10';

INSERT INTO jacks (product_id, category, direction, jack_name, connector_type, voltage, current_ma, function, power_over_connector)
SELECT p.id, 'MIDI Out', 'Output', 'MIDI Out 2 (7-pin)', '7-pin DIN',
    '9-12V DC', NULL,
    'Secondary MIDI output; pins 6–7 carry DC phantom power for compatible RJM devices',
    TRUE
FROM products p JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind GT/10';

INSERT INTO jacks (product_id, category, direction, jack_name, connector_type, function)
SELECT p.id, 'USB', 'Bidirectional', 'USB (Computer)', 'USB-B',
    'Computer connection for MIDI device communication and editor software'
FROM products p JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind GT/10';

INSERT INTO jacks (product_id, category, direction, jack_name, connector_type, function)
SELECT p.id, 'Aux', 'Output', 'USB (Storage)', 'USB-A',
    'Thumb drive connection for settings backup and firmware updates'
FROM products p JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind GT/10';

INSERT INTO jacks (product_id, category, direction, jack_name, connector_type, voltage, current_ma, polarity, function)
SELECT p.id, 'Power Output', 'Output', 'Aux 9V Out 1', '2.1mm barrel',
    '9V DC', 100, 'Center Negative',
    'Auxiliary 9V output (BOSS-style) for powering accessories; 100 mA total shared across both aux outputs'
FROM products p JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind GT/10';

INSERT INTO jacks (product_id, category, direction, jack_name, connector_type, voltage, current_ma, polarity, function)
SELECT p.id, 'Power Output', 'Output', 'Aux 9V Out 2', '2.1mm barrel',
    '9V DC', 100, 'Center Negative',
    'Auxiliary 9V output (BOSS-style) for powering accessories; 100 mA total shared across both aux outputs'
FROM products p JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind GT/10';

INSERT INTO jacks (product_id, category, direction, jack_name, connector_type, function)
SELECT p.id, 'Expression', 'Input', 'Exp 1', '1/4" TRS',
    'Expression pedal input; accepts linear or log taper, high or low impedance'
FROM products p JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind GT/10';

INSERT INTO jacks (product_id, category, direction, jack_name, connector_type, function)
SELECT p.id, 'Expression', 'Input', 'Exp 2', '1/4" TRS',
    'Expression pedal input; accepts linear or log taper, high or low impedance'
FROM products p JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind GT/10';

INSERT INTO jacks (product_id, category, direction, jack_name, connector_type, function)
SELECT p.id, 'Expression', 'Input', 'Exp 3', '1/4" TRS',
    'Expression pedal input; accepts linear or log taper, high or low impedance'
FROM products p JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind GT/10';

INSERT INTO jacks (product_id, category, direction, jack_name, connector_type, function)
SELECT p.id, 'Expression', 'Input', 'Exp 4', '1/4" TRS',
    'Expression pedal input; accepts linear or log taper, high or low impedance'
FROM products p JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind GT/10';

INSERT INTO jacks (product_id, category, direction, jack_name, connector_type, function)
SELECT p.id, 'Aux', 'Input', 'Ext Switch 1/2', '1/4" TRS',
    'External switch input; TRS accommodates 2 momentary switches (tip = switch 1, ring = switch 2)'
FROM products p JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind GT/10';

INSERT INTO jacks (product_id, category, direction, jack_name, connector_type, function)
SELECT p.id, 'Aux', 'Input', 'Ext Switch 3/4', '1/4" TRS',
    'External switch input; TRS accommodates 2 momentary switches (tip = switch 3, ring = switch 4)'
FROM products p JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind GT/10';

-- ----------------------------------------
-- Mastermind GT/16 (identical to GT/10 jacks)
-- ----------------------------------------
INSERT INTO jacks (product_id, category, direction, jack_name, connector_type, voltage, current_ma, polarity, function)
SELECT p.id, 'Power Input', 'Input', 'Power', '2.1mm barrel',
    '12V DC', 1500, 'Center Positive',
    '12V DC center positive; 7-pin DIN MIDI also carries phantom power as alternative'
FROM products p JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind GT/16';

INSERT INTO jacks (product_id, category, direction, jack_name, connector_type, function)
SELECT p.id, 'MIDI In', 'Input', 'MIDI In', '5-pin DIN',
    'Receives MIDI clock and messages for synchronization and merge'
FROM products p JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind GT/16';

INSERT INTO jacks (product_id, category, direction, jack_name, connector_type, function)
SELECT p.id, 'MIDI Out', 'Output', 'MIDI Out 1', '5-pin DIN',
    'Primary MIDI output for connected devices'
FROM products p JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind GT/16';

INSERT INTO jacks (product_id, category, direction, jack_name, connector_type, voltage, current_ma, function, power_over_connector)
SELECT p.id, 'MIDI Out', 'Output', 'MIDI Out 2 (7-pin)', '7-pin DIN',
    '9-12V DC', NULL,
    'Secondary MIDI output; pins 6–7 carry DC phantom power for compatible RJM devices',
    TRUE
FROM products p JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind GT/16';

INSERT INTO jacks (product_id, category, direction, jack_name, connector_type, function)
SELECT p.id, 'USB', 'Bidirectional', 'USB (Computer)', 'USB-B',
    'Computer connection for MIDI device communication and editor software'
FROM products p JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind GT/16';

INSERT INTO jacks (product_id, category, direction, jack_name, connector_type, function)
SELECT p.id, 'Aux', 'Output', 'USB (Storage)', 'USB-A',
    'Thumb drive connection for settings backup and firmware updates'
FROM products p JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind GT/16';

INSERT INTO jacks (product_id, category, direction, jack_name, connector_type, voltage, current_ma, polarity, function)
SELECT p.id, 'Power Output', 'Output', 'Aux 9V Out 1', '2.1mm barrel',
    '9V DC', 100, 'Center Negative',
    'Auxiliary 9V output (BOSS-style) for powering accessories; 100 mA total shared across both aux outputs'
FROM products p JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind GT/16';

INSERT INTO jacks (product_id, category, direction, jack_name, connector_type, voltage, current_ma, polarity, function)
SELECT p.id, 'Power Output', 'Output', 'Aux 9V Out 2', '2.1mm barrel',
    '9V DC', 100, 'Center Negative',
    'Auxiliary 9V output (BOSS-style) for powering accessories; 100 mA total shared across both aux outputs'
FROM products p JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind GT/16';

INSERT INTO jacks (product_id, category, direction, jack_name, connector_type, function)
SELECT p.id, 'Expression', 'Input', 'Exp 1', '1/4" TRS', 'Expression pedal input; accepts linear or log taper, high or low impedance'
FROM products p JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind GT/16';

INSERT INTO jacks (product_id, category, direction, jack_name, connector_type, function)
SELECT p.id, 'Expression', 'Input', 'Exp 2', '1/4" TRS', 'Expression pedal input; accepts linear or log taper, high or low impedance'
FROM products p JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind GT/16';

INSERT INTO jacks (product_id, category, direction, jack_name, connector_type, function)
SELECT p.id, 'Expression', 'Input', 'Exp 3', '1/4" TRS', 'Expression pedal input; accepts linear or log taper, high or low impedance'
FROM products p JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind GT/16';

INSERT INTO jacks (product_id, category, direction, jack_name, connector_type, function)
SELECT p.id, 'Expression', 'Input', 'Exp 4', '1/4" TRS', 'Expression pedal input; accepts linear or log taper, high or low impedance'
FROM products p JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind GT/16';

INSERT INTO jacks (product_id, category, direction, jack_name, connector_type, function)
SELECT p.id, 'Aux', 'Input', 'Ext Switch 1/2', '1/4" TRS',
    'External switch input; TRS accommodates 2 momentary switches (tip = switch 1, ring = switch 2)'
FROM products p JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind GT/16';

INSERT INTO jacks (product_id, category, direction, jack_name, connector_type, function)
SELECT p.id, 'Aux', 'Input', 'Ext Switch 3/4', '1/4" TRS',
    'External switch input; TRS accommodates 2 momentary switches (tip = switch 3, ring = switch 4)'
FROM products p JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind GT/16';

-- ----------------------------------------
-- Mastermind GT/22 (same as GT/16 + 6-pin XLR MIDI Out)
-- ----------------------------------------
INSERT INTO jacks (product_id, category, direction, jack_name, connector_type, voltage, current_ma, polarity, function)
SELECT p.id, 'Power Input', 'Input', 'Power', '2.1mm barrel',
    '12V DC', 2000, 'Center Positive',
    '12V DC center positive; 7-pin DIN and 6-pin XLR MIDI jacks also carry phantom power as alternatives'
FROM products p JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind GT/22';

INSERT INTO jacks (product_id, category, direction, jack_name, connector_type, function)
SELECT p.id, 'MIDI In', 'Input', 'MIDI In', '5-pin DIN',
    'Receives MIDI clock and messages for synchronization and merge'
FROM products p JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind GT/22';

INSERT INTO jacks (product_id, category, direction, jack_name, connector_type, function)
SELECT p.id, 'MIDI Out', 'Output', 'MIDI Out 1', '5-pin DIN',
    'Primary MIDI output for connected devices'
FROM products p JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind GT/22';

INSERT INTO jacks (product_id, category, direction, jack_name, connector_type, voltage, current_ma, function, power_over_connector)
SELECT p.id, 'MIDI Out', 'Output', 'MIDI Out 2 (7-pin)', '7-pin DIN',
    '9-12V DC', NULL,
    'Secondary MIDI output; pins 6–7 carry DC phantom power for compatible RJM devices',
    TRUE
FROM products p JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind GT/22';

INSERT INTO jacks (product_id, category, direction, jack_name, connector_type, voltage, current_ma, function, power_over_connector)
SELECT p.id, 'MIDI Out', 'Output', 'MIDI Out 3 (6-pin XLR)', '6-pin XLR',
    '9-12V DC', NULL,
    'GT/22-exclusive 6-pin XLR MIDI output for direct connection to RJM Rack Gizmo / Effect Gizmo; carries DC phantom power on extra pins',
    TRUE
FROM products p JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind GT/22';

INSERT INTO jacks (product_id, category, direction, jack_name, connector_type, function)
SELECT p.id, 'USB', 'Bidirectional', 'USB (Computer)', 'USB-B',
    'Computer connection for MIDI device communication and editor software'
FROM products p JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind GT/22';

INSERT INTO jacks (product_id, category, direction, jack_name, connector_type, function)
SELECT p.id, 'Aux', 'Output', 'USB (Storage)', 'USB-A',
    'Thumb drive connection for settings backup and firmware updates'
FROM products p JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind GT/22';

INSERT INTO jacks (product_id, category, direction, jack_name, connector_type, voltage, current_ma, polarity, function)
SELECT p.id, 'Power Output', 'Output', 'Aux 9V Out 1', '2.1mm barrel',
    '9V DC', 100, 'Center Negative',
    'Auxiliary 9V output (BOSS-style) for powering accessories; 100 mA total shared across both aux outputs'
FROM products p JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind GT/22';

INSERT INTO jacks (product_id, category, direction, jack_name, connector_type, voltage, current_ma, polarity, function)
SELECT p.id, 'Power Output', 'Output', 'Aux 9V Out 2', '2.1mm barrel',
    '9V DC', 100, 'Center Negative',
    'Auxiliary 9V output (BOSS-style) for powering accessories; 100 mA total shared across both aux outputs'
FROM products p JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind GT/22';

INSERT INTO jacks (product_id, category, direction, jack_name, connector_type, function)
SELECT p.id, 'Expression', 'Input', 'Exp 1', '1/4" TRS', 'Expression pedal input; accepts linear or log taper, high or low impedance'
FROM products p JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind GT/22';

INSERT INTO jacks (product_id, category, direction, jack_name, connector_type, function)
SELECT p.id, 'Expression', 'Input', 'Exp 2', '1/4" TRS', 'Expression pedal input; accepts linear or log taper, high or low impedance'
FROM products p JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind GT/22';

INSERT INTO jacks (product_id, category, direction, jack_name, connector_type, function)
SELECT p.id, 'Expression', 'Input', 'Exp 3', '1/4" TRS', 'Expression pedal input; accepts linear or log taper, high or low impedance'
FROM products p JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind GT/22';

INSERT INTO jacks (product_id, category, direction, jack_name, connector_type, function)
SELECT p.id, 'Expression', 'Input', 'Exp 4', '1/4" TRS', 'Expression pedal input; accepts linear or log taper, high or low impedance'
FROM products p JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind GT/22';

INSERT INTO jacks (product_id, category, direction, jack_name, connector_type, function)
SELECT p.id, 'Aux', 'Input', 'Ext Switch 1/2', '1/4" TRS',
    'External switch input; TRS accommodates 2 momentary switches (tip = switch 1, ring = switch 2)'
FROM products p JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind GT/22';

INSERT INTO jacks (product_id, category, direction, jack_name, connector_type, function)
SELECT p.id, 'Aux', 'Input', 'Ext Switch 3/4', '1/4" TRS',
    'External switch input; TRS accommodates 2 momentary switches (tip = switch 3, ring = switch 4)'
FROM products p JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind GT/22';

-- ----------------------------------------
-- Mastermind PBC/6X
-- ----------------------------------------
INSERT INTO jacks (product_id, category, direction, jack_name, connector_type, voltage, current_ma, polarity, function)
SELECT p.id, 'Power Input', 'Input', 'Power', '2.1mm barrel',
    '9-12V DC', 220, 'Center Negative',
    '9V or 12V DC center negative (BOSS-style); 220 mA at 9V'
FROM products p JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind PBC/6X';

INSERT INTO jacks (product_id, category, direction, jack_name, connector_type, function)
SELECT p.id, 'Audio Input', 'Input', 'Main Input', '1/4" TS',
    'Primary guitar/instrument input; passes through switchable input buffer before loop 1'
FROM products p JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind PBC/6X';

INSERT INTO jacks (product_id, category, direction, jack_name, connector_type, function)
SELECT p.id, 'Audio Input', 'Input', 'Secondary Input', '1/4" TS',
    'Secondary unbuffered input (bypasses input buffer); for use with buffered pedals or sources that already have a buffer'
FROM products p JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind PBC/6X';

INSERT INTO jacks (product_id, category, direction, jack_name, connector_type, function)
SELECT p.id, 'Audio Output', 'Output', 'Output A', '1/4" TS',
    'Primary output; signal path after loop 6 and output buffer'
FROM products p JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind PBC/6X';

INSERT INTO jacks (product_id, category, direction, jack_name, connector_type, function, is_isolated, has_phase_invert)
SELECT p.id, 'Audio Output', 'Output', 'Output B', '1/4" TS',
    'Secondary output with isolation transformer and phase invert switch; useful for stereo rigs or eliminating ground loops',
    TRUE, TRUE
FROM products p JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind PBC/6X';

-- Loops 1–3 (mono, TS)
INSERT INTO jacks (product_id, category, direction, jack_name, connector_type, function, group_id)
SELECT p.id, 'Audio Output', 'Output', 'Loop 1 Send', '1/4" TS', 'Loop 1 send to effect input', 'loop_1'
FROM products p JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind PBC/6X';

INSERT INTO jacks (product_id, category, direction, jack_name, connector_type, function, group_id)
SELECT p.id, 'Audio Input', 'Input', 'Loop 1 Return', '1/4" TS', 'Loop 1 return from effect output', 'loop_1'
FROM products p JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind PBC/6X';

INSERT INTO jacks (product_id, category, direction, jack_name, connector_type, function, group_id)
SELECT p.id, 'Audio Output', 'Output', 'Loop 2 Send', '1/4" TS', 'Loop 2 send to effect input', 'loop_2'
FROM products p JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind PBC/6X';

INSERT INTO jacks (product_id, category, direction, jack_name, connector_type, function, group_id)
SELECT p.id, 'Audio Input', 'Input', 'Loop 2 Return', '1/4" TS', 'Loop 2 return from effect output', 'loop_2'
FROM products p JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind PBC/6X';

INSERT INTO jacks (product_id, category, direction, jack_name, connector_type, function, group_id)
SELECT p.id, 'Audio Output', 'Output', 'Loop 3 Send', '1/4" TS', 'Loop 3 send to effect input', 'loop_3'
FROM products p JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind PBC/6X';

INSERT INTO jacks (product_id, category, direction, jack_name, connector_type, function, group_id)
SELECT p.id, 'Audio Input', 'Input', 'Loop 3 Return', '1/4" TS', 'Loop 3 return from effect output', 'loop_3'
FROM products p JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind PBC/6X';

-- Loops 4–6 (stereo-capable, TRS)
INSERT INTO jacks (product_id, category, direction, jack_name, connector_type, function, group_id)
SELECT p.id, 'Audio Output', 'Output', 'Loop 4 Send', '1/4" TRS', 'Loop 4 send; TRS for stereo-capable connections', 'loop_4'
FROM products p JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind PBC/6X';

INSERT INTO jacks (product_id, category, direction, jack_name, connector_type, function, group_id)
SELECT p.id, 'Audio Input', 'Input', 'Loop 4 Return', '1/4" TRS', 'Loop 4 return; TRS for stereo-capable connections', 'loop_4'
FROM products p JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind PBC/6X';

INSERT INTO jacks (product_id, category, direction, jack_name, connector_type, function, group_id)
SELECT p.id, 'Audio Output', 'Output', 'Loop 5 Send', '1/4" TRS', 'Loop 5 send; TRS for stereo-capable connections', 'loop_5'
FROM products p JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind PBC/6X';

INSERT INTO jacks (product_id, category, direction, jack_name, connector_type, function, group_id)
SELECT p.id, 'Audio Input', 'Input', 'Loop 5 Return', '1/4" TRS', 'Loop 5 return; TRS for stereo-capable connections', 'loop_5'
FROM products p JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind PBC/6X';

INSERT INTO jacks (product_id, category, direction, jack_name, connector_type, function, group_id)
SELECT p.id, 'Audio Output', 'Output', 'Loop 6 Send', '1/4" TRS', 'Loop 6 send; TRS for stereo-capable connections', 'loop_6'
FROM products p JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind PBC/6X';

INSERT INTO jacks (product_id, category, direction, jack_name, connector_type, function, group_id)
SELECT p.id, 'Audio Input', 'Input', 'Loop 6 Return', '1/4" TRS', 'Loop 6 return; TRS for stereo-capable connections', 'loop_6'
FROM products p JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind PBC/6X';

-- Buffered insert loop
INSERT INTO jacks (product_id, category, direction, jack_name, connector_type, function, is_buffered, group_id)
SELECT p.id, 'Audio Output', 'Output', 'Insert Send', '1/4" TS',
    'Buffered insert loop send; always passes through a buffer regardless of bypass state', TRUE, 'insert'
FROM products p JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind PBC/6X';

INSERT INTO jacks (product_id, category, direction, jack_name, connector_type, function, is_buffered, group_id)
SELECT p.id, 'Audio Input', 'Input', 'Insert Return', '1/4" TS',
    'Buffered insert loop return', TRUE, 'insert'
FROM products p JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind PBC/6X';

INSERT INTO jacks (product_id, category, direction, jack_name, connector_type, function)
SELECT p.id, 'MIDI Out', 'Output', 'MIDI Out', '5-pin DIN',
    'MIDI output for connected devices; can be split into MIDI In + MIDI Out using an optional TRS-to-DIN Y cable'
FROM products p JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind PBC/6X';

INSERT INTO jacks (product_id, category, direction, jack_name, connector_type, function)
SELECT p.id, 'USB', 'Bidirectional', 'USB', 'USB-B',
    'Computer connection for editor software and MIDI communication'
FROM products p JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind PBC/6X';

INSERT INTO jacks (product_id, category, direction, jack_name, connector_type, function)
SELECT p.id, 'Expression', 'Input', 'Exp 1', '1/4" TRS',
    'Expression pedal input; programmable for MIDI CC output'
FROM products p JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind PBC/6X';

INSERT INTO jacks (product_id, category, direction, jack_name, connector_type, function)
SELECT p.id, 'Aux', 'Output', 'Function Out 1', '1/4" TRS',
    'Function switch output for amp channel switching or other latching/momentary control'
FROM products p JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind PBC/6X';

INSERT INTO jacks (product_id, category, direction, jack_name, connector_type, function)
SELECT p.id, 'Aux', 'Output', 'Function Out 2', '1/4" TRS',
    'Function switch output for amp channel switching or other latching/momentary control'
FROM products p JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind PBC/6X';

INSERT INTO jacks (product_id, category, direction, jack_name, connector_type, function)
SELECT p.id, 'Aux', 'Input', 'Ext Switch', '1/4" TRS',
    'External switch input; TRS accommodates 2 momentary footswitches for additional control'
FROM products p JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind PBC/6X';

-- ----------------------------------------
-- Mastermind PBC/10
-- ----------------------------------------
INSERT INTO jacks (product_id, category, direction, jack_name, connector_type, voltage, current_ma, function)
SELECT p.id, 'Power Input', 'Input', 'Power', '2.1mm barrel',
    '9V DC / 12V DC / 9V AC', 500,
    '9V DC @ 500 mA, 12V DC @ 400 mA, or 9V AC @ 400 mA; compatible with Voodoo Lab supplies'
FROM products p JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind PBC/10';

INSERT INTO jacks (product_id, category, direction, jack_name, connector_type, function)
SELECT p.id, 'Audio Input', 'Input', 'Main Input', '1/4" TS',
    'Primary guitar/instrument input; passes through switchable input buffer before loop 1'
FROM products p JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind PBC/10';

INSERT INTO jacks (product_id, category, direction, jack_name, connector_type, function)
SELECT p.id, 'Audio Output', 'Output', 'Output A', '1/4" TS',
    'Primary output after all loops and output buffer'
FROM products p JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind PBC/10';

INSERT INTO jacks (product_id, category, direction, jack_name, connector_type, function, is_isolated, has_phase_invert)
SELECT p.id, 'Audio Output', 'Output', 'Output B', '1/4" TS',
    'Secondary output with isolation transformer and phase invert switch',
    TRUE, TRUE
FROM products p JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind PBC/10';

-- Loops 1–6 (mono, TS)
INSERT INTO jacks (product_id, category, direction, jack_name, connector_type, function, group_id)
SELECT p.id, 'Audio Output', 'Output', 'Loop 1 Send', '1/4" TS', 'Loop 1 send to effect input', 'loop_1'
FROM products p JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind PBC/10';

INSERT INTO jacks (product_id, category, direction, jack_name, connector_type, function, group_id)
SELECT p.id, 'Audio Input', 'Input', 'Loop 1 Return', '1/4" TS', 'Loop 1 return from effect output', 'loop_1'
FROM products p JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind PBC/10';

INSERT INTO jacks (product_id, category, direction, jack_name, connector_type, function, group_id)
SELECT p.id, 'Audio Output', 'Output', 'Loop 2 Send', '1/4" TS', 'Loop 2 send to effect input', 'loop_2'
FROM products p JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind PBC/10';

INSERT INTO jacks (product_id, category, direction, jack_name, connector_type, function, group_id)
SELECT p.id, 'Audio Input', 'Input', 'Loop 2 Return', '1/4" TS', 'Loop 2 return from effect output', 'loop_2'
FROM products p JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind PBC/10';

INSERT INTO jacks (product_id, category, direction, jack_name, connector_type, function, group_id)
SELECT p.id, 'Audio Output', 'Output', 'Loop 3 Send', '1/4" TS', 'Loop 3 send to effect input', 'loop_3'
FROM products p JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind PBC/10';

INSERT INTO jacks (product_id, category, direction, jack_name, connector_type, function, group_id)
SELECT p.id, 'Audio Input', 'Input', 'Loop 3 Return', '1/4" TS', 'Loop 3 return from effect output', 'loop_3'
FROM products p JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind PBC/10';

INSERT INTO jacks (product_id, category, direction, jack_name, connector_type, function, group_id)
SELECT p.id, 'Audio Output', 'Output', 'Loop 4 Send', '1/4" TS', 'Loop 4 send to effect input', 'loop_4'
FROM products p JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind PBC/10';

INSERT INTO jacks (product_id, category, direction, jack_name, connector_type, function, group_id)
SELECT p.id, 'Audio Input', 'Input', 'Loop 4 Return', '1/4" TS', 'Loop 4 return from effect output', 'loop_4'
FROM products p JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind PBC/10';

INSERT INTO jacks (product_id, category, direction, jack_name, connector_type, function, group_id)
SELECT p.id, 'Audio Output', 'Output', 'Loop 5 Send', '1/4" TS', 'Loop 5 send to effect input', 'loop_5'
FROM products p JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind PBC/10';

INSERT INTO jacks (product_id, category, direction, jack_name, connector_type, function, group_id)
SELECT p.id, 'Audio Input', 'Input', 'Loop 5 Return', '1/4" TS', 'Loop 5 return from effect output', 'loop_5'
FROM products p JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind PBC/10';

INSERT INTO jacks (product_id, category, direction, jack_name, connector_type, function, group_id)
SELECT p.id, 'Audio Output', 'Output', 'Loop 6 Send', '1/4" TS', 'Loop 6 send to effect input', 'loop_6'
FROM products p JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind PBC/10';

INSERT INTO jacks (product_id, category, direction, jack_name, connector_type, function, group_id)
SELECT p.id, 'Audio Input', 'Input', 'Loop 6 Return', '1/4" TS', 'Loop 6 return from effect output', 'loop_6'
FROM products p JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind PBC/10';

-- Loops 7–10 (stereo-capable TRS; can run series or parallel per preset)
INSERT INTO jacks (product_id, category, direction, jack_name, connector_type, function, group_id)
SELECT p.id, 'Audio Output', 'Output', 'Loop 7 Send', '1/4" TRS', 'Loop 7 send; TRS stereo-capable; series/parallel switchable', 'loop_7'
FROM products p JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind PBC/10';

INSERT INTO jacks (product_id, category, direction, jack_name, connector_type, function, group_id)
SELECT p.id, 'Audio Input', 'Input', 'Loop 7 Return', '1/4" TRS', 'Loop 7 return; TRS stereo-capable; series/parallel switchable', 'loop_7'
FROM products p JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind PBC/10';

INSERT INTO jacks (product_id, category, direction, jack_name, connector_type, function, group_id)
SELECT p.id, 'Audio Output', 'Output', 'Loop 8 Send', '1/4" TRS', 'Loop 8 send; TRS stereo-capable; series/parallel switchable', 'loop_8'
FROM products p JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind PBC/10';

INSERT INTO jacks (product_id, category, direction, jack_name, connector_type, function, group_id)
SELECT p.id, 'Audio Input', 'Input', 'Loop 8 Return', '1/4" TRS', 'Loop 8 return; TRS stereo-capable; series/parallel switchable', 'loop_8'
FROM products p JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind PBC/10';

INSERT INTO jacks (product_id, category, direction, jack_name, connector_type, function, group_id)
SELECT p.id, 'Audio Output', 'Output', 'Loop 9 Send', '1/4" TRS', 'Loop 9 send; TRS stereo-capable; series/parallel switchable', 'loop_9'
FROM products p JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind PBC/10';

INSERT INTO jacks (product_id, category, direction, jack_name, connector_type, function, group_id)
SELECT p.id, 'Audio Input', 'Input', 'Loop 9 Return', '1/4" TRS', 'Loop 9 return; TRS stereo-capable; series/parallel switchable', 'loop_9'
FROM products p JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind PBC/10';

INSERT INTO jacks (product_id, category, direction, jack_name, connector_type, function, group_id)
SELECT p.id, 'Audio Output', 'Output', 'Loop 10 Send', '1/4" TRS', 'Loop 10 send; TRS stereo-capable; series/parallel switchable', 'loop_10'
FROM products p JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind PBC/10';

INSERT INTO jacks (product_id, category, direction, jack_name, connector_type, function, group_id)
SELECT p.id, 'Audio Input', 'Input', 'Loop 10 Return', '1/4" TRS', 'Loop 10 return; TRS stereo-capable; series/parallel switchable', 'loop_10'
FROM products p JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind PBC/10';

INSERT INTO jacks (product_id, category, direction, jack_name, connector_type, function)
SELECT p.id, 'MIDI Out', 'Output', 'MIDI Out', '5-pin DIN',
    'MIDI output for connected devices'
FROM products p JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind PBC/10';

INSERT INTO jacks (product_id, category, direction, jack_name, connector_type, function)
SELECT p.id, 'MIDI In', 'Input', 'MIDI In', '5-pin DIN',
    'MIDI input for receiving clock and external MIDI control'
FROM products p JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind PBC/10';

INSERT INTO jacks (product_id, category, direction, jack_name, connector_type, function)
SELECT p.id, 'USB', 'Bidirectional', 'USB Device', 'USB-B',
    'Computer connection (PC/Mac) for editor software and MIDI communication'
FROM products p JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind PBC/10';

INSERT INTO jacks (product_id, category, direction, jack_name, connector_type, function)
SELECT p.id, 'Aux', 'Output', 'USB Host', 'USB-A',
    'USB host port for thumb drive connection (settings backup and firmware updates)'
FROM products p JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind PBC/10';

INSERT INTO jacks (product_id, category, direction, jack_name, connector_type, function)
SELECT p.id, 'Expression', 'Input', 'Exp 1', '1/4" TRS',
    'Expression pedal input; programmable for MIDI CC output'
FROM products p JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind PBC/10';

INSERT INTO jacks (product_id, category, direction, jack_name, connector_type, function)
SELECT p.id, 'Aux', 'Input', 'Ext Switch 1/2', '1/4" TRS',
    'External switch input; TRS accommodates 2 momentary footswitches'
FROM products p JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind PBC/10';

INSERT INTO jacks (product_id, category, direction, jack_name, connector_type, function)
SELECT p.id, 'Aux', 'Input', 'Ext Switch 3/4', '1/4" TRS',
    'External switch input; TRS accommodates 2 momentary footswitches'
FROM products p JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'RJM Music Technology' AND p.model = 'Mastermind PBC/10';

COMMIT;
