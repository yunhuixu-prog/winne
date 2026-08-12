
select standard_order_date,case when subscription_user_type in ('intro pay as you go','pay up front') then 'promotional'
            when subscription_user_type in ('return_renewal','repeated_renewal') then 'renewal'
            when subscription_user_type in ('first_time_subscription') then 'first_time'
            when subscription_user_type in ('first_time_return_subscription') then 'first_time_return'
        end types
        ,sku
        ,count(distinct original_order_id) uv
        ,round(sum(payment_price_usd)) bookings
from `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp`
where standard_order_date between '2025-06-20' and '2025-07-10'
    and app_id in('BeautyPlus')
    -- and platform='IOS'
group by 1,2,3
