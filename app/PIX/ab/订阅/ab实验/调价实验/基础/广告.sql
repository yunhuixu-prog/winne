-- 广告收入数据
with ads as (
    select
        event_date
        ,user_pseudo_id
        ,platform
        ,sum(max_impression_pv  ) max_impression_pv
        ,sum(max_revenue) max_revenue
    from `dataintegration-265403.advertisement.dws_dzp_ad_placement_user_info`
    where app_name ='AirBrush'
    and event_date between  '2025-06-22' and '2025-08-17'
   group by 1,2,3
)
,enter_test as (
select
    distinct
    date(timestamp_micros(event_timestamp),'Asia/Singapore') enter_abtest_date,  user_pseudo_id
    ,geo.country country
    ,platform
   ,func.getUserprop(user_properties,'device_id').string_value as device_id
    ,func.getParams(event_params,'current_abcode').string_value as abcode
   ,event_timestamp
from
    `dataintegration-265403.analytics.dwd_dzp_events_function`( '2025-06-22' ,'2025-08-17','airbrush',false)
where
    event_name = 'abcode_enter_test'
    and func.getParams(event_params,'current_abcode').string_value in  ('11159','11160','11161','11162','11163','11164')
)
,act as (
    select
        event_date_hk, user_pseudo_id, platform,real_device_id device_id,is_new,country
    from `dataintegration-265403.dwd.dwd_dzp_behavior_active_device`
    -- FROM `dataintegration-265403.stat.stat_active_advice_detail_d`
    where
        event_date_hk between '2025-06-22' and '2025-08-17'
        and  app_name = 'AirBrush'
)
,enter AS (
-- 取活跃用户中有进入实验的用户
    select *
    from
    (
        select
            e.user_pseudo_id,e.platform,e.abcode,e.enter_abtest_date
            ,row_number() over(partition by e.user_pseudo_id order by event_timestamp) ranks
        from  act fa
        join
           enter_test e ON e.user_pseudo_id = fa.user_pseudo_id and e.enter_abtest_date = fa.event_date_hk
        where e.user_pseudo_id is not null
    )
    where ranks=1
)

select
  a.platform,a.abcode
  ,case when abcode in ('11159','11162') then '对照组'
         when abcode in ('11160','11163') then '实验组A'
         when abcode in ('11161','11164') then '实验组B'
        end code
  ,sum(max_revenue) ads_bookings
  ,sum(max_impression_pv ) max_impression_pv
  ,sum(max_revenue)/sum(max_impression_pv )*1000 eCPM
from
    enter a left join ads  b on a.user_pseudo_id = b.user_pseudo_id and a.platform = b.platform
    where  b.event_date >= a.enter_abtest_date
group by 1,2
order by 1,2