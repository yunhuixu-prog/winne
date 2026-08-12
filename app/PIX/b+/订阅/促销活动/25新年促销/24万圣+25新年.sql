-- 整体汇总数据（主要能取dau
select
    event_name
--     ,date
    ,case   when date between '2024-12-22' and '2024-12-27' then '24 圣诞 2024.12.22 - 2024.12.27'
            when date between '2024-12-29' and '2025-01-03' then '25 新年 2024.12.29 - 2025.01.03'
            when date between '2024-12-15' and '2024-12-20' then '24 Benchmark 2024.12.15 - 2024.12.20'
            when date between '2023-12-22' and '2023-12-27' then '23 圣诞 2023.12.22 - 2023.12.27'
            when date between '2023-12-29' and '2024-01-03' then '24 新年 2023.12.29 - 2024.01.03'
            when date between '2023-12-15' and '2023-12-20' then '23 Benchmark 2023.12.15 - 2023.12.20'
            end date_label
    ,a.platform
    ,a.is_ua
    ,a.is_new
    ,case when country in  ('Japan','Thailand','South Korea','United States') then country else 'other countries' end as country
    ,sum(uv) uv
    ,round(sum(payment_price_usd),2) revenue
from
    `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_v5_temp` a
where
    ((date between '2024-12-22' and '2024-12-27') -- 本次圣诞活动时间窗口
    or (date between '2024-12-29' and '2025-01-03')  -- 本次新年活动时间窗口
    or (date between '2024-12-15' and '2024-12-20') -- 本次活动Benchmark时间窗口
    or (date between '2023-12-22' and '2023-12-27') -- 上次圣诞活动时间窗口：实际窗口12.22～12.26
    or (date between '2023-12-29' and '2024-01-03')
    or (date between '2023-12-15' and '2023-12-20') -- 上次活动Benchmark时间窗口
    ) -- 上次新年活动时间窗口
    and data_type= 'event'
    and event_name in ('dau','enter_subscription_page','subscription_clk_try','sub_suc','sub_to_paid')
group by
    1,2,3,4,5,6