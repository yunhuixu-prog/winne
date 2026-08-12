--3.2排查

select EXTRACT(HOUR FROM order_date) hour
    , count(distinct case when order_status=0 then original_order_id end) trial_num
    , count(distinct case when order_status!=0 then original_order_id end) pay_num
    , sum(payment_price_usd)          payment_usd
from dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp
where app_id='BeautyPlus'
and standard_order_date between '2024-03-02' and '2024-03-02'
group by 1
order by 1