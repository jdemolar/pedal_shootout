# Plan: Voltage setting notice for adjustable power supply outputs

## Context

When a user connects a pedal to a power supply output that has selectable/adjustable voltage (e.g., `9V/12V/18V`), there's no indication that the user needs to physically set that port to the correct voltage. This change adds an informational notice in the warning popover telling the user which voltage to select, with its own dismiss button. Additionally, the existing single "I have this adapter" button that bulk-acknowledges all warnings will be replaced with per-warning dismiss buttons.

## Files to modify

1. **`apps/web/src/utils/powerUtils.ts`** — Add voltage-setting notice detection to `validateConnection()`
2. **`apps/web/src/components/Workbench/PowerView.tsx`** — Update warning popover to show per-warning dismiss buttons

## Implementation

### 1. Detect adjustable output + specific pedal need (`powerUtils.ts`)

In `validateConnection()`, after the existing voltage compatibility check passes, add a new check:

- If the supply output jack has **multiple voltage tokens** (e.g., `"9V/12V/18V"` → 3 tokens) or a **voltage range** (e.g., `"9-18V"`)...
- ...and the consumer input jack has a **single specific voltage** (e.g., `"9V"` → 1 token)...
- ...and the voltages ARE compatible (no error)...
- → Push a notice: `"This output is adjustable — set it to 9V for this pedal"`

Use the existing `voltageTokensFromJack()` helper to count tokens and detect ranges. This reuses the existing warning infrastructure — it's just another string in the `warnings[]` array, which means the existing acknowledge system handles it automatically.

### 2. Per-warning dismiss buttons in popover (`PowerView.tsx`)

Replace the current popover layout (all warnings listed + one "I have this adapter" button) with:

- Each warning gets its own row containing the warning text and a dismiss button
- **Adapter warnings** (polarity/connector mismatch): dismiss button says **"I have this adapter"**
- **Voltage setting notices** (the new one): dismiss button says **"Got it"** (or similar)
- Remove the single bulk-acknowledge button
- Keep the "Close" button to dismiss the popover without acknowledging

To distinguish button labels, check if the warning string starts with `"This output is adjustable"` (the new notice prefix). Everything else uses "I have this adapter".

### 3. No changes needed to WorkbenchContext

The existing `acknowledgeWarning(connId, warningKey)` function already stores individual warning strings in `acknowledgedWarnings[]`. The existing `isAcknowledged` check in PowerView already requires ALL warnings to be acknowledged before the line goes dotted. This naturally means the new voltage notice must also be dismissed.

## Verification

1. Run `npm run web:build` (via nvm) to verify compilation
2. Run `npm run web:test` (via nvm) to verify tests pass
3. Manual check: connect a pedal (e.g., 9V pedal) to a supply output with selectable voltage (e.g., `9V/12V/18V`) — popover should show the voltage notice with its own dismiss button
4. Verify that the connection line stays solid (not dotted) until ALL warnings including the voltage notice are individually dismissed
