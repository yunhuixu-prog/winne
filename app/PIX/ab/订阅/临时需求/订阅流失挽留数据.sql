with event as
(
    select
        date(timestamp_micros(event_timestamp),'Asia/Singapore')   date
        ,event_name
        ,platform
        ,func.getParams(event_params,'pop_id').string_value pop_id
        ,func.getParams(event_params,'strategy_name').string_value strategy_name
        ,func.getParams(event_params,'pop_type').string_value pop_type
        ,user_pseudo_id
    from `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-01-01','2025-12-31','airbrush',false)
    where
        event_name in ('strategy_popup_show','strategy_popup_click','w_subscription_renew_success')
    --     and func.getParams(event_params,'strategy_name').string_value='churn'
)

select date,event_name,platform,pop_id,pop_type
    ,count(1) pv,count(distinct user_pseudo_id) uv
from event
where strategy_name='churn'
group by 1,2,3,4,5


