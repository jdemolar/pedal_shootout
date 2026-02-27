# Move MIDI Channel & Clock from Connection to Device Level

## Context

MIDI channel and clock send/receive are device-level settings, not connection (cable) properties. A cable doesn't filter channels — the device itself is configured to send/receive on a specific channel. Similarly, clock send/receive is a per-device setting. The current implementation stores `midiChannel` and `carriesClock` on `MidiConnection`, which is incorrect.

---

## Files to Modify

| File | Change |
|---|---|
| `apps/web/src/types/connections.ts` | Add `MidiDeviceSettings` type, remove `midiChannel`/`carriesClock` from `MidiConnection` |
| `apps/web/src/context/WorkbenchContext.tsx` | Add `midiDeviceSettings` to Workbench, add `updateMidiDeviceSettings` method, simplify `updateMidiConnection` |
| `apps/web/src/components/Workbench/MidiView.tsx` | Move channel/clock UI from connection badge to device card; keep TRS standard on connection badge |
| `apps/web/src/__tests__/utils/midiUtils.test.ts` | Remove `midiChannel`/`carriesClock` from `makeMidiConn` helper |

---

## Step 1: `types/connections.ts`

Add new type:
```typescript
export interface MidiDeviceSettings {
  midiChannel: number | null;    // 1–16, null = omni
  sendsClock: boolean;           // device sends MIDI clock
  receivesClock: boolean;        // device receives MIDI clock
}
```

Remove from `MidiConnection`:
- `midiChannel` (move to device settings)
- `carriesClock` (split into `sendsClock`/`receivesClock` on device settings)

`MidiConnection` becomes:
```typescript
export interface MidiConnection {
  id: string;
  sourceJackId: number;
  targetJackId: number;
  sourceInstanceId: string;
  targetInstanceId: string;
  acknowledgedWarnings?: string[];
  chainIndex: number;
  trsMidiStandard: 'TRS-A' | 'TRS-B' | 'tip-active' | 'ring-active' | null;
}
```

Note: `carriesClock` splits into two fields because clock send and receive are independent settings. A controller might send clock but not receive it; a delay pedal might receive clock but not send it.

---

## Step 2: `WorkbenchContext.tsx`

Add to `Workbench` interface:
```typescript
midiDeviceSettings?: { [instanceId: string]: MidiDeviceSettings };
```

This follows the existing `viewPositions` pattern: `{ [viewMode]: { [instanceId]: data } }`.

Add context method:
```typescript
updateMidiDeviceSettings: (instanceId: string, settings: Partial<MidiDeviceSettings>) => void;
```

Simplify `updateMidiConnection` — remove `midiChannel` and `carriesClock` from the `Partial<Pick<...>>`:
```typescript
updateMidiConnection: (connId: string, updates: Partial<Pick<MidiConnection, 'trsMidiStandard'>>) => void;
```

Implementation of `updateMidiDeviceSettings` follows the `updateActiveWorkbench` pattern:
```typescript
const updateMidiDeviceSettings = useCallback((instanceId: string, settings: Partial<MidiDeviceSettings>) => {
  updateActiveWorkbench(wb => {
    const current = wb.midiDeviceSettings ?? {};
    const existing = current[instanceId] ?? { midiChannel: null, sendsClock: false, receivesClock: false };
    return {
      ...wb,
      midiDeviceSettings: {
        ...current,
        [instanceId]: { ...existing, ...settings },
      },
    };
  });
}, [updateActiveWorkbench]);
```

---

## Step 3: `MidiView.tsx`

### Device settings display
- Show channel and clock settings **on each device card** (not on connection lines)
- Below the device name in each card, render a small label: e.g. "Ch 5 | Clock TX" or "Omni"
- Double-click the label (or the card) to open an edit popover anchored to the card

### Device settings edit popover
When a device card is selected/double-clicked, show an HTML overlay with:
- **Channel** dropdown (Omni / 1–16) — same UI as current badge
- **Sends Clock** checkbox
- **Receives Clock** checkbox

### Connection badge (simplified)
The connection badge (shown when clicking a connection line) now only shows:
- **TRS standard** selector (only when connection involves TRS connectors)
- Remove channel dropdown and clock checkbox from connection badge

### Duplicate channel warning
Currently computed at render-time by scanning connections. Update to scan `midiDeviceSettings` instead — warn when two devices connected to the same source share a channel.

---

## Step 4: Update tests

- Remove `midiChannel` and `carriesClock` from `makeMidiConn` helper in `midiUtils.test.ts`
- Existing validation tests don't reference these fields so should pass without changes

---

## Verification

1. `npm run web:test` — all tests pass
2. `npm run web:build` — compiles cleanly
3. Manual: device cards show channel/clock labels
4. Manual: double-click a device card → settings popover with channel, send clock, receive clock
5. Manual: clicking a connection line only shows TRS standard (for TRS connectors)
6. Manual: duplicate channel warning still works based on device settings
