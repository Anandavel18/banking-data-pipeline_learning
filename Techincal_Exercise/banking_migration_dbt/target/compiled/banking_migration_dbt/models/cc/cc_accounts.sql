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
    FROM `project-b23f2a51-1258-4419-9bd`.`arch_banking`.`arch_accounts`
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