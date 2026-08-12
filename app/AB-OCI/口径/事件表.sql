SELECT distinct date_p,DATE_FORMAT(FROM_UNIXTIME(CAST(`time`/1000 AS bigint)), 'yyyyMMddHHmmss') event_time
        ,event_id
        ,sdk_type os_type,gid,app_version
        ,case when params['duration']='annual' then '年'
              when params['duration']='1month' then '月'
              when params['duration']='3month' then '季'
              when params['duration'] is null then '未知'
        else '其他'
        end duration
        ,params['source_module'] source_module
        ,params['source_0'] source_0
        ,params['source_1'] source_1
        ,params['mids_material_id'] mids_material_id
        ,params['mids_category_id'] mids_category_id
        ,params['SKU'] sku
        ,params['sale_status'] sale_status
    FROM stat_sdk.sdk_odz_source_data
    WHERE date_p between ${start_time} and ${end_time}
        AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
        AND event_id IN  ('w_subscription_enter','w_subscription_click','w_subscription_success')
        AND app_version>='7.19.0'