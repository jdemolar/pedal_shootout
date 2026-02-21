# Remove Legacy Pages and Update Nav

## Context

The Features Table and Submit Pedal Data pages are remnants of an earlier architecture that used MongoDB Realm for data. The app has since migrated to a Spring Boot API with PostgreSQL, and all data views now use the modern `DataTable` + `useApiData` pattern. These legacy pages are dead code — they reference a Realm connection that no longer exists and serve no purpose in the current app. Removing them simplifies the codebase and eliminates confusion.

The nav bar also needs updating: it currently uses a light gray background (`lightgray`) that clashes with the dark theme (`#111` / `#161616`) used by every other view.

---

## Task 1: Delete legacy component files

Delete the following 14 files (6 component directories):

**FeatureTable system:**
- `apps/web/src/components/FeatureTable/index.tsx`
- `apps/web/src/components/FeatureTable/index.scss`
- `apps/web/src/components/FeatureTableCategoryHeader/index.tsx`
- `apps/web/src/components/FeatureTableCategoryHeader/index.scss`
- `apps/web/src/components/FeatureTableColumnHeader/index.tsx`
- `apps/web/src/components/FeatureTableColumnHeader/index.scss`
- `apps/web/src/components/FeatureRow/index.tsx`
- `apps/web/src/components/FeatureRow/index.scss`
- `apps/web/src/components/DetailsTooltip/index.tsx`
- `apps/web/src/components/DetailsTooltip/index.scss`

**PedalSpecForm:**
- `apps/web/src/components/PedalSpecForm/index.tsx`
- `apps/web/src/components/PedalSpecForm/index.scss`

**FormComponents (unused — not imported anywhere):**
- `apps/web/src/components/FormComponents/index.tsx`
- `apps/web/src/components/FormComponents/index.scss`

## Task 2: Remove `realm-web` dependency

`realm-web` is only imported in `FeatureTable/index.tsx`. Remove it from `apps/web/package.json` and regenerate the lockfile with `npm install`.

## Task 3: Update App routing

**File:** `apps/web/src/components/App/index.tsx`

- Remove imports for `FeatureTable` and `PedalSpecForm`
- Remove their entries from the `navElements` array
- Remove the stale `PedalDatabase` TODO comment (line 7-8) — this migration is no longer relevant
- Update the default redirect: `<Navigate to={navElements[0].link}>` will now correctly point to `manufacturers` (the new first element)

## Task 4: Restyle the nav to match the dark theme

**Files:** `apps/web/src/components/Nav/index.tsx`, `apps/web/src/components/Nav/index.scss`

The nav currently uses `background-color: lightgray` with dark text — the only light-themed element in the app. Update it to match the dark theme used by all data views and the workbench.

**SCSS changes (`Nav/index.scss`):**
- Background: `lightgray` → `#161616` (matches data view chrome)
- Link color: `#707070` → `#999` with hover to `#f0f0f0`
- Remove the `|` pipe separators (`&::before, &::after` pseudo-elements) — these are a holdover from the original design
- Add a subtle bottom border (`1px solid #2a2a2a`) to separate nav from content
- Font: switch to the monospace stack used everywhere else (`'SF Mono', 'Fira Code', 'Consolas', monospace`)
- Reduce font size from `1.3em` to something that fits the compact dark theme

**TSX changes (`Nav/index.tsx`):**
- Remove the `activePage` state and `navHandler` — these set a class on the nav based on clicks but the mechanism is broken (it sets the element's `className` as the active page string, which doesn't correspond to any CSS)
- Clean up the link rendering to use a simpler structure

## Task 5: Update CLAUDE.md

**File:** `CLAUDE.md`

Remove the references to `FeatureTable`, `FeatureRow`, and `PedalSpecForm` from the "Key Components" section (lines 111-113). These no longer exist.

## Task 6: Verify

- Run `npm run web:build` to confirm clean compilation
- Run `npm run web:test` to confirm no test regressions (no dedicated tests exist for the removed components, but the general app test should still pass)

---

## Files Summary

**Delete (14 files):**
- `apps/web/src/components/FeatureTable/` (2 files)
- `apps/web/src/components/FeatureTableCategoryHeader/` (2 files)
- `apps/web/src/components/FeatureTableColumnHeader/` (2 files)
- `apps/web/src/components/FeatureRow/` (2 files)
- `apps/web/src/components/DetailsTooltip/` (2 files)
- `apps/web/src/components/PedalSpecForm/` (2 files)
- `apps/web/src/components/FormComponents/` (2 files)

**Modify (4 files):**
- `apps/web/src/components/App/index.tsx` — remove imports, routes, and stale comment
- `apps/web/src/components/Nav/index.tsx` — remove broken active state, simplify
- `apps/web/src/components/Nav/index.scss` — dark theme restyle
- `CLAUDE.md` — remove legacy component references

**Dependency:**
- `apps/web/package.json` — remove `realm-web`
