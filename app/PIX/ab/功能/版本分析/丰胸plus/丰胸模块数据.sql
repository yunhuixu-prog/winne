drop table if exists `dataintegration-265403.temp.function_behavior_breast_analysis_winne`;
create table if not exists `dataintegration-265403.temp.function_behavior_breast_analysis_winne` as

with function_use as
(
    select event_date,user_pseudo_id,event_name,platform,version
           ,func.getParams(event_params,'prf_third_func').string_value prf_third_func
           ,func.getParams(event_params,'first_func').string_value first_func
           ,func.getParams(event_params,'second_func').string_value second_func
           ,func.getParams(event_params,'third_func').string_value third_func
           ,func.getParams(event_params,'fourth_func').string_value fourth_func
           ,func.getParams(event_params,'by_breast').string_value by_breast
           ,func.getParams(event_params,'by_breast_value').string_value by_breast_value
           ,func.getParams(event_params,'breast_lite').string_value breast_lite
           ,func.getParams(event_params,'breast_plus').string_value breast_plus
           ,func.getParams(event_params,'breast').string_value breast -- second_func_save上报
           ,func.getParams(event_params,'source_module').string_value source_module
           ,func.getParams(event_params,'source_0').string_value source_0
           ,func.getParams(event_params,'source_1').string_value source_1
           ,func.getParams(event_params,'is_success').string_value is_success
           ,func.getParams(event_params,'time').string_value time
    from `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-12-08','2026-01-18','airbrush',false)
    where
        (
            event_name in ('second_func_enter','second_func_use','second_func_save','third_func_enter','third_func_use','fourth_func_enter','ai_func_use_result')
            and func.getParams(event_params,'first_func').string_value='retouch'
            and func.getParams(event_params,'second_func').string_value='body'
            )
        or (event_name in ('w_subscription_enter','w_subscription_success')
            and func.getParams(event_params,'source_module').string_value='p_edit'
            and func.getParams(event_params,'source_0').string_value like '%f_body%'
            )
        or (event_name in ('edit_save')
--             and func.getParams(event_params,'prf_first_func').string_value like '%retouch%' -- 部分没上报这个，要查下为啥(哪个版本之类的)
            and func.getParams(event_params,'prf_second_func').string_value like '%body%'
            )
--     and `dataintegration-265403.func`.compare_is_greater_or_equal_version(version,'7.23.0')
)
,active as
(
     select
        event_date_hk,user_pseudo_id
    from
        `dataintegration-265403.stat.stat_active_advice_detail_d`
    where
        event_date_hk between '2025-12-08' and '2026-01-18'
        and app_name = 'AirBrush'
    group by 1,2
)
select f.*
from function_use f
join active a
on f.event_date=a.event_date_hk and f.user_pseudo_id=a.user_pseudo_id
;


select f.event_date
    ,count(distinct case when f.event_name='second_func_enter' then f.user_pseudo_id end) body_enter
    ,count(distinct case when f.event_name='second_func_use' then f.user_pseudo_id end) body_use
    ,count(distinct case when f.event_name='second_func_save' then f.user_pseudo_id end) body_save
    ,count(distinct case when f.event_name='w_subscription_enter' then f.user_pseudo_id end) body_sub_enter
    ,count(distinct case when f.event_name='w_subscription_success' then f.user_pseudo_id end) body_sub_suc

    ,count(distinct case when f.event_name='third_func_enter' and third_func='breast' then f.user_pseudo_id end) body_breast_enter
    ,count(distinct case when f.event_name='third_func_use' and third_func='breast' then f.user_pseudo_id end) body_breast_use_de
    ,count(distinct case when f.event_name='second_func_use' and (by_breast is not null or by_breast_value!='0') then f.user_pseudo_id end) body_breast_use -- 新key
    ,count(distinct case when f.event_name='edit_save' and prf_third_func like '%breast%' then f.user_pseudo_id end) body_breast_save
    ,count(distinct case when f.event_name='w_subscription_enter' and source_1 like '%f_breast%' then f.user_pseudo_id end) body_breast_sub_enter
    ,count(distinct case when f.event_name='w_subscription_success' and source_1 like '%f_breast%' then f.user_pseudo_id end) body_breast_sub_suc

    ,count(distinct case when f.event_name='fourth_func_enter' and third_func='breast'
                                  and `dataintegration-265403.func`.compare_is_greater_or_equal_version(version,'7.23.0') then f.user_pseudo_id end) enter
    ,count(distinct case when f.event_name='second_func_use' and by_breast is not null
                                  and `dataintegration-265403.func`.compare_is_greater_or_equal_version(version,'7.23.0') then f.user_pseudo_id end) use_second
    ,count(distinct case when f.event_name='third_func_use' and third_func='breast'
                                  and `dataintegration-265403.func`.compare_is_greater_or_equal_version(version,'7.23.0') then f.user_pseudo_id end) use_third
    ,count(distinct case when f.event_name='third_func_use' and third_func='breast' and (breast_plus is not null or breast is not null or breast_lite!='0')
                                  and `dataintegration-265403.func`.compare_is_greater_or_equal_version(version,'7.23.0') then f.user_pseudo_id end) real_use_third
    ,count(distinct case when f.event_name='edit_save' and prf_third_func like '%breast%'
                                  and `dataintegration-265403.func`.compare_is_greater_or_equal_version(version,'7.23.0') then f.user_pseudo_id end) save
    ,count(distinct case when f.event_name='w_subscription_enter' and source_1 like '%f_breast%'
                                  and `dataintegration-265403.func`.compare_is_greater_or_equal_version(version,'7.23.0') then f.user_pseudo_id end) sub_enter
    ,count(distinct case when f.event_name='w_subscription_success' and source_1 like '%f_breast%'
                                  and `dataintegration-265403.func`.compare_is_greater_or_equal_version(version,'7.23.0') then f.user_pseudo_id end) sub_suc

    ,count(distinct case when f.event_name='fourth_func_enter' and third_func='breast' and fourth_func='breast_plus'
                                  and `dataintegration-265403.func`.compare_is_greater_or_equal_version(version,'7.23.0') then f.user_pseudo_id end) body_breast_plus_enter
    ,count(distinct case when f.event_name='second_func_use' and by_breast like '%breast_plus%'
                                  and `dataintegration-265403.func`.compare_is_greater_or_equal_version(version,'7.23.0') then f.user_pseudo_id end) body_breast_plus_use_second
    ,count(distinct case when f.event_name='third_func_use' and third_func='breast' and breast_plus is not null
                                  and `dataintegration-265403.func`.compare_is_greater_or_equal_version(version,'7.23.0') then f.user_pseudo_id end) body_breast_plus_use_third
    ,count(distinct case when f.event_name='second_func_save' and breast like '%breast_plus%'
                                  and `dataintegration-265403.func`.compare_is_greater_or_equal_version(version,'7.23.0') then f.user_pseudo_id end) body_breast_plus_save

    ,count(distinct case when f.event_name='fourth_func_enter' and third_func='breast' and fourth_func='breast_lite'
                                  and `dataintegration-265403.func`.compare_is_greater_or_equal_version(version,'7.23.0') then f.user_pseudo_id end) body_breast_lite_enter
    ,count(distinct case when f.event_name='second_func_use' and by_breast like '%breast_lite%'
                                  and `dataintegration-265403.func`.compare_is_greater_or_equal_version(version,'7.23.0') then f.user_pseudo_id end) body_breast_lite_use_second
    ,count(distinct case when f.event_name='third_func_use' and third_func='breast' and breast_lite!='0'
                                  and `dataintegration-265403.func`.compare_is_greater_or_equal_version(version,'7.23.0') then f.user_pseudo_id end) body_breast_lite_use_third
    ,count(distinct case when f.event_name='second_func_save' and breast like '%breast_lite%'
                                  and `dataintegration-265403.func`.compare_is_greater_or_equal_version(version,'7.23.0') then f.user_pseudo_id end) body_breast_lite_save

    ,count(distinct case when f.event_name='fourth_func_enter' and third_func='breast' and fourth_func='breast'
                                  and `dataintegration-265403.func`.compare_is_greater_or_equal_version(version,'7.23.0') then f.user_pseudo_id end) body_breast_normal_enter
    ,count(distinct case when f.event_name='second_func_use' and REGEXP_CONTAINS(by_breast, r'(^|,)breast(,|$)')
                                  and `dataintegration-265403.func`.compare_is_greater_or_equal_version(version,'7.23.0') then f.user_pseudo_id end) body_breast_normal_use_second
    ,count(distinct case when f.event_name='third_func_use' and third_func='breast' and breast is not null
                                  and `dataintegration-265403.func`.compare_is_greater_or_equal_version(version,'7.23.0') then f.user_pseudo_id end) body_breast_normal_use_third
    ,count(distinct case when f.event_name='second_func_save' and REGEXP_CONTAINS(breast, r'(^|,)breast(,|$)')
                                  and `dataintegration-265403.func`.compare_is_greater_or_equal_version(version,'7.23.0') then f.user_pseudo_id end) body_breast_normal_save

    ,count(distinct case when f.event_name='ai_func_use_result' and fourth_func = 'breast_plus'
                                  and `dataintegration-265403.func`.compare_is_greater_or_equal_version(version,'7.23.0') then f.user_pseudo_id end) body_breast_plus_ai
    ,count(distinct case when f.event_name='ai_func_use_result' and fourth_func = 'breast_plus' and is_success='1'
                                  and `dataintegration-265403.func`.compare_is_greater_or_equal_version(version,'7.23.0') then f.user_pseudo_id end) body_breast_plus_ai_suc
    ,round(avg(case when f.event_name='ai_func_use_result' and fourth_func = 'breast_plus'and is_success='1'
                                  and `dataintegration-265403.func`.compare_is_greater_or_equal_version(version,'7.23.0') then cast(time as bigint) end),4) body_breast_plus_ai_time
    ,count(distinct case when f.event_name='ai_func_use_result' and fourth_func = 'breast'
                                  and `dataintegration-265403.func`.compare_is_greater_or_equal_version(version,'7.23.0') then f.user_pseudo_id end) body_breast_normal_ai
    ,count(distinct case when f.event_name='ai_func_use_result' and fourth_func = 'breast' and is_success='1'
                                  and `dataintegration-265403.func`.compare_is_greater_or_equal_version(version,'7.23.0') then f.user_pseudo_id end) body_breast_normal_ai_suc
    ,round(avg(case when f.event_name='ai_func_use_result' and fourth_func = 'breast' and is_success='1'
                                  and `dataintegration-265403.func`.compare_is_greater_or_equal_version(version,'7.23.0') then cast(time as bigint) end),4) body_breast_normal_ai_time

from `dataintegration-265403.temp.function_behavior_breast_analysis_winne` f
group by 1
order by 1