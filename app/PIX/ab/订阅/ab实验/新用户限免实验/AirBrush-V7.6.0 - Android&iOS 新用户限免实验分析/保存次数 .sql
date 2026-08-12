with enter_test as (
select 
    distinct 
   date(timestamp_micros(event_timestamp),'Asia/Singapore')  date, user_pseudo_id
    ,geo.country country
    ,platform 
    ,func.getUserprop(user_properties,'device_id').string_value as device_id
    ,func.getParams(event_params,'current_abcode').string_value as ab_code
  --  ,event_timestamp
from `airbrush-1324.analytics_152810936.events_*` 
   --- `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-02-28','2025-03-16','airbrush',false)
where
    event_name = 'abcode_enter_test' 
    and func.getParams(event_params,'current_abcode').string_value in  ('11072','11073','11074','11075','11076','11077')
      and _table_suffix between '20250402' and '20250421'
   and date(timestamp_micros(event_timestamp),'Asia/Singapore')  between  '2025-04-03' and'2025-04-20'
)
, eves as (
select  
    date(timestamp_micros(event_timestamp),'Asia/Singapore')   date
    ,platform,user_pseudo_id,geo.country country 
    ,case 
        when event_name in ('edit_enter', 'camera_enter','video_start_edit') then 'enter'
        when event_name in ('edit_save', 'camera_save','video_save') then  'save'
        else event_name
    end event_name
    ,func.getUserprop(user_properties,'device_id').string_value as device_id 
   -- ,event_timestamp
   
    ,count(*)pv
from `airbrush-1324.analytics_152810936.events_*` 
  --  `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-02-28','2025-03-16','airbrush',false) -- 这个表跑不动 
where 
    event_name in ('edit_enter','edit_save')
    and _table_suffix between'20250402' and '20250421'
   and date(timestamp_micros(event_timestamp),'Asia/Singapore')  between  '2025-04-03' and'2025-04-20'
group by 1,2,3,4,5,6,7,8,9,10,11,12,13
)

,fe as( -- 限制进入实验的人,且实验触发日期在进入实验之后
    select 
        a.*except(ab_code),b.ab_code
    from
        eves 
         join enter_test b on a.device_id= b.device_id
    where b.date  <= a.date -- 事件发生的日期均 >= 进入实验日期
)

 
select 
    a.platform,a.ab_code
    ,count(distinct a.device_id) enter_abtest_uv
-- 用户行为
    ,count(distinct case when a.event_name ='enter' then a.device_id  end) enter_uv
    ,count(distinct case when a.event_name ='save' then a.device_id  end) save_uv
   
    ,sum(case when a.event_name ='enter' then pv end) enter_pv
    ,sum( case when a.event_name ='save' then pv  end) save_pv

from fe a 