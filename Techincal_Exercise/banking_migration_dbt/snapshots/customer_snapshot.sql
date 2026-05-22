{% snapshot customer_snapshot %}

{{
    config(
        target_schema='snapshots_banking',
        unique_key='customer_id',
        strategy='check',
        check_cols=[
            'first_name',
            'last_name',
            'email',
            'phone',
            'gender',
            'nationality'
        ]
    )
}}

SELECT

    customer_id,
    first_name,
    last_name,
    email,
    phone,
    dob,
    gender,
    nationality,
    CURRENT_TIMESTAMP() AS insert_date_time,
    'DBT_SNAPSHOT' AS insert_process_name

FROM {{ ref('dim_customer') }}

{% endsnapshot %}