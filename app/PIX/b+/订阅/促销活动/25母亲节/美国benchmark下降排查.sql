select
    event_name
    ,data_type
    ,case   when date between '2025-05-09' and '2025-05-13' then '25 母亲节 2025.05.09 - 2025.05.13'
            when date between '2025-05-02' and '2025-05-06' then '25 Benchmark 2025.05.02 - 2025.05.06'
            when date between '2024-05-10' and '2024-05-14' then '24 母亲节 2024.05.10 - 2024.05.14'
            when date between '2024-05-03' and '2024-05-07' then '24 Benchmark 2024.05.03 - 2024.05.07'
            end date_label
    ,is_UA
    ,is_new
    ,sum(uv) uv
    ,round(sum(payment_price_usd),2) revenue
from
    `beautyplus-bc0ed.subscription.ads_dzp_subscription_spm_trial_subscription_v5_abtest` a
where
    ((date between '2025-05-02' and '2025-05-06') -- 本次活动Benchmark时间窗口
    or (date between '2024-05-03' and '2024-05-07')) -- 上次活动Benchmark时间窗口
    and data_type in ('event')
    and event_name in ('enter_subscription_page','sub_suc','dau','sub_to_paid','subscription_clk_try')
    and country='United States'
group by
    1,2,3,4,5
;

select
    event_name
    ,data_type
    ,case   when date between '2025-05-09' and '2025-05-13' then '25 母亲节 2025.05.09 - 2025.05.13'
            when date between '2025-05-02' and '2025-05-06' then '25 Benchmark 2025.05.02 - 2025.05.06'
            when date between '2024-05-10' and '2024-05-14' then '24 母亲节 2024.05.10 - 2024.05.14'
            when date between '2024-05-03' and '2024-05-07' then '24 Benchmark 2024.05.03 - 2024.05.07'
            end date_label
    ,a.category1
    ,a.category2
    ,module
    ,is_new
    ,is_UA
    ,sum(uv) uv
    ,round(sum(payment_price_usd),2) revenue
from
    `beautyplus-bc0ed.subscription.ads_dzp_subscription_spm_trial_subscription_v5_abtest` a
where
    ((date between '2025-05-02' and '2025-05-06') -- 本次活动Benchmark时间窗口
    or (date between '2024-05-03' and '2024-05-07')) -- 上次活动Benchmark时间窗口
    and data_type in ('module','category2','category1')
    and event_name in ('enter_subscription_page','sub_suc')
    and country='United States'
group by
    1,2,3,4,5,6,7,8