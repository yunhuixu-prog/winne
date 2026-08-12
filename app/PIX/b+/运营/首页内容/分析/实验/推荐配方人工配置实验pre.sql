-- 首页整体看板
drop table if exists `beautyplus-bc0ed.temp.temp_homepage_overall_winni`;
create table if not exists `beautyplus-bc0ed.temp.temp_homepage_overall_winni` as
with
abcode as
(
    SELECT
        date_p, cast(ab_code as string) code
    , field as firebase_id
    , country_id
    , case when is_app_new='2' then 'New' when is_app_new='1' then 'Old' end as is_new
    , case when app_key in ('F9B069901A7B2E8D') then 'IOS' when app_key in ('C6FF0769324CD2F1') then 'ANDROID' end as platform,receive_time as timestamp
    FROM
    `dataintegration-265403.abtest.abtest_odz_flow`--2.第一次进入实验用户
    WHERE
        date_p>='2024-11-21' and date_p<='2024-11-28'
        and cast(ab_code as string) in ('10979','10980','10981')
        and field_type = 1 --field是1 firebase_id field是2 gid field是3 device_id
        and app_key in ('F9B069901A7B2E8D','C6FF0769324CD2F1')
)
,
user_info as
(
    select
        event_date_hk
        ,app_name
        ,platform
        ,country
        ,user_pseudo_id
        ,max(uuid) uuid
        ,max(is_new) is_new
        ,max(is_UA) is_UA
        ,max(app_version) app_version
    from
        `dataintegration-265403.stat.stat_active_advice_detail_d`
    where
        event_date_hk between '2024-11-21' and '2024-11-28'
        and app_name='BeautyPlus'
    group by 1,2,3,4,5
)
,
event as
(
  select
      event_date,platform
      ,app_info.version app_version
      ,event_name event_action
      ,event_name
      ,event_timestamp
      ,user_pseudo_id
--       ,uuid
--       ,`dataintegration-265403.func`.getUserprop(user_properties,'hwgid').string_value gid
      ,`dataintegration-265403.func`.getParams(event_params,'模块类型').string_value as module
      ,`dataintegration-265403.func`.getParams(event_params,'模块id').string_value as module_id
      ,`dataintegration-265403.func`.getParams(event_params,'内容类型').string_value as content_type
--       ,`dataintegration-265403.func`.getParams(event_params,'内容id').string_value as content_id
      ,coalesce(`dataintegration-265403.func`.getParams(event_params,'time').string_value,cast(`dataintegration-265403.func`.getParams(event_params,'time').int_value as string)) homepage_time
      ,coalesce(`dataintegration-265403.func`.getParams(event_params,'模块位置').string_value,cast(`dataintegration-265403.func`.getParams(event_params,'模块位置').int_value as string)) module_location
      ,0.0 paid_amounts
  from
    `dataintegration-265403.analytics.dwd_dzp_events_function`('2024-11-21','2024-11-28', 'beautyplus', false)
  where
      event_name in ('homepageappr_bd','home_second_page_appr_bd','home_page_time_bd')

    union all

    select event_date,platform,app_version,event_action,event_name,event_timestamp
        ,user_pseudo_id
--         ,uuid
        ,module,module_id,content_type
        ,cast(null as string) homepage_time
        ,cast(module_location as string) module_location
        ,paid_amounts
    from `dataintegration-265403.duffle_fin.dwd_dz_marvel_home_content`
    where event_date between '2024-11-21' and '2024-11-28'
        and app_name='BeautyPlus'
)

select
    m.event_date,
    m.event_action,
    m.event_name,
    m.module_location,
    m.homepage_time,
    m.paid_amounts,
    m.module,
    m.module_id,
    m.content_type,
    m.app_version,
    b.platform,
    b.country,
    b.is_UA,
    case
    when b.is_new = 1 then 'New'
    else 'Old'
    end as is_new,
    case
    when b.country in ('South Korea', 'Thailand', 'Japan', 'United States') then b.country
    else 'general'
    end as region,
    m.user_pseudo_id,
--     m.uuid,
    case
    when a.code in ('10979') then '对照组'
    when a.code in ('10980') then '实验组A'
    when a.code in ('10981') then '实验组B'
    end as code_type,
    count(1) pv
from event m
join abcode a
on m.user_pseudo_id=a.firebase_id and m.platform=a.platform and m.event_timestamp>=a.timestamp-15000000
join user_info b on m.user_pseudo_id = b.user_pseudo_id and m.event_date = b.event_date_hk
group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17

