select    standard_order_date
         ,    platform
         ,    subscription_period
         ,    sku
         ,    subscription_user_type
         ,    count(distinct original_order_id) uv
         ,    count(distinct order_id) orders
         ,    round(sum(payment_price_usd),2) bookings
--     from `dataintegration-265403.dwd.dwd_dap_subscription_trial_subscription_retention_daily`
    from dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp
    where app_id in ('AirBrush')
--       and event_date_hk='2025-09-14'
      and standard_order_date between '2025-01-01'  and '2025-09-15'
      and sku in ('com.magicv.AirBrush.sub.allAccess.1month.newus.fullPrice'
                 ,'com.magicv.AirBrush.sub.allAccess.1year.newus.fullPrice'
                 ,'com.magicv.AirBrush.sub.allAccess.1year.sharegift'
                 ,'com.magicv.AirBrush.sub.allAccess.1year.discount15'
                 ,'com.meitu.airbrush.subs_12mo_discount15'
                 ,''
                 )
group by 1,2,3,4,5

