select f.event_date
--     ,count(distinct case when f.event_name='fourth_func_enter' and third_func='breast' then f.user_pseudo_id end) enter
    ,count(distinct case when f.event_name='second_func_use' and by_breast is not null then f.user_pseudo_id end) use_second
--     ,count(distinct case when f.event_name='third_func_use' and third_func='breast' then f.user_pseudo_id end) use_third
    ,count(distinct case when f.event_name='third_func_use' and third_func='breast' and (breast_plus is not null or breast is not null or breast_lite!='0') then f.user_pseudo_id end) real_use_third
--     ,count(distinct case when f.event_name='edit_save' and prf_third_func like '%breast%' then f.user_pseudo_id end) save
    ,count(distinct case when f.event_name='w_subscription_enter' and source_1 like '%f_breast%' then f.user_pseudo_id end) sub_enter
    ,count(distinct case when f.event_name='w_subscription_success' and source_1 like '%f_breast%' then f.user_pseudo_id end) sub_suc
from `dataintegration-265403.temp.function_behavior_breast_analysis_winne` f
where `dataintegration-265403.func`.compare_is_greater_or_equal_version(version,'7.23.0')
group by 1
order by 1
;
select a.*
from
(
    select distinct event_date,user_pseudo_id
    from `dataintegration-265403.temp.function_behavior_breast_analysis_winne`
    where `dataintegration-265403.func`.compare_is_greater_or_equal_version(version,'7.23.0')
        and event_name='third_func_use' and third_func='breast' and (breast_plus is not null or breast is not null or breast_lite!='0')
) a
left join
(
    select distinct event_date,user_pseudo_id
    from `dataintegration-265403.temp.function_behavior_breast_analysis_winne`
    where `dataintegration-265403.func`.compare_is_greater_or_equal_version(version,'7.23.0')
        and event_name='second_func_use' and by_breast is not null
) b
on a.event_date=b.event_date and a.user_pseudo_id=b.user_pseudo_id
left join
(
    select distinct event_date,user_pseudo_id
    from `dataintegration-265403.temp.function_behavior_breast_analysis_winne`
    where `dataintegration-265403.func`.compare_is_greater_or_equal_version(version,'7.23.0')
        and event_name='w_subscription_enter' and source_1 like '%f_breast%'
) c
on a.event_date=c.event_date and a.user_pseudo_id=c.user_pseudo_id
where a.event_date='2026-01-18'
    and c.user_pseudo_id is not null and b.user_pseudo_id is not null
;

select a.*
from
(
    select distinct event_date,user_pseudo_id
    from `dataintegration-265403.temp.function_behavior_breast_analysis_winne`
    where `dataintegration-265403.func`.compare_is_greater_or_equal_version(version,'7.23.0')
        and event_name='second_func_use' and by_breast is not null
) a
left join
(
    select distinct event_date,user_pseudo_id
    from `dataintegration-265403.temp.function_behavior_breast_analysis_winne`
    where `dataintegration-265403.func`.compare_is_greater_or_equal_version(version,'7.23.0')
        and event_name='third_func_use' and third_func='breast' and (breast_plus is not null or breast is not null or breast_lite!='0')
) b
on a.event_date=b.event_date and a.user_pseudo_id=b.user_pseudo_id
where a.event_date='2026-01-18'
    and b.user_pseudo_id is null