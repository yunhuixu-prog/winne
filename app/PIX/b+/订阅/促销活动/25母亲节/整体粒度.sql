-- 整体汇总数据（主要能取dau
select
    event_name
    ,date
    ,case   when date between '2025-05-09' and '2025-05-13' then '25 母亲节 2025.05.09 - 2025.05.13'
            when date between '2025-05-02' and '2025-05-06' then '25 Benchmark 2025.05.02 - 2025.05.06'
            when date between '2024-05-10' and '2024-05-14' then '24 母亲节 2024.05.10 - 2024.05.14'
            when date between '2024-05-03' and '2024-05-07' then '24 Benchmark 2024.05.03 - 2024.05.07'
            end date_label
    ,a.platform
    ,case when country in  ('Turkey') then 'Türkiye' else country end as country
    ,case   when country in ('Indonesia', 'Philippines', 'Brazil', 'Turkey', 'South Korea') then '实验国家'
            else '正常活动国家'
            end country_holiday
    ,sum(uv) uv
    ,round(sum(payment_price_usd),2) revenue
from
    `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_v5_temp` a
where
    ((date between '2025-05-09' and '2025-05-13') -- 本次活动时间窗口，周五-周二
    or (date between '2025-05-02' and '2025-05-06') -- 本次活动Benchmark时间窗口
    or (date between '2024-05-10' and '2024-05-14') -- 上次活动时间窗口，实际未做促销
    or (date between '2024-05-03' and '2024-05-07')) -- 上次活动Benchmark时间窗口
    and data_type= 'event'
group by
    1,2,3,4,5,6