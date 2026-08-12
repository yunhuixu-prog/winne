-- 老订阅事件是否有异常波动，异常事件上报是否异常，和新的是否能对上等
-- 老口径
select event_date,event_name,platform
    ,count(1) pv
    ,count(distinct user_pseudo_id) uv
from `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-10-01','2025-11-02','airbrush',false)
where
    event_name in  ('w_subscription_enter','w_subscription_click','w_subscription_success')
--     and func.getParams(event_params,'source_module').string_value='p_onboarding'
    and `dataintegration-265403.func`.compare_is_greater_or_equal_version(app_info.version,'7.17.1')
group by 1,2,3
--     ,func.getParams(event_params,'source_module').string_value as source_module
--     ,func.getParams(event_params,'source_0').string_value as source_0
--     ,func.getParams(event_params,'source_1').string_value as source_1
--     ,func.getParams(event_params,'is_vip').string_value is_vip,
--     ,func.getParams(event_params,'is_platform_vip').string_value is_platform_vip,
--     ,func.getParams(event_params,'is_tripartite_vip').string_value is_tripartite_vip,
--     ,func.getParams(event_params,'is_success').string_value is_success,
--     ,func.getParams(event_params,'time_product').string_value time_product,
--     ,func.getParams(event_params,'time_otid').string_value time_otid,
--     ,func.getParams(event_params,'time_purchased_ids').string_value time_purchased_ids,
--     ,func.getParams(event_params,'prf_fail_reason').string_value prf_fail_reason,
--     ,func.getParams(event_params,'reason').string_value reason,

select event_date,event_name,platform
    ,func.getParams(event_params,'prf_fail_reason').string_value prf_fail_reason
    ,count(1) pv
    ,count(distinct user_pseudo_id) uv
from `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-10-01','2025-11-02','airbrush',false)
where
    event_name in  ('appstore_pay_fail')
group by 1,2,3,4
order by 2,1,3,4
;

select event_date,platform
    ,func.getParams(event_params,'prf_fail_reason').string_value prf_fail_reason
    ,case when `dataintegration-265403.func`.compare_is_greater_or_equal_version(app_info.version,'7.19.0') then '>=7.19.0'
          else '<7.19.0'
    end version_type
    ,count(case when event_name='w_subscription_click' then 1 end) sub_click_pv
    ,count(distinct case when event_name='w_subscription_click' then user_pseudo_id end) sub_click_uv
    ,count(case when event_name='appstore_pay_fail' then 1 end) pay_fail_pv
    ,count(distinct case when event_name='appstore_pay_fail' then user_pseudo_id end) pay_fail_uv
from `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-10-01','2025-11-02','airbrush',false)
where
    event_name in  ('appstore_pay_fail','w_subscription_click')
group by 1,2,3,4
;
select func.getParams(event_params,'is_success').string_value,count(1) pv
from `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-10-29','2025-11-02','airbrush',false)
where
    event_name in  ('load_aw_result')
group by 1
;

-- 新口径
select date_p,event_id
    ,sdk_type platform
    ,count(1) pv,count(distinct gid) uv
from stat_sdk.sdk_odz_source_data
where date_p between 20251001 and 20251102
    and app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
    and event_id in  ('w_subscription_enter','w_subscription_click','w_subscription_success')
    and app_version>='7.17.1'
group by date_p,event_id,sdk_type
;
-- 异常汇总
select
	date_p,sdk_type,event_id
     ,params['prf_fail_reason'] prf_fail_reason
     ,params['is_success'] is_success
     ,params['reason'] reason
     ,count(1) pv
     ,count(distinct gid) uv
from stat_sdk.sdk_odz_source_data
where date_p between 20251029 and 20251102
    and app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
    and event_id in  ('appstore_pay_fail','w_subscription_show_fail','load_product_result')
    and app_version>='7.19.0'
group by date_p,sdk_type,event_id,params['prf_fail_reason'],params['is_success'],params['reason']
;
-- 支付失败明细
select
	date_p,`time`,params['prf_fail_reason'] prf_fail_reason,params['current_sku'] current_sku,
	app_version,sdk_type,sdk_version,device_model,channel,network,os_type,os_version,language,
	uid,idfa,current_idfa,idfv,current_idfv,imei,current_imei,iccid,current_iccid,mac_addr,android_id,current_android_id,advertising_id,
	current_advertising_id,pseudo_unique_id,gid,server_id,src_ip,brand,g_uuid,oaid,vaid,aaid,cbid,current_cbid,id_params,odid
from stat_sdk.sdk_odz_source_data
where date_p between 20251029 and 20251102
    and app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
    and event_id in  ('appstore_pay_fail')
    and app_version>='7.19.0'
    and params['prf_fail_reason']=2 -- 这里可以更改
;
-- 拉取订阅页失败明细
select
	date_p,`time`,params['product_id'] product_id,params['reason'] reason,params['sale_status'] sale_status,
	app_version,sdk_type,sdk_version,device_model,channel,network,os_type,os_version,language,
	uid,idfa,current_idfa,idfv,current_idfv,imei,current_imei,iccid,current_iccid,mac_addr,android_id,current_android_id,advertising_id,
	current_advertising_id,pseudo_unique_id,gid,server_id,src_ip,brand,g_uuid,oaid,vaid,aaid,cbid,current_cbid,id_params,odid
from stat_sdk.sdk_odz_source_data
where date_p between 20251029 and 20251102
    and app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
    and event_id in  ('w_subscription_show_fail')
    and app_version>='7.19.0'
-- 拉取订阅商品失败明细
select
	date_p,`time`,
	params['time_product'] time_product,params['time_otid'] time_otid,params['time_purchased_ids'] time_purchased_ids,
	params['product_id'] product_id,
	app_version,sdk_type,sdk_version,device_model,channel,network,os_type,os_version,language,
	uid,idfa,current_idfa,idfv,current_idfv,imei,current_imei,iccid,current_iccid,mac_addr,android_id,current_android_id,advertising_id,
	current_advertising_id,pseudo_unique_id,gid,server_id,src_ip,brand,g_uuid,oaid,vaid,aaid,cbid,current_cbid,id_params,odid
from stat_sdk.sdk_odz_source_data
where date_p between 20251029 and 20251102
    and app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
    and event_id in  ('load_product_result')
    and params['is_success']=0
    and app_version>='7.19.0'
;
select
	date_p,sdk_type,event_id
     ,count(1) pv
     ,count(distinct gid) uv
from stat_sdk.sdk_odz_source_data
where date_p between 20251029 and 20251102
    and app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
    and event_id in  ('w_subscription_enter','w_subscription_click','w_subscription_success','w_subscription_show_fail','appstore_pay_fail','load_product_result')
    and app_version>='7.19.0'
group by date_p,sdk_type,event_id



--     ,params['is_vip'] is_vip
--     ,params['is_platform_vip'] is_platform_vip
--     ,params['is_tripartite_vip'] is_tripartite_vip
-- 	,params['is_success'] is_success
-- 	,params['time_product'] time_product
--     ,params['time_otid'] time_otid
--     ,params['time_purchased_ids'] time_purchased_ids
--     ,params['product_id'] product_id
--     ,params['prf_fail_reason'] prf_fail_reason
--     ,params['current_sku'] current_sku
--     ,params['reason'] reason
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