SELECT
load_dt, 
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
FROM `cc_banking.cc_transactions`
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY transaction_id
    ORDER BY transaction_timestamp DESC
) = 1