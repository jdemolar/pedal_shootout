-- =============================================================================
-- INSERT TEMPLATE: UTILITY
-- =============================================================================
-- Product type ID: 5
--
-- Usage: Fill in all {{placeholder}} values with researched data.
-- For unknown/unfound values, use NULL (not 0 or empty string).
-- Wrap the entire insert in a transaction so all tables succeed or fail together.
--
-- Note: Utility products are diverse (DI boxes, tuners, volume pedals, load
-- boxes, etc.). Many fields in utility_details are subtype-specific — only
-- fill in the fields relevant to the utility_type. Leave others as NULL.
-- Passive devices (passive DI, passive reamp) do NOT need a power input jack.
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
    5,                              -- product_type_id = utility
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

-- ─── UTILITY DETAILS ────────────────────────────────────────────────────────
INSERT INTO utility_details (
    product_id,
    -- Type
    utility_type, is_active, signal_type, bypass_type,
    -- DI fields
    has_ground_lift, has_pad, pad_db,
    -- Tuner fields
    tuning_display_type, tuning_accuracy_cents, polyphonic_tuning,
    -- Volume/Expression fields
    sweep_type, has_tuner_out, has_minimum_volume, has_polarity_switch,
    -- Load box fields
    power_handling_watts, has_reactive_load, has_attenuation, attenuation_range_db, has_cab_sim
) VALUES (
    currval('products_id_seq'),
    -- Type
    '{{utility_type}}',             -- REQUIRED: 'DI Box', 'Reamp Box', 'Buffer', 'Tuner', 'Volume Pedal', etc.
    {{is_active}},                  -- TRUE/FALSE (default FALSE) — requires power?
    '{{signal_type}}',              -- 'Analog', 'Digital', 'Both'
    {{bypass_type}},                -- e.g., 'True Bypass' or NULL

    -- DI-specific (NULL for non-DI types)
    {{has_ground_lift}},            -- TRUE/FALSE or NULL
    {{has_pad}},                    -- TRUE/FALSE or NULL
    {{pad_db}},                     -- e.g., -20 or NULL

    -- Tuner-specific (NULL for non-tuner types)
    {{tuning_display_type}},        -- 'Strobe', 'Needle', 'LED', 'LCD' or NULL
    {{tuning_accuracy_cents}},      -- e.g., 0.1, 0.5, 1.0 or NULL
    {{polyphonic_tuning}},          -- TRUE/FALSE (default FALSE)

    -- Volume/Expression-specific (NULL for non-volume/expression types)
    {{sweep_type}},                 -- 'Linear', 'Audio Taper', 'Logarithmic' or NULL
    {{has_tuner_out}},              -- TRUE/FALSE (default FALSE)
    {{has_minimum_volume}},         -- TRUE/FALSE (default FALSE)
    {{has_polarity_switch}},        -- TRUE/FALSE (default FALSE)

    -- Load box-specific (NULL for non-load-box types)
    {{power_handling_watts}},       -- e.g., 100 or NULL
    {{has_reactive_load}},          -- TRUE/FALSE (default FALSE)
    {{has_attenuation}},            -- TRUE/FALSE (default FALSE)
    {{attenuation_range_db}},       -- e.g., '-20 to 0' or NULL
    {{has_cab_sim}}                 -- TRUE/FALSE (default FALSE)
);

-- ─── JACKS ──────────────────────────────────────────────────────────────────

-- Audio input
INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, position)
VALUES (currval('products_id_seq'), 'audio', 'input', '{{audio_in_connector}}', '{{audio_in_name}}', '{{audio_in_position}}');

-- Audio output
INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, position)
VALUES (currval('products_id_seq'), 'audio', 'output', '{{audio_out_connector}}', '{{audio_out_name}}', '{{audio_out_position}}');

-- Power input (only for active devices — omit for passive DI, passive reamp, etc.)
-- INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
-- VALUES (currval('products_id_seq'), 'power', 'input', '{{power_connector}}', '{{power_voltage}}', {{power_current_ma}}, '{{power_polarity}}');

-- ─── OPTIONAL JACKS (uncomment as needed) ───────────────────────────────────

-- XLR output (DI boxes)
-- INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, position)
-- VALUES (currval('products_id_seq'), 'audio', 'output', 'XLR', 'XLR Out', 'back');

-- Thru jack (DI boxes, tuners)
-- INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, position)
-- VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Thru', 'back');

-- Tuner output (volume pedals)
-- INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, position)
-- VALUES (currval('products_id_seq'), 'audio', 'output', '1/4" TS', 'Tuner Out', 'back');

-- Speaker input (load boxes)
-- INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, position)
-- VALUES (currval('products_id_seq'), 'audio', 'input', 'Speakon', 'Speaker In', 'back');

-- USB
-- INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, position)
-- VALUES (currval('products_id_seq'), 'usb', 'bidirectional', '{{usb_connector}}', 'USB', '{{usb_position}}');

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
