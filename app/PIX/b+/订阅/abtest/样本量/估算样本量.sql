-- 例1：新用户/再订阅用户买赠实验
-- 需要进入首页新用户/再订阅用户量级，订阅付费人数，比例
with user_info as 
(
    select 
        event_date_hk
        ,app_name
        ,platform
        ,country
        ,user_pseudo_id
        ,max(uuid) uuid
        ,max(is_new) is_new
        ,max(is_UA) is_UA
        ,max(app_version) app_version
    from 
        `dataintegration-265403.stat.stat_active_advice_detail_d`
    where 
        event_date_hk between '2023-10-12' and '2023-11-12'
        and app_name='BeautyPlus'
    group by 1,2,3,4,5
) 
,
sub as 
(
    -- 不同端/用户类型 天 进入订阅页人数，订阅付费人数
    select date,platform,sub_user_type
        ,count(distinct case when event_name in ('page_event') then device_id end) sub_enter
        ,count(distinct case when event_name in ('subscription_try_suc') and standard_order_date is not null and purchase_date is not null then device_id end) sub_success_to_paid
    from `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_abtest`
    where date>='2023-10-12' and date<='2023-11-12' 
        -- and platform='ANDROID'
        -- and sub_user_type='4' --新用户
        -- and country in ('South Korea', 'Thailand', 'Japan', 'United States')
    group by 1,2,3 
)
,
enter_ab as 
(
    -- 不同端/用户类型 天 进入首页人数
    select
    event_date,
    b.platform,
    case
        when b.is_new = 1 then 'New'
        else 'Old'
    end as is_new,
    -- b.country,
    -- case
    --     when b.country in ('South Korea', 'Thailand', 'Japan', 'United States') then b.country
    --     else 'general'
    -- end as region,
    count(distinct a.user_pseudo_id) ab_num
    from
    (
        select
        event_date
        ,user_pseudo_id
        from `beautyplus-bc0ed.analytics.ods_dz_events_tv`('2023-10-12','2023-11-12')
        where event_name in ('homepageappr_bd')
        group by 1,2
    ) a
    join user_info b on a.user_pseudo_id = b.user_pseudo_id and a.event_date = b.event_date_hk
    group by 1,2,3
)

select platform,sub_user_type,round(sum(sub_enter)/count(distinct date),0) sub_enter
    ,round(sum(sub_success_to_paid)/count(distinct date),0) sub_success_to_paid
    ,sum(sub_success_to_paid)/sum(sub_enter) pay_ratio
from sub
where 
    platform in ('ANDROID','IOS')
    -- and sub_user_type='4' --新用户
group by 1,2
order by 1,2
;
select platform,is_new,round(sum(ab_num)/count(distinct event_date),0) ab_num
from enter_ab
where 
    platform in ('ANDROID','IOS')
    -- and is_new='New' --新用户
group by 1,2
order by 1,2

-- 例2:周订阅实验
-- 需要实验的5个国家进入订阅页人数，订阅付费人数（非onboarding）
select round(sum(sub_enter)/count(distinct date),0) sub_enter
    ,round(sum(sub_success_to_paid)/count(distinct date),0) sub_success_to_paid
    ,sum(sub_success_to_paid)/sum(sub_enter) ratio
from 
(
  select date,
    count(distinct case when event_name in ('page_event') then device_id end) sub_enter,
    count(distinct case when event_name in ('subscription_try_suc') and standard_order_date is not null and purchase_date is not null then device_id end) sub_success_to_paid
  from `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_abtest`
  where date>='2023-10-10' and date<='2023-11-10' 
      and source2!='OnboardingPage'
      and platform='ANDROID'
      and country in ('Indonesia','Pakistan','Bangladesh','Nigeria','Peru')
  group by 1
)

-- 例3:aigc混合付费：推荐充值实验

-- 额度管理页曝光人数及他们充值积分的均值标准差
select platform,round(sum(ab_num)/count(distinct event_date),0) ab_num
        ,round(sum(topup_num)/count(distinct event_date),0) topup_num
        ,round(sum(credit_avg)/count(distinct event_date),4) credit_avg
        ,round(sum(credit_std)/count(distinct event_date),4) credit_std
from 
(
select
    a.event_date,
    a.platform,
    count(distinct hwgid) ab_num,
    count(distinct user_id) topup_num,
    AVG(coalesce(credit_num,0)) as credit_avg,STDDEV(coalesce(credit_num,0)) credit_std
from
(
    select
        event_date
        ,platform
        ,func.getUserprop(user_properties,'hwgid').string_value hwgid
    from `beautyplus-bc0ed.analytics.ods_dz_events_tv`('2023-10-12','2023-11-12')
    where event_name in ('credit_page_bd')
    group by 1,2,3
) a 
left join 
(
    select 
        event_date
        ,platform
        ,user_id
        ,sum(credit_num) credit_num
        ,sum(payment_price_usd) payment_price_usd
    from
        `beautyplus-bc0ed.dwd.dwd_da_credit_credit_record`
    where
        record_type=1 -- 积分消耗
        and app_name='BeautyPlus'
        and event_date between '2023-10-12' and '2023-11-12'
    group by
        1,2,3
) b 
on a.event_date=b.event_date and a.platform=b.platform and a.hwgid=b.user_id
group by 1,2
)
group by 1


