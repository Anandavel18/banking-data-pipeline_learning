SELECT
    COUNT(*) AS total_records,
    COUNTIF(amount IS NULL) AS null_amounts,
    COUNTIF(transaction_id IS NULL) AS null_txn_ids,
    COUNTIF(amount > 10000) AS high_value_txns,
    COUNTIF(is_fraud_flag = TRUE) AS fraud_count
FROM {{ ref('stg_transactions') }}