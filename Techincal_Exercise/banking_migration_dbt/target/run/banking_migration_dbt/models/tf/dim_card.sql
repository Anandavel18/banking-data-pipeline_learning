
  
    

    create or replace table `project-b23f2a51-1258-4419-9bd`.`tf_banking`.`dim_card`
      
    partition by effective_from
    cluster by card_id, customer_id, account_number, md_current_flag

    
    OPTIONS()
    as (
      

-- =========================================================
-- SOURCE
-- =========================================================
WITH source AS (

    SELECT
        card_id,
        card_number,
        account_number,
        customer_id,
        card_type,
        expiry_date,
        status,
        TIMESTAMP(load_dt) AS effective_ts,
        TO_HEX(SHA256(CONCAT(
            COALESCE(card_id, ''),
            COALESCE(card_number, ''),
            COALESCE(account_number, ''),
            COALESCE(customer_id, ''),
            COALESCE(card_type, ''),
            COALESCE(status, ''),
            COALESCE(CAST(expiry_date AS STRING), '')
        ))) AS record_hash

    FROM `project-b23f2a51-1258-4419-9bd`.`stg_banking`.`stg_cards`

),

-- =========================================================
-- DEDUP SOURCE
-- =========================================================
deduped AS (

    SELECT *
    FROM source
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY card_id
        ORDER BY effective_ts DESC
    ) = 1

),

-- =========================================================
-- CURRENT TARGET
-- =========================================================
current_target AS (

    

    SELECT * FROM source WHERE 1=0
    


),

-- =========================================================
-- CHANGE DETECTION
-- =========================================================
changes AS (

    SELECT s.*
    FROM deduped s

    LEFT JOIN current_target t
        ON s.card_id = t.card_id

    WHERE
        t.card_id IS NULL
        OR s.record_hash != t.record_hash

),

-- =========================================================
-- EXPIRED RECORDS
-- =========================================================
expired AS (

    

    SELECT
        CAST(NULL AS STRING) AS card_key,
        CAST(NULL AS STRING) AS card_id,
        CAST(NULL AS STRING) AS card_number,
        CAST(NULL AS STRING) AS account_number,
        CAST(NULL AS STRING) AS customer_id,
        CAST(NULL AS STRING) AS card_type,
        CAST(NULL AS DATE) AS expiry_date,
        CAST(NULL AS STRING) AS status,
        CAST(NULL AS STRING) AS record_hash,
        CAST(NULL AS DATE) AS effective_from,
        CAST(NULL AS DATE) AS effective_to,
        CAST(NULL AS STRING) AS md_current_flag,
        CAST(NULL AS TIMESTAMP) AS insert_date_time,
        CAST(NULL AS STRING) AS insert_process_name,
        CAST(NULL AS TIMESTAMP) AS update_date_time,
        CAST(NULL AS STRING) AS update_process_name
    FROM UNNEST([])

    

),

-- =========================================================
-- NEW RECORDS
-- =========================================================
new_records AS (

    SELECT

        TO_HEX(SHA256(CONCAT(card_number, '|', record_hash))) AS card_key,
        card_id,
        card_number,
        account_number,
        customer_id,
        card_type,
        expiry_date,
        status,
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


    );
  