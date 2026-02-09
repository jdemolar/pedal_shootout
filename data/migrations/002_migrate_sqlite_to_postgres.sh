#!/usr/bin/env bash
#
# 002_migrate_sqlite_to_postgres.sh
#
# Migrates data from SQLite (gear.db) to PostgreSQL (pedal_shootout).
# Exports CSV from SQLite, loads into staging tables, converts booleans,
# and inserts into final tables.
#
# Prerequisites:
#   - PostgreSQL running with database and user created
#   - SQLite database at data/local/gear.db
#   - PostgreSQL schema already applied (gear_postgres.sql)
#
# Usage: ./data/migrations/002_migrate_sqlite_to_postgres.sh

set -euo pipefail

# --- Configuration ---
SQLITE_DB="data/local/gear.db"
PG_DB="pedal_shootout"
PG_USER="pedal_shootout_app"
PG_HOST="localhost"
PG_PORT="5432"
CSV_DIR="data/migrations/csv_export"
SCHEMA_FILE="data/schema/gear_postgres.sql"

# Use PGPASSWORD for non-interactive auth
export PGPASSWORD="localdev"

PSQL="psql -h $PG_HOST -p $PG_PORT -U $PG_USER -d $PG_DB -v ON_ERROR_STOP=1"

# --- Helpers ---
info()  { echo "[INFO]  $*"; }
error() { echo "[ERROR] $*" >&2; exit 1; }

# --- Pre-flight checks ---
command -v sqlite3 >/dev/null 2>&1 || error "sqlite3 not found"
command -v psql >/dev/null 2>&1    || error "psql not found"
[ -f "$SQLITE_DB" ]                || error "SQLite database not found: $SQLITE_DB"
[ -f "$SCHEMA_FILE" ]             || error "PostgreSQL schema not found: $SCHEMA_FILE"

# Check PostgreSQL connectivity
$PSQL -c "SELECT 1;" >/dev/null 2>&1 || error "Cannot connect to PostgreSQL. Is the server running?"

# --- Step 1: Apply schema ---
info "Applying PostgreSQL schema..."
$PSQL -f "$SCHEMA_FILE"
info "Schema applied successfully."

# --- Step 2: Export CSVs from SQLite ---
info "Exporting data from SQLite..."
mkdir -p "$CSV_DIR"

# Export manufacturers (no booleans)
sqlite3 -header -csv "$SQLITE_DB" "SELECT * FROM manufacturers;" > "$CSV_DIR/manufacturers.csv"
info "  Exported manufacturers: $(wc -l < "$CSV_DIR/manufacturers.csv" | tr -d ' ') lines"

# Export products (in_production is boolean, image_path is col 19 in SQLite)
sqlite3 -header -csv "$SQLITE_DB" \
  "SELECT id, manufacturer_id, product_type_id, model, color_options, in_production,
          width_mm, depth_mm, height_mm, weight_grams, msrp_cents, product_page,
          instruction_manual, image_path, description, tags, data_reliability, notes,
          created_at, updated_at
   FROM products;" > "$CSV_DIR/products.csv"
info "  Exported products: $(wc -l < "$CSV_DIR/products.csv" | tr -d ' ') lines"

# Export pedal_details (many booleans)
sqlite3 -header -csv "$SQLITE_DB" "SELECT * FROM pedal_details;" > "$CSV_DIR/pedal_details.csv"
info "  Exported pedal_details: $(wc -l < "$CSV_DIR/pedal_details.csv" | tr -d ' ') lines"

# Export jacks (several booleans)
sqlite3 -header -csv "$SQLITE_DB" "SELECT * FROM jacks;" > "$CSV_DIR/jacks.csv"
info "  Exported jacks: $(wc -l < "$CSV_DIR/jacks.csv" | tr -d ' ') lines"

# --- Step 3: Create staging tables and load CSVs ---
info "Creating staging tables and loading CSVs..."

$PSQL <<'SQL'
-- Staging tables use TEXT/INTEGER for everything (no booleans yet)
-- Using regular tables (not TEMP) so they persist across psql sessions

CREATE TABLE stg_manufacturers (
    id INTEGER,
    name TEXT,
    country TEXT,
    founded TEXT,
    status TEXT,
    specialty TEXT,
    website TEXT,
    notes TEXT,
    updated_at TEXT
);

CREATE TABLE stg_products (
    id INTEGER,
    manufacturer_id INTEGER,
    product_type_id INTEGER,
    model TEXT,
    color_options TEXT,
    in_production INTEGER,
    width_mm DOUBLE PRECISION,
    depth_mm DOUBLE PRECISION,
    height_mm DOUBLE PRECISION,
    weight_grams INTEGER,
    msrp_cents INTEGER,
    product_page TEXT,
    instruction_manual TEXT,
    image_path TEXT,
    description TEXT,
    tags TEXT,
    data_reliability TEXT,
    notes TEXT,
    created_at TEXT,
    updated_at TEXT
);

CREATE TABLE stg_pedal_details (
    product_id INTEGER,
    effect_type TEXT,
    circuit_type TEXT,
    circuit_routing_options TEXT,
    signal_type TEXT,
    bypass_type TEXT,
    mono_stereo TEXT,
    audio_mix TEXT,
    has_analog_dry_through INTEGER,
    has_spillover INTEGER,
    sample_rate_khz INTEGER,
    bit_depth INTEGER,
    latency_ms DOUBLE PRECISION,
    preset_count INTEGER,
    has_tap_tempo INTEGER,
    midi_capable INTEGER,
    midi_receive_capabilities TEXT,
    midi_send_capabilities TEXT,
    has_software_editor INTEGER,
    software_platforms TEXT,
    is_firmware_updatable INTEGER,
    has_usb_audio INTEGER,
    battery_capable INTEGER,
    fx_loop_count INTEGER,
    has_reorderable_loops INTEGER
);

CREATE TABLE stg_jacks (
    id INTEGER,
    product_id INTEGER,
    category TEXT,
    direction TEXT,
    jack_name TEXT,
    position TEXT,
    connector_type TEXT,
    impedance_ohms INTEGER,
    voltage TEXT,
    current_ma INTEGER,
    polarity TEXT,
    function TEXT,
    power_over_connector INTEGER,
    is_isolated INTEGER,
    is_buffered INTEGER,
    buffer_switchable INTEGER,
    has_ground_lift INTEGER,
    has_phase_invert INTEGER,
    normalled_to_jack_id INTEGER,
    normalling_type TEXT,
    group_id TEXT
);
SQL

# Load CSVs into staging tables (use absolute path for \COPY)
ABS_CSV_DIR="$(cd "$CSV_DIR" && pwd)"

$PSQL -c "\COPY stg_manufacturers FROM '$ABS_CSV_DIR/manufacturers.csv' WITH (FORMAT csv, HEADER true, NULL '');"
info "  Loaded manufacturers into staging"

$PSQL -c "\COPY stg_products FROM '$ABS_CSV_DIR/products.csv' WITH (FORMAT csv, HEADER true, NULL '');"
info "  Loaded products into staging"

$PSQL -c "\COPY stg_pedal_details FROM '$ABS_CSV_DIR/pedal_details.csv' WITH (FORMAT csv, HEADER true, NULL '');"
info "  Loaded pedal_details into staging"

$PSQL -c "\COPY stg_jacks FROM '$ABS_CSV_DIR/jacks.csv' WITH (FORMAT csv, HEADER true, NULL '');"
info "  Loaded jacks into staging"

# --- Step 4: Insert from staging into final tables with boolean conversion ---
info "Inserting data into final tables with type conversions..."

$PSQL <<'SQL'
-- Manufacturers (no booleans to convert)
INSERT INTO manufacturers (id, name, country, founded, status, specialty, website, notes, updated_at)
OVERRIDING SYSTEM VALUE
SELECT id, name, country, founded, status, specialty, website, notes,
       updated_at::TIMESTAMPTZ
FROM stg_manufacturers;

-- Products (in_production: INTEGER → BOOLEAN)
INSERT INTO products (id, manufacturer_id, product_type_id, model, color_options, in_production,
                      width_mm, depth_mm, height_mm, weight_grams, msrp_cents, product_page,
                      instruction_manual, image_path, description, tags, data_reliability, notes,
                      created_at, updated_at)
OVERRIDING SYSTEM VALUE
SELECT id, manufacturer_id, product_type_id, model, color_options,
       (in_production = 1),
       width_mm, depth_mm, height_mm, weight_grams, msrp_cents, product_page,
       instruction_manual, image_path, description, tags, data_reliability, notes,
       created_at::TIMESTAMPTZ, updated_at::TIMESTAMPTZ
FROM stg_products;

-- Pedal details (many booleans)
INSERT INTO pedal_details (product_id, effect_type, circuit_type, circuit_routing_options,
                           signal_type, bypass_type, mono_stereo, audio_mix,
                           has_analog_dry_through, has_spillover,
                           sample_rate_khz, bit_depth, latency_ms,
                           preset_count, has_tap_tempo,
                           midi_capable, midi_receive_capabilities, midi_send_capabilities,
                           has_software_editor, software_platforms, is_firmware_updatable,
                           has_usb_audio, battery_capable,
                           fx_loop_count, has_reorderable_loops)
SELECT product_id, effect_type, circuit_type, circuit_routing_options,
       signal_type, bypass_type, mono_stereo, audio_mix,
       (has_analog_dry_through = 1), (has_spillover = 1),
       sample_rate_khz, bit_depth, latency_ms,
       preset_count, (has_tap_tempo = 1),
       (midi_capable = 1), midi_receive_capabilities, midi_send_capabilities,
       (has_software_editor = 1), software_platforms, (is_firmware_updatable = 1),
       (has_usb_audio = 1), (battery_capable = 1),
       fx_loop_count, (has_reorderable_loops = 1)
FROM stg_pedal_details;

-- Jacks (several booleans)
INSERT INTO jacks (id, product_id, category, direction, jack_name, position, connector_type,
                   impedance_ohms, voltage, current_ma, polarity, function,
                   power_over_connector, is_isolated, is_buffered, buffer_switchable,
                   has_ground_lift, has_phase_invert,
                   normalled_to_jack_id, normalling_type, group_id)
OVERRIDING SYSTEM VALUE
SELECT id, product_id, category, direction, jack_name, position, connector_type,
       impedance_ohms, voltage, current_ma, polarity, function,
       (power_over_connector = 1), (is_isolated = 1), (is_buffered = 1), (buffer_switchable = 1),
       (has_ground_lift = 1), (has_phase_invert = 1),
       normalled_to_jack_id, normalling_type, group_id
FROM stg_jacks;

SQL

info "Data inserted successfully."

# Clean up staging tables
$PSQL -c "DROP TABLE stg_manufacturers, stg_products, stg_pedal_details, stg_jacks;"
info "Staging tables cleaned up."

# --- Step 5: Reset identity sequences ---
info "Resetting identity sequences..."

$PSQL <<'SQL'
SELECT setval(pg_get_serial_sequence('manufacturers', 'id'), (SELECT MAX(id) FROM manufacturers));
SELECT setval(pg_get_serial_sequence('products', 'id'), (SELECT MAX(id) FROM products));
SELECT setval(pg_get_serial_sequence('jacks', 'id'), (SELECT MAX(id) FROM jacks));
SQL

info "Sequences reset."

# --- Step 6: Verify data integrity ---
info ""
info "=== DATA VERIFICATION ==="
info ""

# Row counts
MFR_COUNT=$($PSQL -t -A -c "SELECT COUNT(*) FROM manufacturers;")
PROD_COUNT=$($PSQL -t -A -c "SELECT COUNT(*) FROM products;")
PD_COUNT=$($PSQL -t -A -c "SELECT COUNT(*) FROM pedal_details;")
JACK_COUNT=$($PSQL -t -A -c "SELECT COUNT(*) FROM jacks;")

info "Row counts:"
info "  manufacturers:  $MFR_COUNT (expected 232)"
info "  products:       $PROD_COUNT (expected 104)"
info "  pedal_details:  $PD_COUNT (expected 104)"
info "  jacks:          $JACK_COUNT (expected 306)"

# Spot check
info ""
info "Spot check — Morning Glory V4:"
$PSQL -c "SELECT p.model, m.name AS manufacturer, p.width_mm, p.depth_mm, p.height_mm, p.msrp_cents, pd.bypass_type
           FROM products p
           JOIN manufacturers m ON p.manufacturer_id = m.id
           JOIN pedal_details pd ON p.id = pd.product_id
           WHERE p.model = 'Morning Glory V4';"

# Legacy view
info ""
info "pedals_legacy view (first 3 rows):"
$PSQL -c "SELECT id, manufacturer, model, effect_type, dimensions, bypass_type FROM pedals_legacy LIMIT 3;"

# FK enforcement test
info ""
info "FK enforcement test (should fail):"
set +e
FK_RESULT=$(psql -h $PG_HOST -p $PG_PORT -U $PG_USER -d $PG_DB -c "INSERT INTO products (manufacturer_id, product_type_id, model) VALUES (99999, 1, 'FK Test');" 2>&1)
FK_EXIT=$?
set -e
if [ $FK_EXIT -ne 0 ]; then
    info "  FK constraint correctly rejected invalid manufacturer_id."
else
    error "FK constraint did NOT prevent invalid insert!"
fi

# Trigger test
info ""
info "Trigger test (update product, check updated_at changes):"
BEFORE=$($PSQL -t -A -c "SELECT updated_at FROM products WHERE id = 1;")
sleep 1
$PSQL -c "UPDATE products SET notes = 'trigger test' WHERE id = 1;" >/dev/null
AFTER=$($PSQL -t -A -c "SELECT updated_at FROM products WHERE id = 1;")
if [ "$BEFORE" != "$AFTER" ]; then
    info "  Trigger fired: updated_at changed from $BEFORE to $AFTER"
else
    error "Trigger did NOT fire — updated_at unchanged."
fi
# Clean up trigger test
$PSQL -c "UPDATE products SET notes = NULL WHERE id = 1;" >/dev/null

info ""
info "=== MIGRATION COMPLETE ==="
info ""
