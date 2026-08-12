-- 整体汇总数据（主要能取dau
select
    event_name
    ,date
    ,case   when date between '2024-11-29' and '2024-12-03' then '24 黑五 2024.11.29 - 2024.12.03'
            when date between '2024-11-22' and '2024-11-26' then '24 Benchmark 2024.11.22 - 2024.11.26'
            when date between '2023-11-24' and '2023-11-28' then '23 黑五 2023.11.24 - 2023.11.28'
            end date_label
    ,a.platform
    ,case when country in  ('Turkey') then 'Türkiye' else country end as country
    ,sum(uv) uv
    ,round(sum(payment_price_usd),2) revenue
from
    `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_v5_temp` a
where
    ((date between '2024-11-29' and '2024-12-03') -- 本次活动时间窗口
    or (date between '2024-11-22' and '2024-11-26') -- 本次活动Benchmark时间窗口
    or (date between '2023-11-24' and '2023-11-28')) -- 上次活动时间窗口：实际窗口11.24～11.27
    and data_type= 'event'
group by
    1,2,3,4,5