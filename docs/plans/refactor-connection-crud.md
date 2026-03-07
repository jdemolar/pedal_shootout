# Refactor WorkbenchContext connection CRUD patterns

## Context

`apps/web/src/context/WorkbenchContext.tsx` has four connection types (power, audio, MIDI, control) that each implement the same four CRUD operations: add, remove, setAll, and acknowledgeWarning. Each operation is a `useCallback` that calls `updateStore` → `updateActiveWorkbench` with nearly identical logic. The only difference is the field name on the `Workbench` object (`powerConnections`, `audioConnections`, etc.).

This is refactoring opportunity #5 from `docs/plans/refactoring-opportunities.md`.

### What's identical (4 operations × 4 types = 16 callbacks → 4)

| Operation | Pattern |
|---|---|
| `add` | Spread conn, add `id: generateId()`, append to array |
| `remove` | Filter array by `c.id !== connId` |
| `setAll` | Replace entire array |
| `acknowledgeWarning` | Map over array, find by id, append `warningKey` to `acknowledgedWarnings` |

### What stays as standalone callbacks (type-specific)

These operations are unique to their connection type and don't benefit from the factory:

- `updateAudioConnectionWaypoints` — updates `waypoints` on a specific audio connection
- `updateMidiConnection` — partial update of MIDI-specific fields (`trsMidiStandard`)
- `updateMidiDeviceSettings` — operates on `midiDeviceSettings` map, not the connections array
- `updateControlConnection` — partial update of control-specific fields (`trsPolarity`)

## Approach

Add a `makeConnectionOps` factory function inside `WorkbenchProvider` (it needs access to `updateStore`). Each call returns the four common operations bound to a specific `Workbench` field. The factory replaces 16 `useCallback` definitions with 4 factory calls + 4 destructurings.

## Files to Modify

| File | Change |
|---|---|
| `apps/web/src/context/WorkbenchContext.tsx` | Add factory, replace 16 callbacks with 4 factory calls, rename `acknowledgeWarning` → `acknowledgePowerWarning` |
| `apps/web/src/components/Workbench/PowerView.tsx` | Update 2 references: destructure and click handler |

No new files needed — the factory is a private function inside the provider.

### Prerequisite: Rename `acknowledgeWarning` → `acknowledgePowerWarning`

The power connection's acknowledge function is named `acknowledgeWarning` (no type prefix) because it was created first, before the other connection types were added. The other three use prefixed names (`acknowledgeAudioWarning`, `acknowledgeMidiWarning`, `acknowledgeControlWarning`). Rename it for consistency before applying the factory.

**`WorkbenchContext.tsx` changes:**
- Interface `WorkbenchContextType`: rename `acknowledgeWarning` → `acknowledgePowerWarning`
- The `useCallback` definition (or factory destructure) and the `value` object

**`PowerView.tsx` changes (only consumer):**
- Line 61: destructure `acknowledgePowerWarning` instead of `acknowledgeWarning`
- Line 577: `onClick={() => acknowledgePowerWarning(...)}`

## Implementation

### 1. Define the factory inside `WorkbenchProvider`

Place this right after the `updateStore` definition (after line 239), before the connection sections:

```typescript
/** Factory for the 4 common connection CRUD operations on a Workbench array field. */
function makeConnectionOps<T extends { id: string; acknowledgedWarnings?: string[] }>(
  field: keyof Workbench & ('powerConnections' | 'audioConnections' | 'midiConnections' | 'controlConnections'),
) {
  const add = (conn: Omit<T, 'id'>) => {
    updateStore(prev => updateActiveWorkbench(prev, wb => ({
      ...wb,
      [field]: [...((wb[field] as T[] | undefined) || []), { ...conn, id: generateId() }],
      updatedAt: new Date().toISOString(),
    })));
  };

  const remove = (connId: string) => {
    updateStore(prev => updateActiveWorkbench(prev, wb => ({
      ...wb,
      [field]: ((wb[field] as T[] | undefined) || []).filter(c => c.id !== connId),
      updatedAt: new Date().toISOString(),
    })));
  };

  const setAll = (conns: T[]) => {
    updateStore(prev => updateActiveWorkbench(prev, wb => ({
      ...wb,
      [field]: conns,
      updatedAt: new Date().toISOString(),
    })));
  };

  const acknowledgeWarning = (connId: string, warningKey: string) => {
    updateStore(prev => updateActiveWorkbench(prev, wb => ({
      ...wb,
      [field]: ((wb[field] as T[] | undefined) || []).map(c =>
        c.id === connId
          ? { ...c, acknowledgedWarnings: [...(c.acknowledgedWarnings || []), warningKey] }
          : c,
      ),
      updatedAt: new Date().toISOString(),
    })));
  };

  return { add, remove, setAll, acknowledgeWarning };
}
```

### 2. Replace the 16 callbacks with 4 factory calls

Replace the power, audio, MIDI, and control connection sections (lines 368–563) with:

```typescript
// --- Connection CRUD (factory-generated) ---

const {
  add: addPowerConnection,
  remove: removePowerConnection,
  setAll: setPowerConnections,
  acknowledgeWarning: acknowledgePowerWarning,
} = useMemo(() => makeConnectionOps<PowerConnection>('powerConnections'), [updateStore]);

const {
  add: addAudioConnection,
  remove: removeAudioConnection,
  setAll: setAudioConnections,
  acknowledgeWarning: acknowledgeAudioWarning,
} = useMemo(() => makeConnectionOps<AudioConnection>('audioConnections'), [updateStore]);

const {
  add: addMidiConnection,
  remove: removeMidiConnection,
  setAll: setMidiConnections,
  acknowledgeWarning: acknowledgeMidiWarning,
} = useMemo(() => makeConnectionOps<MidiConnection>('midiConnections'), [updateStore]);

const {
  add: addControlConnection,
  remove: removeControlConnection,
  setAll: setControlConnections,
  acknowledgeWarning: acknowledgeControlWarning,
} = useMemo(() => makeConnectionOps<ControlConnection>('controlConnections'), [updateStore]);
```

The four type-specific callbacks (`updateAudioConnectionWaypoints`, `updateMidiConnection`, `updateMidiDeviceSettings`, `updateControlConnection`) remain as standalone `useCallback` definitions immediately after.

### 3. Update the `useMemo` dependency array for `value`

The 16 replaced callbacks are now derived from `useMemo` instead of `useCallback`. The dependency array for `value` should still list all the same names — they're just sourced differently. Update `acknowledgeWarning` → `acknowledgePowerWarning` in the context interface, context value object, and the `useMemo` dependency array.

## Verification

1. `npm run web:build` from project root — no compilation errors
2. `npm run web:test` — all tests pass
3. Manual smoke test: open the app, verify power/audio/MIDI/control connections still work (add, remove, acknowledge warning)
4. Check off item #5 in `docs/plans/refactoring-opportunities.md`
5. Move this plan to `docs/plans/completed/`
