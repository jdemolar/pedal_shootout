# TODO

## 1. Catalog views

- [ ] Plugs

## 2. Audio / Signal path

- [ ] **Signal path validator** — Flag mono/stereo mismatches, impedance issues

## 3. MIDI

- [ ] **MIDI routing helper** — Match controller outputs to MIDI-capable pedals, plan MIDI channel/PC/CC assignments

## 4. Board planning

- [ ] **Pedalboard layout planner** — Visual layout tool combining pedalboards, pedals, power supplies, and plugs (similar to pedalplayground.com)

## 5. Shopping & comparison

- [ ] **Shopping list view** — Display workbench items as shopping list, with has, needs, price, totals, and links to purchase

## 6. UI & UX

- [ ] **Unit toggle** — Enable toggle for units of measurement (mm ↔ inches)
- [ ] **Product images** — Add images to views so users can see the product within the details view (in expanded row panels)
- [x] Make objects rotateable (Layout view — `docs/plans/completed/rotation-z-index.md`)
- [x] Enable objects to be sent forward or back on z-axis (Layout view — `docs/plans/completed/rotation-z-index.md`)
- [ ] Add rotation to PowerView and other planning views (see `docs/plans/options/powerview-rotation.md`)
- [ ] Add z-index ordering to PowerView and other planning views
- [ ] Swap position and style of Manufacturer text and Model text in cards (e.g., "BigSky" at top in white and "Strymon" below in green) 

## 7. API

- [ ] POST/PUT/DELETE endpoints (not started — GET-only until explicitly requested)

## 8. Data collection & quality

- [ ] Populate power supply data (ongoing)
- [ ] Populate pedalboard data (not started)
- [ ] Populate MIDI controller data (not started)
- [ ] Populate utility data (not started)
- [ ] Populate plug data (not started)

## 9. MIDI controller guides

- [ ] Add instruction manuals for popular MIDI controllers to provide a guide on pedalboard programming. Although there may be multiple ways of accomplishing various goals with a controller, having a guide can at least recommend solutions when given a specific problem.
- [ ] AI-powered plain-language interface for programming MIDI controllers for desired workflow with specific pedals

## 10. Infrastructure

- [ ] Move app into cloud infrastructure
- [ ] Update node and all packages to newer versions if Docker circumvents macOS limitations

---

## Data Maintenance Notes (ongoing)

- Regularly verify and update reliability ratings as new sources emerge
- When crowd-sourcing begins, all user-submitted data starts as "Low" until verified
- Cross-reference specifications across multiple sources when possible
- Flag conflicts between sources for manual review
