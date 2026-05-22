
  
    

    create or replace table `project-b23f2a51-1258-4419-9bd`.`tf_banking`.`fact_transactions`
      
    partition by transaction_date
    cluster by customer_key, account_key, card_key, merchant_name

    
    OPTIONS()
    as (
      

-- =========================================================
-- SOURCE
-- =========================================================
WITH txn AS (

    SELECT
        transaction_id,
        customer_id,
        account_number,
        transaction_timestamp,
        DATE(transaction_timestamp) AS transaction_date,
        transaction_type,
        channel,
        merchant_name,
        currency,
        amount,
        fee_amount,
        (amount - fee_amount) AS net_amount,
        status,
        is_fraud_flag
    FROM `project-b23f2a51-1258-4419-9bd`.`stg_banking`.`stg_transactions`

),

-- =========================================================
-- CURRENT DIMENSIONS ONLY
-- =========================================================
cust AS (
    SELECT customer_id, customer_key
    FROM `project-b23f2a51-1258-4419-9bd`.`tf_banking`.`dim_customer`
    WHERE md_current_flag = 'Y'
),

acct AS (
    SELECT account_id, account_key,account_number
    FROM `project-b23f2a51-1258-4419-9bd`.`tf_banking`.`dim_account`
    WHERE md_current_flag = 'Y'
),

card AS (
    SELECT card_id, card_key,customer_id
    FROM `project-b23f2a51-1258-4419-9bd`.`tf_banking`.`dim_card`
    WHERE md_current_flag = 'Y'
),

-- =========================================================
-- final FACT
-- =========================================================
final AS (

    SELECT
        t.transaction_id,
        c.customer_key,
        a.account_key,
        cr.card_key,
        t.transaction_timestamp,
        t.transaction_date,
        t.transaction_type,
        t.channel,
        t.merchant_name,
        t.currency,
        t.amount,
        t.fee_amount,
        t.net_amount,
        t.status,
        t.is_fraud_flag,
        CURRENT_TIMESTAMP() AS insert_date_time,
        'DBT_FACT_TRANSACTIONS' AS insert_process_name

    FROM txn t

    LEFT JOIN cust c
        ON t.customer_id = c.customer_id

    LEFT JOIN acct a
        ON t.account_number = a.account_number

    LEFT JOIN card cr
        ON t.customer_id = cr.customer_id

)

-- =========================================================
-- APPEND-ONLY LOGIC
-- =========================================================
SELECT *
FROM final


    );
  