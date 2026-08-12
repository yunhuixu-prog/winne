-- hair-color
-- 上报有gid，但是成本无该gid
select a.*
from
(
    select event_date
        ,`dataintegration-265403.func`.getUserprop(user_properties,'hwgid').string_value gid
        ,func.getParams(event_params,'is_success').string_value is_success
        ,func.getParams(event_params,'material_id').string_value material_id
    from `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-11-11','2025-11-11','airbrush',false)
    where
        event_name in ('ai_func_use_result')
        and func.getParams(event_params,'first_func').string_value in ('color')
        -- and func.getParams(event_params,'second_func').string_value in ('hair')
        and `dataintegration-265403.func`.compare_is_greater_or_equal_version(version,'7.19.0')
        and `dataintegration-265403.func`.getUserprop(user_properties,'hwgid').string_value is not null
) a
left join (select distinct gnum from airbrush-1324.temp.ai_hair_temp) b
on a.gid=b.gnum
where b.gnum is null
;

-- 事例
select gid,params['is_success'] is_success,params['material_id'] material_id,params['time'] ai_time
	,FROM_UNIXTIME(`time`/1000) `time`
from stat_sdk.sdk_odz_source_data
where date_p between 20251111 and 20251111
 and app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
 and event_id='ai_func_use_result'
 and params['first_func']='color'
 and app_version>='7.19.0'
 and gid='2738762922'
;
selECT  algo_provider,country_type,country_name,func_id,func_name,
	os_type,app_name_cn,time,time_hour,order_id,req_time,cost,mtcc_client,
	gnum,uid,time_minute,task_id,model_name,business_name,func_effect,date_p
from
  stat_aigc.cost_odz_aigc_cost_detail_d
where
  date_p between 20251110 and 20251112
  and app_name_cn='AirBrush'
  and func_name='hair'
  and func_effect='color'
  and gnum='2738762922'




-- identify_passersby
-- 对数(新sdk19.0才接入ai_func_use_result)
select sdk_type,count(1) pv,count(distinct gid) uv
from stat_sdk.sdk_odz_source_data
where date_p between 20251111 and 20251111
 and app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
 and event_id='ai_func_use_result'
 and params['second_func']='identify_passersby'
 and app_version>='7.18.0'
 group by sdk_type
;
selECT os_type,count(1) pv,count(distinct order_id) order_pv,count(distinct gnum) uv
from
  stat_aigc.cost_odz_aigc_cost_detail_d
where
  date_p = 20251111
  and app_name_cn='AirBrush'
  and func_name='eraser'
  and func_effect='identify_passersby'
group by os_type

