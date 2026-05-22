SELECT
   load_dt,
    file_name,
    account_id,
    account_number, 
    customer_id, 
    account_type,
    currency, 
    balance, 
    status 
FROM `cc_banking.cc_accounts`
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY account_number
    ORDER BY load_dt DESC
) = 1