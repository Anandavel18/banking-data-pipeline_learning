{{ config(
    materialized='view',
    schema='banking_analytics'
) }}

SELECT 
transaction_id, 
customer_key,
account_key, 
card_key, 
transaction_timestamp, 
transaction_date, 
transaction_type, 
channel, 
merchant_name,
currency, 
amount, 
fee_amount, 
net_amount, 
status,
is_fraud_flag,
insert_process_name, 
insert_date_time
FROM {{ ref('fact_transactions') }}