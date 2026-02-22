# #7 Docker Compose for Local Development
Date: February 21, 2026

## Status
Accepted

## Context
The project has three services — a React frontend, a Spring Boot API, and PostgreSQL 17. Previously, each had to be installed and run manually on the host (Homebrew for Postgres, nvm for Node, Temurin for Java). This created a lengthy setup process with OS-specific gotchas (e.g., PostgreSQL 17 on macOS 13 requires building from source via Homebrew, taking 60+ minutes). Any new contributor would need to replicate this entire environment before seeing the app run.

## Decision
Use **Docker Compose** as the primary local development environment. A single `docker-compose up --build` starts all three services with a fully seeded database. Manual (non-Docker) setup is preserved as a secondary option.

Key design choices within this decision:

- **Full schema + seed via init scripts, not Flyway.** The Docker database loads `gear_postgres.sql` (schema) and `seed.sql` (data) through PostgreSQL's `/docker-entrypoint-initdb.d/` mechanism on first start. Flyway's baseline version is set to the latest migration (V3) in the Docker environment so it skips all migrations. This avoids the chicken-and-egg problem of Flyway trying to alter a schema that was already created complete.

- **Port 5433 for the Docker database.** The Docker Postgres is published on host port 5433 (not 5432) so it can coexist with a local PostgreSQL installation. Contributors can run both without conflict.

- **Environment variable placeholders with defaults in application.yml.** The API's database connection uses `${DB_HOST:localhost}` syntax. In Docker, compose sets `DB_HOST=db`. Without Docker, the defaults (`localhost`, `5432`) apply. One config file serves both environments.

- **Named volumes for node_modules.** The web container mounts the monorepo root for hot reloading but shadows `node_modules/` directories with named volumes. This prevents macOS-compiled native modules from being used inside the Linux container (and vice versa).

## Alternatives Considered

**Dev Containers (VS Code).** A `.devcontainer/` config that opens the entire project inside a container with all tools pre-installed. Rejected because it couples the dev environment to VS Code. Docker Compose is editor-agnostic — it works the same whether you use VS Code, IntelliJ, vim, or anything else.

**Makefile or shell scripts wrapping manual setup.** A `make setup` that installs Postgres, Node, and Java via Homebrew/nvm, then runs the schema. Rejected because it still requires installing everything on the host and is fragile across OS versions (the macOS 13 Homebrew issues are a case in point). Docker isolates the project from the host OS entirely.

**Keep manual setup as the only path.** Document the steps better and leave it at that. Rejected because the setup is genuinely complex (three runtimes, OS-specific workarounds) and Docker eliminates all of it for the common case. The manual path is preserved for contributors who prefer it.

## Consequences
- New contributors only need Docker Desktop installed — no Node, Java, or PostgreSQL setup required.
- The `data/seeds/seed.sql` file must be regenerated whenever the database content changes significantly (e.g., after a bulk data import). The command is documented in the dockerize plan doc.
- When new Flyway migrations are added, `SPRING_FLYWAY_BASELINE_VERSION` in `docker-compose.yml` must be bumped to match, and the schema file should be kept in sync. Forgetting this will cause the API container to fail on a fresh Docker start.
- Hot reloading works for frontend changes (webpack HMR). Java changes require `docker-compose restart api` (~10s with cached Maven dependencies).
- The Docker database is ephemeral by design — `docker-compose down --volumes` gives a clean slate. This is a feature for dev, but means Docker is not a data persistence mechanism.
