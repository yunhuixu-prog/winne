-- 整体汇总数据（主要能取dau
select
    event_name
    ,date
    ,case   when date between '2024-10-26' and '2024-11-01' then '24 万圣节: 2024.10.26 - 2024.11.01'
            when date between '2024-10-19' and '2024-10-25' then '24 Benchmark: 2024.10.19 - 2024.10.25'
            when date between '2023-10-27' and '2023-11-02' then '23 万圣节: 2023.10.27 - 2023.11.02'
            end date_label
    ,a.platform
    ,case when country in  ('Turkey') then 'Türkiye' else country end as country
    ,sum(uv) uv
    ,round(sum(payment_price_usd),2) revenue
from
    `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_v5_temp` a
where
    ((date between '2024-10-26' and '2024-11-01') -- 本次活动时间窗口
    or (date between '2024-10-19' and '2024-10-25') -- 本次活动Benchmark时间窗口
    or (date between '2023-10-27' and '2023-11-02')) -- 上次活动时间窗口
    and data_type= 'event'
group by
    1,2,3,4,5