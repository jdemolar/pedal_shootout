-- Guitar Gear Database Schema (PostgreSQL)
-- Migrated from SQLite schema (gear_sqlite.sql.bak)
--
-- PostgreSQL enforces foreign keys by default — no PRAGMA needed.

-- =============================================================================
-- CORE TABLES
-- =============================================================================

-- Manufacturers table (source of truth for all manufacturer values)
CREATE TABLE manufacturers (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,            -- Official company/brand name
    country TEXT,                         -- Country of origin (e.g., 'USA', 'Japan')
    founded TEXT,                         -- Year founded (TEXT to allow 'circa 1970', 'early 1980s')
    status TEXT CHECK(status IN ('Active', 'Defunct', 'Discontinued', 'Unknown')) DEFAULT 'Unknown',
    specialty TEXT,                       -- What they're known for (e.g., 'Fuzz pedals', 'Boutique overdrives')
    website TEXT,                         -- Official website URL
    notes TEXT,                           -- Internal notes (history, ownership changes, etc.)
    updated_at TIMESTAMPTZ               -- Last modified timestamp
);

-- Product types (enum reference table)
CREATE TABLE product_types (
    id INTEGER PRIMARY KEY,              -- Fixed IDs (not auto-increment) for stable references
    type_name TEXT NOT NULL UNIQUE,      -- Machine-readable identifier (e.g., 'pedal', 'power_supply')
    description TEXT                     -- Human-readable description of this product category
);

INSERT INTO product_types (id, type_name, description) VALUES
    (1, 'pedal', 'Effect pedals'),
    (2, 'power_supply', 'Pedalboard power supplies'),
    (3, 'pedalboard', 'Pedalboards and cases'),
    (4, 'midi_controller', 'MIDI foot controllers'),
    (5, 'utility', 'DI boxes, buffers, splitters, tuners, etc.'),
    (6, 'plug', 'Cable plugs/connectors for layout planning');

-- Products base table (shared attributes for all product types)
CREATE TABLE products (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    manufacturer_id INTEGER NOT NULL,     -- FK to manufacturers table
    product_type_id INTEGER NOT NULL,     -- FK to product_types table
    model TEXT NOT NULL,                  -- Product model name (e.g., 'Morning Glory V4')
    color_options TEXT,                   -- Comma-separated list of available colors
    in_production BOOLEAN DEFAULT TRUE,   -- TRUE = currently available, FALSE = discontinued

    -- Dimensions (in millimeters for international standard)
    width_mm DOUBLE PRECISION,            -- Side-to-side dimension (parallel to pedal labels)
    depth_mm DOUBLE PRECISION,            -- Front-to-back dimension (heel to toe)
    height_mm DOUBLE PRECISION,           -- Total height including knobs/switches at highest point
    weight_grams INTEGER,                 -- Weight in grams (NULL if unknown)

    -- Pricing and documentation
    msrp_cents INTEGER DEFAULT NULL,      -- Divide by 100 for dollars; NULL if unknown
    product_page TEXT DEFAULT NULL,       -- Manufacturer's product page URL
    instruction_manual TEXT DEFAULT NULL, -- URL to instruction manual (usually PDF)
    image_path TEXT DEFAULT NULL,         -- Product image: relative file path or external URL

    -- Metadata
    description TEXT,                     -- User-facing summary of the product
    tags TEXT,                            -- Comma-separated: 'transparent', 'amp-in-a-box', 'tour-grade', etc.
    data_reliability TEXT CHECK(data_reliability IN ('High', 'Medium', 'Low')),  -- Confidence in data accuracy
    notes TEXT,                           -- Internal notes for data quality/sourcing
    created_at TIMESTAMPTZ DEFAULT NOW(), -- Row creation timestamp
    updated_at TIMESTAMPTZ DEFAULT NOW(), -- Last modification timestamp

    FOREIGN KEY (manufacturer_id) REFERENCES manufacturers(id),
    FOREIGN KEY (product_type_id) REFERENCES product_types(id),
    UNIQUE(manufacturer_id, model, product_type_id)
);

CREATE INDEX idx_products_manufacturer ON products(manufacturer_id);
CREATE INDEX idx_products_type ON products(product_type_id);

-- =============================================================================
-- JACKS TABLE (unified connectors for all product types)
-- =============================================================================

-- All physical connectors (audio, MIDI, power, expression, USB) for all products
CREATE TABLE jacks (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    product_id INTEGER NOT NULL,          -- FK to products table
    category TEXT NOT NULL,               -- 'Audio Input', 'Audio Output', 'MIDI In', 'MIDI Out', 'MIDI Thru',
                                          -- 'Power Input', 'Power Output', 'Expression', 'Sidechain', 'USB', 'Aux'
    direction TEXT NOT NULL,              -- 'Input', 'Output', 'Bidirectional'
    jack_name TEXT,              -- 'Input L', 'Exp 1', 'Loop 1 Send', 'Output 1'
    position TEXT,               -- 'Top', 'Left', 'Right', 'Bottom', 'Front', 'Back'
    connector_type TEXT NOT NULL,-- '1/4" TS', '1/4" TRS', 'XLR', 'XLR Combo', '5-pin DIN',
                                 -- '3.5mm TRS', '2.1mm barrel', '2.5mm barrel', 'USB-A',
                                 -- 'USB-B', 'USB-C', 'IEC C14', 'Speakon'
    impedance_ohms INTEGER,      -- For audio jacks (e.g., 1000000 for 1M ohm input)
    voltage TEXT,                -- For power jacks: '9V', '12V', '18V', '9-18V'
    current_ma INTEGER,          -- For power jacks: max current in milliamps
    polarity TEXT,               -- 'Center Negative', 'Center Positive', 'N/A'
    function TEXT,               -- Detailed description of what this jack does
    power_over_connector BOOLEAN DEFAULT FALSE,  -- E.g., phantom power, bus power
    is_isolated BOOLEAN DEFAULT FALSE,           -- For power outputs
    is_buffered BOOLEAN DEFAULT FALSE,           -- Jack has a buffer
    buffer_switchable BOOLEAN DEFAULT FALSE,     -- Buffer can be turned on/off
    has_ground_lift BOOLEAN DEFAULT FALSE,       -- Jack has ground lift option
    has_phase_invert BOOLEAN DEFAULT FALSE,      -- Jack can invert phase/polarity
    normalled_to_jack_id INTEGER,                -- FK to the jack this one is normalled to
    normalling_type TEXT,                        -- 'Normalled', 'Half-Normalled', 'Non-Normalled', 'Parallel'
    group_id TEXT,               -- Links stereo pairs ('stereo_in'), FX loops ('loop_1'),
                                 -- or related jacks together

    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    FOREIGN KEY (normalled_to_jack_id) REFERENCES jacks(id) ON DELETE SET NULL
);

CREATE INDEX idx_jacks_product ON jacks(product_id);
CREATE INDEX idx_jacks_category ON jacks(category);

-- =============================================================================
-- DETAIL TABLES (one per product type, 1:1 relationship with products)
-- =============================================================================

-- Pedal-specific attributes
CREATE TABLE pedal_details (
    product_id INTEGER PRIMARY KEY,

    -- Classification
    effect_type TEXT CHECK(effect_type IN (
        'Gain', 'Fuzz', 'Compression', 'Delay', 'Reverb',
        'Chorus', 'Flanger', 'Phaser', 'Tremolo', 'Vibrato',
        'Rotary', 'Univibe', 'Ring Modulator',
        'Pitch Shifter', 'Wah', 'Filter',
        'Multi Effects', 'Utility', 'Preamp', 'Amp/Cab Sim', 'Other'
    )),                                   -- Primary effect category
    circuit_type TEXT,            -- 'Bluesbreaker', 'Tube Screamer', 'Klon', 'RAT',
                                  -- 'Big Muff', 'Fuzz Face', 'Memory Man', etc.
                                  -- Comma-separated for multi-circuit pedals
    circuit_routing_options TEXT, -- For multi-circuit pedals: 'A→B', 'B→A', 'Parallel', 'Independent'

    -- Signal characteristics
    signal_type TEXT CHECK(signal_type IN ('Analog', 'Digital', 'Hybrid')),  -- Circuit architecture
    bypass_type TEXT CHECK(bypass_type IN (
        'True Bypass', 'Buffered Bypass', 'Relay Bypass', 'DSP Bypass', 'Both'
    )),                                   -- How signal is routed when effect is off
    mono_stereo TEXT CHECK(mono_stereo IN ('Mono', 'Stereo In/Out', 'Mono In/Stereo Out')),  -- I/O configuration
    audio_mix TEXT,               -- Comma-separated: 'Wet/Dry', 'Parallel', 'Series', 'Kill Dry'
    has_analog_dry_through BOOLEAN DEFAULT FALSE,  -- Dry signal bypasses DSP, stays analog
    has_spillover BOOLEAN DEFAULT FALSE,           -- Effect tails continue when bypassed

    -- Digital specs (NULL for analog pedals)
    sample_rate_khz INTEGER,      -- e.g., 48, 96, 192
    bit_depth INTEGER,            -- e.g., 16, 24, 32
    latency_ms DOUBLE PRECISION,  -- DSP latency in milliseconds

    -- Capabilities
    preset_count INTEGER DEFAULT 0,       -- Number of savable presets (0 = no preset capability)
    has_tap_tempo BOOLEAN DEFAULT FALSE,  -- Can tempo be set via footswitch tap?

    -- MIDI (detailed jacks tracked in jacks table)
    midi_capable BOOLEAN DEFAULT FALSE,   -- Can receive or send MIDI messages?
    midi_receive_capabilities TEXT,  -- 'PC, CC, Clock', etc.
    midi_send_capabilities TEXT,     -- 'PC, CC', etc.

    -- Software
    has_software_editor BOOLEAN DEFAULT FALSE,  -- Has companion desktop/mobile app for editing?
    software_platforms TEXT,                     -- Comma-separated: 'macOS, Windows, iOS'
    is_firmware_updatable BOOLEAN DEFAULT FALSE, -- Can firmware be updated by user?
    has_usb_audio BOOLEAN DEFAULT FALSE,  -- Can act as USB audio interface

    -- Power
    battery_capable BOOLEAN DEFAULT FALSE,    -- Can run on 9V battery?

    -- Effects loops (for loop switcher pedals like Boss ES-8)
    fx_loop_count INTEGER DEFAULT 0,      -- Number of effects loops
    has_reorderable_loops BOOLEAN DEFAULT FALSE,  -- Can loop order be changed via presets?

    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);

-- Power supply-specific attributes
CREATE TABLE power_supply_details (
    product_id INTEGER PRIMARY KEY,       -- FK to products table (1:1 relationship)

    -- Power supply type
    supply_type TEXT CHECK(supply_type IN ('Isolated', 'Non-Isolated', 'Hybrid')),  -- Output isolation type
    topology TEXT CHECK(topology IN ('Switch Mode', 'Toroidal', 'Linear', 'Unknown')),  -- Circuit design (see Glossary)

    -- Input power
    input_voltage_range TEXT,     -- '100-240V AC', '9V DC', '12V DC', etc.
    input_frequency TEXT,         -- '50/60Hz' for AC supplies

    -- Output summary (individual outputs tracked in jacks table)
    total_output_count INTEGER NOT NULL,  -- Total number of power outputs
    total_current_ma INTEGER,             -- Combined current capacity across all outputs
    isolated_output_count INTEGER DEFAULT 0,  -- How many outputs are isolated from each other

    -- Voltage options
    available_voltages TEXT,              -- Comma-separated: '9V, 12V, 18V'
    has_variable_voltage BOOLEAN DEFAULT FALSE,  -- Has adjustable voltage output?
    voltage_range TEXT,           -- If variable: '9-18V'

    -- Mounting
    mounting_type TEXT CHECK(mounting_type IN ('Under Board', 'On Board', 'External', 'Rack')),  -- Intended installation location
    bracket_included BOOLEAN DEFAULT FALSE,   -- Includes mounting bracket/hardware?

    -- Expansion
    is_expandable BOOLEAN DEFAULT FALSE,      -- Can add expansion modules for more outputs?
    expansion_port_type TEXT,     -- 'DB25', 'Proprietary', etc.

    -- Battery operation
    is_battery_powered BOOLEAN DEFAULT FALSE,  -- Can run on internal battery
    battery_capacity_wh DOUBLE PRECISION,      -- Battery capacity in watt-hours

    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);

-- Pedalboard-specific attributes
CREATE TABLE pedalboard_details (
    product_id INTEGER PRIMARY KEY,       -- FK to products table (1:1 relationship)

    -- Usable surface dimensions (may differ from external dimensions in products table)
    usable_width_mm DOUBLE PRECISION,     -- Width available for mounting pedals
    usable_depth_mm DOUBLE PRECISION,     -- Depth available for mounting pedals

    -- Surface characteristics
    surface_type TEXT CHECK(surface_type IN (
        'Loop Velcro', 'Hook Velcro', 'Bare Rails', 'Perforated', 'Solid Flat', 'Other'
    )),                                   -- Type of mounting surface
    rail_spacing_mm DOUBLE PRECISION,     -- Gap between rails (edge to edge)

    -- Construction
    material TEXT,                -- 'Aluminum', 'Steel', 'Wood', 'Plastic', 'Carbon Fiber'
    tilt_angle_degrees DOUBLE PRECISION,  -- Front edge lower (at player's feet), back edge elevated

    -- Clearance for under-board mounting
    under_clearance_mm DOUBLE PRECISION,  -- Space below main surface for power supply

    -- Built-in second tier (if integrated into board design)
    has_second_tier BOOLEAN DEFAULT FALSE,    -- Board has built-in raised tier?
    tier2_usable_width_mm DOUBLE PRECISION,   -- Width of second tier surface
    tier2_usable_depth_mm DOUBLE PRECISION,   -- Depth of second tier surface
    tier2_under_clearance_mm DOUBLE PRECISION,-- Space below second tier (for cables, etc.)
    tier2_height_mm DOUBLE PRECISION,         -- Height of second tier above main surface

    -- Integrated features
    has_integrated_power BOOLEAN DEFAULT FALSE,   -- Has built-in power supply?
    integrated_power_product_id INTEGER,          -- FK to products.id if power supply exists as separate product
    has_integrated_patch_bay BOOLEAN DEFAULT FALSE,-- Has built-in I/O junction box?

    -- Case/bag
    case_included BOOLEAN DEFAULT FALSE,      -- Comes with carrying case/bag?
    case_type TEXT CHECK(case_type IN ('Soft Case', 'Hard Case', 'Flight Case', 'Gig Bag', 'None')),

    -- Weight capacity
    max_load_kg DOUBLE PRECISION,         -- Maximum weight the board can support

    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    FOREIGN KEY (integrated_power_product_id) REFERENCES products(id)
);

-- MIDI controller-specific attributes
CREATE TABLE midi_controller_details (
    product_id INTEGER PRIMARY KEY,       -- FK to products table (1:1 relationship)

    -- Footswitches
    footswitch_count INTEGER NOT NULL,    -- Number of footswitches
    footswitch_type TEXT CHECK(footswitch_type IN ('Momentary', 'Latching', 'Dual-Action', 'Mixed')),  -- Switch mechanism type
    has_led_indicators BOOLEAN DEFAULT TRUE,  -- Footswitches have LED status indicators?
    led_color_options TEXT,       -- 'RGB', 'Single Color', 'Bi-Color', etc.

    -- Banks and presets
    bank_count INTEGER,                   -- Number of banks available
    presets_per_bank INTEGER,             -- Presets per bank
    total_preset_slots INTEGER,           -- Total savable presets (may differ from count × per_bank)

    -- Display
    has_display BOOLEAN DEFAULT FALSE,    -- Has screen or display?
    display_type TEXT,            -- 'LCD', 'OLED', 'LED Segment', 'E-Ink', 'None'
    display_size TEXT,            -- '128x64', '320x240', etc.

    -- Expression inputs (count here; jack details in jacks table)
    expression_input_count INTEGER DEFAULT 0,

    -- MIDI capabilities
    midi_channels INTEGER DEFAULT 16,     -- Number of MIDI channels supported (typically 16)
    supports_midi_clock BOOLEAN DEFAULT FALSE,  -- Can send/receive MIDI clock for tempo sync?
    supports_sysex BOOLEAN DEFAULT FALSE,       -- Can send/receive System Exclusive messages?

    -- Programmability
    software_editor_available BOOLEAN DEFAULT FALSE,  -- Has companion desktop/mobile app?
    software_platforms TEXT,          -- 'macOS', 'Windows', 'iOS', 'Android', 'Web'
    on_device_programming BOOLEAN DEFAULT FALSE,   -- Can edit presets without software?
    is_firmware_updatable BOOLEAN DEFAULT FALSE,    -- Can firmware be updated by user?
    config_format TEXT,               -- 'JSON', 'XML', 'YAML', 'SysEx', 'Binary', 'None'
    config_format_documented BOOLEAN DEFAULT FALSE, -- Is the format publicly documented/open?

    -- Special features
    has_tuner BOOLEAN DEFAULT FALSE,          -- Built-in tuner function?
    has_tap_tempo BOOLEAN DEFAULT FALSE,      -- Dedicated tap tempo footswitch?
    has_setlist_mode BOOLEAN DEFAULT FALSE,   -- Can organize presets into setlists/songs?
    has_per_switch_displays BOOLEAN DEFAULT FALSE,  -- Each footswitch has its own small display?
    aux_switch_input_count INTEGER DEFAULT 0,       -- Number of external switch inputs

    has_usb_host BOOLEAN DEFAULT FALSE,       -- Can connect USB MIDI devices directly (like MC6 Pro)
    has_bluetooth_midi BOOLEAN DEFAULT FALSE,  -- Supports wireless MIDI via Bluetooth?

    -- Audio loops (for loop switchers)
    audio_loop_count INTEGER DEFAULT 0,   -- Number of audio effects loops
    has_reorderable_loops BOOLEAN DEFAULT FALSE,  -- Can loop order be changed via presets?
    loop_bypass_type TEXT,            -- 'True Bypass', 'Buffered', 'Relay', 'Mixed'
    has_parallel_routing BOOLEAN DEFAULT FALSE,    -- Can run loops in parallel (not just series)?
    has_gapless_switching BOOLEAN DEFAULT FALSE,   -- No audio gap when changing presets
    has_spillover BOOLEAN DEFAULT FALSE,           -- Allows effect tails when loops are switched out

    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);

-- Utility device-specific attributes
CREATE TABLE utility_details (
    product_id INTEGER PRIMARY KEY,       -- FK to products table (1:1 relationship)

    -- Utility subtype
    utility_type TEXT NOT NULL CHECK(utility_type IN (
        'DI Box', 'Reamp Box', 'Buffer', 'Splitter', 'A/B Box', 'A/B/Y Box',
        'Tuner', 'Volume Pedal', 'Expression Pedal', 'Noise Gate',
        'Power Conditioner', 'Signal Router', 'Impedance Matcher',
        'Headphone Amp', 'Mixer', 'Junction Box', 'Patch Bay',
        'Mute Switch', 'Amp Switcher', 'Load Box', 'Line Level Converter', 'Other'
    )),                                   -- Specific utility category

    -- Signal path
    is_active BOOLEAN DEFAULT FALSE,      -- Requires power? (vs passive)
    signal_type TEXT CHECK(signal_type IN ('Analog', 'Digital', 'Both')),  -- Circuit type
    bypass_type TEXT,                     -- 'True Bypass', 'Buffered', etc. if applicable

    -- For DI boxes
    has_ground_lift BOOLEAN,              -- Can disconnect ground to reduce hum?
    has_pad BOOLEAN,                      -- Has input attenuation pad?
    pad_db INTEGER,                       -- Pad attenuation level in dB (e.g., -20)

    -- For tuners
    tuning_display_type TEXT,     -- 'Strobe', 'Needle', 'LED', 'LCD'
    tuning_accuracy_cents DOUBLE PRECISION,   -- Tuning precision (e.g., 0.1, 0.5, 1.0)
    polyphonic_tuning BOOLEAN DEFAULT FALSE,  -- Can tune all strings simultaneously?

    -- For volume/expression pedals
    sweep_type TEXT,              -- 'Linear', 'Audio Taper', 'Logarithmic'
    has_tuner_out BOOLEAN DEFAULT FALSE,      -- Has dedicated always-on tuner output?
    has_minimum_volume BOOLEAN DEFAULT FALSE, -- Can set a floor so pedal doesn't go fully silent
    has_polarity_switch BOOLEAN DEFAULT FALSE,-- TRS polarity options

    -- For load boxes
    power_handling_watts INTEGER,         -- Maximum wattage the load box can safely absorb
    has_reactive_load BOOLEAN DEFAULT FALSE,  -- vs resistive
    has_attenuation BOOLEAN DEFAULT FALSE,    -- Can reduce signal level for quiet operation?
    attenuation_range_db TEXT,            -- e.g., '-20 to 0'
    has_cab_sim BOOLEAN DEFAULT FALSE,        -- Includes cabinet simulation for direct recording?

    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);

-- Plug/connector-specific attributes (for layout planning)
CREATE TABLE plug_details (
    product_id INTEGER PRIMARY KEY,       -- FK to products table (1:1 relationship)
    plug_type TEXT NOT NULL,              -- 'patch', 'instrument', 'power', 'midi', 'usb'
    connector_type TEXT NOT NULL,   -- '1/4" TS', '1/4" TRS', '2.1mm barrel', '5-pin DIN',
                                    -- 'USB-A', 'USB-B', 'USB-C', 'USB Mini', 'USB Micro',
                                    -- 'XLR', '3.5mm TRS', '3.5mm TRRS', etc.
    is_right_angle BOOLEAN DEFAULT FALSE,     -- Plug exits at 90° angle to jack?
    is_pancake BOOLEAN DEFAULT FALSE,         -- Flat/low-profile design
    plug_width_mm DOUBLE PRECISION,           -- Width of plug housing (parallel to pedal face)
    plug_depth_mm DOUBLE PRECISION,           -- How far plug protrudes from jack (perpendicular to pedal face)
    plug_height_mm DOUBLE PRECISION,          -- Height of plug housing (vertical)
    cable_exit_direction TEXT,      -- 'straight', 'up', 'down', 'side'
    is_solderless BOOLEAN DEFAULT FALSE,      -- For DIY solderless systems (Evidence Audio, Lava Cable, etc.)
    housing_material TEXT,           -- 'Metal', 'Plastic'
    has_locking_mechanism BOOLEAN DEFAULT FALSE,  -- Has twist-lock or other secure connection?

    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);

-- =============================================================================
-- COMPATIBILITY TABLE
-- =============================================================================

-- Tracks known compatibility relationships between products
CREATE TABLE product_compatibility (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    product_a_id INTEGER NOT NULL,        -- First product in the pair
    product_b_id INTEGER NOT NULL,        -- Second product in the pair
    compatibility_type TEXT CHECK(compatibility_type IN (  -- Nature of the relationship
        'Mounting',         -- Physical fit (board + supply)
        'Power',            -- Power compatibility
        'MIDI',             -- MIDI chain compatibility
        'Accessory',        -- Official accessory relationship
        'Replacement'       -- Direct replacement/alternative
    )),
    notes TEXT,                           -- Details about the compatibility relationship
    is_incompatible BOOLEAN DEFAULT FALSE,-- Flags known bad pairings (e.g., causes noise)
    source TEXT,                          -- 'Manufacturer', 'User tested', 'Forum post', etc.
    verified BOOLEAN DEFAULT FALSE,       -- Has this compatibility been human-verified?
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),

    FOREIGN KEY (product_a_id) REFERENCES products(id) ON DELETE CASCADE,
    FOREIGN KEY (product_b_id) REFERENCES products(id) ON DELETE CASCADE,
    UNIQUE(product_a_id, product_b_id, compatibility_type)
);

CREATE INDEX idx_compat_a ON product_compatibility(product_a_id);
CREATE INDEX idx_compat_b ON product_compatibility(product_b_id);

-- =============================================================================
-- TRIGGERS (PL/pgSQL)
-- =============================================================================

-- Update product timestamp on modification (BEFORE UPDATE avoids recursion)
CREATE OR REPLACE FUNCTION update_product_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_product_timestamp
BEFORE UPDATE ON products
FOR EACH ROW
EXECUTE FUNCTION update_product_timestamp();

-- Update manufacturer timestamp when products change
CREATE OR REPLACE FUNCTION update_manufacturer_on_product_change()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE manufacturers SET updated_at = NOW() WHERE id = NEW.manufacturer_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_manufacturer_on_product_insert
AFTER INSERT ON products
FOR EACH ROW
EXECUTE FUNCTION update_manufacturer_on_product_change();

CREATE TRIGGER update_manufacturer_on_product_update
AFTER UPDATE ON products
FOR EACH ROW
EXECUTE FUNCTION update_manufacturer_on_product_change();

-- =============================================================================
-- LEGACY COMPATIBILITY VIEW
-- =============================================================================

-- Maintains backward compatibility with code expecting the old pedals table structure
CREATE VIEW pedals_legacy AS
SELECT
    p.id,
    p.manufacturer_id,
    m.name AS manufacturer,
    p.model,
    p.color_options,
    pd.effect_type,
    p.in_production,
    -- Reconstruct inputs/outputs from jacks (simplified)
    (SELECT STRING_AGG(connector_type, ', ')
     FROM jacks WHERE product_id = p.id AND direction = 'Input' AND category LIKE 'Audio%') AS inputs,
    (SELECT STRING_AGG(connector_type, ', ')
     FROM jacks WHERE product_id = p.id AND direction = 'Output' AND category LIKE 'Audio%') AS outputs,
    -- Power info from jacks
    (SELECT connector_type FROM jacks WHERE product_id = p.id AND category = 'Power Input' LIMIT 1) AS power_plug_size,
    (SELECT polarity FROM jacks WHERE product_id = p.id AND category = 'Power Input' LIMIT 1) AS power_polarity,
    (SELECT voltage FROM jacks WHERE product_id = p.id AND category = 'Power Input' LIMIT 1) AS power_voltage,
    (SELECT current_ma FROM jacks WHERE product_id = p.id AND category = 'Power Input' LIMIT 1) AS power_current_ma,
    -- Dimensions as formatted string
    CASE
        WHEN p.width_mm IS NOT NULL AND p.depth_mm IS NOT NULL AND p.height_mm IS NOT NULL
        THEN TO_CHAR(p.width_mm, 'FM999990.0') || ' x ' || TO_CHAR(p.depth_mm, 'FM999990.0') || ' x ' || TO_CHAR(p.height_mm, 'FM999990.0') || ' mm'
        ELSE NULL
    END AS dimensions,
    p.data_reliability,
    p.msrp_cents,
    p.product_page,
    p.instruction_manual,
    pd.bypass_type,
    pd.midi_capable,
    (SELECT COUNT(*) FROM jacks WHERE product_id = p.id AND category = 'Expression') AS expression_input,
    CASE WHEN pd.mono_stereo = 'Mono' THEN FALSE ELSE TRUE END AS stereo_capable
FROM products p
JOIN manufacturers m ON p.manufacturer_id = m.id
JOIN pedal_details pd ON p.id = pd.product_id
WHERE p.product_type_id = 1;  -- pedal type
