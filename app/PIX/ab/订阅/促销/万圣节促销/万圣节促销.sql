

select event_date
     ,case   when event_date between '2021-10-28' and '2021-11-02' then '21 万圣 2021-10-28 - 2021-11-02'
            when event_date between '2021-10-21' and '2021-10-26' then '21 万圣Benchmark 2021-10-21 - 2021-10-26'
            when event_date between '2022-10-28' and '2022-11-02' then '22 万圣 2022-10-28 - 2022-11-02'
            when event_date between '2022-10-21' and '2022-10-26' then '22 万圣Benchmark 2022-10-21 - 2022-10-26'
            when event_date between '2023-10-28' and '2023-11-02' then '23 万圣 2023-10-28 - 2023-11-02'
            when event_date between '2023-10-21' and '2023-10-26' then '23 万圣Benchmark 2023-10-21 - 2023-10-26'
            when event_date between '2024-10-28' and '2024-11-02' then '24 万圣 2024-10-28 - 2024-11-02'
            when event_date between '2024-10-21' and '2024-10-26' then '24 万圣Benchmark 2024-10-21 - 2024-10-26'
            when event_date between '2025-10-28' and '2025-11-02' then '25 万圣 2025-10-28 - 2025-11-02'
            when event_date between '2025-10-21' and '2025-10-26' then '25 万圣Benchmark 2025-10-21 - 2025-10-26'
            end date_label
     ,case   when country in ('Brazil', 'United States', 'United Kingdom') then country
            else 'else'
            end country
     , platform
     , is_new
     , is_ua
     , case when duration in ('Monthly','Yearly') then duration else 'else' end duration
     , sum(DAU) DAU
     , sum(enter_uv) enter_uv
     , sum(click_uv) click_uv
     , sum(sub_success_uv) sub_success_uv
     , sum(sub_to_paid_uv) sub_to_paid_uv
     , round(sum(sub_to_paid_revenue),2) sub_to_paid_revenue
     , sum(trial_uv) trial_uv
     , sum(trial_to_paid_uv) trial_to_paid_uv
from airbrush-1324.stat.dws_airbrush_subscription_overview_view
where
    (
        event_date between '2025-10-28' and '2025-11-02'
        or event_date between '2025-10-21' and '2025-10-26'
        or event_date between '2024-10-28' and '2024-11-02'
        or event_date between '2024-10-21' and '2024-10-26'
        or event_date between '2023-10-28' and '2023-11-02'
        or event_date between '2023-10-21' and '2023-10-26'
        or event_date between '2022-10-28' and '2022-11-02'
        or event_date between '2022-10-21' and '2022-10-26'
        or event_date between '2021-10-28' and '2021-11-02'
        or event_date between '2021-10-21' and '2021-10-26'
    )
group by 1,2,3,4,5,6,7

;


select event_date
     ,case   when event_date between '2021-10-28' and '2021-11-02' then '21 万圣 2021-10-28 - 2021-11-02'
            when event_date between '2021-10-21' and '2021-10-26' then '21 万圣Benchmark 2021-10-21 - 2021-10-26'
            when event_date between '2022-10-28' and '2022-11-02' then '22 万圣 2022-10-28 - 2022-11-02'
            when event_date between '2022-10-21' and '2022-10-26' then '22 万圣Benchmark 2022-10-21 - 2022-10-26'
            when event_date between '2023-10-28' and '2023-11-02' then '23 万圣 2023-10-28 - 2023-11-02'
            when event_date between '2023-10-21' and '2023-10-26' then '23 万圣Benchmark 2023-10-21 - 2023-10-26'
            when event_date between '2024-10-28' and '2024-11-02' then '24 万圣 2024-10-28 - 2024-11-02'
            when event_date between '2024-10-21' and '2024-10-26' then '24 万圣Benchmark 2024-10-21 - 2024-10-26'
            when event_date between '2025-10-28' and '2025-11-02' then '25 万圣 2025-10-28 - 2025-11-02'
            when event_date between '2025-10-21' and '2025-10-26' then '25 万圣Benchmark 2025-10-21 - 2025-10-26'
            end date_label
     ,case   when country in ('Brazil', 'United States', 'United Kingdom') then country
            else 'else'
            end country
     ,is_paying
     ,count(distinct user_pseudo_id) uv
     ,count(distinct case when is_sub=1 then user_pseudo_id end) sub_uv
     ,count(distinct case when is_sub_to_paid=1 then user_pseudo_id end) sub_to_paid_uv
     ,count(distinct case when is_trial=1 then user_pseudo_id end) trial_uv
     ,count(distinct case when is_trial_to_paid=1 then user_pseudo_id end) trial_to_paid_uv
     ,count(distinct case when is_sub_month=1 then user_pseudo_id end) sub_month_uv
     ,count(distinct case when is_sub_year=1 then user_pseudo_id end) sub_year_uv
     ,count(distinct case when is_sub_to_paid_month=1 then user_pseudo_id end) sub_to_paid_month_uv
     ,count(distinct case when is_sub_to_paid_year=1 then user_pseudo_id end) sub_to_paid_year_uv
     ,sum(revenue) revenue
from dataintegration-265403.temp.winne_temp_day_type_2
where
    (
        event_date between '2025-10-28' and '2025-11-02'
        or event_date between '2025-10-21' and '2025-10-26'
        or event_date between '2024-10-28' and '2024-11-02'
        or event_date between '2024-10-21' and '2024-10-26'
        or event_date between '2023-10-28' and '2023-11-02'
        or event_date between '2023-10-21' and '2023-10-26'
        or event_date between '2022-10-28' and '2022-11-02'
        or event_date between '2022-10-21' and '2022-10-26'
        or event_date between '2021-10-28' and '2021-11-02'
        or event_date between '2021-10-21' and '2021-10-26'
    )
group by 1,2,3,4

