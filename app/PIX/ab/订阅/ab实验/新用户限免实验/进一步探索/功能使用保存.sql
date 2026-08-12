drop table if exists `dataintegration-265403.temp.new_user_behavior_analysis_winne_ad_1`;
create table if not exists `dataintegration-265403.temp.new_user_behavior_analysis_winne_ad_1` as

with eves as (
select
    event_date date,country,platform,user_pseudo_id,is_ua,user_type,is_new
    ,event_name,event_timestamp,action,function_level,function0,function1,function2,function3,function4
FROM
  `dataintegration-265403.dwd.dwd_dzp_behavior_ab_edit_detail`
WHERE
    event_date between '2025-04-03' and '2025-04-20'
    and app_name='AirBrush'
    and function0='修图'
    and case function_level when '1' then function1 is not null
    when '2' then function1 is not null and function2 is not null
    when '3' then function1 is not null and function2 is not null and function3 is not null
    when '4' then function1 is not null and function2 is not null and function3 is not null and function4 is not null
    when '5' then function1 is not null and function2 is not null and function3 is not null and function4 is not null and function5 is not null
    when '6' then function1 is not null and function2 is not null and function3 is not null and function4 is not null and function5 is not null and function6 is not null
    end
 )
,enter_test as (
select
    distinct
   date(timestamp_micros(event_timestamp),'Asia/Singapore')  date, user_pseudo_id
    ,geo.country country
    ,platform
    ,func.getUserprop(user_properties,'device_id').string_value as device_id
    ,func.getParams(event_params,'current_abcode').string_value as ab_code
  --  ,event_timestamp
-- from `airbrush-1324.analytics_152810936.events_*`
from `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-04-03','2025-04-20','airbrush',false)
where
    event_name = 'abcode_enter_test'
    and func.getParams(event_params,'current_abcode').string_value in  ('11072','11073','11074','11075','11076','11077')
--       and _table_suffix between '20250719' and '20250727'
--    and date(timestamp_micros(event_timestamp),'Asia/Singapore')  between  '2025-04-03' and'2025-04-20'
)
,fe as( -- 限制进入实验的人,且实验触发日期在进入实验之后
    select
        a.*,b.ab_code,b.date enter_abtest_date
    from eves a
         join enter_test b on a.user_pseudo_id= b.user_pseudo_id
    where b.date  <= a.date -- 事件发生的日期均 >= 进入实验日期
)

select f.*
from fe f
;


select function_level,date,ab_code
       ,case when ab_code in ('11072','11075') then '对照组'
         when ab_code in ('11073','11076') then '实验组A'
         when ab_code in ('11074','11077') then '实验组B'
        end code
       ,platform
       ,function1 first_func,function2 second_func,function3 third_func
       ,count(distinct case when action = '点击' then user_pseudo_id end) func_enter_uv
       ,count(distinct case when action = '使用' then user_pseudo_id end) func_use_uv
       ,count(distinct case when action = '保存' then user_pseudo_id end) func_save_uv
       ,count(case when action = '点击' then 1 end) func_enter_pv
       ,count(case when action = '使用' then 1 end) func_use_pv
       ,count(case when action = '保存' then 1 end) func_save_pv
from `dataintegration-265403.temp.new_user_behavior_analysis_winne_ad_1`
where date_diff(date,enter_abtest_date,day)=0
group by 1,2,3,4,5,6,7,8
;









