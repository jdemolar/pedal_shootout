# TODO

## 1. Catalog views

- [ ] Plugs

## 2. Connections & Cabling (design: `docs/plans/connections-and-cabling.md`)

- [x] **Structured validation types** — Shared `ConnectionWarning`/`ConnectionValidation` types; migrate `powerUtils.ts` to use them (plan: `docs/plans/completed/connections-phase-1-validation-types.md`)
- [x] **Audio connections view** — Signal chain schematic (right-to-left), virtual nodes, stereo pairs, per-item missing-data warnings, placeholder items with configurable jack configs (plan: `docs/plans/completed/audio-connections-phase-2-revised.md`)
- [ ] **Cable routing waypoints** — Hideable cable-path layer over the Layout view (not the Audio schematic view). Full context and existing infrastructure documented in `docs/plans/audio-cable-routing-waypoints.md`. Requires: jack position data per enclosure, port dot placement in Layout view accounting for card rotation, waypoint add/move/remove UI (logic already written — see closed PR #52), length estimation feeding into shopping list.
- [x] **MIDI connections view** — Chain/hub topology, channel assignment, TRS standard detection (TRS-A, TRS-B, Tip Active, Ring Active) (plan: `docs/plans/completed/midi-connections-phase-3.md`)
- [x] **MIDI device settings refactor** — Move MIDI channel and clock send/receive from connection-level to device-level settings (plan: `docs/plans/completed/midi-device-settings-refactor.md`)
- [ ] **Control connections view** — Expression, aux switch, CV connections with polarity validation
- [ ] **Unified shopping list** — Cables/adapters as rows in List tab alongside products, length estimation from waypoints
- [ ] **Backend persistence** — JSONB workbench storage (deferred until user accounts exist)

## 3. Audio / Signal path

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
- [ ] Make nav and menu area hideable for increased screen real estate (especially on mobile)

## 7. API

- [ ] POST/PUT/DELETE endpoints (not started — GET-only until explicitly requested)

## 8. Data collection & quality

- [ ] Populate power supply data (ongoing)
- [ ] Populate pedalboard data (not started)
- [ ] Populate MIDI controller data (not started)
- [ ] Populate utility data (not started)
- [ ] Populate plug data (not started)
- [ ] Add `trs_midi_standard` column to `jacks` table — currently the MIDI connections view stores TRS wiring configuration (TRS-A, TRS-B, Tip Active, Ring Active) at the connection level rather than per-jack. Once this column exists, validation can derive the standard from the jack data directly and pre-populate the connection's TRS setting automatically.

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
