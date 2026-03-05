# Extract Shared Cycle Detection (Refactor #1)

## Context

`wouldCreateCycle()` in `audioUtils.ts:26-49` and `wouldCreateMidiCycle()` in `midiUtils.ts:35-58` are character-for-character identical BFS implementations. Both check whether adding an edge `source -> target` would create a cycle by doing BFS from `target` to see if `source` is reachable. Having two copies means a bug fix in one could be missed in the other.

**Known bug (out of scope):** The audio cycle detection has a false positive with loop switcher send/return connections. That fix will only affect audio validation logic and is a separate task. This refactor extracts the shared algorithm without changing behavior.

## Approach

Add the shared `wouldCreateCycle` function and a `DirectedEdge` interface to `connectionValidation.ts`, which already serves as the shared module for all connection validation types. Remove the local copies from `audioUtils.ts` and `midiUtils.ts`, replacing them with imports and re-exports to maintain backward compatibility.

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
- Add re-export: `export { wouldCreateCycle } from './connectionValidation';`
- The call at line 65 (`validateAudioConnection`) stays unchanged — same name, same signature

### 3. `apps/web/src/utils/midiUtils.ts`

- Add `wouldCreateCycle` to the import from `'./connectionValidation'` (line 3)
- Delete the local `wouldCreateMidiCycle` function (lines 33-58, including the `// --- Cycle detection ---` comment)
- Update the call at line 125: `wouldCreateMidiCycle(...)` -> `wouldCreateCycle(...)`
- Add alias re-export for backward compatibility: `export { wouldCreateCycle as wouldCreateMidiCycle } from './connectionValidation';`

### 4. Test files — no changes needed

- `__tests__/utils/audioUtils.test.ts` imports `wouldCreateCycle` from `audioUtils` — the re-export keeps this working
- `__tests__/utils/midiUtils.test.ts` imports `wouldCreateMidiCycle` from `midiUtils` — the alias re-export keeps this working

## Verification

1. `npm run web:test` — all existing tests pass with zero test file changes
2. `npm run web:build` — no TypeScript errors
