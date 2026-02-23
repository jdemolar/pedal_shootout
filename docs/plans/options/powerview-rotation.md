# Option: Rotation in PowerView (and other planning views)

## Context

Rotation in LayoutView is straightforward — cards rotate visually and there are no dependent elements like connection lines that need to track port positions.

PowerView is more complex because `ConnectionLine` endpoints are computed independently from the rendered `PortDot` positions. Currently, `portPositions` is a `useMemo` that calculates absolute world coordinates using hardcoded offsets from each card's top-left corner:

```typescript
// Supply output ports — right edge of card
x: pos.x + CARD_WIDTH - 2,
y: pos.y + PORT_START_Y + i * PORT_SPACING,

// Consumer input ports — left edge of card
x: pos.x + 2,
y: pos.y + CARD_HEIGHT / 2,
```

If we rotate a card, the visual port positions (rendered inside the card's Konva Group) rotate automatically via Konva's transform hierarchy, but the connection line endpoints stay at the unrotated positions — causing lines to detach from ports.

## Option A: Refactor portPositions to read from rendered nodes (recommended)

`PortDot` components are children of `ProductCard`, so they live inside the rotating Konva Group. Konva nodes expose `getAbsolutePosition()` which returns the node's position after all parent transforms (including rotation) are applied.

**Approach:**
1. Add refs to each `PortDot` Konva node
2. After render, read `getAbsolutePosition()` from each port node
3. Use those positions for `ConnectionLine` endpoints and hit-testing

**Pros:**
- Rotation comes for free — Konva's transform hierarchy handles the math
- No manual vector rotation logic to maintain
- Single source of truth for port positions (the rendered nodes themselves)

**Cons:**
- Requires an imperative bridge (refs + `useEffect` or second render pass)
- Slightly less idiomatic React (reading from rendered nodes rather than pre-computing data)

## Option B: Manually rotate port offset vectors

Keep the current pre-computed `useMemo` approach but apply rotation math to the offset vectors when a card has a non-zero rotation.

**Approach:**
1. For each port, compute the offset from card center: `(offsetX, offsetY)`
2. Apply 2D rotation to the offset: `(cos(θ)*dx - sin(θ)*dy, sin(θ)*dx + cos(θ)*dy)`
3. Add back the card center to get world position

**Pros:**
- Stays within React's declarative model
- No refs or second render pass needed

**Cons:**
- Duplicates rotation logic (Konva handles it for visuals, we recompute it for positions)
- Must stay in sync with ProductCard's inner Group transform parameters

## Recommendation

Option A is cleaner long-term. It eliminates the duplicated position calculation entirely and makes the system resilient to future transform changes (e.g., if card sizing or pivot points change). The imperative bridge is a well-established React pattern for canvas libraries.
