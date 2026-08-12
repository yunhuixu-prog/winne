with
subscription_event as
(
    select *
    from `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_abtest`
    where
        date>='2023-12-01' and date<='2023-12-27'
        and device_id is not null
),
-- 取用户初次订阅类型
user_user_tag as
(
    select
        m.platform,
        m.device_id,
        min_by(sub_user_type,date) sub_user_type
    from
        subscription_event m
    group by
        1,2
),
problem_user as
(
    select s.date,s.event_name,s.sub_user_type,s.device_id,country,payment_price_usd,standard_order_date,purchase_date
    from subscription_event s
    join user_user_tag u
    on s.platform=u.platform and s.device_id=u.device_id
    where u.sub_user_type='4' and s.platform='ANDROID'
)

select date
    ,case when  event_name in ('page_event') then '1:sub enter uv'
    when  event_name in ('subscription_clk_try') then '2:sub click uv'
    else event_name end as event_name
    ,country
    ,sub_user_type
    ,count(distinct device_id) device_num,0 revenue
from problem_user
where event_name not in ('subscription_try_suc')
    and sub_user_type in ('1','4')
group by 1,2,3,4

union all

select date
    ,'3:sub_success uv' as event_name
    ,country
    ,sub_user_type
    ,count(distinct device_id) device_num,0 revenue
from problem_user
where event_name in ('subscription_try_suc') and standard_order_date is not null
    and sub_user_type in ('1','4')
group by 1,2,3,4

union all

select date
    ,'4:sub_success_to_paid uv' as event_name
    ,country
    ,sub_user_type
    ,count(distinct device_id) device_num,0 revenue
from problem_user
where event_name in ('subscription_try_suc') and standard_order_date is not null and purchase_date is not null
    and sub_user_type in ('1','4')
group by 1,2,3,4

-- union all

-- select date
--     ,'5:sub_success_to_paid revenue' as event_name
--     ,country
--     ,sub_user_type
--     ,0 device_num,round(sum(payment_price_usd),2) revenue
-- from problem_user
-- where event_name in ('subscription_try_suc') and standard_order_date is not null and purchase_date is not null
--     and sub_user_type in ('1','4')
-- group by 1,2,3,4



-- 单个用户查询

    select event_date,event_timestamp,event_name,platform
        ,func.getUserprop(user_properties,'device_id').string_value device_id
        ,user_pseudo_id
        ,user_id
    from
        `beautyplus-bc0ed.analytics.stage_dz_event_view`
    where
        parse_date('%Y%m%d', event_date) between '2023-12-01' and '2023-12-27'
        and platform in ('IOS','ANDROID')
        and event_name in ('subscription_try_suc','first_open','app_remove','app_start_bd')
        and func.getUserprop(user_properties,'device_id').string_value='badc316a793b8c74'
    order by event_timestamp



select date,event_timestamp,platform,country,event_name,cur_page_type,user_pseudo_id,device_id,sub_user_type
from  `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_abtest`
where date>='2023-12-05' and date<='2023-12-26'
        and device_id='badc316a793b8c74'
order by event_timestamp

