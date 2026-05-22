#!/bin/bash

set -euo pipefail

PROJECT_ID="project-b23f2a51-1258-4419-9bd"

echo "Creating customers_arch table..."

# Get the directory of this script
SCRIPT_DIR=$(dirname "$0")
SQL_DIR="$SCRIPT_DIR/../sql"

# Use the relative path for the SQL file
bq query \
  --project_id="${PROJECT_ID}" \
  --use_legacy_sql=false \
  < "$SQL_DIR/arch_table_create.sql"

echo "All tables created successfully!"