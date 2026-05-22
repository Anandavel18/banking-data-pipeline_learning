{{
    config(
        materialized='incremental',
        incremental_strategy='merge',
        unique_key='customer_key',

        partition_by={
            "field": "effective_from",
            "data_type": "DATE"
        },

        cluster_by=["customer_id","md_current_flag"],

        on_schema_change='append_new_columns'
    )
}}

WITH source AS (

    SELECT
        CAST(customer_id AS STRING) AS customer_id,
        first_name,
        last_name,
        email,
        phone,
        dob,
        gender,
        nationality,
        load_dt,
        TIMESTAMP(load_dt) AS effective_ts,
        TO_HEX(SHA256(CONCAT(
            COALESCE(first_name,''),
            COALESCE(last_name,''),
            COALESCE(email,''),
            COALESCE(phone,''),
            COALESCE(CAST(dob AS STRING),''),
            COALESCE(gender,''),
            COALESCE(nationality,'')
        ))) AS record_hash

    FROM {{ ref('stg_customers') }}

  ),

-- latest record per customer in this batch

-- current active records in target
current_target AS (

    {% if is_incremental() %}
    SELECT *
    FROM {{ this }}
    WHERE md_current_flag = 'Y'
    {% else %}
    SELECT * FROM source WHERE 1=0
    {% endif %}

),

-- detect changes
changes AS (

    SELECT
        s.*
    FROM source s
    LEFT JOIN current_target t
        ON s.customer_id = t.customer_id
    WHERE
        t.customer_id IS NULL
        OR s.record_hash != t.record_hash

),

-- expire existing records
-- expire existing records
expired AS (

    {% if is_incremental() %}

    SELECT
        t.customer_key,
        t.customer_id,
        t.first_name,
        t.last_name,
        t.email,
        t.phone,
        t.dob,
        t.gender,
        t.nationality,
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
        ON t.customer_id = s.customer_id
       AND t.record_hash <> s.record_hash

    WHERE t.md_current_flag = 'Y'

    {% else %}

    -- first run: no expired rows
    SELECT
        CAST(NULL AS STRING) AS customer_key,
        CAST(NULL AS STRING) AS customer_id,
        CAST(NULL AS STRING) AS first_name,
        CAST(NULL AS STRING) AS last_name,
        CAST(NULL AS STRING) AS email,
        CAST(NULL AS STRING) AS phone,
        CAST(NULL AS DATE) AS dob,
        CAST(NULL AS STRING) AS gender,
        CAST(NULL AS STRING) AS nationality,
        CAST(NULL AS STRING) AS record_hash,
        CAST(NULL AS DATE) AS effective_from,
        CAST(NULL AS DATE) AS effective_to,
        CAST(NULL AS STRING) AS md_current_flag,
        CAST(NULL AS TIMESTAMP) AS insert_date_time,
        CAST(NULL AS STRING) AS insert_process_name,
        CAST(NULL AS TIMESTAMP) AS update_date_time,
        CAST(NULL AS STRING) AS update_process_name
        FROM UNNEST([])
    WHERE 1=0

    {% endif %}

),

-- insert new version
new_records AS (

    SELECT
        -- deterministic surrogate key (content-based)
        TO_HEX(SHA256(CONCAT(
            s.customer_id, '|', s.record_hash
        ))) AS customer_key,
        s.customer_id,
        s.first_name,
        s.last_name,
        s.email,
        s.phone,
        s.dob,
        s.gender,
        s.nationality,
        s.record_hash,
        DATE(s.effective_ts) AS effective_from,
        DATE('9999-12-31') AS effective_to,
        'Y' AS md_current_flag,
        CURRENT_TIMESTAMP() AS insert_date_time,
        'DBT_SCD2_INSERT' AS insert_process_name,
        CAST(NULL AS TIMESTAMP) AS update_date_time,
        CAST(NULL AS STRING) AS update_process_name
    FROM changes s

)

-- final dataset for merge
SELECT * FROM new_records

{% if is_incremental() %}

UNION ALL

SELECT * FROM expired

{% endif %}