#!/bin/bash

set -euo pipefail

# ====================================
# CONFIGURATION
# ====================================

DATE=$(date +%Y%m%d)

PROJECT_ID="project-b23f2a51-1258-4419-9bd"

DATASET="arch_banking"

BUCKET="gs://migration-banking-bucket"

# ====================================
# FILE PATHS
# ====================================

CUSTOMER_GCS_FILE="${BUCKET}/raw/customers/customers_${DATE}*.csv"

TRANSACTION_GCS_FILE="${BUCKET}/raw/transactions/transactions_${DATE}*.csv"

CARDS_GCS_FILE="${BUCKET}/raw/cards/cards_${DATE}*.csv"

ACCOUNTS_GCS_FILE="${BUCKET}/raw/accounts/accounts_${DATE}*.csv"

# ====================================
# LOAD CUSTOMERS ARCH TABLE
# ====================================

echo "Loading customers_arch..."

bq load \
--project_id=${PROJECT_ID} \
--source_format=CSV \
--skip_leading_rows=1 \
--autodetect=false \
--replace=false \
${DATASET}.arch_customers \
${CUSTOMER_GCS_FILE}

# ====================================
# LOAD TRANSACTIONS ARCH TABLE
# ====================================

echo "Loading transactions_arch..."

bq load \
--project_id=${PROJECT_ID} \
--source_format=CSV \
--skip_leading_rows=1 \
--autodetect=false \
--replace=false \
${DATASET}.arch_transactions \
${TRANSACTION_GCS_FILE}


echo "Loading cards_arch..."

bq load \
--project_id=${PROJECT_ID} \
--source_format=CSV \
--skip_leading_rows=1 \
--autodetect=false \
--replace=false \
${DATASET}.arch_cards \
${CARDS_GCS_FILE}

echo "Loading accounts_arch..."

bq load \
--project_id=${PROJECT_ID} \
--source_format=CSV \
--skip_leading_rows=1 \
--autodetect=false \
--replace=false \
${DATASET}.arch_accounts \
${ACCOUNTS_GCS_FILE}

echo "ARCH table load completed successfully!"