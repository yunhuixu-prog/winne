-- 过去7天内的人均活跃天数
with enter_test as (
    -- 进入实验的人 
select 
    user_pseudo_id
    ,geo.country country
    ,platform 
    ,func.getUserprop(user_properties,'device_id').string_value as device_id
    ,func.getParams(event_params,'current_abcode').string_value as ab_code
    , date(timestamp_micros(event_timestamp),'Asia/Singapore')  date
  --  ,event_timestamp
from `airbrush-1324.analytics_152810936.events_*` 
   --- `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-02-28','2025-03-16','airbrush',false)
where
    event_name = 'abcode_enter_test' 
    and func.getParams(event_params,'current_abcode').string_value in  ('11072','11073','11074','11075','11076','11077')
    and _table_suffix between '20250402' and '20250421'
    and date(timestamp_micros(event_timestamp),'Asia/Singapore')  between  '2025-04-03' and'2025-04-20'
) 
,mact as (
  -- 限制观测活跃天数的日期是在进入实验之后的 
select
  distinct  a.platform,a.user_pseudo_id,ab_code
    ,event_date_hk
 from
    `dataintegration-265403.stat.stat_active_advice_detail_d` a
     join enter_test b on a.user_pseudo_id = b.user_pseudo_id 
 where a.app_name='AirBrush'  
  and a.event_date_hk between'2025-04-03' and'2025-04-20'
  and b.date <= a.event_date_hk
) 
,act as (
  -- 限制活跃用户的人为进入实验的人，，不需要限制进入实验后的日期，因为需要计算实验开始前几天再往前推的活跃天数
  select
    distinct a.platform,a.user_pseudo_id
    ,event_date_hk
 from
    `dataintegration-265403.stat.stat_active_advice_detail_d`a
     join enter_test b on a.user_pseudo_id = b.user_pseudo_id 
 where a.app_name='AirBrush'  
 and a.event_date_hk >='2025-03-01'
)
select 
    platform,ab_code
    ,sum(uv*days) agg_days
    ,sum(uv) agg_uv
    
from
(
select 
    event_date_hk,platform,ab_code
    ,days 
    ,count(distinct user_pseudo_id ) uv
from
  (
  select 
     a.event_date_hk,a.platform,a.user_pseudo_id,a.ab_code,count(distinct b.event_date_hk) days
  from mact a left join act b on a.user_pseudo_id = b.user_pseudo_id
  where 
      b.event_date_hk between date_sub(a.event_date_hk,interval 6 day) and a.event_date_hk
    group by 1,2,3,4
  )
group by 1,2,3,4
)
group by 1,2
order by 1,2