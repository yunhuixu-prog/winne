-- -- 进入编辑器人数
-- select
--      platform,ab_code
--      ,count(distinct user_pseudo_id) enter_uv
-- from `dataintegration-265403.temp.new_user_behavior_analysis`
-- where date_diff(date,enter_abtest_date,day)=0 and event_name='edit_enter'
-- group by 1,2
-- order by 2
-- ;
-- 攻能使用留存
with func as
(
    select a.*,b.enter_pv enter_pv_7,b.use_pv use_pv_7
    from
    (
        select
             platform,ab_code,user_pseudo_id
    --              ,trace_info,trace_rank,trace_day_rank
             ,first_func,second_func,third_func
    --              ,source_module,source_0,source_1
             ,count(case when event_name in ('first_func_enter','second_func_enter','third_func_enter') then 1 end) enter_pv
             ,count(case when event_name in ('first_func_use','second_func_use','third_func_use') then 1 end) use_pv
    --              ,count(case when event_name in ('w_subscription_success') then 1 end) sub_success_pv
        from `dataintegration-265403.temp.new_user_behavior_analysis`
        where date_diff(date,enter_abtest_date,day)=0
        group by 1,2,3,4,5,6
    ) a
    left join
    (
        select
             platform,ab_code,user_pseudo_id
    --              ,trace_info,trace_rank,trace_day_rank
             ,first_func,second_func,third_func
    --              ,source_module,source_0,source_1
             ,count(case when event_name in ('first_func_enter','second_func_enter','third_func_enter') then 1 end) enter_pv
             ,count(case when event_name in ('first_func_use','second_func_use','third_func_use') then 1 end) use_pv
    --              ,count(case when event_name in ('w_subscription_success') then 1 end) sub_success_pv
        from `dataintegration-265403.temp.new_user_behavior_analysis`
        where date_diff(date,enter_abtest_date,day) between 1 and 7
        group by 1,2,3,4,5,6
    ) b
    on a.platform=b.platform and a.ab_code=b.ab_code and a.user_pseudo_id=b.user_pseudo_id
        and coalesce(a.first_func,'others')=coalesce(b.first_func,'others')
        and coalesce(a.second_func,'others')=coalesce(b.second_func,'others')
        and coalesce(a.third_func,'others')=coalesce(b.third_func,'others')
)
select
    platform,ab_code
    ,first_func,'All' second_func,'All' third_func
    ,count(distinct case when enter_pv >0 then user_pseudo_id end) enter_uv
    ,sum(enter_pv) enter_pv
    ,count(distinct case when enter_pv_7 >0 then user_pseudo_id end) enter_uv_7

    ,count(distinct case when use_pv >0 then user_pseudo_id end) use_uv
    ,sum(use_pv) use_pv
    ,count(distinct case when use_pv_7 >0 then user_pseudo_id end) use_uv_7
from func a
group by 1,2,3,4,5

union all

select
    platform,ab_code
    ,first_func,second_func,'All' third_func
    ,count(distinct case when enter_pv >0 then user_pseudo_id end) enter_uv
    ,sum(enter_pv) enter_pv
    ,count(distinct case when enter_pv_7 >0 then user_pseudo_id end) enter_uv_7

    ,count(distinct case when use_pv >0 then user_pseudo_id end) use_uv
    ,sum(use_pv) use_pv
    ,count(distinct case when use_pv_7 >0 then user_pseudo_id end) use_uv_7
from func a
group by 1,2,3,4,5

union all

select
    platform,ab_code
    ,first_func,second_func,s third_func -- 三级有可能是多个使用功能
    ,count(distinct case when enter_pv >0 then user_pseudo_id end) enter_uv
    ,sum(enter_pv) enter_pv
    ,count(distinct case when enter_pv_7 >0 then user_pseudo_id end) enter_uv_7

    ,count(distinct case when use_pv >0 then user_pseudo_id end) use_uv
    ,sum(use_pv) use_pv
    ,count(distinct case when use_pv_7 >0 then user_pseudo_id end) use_uv_7
from func a,unnest(split(coalesce(third_func,'others'),',')) s
group by 1,2,3,4,5

;


-- 攻能收入
select
     platform,ab_code
        ,'module' types
        ,coalesce(source_module,'unknown') source_module
        ,'All' source_0
        ,'All' source_1
--          ,count(case when event_name in ('first_func_enter','second_func_enter','third_func_enter') then 1 end) enter_pv
--          ,count(case when event_name in ('first_func_use','second_func_use','third_func_use') then 1 end) use_pv
        ,count(distinct user_pseudo_id) sub_success_uv
from `dataintegration-265403.temp.new_user_behavior_analysis` --,unnest(split(coalesce(source_0,'others'),',')) s0,unnest(split(coalesce(source_1,'others'),',')) s1
where event_name in ('w_subscription_success')
    and date_diff(date,enter_abtest_date,day) between 0 and 7
group by 1,2,3,4,5,6

union all

select
     platform,ab_code
        ,'source0' types
        ,coalesce(source_module,'unknown') source_module
        ,coalesce(s0,'others') source_0
        ,'All' source_1
--          ,count(case when event_name in ('first_func_enter','second_func_enter','third_func_enter') then 1 end) enter_pv
--          ,count(case when event_name in ('first_func_use','second_func_use','third_func_use') then 1 end) use_pv
         ,count(distinct user_pseudo_id) sub_success_uv
from `dataintegration-265403.temp.new_user_behavior_analysis`,unnest(split(coalesce(source_0,'others'),',')) s0 --,unnest(split(coalesce(source_1,'others'),',')) s1
where event_name in ('w_subscription_success')
    and date_diff(date,enter_abtest_date,day) between 0 and 7
group by 1,2,3,4,5,6

union all

select
     platform,ab_code
        ,'source1' types
        ,coalesce(source_module,'unknown') source_module
        ,coalesce(s0,'others') source_0
        ,coalesce(s1,'others') source_1
--          ,count(case when event_name in ('first_func_enter','second_func_enter','third_func_enter') then 1 end) enter_pv
--          ,count(case when event_name in ('first_func_use','second_func_use','third_func_use') then 1 end) use_pv
         ,count(distinct user_pseudo_id) sub_success_uv
from `dataintegration-265403.temp.new_user_behavior_analysis`,unnest(split(coalesce(source_0,'others'),',')) s0,unnest(split(coalesce(source_1,'others'),',')) s1
where event_name in ('w_subscription_success')
    and date_diff(date,enter_abtest_date,day) between 0 and 7
group by 1,2,3,4,5,6


