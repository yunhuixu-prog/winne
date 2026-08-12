
with
user_info as
(
    select
        event_date_hk
        ,user_pseudo_id
        ,max(country) country
    from
        `dataintegration-265403.stat.stat_active_advice_detail_d`
    where
        event_date_hk between '2024-11-29' and '2024-12-03'
        and app_name in ('BeautyPlus')
    group by 1,2
)
,
event_ab as
(
    select a.*,u.country country_firebase
    from
    (
        select event_date
            ,event_timestamp
            ,platform
            ,event_name
            ,user_pseudo_id
            ,country
            ,coalesce(func.getParams(event_params,'is_trial_open').string_value,cast(func.getParams(event_params,'is_trial_open').int_value as string)) is_trial_open
        from `dataintegration-265403.analytics.dwd_dzp_events_function`('2024-11-29', '2024-12-03', 'BeautyPlus', false)
        where event_name in  ('subscription_clk_try','subscription_try_suc')
            and (func.getParams(event_params,'cur_spm').string_value like '%1008%'
            or func.getParams(event_params,'cur_spm').string_value like '%1009%')
            and func.getParams(event_params,'sub_user_type').string_value in ('1','2')
    ) a
    join user_info u on a.event_date=u.event_date_hk and a.user_pseudo_id=u.user_pseudo_id
    where u.country='United States' -- or a.country='United States'
)

select platform,event_name,is_trial_open_type,sum(num)
from
(
select event_date
        ,event_name
        ,'all' is_trial_open_type
        ,platform
        ,count(distinct user_pseudo_id) num
from event_ab
group by 1,2,3,4

union all

select event_date
        ,event_name
        ,case when is_trial_open='0' then '未开启'
              when is_trial_open='1' then '开启'
        else is_trial_open
        end is_trial_open_type
        ,platform
        ,count(distinct user_pseudo_id) num
from event_ab
group by 1,2,3,4
)
group by 1,2,3
order by 1,2,3