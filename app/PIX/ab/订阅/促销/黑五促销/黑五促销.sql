

select event_date
     ,case   when event_date between '2021-11-25' and '2021-11-30' then '21 黑五 2021-11-25 - 2021-11-30'
            when event_date between '2021-11-18' and '2021-11-23' then '21 黑五Benchmark 2021-11-18 - 2021-11-23'
            when event_date between '2022-11-24' and '2022-11-29' then '22 黑五 2022-11-24 - 2022-11-29'
            when event_date between '2022-11-17' and '2022-11-22' then '22 黑五Benchmark 2022-11-17 - 2022-11-22'
            when event_date between '2023-11-23' and '2023-11-28' then '23 黑五 2023-11-23 - 2023-11-28'
            when event_date between '2023-11-16' and '2023-11-21' then '23 黑五Benchmark 2023-11-16 - 2023-11-21'
            when event_date between '2024-11-28' and '2024-12-03' then '24 黑五 2024-11-28 - 2024-12-03'
            when event_date between '2024-11-21' and '2024-11-26' then '24 黑五Benchmark 2024-11-21 - 2024-11-26'
            when event_date between '2025-11-27' and '2025-12-02' then '25 黑五 2025-11-27 - 2025-12-02'
            when event_date between '2025-11-20' and '2025-11-25' then '25 黑五Benchmark 2025-11-20 - 2025-11-25'
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
        event_date between '2025-11-27' and '2025-12-02'
        or event_date between '2025-11-20' and '2025-11-25'
        or event_date between '2024-11-28' and '2024-12-03'
        or event_date between '2024-11-21' and '2024-11-26'
        or event_date between '2023-11-23' and '2023-11-28'
        or event_date between '2023-11-16' and '2023-11-21'
        or event_date between '2022-11-24' and '2022-11-29'
        or event_date between '2022-11-17' and '2022-11-22'
        or event_date between '2021-11-25' and '2021-11-30'
        or event_date between '2021-11-18' and '2021-11-23'
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
         ,case   when event_date between '2021-11-25' and '2021-11-30' then '21 黑五 2021-11-25 - 2021-11-30'
                when event_date between '2021-11-18' and '2021-11-23' then '21 黑五Benchmark 2021-11-18 - 2021-11-23'
                when event_date between '2022-11-24' and '2022-11-29' then '22 黑五 2022-11-24 - 2022-11-29'
                when event_date between '2022-11-17' and '2022-11-22' then '22 黑五Benchmark 2022-11-17 - 2022-11-22'
                when event_date between '2023-11-23' and '2023-11-28' then '23 黑五 2023-11-23 - 2023-11-28'
                when event_date between '2023-11-16' and '2023-11-21' then '23 黑五Benchmark 2023-11-16 - 2023-11-21'
                when event_date between '2024-11-28' and '2024-12-03' then '24 黑五 2024-11-28 - 2024-12-03'
                when event_date between '2024-11-21' and '2024-11-26' then '24 黑五Benchmark 2024-11-21 - 2024-11-26'
                when event_date between '2025-11-27' and '2025-12-02' then '25 黑五 2025-11-27 - 2025-12-02'
                when event_date between '2025-11-20' and '2025-11-25' then '25 黑五Benchmark 2025-11-20 - 2025-11-25'
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
            event_date between '2025-11-27' and '2025-12-02'
            or event_date between '2025-11-20' and '2025-11-25'
            or event_date between '2024-11-28' and '2024-12-03'
            or event_date between '2024-11-21' and '2024-11-26'
            or event_date between '2023-11-23' and '2023-11-28'
            or event_date between '2023-11-16' and '2023-11-21'
            or event_date between '2022-11-24' and '2022-11-29'
            or event_date between '2022-11-17' and '2022-11-22'
            or event_date between '2021-11-25' and '2021-11-30'
            or event_date between '2021-11-18' and '2021-11-23'
        )
    group by 1,2,3,4,5,6,7
)
group by 1,2,3,4,5,6
