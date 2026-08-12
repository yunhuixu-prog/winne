select event_date
    ,case when event_date between '2025-08-11' and '2025-08-17' then '25:0811~0817'
          when event_date between '2025-08-18' and '2025-08-24' then '25:0818~0824'
          when event_date between '2025-08-25' and '2025-08-31' then '25:0825~0831'
          when event_date between '2025-09-01' and '2025-09-07' then '25:0901~0907'

--           when event_date between '2024-08-11' and '2024-08-17' then '24:0811~0817'
--           when event_date between '2024-08-18' and '2024-08-24' then '24:0818~0824'
--           when event_date between '2024-08-25' and '2024-08-31' then '24:0825~0831'
--           when event_date between '2024-09-01' and '2024-09-07' then '24:0901~0907'
    end week
    ,case when country in ('Brazil','United States','United Kingdom') then country else 'else' end country,is_new,is_ua
    ,second
    ,sum(enter_uv) enter_uv
    ,sum(click_uv) click_uv
    ,sum(sub_success_uv) sub_success_uv
    ,sum(sub_to_paid_uv) sub_to_paid_uv
    ,round(sum(sub_to_paid_revenue),2) sub_to_paid_revenue
from airbrush-1324.stat.dws_airbrush_trial_sub_grads_view
where
--     ((event_date between '2025-08-11' and '2025-09-07') or (event_date between '2024-08-11' and '2024-09-07'))
    event_date between '2025-08-11' and '2025-09-07'
    and category='Second Source'
--     and first='Else' and second='Onboarding'
    and first='Edit'
group by 1,2,3,4,5,6




select event_date
    ,case when event_date between '2025-08-11' and '2025-08-17' then '25:0811~0817'
          when event_date between '2025-08-18' and '2025-08-24' then '25:0818~0824'
          when event_date between '2025-08-25' and '2025-08-31' then '25:0825~0831'
          when event_date between '2025-09-01' and '2025-09-07' then '25:0901~0907'
    end week
    ,case when country in ('Brazil','United States','United Kingdom') then country else 'else' end country,is_new,is_ua
    ,sum(enter_uv) enter_uv
    ,sum(click_uv) click_uv
    ,sum(sub_success_uv) sub_success_uv
    ,sum(sub_to_paid_uv) sub_to_paid_uv
    ,round(sum(sub_to_paid_revenue),2) sub_to_paid_revenue
from airbrush-1324.stat.dws_airbrush_trial_sub_grads_view
where
    event_date between '2025-08-11' and '2025-09-07'
    and category='First Source' and first='Edit'
group by 1,2,3,4,5



select event_date
    ,case when event_date between '2025-08-11' and '2025-08-17' then '25:0811~0817'
          when event_date between '2025-08-18' and '2025-08-24' then '25:0818~0824'
          when event_date between '2025-08-25' and '2025-08-31' then '25:0825~0831'
          when event_date between '2025-09-01' and '2025-09-07' then '25:0901~0907'
    end week
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
    event_date between '2025-08-11' and '2025-09-07'
group by
    1,2,3,4,5,6

