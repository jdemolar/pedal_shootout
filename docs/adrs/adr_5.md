# #5 Multiple Workbenches in Data Model from v1
Date: February 15, 2026

## Status
Accepted

## Context
Users may want to plan more than one pedalboard build — for example, a gigging board and a studio board, or comparing two different configurations. The question is whether to model for multiple workbenches from the start or begin with a single workbench and add multi-workbench support later.

## Decision
The data model and React Context API support **multiple named workbenches from day one**. The UI also exposes full workbench management (create, rename, switch, delete) in v1.

```typescript
interface WorkbenchStore {
  workbenches: Workbench[];
  activeWorkbenchId: string;
}
```

The Context API includes `createWorkbench`, `renameWorkbench`, `deleteWorkbench`, and `setActiveWorkbench` alongside the per-item `addItem`/`removeItem` operations.

## Alternatives Considered

**Single workbench, migrate later.** Simpler initial Context API — no workbench selector, no CRUD operations. The argument for this is YAGNI: build multi-workbench when users ask for it. Rejected because the retrofit cost is high relative to the upfront cost. Every component that calls `addItem` (all catalog views, the nav badge, the workbench page) would need to gain a workbench selector parameter. The localStorage schema migration from a flat `items[]` to `workbenches[]` would need to handle existing user data. Modeling it correctly from the start costs a few extra interface fields and one dropdown component.

**Single workbench in data model, multi in UI later.** Store a single workbench but keep the door open. Rejected because this is the worst of both worlds — you still pay the migration cost when you add multi-workbench, but you also don't get the benefit of a simpler API since you're "keeping the door open" by not committing to either design.

## Consequences
- The Context API is slightly larger than a single-workbench version (workbench CRUD methods, active workbench tracking).
- The "add to workbench" interaction on catalog rows needs a way to select which workbench to add to. This could be as simple as always adding to the active workbench, with a long-press or secondary action to pick a different one.
- localStorage schema is stable from day one — no migration needed when multi-workbench UI ships, because it already shipped.
- A default workbench ("My Workbench") is created automatically if localStorage is empty, so the experience is seamless for users who only ever need one.
