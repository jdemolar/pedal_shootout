# #3 Client-Side Persistence for Workbench State
Date: February 15, 2026

## Status
Accepted

## Context
The workbench feature lets users curate a list of products they're considering for a pedalboard build. This state needs to persist across browser sessions so users don't lose their selections.

Two broad approaches exist: store the data client-side (localStorage, IndexedDB) or server-side (database with user accounts and authentication).

## Decision
Workbench state is persisted in **localStorage**. There is no server-side storage or user authentication for workbench data.

## Alternatives Considered

**Server-side persistence with user accounts.** Would enable cross-device sync, sharing workbenches with others, and protection against browser storage clearing. Rejected because it introduces authentication, session management, a new database table, and write endpoints to a currently read-only API — all for a feature whose core value can be delivered without any of that. The complexity cost is disproportionate to the current stage of the project.

**IndexedDB instead of localStorage.** Higher storage limits and supports structured data natively. Rejected because workbench data is small (product ID references, not full product objects — see ADR #4) and well within localStorage's ~5MB limit. IndexedDB's async API adds complexity without a corresponding benefit at this data size.

**No persistence (in-memory only).** Simplest implementation but makes the feature nearly useless — users would lose their workbench on every page refresh. Rejected.

## Consequences
- Users cannot access their workbenches from a different browser or device.
- Clearing browser data (or localStorage specifically) deletes all workbenches with no recovery path.
- The API remains fully read-only, which keeps the backend simple and avoids authorization concerns.
- If user accounts are added later, workbench data can be migrated from localStorage to the server on first login. The data model (see ADR #4) is a simple JSON structure that maps directly to a database table.
