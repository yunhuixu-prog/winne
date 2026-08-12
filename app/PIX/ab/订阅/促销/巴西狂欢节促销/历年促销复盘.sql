select event_date
     ,case  when event_date between '2023-02-17' and '2023-02-23' then '23 狂欢'
            when event_date between '2023-02-10' and '2023-02-16' then '23 狂欢Benchmark'
            when event_date between '2024-02-09' and '2024-02-15' then '24 狂欢'
            when event_date between '2024-02-02' and '2024-02-08' then '24 狂欢Benchmark'
            when event_date between '2025-02-28' and '2025-03-06' then '25 狂欢'
            when event_date between '2025-02-21' and '2025-02-27' then '25 狂欢Benchmark'

            when event_date between '2023-06-12' and '2023-06-15' then '23 巴西情人'
            when event_date between '2023-06-05' and '2023-06-08' then '23 巴西情人Benchmark'
            when event_date between '2024-06-10' and '2024-06-13' then '24 巴西情人'
            when event_date between '2024-06-03' and '2024-06-06' then '24 巴西情人Benchmark'
            when event_date between '2025-06-09' and '2025-06-12' then '25 巴西情人'
            when event_date between '2025-06-02' and '2025-06-05' then '25 巴西情人Benchmark'
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
        event_date between '2025-02-28' and '2025-03-06'
        or event_date between '2025-02-21' and '2025-02-27'
        or event_date between '2024-02-09' and '2024-02-15'
        or event_date between '2024-02-02' and '2024-02-08'
        or event_date between '2023-02-17' and '2023-02-23'
        or event_date between '2023-02-10' and '2023-02-16'

        or event_date between '2025-06-09' and '2025-06-12'
        or event_date between '2025-06-02' and '2025-06-05'
        or event_date between '2024-06-10' and '2024-06-13'
        or event_date between '2024-06-03' and '2024-06-06'
        or event_date between '2023-06-12' and '2023-06-15'
        or event_date between '2023-06-05' and '2023-06-08'
    )
    and country='Brazil'
group by 1,2,3,4
