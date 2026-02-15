# #6 URL Search Params for Cross-View Filter State
Date: February 15, 2026

## Status
Accepted

## Context
The workbench power budget insight needs to link users to the Power Supplies catalog view with filters pre-applied (e.g., "show supplies with at least 2,780mA capacity"). Currently, all catalog view filters are local component state — there is no way for one view to pass filter criteria to another.

This is the first instance of cross-view communication in the app, so the pattern chosen here will likely be followed by future features (e.g., MIDI insight linking to a filtered controllers view, board fit linking to filtered pedalboards).

## Decision
Catalog views accept **filter criteria via URL search params** (e.g., `/power-supplies?minCurrent=2780`). On mount, the view reads `window.location.search`, applies matching params as initial filter state, and renders accordingly.

## Alternatives Considered

**React Router state (navigate with state object).** Filter criteria would be passed via `navigate('/power-supplies', { state: { minCurrent: 2780 } })` and read via `useLocation().state`. Rejected because route state is ephemeral — it doesn't survive a page refresh, can't be bookmarked, and can't be shared as a link. URL params are durable and transparent.

**Global state (Context or state manager).** A shared filter context that any view can write to and any other view can read from. Rejected because it couples views together through shared mutable state. URL params achieve the same result — passing criteria from one view to another — without the coupling. Each view owns its own filter logic and simply reads from a standard, stateless source (the URL).

**No cross-view filtering.** The workbench links to the unfiltered Power Supplies page and the user applies filters manually. Rejected because the whole point of the guided power budget insight is to reduce friction. Sending users to an unfiltered list of hundreds of power supplies after calculating exactly what they need defeats the purpose.

## Consequences
- Catalog filter state becomes bookmarkable and shareable (e.g., a user could share a link to "all isolated power supplies with 2000mA+ capacity").
- Each catalog view that supports URL params must parse them on mount and map them to its internal filter state. This is a small amount of plumbing per view.
- URL params and local filter state must stay in sync — if the user changes a filter manually, the URL should update (or at minimum, not contradict what's shown). Using `useSearchParams` from React Router keeps this manageable.
- This establishes a convention: **views communicate via URL, not shared state**. Future cross-view links (MIDI insight → controllers, fit check → pedalboards) should follow the same pattern.
