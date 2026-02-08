# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Pedal Shootout is a guitar gear database and comparison tool. It consists of:
- A React/TypeScript web application for comparing pedal specs
- A SQLite database for storing comprehensive gear data (pedals, power supplies, pedalboards, MIDI controllers, utilities)

## Project Structure

```
pedal_shootout/
├── apps/
│   └── web/                    # React frontend
│       ├── src/                # Source code
│       ├── package.json        # Web app dependencies
│       └── webpack.*.js        # Build configuration
│
├── data/
│   ├── schema/                 # SQL schema definitions (source of truth)
│   │   └── gear.sql            # Full database schema
│   ├── migrations/             # Versioned migration scripts
│   ├── seeds/                  # Reference/sample data
│   └── local/                  # Local dev database (gitignored)
│       └── gear.db
│
├── docs/
│   └── plans/                  # Design documents and plans
│       └── data_design.md      # Database schema design rationale
│
├── infrastructure/             # Future AWS CDK/Terraform
│
├── raw_data/                   # Legacy data files (to be migrated)
│
└── package.json                # Root workspace config
```

## Commands

```bash
# From project root (uses npm workspaces)
npm run web              # Start dev server (localhost:8080)
npm run web:build        # Production build
npm run web:test         # Run tests

# Or from apps/web/ directory
cd apps/web
npm start                # Dev server
npm run build            # Production build
npm test                 # Run tests
npm run test:watch       # Tests in watch mode
npm run test:coverage    # Tests with coverage report
```

## Tech Stack

**Web App:**
- React 18 with TypeScript 4.7 (strict mode enabled)
- Webpack 5 for bundling
- SASS/SCSS for styling
- Jest + React Testing Library for tests
- MongoDB Realm Web for backend data (current, will migrate to SQLite API)

**Database:**
- SQLite with Class Table Inheritance pattern
- Schema defined in `data/schema/gear.sql`

## Web App Architecture

**Component Organization:** Each component lives in its own folder under `apps/web/src/components/` with an `index.tsx` file.

**Key Components:**
- `App` - Main router (React Router DOM)
- `FeatureTable` - Primary comparison view, fetches data from Realm on mount
- `FeatureRow` - Renders pedal specs with complex data handling (tooltips, lists)
- `PedalSpecForm` - Form for submitting new pedal specifications

**Testing:**
- Tests in `apps/web/src/__tests__/` with `.test.tsx` or `.test.ts` extension
- 100% coverage threshold configured
- Uses jsdom test environment with @testing-library/jest-dom matchers

**Environment:**
The `apps/web/.env` file contains `REACT_APP_REALM_APP_ID` for MongoDB Realm connection.

---

# Database

## Schema Overview

The gear database uses **Class Table Inheritance**: a shared `products` table contains common attributes, with type-specific detail tables extending it.

**Core Tables:**
- `manufacturers` — Source of truth for all brands
- `product_types` — Enum: pedal, power_supply, pedalboard, midi_controller, utility, plug
- `products` — Base table with shared attributes (dimensions, MSRP, etc.)
- `jacks` — Unified connectors table for all product types

**Detail Tables (1:1 with products):**
- `pedal_details` — Effect type, bypass, MIDI, presets, etc.
- `power_supply_details` — Topology, outputs, voltages, mounting
- `pedalboard_details` — Usable dimensions, surface type, clearance
- `midi_controller_details` — Footswitches, banks, displays, loops
- `utility_details` — DI boxes, tuners, volume pedals, etc.
- `plug_details` — Connector dimensions for layout planning

**Full schema:** See `data/schema/gear.sql`
**Design rationale:** See `docs/plans/data_design.md`

## Foreign Key Enforcement

SQLite does not enforce foreign keys by default. **Always run this first:**

```sql
PRAGMA foreign_keys = ON;
```

Without this, invalid foreign key values will be silently accepted.

## Working with the Database

```bash
# Open the database
sqlite3 data/local/gear.db

# IMPORTANT: Always enable foreign keys first
PRAGMA foreign_keys = ON;

# View all manufacturers
SELECT * FROM manufacturers;

# View products with type and manufacturer
SELECT p.model, m.name AS manufacturer, pt.type_name
FROM products p
JOIN manufacturers m ON p.manufacturer_id = m.id
JOIN product_types pt ON p.product_type_id = pt.id;

# Find all delay pedals
SELECT p.model, m.name AS manufacturer
FROM products p
JOIN manufacturers m ON p.manufacturer_id = m.id
JOIN pedal_details pd ON p.id = pd.product_id
WHERE pd.effect_type = 'Delay';
```

## Creating the Database from Schema

```bash
# Create a fresh database from schema
sqlite3 data/local/gear.db < data/schema/gear.sql
```

### Adding a Product with an Unrecognized Manufacturer

If a product is being added and its manufacturer does not exist in the `manufacturers` table, do **not** reject the product outright. Instead, follow this workflow:

1. Flag that the manufacturer is not currently in the `manufacturers` table.
2. Ask the user whether they would like to add the manufacturer to the `manufacturers` table first.
3. If yes, collect the relevant manufacturer details (country, founded, status, specialty, website, notes) and insert the new manufacturer before proceeding with the product insert.
4. If no, hold the product entry until the manufacturer is resolved.

This keeps the `manufacturers` table as a living source of truth while avoiding unnecessary friction when cataloging products from new or lesser-known brands.

### MSRP (`msrp_cents`)

MSRP is stored as an **INTEGER in cents** — so `$99.00` is stored as `9900`. This avoids floating-point rounding errors that arise when currency is stored as REAL/FLOAT. To display as dollars, divide by 100.

The column is **nullable**. `NULL` means no reliable MSRP is known — this is expected for older discontinued or limited-run products where no public pricing was ever recorded. Do not store `0`; use `NULL` instead.

Always store the **standard retail MSRP**, not sale or clearance prices. If a retailer lists both a regular price and a sale price, use the regular price. This keeps the column stable and comparable across products regardless of when it was last updated.

When backfilling or updating prices:
- Active products: use the current price from the manufacturer's website.
- Discontinued products still listed with a price: use that listed price.
- Discontinued products showing `$0.00` on the manufacturer site: use the last known price from a major retailer (Sweetwater, Guitar Center, etc.) if available. If no reliable last-known price can be found, leave as `NULL`.

### Product Page (`product_page`)

Stores the URL of the manufacturer's product page. The column is **nullable**. `NULL` is the correct value whenever no verified product page exists — this includes products from manufacturers with no online presence, vintage reproductions sold under another brand, or collaboration products whose page lives on a partner's site rather than the primary manufacturer's.

Do not fabricate or guess URLs. Only populate this field from a verified, live page.

### Instruction Manual (`instruction_manual`)

Stores the URL of the product's instruction manual (typically a PDF). Populate this field whenever a manual is consulted during data entry — the URL used to access that manual is what goes here. This creates a traceable link back to the source document used to verify specs.

`NULL` means no manual URL has been found or referenced for this product. Preferred sources in order: manufacturer-hosted PDFs first, then third-party manual archives. Do not fabricate URLs.

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
