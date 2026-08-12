-- 新用户/普通用户调整免费试用实验
select sub_user_type,round(sum(sub_enter)/count(distinct date),0) sub_enter
    ,round(sum(sub_click)/count(distinct date),0) sub_click
    ,round(sum(sub_success)/count(distinct date),0) sub_success
    ,round(sum(sub_success_to_paid)/count(distinct date),0) sub_success_to_paid
    ,sum(sub_success_to_paid)/sum(sub_enter) enter_to_paid
    ,sum(sub_click)/sum(sub_enter) enter_to_click
    ,sum(sub_success)/sum(sub_click) click_to_sub
    ,sum(sub_success_to_paid)/sum(sub_success) sub_to_paid
from
(
  select date,sub_user_type,
    count(distinct case when event_name in ('page_event') then device_id end) sub_enter,
    count(distinct case when event_name in ('subscription_clk_try') then device_id end) sub_click,
    count(distinct case when event_name in ('subscription_try_suc') and standard_order_date is not null then device_id end) sub_success,
    count(distinct case when event_name in ('subscription_try_suc') and standard_order_date is not null and purchase_date is not null then device_id end) sub_success_to_paid
  from `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_abtest`
  where date>='2023-12-01' and date<='2023-12-31'
      and source2!='OnboardingPage'
      and platform='IOS'
      and sub_user_type in ('1','2')
  group by 1,2
)
group by 1


-- 美日英新用户优惠实验
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
        event_date_hk between '2023-12-01' and '2023-12-31'
        and app_name='BeautyPlus'
    group by 1,2,3,4,5
)

select sub_user_type,is_UA,round(sum(sub_enter)/count(distinct date),0) sub_enter
    ,round(sum(sub_click)/count(distinct date),0) sub_click
    ,round(sum(sub_success)/count(distinct date),0) sub_success
    ,round(sum(sub_success_to_paid)/count(distinct date),0) sub_success_to_paid
    ,sum(sub_success_to_paid)/sum(sub_enter) enter_to_paid
    ,sum(sub_click)/sum(sub_enter) enter_to_click
    ,sum(sub_success)/sum(sub_click) click_to_sub
    ,sum(sub_success_to_paid)/sum(sub_success) sub_to_paid
from
(
  select date,sub_user_type,is_UA,
    count(distinct case when event_name in ('page_event') then device_id end) sub_enter,
    count(distinct case when event_name in ('subscription_clk_try') then device_id end) sub_click,
    count(distinct case when event_name in ('subscription_try_suc') and standard_order_date is not null then device_id end) sub_success,
    count(distinct case when event_name in ('subscription_try_suc') and standard_order_date is not null and purchase_date is not null then device_id end) sub_success_to_paid
  from `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_abtest` a
  join user_info u on a.date=u.event_date_hk and a.platform=u.platform and a.user_pseudo_id=u.user_pseudo_id
  where date>='2023-12-01' and date<='2023-12-31'
      and source2!='OnboardingPage'
      and a.platform='IOS'
      and sub_user_type in ('1')
      and u.country in ('United States','Japan','United Kingdom')
  group by 1,2,3
)
group by 1,2



