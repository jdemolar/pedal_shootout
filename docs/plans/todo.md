# TODO

## Add views as components in `apps/web/src/components`

#### Option 1: View per product type

- /pedals           → Pedal-specific columns (effect type, bypass, MIDI, presets)
- /power-supplies   → Supply-specific columns (outputs, voltages, mounting)
- /pedalboards      → Board-specific columns (usable dimensions, clearance, surface)
- /midi-controllers → Controller-specific columns (switches, banks, loops)
- /utilities        → Utility-specific columns (varies by subtype)
- /plugs            → Plug-specific columns (dimensions, profile)
- /manufacturers    → Already built


> Pros: Each view shows relevant columns, simpler queries  
> Cons: More components to maintain


#### Option 2: Unified products view with type filter

- /products         → Common columns + type filter
                    → Expandable rows show type-specific details

> Pros: Single component, unified search  
> Cons: Type-specific columns awkward to display

#### Option 3: Hybrid (recommended)

- /products         → Unified search/browse across all types (common columns)
- /pedals           → Deep dive with all pedal-specific columns (DONE)
- /power-supplies   → Deep dive with power supply columns
- ...etc

Plus use-case views:

- /board-planner    → Combines pedalboards + pedals + power supplies + plugs
- /power-budget     → Pedals with power requirements vs supply capacity
- /midi-planner     → Controllers + MIDI-capable pedals

The hybrid approach aligns with your stated goals in `data_design.md`:

- Spec comparison → type-specific views
- Pedalboard layout planning → board-planner
- Power budget calculations → power-budget view
- MIDI system planning → midi-planner

  For data entry/maintenance, the type-specific views make sense. For users planning a rig, the use-case views are more valuable.

## Migrate to PostreSQL (DONE)

## Create API

## Move app into cloud infrastructure

## Create pedalboard layout planning (similar to pedalplayground.com)

- System for displaying images on a canvas where scale of all products is relative to each other

## Add tools:

Build the "smart" features:

* **Power budget calculator** - Sum pedal power*current*ma values vs supply capacity
* **Signal path validator** - Flag mono/stereo mismatches, impedance issues
* **MIDI routing helper** - Match controller outputs to pedal MIDI needs

## Add MIDI controller instructions

Add instruction manuals for popular midi controllers to provide a guide on pedalboard programming. Although there may be multiple ways of accomplishing various goals with a controller, having a guide can at least recommend solutions when given a specific problem.
