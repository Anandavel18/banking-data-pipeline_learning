WITH ranked AS (
    SELECT load_dt,
    file_name,
    customer_id,
    first_name, 
    last_name, 
    email,
    phone,
    dob,
    gender,
    nationality,
           ROW_NUMBER() OVER (
               PARTITION BY customer_id
               ORDER BY load_dt DESC
           ) AS rn
    FROM `project-b23f2a51-1258-4419-9bd`.`arch_banking`.`arch_customers`
)

SELECT  load_dt,
    file_name,
    customer_id,
    first_name, 
    last_name, 
    email,
    phone,
    dob,
    gender,
    nationality 
FROM ranked
WHERE rn = 1