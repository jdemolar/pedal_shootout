# TODO

> **Numbering:** Sections use numbers (1, 2, …). Items use `<section>.<letter>` (e.g., 2.c, 8.a).
> Cross-reference dependencies with `→ depends on X.Y`.

---

## Dependency Map

```
9.a–9.e (data population) ──┬──→ 1.a (Plugs view needs plug data)
                             ├──→ 5.a (Layout planner needs pedalboard + plug data)
                             ├──→ 4.a, 10.a, 10.b (MIDI features need MIDI controller data)
                             └──→ 6.e (slot finder benefits from dimensions + power jack data)

2.a (cable routing waypoints) ──→ 2.b (cable length estimation)

7.a (write API) ──→ 2.h (backend persistence needs POST/PUT/DELETE)

10.a (cloud infra) ──→ 10.b (Node upgrade via Docker)

6.b (comparison table) ──→ 6.c (contextual suggestions use comparison bar)
                        └──→ 6.d (guided finder feeds into comparison bar)
6.c + 6.d ──────────────────→ 6.e (slot finder builds on both)

7.d (PowerView rotation) ──→ 7.e (PowerView z-index; natural to do together)

8.f (trs_midi_standard col) ──→ improved MIDI TRS auto-detection (no separate task yet)
8.g–8.j (control schema gaps) ──→ improved auto-validation in Control view
```

---

## 1. Catalog Views

- [ ] **1.a — Plugs view** → depends on 8.e (plug data)

## 2. Connections & Cabling (design: `docs/plans/connections-and-cabling.md`)

- [x] **2.✓1 — Structured validation types** — Shared `ConnectionWarning`/`ConnectionValidation` types; migrate `powerUtils.ts` to use them (plan: `docs/plans/completed/connections-phase-1-validation-types.md`)
- [x] **2.✓2 — Audio connections view** — Signal chain schematic (right-to-left), virtual nodes, stereo pairs, per-item missing-data warnings, placeholder items with configurable jack configs (plan: `docs/plans/completed/audio-connections-phase-2-revised.md`)
- [x] **2.✓3 — MIDI connections view** — Chain/hub topology, channel assignment, TRS standard detection (TRS-A, TRS-B, Tip Active, Ring Active) (plan: `docs/plans/completed/midi-connections-phase-3.md`)
- [x] **2.✓4 — MIDI device settings refactor** — Move MIDI channel and clock send/receive from connection-level to device-level settings (plan: `docs/plans/completed/midi-device-settings-refactor.md`)
- [x] **2.✓5 — Control connections view** — Expression, aux switch, CV connections with polarity validation (plan: `docs/plans/completed/control-connections-phase-4.md`)
- [x] **2.✓6 — Unified shopping list** — Cable requirements as rows in List tab alongside products, custom cable detection for connector mismatches (plan: `docs/plans/completed/unified-shopping-list-phase-5.md`)
- [ ] **2.a — Cable routing waypoints** — Hideable cable-path layer over the Layout view (not the Audio schematic view). Full context and existing infrastructure documented in `docs/plans/audio-cable-routing-waypoints.md`. Requires: jack position data per enclosure, port dot placement in Layout view accounting for card rotation, waypoint add/move/remove UI (logic already written — see closed PR #52), length estimation feeding into shopping list.

#### Shopping list — deferred improvements

- [ ] **2.b — Cable length estimation** → depends on 2.a (cable routing waypoints). Requires Layout view waypoint data.
- [ ] **2.c — Direction-agnostic cable grouping** — Cables with the same connector types in opposite order (e.g., 1/4" TRS → 1/4" TS and 1/4" TS → 1/4" TRS) should be counted in the same row. The grouping key in `shoppingListUtils.ts` currently treats source/target order as distinct.
- [ ] **2.d — Cable connector prompt for TRS jacks** — When creating a connection where either end is a TRS jack, show a prompt asking the user to specify the cable connector type for each end (e.g., TRS or TS). A TRS jack can accept a TS plug, so the user should be able to choose. This affects both the connection's signal mode and the shopping list cable type. Currently TRS-to-TRS auto-creates a stereo connection, but the user may want a TS cable for a mono signal; similarly, TS-to-TRS connections should let the user confirm the cable type for each end.
- [ ] **2.e — CSV export** — Export shopping list as CSV for offline use.
- [ ] **2.f — User-editable cable prices** — Allow users to set per-cable-type prices for cost estimation.
- [ ] **2.g — "Have" checkbox persistence** — Let users mark cables they already own; requires new workbench state field.
- [ ] **2.h — Backend persistence** → depends on 7.a (write API) + user accounts. JSONB workbench storage.

## 3. Audio / Signal Path

- [x] **3.✓1 — False cycle detection in loop switcher send/return** — Audio cycle detection falsely flags feedback loops when connecting a pedal in a loop switcher's send/return loop (e.g., RJM Mastermind PBC 10). The cycle detection sees A→B and B→A as a cycle, but send/return is intentionally bidirectional. (plan: `docs/plans/completed/fix-send-return-cycle-detection.md`)
- [x] **3.✓2 — TRS multi-connection support for stereo pairs** — A TRS jack can carry two independent signals (tip + ring), but the stereo pair auto-connection logic assumes each connection needs a unique jack on both sides. When one side has a single TRS jack and the other has discrete L/R jacks (stereo pair with shared `group_id`), the same TRS jack should be reused for both connections — one per conductor. This generalizes beyond send/return loops to any TRS-to-discrete-stereo scenario (balanced connections, mixer inserts, etc.). The shopping list should derive "TRS to 2×TS insert cable" when a single TRS jack sources two connections. (plan: `docs/plans/completed/trs-stereo-pair-support.md`)
- [ ] **3.a — Signal path validator** — Flag mono/stereo mismatches, impedance issues.

## 4. MIDI

- [ ] **4.a — MIDI routing helper** → benefits from 8.c (MIDI controller data). Match controller outputs to MIDI-capable pedals, plan MIDI channel/PC/CC assignments.

## 5. Board Planning

- [ ] **5.a — Pedalboard layout planner** → benefits from 8.b (pedalboard data), 8.e (plug data). Visual layout tool combining pedalboards, pedals, power supplies, and plugs (similar to pedalplayground.com).

## 6. Shopping & Comparison

(plan: `docs/plans/comparison-and-buying-flow.md`)

- [ ] **6.a — Shopping list view** — Display workbench items as shopping list, with has, needs, price, totals, and links to purchase.
- [ ] **6.b — Side-by-side comparison table** — Compare toggle on catalog rows, persistent comparison bar, `/compare` route with spec columns, best-value highlights, and buy links per product. No schema changes needed. Foundational affiliate surface.
- [ ] **6.c — Contextual suggestions** → depends on 6.b (comparison bar integration). "You might also consider" panel in catalog expanded rows and workbench detail panel. Similarity scored client-side from existing spec data. Spec delta callouts ("adds MIDI", "30mm shorter"). Swap button in workbench.
- [ ] **6.d — Guided finder** (`/find`) → benefits from 6.b (comparison bar). Question-driven shortlist for less technical buyers. 6 questions, client-side filter/rank, results feed into comparison bar and buy links. Pre-fillable from workbench board context (see 6.e).
- [ ] **6.e — Workbench slot finder** → depends on 6.c (fit indicators), 6.d (pre-fill), benefits from good data coverage on dimensions + power jacks. Context-aware "find a pedal for this slot" using live board constraints (physical space, power budget, signal chain mode, MIDI availability). Marquee differentiator — no other tool has this.

## 7. UI & UX

(design plan: `docs/plans/design-system-redesign.md`)

- [x] **7.✓1** — Make objects rotateable (Layout view — `docs/plans/completed/rotation-z-index.md`)
- [x] **7.✓2** — Enable objects to be sent forward or back on z-axis (Layout view — `docs/plans/completed/rotation-z-index.md`)
- [ ] **7.a — Design system implementation** — Apply Vintage PCB redesign: design tokens (`_tokens.scss`), web fonts (Barlow Condensed + JetBrains Mono), nav, DataTable, workbench cards, panels, badges, canvas dot grid. Implement in the order specified in the plan. No architectural changes — token and typography migration. (plan: `docs/plans/design-system-redesign.md`)
- [ ] **7.b — Unit toggle** — Enable toggle for units of measurement (mm ↔ inches).
- [ ] **7.c — Product images** — Add images to views so users can see the product within the details view (in expanded row panels).
- [ ] **7.d — PowerView rotation** — Add rotation to PowerView and other planning views (see `docs/plans/options/powerview-rotation.md`).
- [ ] **7.e — PowerView z-index** — Add z-index ordering to PowerView and other planning views. Natural companion to 7.d.
- [ ] **7.f — Swap manufacturer/model card text** — Swap position and style of Manufacturer text and Model text in cards (e.g., "BigSky" at top in white and "Strymon" below in green). Superseded in part by 7.a (design system); revisit after.
- [ ] **7.g — Hideable nav** — Make nav and menu area hideable for increased screen real estate (especially on mobile). Superseded in part by 7.a mobile nav redesign; revisit after.

## 8. API

- [ ] **8.a — POST/PUT/DELETE endpoints** — Not started. GET-only until explicitly requested. Required by 2.h (backend persistence).

## 9. Data Collection & Quality

- [ ] **9.a — Populate power supply data** (ongoing)
- [ ] **9.b — Populate pedalboard data** (not started)
- [ ] **9.c — Populate MIDI controller data** (not started)
- [ ] **9.d — Populate utility data** (not started)
- [ ] **9.e — Populate plug data** (not started)
- [ ] **9.f — `trs_midi_standard` column** — Add to `jacks` table. Currently the MIDI connections view stores TRS wiring configuration (TRS-A, TRS-B, Tip Active, Ring Active) at the connection level rather than per-jack. Once this column exists, validation can derive the standard from the jack data directly and pre-populate the connection's TRS setting automatically.

### Control connections enhancements

#### Schema gaps

- [ ] **9.g — TRS polarity per jack** — Add `trs_polarity` column to `jacks` table (`'tip-active'`, `'ring-active'`, or NULL). Expression jacks have a default polarity that determines compatibility (e.g., Mission Engineering is tip-active, Chase Bliss is ring-active). Currently the Control view stores polarity on the connection, but per-jack data would enable automatic mismatch detection.
- [ ] **9.h — Potentiometer resistance** — Add `impedance_ohms` or `pot_resistance_ohms` column to `jacks` table for expression jacks. Pot resistance (e.g., 10K vs 25K Ohm) affects compatibility between expression pedals and their targets. The existing `impedance_ohms` column is intended for audio impedance matching, so a separate column may be needed.
- [ ] **9.i — Toe switch type** — Add `footswitch_type` column to `jacks` table (`'momentary'`, `'latching'`) for aux/toe switch jacks. Currently `footswitch_type` only exists on `midi_controller_details`. Expression pedals with toe switches (e.g., Mission SP-25M-PRO Aero) need this data for the Control view to validate switch compatibility.
- [ ] **9.j — Independent channel count** — Add a way to represent ganged vs independent expression outputs. Multi-channel expression pedals (e.g., Mission SP-25L-PRO Aero with 3 independent outputs) need to indicate whether channels move together or independently. This could be a column on `utility_details` or a relationship between jacks.

#### Deferred `ControlConnection` fields

- [ ] **9.k — `controlledParameter`** — Which parameter on the target device is being controlled (e.g., volume, feedback, mix). Requires parameter assignment UI.
- [ ] **9.l — `rangeMin` / `rangeMax`** — Parameter range clamping for expression connections. Limits the effective sweep of the control source.
- [ ] **9.m — `auxSwitchAssignments`** — Per-contact function names for aux switch connections (e.g., tap tempo, preset up/down).
- [ ] **9.n — `cvVoltageRange`** — Voltage range spec for CV connections (e.g., 0–5V, ±10V).

## 10. MIDI Controller Guides

- [ ] **10.a — Instruction manual guides** → benefits from 9.c (MIDI controller data). Add instruction manuals for popular MIDI controllers to provide a guide on pedalboard programming. Although there may be multiple ways of accomplishing various goals with a controller, having a guide can at least recommend solutions when given a specific problem.
- [ ] **10.b — AI-powered MIDI programming interface** → depends on 10.a (guides), benefits from 9.c (MIDI controller data). Plain-language interface for programming MIDI controllers for desired workflow with specific pedals.

## 11. Infrastructure

- [ ] **11.a — Cloud deployment** — Move app into cloud infrastructure.
- [ ] **11.b — Node/package upgrade** → depends on 11.a (Docker in cloud circumvents macOS limitations). Update node and all packages to newer versions.

---

## Priority & Complexity Summary

### Quick wins (standalone, small scope)

| Item | Description |
|------|-------------|
| 2.c  | Direction-agnostic cable grouping (one util function) |
| 2.e  | CSV export (small feature) |
| 7.a  | Unit toggle (mm ↔ inches) |
| 7.e  | Swap manufacturer/model card text styling |
| 7.f  | Hideable nav area |
| 9.f  | `trs_midi_standard` column (schema + migration) |
| 9.g  | TRS polarity per jack (schema + migration) |
| 9.h  | Potentiometer resistance column (schema + migration) |
| 9.i  | Toe switch type column (schema + migration) |

### Medium effort (standalone, moderate scope)

| Item | Description |
|------|-------------|
| 2.d  | Cable connector prompt for TRS jacks (UI + logic) |
| 2.f  | User-editable cable prices |
| 2.g  | "Have" checkbox persistence |
| 3.a  | Signal path validator |
| 6.a  | Shopping list view |
| 6.b  | Side-by-side comparison table + buy links (no schema changes) |
| 6.c  | Contextual suggestions with spec deltas + swap |
| 6.d  | Guided finder `/find` (client-side filter/rank) |
| 7.a  | Design system implementation (Vintage PCB — tokens, fonts, workbench cards, nav, badges) |
| 7.c  | Product images |
| 7.d + 7.e | PowerView rotation + z-index (do together) |
| 9.j  | Independent channel count (schema design decision) |
| 9.k–9.n | Deferred ControlConnection fields (UI + schema) |

### High effort / blocked

| Item | Blocker or notes |
|------|------------------|
| 1.a  | Blocked on 9.e (plug data) |
| 2.a  | Requires jack position data schema work |
| 2.b  | Blocked on 2.a |
| 2.h  | Blocked on 8.a + user accounts |
| 4.a  | Benefits from 9.c (MIDI controller data) |
| 5.a  | Benefits from 9.b + 9.e (pedalboard + plug data) |
| 6.e  | Slot finder — depends on 6.c + 6.d; benefits from good dimension + power jack data coverage |
| 8.a  | Large scope (write API) |
| 10.a–10.b | Benefits from 9.c; 10.b depends on 10.a |
| 11.a–11.b | Infrastructure; 11.b blocked on 11.a |

### Data population (ongoing, no blockers)

| Item | Description |
|------|-------------|
| 9.a  | Power supply data (ongoing) |
| 9.b  | Pedalboard data |
| 9.c  | MIDI controller data — **high value**, unblocks 4.a, 10.a, 10.b |
| 9.d  | Utility data |
| 9.e  | Plug data — **high value**, unblocks 1.a, 5.a |

---

## Data Maintenance Notes (ongoing)

- Regularly verify and update reliability ratings as new sources emerge
- When crowd-sourcing begins, all user-submitted data starts as "Low" until verified
- Cross-reference specifications across multiple sources when possible
- Flag conflicts between sources for manual review
