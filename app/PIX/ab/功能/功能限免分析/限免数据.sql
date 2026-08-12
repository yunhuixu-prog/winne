with pop as
(
    select
        event_date,event_name,platform,event_timestamp,user_pseudo_id,app_info.version
        ,func.getParams(event_params,'page_name').string_value as page_name
    from `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-09-12','2025-09-18','airbrush',false)
    where
        event_name in ('popup_show','popup_click')
        and func.getParams(event_params,'pop_name').string_value='no_free_delivery_popup'
        and func.getParams(event_params,'page_name').string_value='edit'
)
,ai_delivery as
(
    select
        event_date,event_name,platform,event_timestamp,user_pseudo_id,app_info.version
        ,func.getParams(event_params,'first_func').string_value as first_func
        ,func.getParams(event_params,'second_func').string_value as second_func
        ,func.getParams(event_params,'third_func').string_value as third_func
        ,func.getParams(event_params,'is_success').string_value as is_success
        ,func.getParams(event_params,'time').string_value as time
        ,func.getParams(event_params,'material_id').string_value as material_id
        ,func.getParams(event_params,'material_name').string_value as material_name
    from `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-09-12','2025-09-18','airbrush',false)
    where
        event_name in ('ai_func_delivery','ai_func_use_result')
        and
        (
        func.getParams(event_params,'first_func').string_value in ('color','hairstyles')
        or (func.getParams(event_params,'first_func').string_value in ('retouch','hair')
            and func.getParams(event_params,'second_func').string_value in ('muscle','makeup','texture','volume'))
        )
)

select p.event_date,p.event_name
    ,coalesce(a.first_func,'unknown') first_func
    ,coalesce(a.second_func,'unknown') second_func
    ,count(distinct p.user_pseudo_id) uv
    ,count(1) pv
from pop p
left join ai_delivery a
on a.event_date=p.event_date and a.user_pseudo_id=p.user_pseudo_id
where p.event_name='popup_show'
    and p.event_timestamp-a.event_timestamp between -100000 and 100000
group by 1,2,3,4
;


with pop as
(
    select
        event_date,event_name,platform,event_timestamp,user_pseudo_id,app_info.version
        ,func.getParams(event_params,'page_name').string_value as page_name
    from `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-09-12','2025-09-18','airbrush',false)
    where
        event_name in ('popup_show','popup_click')
        and func.getParams(event_params,'pop_name').string_value='no_free_delivery_popup'
        and func.getParams(event_params,'page_name').string_value='edit'
)

select event_date,event_name
    ,count(distinct user_pseudo_id) uv
    ,count(1) pv
from pop
group by 1,2
order by 1,2


;
with ai_delivery as
(
    select
        event_date,event_name,platform,event_timestamp,user_pseudo_id,app_info.version
        ,func.getParams(event_params,'first_func').string_value as first_func
        ,func.getParams(event_params,'second_func').string_value as second_func
        ,func.getParams(event_params,'third_func').string_value as third_func
        ,func.getParams(event_params,'is_success').string_value as is_success
        ,func.getParams(event_params,'time').string_value as time
        ,func.getParams(event_params,'material_id').string_value as material_id
        ,func.getParams(event_params,'material_name').string_value as material_name
    from `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-09-05','2025-09-18','airbrush',false)
    where
        event_name in ('ai_func_delivery','ai_func_use_result')
        and
        (
        func.getParams(event_params,'first_func').string_value in ('color','hairstyles')
        or (func.getParams(event_params,'first_func').string_value in ('retouch','hair')
            and func.getParams(event_params,'second_func').string_value in ('muscle','makeup','texture','volume'))
        )
)

select event_date
    ,case when version='7.16.0' then '7.16.0' else 'else' end version
    ,case when event_date between '2025-09-05' and '2025-09-11' then '2:0905~0911'
          when event_date between '2025-09-12' and '2025-09-18' then '3:0912~0918'
    end week
    ,event_name,first_func,second_func,third_func
    ,count(distinct user_pseudo_id) uv
    ,count(1) pv
from ai_delivery
group by 1,2,3,4,5,6,7

;

with ai_delivery as
(
    select
        event_date,event_name,platform,event_timestamp,user_pseudo_id,app_info.version
        ,func.getParams(event_params,'first_func').string_value as first_func
        ,func.getParams(event_params,'second_func').string_value as second_func
        ,func.getParams(event_params,'third_func').string_value as third_func
        ,func.getParams(event_params,'is_success').string_value as is_success
        ,func.getParams(event_params,'time').string_value as time
        ,func.getParams(event_params,'material_id').string_value as material_id
        ,func.getParams(event_params,'material_name').string_value as material_name
    from `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-09-12','2025-09-18','airbrush',false)
    where
        event_name in ('ai_func_delivery','ai_func_use_result')
        and
        (
        func.getParams(event_params,'first_func').string_value in ('color','hairstyles')
        or (func.getParams(event_params,'first_func').string_value in ('retouch','hair')
            and func.getParams(event_params,'second_func').string_value in ('muscle','makeup','texture','volume'))
        )
)

select event_date
    ,case when first_func in ('color','hairstyles','hair') then 'hair' when second_func='muscle' then 'muscle' else 'else' end func
    ,event_name
    ,count(distinct user_pseudo_id) uv
    ,count(1) pv
from ai_delivery
where event_name in ('ai_func_delivery','ai_func_use_result') --and first_func in ('color','hairstyles','hair')
and `dataintegration-265403.func`.compare_is_greater_or_equal_version(version,'7.16.0')
group by 1,2,3


;

select event_name,platform,event_timestamp,user_pseudo_id,app_info.version
    ,func.getParams(event_params,'source_module').string_value as source_module
    ,func.getParams(event_params,'source_0').string_value as source_0
    ,func.getParams(event_params,'source_1').string_value as source_1
from `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-09-01','2025-09-20','airbrush',false)
where
    event_name = 'w_subscription_enter' and func.getParams(event_params,'source_module').string_value='p_edit'
    and func.getParams(event_params,'source_0').string_value='f_volume'
limit 100


