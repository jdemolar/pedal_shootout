-- =============================================================================
-- INSERT TEMPLATE: POWER SUPPLY
-- =============================================================================
-- Product type ID: 2
--
-- Usage: Fill in all {{placeholder}} values with researched data.
-- For unknown/unfound values, use NULL (not 0 or empty string).
-- Wrap the entire insert in a transaction so all tables succeed or fail together.
--
-- IMPORTANT: Power supplies need jacks for EVERY physical port — all power
-- outputs, the AC/DC input, and any expansion/link ports. This data drives
-- the power budgeting tool.
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
    2,                              -- product_type_id = power_supply
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

-- ─── POWER SUPPLY DETAILS ───────────────────────────────────────────────────
INSERT INTO power_supply_details (
    product_id,
    -- Type
    supply_type, topology,
    -- Input
    input_voltage_range, input_frequency,
    -- Output
    total_output_count, total_current_ma, isolated_output_count,
    -- Voltage
    available_voltages, has_variable_voltage, voltage_range,
    -- Mounting
    mounting_type, bracket_included,
    -- Expansion
    is_expandable, expansion_port_type,
    -- Battery
    is_battery_powered, battery_capacity_wh
) VALUES (
    currval('products_id_seq'),
    -- Type
    '{{supply_type}}',              -- 'Isolated', 'Non-Isolated', 'Hybrid'
    '{{topology}}',                 -- 'Switch Mode', 'Toroidal', 'Linear', 'Unknown'
    -- Input
    '{{input_voltage_range}}',      -- e.g., '100-240V AC', '9V DC'
    {{input_frequency}},            -- e.g., '50/60Hz' or NULL
    -- Output
    {{total_output_count}},         -- REQUIRED (NOT NULL) — total number of power outputs
    {{total_current_ma}},           -- Sum of all output mA ratings or NULL
    {{isolated_output_count}},      -- Count of isolated outputs (default 0)
    -- Voltage
    {{available_voltages}},         -- e.g., '9V DC (5 × 500mA)' or NULL
    {{has_variable_voltage}},       -- TRUE/FALSE (default FALSE)
    {{voltage_range}},              -- e.g., '9-18V' or NULL
    -- Mounting
    '{{mounting_type}}',            -- 'Under Board', 'On Board', 'External', 'Rack'
    {{bracket_included}},           -- TRUE/FALSE (default FALSE)
    -- Expansion
    {{is_expandable}},              -- TRUE/FALSE (default FALSE)
    {{expansion_port_type}},        -- e.g., 'EIAJ-05' or NULL
    -- Battery
    {{is_battery_powered}},         -- TRUE/FALSE (default FALSE)
    {{battery_capacity_wh}}         -- Watt-hours or NULL
);

-- ─── JACKS ──────────────────────────────────────────────────────────────────

-- AC mains input (for units with IEC connector)
INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, voltage, current_ma, polarity)
VALUES (currval('products_id_seq'), 'power', 'input', '{{input_connector}}', '{{input_jack_name}}', '{{input_voltage}}', {{input_current_ma}}, {{input_polarity}});

-- Power output 1 (repeat for each output — one INSERT per physical output jack)
INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, voltage, current_ma, polarity, is_isolated)
VALUES (currval('products_id_seq'), 'power', 'output', '{{out1_connector}}', '{{out1_name}}', '{{out1_voltage}}', {{out1_current_ma}}, '{{out1_polarity}}', {{out1_isolated}});

-- Power output 2
-- INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, voltage, current_ma, polarity, is_isolated)
-- VALUES (currval('products_id_seq'), 'power', 'output', '{{out2_connector}}', '{{out2_name}}', '{{out2_voltage}}', {{out2_current_ma}}, '{{out2_polarity}}', {{out2_isolated}});

-- (Continue for each output...)

-- ─── OPTIONAL JACKS (uncomment as needed) ───────────────────────────────────

-- DC link input (for daisy-chainable units like Strymon Ojai)
-- INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, voltage, current_ma, polarity)
-- VALUES (currval('products_id_seq'), 'power', 'input', 'EIAJ-05', 'DC Link In', '24V', 1000, 'center-positive');

-- DC link thru/output (passthrough to next unit)
-- INSERT INTO jacks (product_id, category, direction, connector_type, jack_name, voltage, polarity)
-- VALUES (currval('products_id_seq'), 'power', 'output', 'EIAJ-05', 'DC Link Thru', '24V', 'center-positive');

-- USB port (for firmware updates, etc.)
-- INSERT INTO jacks (product_id, category, direction, connector_type, jack_name)
-- VALUES (currval('products_id_seq'), 'usb', 'bidirectional', '{{usb_connector}}', 'USB');

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
