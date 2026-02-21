# Spring Boot REST API Plan

## Status: Implemented

All 25 endpoints implemented across 9 phases.

## Tech Stack

- Java 17 (Temurin) + Spring Boot 3.4.3
- Spring Data JPA (Hibernate) + PostgreSQL 17
- Flyway (baseline-on-migrate for existing DB)
- Maven with wrapper (`./mvnw`)

## Running

```bash
cd apps/api
./mvnw spring-boot:run    # starts on port 8081
```

## Endpoints

### Layer 1: Per-Table (19 endpoints)

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/manufacturers` | All manufacturers (?search=) |
| GET | `/api/manufacturers/{id}` | Single manufacturer + product count |
| GET | `/api/manufacturers/{id}/products` | Products by manufacturer |
| GET | `/api/products` | All products (?typeId=) |
| GET | `/api/products/{id}` | Single product + jacks |
| GET | `/api/products/{id}/jacks` | Jacks for a product |
| GET | `/api/product-types` | Reference data (6 types) |
| GET | `/api/pedals` | All pedals (?effectType=) |
| GET | `/api/pedals/{id}` | Single pedal + details + jacks |
| GET | `/api/power-supplies` | All power supplies |
| GET | `/api/power-supplies/{id}` | Single power supply |
| GET | `/api/pedalboards` | All pedalboards |
| GET | `/api/pedalboards/{id}` | Single pedalboard |
| GET | `/api/midi-controllers` | All MIDI controllers |
| GET | `/api/midi-controllers/{id}` | Single MIDI controller |
| GET | `/api/utilities` | All utilities (?utilityType=) |
| GET | `/api/utilities/{id}` | Single utility |
| GET | `/api/plugs` | All plugs |
| GET | `/api/plugs/{id}` | Single plug |

### Layer 2: Cross-Table Use-Case (6 endpoints)

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/board-planner/components` | Boards + supplies + pedals for layout |
| GET | `/api/board-planner/fit-check?boardId=X&pedalIds=1,2,3` | Check pedal fit on board |
| GET | `/api/power-budget/calculate?supplyId=X&pedalIds=1,2,3` | Power draw vs capacity |
| GET | `/api/power-budget/supplies-for-pedals?pedalIds=1,2,3` | Find compatible supplies |
| GET | `/api/midi-planner/devices` | All MIDI-capable devices |
| GET | `/api/midi-planner/compatibility?controllerId=X&pedalIds=1,2,3` | MIDI compatibility check |

## Architecture

```
HTTP Request → Controller → Service → Repository → Database
HTTP Response ← Controller ← Service (Entity → DTO) ← Repository ← DB
```

- **Controller**: URL routing, HTTP status codes
- **Service**: Business logic, entity-to-DTO mapping
- **Repository**: Spring auto-generates SQL from interface methods
- **Entity**: Java class mapped 1:1 to a database table
- **DTO**: JSON response shape (decoupled from DB schema)

## Project Structure

```
apps/api/
├── pom.xml
├── mvnw
├── .mvn/wrapper/
├── src/main/
│   ├── java/com/pedalshootout/api/
│   │   ├── PedalShootoutApiApplication.java
│   │   ├── config/CorsConfig.java
│   │   ├── entity/ (10 entities)
│   │   ├── repository/ (10 repositories)
│   │   ├── service/ (6 services)
│   │   ├── dto/ (12 DTOs)
│   │   └── controller/ (7 controllers)
│   └── resources/
│       ├── application.yml
│       └── db/migration/V1__baseline.sql
└── src/test/
    └── java/.../PedalShootoutApiApplicationTests.java
```
