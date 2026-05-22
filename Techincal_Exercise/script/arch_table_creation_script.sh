#!/bin/bash

set -euo pipefail

PROJECT_ID="project-b23f2a51-1258-4419-9bd"

echo "Creating customers_arch table..."

bq query \
--project_id=${PROJECT_ID} \
--use_legacy_sql=false \
< /mnt/c/Users/sanan/OneDrive/Interview/code/table_create.sql

echo "All tables created successfully!"