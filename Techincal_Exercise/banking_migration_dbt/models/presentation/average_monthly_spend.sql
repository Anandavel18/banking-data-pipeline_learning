WITH monthly AS (

    SELECT
        customer_id,
        DATE_TRUNC(transaction_date, MONTH) AS month,
        SUM(amount) AS monthly_spend
    FROM {{ ref('fact_transactions') }}
    GROUP BY customer_id, month

),

customer_summary AS (

    SELECT
        customer_id,
        SUM(monthly_spend) AS total_spend,
        AVG(monthly_spend) AS avg_monthly_spend
    FROM monthly
    GROUP BY customer_id

)

SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    c.gender,
    cs.total_spend,
    cs.avg_monthly_spend

FROM customer_summary cs
LEFT JOIN {{ ref('dim_customer') }} c
    ON cs.customer_id = c.customer_id
    AND c.md_current_flag = 'Y'