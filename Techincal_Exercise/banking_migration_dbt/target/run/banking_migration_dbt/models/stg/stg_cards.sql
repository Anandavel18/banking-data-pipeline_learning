

  create or replace view `project-b23f2a51-1258-4419-9bd`.`stg_banking`.`stg_cards`
  OPTIONS()
  as SELECT
 load_dt, file_name, card_id,card_number, account_number, customer_id, card_type, expiry_date, status
FROM `cc_banking.cc_cards`
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY card_id
    ORDER BY load_dt DESC
) = 1;

