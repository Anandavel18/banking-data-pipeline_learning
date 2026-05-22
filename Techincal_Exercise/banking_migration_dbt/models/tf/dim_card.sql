{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='card_key',

    partition_by={
        "field": "effective_from",
        "data_type": "date"
    },

    cluster_by=[
        "card_id",
        "customer_id",
        "account_number",
        "md_current_flag"
    ],

    on_schema_change='append_new_columns'
) }}

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

    FROM {{ ref('stg_cards') }}

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

    {% if is_incremental() %}

    SELECT *
    FROM {{ this }}
    WHERE md_current_flag = 'Y'

    {% else %}

    SELECT * FROM source WHERE 1=0
    {% endif %}


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

    {% if is_incremental() %}

    SELECT
        t.card_key,
        t.card_id,
        t.card_number,
        t.account_number,
        t.customer_id,

        t.card_type,
        t.expiry_date,
        t.status,

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
        ON t.card_number = s.card_number

    WHERE t.md_current_flag = 'Y'

    {% else %}

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

    {% endif %}

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

{% if is_incremental() %}

UNION ALL

SELECT * FROM expired

{% endif %}