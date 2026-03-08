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

The fix has two parts:

**Part A — Populate `fxLoopGroupId` on connections.** When the user creates a connection where one endpoint is a loop switcher's send or return jack (identifiable by `group_id` linking send/return pairs), set `fxLoopGroupId` on the connection. This tags the connection as part of a send/return loop.

**Part B — Make cycle detection aware of send/return pairs.** When `validateAudioConnection` detects a cycle, check whether all connections forming the cycle are part of the same FX loop group. If so, downgrade from `error` to `info`.

However, Part A requires UI changes to the AudioView connection creation flow and potentially jack metadata lookups, which adds scope. A simpler approach that achieves the same result without needing `fxLoopGroupId`:

**Simplified approach — Check if the cycle involves a loop switcher's paired send/return jacks.** When a cycle is detected, trace the cycle path and check whether the connections use jacks that share a `group_id` on the same device (i.e., a send/return pair). If the cycle passes through a send/return pair, it's an intentional loop topology.

After reviewing the complexity tradeoffs, the simplest correct fix is:

**Final approach — Exempt connections between jacks that share a `group_id` on the same instance.** A send/return loop always involves two connections to the same device where one jack is the send (output) and the other is the return (input), linked by `group_id`. When checking for cycles, if the proposed connection's source and target jacks share a `group_id` with existing connection jacks on the same instance, it's a send/return pair.

Actually, the simplest approach: pass jack info into the validator and check whether the source jack and target jack of the **new** connection correspond to the return and send of a loop on the same device. But connections go between *different* devices, so that doesn't apply directly.

Let me re-examine the actual scenario:

```
Loop Switcher (instance A):
  - Loop 1 Send (output, group_id = "loop-1")
  - Loop 1 Return (input, group_id = "loop-1")

Pedal (instance B):
  - Audio Input
  - Audio Output

Connections:
  1. A (Send) → B (Input)     [sourceInstanceId=A, targetInstanceId=B]
  2. B (Output) → A (Return)  [sourceInstanceId=B, targetInstanceId=A]
```

When connection 2 is being created, the BFS from A finds A→B (via connection 1), so it reports a cycle. The key distinguishing feature: the two connections to the loop switcher (A) use jacks that share a `group_id` — Send and Return are paired. A genuine feedback loop would connect to unrelated jacks.

### Implementation approach

When `wouldCreateCycle` returns `true`, perform a secondary check: trace the cycle and determine if the connections touching the same device use jacks from a send/return pair (same `group_id`). This requires passing jack information into the validation.

Concretely:
1. Add a new function `isSendReturnLoop` that checks whether a detected cycle is actually a send/return topology
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

This function checks whether a cycle between two instances is caused by a send/return pair on one of the devices.

```ts
/**
 * Check if a detected cycle between sourceInstanceId and targetInstanceId
 * is actually a send/return loop (not a genuine feedback loop).
 *
 * A send/return loop exists when two connections between the same pair of
 * instances use jacks that share a group_id on one device — meaning one
 * connection uses the "send" jack and the other uses the "return" jack
 * of the same FX loop.
 */
function isSendReturnLoop(
  sourceInstanceId: string,
  targetInstanceId: string,
  newSourceJackId: number | string,
  newTargetJackId: number | string,
  existingConnections: AudioConnection[],
  jackLookup: ReadonlyMap<number, { group_id: string | null }>,
): boolean {
  // Find existing connections that go in the opposite direction
  // (targetInstanceId → sourceInstanceId) — these complete the "loop"
  const reverseConnections = existingConnections.filter(
    c => c.sourceInstanceId === targetInstanceId && c.targetInstanceId === sourceInstanceId,
  );

  if (reverseConnections.length === 0) return false;

  // For each reverse connection, check if the jacks on the shared device(s)
  // form a send/return pair (same group_id)
  for (const rev of reverseConnections) {
    // On the source instance (loop switcher side of the new connection):
    // - The new connection uses newSourceJackId (we're connecting FROM this device)
    // - The reverse connection uses rev.targetJackId (it connects TO this device)
    // If these two jacks share a group_id → send/return pair on source instance
    const srcNewJack = typeof newSourceJackId === 'number' ? jackLookup.get(newSourceJackId) : null;
    const srcRevJack = typeof rev.targetJackId === 'number' ? jackLookup.get(rev.targetJackId) : null;
    if (
      srcNewJack?.group_id && srcRevJack?.group_id &&
      srcNewJack.group_id === srcRevJack.group_id
    ) {
      return true;
    }

    // Same check on the target instance side:
    // - The new connection uses newTargetJackId (connecting TO this device)
    // - The reverse connection uses rev.sourceJackId (it connects FROM this device)
    const tgtNewJack = typeof newTargetJackId === 'number' ? jackLookup.get(newTargetJackId) : null;
    const tgtRevJack = typeof rev.sourceJackId === 'number' ? jackLookup.get(rev.sourceJackId) : null;
    if (
      tgtNewJack?.group_id && tgtRevJack?.group_id &&
      tgtNewJack.group_id === tgtRevJack.group_id
    ) {
      return true;
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
// Test: send/return loop returns info, not error
it('returns info for send/return loop (not error)', () => {
  // Existing connection: Switcher(Send, group_id=loop1) → Pedal(Input)
  // New connection: Pedal(Output) → Switcher(Return, group_id=loop1)
  // The jacks on the switcher share group_id → send/return pair
});

// Test: genuine cycle still returns error
it('returns error for genuine feedback loop', () => {
  // Existing: A→B
  // New: B→A, but jacks on shared device do NOT share group_id
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
