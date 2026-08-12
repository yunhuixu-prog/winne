select event_date_hk,a.is_new,a.version,a.dau,retention_ratio,uninstall_uv
from
(
  select event_date_hk,is_new,case when app_version>='7.7.010' then 'new' else 'old' end as version,sum(dau) dau
        ,round(sum(retention_dau)/sum(dau),4) retention_ratio
  from dataintegration-265403.active_retention.ads_dz_appversion_dau_rentention
  where event_date_hk>='2023-11-20'
      and app_name in ('Beauty Plus Cam') --and is_new in ('New user') --and app_version >= '7.1.070'
  group by 1,2,3
) a
left join
(
  select event_date,case when is_new='New users' then 'New user' else 'Old user' end is_new
    ,case when app_version>='7.7.010' then 'new' else 'old' end as version,sum(uv) uninstall_uv
  -- select *
  from `beauty-cam-new.event_data.dws_da_uninstall_event`
  -- limit 10
  where event_date>='2023-11-20'
  group by 1,2,3
) b
on a.event_date_hk=b.event_date and a.is_new=b.is_new and a.version=b.version
order by 1,2,3

-- top 国家
select country
    -- ,case when app_version>='7.7.013' then '>=7.7.013' when app_version>='7.7.010' then '>=7.7.010' else 'old' end as version
    ,sum(dau) dau
    ,round(sum(retention_dau)/sum(dau),4) retention_ratio
from dataintegration-265403.active_retention.ads_dz_appversion_dau_rentention
where event_date_hk>='2023-12-10'
  and app_name in ('Beauty Plus Cam') --and is_new in ('New user') --and app_version >= '7.1.070'
group by 1
order by 2 desc


-- select event_date_hk,a.is_new,a.version,a.dau,retention_ratio,uninstall_uv
select coalesce(event_date_hk,event_date) event_date
        ,coalesce(a.is_new,b.is_new) is_new
        ,coalesce(a.is_ua,b.is_ua) is_ua
        ,coalesce(a.country,b.country) country
        ,a.dau,retention_ratio,uninstall_uv
from
(
  select event_date_hk,is_new,is_ua,case when country in ('India','Philippines','Indonesia') then country when country is null then country else 'else' end country
        -- ,case when app_version>='7.7.013' then '>=7.7.013' when app_version>='7.7.010' then '>=7.7.010' else 'old' end as version
        ,sum(dau) dau
        ,round(sum(retention_dau)/sum(dau),4) retention_ratio
  from dataintegration-265403.active_retention.ads_dz_appversion_dau_rentention
  where event_date_hk>='2023-11-20'
      and app_name in ('Beauty Plus Cam') --and is_new in ('New user') --and app_version >= '7.1.070'
  group by 1,2,3,4
) a
full join
(
  select event_date
    ,case when is_ua is null then null when is_new='New users' then 'New user' else 'Old user' end is_new
    ,is_ua,case when country in ('India','Philippines','Indonesia') then country when country is null then country else 'else' end country
    -- ,case when app_version>='7.7.013' then '>=7.7.013' when app_version>='7.7.010' then '>=7.7.010' else 'old' end as version
    ,sum(uv) uninstall_uv
  -- select *
  from `beauty-cam-new.event_data.dws_da_uninstall_event`
  -- limit 10
  where event_date>='2023-11-20'
--   where event_date='2023-11-26'
  group by 1,2,3,4
) b
on a.event_date_hk=b.event_date and a.is_new=b.is_new and a.is_ua=b.is_ua and a.country=b.country --and a.version=b.version
order by 1,2,3,4


-- select event_date,is_new
--     ,case when app_version>='7.7.010' then 'new' else 'old' end as version
--     ,sum(selfiesave_uv) selfiesave_uv
--     ,sum(beautifysave_uv) beautifysave_uv
--     ,sum(beautifysave_second_uv) beautifysave_second_uv
--     ,sum(ai_editor_save_clk_uv) ai_editor_save_clk_uv
-- from `beauty-cam-new.event_data.dws_da_save_event`
-- where event_date>='2023-11-20'
-- group by 1,2,3
-- order by 1,2,3

-- select event_date,is_new
--     ,case when app_version>='7.7.010' then 'new' else 'old' end as version
--     ,sum(selfiesave_uv) selfiesave_uv
--     ,sum(beautifysave_uv) beautifysave_uv
--     ,sum(beautifysave_second_uv) beautifysave_second_uv
--     ,sum(ai_editor_save_clk_uv) ai_editor_save_clk_uv
--     ,sum(selfiesave_pv) selfiesave_pv
--     ,sum(beautifysave_pv) beautifysave_pv
--     ,sum(beautifysave_second_pv) beautifysave_second_pv
--     ,sum(ai_editor_save_clk_pv) ai_editor_save_clk_pv
-- from
-- (
--     select
--         event_date
--         ,platform
--         ,app_version
--         ,is_new
--         ,is_UA
--         ,user_type
--         ,case when country='China' then 'China Mainland' else country end country
--         ,if_high
--         ,is_pay
--
--         ,coalesce(count(case when event_name='selfiesave_bd' then user_pseudo_id end),0) selfiesave_uv
--         ,coalesce(sum(case when event_name='selfiesave_bd' then pv end),0) selfiesave_pv
--         ,coalesce(count(case when event_name in ('ad_beautifysvclk','beautifysave_bd') then user_pseudo_id end),0) beautifysave_uv
--         ,coalesce(sum(case when event_name in ('ad_beautifysvclk','beautifysave_bd') then pv end),0) beautifysave_pv
--         ,coalesce(count(case when event_name='beautifysave_second_bd' then user_pseudo_id end),0) beautifysave_second_uv
--         ,coalesce(sum(case when event_name='beautifysave_second_bd' then pv end),0) beautifysave_second_pv
--         ,coalesce(count(case when event_name='ai_editor_save_clk_bd' then user_pseudo_id end),0) ai_editor_save_clk_uv
--         ,coalesce(sum(case when event_name='ai_editor_save_clk_bd' then pv end),0) ai_editor_save_clk_pv
--     from
--         `beauty-cam-new.temp.dwd_da_save_event_temp`
--     where country!="" and
--     (case when event_name in ('beautifysave_bd') then app_version>='7.7.010'
--           when event_name in ('ad_beautifysvclk') then app_version<'7.7.010'
--     else 1=1 end)
--     group by
--         1,2,3,4,5,6,7,8,9
-- )
-- group by 1,2,3
-- order by 1,2,3


-- 新用户行为情况
with
user_activity_pre as
(
    select
        distinct event_date,event_name,user_pseudo_id,platform,version
    from `dataintegration-265403.analytics.dwd_dzp_events_function`('2023-11-20', '2023-12-27', 'beautypluscam', false)
    where event_name in ('selfietakepic_bd','home_clk_edit_bd','home_clk_selfie_bd','home_clk_beautify_bd')
)
,
user_info as
(
    select
        user_pseudo_id
        ,is_new
        ,is_UA
        ,user_type
        ,country
        ,event_date_hk
        ,platform
    from
        `dataintegration-265403.stat.stat_active_advice_detail_d` u
    where
        -- u.event_date_hk between date'2023-07-01' and date'2023-07-05'
        -- u.event_date_hk between date'2022-10-01' and date_sub(current_date,interval'1'day)
        u.event_date_hk>='2023-11-20'
        and u.event_date_hk<='2023-12-27'
)
,
user_activity as
(
    select event_date,case when u.is_new=1 then 'New user' else 'Old user' end is_new,is_ua
        ,case when version>='7.7.013' then '>=7.7.013' when version>='7.7.010' then '>=7.7.010' else 'old' end as version
        ,count(distinct case when event_name='selfietakepic_bd' then a.user_pseudo_id end) take_photo_uv
        ,count(distinct case when event_name='home_clk_selfie_bd' then a.user_pseudo_id end) selfie_clk_uv
        ,count(distinct case when event_name='home_clk_beautify_bd' then a.user_pseudo_id end) beauty_clk_uv
    from user_activity_pre a
    join user_info u
    on a.user_pseudo_id=u.user_pseudo_id
                and a.event_date=u.event_date_hk
                and a.platform=u.platform
    group by 1,2,3,4
)

-- select *
-- from user_activity
-- where event_date>='2023-12-20'

select a.event_date_hk event_date
        ,a.is_new
        ,a.is_ua
--         ,a.country
        ,a.version
        ,a.dau,selfiesave_uv,beautifysave_uv,selfiesave_pv,beautifysave_pv
        ,take_photo_uv,selfie_clk_uv,beauty_clk_uv
from
(
  select event_date_hk,is_new,is_ua
--        ,case when country in ('India','Philippines','Indonesia') then country when country is null then country else 'else' end country
        ,case when app_version>='7.7.013' then '>=7.7.013' when app_version>='7.7.010' then '>=7.7.010' else 'old' end as version
        ,sum(dau) dau
        ,round(sum(retention_dau)/sum(dau),4) retention_ratio
  from dataintegration-265403.active_retention.ads_dz_appversion_dau_rentention
  where event_date_hk>='2023-11-20'
      and app_name in ('Beauty Plus Cam') --and is_new in ('New user') --and app_version >= '7.1.070'
  group by 1,2,3,4
) a
left join
(
  select event_date
        ,case when is_new='New users' then 'New user' else 'Old user' end is_new
        ,is_ua
        ,case when app_version>='7.7.013' then '>=7.7.013' when app_version>='7.7.010' then '>=7.7.010' else 'old' end as version
        ,sum(selfiesave_uv) selfiesave_uv
        ,sum(beautifysave_uv) beautifysave_uv
--         ,sum(beautifysave_second_uv) beautifysave_second_uv
--         ,sum(ai_editor_save_clk_uv) ai_editor_save_clk_uv
        ,sum(selfiesave_pv) selfiesave_pv
        ,sum(beautifysave_pv) beautifysave_pv
--         ,sum(beautifysave_second_pv) beautifysave_second_pv
--         ,sum(ai_editor_save_clk_pv) ai_editor_save_clk_pv
    from `beauty-cam-new.event_data.dws_da_save_event`
    group by 1,2,3,4
) b
on a.event_date_hk=b.event_date and a.is_new=b.is_new and a.is_ua=b.is_ua and a.version=b.version --and a.country=b.country
-- 再看看其他行为
left join user_activity u
on a.event_date_hk=u.event_date and a.is_new=u.is_new and a.is_ua=u.is_ua and a.version=u.version --and a.country=u.country
order by 1,2,3,4




