declare cal_date default date('2024-11-20');
with ori_order_table as
(
    select    platform
         ,    standard_order_date
         ,    if(offer_method = 'normal',subscription_user_type,'promotional')subscription_user_type
         ,    subscription_period
         ,    is_ua
         ,    country
         ,    count(distinct original_order_id)uv
         ,    count(distinct order_id)orders
         ,    sum(payment_price_usd)bookings
    from `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp_history_backup`
    where update_date = date_add(cal_date,interval 1 day)
        and  app_id in ('BeautyPlus')  and order_status in (1,2)
        and standard_order_date >= '2024-09-01'  and standard_order_date <= '2024-11-20'
    group by 1,2,3,4,5,6
),
fix_order_table as
(
    select    platform
         ,    standard_order_date
         ,     if(offer_method = 'normal',subscription_user_type,'promotional')subscription_user_type
         ,    subscription_period
         ,    is_ua
         ,    country
         ,    count(distinct original_order_id)fix_uv
         ,    count(distinct order_id)fix_orders
         ,    sum(payment_price_usd)fix_bookings
    from `dataintegration-265403.dwd.dwd_dap_subscription_trial_subscription_retention_daily`
    where event_date_hk = cal_date and app_id in ('BeautyPlus')
      and standard_order_date >= '2024-09-01'  and standard_order_date <= '2024-11-20'
      and order_status in (1,2)
    group by 1,2,3,4,5,6
)

select o.platform,o.standard_order_date,o.subscription_user_type,o.subscription_period,o.is_ua,o.country,o.uv,o.orders,round(o.bookings) bookings
     ,f.fix_uv,f.fix_orders,round(f.fix_bookings) fix_bookings
from ori_order_table o
join fix_order_table f
on o.standard_order_date = f.standard_order_date
       and IFNULL(CAST(o.platform AS STRING), '') = IFNULL(CAST(f.platform AS STRING), '')
       AND IFNULL(CAST(o.is_ua AS STRING), '') = IFNULL(CAST(f.is_ua AS STRING), '')
       AND IFNULL(CAST(o.country AS STRING), '') = IFNULL(CAST(f.country AS STRING), '')
       AND IFNULL(CAST(o.subscription_period AS STRING), '') = IFNULL(CAST(f.subscription_period AS STRING), '')
       and IFNULL(CAST(o.subscription_user_type AS STRING), '') = IFNULL(CAST(f.subscription_user_type AS STRING), '')
-- where o.subscription_user_type in ('promotional')
-- where o.subscription_user_type in ('first_time_subscription','first_time_return_subscription')
where o.subscription_user_type in ('repeated_renewal','return_renewal')
