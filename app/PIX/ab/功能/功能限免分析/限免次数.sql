with pop as
(
    select
        event_date,event_name,platform,event_timestamp,user_pseudo_id,app_info.version
        ,func.getParams(event_params,'page_name').string_value as page_name
    from `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-09-10','2025-09-23','airbrush',false)
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
    from `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-09-10','2025-09-23','airbrush',false)
    where
        event_name in ('ai_func_delivery','ai_func_use_result')
        and
        (
        func.getParams(event_params,'first_func').string_value in ('color','hairstyles')
        or (func.getParams(event_params,'first_func').string_value in ('retouch','hair','edit')
            and func.getParams(event_params,'second_func').string_value in ('muscle','makeup','texture','volume','ai_replace'))
        )
)
,user_tag as (
    -- 用户标签
    select event_date,platform,user_pseudo_id,uuid,AppsFlyer_ID
           ,country,app_version,is_UA,user_type,is_New,lifecycle,is_paying
    from `airbrush-1324.behavior.dws_dz_behavior_user_tag_id`
    where
    event_date  between '2025-09-10' and '2025-09-23'
)
,pop_exp_func as
(
    select p.*
        ,coalesce(a.first_func,'unknown') first_func
        ,coalesce(a.second_func,'unknown') second_func
    from pop p
    left join ai_delivery a
    on a.event_date=p.event_date and a.user_pseudo_id=p.user_pseudo_id
    where p.event_name='popup_show'
        and (p.event_timestamp-a.event_timestamp between -100000 and 100000 or a.event_timestamp is null)
)

select a.event_date,a.event_name,a.platform
    ,case when a.event_date between '2025-09-10' and '2025-09-16' then '2:0910~0916'
          when a.event_date between '2025-09-17' and '2025-09-23' then '3:0917~0923'
    end week
--     ,a.first_func,a.second_func
    ,case when a.first_func in ('color','hairstyles','hair') then 'hair'
          when a.second_func in ('muscle','ai_replace') then a.second_func else 'else' end func
    ,case when `dataintegration-265403.func`.compare_is_greater_or_equal_version(a.version,'7.16.0') then version
          else '<7.16.0'
    end version
    ,u.is_paying
    ,count(distinct a.user_pseudo_id) uv
    ,count(1) pv
from ai_delivery a
left join user_tag u on a.user_pseudo_id = u.user_pseudo_id and a.event_date = u.event_date
group by 1,2,3,4,5,6,7

union all

select p.event_date,p.event_name,p.platform
    ,case when p.event_date between '2025-09-10' and '2025-09-16' then '2:0910~0916'
          when p.event_date between '2025-09-17' and '2025-09-23' then '3:0917~0923'
    end week
--     ,p.first_func,p.second_func
    ,case when p.first_func in ('color','hairstyles','hair') then 'hair'
          when p.second_func in ('muscle','ai_replace') then p.second_func
          when p.first_func = 'unknown' then 'unknown' else 'else' end func
    ,case when `dataintegration-265403.func`.compare_is_greater_or_equal_version(p.version,'7.16.0') then version
          else '<7.16.0'
    end version
    ,u.is_paying
    ,count(distinct p.user_pseudo_id) uv
    ,count(1) pv
from pop_exp_func p
left join user_tag u on p.user_pseudo_id = u.user_pseudo_id and p.event_date = u.event_date
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
    from `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-09-03','2025-09-30','airbrush',false)
    where
        event_name in ('ai_func_delivery','ai_func_use_result')
        and
        (
        func.getParams(event_params,'first_func').string_value in ('color','hairstyles')
        or (func.getParams(event_params,'first_func').string_value in ('retouch','hair','edit')
            and func.getParams(event_params,'second_func').string_value in ('muscle','makeup','texture','volume','ai_replace'))
        )
)
,user_tag as (
    -- 用户标签
    select event_date,platform,user_pseudo_id,uuid,AppsFlyer_ID
           ,country,app_version,is_UA,user_type,is_New,lifecycle,is_paying
    from `airbrush-1324.behavior.dws_dz_behavior_user_tag_id`
    where
    event_date between '2025-09-03' and '2025-09-30'
)

select event_date,event_name,platform
    ,case when event_date between '2025-09-03' and '2025-09-09' then '2:0903~0909'
          when event_date between '2025-09-10' and '2025-09-16' then '2:0910~0916'
          when event_date between '2025-09-17' and '2025-09-23' then '3:0917~0923'
          when event_date between '2025-09-24' and '2025-09-30' then '3:0924~0930'
    end week
--     ,a.first_func,a.second_func
    ,func
    ,case when `dataintegration-265403.func`.compare_is_greater_or_equal_version(version,'7.16.0') then version
          else '<7.16.0'
    end version
    ,is_paying
    ,case when pv<=10 then pv
          when pv<=15 then 15
          when pv<=20 then 20
          when pv<=50 then 50
          when pv<=100 then 100
    else 999 end pv
    ,count(distinct user_pseudo_id) uv
    ,sum(pv) pv_all
from
(
    select a.event_date,a.event_name,a.platform
         ,case when a.first_func in ('color','hairstyles','hair') then 'hair'
          when a.second_func in ('muscle','ai_replace') then a.second_func else 'else' end func
         ,a.version
         ,u.is_paying
         ,a.user_pseudo_id
         ,count(1) pv
    from ai_delivery a
    left join user_tag u on a.user_pseudo_id = u.user_pseudo_id and a.event_date = u.event_date
    group by 1,2,3,4,5,6,7
)
group by 1,2,3,4,5,6,7,8
;


-- label_click:label_id
select
    event_date,event_name,platform
    ,case when `dataintegration-265403.func`.compare_is_greater_or_equal_version(version,'7.16.0') then version
          else '<7.16.0'
    end version
    ,func.getParams(event_params,'label_id').string_value as label_id
    ,count(distinct user_pseudo_id) uv
    ,count(1) pv
from `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-09-10','2025-09-23','airbrush',false)
where
    event_name in ('label_click')
group by 1,2,3,4,5

union all

select
    event_date,event_name,platform
    ,case when `dataintegration-265403.func`.compare_is_greater_or_equal_version(version,'7.16.0') then version
          else '<7.16.0'
    end version
    ,'All' as label_id
    ,count(distinct user_pseudo_id) uv
    ,count(1) pv
from `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-09-10','2025-09-23','airbrush',false)
where
    event_name in ('label_click')
group by 1,2,3,4,5