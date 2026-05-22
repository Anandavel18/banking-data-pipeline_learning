WITH ranked AS (
    SELECT load_dt, file_name, card_id,card_number, account_number, customer_id, card_type, expiry_date, status,
           ROW_NUMBER() OVER (
               PARTITION BY card_id
               ORDER BY load_dt DESC
           ) AS rn
    FROM `project-b23f2a51-1258-4419-9bd`.`arch_banking`.`arch_cards`
)

SELECT  load_dt, file_name, card_id,card_number, account_number, customer_id, card_type, expiry_date, status 
FROM ranked
WHERE rn = 1