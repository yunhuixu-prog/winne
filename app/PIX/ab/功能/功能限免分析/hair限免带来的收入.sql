with pop as
(
    select
        event_date,event_name,platform,event_timestamp,user_pseudo_id,app_info.version
        ,func.getParams(event_params,'page_name').string_value as page_name
    from `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-09-12','2025-11-11','airbrush',false)
    where
        event_name in ('popup_show','popup_click')
        and func.getParams(event_params,'pop_name').string_value='no_free_delivery_popup'
        and func.getParams(event_params,'page_name').string_value='edit'
        and `dataintegration-265403.func`.compare_is_greater_or_equal_version(version,'7.16.0')
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
    from `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-09-12','2025-11-11','airbrush',false)
    where
        event_name in ('ai_func_delivery','ai_func_use_result')
        and
        (
        func.getParams(event_params,'first_func').string_value in ('color','hairstyles')
        or (func.getParams(event_params,'first_func').string_value in ('retouch','hair')
            and func.getParams(event_params,'second_func').string_value in ('muscle','makeup','texture','volume'))
        )
        and `dataintegration-265403.func`.compare_is_greater_or_equal_version(version,'7.16.0')
)
,pop_type as
(
    select distinct p.event_date,p.event_name,p.user_pseudo_id
        ,coalesce(a.first_func,'unknown') first_func
        ,coalesce(a.second_func,'unknown') second_func
    from pop p
    left join ai_delivery a
    on a.event_date=p.event_date and a.user_pseudo_id=p.user_pseudo_id
    where p.event_name='popup_show'
        and p.event_timestamp-a.event_timestamp between -100000 and 100000
)
,sub as
(
--     select
--         event_date,event_name,platform,event_timestamp,user_pseudo_id,app_info.version
--         ,func.getParams(event_params,'first_func').string_value as first_func
--         ,func.getParams(event_params,'second_func').string_value as second_func
--         ,func.getParams(event_params,'third_func').string_value as third_func
--         ,func.getParams(event_params,'is_success').string_value as is_success
--         ,func.getParams(event_params,'time').string_value as time
--         ,func.getParams(event_params,'material_id').string_value as material_id
--         ,func.getParams(event_params,'material_name').string_value as material_name
--     from `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-09-12','2025-11-11','airbrush',false)
--     where
--         event_name in ('w_subscription_enter','w_subscription_click','w_subscription_success')
--         and func.getParams(event_params,'source_module').string_value in ('p_edit')
--         and func.getParams(event_params,'source_0').string_value in ('f_volume','f_hair_texture','f_hairstyles','f_hair_dye')
--         and `dataintegration-265403.func`.compare_is_greater_or_equal_version(version,'7.16.0')

    select event_date,user_pseudo_id
            ,max(if(event_name = 'w_subscription_enter' and duration is null,1,0)) is_sub_enter
            ,max(if(event_name = 'sub_suc',1,0)) is_sub
            ,max(if(event_name = 'sub_to_paid',1,0)) is_sub_to_paid
            ,max(if(event_name = 'trial',1,0)) is_trial
            ,max(if(event_name = 'trial_to_paid',1,0)) is_trial_to_paid
            ,max(if(event_name = 'sub_to_paid',payment_price_usd,0)) revenue
        from `airbrush-1324.stat.dws_airbrush_trial_sub`
        where source_module = 'p_edit'
        and source_00 in ('f_volume','f_hair_texture','f_hairstyles','f_hair_dye')
        and event_date between '2025-09-12' and '2025-11-11'
        and `dataintegration-265403.func`.compare_is_greater_or_equal_version(app_version,'7.16.0')
        group by 1,2
)

select p.event_date,p.event_name
    ,count(distinct p.user_pseudo_id) uv
    ,count(distinct case when a.is_sub_enter=1 then a.user_pseudo_id end) sub_enter_uv
    ,count(distinct case when is_sub=1 then a.user_pseudo_id end) sub_uv
    ,count(distinct case when is_sub_to_paid=1 then a.user_pseudo_id end) sub_paid_uv
    ,round(sum(a.revenue),2) sub_revenue
from pop_type p
left join sub a
on a.event_date=p.event_date and a.user_pseudo_id=p.user_pseudo_id
where p.first_func='hair'
group by 1,2