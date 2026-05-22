{{ config(
    materialized='view',
    schema='banking_analytics'
) }}

SELECT
    customer_id,
    customer_key,
    first_name,
    last_name,
    email,
    phone,
    dob,
    gender,
    nationality,
    record_hash,
    effective_from,
    effective_to,
    md_current_flag
FROM {{ ref('dim_customer') }}