WITH ranked AS (
    SELECT load_dt,
    file_name, 
    transaction_id, 
    customer_id, 
    account_number, 
    card_number,
     transaction_timestamp,
     transaction_type, 
    channel,
     merchant_name, 
    currency, 
    amount, 
    fee_amount, 
    balance_after_txn,
    status, 
    is_fraud_flag,
           ROW_NUMBER() OVER (
               PARTITION BY transaction_id
               ORDER BY load_dt DESC
           ) AS rn
    FROM {{ source('arch_banking', 'transactions') }}
)

SELECT load_dt,
    file_name, 
    transaction_id, 
    customer_id, 
    account_number, 
    card_number,
     transaction_timestamp,
     transaction_type, 
    channel,
     merchant_name, 
    currency, 
    amount, 
    fee_amount, 
    balance_after_txn,
    status, 
    is_fraud_flag
FROM ranked
WHERE rn = 1