select app_name,event_date_hk Date,platform
  ,case when app_version>='7.7.120' then app_version else 'old version' end app_version
  ,sum(dau) dau,sum(day1_retention) day1_retention
from dataintegration-265403.active_retention.ads_dz_appversion_day_rentention
where event_date_hk between '2024-06-08' and '2024-07-07' and
app_name in ('Beauty Plus Cam','BeautyPlus') and platform='ANDROID' and country='India'
-- (
--   (app_name in ('BeautyPlus')
--   and platform='ANDROID' and country='India')
--   or app_name in ('Beauty Plus Cam')
-- )
group by 1,2,3,4
;
select app_name APP,event_date_hk Date,platform Platform,is_new `is New`,is_ua `is UA`
  ,sum(dau) DAU,sum(day1_retention) `Next day retention users`
from dataintegration-265403.active_retention.ads_dz_appversion_day_rentention
where event_date_hk between '2024-06-08' and '2024-07-07' and
app_name in ('Beauty Plus Cam','BeautyPlus') and platform='ANDROID' and country='India'
-- (
--   (app_name in ('BeautyPlus')
--   and platform='ANDROID' and country='India')
--   or app_name in ('Beauty Plus Cam')
-- )
group by 1,2,3,4,5

-- 22年12月距今
select app_name APP,event_date_hk Date
  ,sum(dau) DAU,sum(day1_retention) `Next day retention users`
from dataintegration-265403.active_retention.ads_dz_appversion_day_rentention
where event_date_hk between '2022-12-01' and '2024-06-30' and
    app_name in ('Beauty Plus Cam')
group by 1,2
order by 1,2

-- 分国家新老渠道
select app_name APP,event_date_hk Date,is_new,is_ua,case when country in ('India') then country else 'else' end country
  ,sum(dau) DAU,sum(day1_retention) `Next day retention users`
from dataintegration-265403.active_retention.ads_dz_appversion_day_rentention
where event_date_hk between '2022-12-01' and '2024-06-30' and
    app_name in ('Beauty Plus Cam')
group by 1,2,3,4,5
order by 1,2,3,4,5


-- 低版本强升结果
select
    event_date_hk
    ,app_version
    ,user_pseudo_id
    ,max(is_new) is_new
    ,max(is_UA) is_UA
from
    `dataintegration-265403.stat.stat_active_advice_detail_d`
where
    event_date_hk between '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}' and '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
    and app_name in ('Beauty Plus Cam')
group by 1,2,3,4,5

select
        event_date
        ,event_timestamp
        ,event_name
--         ,event_params
        ,user_pseudo_id
        ,country
        ,platform
        ,version
        ,language
    from
        `dataintegration-265403.analytics.dwd_dzp_events_function`('2024-07-03',
        '2024-07-07','beautypluscam',false)
    where event_name in ('homepageappr_bd','home_page_time_bd','selfietakepic_bd','home_clk_edit_bd','home_clk_selfie_bd','home_clk_beautify_bd')
    and version<'7.7.021'

select
        event_date
        ,event_timestamp
        ,event_name
--         ,event_params
        ,user_pseudo_id
        ,country
        ,platform
        ,version
        ,language
    from
        `dataintegration-265403.analytics.dwd_dzp_events_function`('2024-07-03',
        '2024-07-07','beautypluscam',false)
    where user_pseudo_id='3f8bcffe269d7763aa68f0615b93550e'
order by 2