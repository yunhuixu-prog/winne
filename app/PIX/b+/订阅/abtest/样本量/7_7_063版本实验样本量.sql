-- 缩短onboarding流程
with a as (
  select
distinct event_date,platform,user_pseudo_id
  from `dataintegration-265403.analytics.dwd_dzp_events_function`('2024-01-01', '2024-01-24', 'beautyplus', false)
where event_name ='first_open'
),
b as (
  select
distinct event_date,platform,user_pseudo_id
  from `dataintegration-265403.analytics.dwd_dzp_events_function`('2024-01-01', '2024-01-24', 'beautyplus', false)
where event_name ='homepageappr_bd'
)
select platform,sum(first_open_uv)/count(distinct event_date) first_open_uv,sum(enter_home_uv)/count(distinct event_date) enter_home_uv,sum(enter_home_uv)/sum(first_open_uv)
from
(
select
a.event_date,a.platform,count(distinct a.user_pseudo_id) first_open_uv,count(distinct b.user_pseudo_id) enter_home_uv
from a left join b
on a.user_pseudo_id = b.user_pseudo_id and a.event_date=b.event_date and a.platform=b.platform
group by 1,2
)
group by 1




-- 首次订阅优惠(安装7天以上的未订阅用户10次以内打开。。。算了就算安装7天以上14天一下的吧)
with b as
(
    select
        event_date_hk event_date
        ,user_pseudo_id
        ,platform
        ,first_launch_date
    from
        `beautyplus-bc0ed.ods.ods_da_all_device`
    where
        event_date_hk = '2024-01-25'
        and first_launch_date<'2024-01-18'
    group by 1,2,3,4
)
,
a as (
  select distinct event_date,platform,user_pseudo_id
  from `dataintegration-265403.analytics.dwd_dzp_events_function`('2024-01-01', '2024-01-24', 'beautyplus', false)
where event_name ='homepageappr_bd'
)
,
s as
(
    select date event_date,platform,user_pseudo_id
    from `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_abtest`
    where date between '2024-01-01' and '2024-01-24'
        and event_name in ('subscription_try_suc') and standard_order_date is not null and purchase_date is not null
    group by 1,2,3
)


select platform,sum(enter_home_uv)/count(distinct event_date) enter_home_uv,sum(pay_uv)/count(distinct event_date) pay_uv,sum(pay_uv)/sum(enter_home_uv)
from
(
select
a.event_date,a.platform,count(distinct a.user_pseudo_id) enter_home_uv,count(distinct s.user_pseudo_id) pay_uv
from a
left join b
on a.user_pseudo_id = b.user_pseudo_id and a.platform=b.platform
left join s
on a.user_pseudo_id = s.user_pseudo_id and a.event_date=s.event_date and a.platform=s.platform
where date_diff(a.event_date,b.first_launch_date,day)>7 and date_diff(a.event_date,b.first_launch_date,day)<14
group by 1,2
)
group by 1

-- 首次订阅具体样本量

    select
        event_date_hk event_date,platform
        ,count(distinct user_pseudo_id) uv
    from
        `beautyplus-bc0ed.dim.dim_dzp_portrait_firebase_id_user`
    where
        event_date_hk between '2024-03-20' and '2024-03-26'
        and event_date_hk=last_active_date
--         and first_active_date between DATE_SUB(event_date_hk, INTERVAL 90 DAY) and DATE_SUB(event_date_hk, INTERVAL 6 DAY)
        and first_active_date <DATE_SUB(event_date_hk, INTERVAL 5 DAY)
        and active_sessions_90d between 2 and 10
    group by 1,2

