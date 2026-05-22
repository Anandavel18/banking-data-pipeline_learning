-- back compat for old kwarg name
  
  
        
            
	    
	    
            
        
    

    

    merge into `project-b23f2a51-1258-4419-9bd`.`tf_banking`.`dim_account` as DBT_INTERNAL_DEST
        using (
        select
        * from `project-b23f2a51-1258-4419-9bd`.`tf_banking`.`dim_account__dbt_tmp`
        ) as DBT_INTERNAL_SOURCE
        on ((DBT_INTERNAL_SOURCE.account_key = DBT_INTERNAL_DEST.account_key))

    
    when matched then update set
        `account_key` = DBT_INTERNAL_SOURCE.`account_key`,`account_id` = DBT_INTERNAL_SOURCE.`account_id`,`customer_id` = DBT_INTERNAL_SOURCE.`customer_id`,`account_type` = DBT_INTERNAL_SOURCE.`account_type`,`currency` = DBT_INTERNAL_SOURCE.`currency`,`balance` = DBT_INTERNAL_SOURCE.`balance`,`status` = DBT_INTERNAL_SOURCE.`status`,`account_number` = DBT_INTERNAL_SOURCE.`account_number`,`record_hash` = DBT_INTERNAL_SOURCE.`record_hash`,`effective_from` = DBT_INTERNAL_SOURCE.`effective_from`,`effective_to` = DBT_INTERNAL_SOURCE.`effective_to`,`md_current_flag` = DBT_INTERNAL_SOURCE.`md_current_flag`,`insert_date_time` = DBT_INTERNAL_SOURCE.`insert_date_time`,`insert_process_name` = DBT_INTERNAL_SOURCE.`insert_process_name`,`update_date_time` = DBT_INTERNAL_SOURCE.`update_date_time`,`update_process_name` = DBT_INTERNAL_SOURCE.`update_process_name`
    

    when not matched then insert
        (`account_key`, `account_id`, `customer_id`, `account_type`, `currency`, `balance`, `status`, `account_number`, `record_hash`, `effective_from`, `effective_to`, `md_current_flag`, `insert_date_time`, `insert_process_name`, `update_date_time`, `update_process_name`)
    values
        (`account_key`, `account_id`, `customer_id`, `account_type`, `currency`, `balance`, `status`, `account_number`, `record_hash`, `effective_from`, `effective_to`, `md_current_flag`, `insert_date_time`, `insert_process_name`, `update_date_time`, `update_process_name`)


    