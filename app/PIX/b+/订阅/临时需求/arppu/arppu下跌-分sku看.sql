
select date_trunc(standard_order_date, month) event_month
     ,case when standard_order_date between '2023-10-01' and '2023-11-01' then '23.10-23.11'
           when standard_order_date between '2024-10-01' and '2024-11-01' then '24.10-24.11'
     end compare_d
     ,FORMAT_DATE('%m-%d', standard_order_date) days
--      ,sku
     ,subscription_period
     ,count(distinct original_order_id) uv
     ,round(sum(payment_price_usd),2) bookings
from `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp`
where (standard_order_date between '2023-10-01' and '2023-11-01'
           or standard_order_date between '2024-10-01' and '2024-11-01')
    and app_id in('BeautyPlus')
    and subscription_user_type in ('first_time_subscription','first_time_return_subscription')
    and country='Japan'
group by 1,2,3,4
;

select sku
     ,subscription_period
     ,count(distinct original_order_id) uv
     ,round(sum(payment_price_usd),2) bookings
from `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp`
where standard_order_date between '2025-01-01' and '2025-05-31'
    and app_id in('BeautyPlus')
    and subscription_user_type in ('intro pay as you go','trial mix pay up front','pay up front')
--     and country='Japan'
group by 1,2



