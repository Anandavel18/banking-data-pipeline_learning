SELECT *
FROM {{ ref('stg_transactions') }}
WHERE
    amount IS NULL
    OR amount <= 0
    OR status IS NULL
    OR transaction_id IS NULL