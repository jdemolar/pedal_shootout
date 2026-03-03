# Workbench Cloud Save (Backend Persistence)

**Status:** Design
**Created:** 2026-02-23
**Parent:** Extracted from `connections-and-cabling.md` Phase 6

**Prerequisite:** User accounts (authentication/authorization) must be implemented before cloud save is useful.

---

## Context

Workbench data is user-specific state that gets loaded whole and saved whole — there's no need to query individual connections or positions at the database level. A JSONB blob approach is simpler and maps directly to the localStorage model.

---

## Database Design

### Table

```sql
CREATE TABLE workbenches (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    -- user_id INTEGER NOT NULL REFERENCES users(id),  -- Future: when auth is implemented
    name TEXT NOT NULL,
    data JSONB NOT NULL,              -- Complete workbench state (items, connections, positions, virtual nodes)
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_workbenches_name ON workbenches(name);
-- Future: CREATE INDEX idx_workbenches_user ON workbenches(user_id);
```

The `data` column stores the entire `Workbench` object from the frontend (minus `id`, `name`, `createdAt`, `updatedAt` which live in the table columns). This includes `items`, `viewPositions`, `viewportStates`, `powerConnections`, `audioConnections`, `midiConnections`, `controlConnections`, and `virtualNodes`.

**Sync protocol:** On save, serialize the current localStorage workbench state to JSON and PUT to `/api/workbenches/{id}`. On load, GET the JSON and hydrate localStorage. Conflict resolution is last-write-wins (sufficient for single-user).

---

## Implementation Checklist

- Write migration SQL for `workbenches` table with JSONB `data` column
- Spring Boot entity, repository, DTO, controller
- Workbench CRUD API endpoints (GET/PUT)
- localStorage <-> server sync
