# Guitar Gear Database Schema Redesign

## Overview

Redesign the SQLite database to support multiple product types (pedals, power supplies, pedalboards, MIDI controllers, utilities, plugs) using **Class Table Inheritance** with a **unified jacks table**.

## Design Pattern

**Class Table Inheritance**: A shared `products` base table contains common attributes, with type-specific detail tables extending it.

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

**Note**: Cables excluded for now. Plugs are included because their physical profile affects pedal spacing on a board - users need to plan around plug dimensions.

### Jacks Table Structure

```sql
CREATE TABLE jacks (
    id INTEGER PRIMARY KEY,
    product_id INTEGER NOT NULL REFERENCES products(id),
    category TEXT NOT NULL,      -- 'Audio Input', 'Audio Output', 'MIDI In', 'Power Output', 'Expression', etc.
    direction TEXT NOT NULL,     -- 'Input', 'Output', 'Bidirectional'
    jack_name TEXT,              -- 'Input L', 'Exp 1', 'Loop 1 Send'
    position TEXT,               -- 'Top', 'Left', 'Right', etc.
    connector_type TEXT NOT NULL,-- '1/4" TS', '1/4" TRS', 'XLR', '5-pin DIN', '2.1mm barrel'
    impedance_ohms INTEGER,      -- For audio jacks
    voltage TEXT,                -- For power jacks
    current_ma INTEGER,          -- For power jacks
    polarity TEXT,               -- 'Center Negative', 'Center Positive'
    function TEXT,               -- Detailed description
    power_over_connector INTEGER DEFAULT 0,
    is_isolated INTEGER DEFAULT 0,
    group_id TEXT                -- Links stereo pairs, FX loop send/return
);
```

### Supporting Tables

| Table | Purpose |
|-------|---------|
| `product_compatibility` | Links compatible products (pedalboard + power supply, etc.) |

## Key Design Decisions

1. **Plugs instead of cables**: Cables are excluded (length depends on pedal arrangement). Plugs are included because their physical profile affects pedal spacing. A "pancake" plug vs. a straight plug changes how close pedals can be placed.

2. **Dimensions in mm**: International standard, precise. Products table stores `width_mm`, `depth_mm`, `height_mm`, `weight_grams`.

3. **FX Loops via group_id**: Send and return jacks share a `group_id` value (e.g., "loop_1") to link them as a pair.

4. **Hybrid products** (e.g., pedalboard with integrated power): Use `integrated_power_id` FK or create two linked products via `product_compatibility`.

## Plug Details Structure

```sql
CREATE TABLE plug_details (
    product_id INTEGER PRIMARY KEY REFERENCES products(id),
    plug_type TEXT NOT NULL,        -- 'patch', 'instrument', 'power', 'midi'
    connector_type TEXT NOT NULL,   -- '1/4" TS', '1/4" TRS', '2.1mm barrel', etc.
    is_right_angle INTEGER DEFAULT 0,
    is_pancake INTEGER DEFAULT 0,   -- Flat/low-profile design
    plug_width_mm REAL,             -- Width of the plug housing
    plug_depth_mm REAL,             -- How far it protrudes from jack
    plug_height_mm REAL,            -- Height of plug housing
    cable_exit_direction TEXT,      -- 'straight', 'up', 'down', 'side'
    is_solderless INTEGER DEFAULT 0 -- DIY solderless system
);
```

This enables pedalboard layout planning: "If I use pancake plugs, I can fit pedals 5mm closer together."

## Migration Path

1. Create new tables alongside existing `pedals` table
2. Migrate pedal data to `products` + `pedal_details`
3. Parse existing `inputs`/`outputs` text fields into `jacks` rows
4. Create `pedals_legacy` view for backward compatibility
5. Validate, then drop old table

## Files to Modify

- `raw_data/pedals.db` - Add new tables, migrate data
- `CLAUDE.md` - Update documentation with new schema

## Verification

1. Run schema creation SQL
2. Migrate existing pedal data
3. Query via `pedals_legacy` view to confirm backward compatibility
4. Insert sample data for each new product type
5. Test cross-product queries (e.g., "find power supplies compatible with this pedalboard's clearance")
