select event_name,platform,event_timestamp,user_pseudo_id,app_info.version
    ,func.getParams(event_params,'buttom').string_value as buttom
    ,func.getParams(event_params,'page').string_value as page
    ,func.getParams(event_params,'video_time').string_value as video_time
    ,func.getParams(event_params,'trace_info').string_value as trace_info
    ,func.getParams(event_params,'source_module').string_value as source_module
    ,func.getParams(event_params,'source_0').string_value as source_0
    ,func.getParams(event_params,'source_1').string_value as source_1
from `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-08-01','2025-08-02','airbrush',false)
where
    event_name = 'w_subscription_success' and func.getParams(event_params,'source_module').string_value='p_onboarding'
limit 100

;

select platform,event_timestamp,user_pseudo_id,app_info.version,event_name
    ,func.getParams(event_params,'trace_info').string_value as trace_info
    ,func.getParams(event_params,'first_func').string_value as first_func
    ,func.getParams(event_params,'second_func').string_value as second_func
    ,func.getParams(event_params,'third_func').string_value as third_func
    ,func.getParams(event_params,'prf_first_func').string_value as prf_first_func
    ,func.getParams(event_params,'prf_second_func').string_value as prf_second_func
    ,func.getParams(event_params,'prf_third_func').string_value as prf_third_func
    ,func.getParams(event_params,'prf_material_type').string_value as prf_material_type
    ,func.getParams(event_params,'source_module').string_value as source_module
    ,func.getParams(event_params,'source_0').string_value as source_0
    ,func.getParams(event_params,'source_1').string_value as source_1
from `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-08-01','2025-08-02','airbrush',false)
where
    user_pseudo_id='43E786AD01CA4C6C999AFD19B901943E'
order by event_timestamp

;

select app_info.version
    ,func.getParams(event_params,'buttom').string_value as buttom
    ,func.getParams(event_params,'page').string_value as page
    ,count(1) pv
from `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-08-01','2025-08-02','airbrush',false)
where
    event_name = 'second_func_use'
    and func.getParams(event_params,'first_func').string_value='retouch'
    and func.getParams(event_params,'second_func').string_value='reshape'
group by 1,2,3
order by 1,4 desc




