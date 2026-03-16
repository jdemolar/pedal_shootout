# Design System Redesign

**Status:** Design
**Created:** 2026-03-15

## Context

The current design is functional but generic — a neutral dark-mode app with system fonts and no strong visual identity. The goal of this redesign is to give Pedal Shootout a distinctive aesthetic that:

- Immediately reads as *guitar electronics* without being clichéd
- Scales gracefully from desktop to mobile (the app must work on any device)
- Handles high information density without feeling overwhelming
- Differentiates clearly from existing tools (pedalboardplanner.com, pedalplayground.com)
- Aligns with the target audience's visual world: vintage gear, technical precision, analog warmth

The design direction is **Vintage PCB** — inspired by the aesthetics of 1970s–80s electronics: dark olive-green substrate, copper trace accents, cream silkscreen labels, blueprint-style annotation lines, and the warmth of analog gear rather than the sterility of modern "dark mode" apps.

### Reference Points

- **Eventide H9 Control** (mobile) — focused single-view layout, hardware-mirroring UI, clean mode switching
- **Morningstar Editor** (mobile + desktop) — functional hierarchy, works across both
- **KiCad / Eagle PCB layout software** — dot grid canvas, component chip aesthetics, copper trace visual language
- **Vintage gear silkscreen typography** — upper-case monospace labels, technical annotation style

---

## Design Decisions

| Decision | Choice | Rationale |
|---|---|---|
| Theme | Dark mode (retained) | Reduces eye fatigue for extended planning sessions; consistent with guitar gear software conventions |
| Color base | Dark olive-green (`#111a0d`) | Immediately evokes PCB substrate; more specific than neutral black; differentiates from existing tools |
| Primary accent | Copper (`#c87c3a`) | Copper traces are the defining visual element of PCBs; replaces current blue links and amber highlights with a single unified accent |
| Primary text | Warm cream (`#e4d9b8`) | Off-white against dark green reads as aged silkscreen labeling; less harsh than pure white |
| Heading font | Barlow Condensed (Google Fonts) | Condensed industrial sans — technical, slightly vintage without being kitsch; uppercase at nav scale reads as PCB silkscreen |
| Data font | JetBrains Mono (Google Fonts) | Designed for dense technical display; better than system monospace at 11–12px; humanist qualities aid readability |
| Body font | Barlow (regular weight) | Companion to Barlow Condensed for longer text blocks |
| Web font delivery | Google Fonts CDN with `font-display: swap` + self-hosted fallback option | App requires internet connection; FOUT mitigated by swap + matched fallback stack; self-host for GDPR compliance if needed |
| Canvas grid | Subtle dot grid, `rgba(#3a5428, 0.4)`, 18px spacing | Matches PCB layout software (KiCad/Eagle); texture at current zoom, visible grid when zoomed in |
| Card style | 2px border-radius, left-edge type bar, copper border on selection | Near-rectangular like circuit components; type color encoded in edge stripe rather than fill |
| Product type color system | Retained, shifted warmer | Current system (green=pedal, amber=power supply, etc.) is correct; hues adjusted to harmonize with copper accent and olive base |
| Semantic colors | Retained (green=success, red=error, amber=warning) | Existing mapping is sensible; shift slightly warmer to match palette |

---

## 1. Color System

### Base palette

| Token | Hex | Usage |
|---|---|---|
| `bg-canvas` | `#0b1208` | Workbench canvas, deepest background |
| `bg-app` | `#111a0d` | App background |
| `bg-surface` | `#172012` | Nav, panels, sidebars |
| `bg-card` | `#1c2916` | Table rows, product cards |
| `bg-card-hover` | `#222f1b` | Hover / selected state |
| `border-subtle` | `#2a3f20` | Default borders, dividers |
| `border-strong` | `#3a5428` | Active borders, section dividers |

### Accent

| Token | Hex | Usage |
|---|---|---|
| `accent-copper` | `#c87c3a` | Links, active states, highlights, selected card border |
| `accent-copper-bright` | `#e09048` | Hover/focus states on interactive elements |

### Text

| Token | Hex | Usage |
|---|---|---|
| `text-primary` | `#e4d9b8` | Primary text (cream, warm off-white) |
| `text-secondary` | `#9a8f6e` | Labels, metadata, secondary info |
| `text-ghost` | `#5a5440` | Null values, placeholders, disabled |

### Product type colors (adjusted from current)

| Type | Current text | Revised text | Background |
|---|---|---|---|
| Pedal | `#6aaa6a` | `#7ab86a` | `#182a12` |
| Power Supply | `#aaaa5a` | `#c8a840` | `#282810` |
| Pedalboard | `#6a6aaa` | `#7a7abf` | `#12122a` |
| MIDI Controller | `#aa6aaa` | `#bf7abf` | `#22122a` |
| Utility | `#6aaaaa` | `#6abfbf` | `#122a2a` |

### Semantic colors (adjusted)

| Role | Current | Revised | Notes |
|---|---|---|---|
| Success / active | `#5ccc88` | `#6abf7a` | Warmer green |
| Warning | `#f0a855` | `#c8882a` | Shifts toward copper-adjacent amber |
| Error / discontinued | `#cc6060` | `#c85a3a` | Warmer red |
| Info | `#6a9fcc` | — | Replaced by copper accent; blue used only where truly needed (external links) |

---

## 2. Typography

### Font stack

```css
/* Headings, nav, section titles */
font-family: 'Barlow Condensed', 'Arial Narrow', sans-serif;
font-weight: 600; /* or 700 for strong headings */
text-transform: uppercase;
letter-spacing: 0.05em;

/* Data, tables, code, labels */
font-family: 'JetBrains Mono', 'Fira Code', 'Consolas', monospace;

/* Body copy, descriptions */
font-family: 'Barlow', system-ui, sans-serif;
font-weight: 400;
```

### Loading (Google Fonts)

```html
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Barlow:wght@400;500&family=Barlow+Condensed:wght@500;600;700&family=JetBrains+Mono:wght@400;500&display=swap" rel="stylesheet">
```

### Size scale (unchanged from current — existing sizes are appropriate)

| Context | Size | Font | Weight |
|---|---|---|---|
| View title | `24px` | Barlow Condensed | 700 |
| Nav links | `13px` | Barlow Condensed | 600, uppercase |
| Table manufacturer | `12.5px` | Barlow Condensed | 600 |
| Table model | `11px` | JetBrains Mono | 400 |
| Table data cells | `11px` | JetBrains Mono | 400 |
| Detail labels | `9px` | JetBrains Mono | 500, uppercase |
| Badges | `10px` | JetBrains Mono | 500 |
| Workbench card manufacturer | `10px` | Barlow Condensed | 600, uppercase |
| Workbench card model | `11px` | JetBrains Mono | 400 |

---

## 3. Navigation

### Desktop

- Barlow Condensed, uppercase, `13px`, `letter-spacing: 0.08em`
- Active route: `accent-copper` bottom border `2px` + text shifts to `text-primary`
- Subtle ambient tint: the nav bar bottom border picks up the active section's product type color at low opacity (e.g., on the Pedals route, a faint green tint in the border)
- Workbench button: retains amber badge but badge color shifts to `accent-copper`

### Mobile

- Collapses to a **bottom tab bar** (iOS/Android native pattern — familiar on mobile)
- 5 visible tabs: Workbench (primary), Pedals, Power, [More...], Search
- Overflow routes accessible via "More" sheet
- Tab bar height: `56px` (comfortable touch target)
- Active tab: `accent-copper` icon + label
- The workbench tab is always first/leftmost — it's the primary action surface

---

## 4. DataTable Views

### Density & mobile strategy

The DataTable already handles the right concerns (sortable, filterable, expandable rows). The redesign focuses on visual refinement and responsive behavior.

**Desktop:** Minimal changes to layout. Typography and color token updates carry most of the improvement.

**Mobile — column priority system:**
- Each view defines a `mobilePriority` on each `ColumnDef` (1 = always visible, 2 = visible if space, 3 = hidden by default)
- At narrow viewports, only priority-1 columns render; lower priorities collapse into the expanded row
- Priority 1 columns: Manufacturer + Model (always), plus 1 type-specific key spec (e.g., effect type for pedals, total output count for power supplies)
- The expand toggle is always visible and the expanded view shows everything

**Filter/search bar on mobile:**
- Collapses behind a single filter icon button in the header
- Tapping opens a filter sheet from the bottom (full-width, touch-friendly inputs)
- Active filter count shown as a badge on the icon when filters are applied

### Visual refinements

- Table header: Barlow Condensed, uppercase, `10px`, `letter-spacing: 0.1em`, `text-secondary` color
- Row alternation: keep current approach but shift to `bg-card` / `bg-card-hover` tokens
- `null-value` class: shift from `#3a3a3a` to `border-subtle` (`#2a3f20`) — reads as absent rather than error against the new base
- Links: replace blue (`#5a9bcf`) with `accent-copper`
- Expanded row label: JetBrains Mono, `9px`, uppercase, `text-ghost`
- Expanded row value: JetBrains Mono, `11.5px`, `text-secondary`
- Highlight value (was amber): use `accent-copper`

---

## 5. Workbench

The workbench is the highest-priority surface. Most design effort should land here first.

### Canvas

- Background: `bg-canvas` (`#0b1208`)
- Dot grid overlay: `rgba(#3a5428, 0.4)`, dots at `2px` diameter, `18px` spacing
  - Renders as texture at zoom-out; becomes a visible snap grid at zoom-in
  - Hideable via a toggle (default: visible)
- Zoom controls: retain current position (bottom-left), update to match new color tokens

### Product cards (Konva)

Current cards are too soft. New spec:

- `cornerRadius: 2` (near-square — circuit component aesthetic)
- Fill: `bg-card` (`#1c2916`) for all product types
- Left edge stripe: `3px` wide, product type color — this is the sole type indicator
- Border (unselected): `1px`, `border-subtle` (`#2a3f20`)
- Border (selected): `1.5px`, `accent-copper` (`#c87c3a`) with shadow `rgba(200, 124, 58, 0.3)`
- **Manufacturer** (top): Barlow Condensed, `10px`, `600`, uppercase, `text-primary`, at `y: 8`
- **Model** (middle): JetBrains Mono, `11px`, product type color, at `y: 22`
- **Type label** (bottom): JetBrains Mono, `8px`, `text-ghost`, uppercase (hidden if card height < 55px)

### Panels (detail panel, insights sidebar)

- Background: `bg-surface` (`#172012`)
- Border: `border-subtle` left edge (`1px`)
- Section headers: Barlow Condensed, `11px`, uppercase, `letter-spacing: 0.1em`, `text-ghost`
- Values: JetBrains Mono, `11.5px`, `text-secondary`

### Mobile workbench layout

Full-screen treatment — no sidebars at narrow viewports:

- **View mode tabs** (AudioView, PowerView, MidiView, etc.): scrollable horizontal tab bar at top, `40px` height, Barlow Condensed uppercase
- **Detail panel**: becomes a **bottom sheet** — slides up from the bottom when a card is tapped; closes via swipe down or tap outside
  - Bottom sheet header shows manufacturer + model, type badge, close button
  - Sheet snaps to two heights: summary (~40% screen) and full (~90%)
- **Insights sidebar**: collapses into a floating button (bottom-right), tapping opens a bottom sheet
- **Add product**: floating action button (bottom-right, above insights button); opens a search sheet from bottom
- **Zoom controls**: move to bottom-left, above the canvas edge

### Connection lines

No change to connection logic. Visual updates:

- Line color stays category-coded (audio=green-tinted, power=amber, MIDI=cyan, control=purple)
- Line weight: increase from current to `2px` default, `3px` selected
- Selected line: `accent-copper` glow shadow
- Blueprint annotation style for warning callouts: thin lines with arrowheads, JetBrains Mono label

---

## 6. Badges

### Effect type badges

Keep the current concept (dark tinted bg + type text color). Shift toward the new palette:

- Backgrounds: replace `#2a1a1a`-style near-blacks with tinted versions of `bg-card` (`#1c2916` + hue tint)
- Text colors: warm each slightly (less neon saturation, more aged)
- Font: JetBrains Mono `10px` `500` (replaces current generic sans)
- Border: `1px solid` at 20% opacity of the text color (already done — retain)

### Status badges

- `in-production`: `text-success` on `bg-success-dim`
- `discontinued`: `text-error` on `bg-error-dim`

### Data reliability badges

No change to logic. Update color tokens to match new palette.

### Cable type badges

Blueprint annotation aesthetic — no fill, thin border, JetBrains Mono:

```scss
.cable-badge {
  background: transparent;
  border: 1px solid currentColor;
  font-family: 'JetBrains Mono', monospace;
  font-size: 9px;
  text-transform: uppercase;
  letter-spacing: 0.08em;
  padding: 2px 5px;
  border-radius: 2px;
}
```

---

## 7. Responsive Strategy Summary

| Surface | Desktop | Tablet | Mobile |
|---|---|---|---|
| Nav | Horizontal top bar | Horizontal top bar | Bottom tab bar |
| DataTable | Full columns | Reduced columns | Priority columns only; filter sheet |
| Expanded row | Grid layout | Grid layout | Stacked single-column |
| Workbench canvas | Full with side panels | Full with collapsed panels | Full-screen; panels as bottom sheets |
| View mode tabs | Sidebar or top bar | Top bar | Scrollable horizontal top bar |
| Detail panel | Fixed right sidebar (360px) | Fixed right sidebar (280px) | Bottom sheet |
| Insights | Fixed right (220px) | Floating button | Floating button |
| Comparison bar | Fixed bottom strip | Fixed bottom strip | Compact fixed bottom strip |

---

## 8. Implementation Order

The design tokens and typography can be applied incrementally without requiring architectural changes. Recommended order:

1. **Design tokens first** — add a `_tokens.scss` file with all CSS custom properties (`--bg-canvas`, `--accent-copper`, etc.). Do not refactor all existing SCSS at once; migrate component by component.
2. **Web fonts** — add the Google Fonts `<link>` tags to `index.html` and update the `body` font stack. Immediate visible improvement across all views.
3. **Nav** — small surface area, high visibility. Update colors, typography, mobile bottom bar.
4. **DataTable** — affects all catalog views at once. Update tokens, typography, mobile column priority system.
5. **Workbench cards** — update Konva card rendering in `ProductCard.tsx`. High visual impact on the primary feature.
6. **Workbench panels** — detail panel, insights, bottom sheets for mobile.
7. **Badges** — global, small surface area per badge. Update `badges.scss` last since it's self-contained.
8. **Canvas grid** — add dot grid overlay to workbench canvas.

---

## Open Questions

- **Self-hosting fonts:** If GDPR compliance becomes a concern, fonts should be downloaded and served from `/public/fonts/` instead of Google's CDN. Same files, no behavior change — just a hosting decision.
- **Canvas dot grid performance:** At high zoom levels or with many cards, the dot grid SVG/canvas overlay should be tested for render performance. May need to be drawn as a pattern fill rather than individual dots.
- **Barlow Condensed at very small sizes:** Test at 9–10px (badge/label scale) on low-res screens. If readability suffers, fall back to Barlow (non-condensed) below `11px`.
- **Prototype scope:** Before full implementation, a static prototype of the workbench card and DataTable row in the new palette will confirm the PCB aesthetic reads correctly at screen resolution.
