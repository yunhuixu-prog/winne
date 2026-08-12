select
    date(timestamp_micros(event_timestamp),'Asia/Singapore')   date
    ,platform
    ,func.getParams(event_params,'source_module').string_value source_module
    ,func.getParams(event_params,'source_0').string_value source_0
    ,func.getParams(event_params,'source_1').string_value source_1
    ,func.getParams(event_params,'duration').string_value duration
    ,func.getParams(event_params,'SKU').string_value sku
--     ,count(distinct func.getParams(event_params,'order_id').string_value) order_num
--     ,count(distinct user_pseudo_id) uv
from `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-01-01','2025-09-15','airbrush',false)
where
    event_name in ('w_subscription_enter') --'w_subscription_click','w_subscription_success'
    and func.getParams(event_params,'source_1').string_value='feedback_reward'