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
    FROM `project-b23f2a51-1258-4419-9bd`.`arch_banking`.`arch_transactions`
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