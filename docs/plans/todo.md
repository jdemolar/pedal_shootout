# TODO

## 1. Add type-specific views:

- [x] Manufacturers
- [x] Products
- [x] Pedals
- [x] Power Supplies
- [x] Pedalboards
- [x] MIDI Controllers
- [x] Utilities
- [ ] Plugs

## 2. Add use-case views:

- [ ] /board-planner    → Combines pedalboards + pedals + power supplies + plugs
- [x] /power-budget     → Pedals with power requirements vs supply capacity
- [ ] /midi-planner     → Controllers + MIDI-capable pedals

## 3. Build the "smart" features:

- [x] **Power budget calculator** - Sum pedal power *current* mA values vs supply capacity
- [ ] **Signal path validator** - Flag mono/stereo mismatches, impedance issues
- [ ] **MIDI routing helper** - Match controller outputs to pedal MIDI needs
- [ ] **Unit toggle** - Enable toggle for units of measurement (mm ↔ inches)
- [x] **Sticky nav, filters, and table headers** - Viewport-locked flex layout keeps nav, filters, and column headers fixed while only table body rows scroll
- [x] **Power budget calculator improvements:**
	- [x] Revisit the value and accuracy of URL param filters, especially voltage
	- [x] Show URL param filters in UI
	- [x] Check why polarity warning is showing when it shouldn't
	- [x] Figure out how to suggest mapping of pedals to power ports on power supply/supplies
	- [ ] Show appropriate setting for ports with selectable/variale voltage in "Show port assigments"

## 4. Spring Boot API:

- [x] Spring Boot API (25 GET endpoints — 19 Layer 1 + 6 Layer 2)
- [x] OpenAPI spec (`docs/openapi.yaml`)
- [ ] POST/PUT/DELETE endpoints (not started — GET-only until explicitly requested)

## 5. Data collection & quality:

- [x] Data collection checklists in CLAUDE.md (field-by-field tables per product type)
- [x] SQL insert templates (`data/templates/` — one per product type)
- [x] Data provenance plan (`docs/plans/data_provenance.md`)
- [x] Power supplies data collection guidelines in CLAUDE.md
- [ ] Populate power supply data (ongoing)
- [ ] Populate pedalboard data (not started)
- [ ] Populate MIDI controller data (not started)
- [ ] Populate utility data (not started)
- [ ] Populate plug data (not started)

## 6. Product images:

- [ ] Add images to views so users can see the product within the details view (in expanded row panels)

## 7. Product comparison & shopping:

- [ ] Create a way for users to put multiple products into a "cart" for product comparison and compatibility analysis, generating a shopping list, and moving to pedal arrangement

## 8. Pedalboard layout planning:

- [ ] Create pedalboard layout planning (similar to pedalplayground.com)
- [ ] System for displaying images on a canvas where scale of all products is relative to each other

## 9. Product instructions (especially MIDI controllers):

- [ ] Add instruction manuals for popular MIDI controllers to provide a guide on pedalboard programming. Although there may be multiple ways of accomplishing various goals with a controller, having a guide can at least recommend solutions when given a specific problem.
- [ ] AI-powered plain-language interface for programming MIDI controllers for desired workflow with specific pedals

## 10. Cloud infrastructure:

- [ ] Move app into cloud infrastructure

## 11. Fixes and Improvements

- [x] Enable users to select multiple instances of the same pedal
- [ ] Layout views improvements
	- [ ] Make objects rotateable
	- [ ] Make objects fit product dimensions
	- [x] Add a delete button to selected connection lines
- [x] Move to Docker for better development processes
	- [ ] Update node and all packages to newer versions if Docker circumvents macOS limitations

---

## Data Maintenance Notes (ongoing)

- Regularly verify and update reliability ratings as new sources emerge
- When crowd-sourcing begins, all user-submitted data starts as "Low" until verified
- Cross-reference specifications across multiple sources when possible
- Flag conflicts between sources for manual review
