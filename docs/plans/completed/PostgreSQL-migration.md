# Plan: Migrate SQLite to PostgreSQL

## Context

The project currently uses a SQLite database (`data/local/gear.db`) with 232 manufacturers, 104 pedals, and ~306 jacks. The user wants to build an API (Java/Spring Boot with Maven) to serve data dynamically to the React frontend. Before building the API, we're migrating to PostgreSQL because:

- The database will grow to tens of thousands of records
- Crowd-sourced data corrections/additions will require concurrent write support
- PostgreSQL works locally for free and migrates cleanly to AWS RDS later
- It's the standard pairing with Spring Boot

This plan covers **Step 1 only: the database migration.** The Spring Boot API will be Step 2.

## Step 1: Install and configure PostgreSQL

```bash
brew install postgresql@17
brew services start postgresql@17
```

Create database and application user:
```sql
CREATE USER pedal_shootout_app WITH PASSWORD 'localdev';
CREATE DATABASE pedal_shootout OWNER pedal_shootout_app;
GRANT ALL PRIVILEGES ON DATABASE pedal_shootout TO pedal_shootout_app;
```

## Step 2: Create PostgreSQL schema

Create `data/schema/gear_postgres.sql` by translating the SQLite schema. Key changes:

| SQLite | PostgreSQL |
|--------|-----------|
| `INTEGER PRIMARY KEY AUTOINCREMENT` | `INTEGER GENERATED ALWAYS AS IDENTITY` |
| `INTEGER CHECK(x IN (0, 1))` / `INTEGER DEFAULT 0` (booleans) | `BOOLEAN DEFAULT FALSE` |
| `REAL` | `DOUBLE PRECISION` |
| `DATETIME DEFAULT CURRENT_TIMESTAMP` | `TIMESTAMPTZ DEFAULT NOW()` |
| `datetime('now')` in triggers | `NOW()` in trigger functions |
| `GROUP_CONCAT(x, ', ')` | `STRING_AGG(x, ', ')` |
| `printf(...)` | `FORMAT(...)` |

~55 boolean columns across all tables need conversion. All `REAL` dimension columns become `DOUBLE PRECISION`.

Triggers become PL/pgSQL functions. The `update_product_timestamp` trigger uses `BEFORE UPDATE` to set `NEW.updated_at = NOW()` directly (avoids recursion). The two manufacturer timestamp triggers use `AFTER INSERT/UPDATE` on products.

The `pedals_legacy` view is ported with syntax changes.

Archive the original: rename `gear.sql` to `gear_sqlite.sql.bak`.

## Step 3: Export data from SQLite

Create `data/migrations/002_migrate_sqlite_to_postgres.sh` that:
1. Exports CSV from SQLite for tables with data: `manufacturers`, `products`, `pedal_details`, `jacks`
2. Skips `product_types` (seeded in DDL)
3. CSVs go to `data/migrations/csv_export/` (gitignored)

## Step 4: Import data into PostgreSQL

The migration script also handles import:
1. Load CSVs into temp staging tables (INTEGER for booleans)
2. `INSERT INTO ... SELECT` with boolean conversion (`col = 1` → `TRUE`)
3. Use `OVERRIDING SYSTEM VALUE` for identity columns
4. Reset identity sequences with `setval()`

Import order (respects FK constraints):
1. `manufacturers` (no dependencies)
2. `products` (depends on manufacturers, product_types)
3. `pedal_details` (depends on products)
4. `jacks` (depends on products)

## Step 5: Verify data integrity

- Row counts: 232 manufacturers, 104 products, 104 pedal_details, ~306 jacks
- Spot-check specific records (e.g., Morning Glory V4)
- Verify `pedals_legacy` view returns data
- Verify FK enforcement (INSERT with bad FK should fail)
- Verify triggers fire (UPDATE a product, check `updated_at`)

## Step 6: Update project documentation

- **`CLAUDE.md`**: Replace SQLite commands/guidance with PostgreSQL equivalents, remove PRAGMA section, add connection info
- **`.gitignore`**: Add `data/migrations/csv_export/`
- **`.env.example`** (new): Document `DATABASE_URL=postgresql://pedal_shootout_app:localdev@localhost:5432/pedal_shootout`

## Files

| File | Change |
|------|--------|
| `data/schema/gear_postgres.sql` | **New** — PostgreSQL schema (new source of truth) |
| `data/schema/gear_sqlite.sql.bak` | **Rename** — Archive of original SQLite schema |
| `data/migrations/002_migrate_sqlite_to_postgres.sh` | **New** — Export/import/verify script |
| `CLAUDE.md` | Update database docs for PostgreSQL |
| `.gitignore` | Add csv_export directory |
| `.env.example` | **New** — Document DATABASE_URL |

## Verification

1. `psql -U pedal_shootout_app -d pedal_shootout -c "SELECT COUNT(*) FROM manufacturers;"` → 232
2. `psql -U pedal_shootout_app -d pedal_shootout -c "SELECT COUNT(*) FROM products;"` → 104
3. `psql -U pedal_shootout_app -d pedal_shootout -c "SELECT * FROM pedals_legacy LIMIT 3;"` → data appears
4. FK violation test fails as expected
5. Trigger fires on product update

## Notes

- SQLite file (`data/local/gear.db`) is kept as-is — not deleted
- Migration tool (Flyway) deferred to Spring Boot setup — it integrates naturally as a Spring dependency
- No changes to the React frontend in this step
