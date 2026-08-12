

select
--     event_date
     date_trunc(event_date, month) event_month
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
        event_date between '2021-01-01' and '2025-10-31'
group by 1,2,3,4,5,6
