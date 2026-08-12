with event as
(
    select
        parse_date('%Y%m%d', event_date) event_date
        ,platform
        ,event_name
        ,coalesce(`dataintegration-265403.func`.getParams(event_params,'duration_time').string_value,cast(`dataintegration-265403.func`.getParams(event_params,'duration_time').int_value as string)) as duration_time
        ,coalesce(`dataintegration-265403.func`.getParams(event_params,'carousel_position').string_value,cast(`dataintegration-265403.func`.getParams(event_params,'carousel_position').int_value as string)) as carousel_position
        ,`dataintegration-265403.func`.getParams(event_params,'carousel_func').string_value as carousel_func
        ,coalesce(`dataintegration-265403.func`.getParams(event_params,'is_carousel_slide').string_value,cast(`dataintegration-265403.func`.getParams(event_params,'is_carousel_slide').int_value as string)) as is_carousel_slide
        ,`dataintegration-265403.func`.getParams(event_params,'cur_spm').string_value as cur_spm
        ,`dataintegration-265403.func`.getUserprop(user_properties,'UserPaymentStatus').string_value is_pay
        ,user_pseudo_id
    from
        `beautyplus-bc0ed.analytics.stage_dz_event_view`
    where
        parse_date('%Y%m%d', event_date) between '2023-12-16' and '2024-01-16'
        and platform in ('IOS','ANDROID')
        and app_info.version>='7.7.023'
        and (event_name in ('subscription_clk_try','subscription_try_suc')
            or
            (event_name in ('page_event')
                and regexp_contains(`dataintegration-265403.func`.getParams(event_params,'cur_spm').string_value,'1009')))
)
-- duration_time,carousel_position,carousel_func,is_carousel_slide

select event_name,is_pay
    ,count(1) as pv
    ,avg(safe_cast(duration_time as int64)) duration_time
    ,avg(safe_cast(carousel_position as int64)) carousel_position
    ,count(case when is_carousel_slide='1' then 1 end) carousel_slide_pv
-- select *
from event
where is_carousel_slide in ('0','1') and safe_cast(duration_time as int64)<=24*60*60*1000 and is_pay='Non-paying'
-- limit 100
group by 1,2
order by 1,2;

select event_name,is_pay,carousel_position
    ,count(1) as pv
    ,avg(safe_cast(duration_time as int64)) duration_time
    ,count(case when is_carousel_slide='1' then 1 end) carousel_slide_pv
-- select *
from event
where is_carousel_slide in ('0','1') and safe_cast(duration_time as int64)<=24*60*60*1000 and is_pay='Non-paying'
-- limit 100
group by 1,2,3
order by 1,2,3


