# Pedal Shootout

A guitar gear database and comparison tool for comparing the specs and features of effects pedals.

## Quick Start

### Web App

```bash
npm run web              # Start dev server (localhost:8080)
```

### Database

The database runs on PostgreSQL 17. Connect with:

```bash
psql -U pedal_shootout_app -d pedal_shootout
```

If `psql` isn't found, add it to your PATH:

```bash
export PATH="/usr/local/opt/postgresql@17/bin:$PATH"
```

### Useful Queries

```sql
-- All pedals with manufacturer name
SELECT m.name, p.model, pd.effect_type, pd.bypass_type
FROM products p
JOIN manufacturers m ON p.manufacturer_id = m.id
JOIN pedal_details pd ON p.id = pd.product_id
ORDER BY m.name, p.model;

-- Legacy flat view (closest to the old spreadsheet format)
SELECT * FROM pedals_legacy;

-- All manufacturers
SELECT name, country, status FROM manufacturers ORDER BY name;

-- Find pedals by effect type
SELECT m.name, p.model FROM products p
JOIN manufacturers m ON p.manufacturer_id = m.id
JOIN pedal_details pd ON p.id = pd.product_id
WHERE pd.effect_type = 'Delay';

-- Jacks/connections for a specific pedal
SELECT j.category, j.direction, j.connector_type, j.voltage, j.current_ma
FROM jacks j
JOIN products p ON j.product_id = p.id
WHERE p.model = 'Morning Glory V4';
```

## Features

- A form for submitting the specs of a particular pedal
- A filterable view for comparing all of the specs of selected pedals side-by-side

## Project Structure

```
pedal_shootout/
├── apps/web/                   # React/TypeScript frontend
├── data/
│   ├── schema/                 # SQL schema (gear_postgres.sql is source of truth)
│   └── migrations/             # Migration scripts
├── docs/plans/                 # Design docs and plans
└── infrastructure/             # Future AWS CDK/Terraform
```

## Tech Stack

- **Frontend:** React 18, TypeScript, Webpack 5, SASS
- **Database:** PostgreSQL 17 (Class Table Inheritance pattern)
- **API:** Spring Boot (planned)

## Database Setup

For a fresh install:

```bash
# Install PostgreSQL
brew install postgresql@17
brew services start postgresql@17

# Create user and database
psql postgres -c "CREATE USER pedal_shootout_app WITH PASSWORD 'localdev';"
psql postgres -c "CREATE DATABASE pedal_shootout OWNER pedal_shootout_app;"

# Apply schema
PGPASSWORD=localdev psql -U pedal_shootout_app -d pedal_shootout -f data/schema/gear_postgres.sql

# Run migration (imports data from SQLite)
./data/migrations/002_migrate_sqlite_to_postgres.sh
```

See `CLAUDE.md` for detailed data collection guidelines and schema documentation.
