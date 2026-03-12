# TRS Multi-Connection Support for Stereo Pairs

## Context

The Audio connections view supports stereo pair auto-connection: when both the source and target jacks have stereo partners (detected via shared `group_id`), the UI offers a "Connect as stereo pair?" prompt and creates two `AudioConnection` objects — one for each channel.

This works correctly when both sides have **discrete L/R jacks** (e.g., two 1/4" TS outputs → two 1/4" TS inputs). But it breaks when one side uses a **single TRS jack** to carry both channels (tip = left, ring = right), which is common on loop switcher send/return jacks.

### Current behavior

The stereo detection at `AudioView.tsx:430–435` requires **both sides** to have a stereo partner:

```ts
const srcHasStereo = srcJack && srcJack.group_id !== null && !!getStereoPartner(srcJack, srcRow.jacks);
const tgtHasStereo = tgtJack && tgtJack.group_id !== null && !!getStereoPartner(tgtJack, tgtRow.jacks);
if (srcHasStereo && tgtHasStereo) { /* show prompt */ }
```

A single TRS jack has no stereo partner (no second jack with the same `group_id`), so the prompt never appears. If the user connects manually, the handler at `AudioView.tsx:491` also requires both sides to have partners to create the second connection.

### The problem

When connecting a loop switcher's TRS send jack to a stereo pedal with discrete L/R inputs:
- The TRS side has **one jack** carrying two signals — no partner exists
- The pedal side has **two jacks** with shared `group_id`
- The stereo prompt doesn't appear, or if forced, the second connection has no jack to use on the TRS side

### Real-world cable topology

A TRS-to-2×TS insert cable is used:
- **Send:** TRS tip → Left input (TS), TRS ring → Right input (TS)
- **Return:** Left output (TS) → TRS tip, Right output (TS) → TRS ring

Both connections on the TRS side share the **same physical jack** — this is electrically correct because TRS has three conductors.

## Goals

1. **Detect asymmetric stereo pairs** — when one side has a TRS jack (no partner) and the other has discrete L/R jacks (with partner), offer the stereo pair prompt
2. **Reuse the TRS jack** — create two connections where the TRS side uses the same jack ID for both
3. **Derive correct cable type** — the shopping list should show "TRS to 2×TS insert cable" instead of two separate patch cables
4. No changes to the database schema or API

## Files to modify

| File | Change |
|---|---|
| `apps/web/src/components/Workbench/AudioView.tsx` | Update stereo detection to handle asymmetric TRS↔discrete pairs; update `handleStereoConfirm` to reuse TRS jack |
| `apps/web/src/utils/audioUtils.ts` | Add `isTrsConnector` helper (or import from controlUtils) |
| `apps/web/src/utils/shoppingListUtils.ts` | Detect TRS↔TS insert cable pattern and derive correct label |
| `apps/web/src/__tests__/utils/shoppingListUtils.test.ts` | Add tests for insert cable detection |
| `apps/web/src/__tests__/utils/audioUtils.test.ts` | Add tests if any new audio util functions are added |

## Step-by-step implementation

### Step 1: Add a shared `isTrsConnector` helper

`controlUtils.ts` already has `isTrsConnector`. Rather than importing across util boundaries, add the same one-liner to `audioUtils.ts` (it's a pure string check, not worth creating a shared module for):

```ts
function isTrsConnector(connectorType: string | null): boolean {
  if (!connectorType) return false;
  return connectorType.toLowerCase().includes('trs');
}
```

### Step 2: Update stereo detection in `AudioView.tsx`

Currently (lines 430–437):
```ts
const srcHasStereo = (srcJack && srcRow && ...) || placeholderHasStereoPartner(...);
const tgtHasStereo = (tgtJack && tgtRow && ...) || placeholderHasStereoPartner(...);
if (srcHasStereo && tgtHasStereo) { /* prompt */ }
```

Add detection for TRS jacks that can carry stereo without a partner. A TRS jack qualifies for stereo pairing if:
- It is a TRS connector type (`isTrsConnector` returns true)
- The **other** side has a discrete stereo pair (partner exists via `group_id`)

```ts
// Existing checks
const srcHasStereo = /* ... unchanged ... */;
const tgtHasStereo = /* ... unchanged ... */;

// NEW: TRS jack on one side can pair with discrete stereo on the other
const srcIsTrs = srcJack && isTrsConnector(srcJack.connector_type);
const tgtIsTrs = tgtJack && isTrsConnector(tgtJack.connector_type);

const canStereoPair =
  (srcHasStereo && tgtHasStereo) ||          // Both have discrete partners (existing)
  (srcIsTrs && tgtHasStereo) ||               // TRS source ↔ discrete stereo target
  (srcHasStereo && tgtIsTrs);                 // Discrete stereo source ↔ TRS target

// TRS-to-TRS: single cable carries both channels — no prompt needed, auto-stereo
const bothTrs = srcIsTrs && tgtIsTrs && !srcHasStereo && !tgtHasStereo;

if (bothTrs) {
  // Create a single stereo connection directly (no fan-out, one cable suffices)
  createConnection(sourceJackId, sourceInstanceId, targetJackId, targetInstanceId, 'stereo', null);
  setPendingSource(null);
  setMousePos(null);
} else if (canStereoPair) {
  /* show prompt */
}
```

Import `isTrsConnector` from `audioUtils.ts` (or inline the check).

### Step 3: Update `handleStereoConfirm` in `AudioView.tsx`

Currently (lines 467–500), the handler creates two connections and requires both sides to have partners. Update it to handle the asymmetric case where one side is TRS (reuse the same jack):

```ts
const handleStereoConfirm = useCallback((asStereo: boolean) => {
  if (!stereoPrompt) return;
  const { sourceJackId, sourceInstanceId, targetJackId, targetInstanceId } = stereoPrompt;

  if (asStereo) {
    const srcJack = typeof sourceJackId === 'number' ? jackMap.get(sourceJackId) : null;
    const tgtJack = typeof targetJackId === 'number' ? jackMap.get(targetJackId) : null;
    const srcRow = rowMap.get(sourceInstanceId);
    const tgtRow = rowMap.get(targetInstanceId);
    const srcPartner = srcJack && srcRow ? getStereoPartner(srcJack, srcRow.jacks) : undefined;
    const tgtPartner = tgtJack && tgtRow ? getStereoPartner(tgtJack, tgtRow.jacks) : undefined;

    // ... existing placeholder partner logic ...

    // Primary connection (always created)
    createConnection(sourceJackId, sourceInstanceId, targetJackId, targetInstanceId, 'stereo', null);

    // Partner connection — handle asymmetric TRS case
    const srcPartnerJackId = srcPartner?.id ?? srcPlaceholderPartner?.virtualJackId;
    const tgtPartnerJackId = tgtPartner?.id ?? tgtPlaceholderPartner?.virtualJackId;

    // Determine the second connection's jack IDs:
    // - If a side has a discrete partner, use the partner's jack ID
    // - If a side is TRS with no partner, reuse the same jack ID (TRS carries both channels)
    const secondSrcJackId = srcPartnerJackId
      ?? (srcJack && isTrsConnector(srcJack.connector_type) ? sourceJackId : undefined);
    const secondTgtJackId = tgtPartnerJackId
      ?? (tgtJack && isTrsConnector(tgtJack.connector_type) ? targetJackId : undefined);

    if (secondSrcJackId !== undefined && secondTgtJackId !== undefined) {
      createConnection(secondSrcJackId, sourceInstanceId, secondTgtJackId, targetInstanceId, 'stereo', null);
    }
  } else {
    createConnection(sourceJackId, sourceInstanceId, targetJackId, targetInstanceId, 'mono', null);
  }
  setStereoPrompt(null);
}, [stereoPrompt, jackMap, rowMap, placeholders, createConnection]);
```

The key insight: when the TRS side has no partner, `secondSrcJackId` (or `secondTgtJackId`) falls through to the `isTrsConnector` check and reuses the original jack ID. This means two `AudioConnection` objects share the same jack on the TRS side — which is electrically correct.

### Step 4: Update shopping list to detect insert cables

In `shoppingListUtils.ts`, the `computeShoppingList` function processes each audio connection independently. When two stereo-paired connections share a jack on one side (TRS) but use different jacks on the other (TS), they should be grouped as a single "insert cable" rather than two separate patch cables.

Add a post-processing step after the main connection loop:

```ts
/**
 * Detect TRS-to-2×TS insert cable patterns in audio connections.
 * When two stereo connections share the same jack on one side (TRS)
 * and use different jacks on the other (TS), they represent a single
 * insert cable rather than two separate patch cables.
 */
function consolidateInsertCables(
  audioConnections: AudioConnection[],
  jackMap: Map<number, Jack>,
  grouped: Map<string, CableRequirement>,
): void {
  // Find pairs of stereo connections that share a jack on one side
  const stereoConns = audioConnections.filter(c => c.signalMode === 'stereo');

  // Group by shared jack — key is the jack ID that appears in multiple connections
  const bySourceJack = new Map<number | string, AudioConnection[]>();
  const byTargetJack = new Map<number | string, AudioConnection[]>();
  for (const conn of stereoConns) {
    const srcGroup = bySourceJack.get(conn.sourceJackId) ?? [];
    srcGroup.push(conn);
    bySourceJack.set(conn.sourceJackId, srcGroup);

    const tgtGroup = byTargetJack.get(conn.targetJackId) ?? [];
    tgtGroup.push(conn);
    byTargetJack.set(conn.targetJackId, tgtGroup);
  }

  // Process pairs sharing a source jack (TRS output → 2× TS inputs)
  for (const [jackId, conns] of bySourceJack) {
    if (conns.length !== 2) continue;
    const jack = typeof jackId === 'number' ? jackMap.get(jackId) : null;
    if (!jack || !isTrsConnector(jack.connector_type)) continue;
    mergeAsInsertCable(conns, 'source', jack.connector_type!, jackMap, grouped);
  }

  // Process pairs sharing a target jack (2× TS outputs → TRS input)
  for (const [jackId, conns] of byTargetJack) {
    if (conns.length !== 2) continue;
    const jack = typeof jackId === 'number' ? jackMap.get(jackId) : null;
    if (!jack || !isTrsConnector(jack.connector_type)) continue;
    mergeAsInsertCable(conns, 'target', jack.connector_type!, jackMap, grouped);
  }
}

function mergeAsInsertCable(
  conns: AudioConnection[],
  sharedSide: 'source' | 'target',
  trsConnectorType: string,
  jackMap: Map<number, Jack>,
  grouped: Map<string, CableRequirement>,
): void {
  // Determine the TS connector type from the non-shared side
  const otherJackId = sharedSide === 'source' ? conns[0].targetJackId : conns[0].sourceJackId;
  const otherJack = typeof otherJackId === 'number' ? jackMap.get(otherJackId) : null;
  const tsConnectorType = otherJack?.connector_type ?? 'unknown';

  // Remove the two individual cable entries
  for (const conn of conns) {
    for (const [key, req] of grouped) {
      const idx = req.connectionIds.indexOf(conn.id);
      if (idx !== -1) {
        req.quantity -= 1;
        req.connectionIds.splice(idx, 1);
        if (req.quantity <= 0) grouped.delete(key);
        break;
      }
    }
  }

  // Add a single insert cable entry
  const insertKey = `audio::insert::${trsConnectorType}::${tsConnectorType}`;
  const label = `${trsConnectorType} to 2×${tsConnectorType} insert cable`;
  grouped.set(insertKey, {
    category: 'audio',
    sourceConnectorType: sharedSide === 'source' ? trsConnectorType : tsConnectorType,
    targetConnectorType: sharedSide === 'source' ? tsConnectorType : trsConnectorType,
    label,
    quantity: 1,
    connectionIds: conns.map(c => c.id),
    requiresCustomCable: true,
    notes: ['Insert cable — single TRS splits to two TS connections'],
  });
}
```

Call `consolidateInsertCables` inside `computeShoppingList`, after the main audio connection loop:

```ts
for (const conn of audioConnections) {
  processConnection(conn, 'audio', jackMap, grouped);
}
consolidateInsertCables(audioConnections, jackMap, grouped);
```

Import `isTrsConnector` from a shared location or inline the check. Since `shoppingListUtils.ts` doesn't currently import from `audioUtils.ts` or `controlUtils.ts`, the simplest approach is to add a local `isTrsConnector` (same one-liner).

### Step 5: Handle edge cases

**Multiple insert cables:** If two different TRS jacks each fan out to stereo pairs (e.g., a loop switcher with two stereo loops), `consolidateInsertCables` handles them independently since each TRS jack groups separately.

**TRS-to-TRS stereo:** If both sides are TRS with no discrete partners, a single TRS-to-TRS cable carries both channels. The `bothTrs` check (Step 2) handles this by auto-creating a single connection with `signalMode: 'stereo'` — no prompt, no fan-out, just the correct signal mode. The shopping list processes this as one TRS patch cable.

**Validation:** The existing `validateAudioConnection` function validates each connection independently. When two connections share a TRS jack, both will be validated — this is fine since each represents a valid signal path (one conductor of the TRS).

## Verification

```bash
# Run all web tests
export NVM_DIR="$HOME/.nvm" && [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" && npm run web:test

# Build check
export NVM_DIR="$HOME/.nvm" && [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" && npm run web:build
```

### Manual testing

1. **TRS send → stereo pedal:** Add a loop switcher (e.g., RJM PBC 10) with TRS send/return jacks and a stereo pedal (e.g., Strymon BigSky) to the workbench. Connect the send jack to one of the pedal's inputs. Verify:
   - The "Connect as stereo pair?" prompt appears
   - Clicking "Yes" creates two connections, both using the same TRS send jack
   - The two connections target the pedal's L and R inputs respectively

2. **Stereo pedal → TRS return:** Connect the pedal's L output to the return jack. Verify the same stereo pair behavior in the opposite direction.

3. **Shopping list:** Check the List tab. Verify the cable entry shows "1/4" TRS to 2×1/4" TS insert cable" (quantity 1) rather than two separate patch cables.

4. **TRS-to-TRS:** Connect two devices that both have TRS jacks (no discrete partners). Verify no stereo prompt appears — a single connection is auto-created with `signalMode: 'stereo'`. The shopping list shows one TRS patch cable.

5. **Discrete-to-discrete:** Connect two devices that both have discrete L/R jacks. Verify the existing stereo pair flow works unchanged.
