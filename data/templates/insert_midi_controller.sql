-- =============================================================================
-- INSERT TEMPLATE: MIDI CONTROLLER
-- =============================================================================
-- Product type ID: 4
--
-- Usage: Fill in all {{placeholder}} values with researched data.
-- For unknown/unfound values, use NULL (not 0 or empty string).
-- Wrap the entire insert in a transaction so all tables succeed or fail together.
--
-- Before running: verify the manufacturer exists with:
--   SELECT id, name FROM manufacturers WHERE name ILIKE '%{{manufacturer_name}}%';
-- =============================================================================

BEGIN;

-- ─── MANUFACTURER (uncomment if new) ────────────────────────────────────────
-- INSERT INTO manufacturers (name, country, founded, status, specialty, website, notes)
-- VALUES (
--     '{{manufacturer_name}}',
--     '{{country}}',
--     '{{founded}}',
--     '{{status}}',                -- 'Active', 'Defunct', 'Discontinued', 'Unknown'
--     '{{specialty}}',
--     '{{website}}',
--     '{{notes}}'
-- );

-- ─── PRODUCT ────────────────────────────────────────────────────────────────
INSERT INTO products (
    manufacturer_id, product_type_id, model,
    color_options, in_production,
    width_mm, depth_mm, height_mm, weight_grams,
    msrp_cents, product_page, instruction_manual,
    description, tags, data_reliability, notes
) VALUES (
    {{manufacturer_id}},            -- FK to manufacturers.id
    4,                              -- product_type_id = midi_controller
    '{{model}}',
    {{color_options}},
    {{in_production}},
    {{width_mm}},
    {{depth_mm}},
    {{height_mm}},
    {{weight_grams}},
    {{msrp_cents}},
    {{product_page}},
    {{instruction_manual}},
    {{description}},
    {{tags}},
    '{{data_reliability}}',
    {{notes}}
);

-- ─── MIDI CONTROLLER DETAILS ────────────────────────────────────────────────
INSERT INTO midi_controller_details (
    product_id,
    -- Footswitches
    footswitch_count, footswitch_type, has_led_indicators, led_color_options,
    -- Banks and presets
    bank_count, presets_per_bank, total_preset_slots,
    -- Display
    has_display, display_type, display_size,
    -- Expression
    expression_input_count,
    -- MIDI
    midi_channels, supports_midi_clock, supports_sysex,
    -- Software
    software_editor_available, software_platforms, on_device_programming,
    is_firmware_updatable, config_format, config_format_documented,
    -- Features
    has_tuner, has_tap_tempo, has_setlist_mode, has_per_switch_displays,
    aux_switch_input_count, has_usb_host, has_bluetooth_midi,
    -- Loops
    audio_loop_count, has_reorderable_loops, loop_bypass_type,
    has_parallel_routing, has_gapless_switching, has_spillover
) VALUES (
    currval('products_id_seq'),
    -- Footswitches
    {{footswitch_count}},           -- REQUIRED (NOT NULL)
    '{{footswitch_type}}',          -- 'Momentary', 'Latching', 'Dual-Action', 'Mixed'
    {{has_led_indicators}},         -- TRUE/FALSE (default TRUE)
    {{led_color_options}},          -- e.g., 'RGB' or NULL
    -- Banks and presets
    {{bank_count}},                 -- or NULL
    {{presets_per_bank}},           -- or NULL
    {{total_preset_slots}},         -- or NULL
    -- Display
    {{has_display}},                -- TRUE/FALSE (default FALSE)
    {{display_type}},               -- e.g., 'OLED', 'LCD' or NULL
    {{display_size}},               -- e.g., '128x64' or NULL
    -- Expression
    {{expression_input_count}},     -- INTEGER (default 0)
    -- MIDI
    {{midi_channels}},              -- INTEGER (default 16)
    {{supports_midi_clock}},        -- TRUE/FALSE (default FALSE)
    {{supports_sysex}},             -- TRUE/FALSE (default FALSE)
    -- Software
    {{software_editor_available}},  -- TRUE/FALSE (default FALSE)
    {{software_platforms}},         -- e.g., 'macOS, Windows, iOS' or NULL
    {{on_device_programming}},      -- TRUE/FALSE (default FALSE)
    {{is_firmware_updatable}},      -- TRUE/FALSE (default FALSE)
    {{config_format}},              -- e.g., 'JSON', 'SysEx' or NULL
    {{config_format_documented}},   -- TRUE/FALSE (default FALSE)
    -- Features
    {{has_tuner}},                  -- TRUE/FALSE (default FALSE)
    {{has_tap_tempo}},              -- TRUE/FALSE (default FALSE)
    {{has_setlist_mode}},           -- TRUE/FALSE (default FALSE)
    {{has_per_switch_displays}},    -- TRUE/FALSE (default FALSE)
    {{aux_switch_input_count}},     -- INTEGER (default 0)
    {{has_usb_host}},               -- TRUE/FALSE (default FALSE)
    {{has_bluetooth_midi}},         -- TRUE/FALSE (default FALSE)
    -- Loops
    {{audio_loop_count}},           -- INTEGER (default 0)
    {{has_reorderable_loops}},      -- TRUE/FALSE (default FALSE)
    {{loop_bypass_type}},           -- e.g., 'True Bypass', 'Relay' or NULL
    {{has_parallel_routing}},       -- TRUE/FALSE (default FALSE)
    {{has_gapless_switching}},      -- TRUE/FALSE (default FALSE)
    {{has_spillover}}               -- TRUE/FALSE (default FALSE)
);

-- ─── JACKS ──────────────────────────────────────────────────────────────────

-- Power input
INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '{{power_connector}}', '{{power_voltage}}', {{power_current_ma}}, '{{power_polarity}}');

-- MIDI output (required — primary function)
INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, position)
VALUES (currval('products_id_seq'), 'midi', 'output', '{{midi_out_connector}}', 'MIDI Out', '{{midi_out_position}}');

-- ─── OPTIONAL JACKS (uncomment as needed) ───────────────────────────────────

-- MIDI input
-- INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, position)
-- VALUES (currval('products_id_seq'), 'midi', 'input', '{{midi_in_connector}}', 'MIDI In', '{{midi_in_position}}');

-- MIDI thru
-- INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, position)
-- VALUES (currval('products_id_seq'), 'midi', 'output', '{{midi_thru_connector}}', 'MIDI Thru', '{{midi_thru_position}}');

-- Expression input(s)
-- INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, position)
-- VALUES (currval('products_id_seq'), 'expression', 'input', '1/4" TRS', 'Expression 1', '{{exp_position}}');

-- USB
-- INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, position)
-- VALUES (currval('products_id_seq'), 'usb', 'bidirectional', '{{usb_connector}}', 'USB', '{{usb_position}}');

-- Aux switch input(s)
-- INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, position)
-- VALUES (currval('products_id_seq'), 'aux', 'input', '1/4" TRS', 'Aux Switch 1', '{{aux_position}}');

-- Audio loop send/return (repeat for each loop)
-- INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, position, group_id)
-- VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Loop 1 Send', 'top', 'loop_1');
-- INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, position, group_id)
-- VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS', 'Loop 1 Return', 'top', 'loop_1');

-- ─── PRODUCT COMPATIBILITY (uncomment if applicable) ────────────────────────
-- INSERT INTO product_compatibility (product_a_id, product_b_id, compatibility_type, notes, source, verified)
-- VALUES (
--     currval('products_id_seq'),
--     {{related_product_id}},
--     '{{compatibility_type}}',    -- 'Mounting', 'Power', 'MIDI', 'Accessory', 'Replacement'
--     '{{compatibility_notes}}',
--     '{{compatibility_source}}',
--     {{verified}}
-- );

COMMIT;
