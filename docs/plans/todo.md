# TODO

## Add new tables for:

* **pedalboards** - dimensions (including height/clearance), material, mounting type, inputs/outputs, weight capacity
* **power_supplies** - outputs (count, voltage, current per output), total current, isolated vs non-isolated, switch mode vs torroidal
* **midi_controllers** - channels, presets, footswitches, expression inputs
* **cables** - type (patch, power, MIDI), length, plug types

Consider a compatibility junction table linking products that work well together.

## Add tools:

Build the "smart" features:

* **Power budget calculator** - Sum pedal power*current*ma values vs supply capacity
* **Signal path validator** - Flag mono/stereo mismatches, impedance issues
* **MIDI routing helper** - Match controller outputs to pedal MIDI needs

## Add MIDI controller instructions

Add instruction manuals for popular midi controllers to provide a guide on pedalboard programming. Although there may be multiple ways of accomplishing various goals with a controller, having a guide can at least recommend solutions when given a specific problem.
