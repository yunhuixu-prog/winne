select    standard_order_date
         ,    platform
         ,    subscription_period
         ,    sku
         ,    count(distinct original_order_id) uv
         ,    count(distinct order_id) orders
         ,    round(sum(payment_price_usd),2) bookings
    from `dataintegration-265403.dwd.dwd_dap_subscription_trial_subscription_retention_daily`
    where app_id in ('BeautyPlus')
      and event_date_hk='2025-06-12'
      and standard_order_date between '2025-05-01'  and '2025-05-31'
      and order_status in (1,2)
      and offer_method in ('trial mix pay up front','pay as you go','pay up front')
group by 1,2,3,4

