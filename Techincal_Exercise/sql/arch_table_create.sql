CREATE  OR REPLACE TABLE arch_banking.arch_customers (

    load_dt TIMESTAMP,
    file_name string,
    customer_id STRING,
    first_name STRING,
    last_name STRING,
    email STRING,
    phone STRING,
    dob DATE,
    gender STRING,
    nationality STRING
)
PARTITION BY DATE(load_dt);

CREATE  OR REPLACE TABLE  arch_banking.arch_transactions(
 
    load_dt TIMESTAMP,
    file_name string,
    transaction_id STRING,

    customer_id STRING,
    account_number STRING,
    card_number INT64,

    transaction_timestamp TIMESTAMP,
    transaction_type STRING,
    channel STRING,
    merchant_name STRING,

    currency STRING,

    amount NUMERIC,
    fee_amount NUMERIC,
    balance_after_txn NUMERIC,

    status STRING,

    is_fraud_flag BOOL

)
PARTITION BY DATE(transaction_timestamp)
CLUSTER BY customer_id, merchant_name;


CREATE  OR REPLACE TABLE arch_banking.arch_cards (

    load_dt TIMESTAMP,
    file_name string,
    card_id STRING,
    card_number STRING,
    account_number STRING,
    customer_id STRING,
    card_type STRING,
    expiry_date STRING,
    status STRING
)
PARTITION BY DATE(load_dt);


CREATE  OR REPLACE TABLE arch_banking.arch_accounts (

    load_dt TIMESTAMP,
    file_name string,
    account_id STRING,
    account_number STRING,
    customer_id STRING,
    account_type STRING,
    currency STRING,
    balance NUMERIC,
    status STRING
)
PARTITION BY DATE(load_dt)
CLUSTER BY customer_id;
