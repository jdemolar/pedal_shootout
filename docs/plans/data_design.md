# Guitar Gear Database Schema Redesign

## Overview

Redesign the SQLite database to support multiple product types (pedals, power supplies, pedalboards, MIDI controllers, utilities, plugs) using **Class Table Inheritance** with a **unified jacks table**.

## Purpose & Goals

This database serves guitarists and pedalboard builders by enabling:

- **Spec comparison** — Compare pedals by effect type, bypass type, power requirements, dimensions, and features
- **Pedalboard layout planning** — Calculate if pedals fit on a board, considering plug dimensions and spacing
- **Power budget calculations** — Sum pedal current draw against power supply capacity
- **Compatibility tracking** — Know which power supplies fit under which boards, which accessories work together
- **MIDI system planning** — Match controllers to pedals, track MIDI capabilities

The data model prioritizes **queryability** (find all stereo delay pedals with MIDI under $300) and **completeness** (capture specs that matter for real-world pedalboard building).

## Conventions

Throughout this schema:

- **Booleans** — Stored as `INTEGER` with values `0` (false) or `1` (true)
- **Multi-value fields** — Comma-separated strings (e.g., `'macOS, Windows, iOS'`)
- **NULL handling** — `NULL` means unknown or not applicable; empty string means intentionally blank
- **Dimensions** — Always in millimeters (`_mm` suffix)
- **Weight** — Always in grams (`weight_grams`)
- **Currency** — Always in cents (`msrp_cents`); divide by 100 for dollars
- **Timestamps** — SQLite `DATETIME` format, auto-populated via `DEFAULT CURRENT_TIMESTAMP`

## Design Pattern

**Class Table Inheritance**: A shared `products` base table contains common attributes, with type-specific detail tables extending it. Each product has exactly one row in `products` and exactly one row in its corresponding detail table (1:1 relationship).

```
┌─────────────────┐
│   products      │  ← Common: manufacturer, model, dimensions, MSRP, etc.
└────────┬────────┘
         │
    ┌────┴────┬──────────┬──────────┬──────────┬──────────┐
    ▼         ▼          ▼          ▼          ▼          ▼
┌────────┐┌────────┐┌────────┐┌────────┐┌────────┐┌────────┐
│pedal_  ││power_  ││pedal-  ││midi_   ││utility_││plug_   │
│details ││supply_ ││board_  ││control-││details ││details │
│        ││details ││details ││ler_det.││        ││        │
└────────┘└────────┘└────────┘└────────┘└────────┘└────────┘
```

**Unified Jacks Table**: All connectors (audio, MIDI, power, aux) reference a single `jacks` table linked to `products`.

## Schema Summary

### Core Tables

| Table | Purpose |
|-------|---------|
| `manufacturers` | Existing table (unchanged) |
| `product_types` | Enum reference: pedal, power_supply, pedalboard, midi_controller, utility, plug |
| `products` | Base table with shared attributes |
| `jacks` | All connectors for all product types |

### Detail Tables (one per product type)

| Table | Key Attributes |
|-------|----------------|
| `pedal_details` | effect_type, bypass_type, signal_type, preset_count, midi_capable, fx_loop_count |
| `power_supply_details` | supply_type, topology, total_output_count, isolated_output_count, available_voltages |
| `pedalboard_details` | usable dimensions, surface_type, rail_spacing, under_clearance, case_type |
| `midi_controller_details` | footswitch_count, bank_count, preset_slots, display_type, expression_input_count |
| `utility_details` | utility_type (DI, buffer, splitter, tuner, etc.), is_active, specific fields per subtype |
| `plug_details` | plug_type (patch, instrument, power, MIDI), connector_type, is_right_angle, profile dimensions |

**Note**: Cables excluded for now. Plugs are included because their physical profile affects pedal spacing on a board—users need to plan around plug dimensions.

---

## Full Schema

### manufacturers (existing, add updated_at if missing)

```sql
CREATE TABLE manufacturers (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE,            -- Official company/brand name
    country TEXT,                         -- Country of origin (e.g., 'USA', 'Japan')
    founded TEXT,                         -- Year founded (TEXT to allow 'circa 1970', 'early 1980s')
    status TEXT CHECK(status IN ('Active', 'Defunct', 'Discontinued', 'Unknown')) DEFAULT 'Unknown',
    specialty TEXT,                       -- What they're known for (e.g., 'Fuzz pedals', 'Boutique overdrives')
    website TEXT,                         -- Official website URL
    notes TEXT,                           -- Internal notes (history, ownership changes, etc.)
    updated_at DATETIME                   -- Last modified timestamp
);
```

### product_types (enum reference)

```sql
CREATE TABLE product_types (
    id INTEGER PRIMARY KEY,               -- Fixed IDs (not auto-increment) for stable references
    type_name TEXT NOT NULL UNIQUE,       -- Machine-readable identifier (e.g., 'pedal', 'power_supply')
    description TEXT                      -- Human-readable description of this product category
);

INSERT INTO product_types (id, type_name, description) VALUES
    (1, 'pedal', 'Effect pedals'),
    (2, 'power_supply', 'Pedalboard power supplies'),
    (3, 'pedalboard', 'Pedalboards and cases'),
    (4, 'midi_controller', 'MIDI foot controllers'),
    (5, 'utility', 'DI boxes, buffers, splitters, tuners, etc.'),
    (6, 'plug', 'Cable plugs/connectors for layout planning');
```

### products (base table)

```sql
CREATE TABLE products (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    manufacturer_id INTEGER NOT NULL,     -- FK to manufacturers table
    product_type_id INTEGER NOT NULL,     -- FK to product_types table
    model TEXT NOT NULL,                  -- Product model name (e.g., 'Morning Glory V4')
    color_options TEXT,                   -- Comma-separated list of available colors
    in_production INTEGER CHECK(in_production IN (0, 1)) DEFAULT 1,  -- 1 = currently available, 0 = discontinued

    -- Dimensions (in millimeters for international standard)
    width_mm REAL,                        -- Side-to-side dimension (parallel to pedal labels)
    depth_mm REAL,                        -- Front-to-back dimension (heel to toe)
    height_mm REAL,                       -- Total height including knobs/switches at highest point
    weight_grams INTEGER,                 -- Weight in grams (NULL if unknown)

    -- Pricing and documentation
    msrp_cents INTEGER DEFAULT NULL,      -- Divide by 100 for dollars; NULL if unknown
    product_page TEXT DEFAULT NULL,       -- Manufacturer's product page URL
    instruction_manual TEXT DEFAULT NULL, -- URL to instruction manual (usually PDF)

    -- Metadata
    description TEXT,                     -- User-facing summary of the product
    tags TEXT,                            -- Comma-separated: 'transparent', 'amp-in-a-box', 'tour-grade', etc.
    data_reliability TEXT CHECK(data_reliability IN ('High', 'Medium', 'Low')),  -- Confidence in data accuracy
    notes TEXT,                           -- Internal notes for data quality/sourcing
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,   -- Row creation timestamp
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,   -- Last modification timestamp

    FOREIGN KEY (manufacturer_id) REFERENCES manufacturers(id),
    FOREIGN KEY (product_type_id) REFERENCES product_types(id),
    UNIQUE(manufacturer_id, model, product_type_id)
);

CREATE INDEX idx_products_manufacturer ON products(manufacturer_id);
CREATE INDEX idx_products_type ON products(product_type_id);
```

### jacks (unified connectors)

All physical connectors (audio, MIDI, power, expression, USB) for all product types are stored in this single table. This unified approach:
- Avoids duplicating I/O columns across every detail table
- Enables queries like "find all products with XLR outputs" across product types
- Allows flexible per-jack attributes (buffered, isolated, normalled) without schema changes
- Links related jacks via `group_id` (stereo pairs, FX loop send/return)

```sql
CREATE TABLE jacks (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
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
    power_over_connector INTEGER DEFAULT 0,  -- E.g., phantom power, bus power
    is_isolated INTEGER DEFAULT 0,           -- For power outputs
    is_buffered INTEGER DEFAULT 0,           -- Jack has a buffer
    buffer_switchable INTEGER DEFAULT 0,     -- Buffer can be turned on/off
    has_ground_lift INTEGER DEFAULT 0,       -- Jack has ground lift option
    has_phase_invert INTEGER DEFAULT 0,      -- Jack can invert phase/polarity
    normalled_to_jack_id INTEGER,            -- FK to the jack this one is normalled to
    normalling_type TEXT,                    -- 'Normalled', 'Half-Normalled', 'Non-Normalled', 'Parallel'
    group_id TEXT,               -- Links stereo pairs ('stereo_in'), FX loops ('loop_1'),
                                 -- or related jacks together

    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    FOREIGN KEY (normalled_to_jack_id) REFERENCES jacks(id) ON DELETE SET NULL
);

CREATE INDEX idx_jacks_product ON jacks(product_id);
CREATE INDEX idx_jacks_category ON jacks(category);
```

### pedal_details

```sql
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
    has_analog_dry_through INTEGER DEFAULT 0,  -- Dry signal bypasses DSP, stays analog
    has_spillover INTEGER DEFAULT 0,           -- Effect tails continue when bypassed

    -- Digital specs (NULL for analog pedals)
    sample_rate_khz INTEGER,      -- e.g., 48, 96, 192
    bit_depth INTEGER,            -- e.g., 16, 24, 32
    latency_ms REAL,              -- DSP latency in milliseconds

    -- Capabilities
    preset_count INTEGER DEFAULT 0,       -- Number of savable presets (0 = no preset capability)
    has_tap_tempo INTEGER DEFAULT 0,      -- Can tempo be set via footswitch tap?

    -- MIDI (detailed jacks tracked in jacks table)
    midi_capable INTEGER DEFAULT 0,       -- Can receive or send MIDI messages?
    midi_receive_capabilities TEXT,  -- 'PC, CC, Clock', etc.
    midi_send_capabilities TEXT,     -- 'PC, CC', etc.

    -- Software
    has_software_editor INTEGER DEFAULT 0,  -- Has companion desktop/mobile app for editing?
    software_platforms TEXT,                -- Comma-separated: 'macOS, Windows, iOS'
    is_firmware_updatable INTEGER DEFAULT 0,  -- Can firmware be updated by user?
    has_usb_audio INTEGER DEFAULT 0,  -- Can act as USB audio interface

    -- Power
    battery_capable INTEGER DEFAULT 0,    -- Can run on 9V battery?

    -- Effects loops (for loop switcher pedals like Boss ES-8)
    fx_loop_count INTEGER DEFAULT 0,      -- Number of effects loops
    has_reorderable_loops INTEGER DEFAULT 0,  -- Can loop order be changed via presets?

    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);
```

### power_supply_details

```sql
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
    has_variable_voltage INTEGER DEFAULT 0,  -- Has adjustable voltage output?
    voltage_range TEXT,           -- If variable: '9-18V'

    -- Mounting
    mounting_type TEXT CHECK(mounting_type IN ('Under Board', 'On Board', 'External', 'Rack')),  -- Intended installation location
    bracket_included INTEGER DEFAULT 0,   -- Includes mounting bracket/hardware?

    -- Expansion
    is_expandable INTEGER DEFAULT 0,      -- Can add expansion modules for more outputs?
    expansion_port_type TEXT,     -- 'DB25', 'Proprietary', etc.

    -- Battery operation
    is_battery_powered INTEGER DEFAULT 0,  -- Can run on internal battery
    battery_capacity_wh REAL,              -- Battery capacity in watt-hours

    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);
```

### pedalboard_details

```sql
CREATE TABLE pedalboard_details (
    product_id INTEGER PRIMARY KEY,       -- FK to products table (1:1 relationship)

    -- Usable surface dimensions (may differ from external dimensions in products table)
    usable_width_mm REAL,                 -- Width available for mounting pedals
    usable_depth_mm REAL,                 -- Depth available for mounting pedals

    -- Surface characteristics
    surface_type TEXT CHECK(surface_type IN (
        'Loop Velcro', 'Hook Velcro', 'Bare Rails', 'Perforated', 'Solid Flat', 'Other'
    )),                                   -- Type of mounting surface
    rail_spacing_mm REAL,         -- Gap between rails (edge to edge)

    -- Construction
    material TEXT,                -- 'Aluminum', 'Steel', 'Wood', 'Plastic', 'Carbon Fiber'
    tilt_angle_degrees REAL,      -- Front edge lower (at player's feet), back edge elevated

    -- Clearance for under-board mounting
    under_clearance_mm REAL,              -- Space below main surface for power supply

    -- Built-in second tier (if integrated into board design)
    has_second_tier INTEGER DEFAULT 0,    -- Board has built-in raised tier?
    tier2_usable_width_mm REAL,           -- Width of second tier surface
    tier2_usable_depth_mm REAL,           -- Depth of second tier surface
    tier2_under_clearance_mm REAL,        -- Space below second tier (for cables, etc.)
    tier2_height_mm REAL,             -- Height of second tier above main surface

    -- Integrated features
    has_integrated_power INTEGER DEFAULT 0,   -- Has built-in power supply?
    integrated_power_product_id INTEGER,      -- FK to products.id if power supply exists as separate product
    has_integrated_patch_bay INTEGER DEFAULT 0,  -- Has built-in I/O junction box?

    -- Case/bag
    case_included INTEGER DEFAULT 0,      -- Comes with carrying case/bag?
    case_type TEXT CHECK(case_type IN ('Soft Case', 'Hard Case', 'Flight Case', 'Gig Bag', 'None')),

    -- Weight capacity
    max_load_kg REAL,             -- Maximum weight the board can support

    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    FOREIGN KEY (integrated_power_product_id) REFERENCES products(id)
);
```

### midi_controller_details

```sql
CREATE TABLE midi_controller_details (
    product_id INTEGER PRIMARY KEY,       -- FK to products table (1:1 relationship)

    -- Footswitches
    footswitch_count INTEGER NOT NULL,    -- Number of footswitches
    footswitch_type TEXT CHECK(footswitch_type IN ('Momentary', 'Latching', 'Dual-Action', 'Mixed')),  -- Switch mechanism type
    has_led_indicators INTEGER DEFAULT 1, -- Footswitches have LED status indicators?
    led_color_options TEXT,       -- 'RGB', 'Single Color', 'Bi-Color', etc.

    -- Banks and presets
    bank_count INTEGER,                   -- Number of banks available
    presets_per_bank INTEGER,             -- Presets per bank
    total_preset_slots INTEGER,           -- Total savable presets (may differ from count × per_bank)

    -- Display
    has_display INTEGER DEFAULT 0,        -- Has screen or display?
    display_type TEXT,            -- 'LCD', 'OLED', 'LED Segment', 'E-Ink', 'None'
    display_size TEXT,            -- '128x64', '320x240', etc.

    -- Expression inputs (count here; jack details in jacks table)
    expression_input_count INTEGER DEFAULT 0,

    -- MIDI capabilities
    midi_channels INTEGER DEFAULT 16,     -- Number of MIDI channels supported (typically 16)
    supports_midi_clock INTEGER DEFAULT 0,  -- Can send/receive MIDI clock for tempo sync?
    supports_sysex INTEGER DEFAULT 0,     -- Can send/receive System Exclusive messages?

    -- Programmability
    software_editor_available INTEGER DEFAULT 0,  -- Has companion desktop/mobile app?
    software_platforms TEXT,          -- 'macOS', 'Windows', 'iOS', 'Android', 'Web'
    on_device_programming INTEGER DEFAULT 0,   -- Can edit presets without software?
    is_firmware_updatable INTEGER DEFAULT 0,  -- Can firmware be updated by user?
    config_format TEXT,               -- 'JSON', 'XML', 'YAML', 'SysEx', 'Binary', 'None'
    config_format_documented INTEGER DEFAULT 0,  -- Is the format publicly documented/open?

    -- Special features
    has_tuner INTEGER DEFAULT 0,          -- Built-in tuner function?
    has_tap_tempo INTEGER DEFAULT 0,      -- Dedicated tap tempo footswitch?
    has_setlist_mode INTEGER DEFAULT 0,   -- Can organize presets into setlists/songs?
    has_per_switch_displays INTEGER DEFAULT 0,  -- Each footswitch has its own small display?
    aux_switch_input_count INTEGER DEFAULT 0,   -- Number of external switch inputs

    has_usb_host INTEGER DEFAULT 0,       -- Can connect USB MIDI devices directly (like MC6 Pro)
    has_bluetooth_midi INTEGER DEFAULT 0, -- Supports wireless MIDI via Bluetooth?

    -- Audio loops (for loop switchers)
    audio_loop_count INTEGER DEFAULT 0,   -- Number of audio effects loops
    has_reorderable_loops INTEGER DEFAULT 0,  -- Can loop order be changed via presets?
    loop_bypass_type TEXT,            -- 'True Bypass', 'Buffered', 'Relay', 'Mixed'
    has_parallel_routing INTEGER DEFAULT 0,    -- Can run loops in parallel (not just series)?
    has_gapless_switching INTEGER DEFAULT 0,  -- No audio gap when changing presets
    has_spillover INTEGER DEFAULT 0,          -- Allows effect tails when loops are switched out

    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);
```

### utility_details

```sql
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
    is_active INTEGER DEFAULT 0,          -- Requires power? (vs passive)
    signal_type TEXT CHECK(signal_type IN ('Analog', 'Digital', 'Both')),  -- Circuit type
    bypass_type TEXT,                     -- 'True Bypass', 'Buffered', etc. if applicable

    -- For DI boxes
    has_ground_lift INTEGER,              -- Can disconnect ground to reduce hum?
    has_pad INTEGER,                      -- Has input attenuation pad?
    pad_db INTEGER,                       -- Pad attenuation level in dB (e.g., -20)

    -- For tuners
    tuning_display_type TEXT,     -- 'Strobe', 'Needle', 'LED', 'LCD'
    tuning_accuracy_cents REAL,           -- Tuning precision (e.g., 0.1, 0.5, 1.0)
    polyphonic_tuning INTEGER DEFAULT 0,  -- Can tune all strings simultaneously?

    -- For volume/expression pedals
    sweep_type TEXT,              -- 'Linear', 'Audio Taper', 'Logarithmic'
    has_tuner_out INTEGER DEFAULT 0,      -- Has dedicated always-on tuner output?
    has_minimum_volume INTEGER DEFAULT 0,   -- Can set a floor so pedal doesn't go fully silent
    has_polarity_switch INTEGER DEFAULT 0,  -- TRS polarity options

    -- For load boxes
    power_handling_watts INTEGER,         -- Maximum wattage the load box can safely absorb
    has_reactive_load INTEGER DEFAULT 0,  -- vs resistive
    has_attenuation INTEGER DEFAULT 0,    -- Can reduce signal level for quiet operation?
    attenuation_range_db TEXT,            -- e.g., '-20 to 0'
    has_cab_sim INTEGER DEFAULT 0,        -- Includes cabinet simulation for direct recording?

    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);
```

### plug_details

```sql
CREATE TABLE plug_details (
    product_id INTEGER PRIMARY KEY,       -- FK to products table (1:1 relationship)
    plug_type TEXT NOT NULL,              -- 'patch', 'instrument', 'power', 'midi', 'usb'
    connector_type TEXT NOT NULL,   -- '1/4" TS', '1/4" TRS', '2.1mm barrel', '5-pin DIN',
                                    -- 'USB-A', 'USB-B', 'USB-C', 'USB Mini', 'USB Micro',
                                    -- 'XLR', '3.5mm TRS', '3.5mm TRRS', etc.
    is_right_angle INTEGER DEFAULT 0,     -- Plug exits at 90° angle to jack?
    is_pancake INTEGER DEFAULT 0,   -- Flat/low-profile design
    plug_width_mm REAL,             -- Width of plug housing (parallel to pedal face)
    plug_depth_mm REAL,             -- How far plug protrudes from jack (perpendicular to pedal face)
    plug_height_mm REAL,            -- Height of plug housing (vertical)
    cable_exit_direction TEXT,      -- 'straight', 'up', 'down', 'side'
    is_solderless INTEGER DEFAULT 0,-- For DIY solderless systems (Evidence Audio, Lava Cable, etc.)
    housing_material TEXT,           -- 'Metal', 'Plastic'
    has_locking_mechanism INTEGER DEFAULT 0,  -- Has twist-lock or other secure connection?

    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);
```

### product_compatibility

```sql
CREATE TABLE product_compatibility (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
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
    is_incompatible INTEGER DEFAULT 0,    -- Flags known bad pairings (e.g., causes noise)
    source TEXT,                        -- 'Manufacturer', 'User tested', 'Forum post', etc.
    verified INTEGER DEFAULT 0,         -- Has this compatibility been human-verified?
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (product_a_id) REFERENCES products(id) ON DELETE CASCADE,
    FOREIGN KEY (product_b_id) REFERENCES products(id) ON DELETE CASCADE,
    UNIQUE(product_a_id, product_b_id, compatibility_type)
);

CREATE INDEX idx_compat_a ON product_compatibility(product_a_id);
CREATE INDEX idx_compat_b ON product_compatibility(product_b_id);
```

---

## Triggers

```sql
-- Update product timestamp on modification
CREATE TRIGGER update_product_timestamp
AFTER UPDATE ON products
BEGIN
    UPDATE products SET updated_at = datetime('now') WHERE id = NEW.id;
END;

-- Update manufacturer timestamp when products change
CREATE TRIGGER update_manufacturer_on_product_insert
AFTER INSERT ON products
BEGIN
    UPDATE manufacturers SET updated_at = datetime('now') WHERE id = NEW.manufacturer_id;
END;

CREATE TRIGGER update_manufacturer_on_product_update
AFTER UPDATE ON products
BEGIN
    UPDATE manufacturers SET updated_at = datetime('now') WHERE id = NEW.manufacturer_id;
END;
```

---

## Legacy Compatibility View

To maintain backward compatibility with existing code that queries the `pedals` table:

```sql
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
    (SELECT GROUP_CONCAT(connector_type, ', ')
     FROM jacks WHERE product_id = p.id AND direction = 'Input' AND category LIKE 'Audio%') AS inputs,
    (SELECT GROUP_CONCAT(connector_type, ', ')
     FROM jacks WHERE product_id = p.id AND direction = 'Output' AND category LIKE 'Audio%') AS outputs,
    -- Power info from jacks
    (SELECT connector_type FROM jacks WHERE product_id = p.id AND category = 'Power Input' LIMIT 1) AS power_plug_size,
    (SELECT polarity FROM jacks WHERE product_id = p.id AND category = 'Power Input' LIMIT 1) AS power_polarity,
    (SELECT voltage FROM jacks WHERE product_id = p.id AND category = 'Power Input' LIMIT 1) AS power_voltage,
    (SELECT current_ma FROM jacks WHERE product_id = p.id AND category = 'Power Input' LIMIT 1) AS power_current_ma,
    -- Dimensions as formatted string
    CASE
        WHEN p.width_mm IS NOT NULL AND p.depth_mm IS NOT NULL AND p.height_mm IS NOT NULL
        THEN printf('%.1f x %.1f x %.1f mm', p.width_mm, p.depth_mm, p.height_mm)
        ELSE NULL
    END AS dimensions,
    p.data_reliability,
    p.msrp_cents,
    p.product_page,
    p.instruction_manual,
    pd.bypass_type,
    pd.midi_capable,
    (SELECT COUNT(*) FROM jacks WHERE product_id = p.id AND category = 'Expression') AS expression_input,
    CASE pd.mono_stereo WHEN 'Mono' THEN 0 ELSE 1 END AS stereo_capable
FROM products p
JOIN manufacturers m ON p.manufacturer_id = m.id
JOIN pedal_details pd ON p.id = pd.product_id
WHERE p.product_type_id = 1;  -- pedal type
```

---

## Key Design Decisions

### 1. Plugs instead of cables
Cables are excluded (length depends on pedal arrangement). Plugs are included because their physical profile affects pedal spacing. A "pancake" plug vs. a straight plug changes how close pedals can be placed.

### 2. Dimensions in mm
International standard, precise. Products table stores `width_mm`, `depth_mm`, `height_mm`, `weight_grams`.

### 3. FX Loops via group_id
Send and return jacks share a `group_id` value (e.g., "loop_1") to link them as a pair.

### 4. Hybrid products
For products like pedalboards with integrated power: use `integrated_power_product_id` FK or create two linked products via `product_compatibility`.

### 5. MSRP in cents
Stored as INTEGER to avoid floating-point rounding errors. `$99.00` = `9900`. NULL means unknown.

### 6. Foreign key enforcement
SQLite requires explicit enabling:
```sql
PRAGMA foreign_keys = ON;
```
This must be run on every new connection.

---

## Glossary

**Analog dry through** — A feature of some digital pedals where the dry (unprocessed) signal stays in the analog domain and never passes through the DSP. Only the wet signal is digitally processed. Preserves analog tone quality in the dry path.

**Class Table Inheritance** — A database design pattern where a base table contains shared attributes (like `products`), and specialized subtables contain type-specific attributes (like `pedal_details`). Each entity has one row in the base table and one row in its detail table.

**Normalling** — Internal wiring in patch bays/junction boxes that creates a default signal path when nothing is plugged in:
- **Normalled** — Plugging into either jack breaks the internal connection
- **Half-Normalled** — Plugging into the output doesn't break the connection (allows signal splitting); plugging into the input breaks it
- **Non-Normalled** — No internal connection; jacks are independent
- **Parallel** — Jacks are always connected (mult); plugging in never breaks the connection

**Spillover / Trails** — When a time-based effect (delay, reverb) continues its tails after being bypassed or switched out, rather than cutting off abruptly. For loop switchers, this means effect tails can ring out even when the loop is removed from the signal path.

**Topology** (power supplies) — The circuit design used to convert/regulate power:
- **Switch Mode** — Uses high-frequency switching for efficient, lightweight conversion
- **Toroidal** — Uses a toroidal transformer; often quieter, heavier
- **Linear** — Traditional transformer-based; simple, reliable, heavier

---

## Migration Path

1. **Create new tables** alongside existing `pedals` table
2. **Migrate pedal data** to `products` + `pedal_details`
3. **Parse existing I/O fields** into `jacks` rows:
   - `inputs` text → Audio Input jacks
   - `outputs` text → Audio Output jacks
   - Power columns → Power Input jack
4. **Create `pedals_legacy` view** for backward compatibility
5. **Validate** migrated data matches original
6. **Rename old table** to `pedals_old` (keep for rollback)
7. **Update application code** to use new schema
8. **Drop old table** once stable

---

## Example Queries

### Find all pedals by a manufacturer
```sql
SELECT p.model, pd.effect_type, p.msrp_cents / 100.0 AS msrp_dollars
FROM products p
JOIN pedal_details pd ON p.id = pd.product_id
WHERE p.manufacturer_id = 1
ORDER BY p.model;
```

### Find power supplies that fit under a specific pedalboard
```sql
SELECT ps_prod.model, psd.total_output_count, ps_prod.height_mm
FROM products ps_prod
JOIN power_supply_details psd ON ps_prod.id = psd.product_id
WHERE ps_prod.height_mm <= (
    SELECT under_clearance_mm
    FROM pedalboard_details pbd
    JOIN products pb_prod ON pbd.product_id = pb_prod.id
    WHERE pb_prod.model = 'Classic 2'
);
```

### List all jacks for a specific pedal
```sql
SELECT j.category, j.direction, j.jack_name, j.connector_type, j.position
FROM jacks j
JOIN products p ON j.product_id = p.id
WHERE p.model = 'Morning Glory V4'
ORDER BY j.category, j.jack_name;
```

### Find stereo-capable delay pedals with MIDI
```sql
SELECT p.model, m.name AS manufacturer
FROM products p
JOIN manufacturers m ON p.manufacturer_id = m.id
JOIN pedal_details pd ON p.id = pd.product_id
WHERE pd.effect_type = 'Delay'
  AND pd.mono_stereo IN ('Stereo In/Out', 'Mono In/Stereo Out')
  AND pd.midi_capable = 1;
```

### Find all products compatible with a specific pedalboard
```sql
SELECT p2.model, pt.type_name, pc.compatibility_type, pc.notes
FROM product_compatibility pc
JOIN products p1 ON pc.product_a_id = p1.id
JOIN products p2 ON pc.product_b_id = p2.id
JOIN product_types pt ON p2.product_type_id = pt.id
WHERE p1.model = 'Novo 24'
ORDER BY pt.type_name;
```

---

## Files to Modify During Implementation

- `raw_data/pedals.db` — Add new tables, migrate data
- `CLAUDE.md` — Update documentation with new schema reference
- Application code — Update to use new table structure (future task)
