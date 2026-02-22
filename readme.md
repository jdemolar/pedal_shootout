# Pedal Shootout

A guitar gear database and comparison tool for comparing the specs and features of effects pedals, power supplies, pedalboards, MIDI controllers, and utilities.

## Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) — the only requirement for local development

## Quick Start

```bash
docker-compose up --build    # First run: builds images, seeds database (~2-3 min)
```

Once all three containers are running:
- **Web app:** http://localhost:8080
- **API:** http://localhost:8081/api/pedals
- **Database:** `psql -h localhost -p 5433 -U pedal_shootout_app -d pedal_shootout`

> The Docker database runs on port **5433** (not 5432) to avoid conflicts with any local PostgreSQL installation.

## Dev Workflow

| Action | Command |
|---|---|
| Start everything | `docker-compose up` |
| Start (rebuild images) | `docker-compose up --build` |
| Stop (keep data) | `docker-compose down` |
| Wipe DB and start fresh | `docker-compose down --volumes && docker-compose up` |
| After Java code change | `docker-compose restart api` |
| After `pom.xml` change | `docker-compose up --build api` |
| After `package.json` change | `docker-compose down --volumes && docker-compose up` |
| View logs for one service | `docker-compose logs -f api` |

### What persists across restarts

Database data is stored in a Docker volume. Running `docker-compose down` stops the containers but keeps the data. To fully reset the database (re-run schema + seed), use `docker-compose down --volumes`.

### Hot reloading

- **Frontend:** Editing `.tsx`/`.scss` files on your host triggers webpack HMR — changes appear in the browser immediately.
- **API:** Java changes require `docker-compose restart api` to recompile (~10s, Maven deps are cached).

## Project Structure

```
pedal_shootout/
├── apps/
│   ├── api/                    # Spring Boot API (Java 17, port 8081)
│   │   ├── src/main/java/...   # Controllers, services, entities, DTOs
│   │   ├── Dockerfile
│   │   └── pom.xml
│   └── web/                    # React/TypeScript frontend (port 8080)
│       ├── src/
│       ├── Dockerfile
│       └── package.json
├── data/
│   ├── schema/                 # gear_postgres.sql (schema source of truth)
│   ├── seeds/                  # seed.sql (data loaded on first Docker start)
│   ├── templates/              # SQL insert templates per product type
│   └── migrations/             # Versioned migration scripts
├── docs/plans/                 # Design docs and plans
├── docker-compose.yml
└── CLAUDE.md                   # Detailed project conventions and data guidelines
```

## Tech Stack

- **Frontend:** React 18, TypeScript, Webpack 5, SASS
- **API:** Spring Boot 3.4.3, Java 17, Spring Data JPA, Flyway
- **Database:** PostgreSQL 17 (Class Table Inheritance pattern)

## Architecture

```
Browser (host)
  ├── http://localhost:8080  →  web container (webpack-dev-server)
  └── http://localhost:8081  →  api container (Spring Boot)
                                      │
                                 db container (PostgreSQL 17)
                                 internal hostname: db, port 5432
```

The browser calls the API directly at `localhost:8081`. The API container connects to the database via the internal Docker hostname `db`.

## API

The API serves 25 read-only GET endpoints. Full spec at `docs/openapi.yaml`.

Key endpoints:
- `GET /api/pedals` — all pedals with details
- `GET /api/manufacturers` — all manufacturers
- `GET /api/pedals/{id}` — single pedal with full details and jacks

## Running Without Docker

If you prefer running services natively on your host:

### Prerequisites

- **Node 20** (via [nvm](https://github.com/nvm-sh/nvm))
- **Java 17** (e.g., [Eclipse Temurin](https://adoptium.net/))
- **PostgreSQL 17**

### Database Setup

```bash
# Install PostgreSQL (macOS)
brew install postgresql@17
brew services start postgresql@17

# Create user and database
psql postgres -c "CREATE USER pedal_shootout_app WITH PASSWORD 'localdev';"
psql postgres -c "CREATE DATABASE pedal_shootout OWNER pedal_shootout_app;"

# Apply schema and seed data
PGPASSWORD=localdev psql -U pedal_shootout_app -d pedal_shootout -f data/schema/gear_postgres.sql
PGPASSWORD=localdev psql -U pedal_shootout_app -d pedal_shootout -f data/seeds/seed.sql
```

### Start Services

```bash
# Web app (from project root)
npm run web                    # localhost:8080

# API (from apps/api/)
cd apps/api
./mvnw spring-boot:run         # localhost:8081
```

### Connect to Database

```bash
psql -U pedal_shootout_app -d pedal_shootout

# If psql isn't found:
export PATH="/usr/local/opt/postgresql@17/bin:$PATH"
```

## Useful Queries

```sql
-- All pedals with manufacturer name
SELECT m.name, p.model, pd.effect_type, pd.bypass_type
FROM products p
JOIN manufacturers m ON p.manufacturer_id = m.id
JOIN pedal_details pd ON p.id = pd.product_id
ORDER BY m.name, p.model;

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

## Additional Documentation

See `CLAUDE.md` for detailed schema documentation, data collection guidelines, and project conventions.
