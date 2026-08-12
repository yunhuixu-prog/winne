select event_date_hk
    ,case   when event_date_hk between '2025-04-18' and '2025-04-21' then '25 复活节 2025.04.18 - 2025.04.21'
            when event_date_hk between '2025-04-11' and '2025-04-14' then '25 Benchmark 2025.04.11 - 2025.04.14'
            when event_date_hk between '2024-03-29' and '2024-04-01' then '24 复活节 2024.03.29 - 2024.04.01'
            when event_date_hk between '2024-03-22' and '2024-03-25' then '24 Benchmark 2024.03.22 - 2024.03.25'
            end date_label
    ,a.platform
    ,a.is_ua
    ,a.is_new
    ,count(distinct )
FROM `dataintegration-265403.stat.stat_active_advice_detail_d`
where ((event_date_hk between '2025-04-18' and '2025-04-21') -- 本次活动时间窗口
    or (event_date_hk between '2025-04-11' and '2025-04-14') -- 本次活动Benchmark时间窗口
    or (event_date_hk between '2024-03-29' and '2024-04-01') -- 上次活动时间窗口，真实窗口：3.31-4.1
    or (event_date_hk between '2024-03-22' and '2024-03-25')) -- 上次活动Benchmark时间窗口
    and app_name = 'BeautyPlus'