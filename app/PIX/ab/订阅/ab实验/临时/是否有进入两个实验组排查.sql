with enter_test as (
select
    distinct
   date(timestamp_micros(event_timestamp),'Asia/Singapore')  enter_abtest_date, user_pseudo_id
    ,geo.country country
    ,platform
    ,func.getUserprop(user_properties,'device_id').string_value as device_id
    ,func.getParams(event_params,'current_abcode').string_value as ab_code
    ,event_timestamp
from `airbrush-1324.analytics_152810936.events_*`
   --- `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-02-28','2025-03-16','airbrush',false)
where
    event_name = 'abcode_enter_test'
    and func.getParams(event_params,'current_abcode').string_value in  ('11369','11371','11372','11373') --,'11374','11375','11376','11377','11390','11391','11392','11393'
      and _table_suffix between '20250821' and '20250829'
   and date(timestamp_micros(event_timestamp),'Asia/Singapore')  between  '2025-08-22' and'2025-08-28'
)
--'11289','11290','11291','11292','11285','11286','11287','11288'
select platform,first_abcode,count(distinct user_pseudo_id) uv,count(distinct case when code_num>1 then user_pseudo_id end) uv_bigger_then_1
from
(
    select platform,user_pseudo_id
         ,max(case when ranks=1 then ab_code end) first_abcode
         ,count(distinct ab_code) code_num
         ,max(case when ranks=2 then ab_code end) second_abcode
    from
    (
        select platform,user_pseudo_id,enter_abtest_date,ab_code
             ,row_number() over(partition by user_pseudo_id order by event_timestamp) ranks
        from enter_test
    )
    group by 1,2
)
group by 1,2
order by 1,2

--
-- select first_abcode,second_abcode,count(distinct user_pseudo_id) uv
-- from
-- (
--     select user_pseudo_id
--          ,max(case when ranks=1 then ab_code end) first_abcode
--          ,count(distinct ab_code) code_num
--          ,max(case when ranks=2 then ab_code end) second_abcode
--     from
--     (
--         select user_pseudo_id,enter_abtest_date,ab_code
--              ,row_number() over(partition by user_pseudo_id order by event_timestamp) ranks
--         from enter_test
--     )
--     group by 1
-- )
-- group by 1,2
-- order by 1,2

;

-- 问题用户id
with enter_test as (
select
    distinct
   date(timestamp_micros(event_timestamp),'Asia/Singapore')  enter_abtest_date, user_pseudo_id
    ,func.getUserprop(user_properties,'hwgid').string_value gid
    ,geo.country country
    ,platform
    ,func.getUserprop(user_properties,'device_id').string_value as device_id
    ,func.getParams(event_params,'current_abcode').string_value as ab_code
    ,device.category
    ,device.mobile_brand_name
    ,device.mobile_model_name
    ,device.mobile_os_hardware_model
    ,device.operating_system_version
    ,event_timestamp
from `airbrush-1324.analytics_152810936.events_*`
   --- `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-02-28','2025-03-16','airbrush',false)
where
    event_name = 'abcode_enter_test'
    and func.getParams(event_params,'current_abcode').string_value in  ('11369','11370','11372','11373') --,'11374','11375','11376','11377','11390','11391','11392','11393'
      and _table_suffix between '20250821' and '20250829'
   and date(timestamp_micros(event_timestamp),'Asia/Singapore')  between  '2025-08-22' and'2025-08-28'
)

select *
from
(
    select user_pseudo_id,gid,device_id,category,mobile_brand_name,mobile_model_name,mobile_os_hardware_model,operating_system_version
         ,count(distinct ab_code) code_num
         ,max(case when ranks=1 then ab_code end) first_abcode
         ,max(case when ranks=1 then enter_abtest_date end) first_enter_abtest_date
         ,max(case when ranks=2 then ab_code end) second_abcode
         ,max(case when ranks=2 then enter_abtest_date end) second_enter_abtest_date
   from
    (
        select user_pseudo_id,gid,enter_abtest_date,ab_code,device_id,category,mobile_brand_name,mobile_model_name,mobile_os_hardware_model,operating_system_version
             ,row_number() over(partition by user_pseudo_id order by event_timestamp) ranks
        from enter_test
    )
    group by 1,2,3,4,5,6,7,8
)
where code_num>1 and first_abcode!=second_abcode
limit 1000

;



-- 问题用户事件
-- 冷启动后就重新上报了新的abcode
select platform,timestamp_micros(event_timestamp) times,event_timestamp,user_pseudo_id,app_info.version,event_name
    ,func.getParams(event_params,'current_abcode').string_value as current_abcode
    ,func.getParams(event_params,'trace_info').string_value as trace_info
    ,func.getParams(event_params,'first_func').string_value as first_func
    ,func.getParams(event_params,'second_func').string_value as second_func
    ,func.getParams(event_params,'third_func').string_value as third_func
    ,func.getParams(event_params,'prf_first_func').string_value as prf_first_func
    ,func.getParams(event_params,'prf_second_func').string_value as prf_second_func
    ,func.getParams(event_params,'prf_third_func').string_value as prf_third_func
    ,func.getParams(event_params,'prf_material_type').string_value as prf_material_type
    ,func.getParams(event_params,'source_module').string_value as source_module
    ,func.getParams(event_params,'source_0').string_value as source_0
    ,func.getParams(event_params,'source_1').string_value as source_1
from `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-08-22','2025-08-28','airbrush',false)
where
    user_pseudo_id='03E022CC26B242A8BDE5725644897562'  --24E7E13C2013454EA4F48842C9E10CCF
order by event_timestamp