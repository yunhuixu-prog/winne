select app_key_p,event_id,gid,date_p,sdk_type
	,app_version
    ,params['is_vip'] is_vip
    ,params['is_platform_vip'] is_platform_vip
    ,params['is_tripartite_vip'] is_tripartite_vip
	,params['is_success'] is_success
	,params['time_product'] time_product
    ,params['time_otid'] time_otid
    ,params['time_purchased_ids'] time_purchased_ids
    ,params['product_id'] product_id
    ,params['prf_fail_reason'] prf_fail_reason
    ,params['current_sku'] current_sku
    ,params['reason'] reason
-- 	,params['source_module'] source_module
-- 	,params['source_0'] source_0
--     ,params['source_1'] source_1
--     ,params['sale_status'] sale_status
--     ,params['type_id'] type_id
--     ,params['mids_material_id'] mids_material_id
--     ,params['mids_category_id'] mids_category_id
--     ,params['duration'] duration
--     ,params['SKU'] SKU
--     ,params['is_open_trial'] is_open_trial
--     ,params['order_id'] order_id
from stat_sdk.sdk_odz_source_data
where date_p between 20251024 and 20251028
 and app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
 and event_id='load_product_result' and app_version='7.19.0'
limit 100
;
select `time`,app_key_p,event_id
	,app_version
    ,params['current_abcode'] current_abcode
    ,params['meepo_abcode'] meepo_abcode
from stat_sdk.sdk_odz_source_data
where date_p between 20251024 and 20251028
 and app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
 and app_version='7.19.0'
 and gid='2617609438'
order by `time`
;
select distinct sdk_type,gid
	,params['current_abcode'] current_abcode
from stat_sdk.sdk_odz_source_data
where date_p between 20251024 and 20251028
 and app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
 and event_id='abcode_enter_test' and app_version='7.19.0'
 and params['current_abcode'] in ('28447','28448','28449')
order by params['current_abcode']
;
