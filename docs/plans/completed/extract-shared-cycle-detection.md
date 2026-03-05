# Extract Shared Cycle Detection (Refactor #1)

## Context

`wouldCreateCycle()` in `audioUtils.ts:26-49` and `wouldCreateMidiCycle()` in `midiUtils.ts:35-58` are character-for-character identical BFS implementations. Both check whether adding an edge `source -> target` would create a cycle by doing BFS from `target` to see if `source` is reachable. Having two copies means a bug fix in one could be missed in the other.

**Known bug (out of scope):** The audio cycle detection has a false positive with loop switcher send/return connections. That fix will only affect audio validation logic and is a separate task. This refactor extracts the shared algorithm without changing behavior.

## Approach

Add the shared `wouldCreateCycle` function and a `DirectedEdge` interface to `connectionValidation.ts`, which already serves as the shared module for all connection validation types. Remove the local copies from `audioUtils.ts` and `midiUtils.ts`, and update all imports (including tests) to point at the new location. No re-exports needed — the function is only used in a handful of places.

## Files to Modify

### 1. `apps/web/src/utils/connectionValidation.ts`

Add after the existing type exports (after line 26):

```typescript
export interface DirectedEdge {
  sourceInstanceId: string;
  targetInstanceId: string;
}

export function wouldCreateCycle(
  sourceInstanceId: string,
  targetInstanceId: string,
  existingConnections: ReadonlyArray<DirectedEdge>,
): boolean {
  const visited = new Set<string>();
  const queue: string[] = [targetInstanceId];

  while (queue.length > 0) {
    const current = queue.shift()!;
    if (current === sourceInstanceId) return true;
    if (visited.has(current)) continue;
    visited.add(current);

    for (const conn of existingConnections) {
      if (conn.sourceInstanceId === current && !visited.has(conn.targetInstanceId)) {
        queue.push(conn.targetInstanceId);
      }
    }
  }

  return false;
}
```

Both `AudioConnection` and `MidiConnection` have `sourceInstanceId` and `targetInstanceId` fields, so they satisfy `DirectedEdge` structurally — no casts needed at call sites.

### 2. `apps/web/src/utils/audioUtils.ts`

- Add `wouldCreateCycle` to the import from `'./connectionValidation'` (line 3)
- Delete the local `wouldCreateCycle` function (lines 24-49, including the `// --- Cycle detection ---` comment)
- The call in `validateAudioConnection` stays unchanged — same name, same signature

### 3. `apps/web/src/utils/midiUtils.ts`

- Add `wouldCreateCycle` to the import from `'./connectionValidation'` (line 3)
- Delete the local `wouldCreateMidiCycle` function (lines 33-58, including the `// --- Cycle detection ---` comment)
- Update the call at line 125: `wouldCreateMidiCycle(...)` -> `wouldCreateCycle(...)`

### 4. `apps/web/src/__tests__/utils/audioUtils.test.ts`

- Move `wouldCreateCycle` from the `audioUtils` import to a new import from `connectionValidation`

### 5. `apps/web/src/__tests__/utils/midiUtils.test.ts`

- Remove `wouldCreateMidiCycle` from the `midiUtils` import
- Add import of `wouldCreateCycle` from `connectionValidation`
- Rename all `wouldCreateMidiCycle` calls to `wouldCreateCycle` (5 occurrences)
- Rename the `describe` block from `'wouldCreateMidiCycle'` to `'wouldCreateCycle'`

## Verification

1. `npm run web:test` — all existing tests pass
2. `npm run web:build` — no TypeScript errors
