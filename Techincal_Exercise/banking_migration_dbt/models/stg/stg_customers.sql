SELECT
    customer_id,
    first_name,
    last_name,
    email,
    phone,
    dob,
    gender,
    nationality,
    load_dt,
    file_name
FROM `cc_banking.cc_customers`
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY customer_id
    ORDER BY load_dt DESC
) = 1