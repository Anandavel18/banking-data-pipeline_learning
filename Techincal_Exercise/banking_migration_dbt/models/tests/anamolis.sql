SELECT
    transaction_id,
    customer_key,
    amount,
    merchant_name,
    transaction_timestamp,

    CASE 
        WHEN amount > 10000 THEN 'HIGH_VALUE_TXN'
        WHEN amount > 5000 AND channel = 'ONLINE' THEN 'ONLINE_HIGH_VALUE'
    END AS anomaly_type

FROM {{ ref('stg_transactions') }}
WHERE amount > 5000