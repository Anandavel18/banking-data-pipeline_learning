

-- =========================================================
-- SOURCE
-- =========================================================
WITH source AS (

    SELECT
        CAST(account_id AS STRING) AS account_id,
        CAST(customer_id AS STRING) AS customer_id,
        account_type,
        currency,
        balance,
        status,
        account_number,
        TIMESTAMP(load_dt) AS effective_ts,
        TO_HEX(SHA256(CONCAT(
            COALESCE(account_id, ''),
            COALESCE(account_type, ''),
            COALESCE(currency, ''),
            COALESCE(status, ''),
            COALESCE(account_number, ''),
            COALESCE(CAST(balance AS STRING), '')
        ))) AS record_hash

    FROM `project-b23f2a51-1258-4419-9bd`.`stg_banking`.`stg_accounts`

),

-- =========================================================
-- DEDUP SOURCE
-- =========================================================
deduped AS (

    SELECT *
    FROM source
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY account_id
        ORDER BY effective_ts DESC
    ) = 1

),

-- =========================================================
-- CURRENT TARGET
-- =========================================================
current_target AS (

    

    SELECT *
    FROM `project-b23f2a51-1258-4419-9bd`.`tf_banking`.`dim_account`
    WHERE md_current_flag = 'Y'

    

),

-- =========================================================
-- CHANGES
-- =========================================================
changes AS (

    SELECT s.*
    FROM deduped s

    LEFT JOIN current_target t
        ON s.account_id = t.account_id

    WHERE
        t.account_id IS NULL
        OR s.record_hash != t.record_hash

),

-- =========================================================
-- EXPIRE OLD RECORDS
-- =========================================================
expired AS (

    

    SELECT
        t.account_key,
        t.account_id,
        t.customer_id,
        t.account_type,
        t.currency,
        t.balance,
        t.status,
        t.account_number,
        t.record_hash,
        t.effective_from,
        DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY) AS effective_to,
        'N' AS md_current_flag,
        t.insert_date_time,
        t.insert_process_name,
        CURRENT_TIMESTAMP() AS update_date_time,
        'DBT_SCD2_EXPIRE' AS update_process_name

    FROM current_target t

    INNER JOIN changes s
        ON t.account_id = s.account_id

    WHERE t.md_current_flag = 'Y'

    

),

-- =========================================================
-- NEW RECORDS (CURRENT VERSION)
-- =========================================================
new_records AS (

    SELECT

        TO_HEX(SHA256(CONCAT(account_id, '|', record_hash))) AS account_key,

        account_id,
        customer_id,

        account_type,
        currency,
        balance,
        status,
        account_number,
        record_hash,
        DATE(effective_ts) AS effective_from,
        DATE('9999-12-31') AS effective_to,

        'Y' AS md_current_flag,

        CURRENT_TIMESTAMP() AS insert_date_time,
        'DBT_SCD2_INSERT' AS insert_process_name,

        CAST(NULL AS TIMESTAMP) AS update_date_time,
        CAST(NULL AS STRING) AS update_process_name

    FROM changes

)

-- =========================================================
-- FINAL OUTPUT
-- =========================================================
SELECT * FROM new_records



UNION ALL

SELECT * FROM expired

