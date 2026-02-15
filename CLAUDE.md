# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Pedal Shootout is a guitar gear database and comparison tool. It consists of:
- A React/TypeScript web application for comparing pedal specs
- A PostgreSQL database for storing comprehensive gear data (pedals, power supplies, pedalboards, MIDI controllers, utilities)

## Project Structure

```
pedal_shootout/
├── apps/
│   ├── api/                    # Spring Boot API (Java 17)
│   │   ├── src/main/java/com/pedalshootout/api/
│   │   │   ├── controller/     # REST controllers
│   │   │   ├── dto/            # Data Transfer Objects
│   │   │   ├── entity/         # JPA entities
│   │   │   ├── repository/     # Spring Data JPA repositories
│   │   │   └── service/        # Business logic
│   │   └── pom.xml             # Maven build config
│   └── web/                    # React frontend
│       ├── src/                # Source code
│       ├── package.json        # Web app dependencies
│       └── webpack.*.js        # Build configuration
│
├── data/
│   ├── schema/                 # SQL schema definitions (source of truth)
│   │   └── gear_postgres.sql   # PostgreSQL database schema
│   ├── migrations/             # Versioned migration scripts
│   ├── seeds/                  # Reference/sample data
│   └── local/                  # Local dev artifacts (gitignored)
│       └── gear.db             # Legacy SQLite database (archived)
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

# Spring Boot API (from apps/api/ directory)
cd apps/api
./mvnw spring-boot:run   # Start API server (localhost:8081)
./mvnw compile -q        # Compile check (no tests)
./mvnw test              # Run tests
```

## Tech Stack

**Web App:**
- React 18 with TypeScript 4.7 (strict mode enabled)
- Webpack 5 for bundling
- SASS/SCSS for styling
- Jest + React Testing Library for tests

**API:**
- Spring Boot 3.4.3 with Java 17
- Spring Data JPA + PostgreSQL
- Runs on port 8081; frontend dev server on port 8080
- CORS configured for `localhost:8080`, GET-only
- All endpoints are read-only (GET)
- OpenAPI spec at `docs/openapi.yaml`

**Database:**
- PostgreSQL 17 with Class Table Inheritance pattern
- Schema defined in `data/schema/gear_postgres.sql`
- Local connection: `postgresql://pedal_shootout_app:localdev@localhost:5432/pedal_shootout`

## Local Environment

**Operating System**
- macOS 13.7.8
- Only install versions of node and other tools compatible with macOS 13.7.8
- Do NOT run `brew upgrade node` or install Node via Homebrew — Homebrew's current Node requires XCode CLI Tools newer than what macOS 13 supports

**Node / npm**
- Managed via nvm (installed at `~/.nvm`); project is pinned to Node 20 via `.nvmrc`
- nvm is NOT auto-loaded in non-interactive shells (such as the shell Claude Code uses)
- All `node`/`npm` commands must be prefixed with: `export NVM_DIR="$HOME/.nvm" && . "$NVM_DIR/nvm.sh" &&`
- Example: `export NVM_DIR="$HOME/.nvm" && . "$NVM_DIR/nvm.sh" && npm run web --prefix /path/to/project`

## Web App Architecture

**Component Organization:** Each component lives in its own folder under `apps/web/src/components/` with an `index.tsx` file.

**Key Components:**
- `App` - Main router (React Router DOM)
- `FeatureTable` - Primary comparison view, fetches data from Realm on mount
- `FeatureRow` - Renders pedal specs with complex data handling (tooltips, lists)
- `PedalSpecForm` - Form for submitting new pedal specifications

**Shared Components and Utilities:**
- `DataTable<T>` (`components/DataTable/index.tsx`) — Generic table with sorting, filtering, search, and expandable rows. All data views use this.
- `useApiData<TRaw, TDisplay>` (`hooks/useApiData.ts`) — Hook that fetches from the API, transforms data, and manages loading/error states.
- `api` object (`services/api.ts`) — Centralized API client with typed methods (`api.getPedals()`, `api.getManufacturers()`, etc.).
- Transformer functions (`utils/transformers.ts`) — One per entity type (e.g., `transformPedal`, `transformPowerSupply`). Maps API camelCase to component snake_case.
- `formatMsrp`, `formatDimensions`, `formatPower` (`utils/formatters.ts`) — Shared display formatters.
- `ColumnDef<T>` and `FilterConfig<T>` (`DataTable/index.tsx`) — Exported interfaces used by every data view to define columns and filters.

**Adding a New Data View (checklist):**
1. Add `XxxApiResponse` interface to `types/api.ts` (matches DTO JSON shape)
2. Add `getXxx` method to `services/api.ts`
3. Add `transformXxx` function to `utils/transformers.ts`
4. Create `components/Xxx/index.tsx` with interface, columns, filters, expanded row, stats
5. Add import and nav entry to `components/App/index.tsx`
6. Verify: `./mvnw compile -q` (API) and `npm run web:build` (frontend)

**API ↔ Frontend Field Naming:**
The API returns camelCase (Java convention). Frontend components use snake_case. The transformer function in `utils/transformers.ts` is the single place where this mapping happens. Do not convert field names anywhere else.

**Testing:**
- Tests in `apps/web/src/__tests__/` with `.test.tsx` or `.test.ts` extension
- 100% coverage threshold configured
- Uses jsdom test environment with @testing-library/jest-dom matchers

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

**Full schema:** See `data/schema/gear_postgres.sql`
**Design rationale:** See `docs/plans/data_design.md`

## Working with the Database

PostgreSQL enforces foreign keys by default — no PRAGMA needed.

```bash
# Connect to the database
psql -U pedal_shootout_app -d pedal_shootout
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
   - Open-source, community-contributed pedal database

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

### Web Fetching Notes (for automated research)
- **Manufacturer websites** are often JavaScript-rendered SPAs. Fetching their product pages via HTTP typically returns only `<script>` tags with no usable specs. Do not rely on direct web fetches to manufacturer sites for spec data.
- **Sweetwater** product pages consistently return full HTML with specs and are the most reliable source for automated fetching.
- **Thomann** product pages are also reliably fetchable.
- **Perfect Circuit** and **zZounds** often return 403 errors or block automated requests.
- **Reverb.com** listing pages are fetchable but specs may be incomplete.
- When a manufacturer site doesn't yield specs, search for the product on Sweetwater or Thomann first, then fall back to other retailers or review sites.

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

## CHECK Constraints Quick Reference

The schema enforces allowed values via CHECK constraints. Inserts will fail if a value doesn't match.

**`products`**
- `data_reliability`: `'High'`, `'Medium'`, `'Low'`

**`manufacturers`**
- `status`: `'Active'`, `'Defunct'`, `'Discontinued'`, `'Unknown'`

**`pedal_details`**
- `effect_type`: `'Gain'`, `'Fuzz'`, `'Compression'`, `'Delay'`, `'Reverb'`, `'Chorus'`, `'Flanger'`, `'Phaser'`, `'Tremolo'`, `'Vibrato'`, `'Rotary'`, `'Univibe'`, `'Ring Modulator'`, `'Pitch Shifter'`, `'Wah'`, `'Filter'`, `'Multi Effects'`, `'Utility'`, `'Preamp'`, `'Amp/Cab Sim'`, `'Other'`
- `signal_type`: `'Analog'`, `'Digital'`, `'Hybrid'`
- `bypass_type`: `'True Bypass'`, `'Buffered Bypass'`, `'Relay Bypass'`, `'DSP Bypass'`, `'Both'`
- `mono_stereo`: `'Mono'`, `'Stereo In/Out'`, `'Mono In/Stereo Out'`

**`power_supply_details`**
- `supply_type`: `'Isolated'`, `'Non-Isolated'`, `'Hybrid'`
- `topology`: `'Switch Mode'`, `'Toroidal'`, `'Linear'`, `'Unknown'`
- `mounting_type`: `'Under Board'`, `'On Board'`, `'External'`, `'Rack'`

**`pedalboard_details`**
- `surface_type`: `'Loop Velcro'`, `'Hook Velcro'`, `'Bare Rails'`, `'Perforated'`, `'Solid Flat'`, `'Other'`
- `case_type`: `'Soft Case'`, `'Hard Case'`, `'Flight Case'`, `'Gig Bag'`, `'None'`

**`midi_controller_details`**
- `footswitch_type`: `'Momentary'`, `'Latching'`, `'Dual-Action'`, `'Mixed'`

**`utility_details`**
- `utility_type` (22 values): `'DI Box'`, `'Reamp Box'`, `'Buffer'`, `'Splitter'`, `'A/B Box'`, `'A/B/Y Box'`, `'Tuner'`, `'Volume Pedal'`, `'Expression Pedal'`, `'Noise Gate'`, `'Power Conditioner'`, `'Signal Router'`, `'Impedance Matcher'`, `'Headphone Amp'`, `'Mixer'`, `'Junction Box'`, `'Patch Bay'`, `'Mute Switch'`, `'Amp Switcher'`, `'Load Box'`, `'Line Level Converter'`, `'Other'`
- `signal_type`: `'Analog'`, `'Digital'`, `'Both'`

**`product_compatibility`**
- `compatibility_type`: `'Mounting'`, `'Power'`, `'MIDI'`, `'Accessory'`, `'Replacement'`

## Required Fields Per Detail Table

Each detail table has a `product_id` PK (always required). Below are the additional NOT NULL fields — everything else is nullable or has a DEFAULT.

| Table | Required Fields (NOT NULL) |
|---|---|
| `products` | `manufacturer_id`, `product_type_id`, `model` |
| `pedal_details` | *(none beyond product_id — all fields nullable or have defaults)* |
| `power_supply_details` | `total_output_count` |
| `pedalboard_details` | *(none beyond product_id)* |
| `midi_controller_details` | `footswitch_count` |
| `utility_details` | `utility_type` |
| `plug_details` | `plug_type`, `connector_type` |
| `jacks` | `product_id`, `category`, `direction`, `connector_type` |

## Standard Field Value Conventions

- **Dimensions**: Stored as `DOUBLE PRECISION` in millimeters (`width_mm`, `depth_mm`, `height_mm`)
- **Weight**: Stored as `INTEGER` in grams (`weight_grams`)
- **MSRP**: Stored as `INTEGER` in cents (`msrp_cents`). `$99.00` = `9900`. Use `NULL` for unknown, never `0`.
- **Booleans**: Use `TRUE`/`FALSE`. Most default to `FALSE`.
- **`in_production`**: `TRUE` = currently available, `FALSE` = discontinued. Defaults to `TRUE`.
- **`notes`**: Internal-only field on `products` table. Not exposed via the API. Use for data curation notes (e.g., "jacks are user-configurable — see manual").

## Jack Insertion Patterns

Jacks represent physical connectors. Only insert jacks for ports that exist on the product.

**Power input jack (most common — needed for any active device):**
```sql
INSERT INTO jacks (product_id, category, direction, connector_type, voltage, current_ma, polarity)
VALUES (<id>, 'power', 'input', '2.1mm barrel', '9V', <current_ma>, 'center-negative');
```

**Passive devices** (passive DI boxes, passive reamp boxes, etc.) do not need power jacks.

**Required fields for every jack:** `product_id`, `category`, `direction`, `connector_type`. Everything else is optional.

**Common category values:** `'audio'`, `'power'`, `'midi'`, `'expression'`, `'usb'`, `'aux'`
**Common direction values:** `'input'`, `'output'`, `'bidirectional'`
