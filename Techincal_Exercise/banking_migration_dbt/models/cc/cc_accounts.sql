WITH ranked AS (
    SELECT  
    load_dt,
    file_name, 
    account_number, 
    account_id,
    customer_id, 
    account_type,
    currency, 
    balance, 
    status,
           ROW_NUMBER() OVER (
               PARTITION BY account_number
               ORDER BY load_dt DESC
           ) AS rn
    FROM {{ source('arch_banking', 'accounts') }}
)

SELECT load_dt,
    file_name, 
    account_number,
    account_id, 
    customer_id, 
    account_type,
    currency, 
    balance, 
    status 
FROM ranked
WHERE rn = 1