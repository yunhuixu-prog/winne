drop table if exists `dataintegration-265403.temp.new_user_behavior_analysis`;
create table if not exists `dataintegration-265403.temp.new_user_behavior_analysis` as

with eves as (
select
    date(timestamp_micros(event_timestamp),'Asia/Singapore')   date
    ,platform,user_pseudo_id,geo.country country
    ,event_name
    ,func.getUserprop(user_properties,'device_id').string_value as device_id
    ,event_timestamp
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
    ,func.getParams(event_params,'SKU').string_value as sku
    ,func.getParams(event_params,'order_id').string_value as order_id
    ,func.getParams(event_params,'current_abcode').string_value  ab_code
from `airbrush-1324.analytics_152810936.events_*`
  --  `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-02-28','2025-03-16','airbrush',false) -- 这个表跑不动
where
    event_name in ('edit_enter','edit_save','w_subscription_enter','w_subscription_click','w_subscription_success'
    ,'first_func_enter','second_func_enter','third_func_enter','first_func_use','second_func_use','third_func_use'
    )
    and _table_suffix between'20250402' and '20250421'
   and date(timestamp_micros(event_timestamp),'Asia/Singapore')  between  '2025-04-03' and'2025-04-20'
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
from `airbrush-1324.analytics_152810936.events_*`
   --- `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-02-28','2025-03-16','airbrush',false)
where
    event_name = 'abcode_enter_test'
    and func.getParams(event_params,'current_abcode').string_value in  ('11072','11073','11074','11075','11076','11077')
      and _table_suffix between '20250402' and '20250421'
   and date(timestamp_micros(event_timestamp),'Asia/Singapore')  between  '2025-04-03' and'2025-04-20'
)
,fe as( -- 限制进入实验的人,且实验触发日期在进入实验之后
    select
        a.*except(ab_code),b.ab_code,b.date enter_abtest_date
    from
        (select * from eves
        where event_name <>  'abcode_enter_test'
        )a
         join enter_test b on a.user_pseudo_id= b.user_pseudo_id
    where b.date  <= a.date -- 事件发生的日期均 >= 进入实验日期
)
,trace_rank as
(
    select *
        , row_number() over(partition by user_pseudo_id order by event_timestamp) trace_rank
        , row_number() over(partition by date,user_pseudo_id order by event_timestamp) trace_day_rank
    from
    (
        select date, platform, user_pseudo_id, trace_info, min(event_timestamp) event_timestamp
        from fe
        where event_name='edit_enter'
        and trace_info is not null
        group by 1,2,3,4
    )
)

select f.*,t.trace_rank,t.trace_day_rank
from fe f
left join trace_rank t
on f.date=t.date and f.platform=t.platform and f.user_pseudo_id=t.user_pseudo_id and f.trace_info=t.trace_info
;

select enter_abtest_days,platform,ab_code
    ,trace
    ,no_sub_enter_and_save + sub_enter_and_save save
    ,sub_enter_and_no_save + sub_enter_and_save sub_enter
    ,sub_enter_pv_before_sub,sub_enter_trace_pv_before_sub
    ,trace_num_before_sub
    ,count(distinct user_pseudo_id) uv
from
(
    select
        a.enter_abtest_days,a.platform,a.ab_code,a.user_pseudo_id
        ,count(distinct trace_info) trace
        ,count(distinct case when sub_enter_pv=0 and save_pv=0 then trace_info end) no_sub_enter_and_no_save
        ,count(distinct case when sub_enter_pv=0 and save_pv>0 then trace_info end) no_sub_enter_and_save
        ,count(distinct case when sub_enter_pv>0 and save_pv=0 then trace_info end) sub_enter_and_no_save
        ,count(distinct case when sub_enter_pv>0 and save_pv>0 then trace_info end) sub_enter_and_save
        ,min(case when sub_success_pv>0 then a.trace_rank end) trace_num_before_sub
        ,sum(case when b.user_pseudo_id is not null
                           and a.trace_rank<=b.trace_rank then sub_enter_pv end) sub_enter_pv_before_sub  -- 编辑器订阅前订阅页曝光次数
        ,sum(case when b.user_pseudo_id is not null
                           and a.trace_rank=b.trace_rank then sub_enter_pv end) sub_enter_trace_pv_before_sub  -- 某次编辑器订阅前订阅页曝光次数
    from
    (
        select date_diff(date,enter_abtest_date,day) enter_abtest_days
             ,platform,ab_code,user_pseudo_id,trace_info,trace_rank,trace_day_rank
             ,count(case when event_name ='edit_enter' then 1 end) enter_pv
             ,count(case when event_name ='first_func_use' then 1 end) use_first_pv
             ,count(case when event_name ='second_func_use' then 1 end) use_second_pv
             ,count(case when event_name ='third_func_use' then 1 end) use_third_pv
             ,count(case when event_name ='edit_save' then 1 end) save_pv
             ,count(case when event_name ='w_subscription_enter' then 1 end) sub_enter_pv
             ,count(case when event_name ='w_subscription_success' then 1 end) sub_success_pv
        from `dataintegration-265403.temp.new_user_behavior_analysis`
        group by 1,2,3,4,5,6,7
    ) a
    left join
    (
        select platform,ab_code,user_pseudo_id
             ,min(date_diff(date,enter_abtest_date,day)) enter_days
             ,coalesce(min(trace_rank),0) trace_rank
        from `dataintegration-265403.temp.new_user_behavior_analysis`
        where event_name ='w_subscription_success'
        group by 1,2,3
    ) b
    on a.platform=b.platform and a.ab_code=b.ab_code and a.user_pseudo_id=b.user_pseudo_id
    where a.enter_pv>0 and a.enter_abtest_days=0
    group by 1,2,3,4
)
group by 1,2,3,4,5,6,7,8,9
;




select platform,ab_code
    ,count(distinct user_pseudo_id) uv
    ,avg(trace) trace
    ,avg(no_sub_enter_and_no_save) no_sub_enter_and_no_save
    ,avg(no_sub_enter_and_save) no_sub_enter_and_save
    ,avg(sub_enter_and_no_save) sub_enter_and_no_save
    ,avg(sub_enter_and_save) sub_enter_and_save
    ,avg(use_first_pv) use_first_pv
    ,avg(use_second_pv) use_second_pv
    ,avg(use_third_pv) use_third_pv
    ,avg(sub_enter_pv) sub_enter_pv
    ,avg(sub_enter_pv_before_sub) sub_enter_pv_before_sub
    ,avg(sub_enter_trace_pv_before_sub) sub_enter_trace_pv_before_sub
    ,avg(trace_num_before_sub) trace_num_before_sub
from
(
    select
        a.platform,a.ab_code,a.user_pseudo_id
        ,count(distinct trace_info) trace
        ,count(distinct case when sub_enter_pv=0 and save_pv=0 then trace_info end) no_sub_enter_and_no_save
        ,count(distinct case when sub_enter_pv=0 and save_pv>0 then trace_info end) no_sub_enter_and_save
        ,count(distinct case when sub_enter_pv>0 and save_pv=0 then trace_info end) sub_enter_and_no_save
        ,count(distinct case when sub_enter_pv>0 and save_pv>0 then trace_info end) sub_enter_and_save
        ,avg(use_first_pv) use_first_pv
        ,avg(use_second_pv) use_second_pv
        ,avg(use_third_pv) use_third_pv
        ,avg(sub_enter_pv) sub_enter_pv
        ,sum(case when b.user_pseudo_id is not null
                           and a.trace_rank<=b.trace_rank then sub_enter_pv end) sub_enter_pv_before_sub  -- 编辑器订阅前订阅页曝光次数
        ,sum(case when b.user_pseudo_id is not null
                           and a.trace_rank=b.trace_rank then sub_enter_pv end) sub_enter_trace_pv_before_sub  -- 某次编辑器订阅前订阅页曝光次数
        ,min(case when b.trace_rank>0 then b.trace_rank end) trace_num_before_sub
    from
    (
        select date_diff(date,enter_abtest_date,day) enter_abtest_days
             ,platform,ab_code,user_pseudo_id,trace_info,trace_rank,trace_day_rank
             ,count(case when event_name ='edit_enter' then 1 end) enter_pv
             ,count(case when event_name ='first_func_use' then 1 end) use_first_pv
             ,count(case when event_name ='second_func_use' then 1 end) use_second_pv
             ,count(case when event_name ='third_func_use' then 1 end) use_third_pv
             ,count(case when event_name ='edit_save' then 1 end) save_pv
             ,count(case when event_name ='w_subscription_enter' then 1 end) sub_enter_pv
             ,count(case when event_name ='w_subscription_success' then 1 end) sub_success_pv
        from `dataintegration-265403.temp.new_user_behavior_analysis`
        group by 1,2,3,4,5,6,7
    ) a
    left join
    (
        select platform,ab_code,user_pseudo_id
             ,min(date_diff(date,enter_abtest_date,day)) enter_days
             ,coalesce(min(trace_rank),0) trace_rank
        from `dataintegration-265403.temp.new_user_behavior_analysis`
        where event_name ='w_subscription_success'
        group by 1,2,3
    ) b
    on a.platform=b.platform and a.ab_code=b.ab_code and a.user_pseudo_id=b.user_pseudo_id
    where a.enter_pv>0 and a.enter_abtest_days=0
    group by 1,2,3
)
group by 1,2
;




-- select platform,ab_code
--      ,count(distinct user_pseudo_id) uv
--      ,count(distinct case when event_name ='edit_enter' then user_pseudo_id end) enter_uv
--      ,count(distinct case when event_name ='first_func_use' then user_pseudo_id end) use_first_uv
--      ,count(distinct case when event_name ='second_func_use' then user_pseudo_id end) use_second_uv
--      ,count(distinct case when event_name ='third_func_use' then user_pseudo_id end) use_third_uv
--      ,count(distinct case when event_name ='edit_save' then user_pseudo_id end) save_uv
--      ,count(distinct case when event_name ='w_subscription_enter' then user_pseudo_id end) sub_enter_uv
--      ,count(distinct case when event_name ='w_subscription_success' then user_pseudo_id end) sub_success_uv
-- from fe
-- group by 1,2
--
-- ;
--
--
--     select
--         a.platform,a.ab_code
--         ,if(sub_success_pv>0,1,0) is_sub
--         ,avg(save_pv) save_pv
--     from
--     (
--         select platform,ab_code,user_pseudo_id
--              ,count(case when event_name ='edit_enter' then 1 end) enter_pv
--              ,count(case when event_name ='first_func_use' then 1 end) use_first_pv
--              ,count(case when event_name ='second_func_use' then 1 end) use_second_pv
--              ,count(case when event_name ='third_func_use' then 1 end) use_third_pv
--              ,count(case when event_name ='edit_save' then 1 end) save_pv
--              ,count(case when event_name ='w_subscription_enter' then 1 end) sub_enter_pv
--              ,count(case when event_name ='w_subscription_success' then 1 end) sub_success_pv
--         from fe
--         group by 1,2,3
--     ) a
--     where enter_pv>0
--     group by 1,2,3
--     order by 2,3





