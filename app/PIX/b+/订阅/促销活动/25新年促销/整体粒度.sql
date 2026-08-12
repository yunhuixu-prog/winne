-- 整体汇总数据（主要能取dau
select
    event_name
    ,date
    ,case   when date between '2024-12-29' and '2025-01-03' then '25 新年 2024.12.29 - 2025.01.03'
            when date between '2024-12-15' and '2024-12-20' then '24 Benchmark 2024.12.15 - 2024.12.20'
            when date between '2023-12-29' and '2024-01-03' then '24 新年 2023.12.29 - 2024.01.03'
            end date_label
    ,a.platform
    ,a.is_ua
    ,case when country in  ('Turkey') then 'Türkiye' else country end as country
    ,sum(uv) uv
    ,round(sum(payment_price_usd),2) revenue
from
    `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_v5_temp` a
where
    ((date between '2024-12-29' and '2025-01-03') -- 本次活动时间窗口
    or (date between '2024-12-15' and '2024-12-20') -- 本次活动Benchmark时间窗口（上一周是圣诞，再前一周）
    or (date between '2023-12-29' and '2024-01-03')) -- 上次活动时间窗口
    and data_type= 'event'
    and event_name in ('dau','enter_subscription_page','subscription_clk_try','sub_suc','sub_to_paid')
group by
    1,2,3,4,5,6