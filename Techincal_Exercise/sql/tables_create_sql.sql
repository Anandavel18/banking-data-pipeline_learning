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


CREATE OR REPLACE TABLE tf_banking.dim_customer (
    customer_key STRING NOT NULL,                -- PK  --TO_HEX(SHA256(CONCAT(customer_id, '|', CAST(effective_from AS STRING))))
    customer_id STRING NOT NULL,                -- Natural key
    first_name STRING NOT NULL,
    last_name STRING,
    email STRING,
    phone STRING,
    dob DATE,
    gender STRING,
    nationality STRING,
    record_hash STRING NOT NULL,
    effective_from DATE NOT NULL,
    effective_to DATE NOT NULL,
    md_current_flag STRING NOT NULL,
    insert_date_time TIMESTAMP NOT NULL,
    insert_process_name STRING NOT NULL,
    update_date_time TIMESTAMP,
    update_process_name STRING
)
PARTITION BY effective_from
CLUSTER BY customer_id;


CREATE  or replace TABLE tf_banking.dim_account(

    account_key STRING NOT NULL,
    account_id STRING NOT NULL,
    customer_id STRING NOT NULL,
    account_type STRING NOT NULL,
    currency STRING,
    status STRING,
    opened_date DATE,
    account_number STRING,
    sort_code STRING,
    record_hash STRING NOT NULL,
    effective_from DATE NOT NULL,
    effective_to DATE NOT NULL,
    md_current_flag STRING NOT NULL,
    insert_date_time TIMESTAMP NOT NULL,
    insert_process_name STRING NOT NULL,
    update_date_time TIMESTAMP,
    update_process_name STRING

)
PARTITION BY effective_from
CLUSTER BY account_id, md_current_flag
	


    CREATE  or replace TABLE tf_banking.dim_cards(

    card_key STRING,
    card_id STRING,
    customer_id STRING,
    card_number STRING,
    account_number STRING,
    card_type STRING,
    expiry_date STRING,
    status STRING,
    record_hash STRING NOT NULL,
    effective_from DATE NOT NULL,
    effective_to DATE NOT NULL,
    md_current_flag STRING NOT NULL,
    insert_date_time TIMESTAMP NOT NULL,
    insert_process_name STRING NOT NULL,
    update_date_time TIMESTAMP,
    update_process_name STRING
)
PARTITION BY effective_from
CLUSTER BY card_id, md_current_flag
	
