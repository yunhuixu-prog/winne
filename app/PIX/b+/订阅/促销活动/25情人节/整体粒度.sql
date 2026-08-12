-- 整体汇总数据（主要能取dau
select
    event_name
    ,date
    ,case   when date between '2025-02-11' and '2025-02-17' then '25 情人节 2025.02.11 - 2025.02.17'
            when date between '2025-02-04' and '2025-02-10' then '25 Benchmark 2025.02.04 - 2025.02.10'
            when date between '2024-02-09' and '2024-02-15' then '24 情人/狂欢/春节 2024.02.09 - 2024.02.15'
            when date between '2024-02-02' and '2024-02-08' then '24 Benchmark 2024.02.02 - 2024.02.08'
            end date_label
    ,a.platform
    ,case when country in  ('Turkey') then 'Türkiye' else country end as country
    ,case when country in ('South Korea','Thailand','Indonesia','Vietnam','Malaysia','Philippines','Singapore','Cambodia','Laos') then '春节'
                when country in ('Mexico','Guatemala','Honduras','El Salvador','Nicaragua','Costa Rica','Panama','Cuba'
                    ,'Haiti','Dominican Republic','Jamaica','Trinidad & Tobago','Barbados','Grenada','St. Lucia'
                    ,'St. Kitts & Nevis','St. Vincent & Grenadines','Argentina','Bolivia','Brazil','Chile'
                    ,'Colombia','Ecuador','Guyana','Paraguay','Peru','Suriname','Uruguay','Venezuela','Belize'
                    ,'Dominica','Antigua & Barbuda','Bahamas') then '狂欢节'
                else '情人节' end as country_holiday
    ,sum(uv) uv
    ,round(sum(payment_price_usd),2) revenue
from
    `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_v5_temp` a
where
    ((date between '2025-02-11' and '2025-02-17') -- 本次活动时间窗口：周二-周一，实际活动13-17
    or (date between '2025-02-04' and '2025-02-10') -- 本次活动Benchmark时间窗口：周二-周一
    or (date between '2024-02-09' and '2024-02-15') -- 上次活动时间窗口：周五-周四
    or (date between '2024-02-02' and '2024-02-08')) -- 上次活动Benchmark时间窗口：周五-周四
    and data_type= 'event'
group by
    1,2,3,4,5,6