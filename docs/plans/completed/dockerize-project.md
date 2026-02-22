 Context

 The project has three components — a React frontend, a Spring Boot API, and PostgreSQL 17 — each running manually on the host. Dockerizing creates a single docker-compose up command that starts everything
 with a fully loaded database. This is dev-only; prod images can be layered on later without rework.

 Architecture

 Browser (host)
   ├── http://localhost:8080 → web container (webpack-dev-server)
   └── http://localhost:8081 → api container (Spring Boot)
                                     │ (internal network)
                                db container (PostgreSQL 17)
                                hostname: db, port: 5432

 The browser calls the API directly at localhost:8081 (no proxy) — confirmed in apps/web/src/services/api.ts. The API container connects to the DB via internal hostname db, not localhost.

 Files to create

 1. docker-compose.yml (project root)

 Three services:
 - db: postgres:17-alpine, env vars set POSTGRES_DB=pedal_shootout, POSTGRES_USER=pedal_shootout_app, POSTGRES_PASSWORD=localdev. Mounts data/schema/gear_postgres.sql as 01_schema.sql and data/seeds/seed.sql
  as 02_seed.sql in /docker-entrypoint-initdb.d/ (run once on first start). Named volume db_data for persistence. Published on host port 5433 (avoids conflict with local Postgres on 5432). Healthcheck via
 pg_isready.
 - api: Builds from apps/api/Dockerfile. Depends on db (healthy). Env vars: DB_HOST=db, DB_PORT=5432, DB_NAME=pedal_shootout, DB_USER=pedal_shootout_app, DB_PASSWORD=localdev. Volume-mounts apps/api/src into
  the container for live editing (restart to pick up changes). Named volume maven_cache at /root/.m2. Published port 8081.
 - web: Builds from apps/web/Dockerfile. Env vars: CHOKIDAR_USEPOLLING=true (macOS Docker needs polling for file watching), BROWSER=none. Mounts the entire monorepo root at /workspace (webpack resolves
 modules from both apps/web/node_modules/ and root node_modules/ — confirmed in webpack.common.js:50-52). Two named volumes shadow the host's macOS node_modules/ with Linux-native ones: web_node_modules_root
  at /workspace/node_modules and web_node_modules_app at /workspace/apps/web/node_modules. Working dir /workspace/apps/web. Published port 8080.

 2. apps/api/Dockerfile

 - Base: eclipse-temurin:17-jdk
 - Copy .mvn/, mvnw, pom.xml first → RUN ./mvnw dependency:go-offline -q (caches deps in image layer)
 - Copy src/ last (changes most often)
 - CMD ["./mvnw", "spring-boot:run"]

 3. apps/web/Dockerfile

 - Base: node:20-alpine
 - Install build tools: apk add --no-cache python3 make g++
 - Working dir /workspace/apps/web
 - Conditional npm install: only runs if /workspace/node_modules/.bin doesn't exist (named volume is fresh)
 - Then runs npm run web from the monorepo root (which triggers webpack serve)

 4. apps/api/.dockerignore

 Exclude target/, .idea/, .git/, .DS_Store

 5. apps/web/.dockerignore

 Exclude node_modules/, build/, dist/, .DS_Store

 6. data/seeds/seed.sql (generated via pg_dump)

 Data-only dump of the current local database. Command:
 pg_dump --host=localhost --port=5432 --username=pedal_shootout_app \
   --dbname=pedal_shootout --no-owner --no-acl --data-only --column-inserts \
   --exclude-table=product_types --exclude-table=flyway_schema_history \
   --file=data/seeds/seed.sql
 - --no-owner/--no-acl: strips role-specific statements
 - --data-only: schema already loaded from 01_schema.sql
 - --exclude-table=product_types: already seeded by gear_postgres.sql (line 30)
 - --exclude-table=flyway_schema_history: Flyway creates its own on startup

 Files to modify

 7. apps/api/src/main/resources/application.yml

 Replace hardcoded DB connection with Spring property placeholders:
 spring:
   datasource:
     url: jdbc:postgresql://${DB_HOST:localhost}:${DB_PORT:5432}/${DB_NAME:pedal_shootout}
     username: ${DB_USER:pedal_shootout_app}
     password: ${DB_PASSWORD:localdev}
 Defaults match current values, so local development without Docker is unchanged.

 Dev workflow after setup

 ┌───────────────────────────┬─────────────────────────────────────────────────────────────────────────┐
 │          Action           │                                 Command                                 │
 ├───────────────────────────┼─────────────────────────────────────────────────────────────────────────┤
 │ Start everything          │ docker-compose up                                                       │
 ├───────────────────────────┼─────────────────────────────────────────────────────────────────────────┤
 │ Stop (keep data)          │ docker-compose down                                                     │
 ├───────────────────────────┼─────────────────────────────────────────────────────────────────────────┤
 │ Wipe DB and start fresh   │ docker-compose down --volumes then docker-compose up                    │
 ├───────────────────────────┼─────────────────────────────────────────────────────────────────────────┤
 │ After Java code change    │ docker-compose restart api (~10s, Maven cached)                         │
 ├───────────────────────────┼─────────────────────────────────────────────────────────────────────────┤
 │ After pom.xml change      │ docker-compose build api && docker-compose up                           │
 ├───────────────────────────┼─────────────────────────────────────────────────────────────────────────┤
 │ After package.json change │ docker-compose down, remove web node_modules volumes, docker-compose up │
 ├───────────────────────────┼─────────────────────────────────────────────────────────────────────────┤
 │ Connect psql to Docker DB │ psql -h localhost -p 5433 -U pedal_shootout_app -d pedal_shootout       │
 └───────────────────────────┴─────────────────────────────────────────────────────────────────────────┘

 Verification

 1. docker-compose up --build — all three containers start without errors
 2. DB healthcheck passes; API waits for it before starting
 3. Spring Boot connects to db:5432, Flyway runs without errors
 4. http://localhost:8080 loads the React app
 5. http://localhost:8081/api/pedals returns data (confirms DB seeded + API connected)
 6. Edit a .tsx file on host → webpack HMR updates in browser
 7. Local (non-Docker) dev still works: ./mvnw spring-boot:run connects to localhost:5432, npm run web serves on 8080