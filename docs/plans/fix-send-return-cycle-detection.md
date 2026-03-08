# Fix false cycle detection in loop switcher send/return

## Context

The shared `wouldCreateCycle` function in `connectionValidation.ts` performs a BFS over directed edges (sourceInstanceId → targetInstanceId). When a user connects a pedal into a loop switcher's send/return loop, two connections are created:

1. **Loop switcher Send → Pedal Input** (switcher is source, pedal is target)
2. **Pedal Output → Loop switcher Return** (pedal is source, switcher is target)

The BFS sees this as A→B and B→A, which is a cycle. But it's an intentional send/return topology, not a feedback loop. The current code emits an `audio:circular-connection` error with the message "This connection would create a feedback loop in the signal chain."

The `AudioConnection` type already has an `fxLoopGroupId` field (linked to `jacks.group_id`) designed for exactly this purpose, but it's always set to `null` today.

## Goals

1. Stop falsely flagging send/return connections as feedback loops
2. Downgrade the warning from `error` to `info` when the cycle is caused by a send/return pair (it's expected topology, not a problem)
3. Keep the `error` severity for genuine feedback loops (e.g., connecting a pedal's output back to its own input via another pedal without a loop switcher in the path)

## Approach

When `wouldCreateCycle` returns `true`, perform a secondary check: does the cycle pass through a device via paired send/return jacks (same `group_id`)? If so, it's intentional topology — downgrade from `error` to `info`.

The key insight: a send/return loop — regardless of how many pedals are in the chain — always **enters and exits the same device** through paired jacks. The Send jack is the cycle's exit point and the Return jack is the cycle's entry point (or vice versa), and they share a `group_id`.

### Scenarios considered

**Simple case — one pedal in the loop:**
```
Connections:
  1. A(Send, group_id=loop-1) → B(Input)
  2. B(Output) → A(Return, group_id=loop-1)   ← new
```
Cycle detected. On device A: the new connection enters via Return, and existing connection 1 exits via Send. Both jacks share `group_id=loop-1` → send/return loop → `info`.

**Multi-pedal chain in one loop:**
```
Connections:
  1. A(Send, group_id=loop-1) → B(Input)
  2. B(Output) → C(Input)
  3. C(Output) → A(Return, group_id=loop-1)   ← new
```
Cycle detected (A→B→C→A). On device A: the new connection enters via Return (jack id from connection 3's `targetJackId`), and the cycle exits via Send (jack id from connection 1's `sourceJackId`). Both share `group_id=loop-1` → send/return loop → `info`.

**Send to separate amp (no return):**
```
Connections:
  1. A(Send) → B(AmpInput)
```
No cycle detected — `wouldCreateCycle` returns false. The `isSendReturnLoop` check is never reached. No issue.

**Genuine feedback loop (no paired jacks):**
```
Connections:
  1. A(Output) → B(Input)
  2. B(Output) → A(Input)   ← new, different jack, no shared group_id
```
Cycle detected. On device A: the entry jack and exit jack do NOT share a `group_id` → genuine feedback loop → `error`.

### Implementation steps

1. Add a new function `isSendReturnLoop` that checks whether the cycle enters and exits any device through paired jacks (same `group_id`)
2. Pass jack lookup data into `validateAudioConnection` so it can resolve `group_id` for connection jacks
3. When cycle detected + send/return confirmed → emit `info` instead of `error`

## Files to Modify

| File | Change |
|---|---|
| `apps/web/src/utils/audioUtils.ts` | Add `isSendReturnLoop` check; update `validateAudioConnection` to accept jack lookup and downgrade send/return cycles to `info` |
| `apps/web/src/components/Workbench/AudioView.tsx` | Pass jack lookup map to `validateAudioConnection` (already has `jackMap`) |
| `apps/web/src/__tests__/utils/audioUtils.test.ts` | Add tests for send/return cycle detection (info) vs genuine cycle (error) |

## Implementation

### 1. Add `isSendReturnLoop` helper to `audioUtils.ts`

This function checks whether a detected cycle enters and exits any single device through paired send/return jacks (same `group_id`). It handles both the simple 2-device case and multi-pedal chains.

```ts
/**
 * Check if a detected cycle is actually a send/return loop topology.
 *
 * A send/return loop exists when the cycle enters and exits the same device
 * through jacks that share a group_id (a paired send/return). This works
 * regardless of how many pedals are in the chain between send and return.
 *
 * For the new connection and all existing connections, we check both endpoints:
 * - On the new connection's TARGET instance: does the cycle exit that device
 *   (via an existing connection's sourceJackId) through a jack that shares
 *   group_id with the new connection's entry jack (targetJackId)?
 * - On the new connection's SOURCE instance: does the cycle enter that device
 *   (via an existing connection's targetJackId) through a jack that shares
 *   group_id with the new connection's exit jack (sourceJackId)?
 */
function isSendReturnLoop(
  sourceInstanceId: string,
  targetInstanceId: string,
  newSourceJackId: number | string,
  newTargetJackId: number | string,
  existingConnections: AudioConnection[],
  jackLookup: ReadonlyMap<number, { group_id: string | null }>,
): boolean {
  // Check the new connection's TARGET instance (where the cycle closes).
  // The new connection enters this device via newTargetJackId.
  // Look for existing connections where this device is the source (the exit point).
  const entryJack = typeof newTargetJackId === 'number' ? jackLookup.get(newTargetJackId) : null;
  if (entryJack?.group_id) {
    for (const conn of existingConnections) {
      if (conn.sourceInstanceId === targetInstanceId) {
        const exitJack = typeof conn.sourceJackId === 'number' ? jackLookup.get(conn.sourceJackId) : null;
        if (exitJack?.group_id && exitJack.group_id === entryJack.group_id) {
          return true;
        }
      }
    }
  }

  // Check the new connection's SOURCE instance (the other closing point).
  // The new connection exits this device via newSourceJackId.
  // Look for existing connections where this device is the target (the entry point).
  const exitJack = typeof newSourceJackId === 'number' ? jackLookup.get(newSourceJackId) : null;
  if (exitJack?.group_id) {
    for (const conn of existingConnections) {
      if (conn.targetInstanceId === sourceInstanceId) {
        const connEntryJack = typeof conn.targetJackId === 'number' ? jackLookup.get(conn.targetJackId) : null;
        if (connEntryJack?.group_id && connEntryJack.group_id === exitJack.group_id) {
          return true;
        }
      }
    }
  }

  return false;
}
```

### 2. Update `validateAudioConnection` signature

Add `newSourceJackId`, `newTargetJackId`, and `jackLookup` parameters:

```ts
export function validateAudioConnection(
  sourceJack: { connector_type: string | null; group_id: string | null; impedance_ohms: number | null },
  targetJack: { connector_type: string | null; group_id: string | null; impedance_ohms: number | null },
  sourceSignalMode: 'mono' | 'stereo',
  targetSignalMode: 'mono' | 'stereo',
  existingConnections: AudioConnection[],
  sourceInstanceId: string,
  targetInstanceId: string,
  newSourceJackId: number | string,
  newTargetJackId: number | string,
  jackLookup: ReadonlyMap<number, { group_id: string | null }>,
): ConnectionValidation {
```

Update the circular connection check:

```ts
  if (wouldCreateCycle(sourceInstanceId, targetInstanceId, existingConnections)) {
    if (isSendReturnLoop(sourceInstanceId, targetInstanceId, newSourceJackId, newTargetJackId, existingConnections, jackLookup)) {
      warnings.push({
        key: 'audio:send-return-loop',
        severity: 'info',
        message: 'This connection completes a send/return loop — this is expected topology.',
      });
    } else {
      warnings.push({
        key: 'audio:circular-connection',
        severity: 'error',
        message: 'This connection would create a feedback loop in the signal chain.',
      });
    }
  }
```

### 3. Update `AudioView.tsx` call site

The AudioView already has a `jackMap: Map<number, Jack>` which satisfies `ReadonlyMap<number, { group_id: string | null }>`. Pass `sourceJackId`, `targetJackId`, and `jackMap` to the updated `validateAudioConnection`.

### 4. Add tests

```ts
// Test: simple send/return loop (2 devices) returns info, not error
it('returns info for simple send/return loop (not error)', () => {
  // Existing: Switcher(Send, group_id=loop1) → Pedal(Input)
  // New: Pedal(Output) → Switcher(Return, group_id=loop1)
  // Entry/exit jacks on switcher share group_id → send/return → info
});

// Test: multi-pedal chain in send/return loop returns info, not error
it('returns info for multi-pedal send/return chain (not error)', () => {
  // Existing: Switcher(Send, group_id=loop1) → PedalB(Input), PedalB(Output) → PedalC(Input)
  // New: PedalC(Output) → Switcher(Return, group_id=loop1)
  // Entry/exit jacks on switcher share group_id → send/return → info
});

// Test: genuine cycle still returns error
it('returns error for genuine feedback loop', () => {
  // Existing: A(Output) → B(Input)
  // New: B(Output) → A(Input), jacks on A do NOT share group_id
});

// Test: send/return with virtual/placeholder jacks (string IDs) falls through to error
it('returns error when cycle involves virtual jacks (no group_id available)', () => {
  // Virtual jacks have string IDs, jackLookup won't find them
});
```

## Verification

1. `npm run web:build` — no compilation errors
2. `npm run web:test` — all tests pass including new send/return tests
3. Manual check: connect a pedal into a loop switcher's send/return in AudioView — should show info badge, not error
4. Manual check: create a genuine feedback loop (A output → B input, B output → A input on non-paired jacks) — should still show error
