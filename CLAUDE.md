# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Pedal Shootout is a React/TypeScript web application for comparing specs and features of effects pedals. It uses MongoDB Realm for data persistence with anonymous authentication.

## Commands

```bash
# Development server (hot reload at localhost:8080)
npm start

# Production build (outputs to /build)
npm run build

# Run tests
npm test

# Tests in watch mode
npm run test:watch

# Tests with coverage report
npm run test:coverage
```

## Tech Stack

- React 18 with TypeScript 4.7 (strict mode enabled)
- Webpack 5 for bundling
- SASS/SCSS for styling
- Jest + React Testing Library for tests
- MongoDB Realm Web for backend data

## Architecture

**Component Organization:** Each component lives in its own folder under `src/components/` with an `index.tsx` file.

**Key Components:**
- `App` - Main router (React Router DOM)
- `FeatureTable` - Primary comparison view, fetches data from Realm on mount
- `FeatureRow` - Renders pedal specs with complex data handling (tooltips, lists)
- `PedalSpecForm` - Form for submitting new pedal specifications using react-jsonschema-form

**Data Flow:** App routes between FeatureTable and PedalSpecForm. FeatureTable fetches from Realm using `useEffect`, then passes data down via props.

## Testing

- Tests go in `src/__tests__/` with `.test.tsx` or `.test.ts` extension
- Snapshots stored in `src/__tests__/__snapshots__/`
- 100% coverage threshold is configured (branches, functions, lines, statements)
- Uses jsdom test environment with @testing-library/jest-dom matchers

## Environment

The `.env` file contains `REACT_APP_REALM_APP_ID` for MongoDB Realm connection.

---

# Pedal Database (Separate Project)

The `raw_data/` directory contains a standalone data collection project, separate from the main pedal_shootout React app. The goal is to build a robust data model and populate it with accurate pedal specifications. Once the model and data are finalized, the pedal_shootout app will be updated to use this as its data source.

**Files:**
- **`pedals.db`** — SQLite database (primary data store)
- **`pedal_database_view.jsx`** — Standalone React component for viewing/filtering pedal data
- **`*.xlsx`** — Excel exports for reference

---

## Database Architecture

The pedal catalog is stored in `raw_data/pedals.db`, a SQLite relational database with two core tables:

- **`manufacturers`** — the source of truth for all manufacturer values. No pedal can reference a manufacturer that does not exist in this table.
  - Columns: `id`, `name` (unique), `country`, `founded`, `status` (Active/Defunct/Discontinued/Unknown), `specialty`, `website`, `notes`

- **`pedals`** — references `manufacturers` via a `manufacturer_id` foreign key. Also enforces a unique constraint on `manufacturer_id` + `model`, preventing duplicate pedal entries.
  - Columns: `id`, `manufacturer_id`, `model`, `color_options`, `effect_type`, `in_production` (0/1), `inputs`, `outputs`, `power_plug_size`, `power_polarity`, `power_voltage`, `power_current_ma`, `dimensions`, `data_reliability`, `msrp_cents`, `product_page`, `instruction_manual`
  - `effect_type` must be one of: Gain, Fuzz, Compression, Modulation, Delay, Reverb, Multi Effects, Utility, Preamp, Amp/Cab Sim, Other

### Foreign Key Enforcement

SQLite does not enforce foreign keys by default. Any connection to this database **must** run the following as its first statement:

```sql
PRAGMA foreign_keys = ON;
```

Without this, invalid `manufacturer_id` values will be silently accepted. Every Node.js (or other) database driver should be configured to execute this pragma on connection open.

### Adding a Pedal with an Unrecognized Manufacturer

If a pedal is being added and its manufacturer does not exist in the `manufacturers` table, do **not** reject the pedal outright. Instead, follow this workflow:

1. Flag that the manufacturer is not currently in the `manufacturers` table.
2. Ask the user whether they would like to add the manufacturer to the `manufacturers` table first.
3. If yes, collect the relevant manufacturer details (country, founded, status, specialty, website, notes) and insert the new manufacturer before proceeding with the pedal insert.
4. If no, hold the pedal entry until the manufacturer is resolved.

This keeps the `manufacturers` table as a living source of truth while avoiding unnecessary friction when cataloging pedals from new or lesser-known brands.

### MSRP (`msrp_cents`)

MSRP is stored as an **INTEGER in cents** — so `$99.00` is stored as `9900`. This avoids floating-point rounding errors that arise when currency is stored as REAL/FLOAT. To display as dollars, divide by 100.

The column is **nullable**. `NULL` means no reliable MSRP is known — this is expected for older discontinued or limited-run pedals where no public pricing was ever recorded. Do not store `0`; use `NULL` instead.

Always store the **standard retail MSRP**, not sale or clearance prices. If a retailer lists both a regular price and a sale price, use the regular price. This keeps the column stable and comparable across pedals regardless of when it was last updated.

When backfilling or updating prices:
- Active pedals: use the current price from the manufacturer's website.
- Discontinued pedals still listed with a price: use that listed price.
- Discontinued pedals showing `$0.00` on the manufacturer site: use the last known price from a major retailer (Sweetwater, Guitar Center, etc.) if available. If no reliable last-known price can be found, leave as `NULL`.

### Product Page (`product_page`)

Stores the URL of the manufacturer's product page for the pedal. The column is **nullable**. `NULL` is the correct value whenever no verified product page exists — this includes pedals from manufacturers with no online presence, vintage reproductions sold under another brand, or collaboration pedals whose page lives on a partner's site rather than the primary manufacturer's.

Do not fabricate or guess URLs. Only populate this field from a verified, live page.

### Instruction Manual (`instruction_manual`)

Stores the URL of the pedal's instruction manual (typically a PDF). Populate this field whenever a manual is consulted during data entry — the URL used to access that manual is what goes here. This creates a traceable link back to the source document used to verify specs.

`NULL` means no manual URL has been found or referenced for this pedal. Preferred sources in order: manufacturer-hosted PDFs first, then third-party manual archives. Do not fabricate URLs.

---

## Data Collection Guidelines

### Variant Combination Rules
- Variants should only be combined if **all other columns** (except Model and Color Options) are identical
- If any column has different values between variants:
  1. Point out the differences to the user
  2. Ask for confirmation before combining them
- Only combine variants if all variants are currently available
- Example: Color variants with identical specs can be combined into a "Color Options" column

### Data Sources (in order of reliability)

#### High Reliability Sources
1. **Manufacturer's official website** (product pages)
2. **Manufacturer's official PDF manuals/documentation**
3. **Manufacturer's official forum posts** (clearly identified official representatives)
4. **Manufacturer's official social media** (verified accounts with technical specs)

#### Medium Reliability Sources
1. **Major music retailers** (Sweetwater, Thomann, Guitar Center, Andertons, etc.)
   - These typically quote manufacturer specs directly
   - Track record of accuracy
2. **Established gear review sites** (Premier Guitar, Reverb, etc.)
3. **Professional demo videos** with on-screen specifications
4. **pedalplayground.com** — particularly useful for **dimensions**
   - Open-source, community-contributed pedal database (hosted on GitHub)
   - Each pedal entry requires dimensions in inches, including jacks and protrusions
   - Contributors submit measured dimensions alongside top-down pedal images; the project maintainers review and merge via pull requests
   - Dimensions are the primary value here — the site is a pedalboard layout planner, not a general spec database, so it does not cover I/O, power, or pricing
   - Many manufacturers (including JHS) do not publish dimensions on their own product pages, making pedalplayground.com one of the few reliable sources for this data

#### Low Reliability Sources
1. **User forums** (unless official manufacturer representative)
2. **User reviews** on retail sites
3. **Personal blogs/websites**
4. **Social media posts** from non-official accounts

### Source Documentation Requirements
When data is not immediately available on the manufacturer's website:
- Document the source used
- Note: "Data from [Source Name] - [URL if applicable]"
- If multiple sources confirm the same data, note: "Verified across multiple sources"

### Current Known Reliable Sources for Guitar Pedals:
- **Sweetwater** - Consistently accurate, quotes manufacturer specs
- **Thomann** - European retailer, reliable specifications
- **Reverb.com** - Good for discontinued pedals
- **Premier Guitar** - Professional reviews often include detailed specs
- **JHS Pedals official PDF manuals** - Highly detailed and accurate
- **pedalplayground.com** - Best available source for pedal dimensions; community-measured and version-controlled on GitHub

*This list will be updated as more reliable sources are discovered*

## Data Reliability Column

Each row should have a "Data Reliability" rating:

### High
- Data verified from multiple sources, OR
- Data directly from manufacturer (website, manuals, official forums), OR
- All specifications confirmed through official channels

### Medium
- Data from a known reliable source (major retailers, established review sites)
- Not yet validated by additional sources
- Source has proven track record of accuracy

### Low
- Data from unvalidated source
- Source is not yet known/trusted
- Single source with no corroboration
- User-submitted data not yet verified

### Setting Reliability Ratings
- Start all manufacturer-sourced data as "High"
- Data from Sweetwater, Thomann, or other major retailers starts as "Medium"
- Data from unknown sources starts as "Low"
- Upgrade ratings when additional sources confirm the data
- Document reasoning for reliability rating if ambiguous

## Database Maintenance Notes
- Regularly verify and update reliability ratings as new sources emerge
- When crowd-sourcing begins, all user-submitted data starts as "Low" until verified
- Cross-reference specifications across multiple sources when possible
- Flag conflicts between sources for manual review

## Working with the Database

Use sqlite3 CLI to query and modify data:

```bash
# Open the database
sqlite3 raw_data/pedals.db

# IMPORTANT: Always enable foreign keys first
PRAGMA foreign_keys = ON;

# View all manufacturers
SELECT * FROM manufacturers;

# View pedals with manufacturer names
SELECT p.*, m.name as manufacturer
FROM pedals p
JOIN manufacturers m ON p.manufacturer_id = m.id;

# Insert a new manufacturer
INSERT INTO manufacturers (name, country, status, website)
VALUES ('Example Co', 'USA', 'Active', 'https://example.com');

# Insert a new pedal (get manufacturer_id first)
INSERT INTO pedals (manufacturer_id, model, effect_type, in_production, inputs, outputs,
  power_plug_size, power_polarity, power_voltage, data_reliability)
VALUES (1, 'Model Name', 'Gain', 1, 'Mono (1/4" TS)', 'Mono (1/4" TS)',
  '2.1mm', 'Center Negative', '9V DC', 'High');
```

When populating data from web research:
1. Check if the manufacturer exists: `SELECT id FROM manufacturers WHERE name = 'Brand Name';`
2. If not, add the manufacturer first with available details
3. Insert the pedal with the correct `manufacturer_id`
4. Set `data_reliability` based on source quality (see Data Sources section)
