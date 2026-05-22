-- back compat for old kwarg name
  
  
        
            
	    
	    
            
        
    

    

    merge into `project-b23f2a51-1258-4419-9bd`.`tf_banking`.`dim_customer` as DBT_INTERNAL_DEST
        using (
        select
        * from `project-b23f2a51-1258-4419-9bd`.`tf_banking`.`dim_customer__dbt_tmp`
        ) as DBT_INTERNAL_SOURCE
        on ((DBT_INTERNAL_SOURCE.customer_key = DBT_INTERNAL_DEST.customer_key))

    
    when matched then update set
        `customer_key` = DBT_INTERNAL_SOURCE.`customer_key`,`customer_id` = DBT_INTERNAL_SOURCE.`customer_id`,`first_name` = DBT_INTERNAL_SOURCE.`first_name`,`last_name` = DBT_INTERNAL_SOURCE.`last_name`,`email` = DBT_INTERNAL_SOURCE.`email`,`phone` = DBT_INTERNAL_SOURCE.`phone`,`dob` = DBT_INTERNAL_SOURCE.`dob`,`gender` = DBT_INTERNAL_SOURCE.`gender`,`nationality` = DBT_INTERNAL_SOURCE.`nationality`,`record_hash` = DBT_INTERNAL_SOURCE.`record_hash`,`effective_from` = DBT_INTERNAL_SOURCE.`effective_from`,`effective_to` = DBT_INTERNAL_SOURCE.`effective_to`,`md_current_flag` = DBT_INTERNAL_SOURCE.`md_current_flag`,`insert_date_time` = DBT_INTERNAL_SOURCE.`insert_date_time`,`insert_process_name` = DBT_INTERNAL_SOURCE.`insert_process_name`,`update_date_time` = DBT_INTERNAL_SOURCE.`update_date_time`,`update_process_name` = DBT_INTERNAL_SOURCE.`update_process_name`
    

    when not matched then insert
        (`customer_key`, `customer_id`, `first_name`, `last_name`, `email`, `phone`, `dob`, `gender`, `nationality`, `record_hash`, `effective_from`, `effective_to`, `md_current_flag`, `insert_date_time`, `insert_process_name`, `update_date_time`, `update_process_name`)
    values
        (`customer_key`, `customer_id`, `first_name`, `last_name`, `email`, `phone`, `dob`, `gender`, `nationality`, `record_hash`, `effective_from`, `effective_to`, `md_current_flag`, `insert_date_time`, `insert_process_name`, `update_date_time`, `update_process_name`)


    