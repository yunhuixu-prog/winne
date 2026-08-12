-- 月的payment_365比年高，一个原因是月可能又去订阅了年导致的
-- 只看相同sku续订，月还是比年高，是不是用户类型不一样，月订阅用户一般是付费频繁的再订阅用户，年一般是新用户，建议分用户类型看看
select subscription_period
     ,count(uuid) uv
     ,round(sum(payment)/count(uuid),2) payment
     ,round((sum(order_num_af+1))/count(uuid),2) order_num_365
     ,round((sum(payment)+sum(payment_af_30))/count(uuid),2) payment_30
     ,round((sum(payment)+sum(payment_af_365))/count(uuid),2) payment_365
     ,round((sum(same_order_num_af+1))/count(uuid),2) same_order_num_365
     ,round((sum(payment)+sum(same_payment_af))/count(uuid),2) same_payment_365
from
(

--     select a.standard_order_date,a.subscription_period,a.uuid,a.payment_price_usd
--         ,b.standard_order_date standard_order_date_af
--         ,b.subscription_period subscription_period_af
--         ,b.subscription_user_type subscription_user_type_af
--         ,b.payment_price_usd payment_price_usd_af
    select a.standard_order_date,a.subscription_period,a.uuid
        ,max(a.payment_price_usd) payment
        ,sum(case when b.standard_order_date between date_add(a.standard_order_date,interval 1 day) and date_add(a.standard_order_date,interval 29 day) then
            b.payment_price_usd end) payment_af_30
        ,sum(b.payment_price_usd) payment_af_365
        ,count(distinct b.order_id) order_num_af
        ,sum(case when b.subscription_period=a.subscription_period then b.payment_price_usd end) same_payment_af
        ,count(distinct case when b.subscription_period=a.subscription_period then b.order_id end) same_order_num_af
    from
    (
        select standard_order_date,platform,subscription_period,uuid,original_order_id,order_id,payment_price_usd
        from `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp`
        where standard_order_date between '2024-01-01' and '2024-10-31'
            and app_id in('AirBrush')
            and subscription_user_type in ('first_time_subscription','first_time_return_subscription')
            -- and platform='IOS'
    ) a
    left join
    (
        select standard_order_date,subscription_period,subscription_user_type,uuid,original_order_id,order_id,payment_price_usd
        from `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp`
        where standard_order_date between '2024-01-01' and date_add('2024-10-31',interval 364 day)
            and app_id in('AirBrush')
    ) b
    on a.uuid=b.uuid and b.standard_order_date between date_add(a.standard_order_date,interval 1 day) and date_add(a.standard_order_date,interval 364 day)
    group by 1,2,3
)
where order_num_af<20
group by 1


