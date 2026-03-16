# Comparison & Buying Flow

**Status:** Design
**Created:** 2026-03-15

## Context

One of the primary differentiators for Pedal Shootout is moving users from research to purchase — not as a hard sell, but as a natural byproduct of having the best planning tool available. Four complementary features accomplish this:

1. **Side-by-side comparison table** (Option A) — standalone spec comparison with buy links
2. **Guided finder** (Option B) — question-driven shortlist generator for less technical buyers
3. **Workbench-integrated slot finder** (Option C) — context-aware "find a pedal for this slot" inside the board planner
4. **Contextual suggestions** (Option D) — "you might also consider" panel in catalog and workbench views

These are designed to layer on top of each other. The natural build order progresses from the simplest affiliate surface (A) through increasingly differentiated features (D, B, C), culminating in the marquee feature that no other tool offers (C).

---

## Design Decisions

| Decision | Choice | Rationale |
|---|---|---|
| Buy link targets | External affiliate links (Sweetwater, Thomann, Reverb) | MSRP data already in DB; product_page already stored. No in-app checkout needed. |
| Comparison state | Frontend-only (URL params or session state) | No backend needed for comparison selections — shareable URLs are a bonus |
| Slot finder constraints | Derived live from workbench state | Physical dimensions, remaining power budget, signal chain mode — all already computed |
| Similarity algorithm | Spec-field overlap scoring | Effect type match is mandatory; other fields (size, power, MIDI, stereo) contribute to rank |
| Guided finder logic | Frontend filter chain | Not ML — a deterministic filter/rank over the existing catalog based on question answers |
| Editorial content | Minimal at launch | "Why this fits" callouts derived from spec deltas, not hand-written copy |

---

## Phased Implementation Plan

### Phase 1 — Option A: Side-by-Side Comparison Table

**Goal:** Let users pin products and compare their specs in a column layout, with buy links per product. This is the foundational affiliate surface and the fastest to ship.

**Steps:**

1. **Add compare toggle to DataTable rows**
   - Add a "Compare" checkbox or icon to each row in all catalog views
   - Store compared item IDs in a `useComparison` hook (React context, session-scoped)
   - Cap at 5 items — show a toast if user tries to add a 6th

2. **Add persistent comparison bar**
   - A fixed bar at the bottom of the screen showing thumbnails/names of pinned items
   - Shows item count ("3 items selected"), a "Compare" CTA button, and an "X" to clear
   - Only visible when ≥2 items are pinned
   - Designed to not obscure the table footer or workbench controls

3. **Build the Comparison view (`/compare`)**
   - New route `/compare?ids=1,2,3`
   - Products as columns, spec fields as rows
   - Grouped row sections matching existing detail panel groups (e.g., Signal, Bypass, MIDI, Power, Dimensions)
   - Cells highlight the "best" value per row using per-field comparison logic (lowest power draw, highest preset count, smallest footprint, etc.)
   - Null/unknown values shown distinctly — don't highlight unknowns as "best"
   - Header row: manufacturer + model name, MSRP, product type badge
   - Footer row per column: MSRP + buy link buttons (Sweetwater, Thomann, product page)

4. **Add buy links to catalog expanded rows**
   - In the existing expanded detail panel for each row, add a "Buy" link cluster
   - Sources: `product_page` (manufacturer), Sweetwater search fallback, Reverb search fallback
   - Small, tasteful — not a dominant UI element

5. **Add comparison CTA to workbench detail panel**
   - "Compare with similar" link in the workbench detail panel for a selected item
   - Populates comparison bar with the current item and opens catalog view filtered to same effect type

**Data requirements:** No schema changes needed. Uses `msrp_cents`, `product_page`, and existing spec fields.

---

### Phase 2 — Option D: Contextual Suggestions

**Goal:** Surface 2–3 relevant alternatives inline when a user is viewing a product — in both catalog and workbench. Lower build cost than B or C, high value per interaction.

**Steps:**

1. **Define similarity scoring**
   - Write a `scoreSimilarity(source: Product, candidate: Product): number` utility
   - Mandatory match: `effect_type` (pedals) or `utility_type` (utilities) or product type
   - Contributing factors (weighted): signal type match, mono/stereo match, power range proximity, size class proximity, MIDI capability match, price range proximity
   - Returns a 0–1 score; threshold for "similar" is configurable

2. **Add "You might also consider" section to catalog expanded rows**
   - Below the existing spec detail grid, add a compact row of 2–3 suggestion cards
   - Each card: manufacturer + model, type badge, 1–2 key spec deltas ("adds MIDI", "30mm shorter", "+$100")
   - Tapping a suggestion card expands it in place (or opens its own row)
   - Each suggestion card has a buy link

3. **Add suggestions panel to workbench detail panel**
   - Below the existing product specs in the detail panel, add "Similar options" section
   - Same compact card format
   - Cards have "Swap" button — replaces the selected workbench item with the suggestion
   - Swap respects connection state: warns if the replacement has different jack counts/types that would break existing connections

4. **Spec delta callout logic**
   - For each suggestion, compute 2–3 of the most meaningful differences vs. the source product
   - Priority: MIDI (add/remove), stereo (add/remove), size (smaller/larger by >20mm), price (±25%), preset count (add/remove), bypass type
   - Display as small labeled chips: "+ MIDI", "− Stereo", "30mm shorter", "+$50"

**Data requirements:** No schema changes. Suggestions are computed client-side from existing API data.

---

### Phase 3 — Option B: Guided Finder ("Help Me Choose")

**Goal:** A short questionnaire that produces a ranked shortlist with buy links. Captures buyers who don't know the market and helps them reach a purchase decision.

**Steps:**

1. **Design the question flow**
   - Maximum 6 questions; each answer filters/weights the candidate pool
   - Questions (in order):
     1. Product type (pedal / power supply / utility / …)
     2. Effect type (for pedals — Gain, Reverb, Delay, etc.) or sub-type for other categories
     3. Budget (under $100 / $100–$200 / $200–$400 / $400+)
     4. Signal path: Mono or Stereo?
     5. MIDI? (Yes / No / Nice to have)
     6. Size constraint? (No preference / Small (<100mm) / Medium / Any)
   - Questions adapt based on prior answers (e.g., question 4 skips for power supplies)

2. **Build the Finder UI (`/find`)**
   - New route `/find`
   - Step-by-step card interface — one question at a time, with large tap targets (mobile-first)
   - Progress indicator (step 2 of 5)
   - "Back" button on each step
   - Final step shows results immediately (no loading state needed — client-side filter)

3. **Implement results ranking**
   - Filter candidates by mandatory answers (type, effect type, budget range)
   - Score remaining candidates by optional answers (mono/stereo, MIDI, size)
   - Sort by score descending, break ties by MSRP ascending (best value first)
   - Show top 5–8 results
   - Each result: full product card with key specs, MSRP, buy link buttons
   - "Compare selected" button pre-populates comparison bar with result items

4. **Entry points**
   - "Find a pedal" CTA on the home/landing state of the app
   - "Help me choose" link in catalog view headers
   - "Find a replacement" option in workbench detail panel (pre-fills answers from board context — see Option C)

5. **"Why this result" callout**
   - For each result card, a small "Why:" label listing the matched criteria
   - e.g., "Matches: Reverb · Stereo · MIDI · Under $300"
   - Derived automatically from the filter answers — no editorial copy needed

**Data requirements:** No schema changes. Requires good data coverage on `effect_type`, `msrp_cents`, `mono_stereo`, `midi_capable` for pedals. Current pedal data is sufficient.

---

### Phase 4 — Option C: Workbench-Integrated Slot Finder

**Goal:** The marquee feature. When a user has a placeholder slot on their board, the app uses live board context — physical space, remaining power budget, signal chain mode — to surface a ranked list of fitting products with side-by-side comparison and buy links. No other tool can do this.

**Steps:**

1. **Prerequisite: placeholder slot UX**
   - Placeholders already exist in the workbench. Confirm or add: a placeholder can have a specified product type and act as a "reserved slot" with configurable dimensions.
   - Placeholder cards show a "Find a pedal" / "Find a product" CTA button

2. **Compute live board constraints from workbench state**
   - **Physical space:** Placeholder dimensions define the max footprint (width × depth in mm). If no dimensions set, use "no constraint."
   - **Power budget:** Query the power view's remaining-budget data for available mA at common voltages (9V, 12V, 18V). Already computed in `powerUtils.ts`.
   - **Signal chain mode:** Determine mono vs. stereo from the audio connections adjacent to the placeholder's position in the chain.
   - **MIDI availability:** Check if a MIDI controller is present and has an unassigned output channel.
   - Bundle these into a `BoardConstraints` object passed to the finder.

3. **Build the Slot Finder panel**
   - Triggered by "Find a pedal for this slot" CTA on a placeholder card or detail panel
   - Opens as a full-screen overlay on mobile, a wide right panel on desktop
   - Top section: displays the computed constraints as a readable summary
     - e.g., "Max 90mm wide · 200mA available at 9V · Stereo signal chain · MIDI available"
   - User can override any constraint (tap to edit)
   - Results list below: ranked products matching all constraints
   - Each result shows: key specs, fit indicators (green check / amber warning per constraint), MSRP, buy links
   - "Compare" pins items to the comparison bar
   - "Add to board" replaces the placeholder with the selected product

4. **Fit indicator logic**
   - Per constraint, compute: pass (green) / marginal (amber, within 10%) / fail (red, excluded by default)
   - "Exclude fails" toggle — off by default so users can see what almost fits
   - Amber marginal items shown with a note ("12mm too wide — check fit")

5. **Pre-fill the Guided Finder from board context**
   - "More options" link from the slot finder opens the Guided Finder (Option B) with answers pre-filled from board constraints
   - Connects the two flows without duplicating logic

6. **Entry points**
   - Placeholder card CTA ("Find a pedal")
   - Workbench detail panel for any existing product: "Find a replacement that fits this slot"
   - Workbench "Add product" menu: "Find by board constraints" option

**Data requirements:**
- Good coverage of `width_mm`, `depth_mm`, `height_mm` for meaningful physical filtering
- Good coverage of power input jack `current_ma` for power budget filtering
- Good coverage of `mono_stereo` and `midi_capable` for signal/MIDI filtering
- The slot finder degrades gracefully if data is sparse: constraints with no matching data are simply skipped rather than returning zero results

---

## Combined Flow Diagram

```
Catalog View
  ├─ Compare toggle → Comparison Bar → /compare (Option A)
  │                                      └─ Buy links
  └─ Expanded row → "You might also consider" (Option D)
                  └─ Buy links per suggestion

Nav → /find (Option B)
  └─ Results → Comparison Bar → /compare
             └─ Buy links

Workbench
  ├─ Selected product → Detail panel → "Similar options" (Option D)
  │                                  └─ Swap + buy links
  ├─ Placeholder card → "Find a pedal for this slot" (Option C)
  │   └─ Slot Finder panel
  │       ├─ Results → "Add to board"
  │       ├─ Results → Comparison Bar → /compare
  │       └─ "More options" → /find pre-filled (Option B)
  └─ Any product → "Find a replacement" → Slot Finder (Option C)
```

---

## Open Questions

- **Affiliate program specifics:** Which retailer affiliate programs will be used? Sweetwater, Thomann, and Reverb each have different program structures and link formats. This affects how buy links are constructed and whether prices can be dynamically fetched.
- **Price freshness:** MSRP in the DB is manually maintained. For accurate price comparison in Option A, consider whether a price-fetch integration (via retailer APIs or periodic scraping) is worth building, or whether MSRP as a stable reference price is sufficient.
- **Finder route on mobile:** `/find` needs to work well as both a standalone entry point and as a modal/overlay from within the workbench. Decide whether it's always a full route or can be rendered inline.
- **"Swap" safety:** When Option D's "Swap" replaces a workbench item, connection state may be invalidated. Define the user-facing behavior: auto-reconnect where jacks match, warn for mismatches, or always clear connections on swap.
