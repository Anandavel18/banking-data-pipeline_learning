#!/bin/bash

# Get current date in YYYYMMDD format
DATE=$(date +%Y%m%d)

# Local source directory
SOURCE_PATH="/mnt/c/Users/sanan/OneDrive/Interview/source_files"
echo $SOURCE_PATH

# Input files (dated)
CUSTOMER_FILE="${SOURCE_PATH}/customers_${DATE}*.csv"
TRANSACTION_FILE="${SOURCE_PATH}/transactions_${DATE}*.csv"
CARD_FILE="${SOURCE_PATH}/cards_${DATE}*.csv"
ACCOUNT_FILE="${SOURCE_PATH}/accounts_${DATE}*.csv"


# GCS bucket
BUCKET="gs://migration-banking-bucket"

echo "Starting upload for date: $DATE"

# Upload customers file
gcloud storage cp "$CUSTOMER_FILE" "$BUCKET/raw/customers/"

# Upload transactions file
gcloud storage cp "$TRANSACTION_FILE" "$BUCKET/raw/transactions/"


gcloud storage cp "$CARD_FILE" "$BUCKET/raw/cards/"

# Upload transactions file
gcloud storage cp "$ACCOUNT_FILE" "$BUCKET/raw/accounts/"


echo "Upload completed successfully!"



