-- =============================================================================
-- INSERT TEMPLATE: PEDAL
-- =============================================================================
-- Product type ID: 1
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
--     '{{country}}',               -- e.g., 'USA', 'Japan', 'UK'
--     '{{founded}}',               -- e.g., '2004', 'circa 1970'
--     '{{status}}',                -- 'Active', 'Defunct', 'Discontinued', 'Unknown'
--     '{{specialty}}',             -- e.g., 'Boutique overdrives'
--     '{{website}}',               -- e.g., 'https://example.com'
--     '{{notes}}'                  -- Internal notes
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
    1,                              -- product_type_id = pedal
    '{{model}}',                    -- e.g., 'Morning Glory V4'
    {{color_options}},              -- e.g., 'Blue, Red' or NULL
    {{in_production}},              -- TRUE or FALSE
    {{width_mm}},                   -- mm (DOUBLE PRECISION) or NULL
    {{depth_mm}},                   -- mm (DOUBLE PRECISION) or NULL
    {{height_mm}},                  -- mm (DOUBLE PRECISION) or NULL
    {{weight_grams}},               -- grams (INTEGER) or NULL
    {{msrp_cents}},                 -- cents (INTEGER) or NULL — $99.00 = 9900
    {{product_page}},               -- URL or NULL
    {{instruction_manual}},         -- URL or NULL
    {{description}},                -- User-facing summary or NULL
    {{tags}},                       -- e.g., 'transparent, amp-in-a-box' or NULL
    '{{data_reliability}}',         -- 'High', 'Medium', or 'Low'
    {{notes}}                       -- Internal data curation notes or NULL
);

-- ─── PEDAL DETAILS ──────────────────────────────────────────────────────────
INSERT INTO pedal_details (
    product_id,
    -- Classification
    effect_type, circuit_type, circuit_routing_options,
    -- Signal
    signal_type, bypass_type, mono_stereo,
    audio_mix, has_analog_dry_through, has_spillover,
    -- Digital specs
    sample_rate_khz, bit_depth, latency_ms,
    -- Capabilities
    preset_count, has_tap_tempo,
    -- MIDI
    midi_capable, midi_receive_capabilities, midi_send_capabilities,
    -- Software
    has_software_editor, software_platforms, is_firmware_updatable, has_usb_audio,
    -- Power
    battery_capable,
    -- Loops
    fx_loop_count, has_reorderable_loops
) VALUES (
    currval('products_id_seq'),
    -- Classification
    '{{effect_type}}',              -- CHECK: 'Gain', 'Fuzz', 'Compression', 'Delay', 'Reverb', etc.
    {{circuit_type}},               -- e.g., 'Bluesbreaker' or NULL
    {{circuit_routing_options}},    -- e.g., 'A→B, B→A, Parallel' or NULL
    -- Signal
    '{{signal_type}}',              -- 'Analog', 'Digital', 'Hybrid'
    '{{bypass_type}}',              -- 'True Bypass', 'Buffered Bypass', 'Relay Bypass', 'DSP Bypass', 'Both'
    '{{mono_stereo}}',              -- 'Mono', 'Stereo In/Out', 'Mono In/Stereo Out'
    {{audio_mix}},                  -- e.g., 'Wet/Dry' or NULL
    {{has_analog_dry_through}},     -- TRUE/FALSE (default FALSE)
    {{has_spillover}},              -- TRUE/FALSE (default FALSE)
    -- Digital specs (NULL for analog pedals)
    {{sample_rate_khz}},            -- e.g., 48, 96 or NULL
    {{bit_depth}},                  -- e.g., 24, 32 or NULL
    {{latency_ms}},                 -- e.g., 1.5 or NULL
    -- Capabilities
    {{preset_count}},               -- INTEGER (default 0)
    {{has_tap_tempo}},              -- TRUE/FALSE (default FALSE)
    -- MIDI
    {{midi_capable}},               -- TRUE/FALSE (default FALSE)
    {{midi_receive_capabilities}},  -- e.g., 'PC, CC, Clock' or NULL
    {{midi_send_capabilities}},     -- e.g., 'PC, CC' or NULL
    -- Software
    {{has_software_editor}},        -- TRUE/FALSE (default FALSE)
    {{software_platforms}},         -- e.g., 'macOS, Windows, iOS' or NULL
    {{is_firmware_updatable}},      -- TRUE/FALSE (default FALSE)
    {{has_usb_audio}},              -- TRUE/FALSE (default FALSE)
    -- Power
    {{battery_capable}},            -- TRUE/FALSE (default FALSE)
    -- Loops
    {{fx_loop_count}},              -- INTEGER (default 0)
    {{has_reorderable_loops}}       -- TRUE/FALSE (default FALSE)
);

-- ─── JACKS ──────────────────────────────────────────────────────────────────

-- Power input (required for all active pedals)
INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '{{power_connector}}', '{{power_voltage}}', {{power_current_ma}}, '{{power_polarity}}');

-- Audio input
INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, position)
VALUES (currval('products_id_seq'), 'audio', 'input', '{{audio_in_connector}}', '{{audio_in_name}}', '{{audio_in_position}}');

-- Audio output
INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, position)
VALUES (currval('products_id_seq'), 'audio', 'output', '{{audio_out_connector}}', '{{audio_out_name}}', '{{audio_out_position}}');

-- ─── OPTIONAL JACKS (uncomment as needed) ───────────────────────────────────

-- Second audio input (stereo pedals)
-- INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, position, group_id)
-- VALUES (currval('products_id_seq'), 'audio', 'input', '1/4" TS', 'Input R', 'right', 'stereo_in');

-- Second audio output (stereo pedals)
-- INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, position, group_id)
-- VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Output R', 'right', 'stereo_out');

-- MIDI input
-- INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, position)
-- VALUES (currval('products_id_seq'), 'midi', 'input', '{{midi_in_connector}}', 'MIDI In', '{{midi_in_position}}');

-- MIDI output
-- INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, position)
-- VALUES (currval('products_id_seq'), 'midi', 'output', '{{midi_out_connector}}', 'MIDI Out', '{{midi_out_position}}');

-- MIDI thru
-- INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, position)
-- VALUES (currval('products_id_seq'), 'midi', 'output', '{{midi_thru_connector}}', 'MIDI Thru', '{{midi_thru_position}}');

-- Expression input
-- INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, position)
-- VALUES (currval('products_id_seq'), 'expression', 'input', '1/4" TRS', 'Expression', '{{exp_position}}');

-- USB
-- INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, position)
-- VALUES (currval('products_id_seq'), 'usb', 'bidirectional', '{{usb_connector}}', 'USB', '{{usb_position}}');

-- FX loop send/return (repeat for each loop)
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
--     '{{compatibility_source}}',  -- 'Manufacturer', 'User tested', etc.
--     {{verified}}                 -- TRUE/FALSE
-- );

COMMIT;
