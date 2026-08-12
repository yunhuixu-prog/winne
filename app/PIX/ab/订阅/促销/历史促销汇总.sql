select event_date
    ,case   when event_date between '2021-10-29' and '2021-11-02' then '21 万圣 2021-10-29 - 2021-11-02'
            when event_date between '2021-10-22' and '2021-10-26' then '21 万圣Benchmark 2021-10-22 - 2021-10-26'
            when event_date between '2022-10-28' and '2022-11-01' then '22 万圣 2022-10-28 - 2022-11-01'
            when event_date between '2022-10-21' and '2022-10-25' then '22 万圣Benchmark 2022-10-21 - 2022-10-25'
            when event_date between '2023-10-28' and '2023-11-01' then '23 万圣 2023-10-28 - 2023-11-01'
            when event_date between '2023-10-21' and '2023-10-25' then '23 万圣Benchmark 2023-10-21 - 2023-10-25'
            when event_date between '2024-10-29' and '2024-11-02' then '24 万圣 2024-10-29 - 2024-11-02'
            when event_date between '2024-10-22' and '2024-10-26' then '24 万圣Benchmark 2024-10-22 - 2024-10-26'
            -- 黑五
            when event_date between '2021-11-26' and '2021-11-29' then '21 黑五 2021-11-26 - 2021-11-29'
            when event_date between '2021-11-19' and '2021-11-22' then '21 黑五Benchmark 2021-11-19 - 2021-11-22'
            when event_date between '2022-11-25' and '2022-11-28' then '22 黑五 2022-11-25 - 2022-11-28'
            when event_date between '2022-11-18' and '2022-11-21' then '22 黑五Benchmark 2022-11-18 - 2022-11-21'
            when event_date between '2023-11-24' and '2023-11-27' then '23 黑五 2023-11-24 - 2023-11-27'
            when event_date between '2023-11-17' and '2023-11-20' then '23 黑五Benchmark 2023-11-17 - 2023-11-20'
            when event_date between '2024-11-29' and '2024-12-02' then '24 黑五 2024-11-29 - 2024-12-02'
            when event_date between '2024-11-22' and '2024-11-25' then '24 黑五Benchmark 2024-11-22 - 2024-11-25'
            -- 圣诞
            when event_date between '2021-12-24' and '2021-12-28' then '21 圣诞 2021-12-24 - 2021-12-28'
            when event_date between '2021-12-17' and '2021-12-21' then '21 圣诞Benchmark 2021-12-17 - 2021-12-21'
            when event_date between '2022-12-23' and '2022-12-27' then '22 圣诞 2022-12-23 - 2022-12-27'
            when event_date between '2022-12-16' and '2022-12-20' then '22 圣诞Benchmark 2022-12-16 - 2022-12-20'
            when event_date between '2023-12-22' and '2023-12-26' then '23 圣诞 2023-12-22 - 2023-12-26'
            when event_date between '2023-12-15' and '2023-12-19' then '23 圣诞Benchmark 2023-12-15 - 2023-12-19'
            when event_date between '2024-12-22' and '2024-12-26' then '24 圣诞 2024-12-22 - 2024-12-26'
            when event_date between '2024-12-15' and '2024-12-19' then '24 圣诞Benchmark 2024-12-15 - 2024-12-19'
            end date_label
    ,a.platform,a.is_new,a.is_ua
    ,case   when country in ('Brazil', 'United States', 'United Kingdom') then country
            else 'else'
            end country
    ,sum(DAU) DAU
    ,sum(enter_uv) enter_uv
    ,sum(click_uv) click_uv
    ,sum(sub_success_uv) sub_success_uv
    ,sum(sub_to_paid_uv) sub_to_paid_uv
    ,round(sum(sub_to_paid_revenue),2) sub_to_paid_revenue
from airbrush-1324.stat.dws_airbrush_subscription_overview_view a
where
    (
    -- 万圣
       (event_date between '2021-10-29' and '2021-11-02') -- 21，周五-周二
    or (event_date between '2021-10-22' and '2021-10-26') -- 21pre，周五-周二
    or (event_date between '2022-10-28' and '2022-11-01') -- 22，周五-周二
    or (event_date between '2022-10-21' and '2022-10-25') -- 22pre，周五-周二
    or (event_date between '2023-10-28' and '2023-11-01') -- 23，周六-周三
    or (event_date between '2023-10-21' and '2023-10-25') -- 23pre，周六-周三
    or (event_date between '2024-10-29' and '2024-11-02') -- 24，周二-周六
    or (event_date between '2024-10-22' and '2024-10-26') -- 24pre，周二-周六
    -- 黑五
    or (event_date between '2021-11-26' and '2021-11-29') -- 21，周五-周一
    or (event_date between '2021-11-19' and '2021-11-22') -- 21pre，周五-周一
    or (event_date between '2022-11-25' and '2022-11-28') -- 22，周五-周一
    or (event_date between '2022-11-18' and '2022-11-21') -- 22pre，周五-周一
    or (event_date between '2023-11-24' and '2023-11-27') -- 23，周五-周一
    or (event_date between '2023-11-17' and '2023-11-20') -- 23pre，周五-周一
    or (event_date between '2024-11-29' and '2024-12-02') -- 24，周五-周一
    or (event_date between '2024-11-22' and '2024-11-25') -- 24pre，周五-周一
    -- 圣诞
    or (event_date between '2021-12-24' and '2021-12-28') -- 21，周五-周二
    or (event_date between '2021-12-17' and '2021-12-21') -- 21pre，周五-周二
    or (event_date between '2022-12-23' and '2022-12-27') -- 22，周五-周二
    or (event_date between '2022-12-16' and '2022-12-20') -- 22pre，周五-周二
    or (event_date between '2023-12-22' and '2023-12-26') -- 23，周五-周二
    or (event_date between '2023-12-15' and '2023-12-19') -- 23pre，周五-周二
    or (event_date between '2024-12-22' and '2024-12-26') -- 24，周日-周四
    or (event_date between '2024-12-15' and '2024-12-19') -- 24pre，周日-周四
    )
group by
    1,2,3,4,5,6


union all

select event_date
    ,case   when event_date between '2021-12-31' and '2022-01-05' then '21 新年 2021-12-31 - 2022-01-05'
            when event_date between '2021-12-17' and '2021-12-22' then '21 新年Benchmark 2021-12-17 - 2021-12-22'
            when event_date between '2022-12-30' and '2023-01-04' then '22 新年 2022-12-30 - 2023-01-04'
            when event_date between '2022-12-16' and '2022-12-21' then '22 新年Benchmark 2022-12-16 - 2022-12-21'
            when event_date between '2023-12-29' and '2024-01-03' then '23 新年 2023-12-29 - 2024-01-03'
            when event_date between '2023-12-15' and '2023-12-20' then '23 新年Benchmark 2023-12-15 - 2023-12-20'
            when event_date between '2024-12-29' and '2025-01-03' then '24 新年 2024-12-29 - 2025-01-03'
            when event_date between '2024-12-15' and '2024-12-20' then '24 新年Benchmark 2024-12-15 - 2024-12-20'
            end date_label
    ,a.platform,a.is_new,a.is_ua
    ,case   when country in ('Brazil', 'United States', 'United Kingdom') then country
            else 'else'
            end country
    ,sum(DAU) DAU
    ,sum(enter_uv) enter_uv
    ,sum(click_uv) click_uv
    ,sum(sub_success_uv) sub_success_uv
    ,sum(sub_to_paid_uv) sub_to_paid_uv
    ,round(sum(sub_to_paid_revenue),2) sub_to_paid_revenue
from airbrush-1324.stat.dws_airbrush_subscription_overview_view a
where
    (
    -- 新年
       (event_date between '2021-12-31' and '2022-01-05') -- 21，周五-周三
    or (event_date between '2021-12-17' and '2021-12-22') -- 21pre，周五-周三
    or (event_date between '2022-12-30' and '2023-01-04') -- 22，周五-周三
    or (event_date between '2022-12-16' and '2022-12-21') -- 22pre，周五-周三
    or (event_date between '2023-12-29' and '2024-01-03') -- 23，周五-周三
    or (event_date between '2023-12-15' and '2023-12-20') -- 23pre，周五-周三
    or (event_date between '2024-12-29' and '2025-01-03') -- 24，周日-周五
    or (event_date between '2024-12-15' and '2024-12-20') -- 24pre，周日-周五
    )
group by
    1,2,3,4,5,6




