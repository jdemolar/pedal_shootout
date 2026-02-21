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

## Details that still need to be worked out

### 1. UI layout and interaction design

#### Questions
- What does the view actually look like? The plan says "drag connections" but doesn't describe the visual layout — are power supplies on the left and pedals on the right? Cards? Columns? A canvas?
- How are connections drawn — SVG lines, CSS connectors, a canvas layer?
- How does the user initiate a connection — drag from a port dot? Click source then click target? Both?
- How does the user remove or change a connection?
- Mobile/responsive behavior?

### 2. View mode toggle

#### Questions
- The plan mentions a view mode toggle (List / Power / Audio / MIDI) but doesn't specify where it goes in the current Workbench header or how it interacts with the existing layout (sidebar, detail panel,
etc.)
- Does the sidebar stay visible in connection views, or does the connection view replace the whole body?

### 3. State persistence

#### Questions
- Where are connections stored? The WorkbenchContext currently stores items in localStorage but has no concept of connections between items. Need a data structure for connections (e.g., { sourceJackId,
targetJackId, cableType? })
- Are connections per-workbench?
- Do connections survive page reload (localStorage) or eventually need API persistence?

### 4. Daisy-chain / current-doubling UX

#### Questions
- How does a user express "daisy-chain these 3 pedals to one output"? Drag all three to the same port? A separate grouping UI?
- How does current-doubling work visually? Drag two outputs to one pedal? A "combine outputs" button?
- How are Y-cables represented?

### 5. Relationship to existing PowerBudgetInsight

#### Questions
- The existing PowerBudgetInsight component already has a assignPedalsToOutputs() algorithm and port assignment display. Does the power mapping view replace it, extend it, or is it a visual version of the
same thing?
- Should there be an "auto-assign" button that uses the existing algorithm to seed the visual mapping?
- Does the sidebar insight update in real-time as connections are made in the visual view?

### 6. Handling products not yet in the workbench

#### Questions
- Can the user only map items already in the workbench, or can they drag in new products from the catalog?
- What if there's no power supply in the workbench?

### 7. Multiple power supplies

#### Questions
- How are multiple supplies displayed? Side by side? Stacked?
- Can connections span across supplies?

### 8. Adapter/cable representation

#### Questions
- Yellow warnings suggest "needs an adapter" — is this just informational, or can the user explicitly add an adapter/cable to a connection?

### 9. Implementation phasing

#### Questions
- What's the MVP vs. nice-to-have? The plan covers four view modes (Power, Audio, MIDI, List) — are Audio and MIDI in scope for this task, or is this power-only?

Would you like to discuss any of these areas to flesh out the plan, or should I propose recommended approaches for some of them?