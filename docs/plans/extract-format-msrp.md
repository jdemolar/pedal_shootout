# Extract shared `formatMsrp` utility

## Context

The same 3-line `formatMsrp` method is duplicated in 8 DTO records and 1 service class (9 copies total). This is refactoring opportunity #4 from `docs/plans/refactoring-opportunities.md`.

```java
private static String formatMsrp(Integer cents) {
    if (cents == null) return null;
    return String.format("$%d.%02d", cents / 100, cents % 100);
}
```

**Files with duplicates:**
| # | File | Visibility |
|---|---|---|
| 1 | `PedalDto.java:65-68` | `private static` |
| 2 | `PowerSupplyDto.java:64-67` | `private static` |
| 3 | `PedalboardDto.java:63-66` | `private static` |
| 4 | `MidiControllerDto.java:84-87` | `private static` |
| 5 | `UtilityDto.java:64-67` | `private static` |
| 6 | `PlugDto.java:45-48` | `private static` |
| 7 | `ProductSummaryDto.java:57-60` | `private static` |
| 8 | `ProductDetailDto.java:58-61` | `private static` |
| 9 | `PowerBudgetService.java:129-132` | `private` (instance method) |

## Approach

Create a `DtoUtils` class in the `dto` package with a single `public static` method, then replace all 9 copies with `DtoUtils.formatMsrp(...)`.

## Files to Create

| File | Purpose |
|---|---|
| `apps/api/src/main/java/com/pedalshootout/api/dto/DtoUtils.java` | Shared formatting utilities for DTOs |

## Files to Modify

| File | Change |
|---|---|
| `PedalDto.java` | Replace `formatMsrp` call with `DtoUtils.formatMsrp`, remove private method |
| `PowerSupplyDto.java` | Same |
| `PedalboardDto.java` | Same |
| `MidiControllerDto.java` | Same |
| `UtilityDto.java` | Same |
| `PlugDto.java` | Same |
| `ProductSummaryDto.java` | Same |
| `ProductDetailDto.java` | Same |
| `PowerBudgetService.java` | Replace `formatMsrp` call with `DtoUtils.formatMsrp`, remove private method, add import |

## Implementation

### 1. Create `DtoUtils.java`

```java
package com.pedalshootout.api.dto;

public final class DtoUtils {

    private DtoUtils() {}

    public static String formatMsrp(Integer cents) {
        if (cents == null) return null;
        return String.format("$%d.%02d", cents / 100, cents % 100);
    }
}
```

### 2. Update each DTO record

In each of the 8 DTO files:
- Change `formatMsrp(p.getMsrpCents())` → `DtoUtils.formatMsrp(p.getMsrpCents())`
- Delete the `private static String formatMsrp(...)` method

No new import needed — `DtoUtils` is in the same `dto` package.

### 3. Update `PowerBudgetService.java`

- Change `formatMsrp(p.getMsrpCents())` → `DtoUtils.formatMsrp(p.getMsrpCents())`
- Delete the `private String formatMsrp(...)` method
- Add `import com.pedalshootout.api.dto.DtoUtils;`

## Verification

1. `cd apps/api && ./mvnw compile -q` — no compilation errors
2. `cd apps/api && ./mvnw test` — smoke test passes
3. Confirm no remaining copies: `grep -r "private.*formatMsrp" apps/api/src/` should return nothing
4. Check off item #4 in `docs/plans/refactoring-opportunities.md`
5. Move this plan to `docs/plans/completed/`
