

  create or replace view `project-b23f2a51-1258-4419-9bd`.`stg_banking`.`stg_accounts`
  OPTIONS()
  as SELECT
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
) = 1;

