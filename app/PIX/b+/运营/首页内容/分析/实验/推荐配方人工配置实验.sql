
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
-- ,
-- user_homepage_info as
-- (
--     select distinct
--     from `beautyplus-bc0ed.temp.temp_homepage_overall_winni`
--     where event_name in ('home_second_page_appr_bd','home_page_time_bd')
--     group by
-- )

select
--     date_p event_date,
    '0:enter abtest' event_action
    ,'All' module
    ,'All' module_type
--     ,null module_id,null content_type
    ,is_new
    ,cast(null as string) is_UA,cast(null as string) region,platform
    ,case
        when code in ('10979') then '对照组'
        when code in ('10980') then '实验组A'
        when code in ('10981') then '实验组B'
    end as code_type
    ,count(distinct firebase_id) uv
    ,0 pv
from abcode
group by 1,2,3,4,5,6,7,8

union all

select
--     event_date,
    case when event_action = 'impression' then '1:exposure'
          when event_action = 'click' then '2:click'
          when event_action = 'save' then '3:save'
          when event_action = 'subscription' then '4:sub'
    else event_action
    end event_action
    ,'All' module
    ,'All' module_type
--     ,module_id,content_type
    ,is_new,is_UA,region,platform
    ,code_type
    ,count(distinct user_pseudo_id) uv
    ,sum(pv) pv
from `beautyplus-bc0ed.temp.temp_homepage_overall_winni`
where event_name!='home_page_time_bd' and coalesce(module,'-') != '金刚区'
group by 1,2,3,4,5,6,7,8

union all

select
--     event_date,
    case when event_action = 'impression' then '1:exposure'
          when event_action = 'click' then '2:click'
          when event_action = 'save' then '3:save'
          when event_action = 'subscription' then '4:sub'
    end event_action
    ,module
    ,case when module in ('金刚区','Banner','轮播图','专题') then '人工配置'
     else module
    end module_type
--     ,module_id,content_type
    ,is_new,is_UA,region,platform
    ,code_type
    ,count(distinct user_pseudo_id) uv
    ,sum(pv) pv
from `beautyplus-bc0ed.temp.temp_homepage_overall_winni`
where module is not null and coalesce(module,'-') != '金刚区'
group by 1,2,3,4,5,6,7,8


union all

-- 看停留时长
select
--     event_date,
    'homepage time' event_action
    ,'All' module
    ,'All' module_type
--     ,null module_id,null content_type
    ,is_new,is_UA,region,platform
    ,code_type
    ,count(distinct user_pseudo_id) uv
    ,round(sum(homepage_time/1000)) pv
from
(
    select event_date
        ,user_pseudo_id
        ,is_new,is_UA,region,platform
        ,code_type
        ,sum(cast(homepage_time as int64)*pv) homepage_time
    from `beautyplus-bc0ed.temp.temp_homepage_overall_winni`
    where event_name='home_page_time_bd'
    group by 1,2,3,4,5,6,7
)
where homepage_time is not null and homepage_time>0 and homepage_time<=24*60*60*1000
group by 1,2,3,4,5,6,7,8