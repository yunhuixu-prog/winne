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
    and event_date between  '2025-04-03' and'2025-04-20'
   group by 1,2,3
)
,enter as (
select 
    distinct 
    date(timestamp_micros(event_timestamp),'Asia/Singapore') event_date,  user_pseudo_id
    ,geo.country country
    ,platform 
   -- ,func.getUserprop(user_properties,'device_id').string_value as device_id
    ,func.getParams(event_params,'current_abcode').string_value as abcode
  --  ,event_timestamp
from
    `dataintegration-265403.analytics.dwd_dzp_events_function`( '2025-04-03' ,'2025-04-20','airbrush',false)
where
    event_name = 'abcode_enter_test' 
    and func.getParams(event_params,'current_abcode').string_value in  ('11072','11073','11074','11075','11076','11077')
)

select 
  a.platform,a.abcode
  ,sum(max_revenue) ads_bookings
  ,sum(max_impression_pv ) max_impression_pv 
  ,sum(max_revenue)/sum(max_impression_pv )*1000 eCPM
from 
    enter a left join ads  b on a.user_pseudo_id = b.user_pseudo_id and a.platform = b.platform  
    where  b.event_date >= a.event_date
group by 1,2
order by 1,2