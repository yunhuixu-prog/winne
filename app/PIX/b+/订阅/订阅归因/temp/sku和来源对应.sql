

select date,sku,case when a.category2='OnboardingPage' then 'OnboardingPage' else 'Else' end category
     ,count(distinct user_pseudo_id) uv
     ,count(1) pv
from `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_abtest` s ,UNNEST(agg) a
where date between '2025-02-06' and '2025-02-24'
    and event_name in ('subscription_try_suc') and standard_order_date is not null
group by 1,2,3


