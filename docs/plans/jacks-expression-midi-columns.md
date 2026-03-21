# Plan: Add Expression/MIDI/Aux Jack Columns (9.f–9.i)

## Context

Four schema gaps in the `jacks` table were identified during Control and MIDI connections development:
- **9.f** — `trs_midi_standard`: MIDI TRS wiring standard per-jack, enabling the MIDI connections view to auto-detect TRS-A vs TRS-B instead of requiring the user to configure it on the connection.
- **9.g** — `trs_polarity`: Expression jack tip-active vs ring-active, enabling the Control view to auto-detect polarity mismatches (e.g., Mission Engineering vs Chase Bliss).
- **9.h** — `pot_resistance_ohms`: Expression pedal potentiometer resistance, enabling resistance compatibility warnings (10K vs 25K Ohm mismatches).
- **9.i** — `footswitch_type`: Momentary vs latching per aux/toe-switch jack, enabling the Control view to validate switch compatibility.

All four are nullable columns on the `jacks` table — purely additive, no data migration needed. Batched into a single migration file.

## Files Modified

| File | Change |
|---|---|
| `data/migrations/008_add_jacks_expression_midi_columns.sql` | New migration — ALTER TABLE with CHECK constraints |
| `data/schema/gear_postgres.sql` | Added 4 columns to jacks CREATE TABLE block |
| `apps/api/src/main/java/com/pedalshootout/api/entity/Jack.java` | Added 4 fields + getters |
| `apps/api/src/main/java/com/pedalshootout/api/dto/JackDto.java` | Added 4 params to record + from() |
| `apps/web/src/types/api.ts` | Added 4 fields to JackApiResponse |

## New Columns

| Column | Type | CHECK Constraint | Applies to |
|---|---|---|---|
| `trs_midi_standard` | TEXT | `'TRS-A', 'TRS-B', 'Tip Active', 'Ring Active'` | MIDI jacks |
| `trs_polarity` | TEXT | `'tip-active', 'ring-active'` | Expression jacks |
| `pot_resistance_ohms` | INTEGER | none | Expression jacks |
| `footswitch_type` | TEXT | `'momentary', 'latching'` | Aux/toe-switch jacks |
