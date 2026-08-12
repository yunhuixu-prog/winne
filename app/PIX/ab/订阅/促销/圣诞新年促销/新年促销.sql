select event_date
     ,case
            when event_date between '2021-12-29' and '2022-01-04' then '21 新年'
            when event_date between '2022-12-29' and '2023-01-04' then '22 新年'
            when event_date between '2023-12-29' and '2024-01-04' then '23 新年'
            when event_date between '2024-12-29' and '2025-01-04' then '24 新年'
            when event_date between '2025-12-29' and '2026-01-04' then '25 新年'

            when event_date between '2021-12-15' and '2021-12-21' then '21 新年Benchmark'
            when event_date between '2022-12-15' and '2022-12-21' then '22 新年Benchmark'
            when event_date between '2023-12-15' and '2023-12-21' then '23 新年Benchmark'
            when event_date between '2024-12-15' and '2024-12-21' then '24 新年Benchmark'
            when event_date between '2025-12-15' and '2025-12-21' then '25 新年Benchmark'
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
         -- 新年
           (event_date between '2021-12-29' and '2022-01-04') -- 21，周三-周二
        or (event_date between '2022-12-29' and '2023-01-04') -- 22，周四-周三
        or (event_date between '2023-12-29' and '2024-01-04') -- 23，周五-周四
        or (event_date between '2024-12-29' and '2025-01-04') -- 24，周日-周六
        or (event_date between '2025-12-29' and '2026-01-04') -- 25，周一-周日

        or (event_date between '2021-12-15' and '2021-12-21') -- 21pre，周三-周二
        or (event_date between '2022-12-15' and '2022-12-21') -- 22pre，周四-周三
        or (event_date between '2023-12-15' and '2023-12-21') -- 23pre，周五-周四
        or (event_date between '2024-12-15' and '2024-12-21') -- 24pre，周日-周六
        or (event_date between '2025-12-15' and '2025-12-21') -- 24pre，周一-周日
    )
group by 1,2,3,4,5,6,7

;

select date_label,country,is_new,is_ua,is_paying,install_days_type
    ,sum(uv) uv
    ,sum(sub_uv) sub_uv
    ,sum(sub_to_paid_uv) sub_to_paid_uv
    ,sum(trial_uv) trial_uv
    ,sum(trial_to_paid_uv) trial_to_paid_uv
    ,sum(sub_month_uv) sub_month_uv
    ,sum(sub_year_uv) sub_year_uv
    ,sum(sub_to_paid_month_uv) sub_to_paid_month_uv
    ,sum(sub_to_paid_year_uv) sub_to_paid_year_uv
    ,round(sum(revenue),2) revenue
from
(
    select event_date
         ,case
            when event_date between '2021-12-29' and '2022-01-04' then '21 新年'
            when event_date between '2022-12-29' and '2023-01-04' then '22 新年'
            when event_date between '2023-12-29' and '2024-01-04' then '23 新年'
            when event_date between '2024-12-29' and '2025-01-04' then '24 新年'
            when event_date between '2025-12-29' and '2026-01-04' then '25 新年'

            when event_date between '2021-12-15' and '2021-12-21' then '21 新年Benchmark'
            when event_date between '2022-12-15' and '2022-12-21' then '22 新年Benchmark'
            when event_date between '2023-12-15' and '2023-12-21' then '23 新年Benchmark'
            when event_date between '2024-12-15' and '2024-12-21' then '24 新年Benchmark'
            when event_date between '2025-12-15' and '2025-12-21' then '25 新年Benchmark'
          end date_label
         ,case   when country in ('Brazil', 'United States', 'United Kingdom') then country
                else 'else'
                end country
         ,is_new,is_ua
         ,is_paying
         ,case when install_days<=30 then '1:1~30'
               when install_days<=180 then '2:31~180'
               when install_days<=365 then '3:181~365'
               else '4:365+'
         end install_days_type
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
            -- 新年
               (event_date between '2021-12-29' and '2022-01-04') -- 21，周三-周二
            or (event_date between '2022-12-29' and '2023-01-04') -- 22，周四-周三
            or (event_date between '2023-12-29' and '2024-01-04') -- 23，周五-周四
            or (event_date between '2024-12-29' and '2025-01-04') -- 24，周日-周六
            or (event_date between '2025-12-29' and '2026-01-04') -- 25，周一-周日

            or (event_date between '2021-12-15' and '2021-12-21') -- 21pre，周三-周二
            or (event_date between '2022-12-15' and '2022-12-21') -- 22pre，周四-周三
            or (event_date between '2023-12-15' and '2023-12-21') -- 23pre，周五-周四
            or (event_date between '2024-12-15' and '2024-12-21') -- 24pre，周日-周六
            or (event_date between '2025-12-15' and '2025-12-21') -- 24pre，周一-周日
        )
    group by 1,2,3,4,5,6,7
)
group by 1,2,3,4,5,6
