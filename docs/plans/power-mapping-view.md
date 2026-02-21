# Plan: Power Mapping View (Pedal-to-Port Mapping)

*Separate task from the immediate power budget bug fixes in [improve-power-budgeting-tool.md](./improve-power-budgeting-tool.md).*

## Vision: Workbench connection views

The workbench gets a view mode toggle with multiple modes:
- **List view** (current) — table of all workbench items with sidebar insights
- **Power connection view** — drag-and-drop mapping of pedals to power supply outputs
- **Audio connection view** — signal chain routing (pedal order, mono/stereo paths)
- **MIDI connection view** — MIDI controller-to-pedal routing

Each connection type gets its own diagram to keep things clean and focused. Only the connection views enable drag-and-drop; list view stays as-is.

## Power connection view — design notes

**Core interaction:** User drags connections between pedal power input jacks and power supply output jacks. Supports:
- **One-to-one** — standard: one pedal per output
- **Many-to-one (daisy-chain)** — multiple low-draw pedals sharing one output
- **One-to-many (current doubling)** — one high-draw pedal fed by multiple outputs via a Y-cable. Common for pedals drawing >500mA (e.g., Strymon, Line 6, HX Stomp). Most supply outputs max out at 500mA (some Cioks outputs go to 660mA at 9V), so guitarists use current-doubling cables that combine two outputs.

**Real-time validation:** As the user drags or after a connection is made, highlight the connection/port with warning colors:
- **Green** — compatible (voltage, current, polarity, connector all match)
- **Yellow** — works but needs an adapter (polarity reversal cable, connector adapter)
- **Red** — incompatible (insufficient current, wrong voltage with no selectable option)
- Clickable warning icon on each connection reveals specific details (e.g., "This output provides ~250mA at 18V but pedal draws 300mA")

**Voltage/current relationship:** The stored `current_ma` on a jack represents the rating at the lowest selectable voltage. For selectable-voltage outputs, the effective current at a higher voltage is estimated using constant-wattage math:

```
effective_mA = stored_mA × (base_voltage / selected_voltage)
```

Example: A `9V/12V/18V` output rated at 500mA → 500mA at 9V, 375mA at 12V, 250mA at 18V. This is conservative and physically accurate for switching-topology supplies. The `effectiveCurrentMa()` utility in `powerUtils.ts` handles this calculation.

**When voltage is selectable:** If a pedal needing 18V is connected to a `9V/12V/18V` output, the tool should automatically "set" that output to 18V and recalculate available current accordingly. The selected voltage affects current capacity warnings for that output.

**Data conventions:**
- `current_ma` in the `jacks` table always represents the maximum current at the base (lowest) voltage
- This convention should be documented in CLAUDE.md under "Standard Field Value Conventions"
