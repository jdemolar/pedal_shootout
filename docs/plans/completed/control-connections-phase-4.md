# Phase 4: Control Connections View

## Context

This is Phase 4 of the connections & cabling roadmap (`docs/plans/connections-and-cabling.md`). It adds a canvas view for expression pedals, aux switches, and CV connections — the control signals that let external controllers modify pedal parameters.

Control connections are fundamentally point-to-point: an expression pedal connects to a target's expression input, an external footswitch connects to an aux input. Unlike MIDI (chains/hubs) or audio (signal chains), control connections don't form graphs — each is an independent pair.

**Current data:** The database has 22 expression input jacks, 9 aux input jacks, 15 aux output jacks (including 5 USB-A which should be excluded), and 0 CV jacks. Expression pedals (the source side) don't yet have formal expression output jacks in the DB, so the view must handle items that only have control inputs.

---

## Files to Create

| File | Purpose |
|---|---|
| `apps/web/src/utils/controlUtils.ts` | Jack filtering helpers + `validateControlConnection` |
| `apps/web/src/components/Workbench/ControlView.tsx` | Canvas view for control connections |
| `apps/web/src/__tests__/utils/controlUtils.test.ts` | Tests for control validation logic |

## Files to Modify

| File | Change |
|---|---|
| `apps/web/src/types/connections.ts` | Expand `ControlConnection` stub to full spec |
| `apps/web/src/context/WorkbenchContext.tsx` | Add `controlConnections` to Workbench + CRUD methods |
| `apps/web/src/components/Workbench/ViewNav.tsx` | Enable Control tab |
| `apps/web/src/components/Workbench/index.tsx` | Add `case 'control'` to view routing + import |

---

## Step 1: Expand `ControlConnection` type (`types/connections.ts`)

Replace the stub with the full type. The design doc specifies `trsPolarity` instead of the stub's `polarityNormal` — use `trsPolarity` since it captures the actual physical wiring, not just a boolean.

Keep `'other'` in `controlType` (the stub already has it) as a catch-all for uncommon control connections.

```typescript
export interface ControlConnection {
  id: string;
  sourceJackId: number;
  targetJackId: number;
  sourceInstanceId: string;
  targetInstanceId: string;
  acknowledgedWarnings?: string[];
  controlType: 'expression' | 'aux_switch' | 'cv' | 'other';
  trsPolarity: 'tip-active' | 'ring-active' | null;  // replaces polarityNormal
}
```

Fields deferred (not needed for initial canvas view):
- `controlledParameter` — future: which parameter is being controlled
- `rangeMin` / `rangeMax` — future: for parameter range clamping
- `auxSwitchAssignments` — future: per-contact function names
- `cvVoltageRange` — future: voltage range spec

These can be added later when the Control view gets parameter assignment UI. The initial view focuses on physical connections and polarity validation.

---

## Step 2: WorkbenchContext (`WorkbenchContext.tsx`)

### Add to Workbench interface

```typescript
controlConnections?: ControlConnection[];
```

### Add to WorkbenchContextType interface

```typescript
// Control connections
addControlConnection: (conn: Omit<ControlConnection, 'id'>) => void;
removeControlConnection: (connId: string) => void;
setControlConnections: (conns: ControlConnection[]) => void;
acknowledgeControlWarning: (connId: string, warningKey: string) => void;
updateControlConnection: (connId: string, updates: Partial<Pick<ControlConnection, 'trsPolarity'>>) => void;
```

### Implementation

Follow the exact pattern of the MIDI connection methods. Each is a `useCallback` wrapping `updateStore(prev => updateActiveWorkbench(prev, wb => ...))`.

Add `ControlConnection` to the import from `types/connections.ts`.

Add all five methods to the `value` useMemo and its dependency array.

---

## Step 3: `controlUtils.ts`

### Jack filtering helpers

```typescript
const CONTROL_CATEGORIES = ['expression', 'aux', 'cv'];

export function getControlInputJacks(row: { jacks: Jack[] }): Jack[] {
  return row.jacks.filter(j =>
    CONTROL_CATEGORIES.includes(j.category ?? '') &&
    (j.direction === 'input' || j.direction === 'bidirectional')
  );
}

export function getControlOutputJacks(row: { jacks: Jack[] }): Jack[] {
  return row.jacks.filter(j =>
    CONTROL_CATEGORIES.includes(j.category ?? '') &&
    (j.direction === 'output' || j.direction === 'bidirectional') &&
    j.connector_type !== 'USB-A'  // exclude USB storage ports
  );
}

export function hasControlJacks(row: { jacks: Jack[] }): boolean {
  return row.jacks.some(j => CONTROL_CATEGORIES.includes(j.category ?? ''));
}
```

### Category detection

```typescript
export function inferControlType(jack: { category: string | null }): ControlConnection['controlType'] {
  switch (jack.category) {
    case 'expression': return 'expression';
    case 'aux': return 'aux_switch';
    case 'cv': return 'cv';
    default: return 'other';
  }
}
```

### Validation (`validateControlConnection`)

```typescript
export function validateControlConnection(
  sourceJack: { category: string | null; connector_type: string | null; jack_name: string | null },
  targetJack: { category: string | null; connector_type: string | null; jack_name: string | null },
  existingConnections: ControlConnection[],
  sourceInstanceId: string,
  targetInstanceId: string,
  sourceJackId?: number,
  targetJackId?: number,
): ConnectionValidation
```

**Validation rules:**

| Rule | Severity | Key | Condition |
|---|---|---|---|
| Category mismatch | Error | `control:category-mismatch` | Source and target jack categories don't match (e.g., expression to aux) |
| Self-connection | Error | `control:self-connection` | Source and target are the same instance |
| Shared input | Warning | `control:shared-input` | Target jack already has a connection |
| Connector type mismatch | Warning | `control:connector-mismatch` | Different connector types (e.g., 1/4" TRS vs 3.5mm TRS) — adapter needed |
| Polarity unknown | Info | `control:polarity-unknown` | TRS connection where polarity hasn't been confirmed |

Notes:
- Category mismatch is an error because plugging an expression pedal into an aux input won't work.
- We don't validate polarity *mismatch* yet because TRS polarity data isn't stored per-jack. The `trsPolarity` field on `ControlConnection` is user-set. Future: when the `jacks` table gets a `trs_polarity` column, we can detect mismatches automatically.
- Circular connections are not checked — control connections are point-to-point, not chainable.

---

## Step 4: `ControlView.tsx`

### Layout approach

Since control connections are point-to-point (no chains/hubs), use a simpler layout than MIDI:

- **Items with control inputs** on the left (pedals/controllers that *receive* expression/aux/CV)
- **Items with control outputs** on the right (expression pedals, external footswitches)
- Items with both appear once, with ports on both sides

This keeps source→target flow consistent (right to left, matching audio convention).

### Canvas structure (follows MidiView pattern)

```
const VIEW_KEY = 'control';
```

**Port rendering:**
- Control input ports on the right side of the card (signal enters from right)
- Control output ports on the left side of the card (signal exits to left)
- Color coding: expression = teal, aux = orange, cv = yellow (distinct from MIDI's purple/blue)

Port colors:
```typescript
const CONTROL_PORT_COLORS: Record<string, string> = {
  expression: '#5aaa8a',  // teal
  aux: '#aa8a5a',         // orange
  cv: '#aaaa5a',          // yellow
};
```

### Interaction

Same click-to-connect pattern as MIDI/Audio/Power:
1. Click a source control output port
2. Click a target control input port
3. Connection created, validation runs

On connection creation, auto-detect `controlType` from the target jack's category using `inferControlType`.

### Selected connection overlay

Same as MIDI view (post-refactor):
- Floating `×` delete button at line midpoint (always)
- Popover with warnings + polarity selector (when the connection has warnings or is TRS)

### Polarity selector (in popover)

When a connection involves TRS connectors, show:
```
Polarity: [Tip Active] [Ring Active] [Unknown]
```

This sets `trsPolarity` on the `ControlConnection`.

### Missing items banner

Same pattern as MIDI: "N items not shown — no control jack data"

### Items that only have control inputs (no outputs)

Most items in the workbench will only have expression/aux *input* jacks (pedals that receive expression). These still need to be shown so users can connect to them. The view should show all items with any control jacks (inputs or outputs).

Items that are only *sources* (expression pedals, volume pedals with expression out) may not have formally tagged output jacks in the database yet. These items will appear in the "not shown" banner until their jacks are entered. This is acceptable for the initial implementation.

---

## Step 5: Tests (`controlUtils.test.ts`)

Follow the `midiUtils.test.ts` pattern. Test:

### Jack filtering
- `getControlInputJacks` — returns expression/aux/cv input and bidirectional jacks
- `getControlOutputJacks` — returns expression/aux/cv output and bidirectional jacks, excludes USB-A
- `hasControlJacks` — returns true/false based on jack categories

### Category inference
- `inferControlType` — maps jack categories to control types

### Validation
- Valid connection: matching categories, no existing connections
- Category mismatch: expression source → aux target → error
- Self-connection: same instance → error
- Shared input: target jack already connected → warning
- Connector mismatch: different connector types → warning with adapter implication
- No warnings for valid matching connections

### Helper

```typescript
function makeControlConn(overrides: Partial<ControlConnection> = {}): ControlConnection {
  return {
    id: 'conn-1',
    sourceJackId: 1,
    targetJackId: 2,
    sourceInstanceId: 'inst-a',
    targetInstanceId: 'inst-b',
    controlType: 'expression',
    trsPolarity: null,
    ...overrides,
  };
}
```

---

## Step 6: Enable the tab

### `ViewNav.tsx`
Change `enabled: false` to `enabled: true` for the Control tab.

### `Workbench/index.tsx`
Add import and case:
```typescript
import ControlView from './ControlView';

case 'control':
  return (
    <div className="workbench__content workbench__content--canvas">
      <ControlView rows={rows} />
    </div>
  );
```

---

## Verification

1. `npm run web:test` — all tests pass (including new controlUtils tests)
2. `npm run web:build` — compiles cleanly
3. Manual: Control tab is enabled and clickable
4. Manual: items with expression/aux jacks appear as cards
5. Manual: click-to-connect between control output and input ports
6. Manual: category mismatch connections are blocked (error)
7. Manual: connector mismatch shows warning with adapter implication
8. Manual: selected connection shows × delete button
9. Manual: TRS connections show polarity selector in popover
10. Manual: "N items not shown" banner for items without control jacks
