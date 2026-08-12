-- 代码一
with all_data_detail as (
select
*
FROM
  `dataintegration-265403.dwd.dwd_dzp_behavior_ab_edit_detail`
WHERE
    event_date between '2025-07-20' and '2025-07-26'
    and case function_level when '1' then function1 is not null
    when '2' then function1 is not null and function2 is not null
    when '3' then function1 is not null and function2 is not null and function3 is not null
    when '4' then function1 is not null and function2 is not null and function3 is not null and function4 is not null
    when '5' then function1 is not null and function2 is not null and function3 is not null and function4 is not null and function5 is not null
    when '6' then function1 is not null and function2 is not null and function3 is not null and function4 is not null and function5 is not null and function6 is not null
    end
 ),
 user_specify_function as (
-- 捞出指定功能 与 可能对应的层级
  select
    user_pseudo_id,function_level,specify_function,event_date,function_level_string
  from `dataintegration-265403.behavior.dws_dzp_behavior_ab_edit_user_specify_function_info`
  where event_date between '2025-07-20' and '2025-07-26'
)
select
*
from (
select
 app_name,
  platform,
  country,
  is_ua,
  is_valid_paid_1d,
  user_type,
  lifecycle,
  paid_type,
  app_version,
  all_data_detail.event_date,
  user_specify_function.specify_function,
all_data_detail.function as sub_function,
 COUNT(DISTINCT
  IF
    (action='点击',all_data_detail.user_pseudo_id,NULL)) AS enter_uv_1d,
    countif(action='点击') as enter_pv_1d,
  COUNT(DISTINCT
  IF
    (action='使用',all_data_detail.user_pseudo_id,NULL)) AS use_uv_1d,
    countif(action='使用') as use_pv_1d,
  COUNT(DISTINCT
  IF
    (action='使用'
      AND is_effect='1',all_data_detail.user_pseudo_id,NULL)) AS effect_use_uv_1d,
      countif(action='使用'and is_effect='1') as effect_use_pv_1d,
  COUNT(DISTINCT
  IF
    (action='保存',all_data_detail.user_pseudo_id,NULL)) AS save_uv_1d,
    countif(action='保存') as save_pv_1d,

from user_specify_function
join all_data_detail  -- 拿到指定功能子功能的漏斗指标
on
case user_specify_function.function_level
  when '1' then user_specify_function.function_level_string = all_data_detail.function1
  when '2' then user_specify_function.function_level_string = concat(all_data_detail.function1,all_data_detail.function2)
  when '3' then user_specify_function.function_level_string = concat(all_data_detail.function1,all_data_detail.function2,all_data_detail.function3)
  when '4' then user_specify_function.function_level_string = concat(all_data_detail.function1,all_data_detail.function2,all_data_detail.function3,all_data_detail.function4)
  when '5' then user_specify_function.function_level_string = concat(all_data_detail.function1,all_data_detail.function2,all_data_detail.function3,all_data_detail.function4,all_data_detail.function5)
  end
and cast(user_specify_function.function_level as int64)+1= cast(all_data_detail.function_level as int64)
and all_data_detail.event_date = user_specify_function.event_date
and all_data_detail.user_pseudo_id = user_specify_function.user_pseudo_id
group by 1,2,3,4,5,6,7,8,9,10,11,12
)
where (enter_uv_1d>0 or use_uv_1d >0)

-- 代码二-临时用
with eves as (
select
    event_date date,country,platform,user_pseudo_id,is_ua,user_type,is_new
    ,event_name,event_timestamp,action,function_level,function0,function1,function2,function3,function4
FROM
  `dataintegration-265403.dwd.dwd_dzp_behavior_ab_edit_detail`
WHERE
    event_date between '2025-07-20' and '2025-07-26'
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
select function_level,date,platform
       ,function1 first_func,function2 second_func,function3 third_func
       ,count(distinct case when action = '点击' then user_pseudo_id end) func_enter_uv
       ,count(distinct case when action = '使用' then user_pseudo_id end) func_use_uv
       ,count(distinct case when action = '保存' then user_pseudo_id end) func_save_uv
       ,count(case when action = '点击' then 1 end) func_enter_pv
       ,count(case when action = '使用' then 1 end) func_use_pv
       ,count(case when action = '保存' then 1 end) func_save_pv
from eves
where is_new='New'
group by 1,2,3,4,5,6


