
-- 月的payment_365居然比年高，是不是用户类型不一样，月订阅用户一般是付费频繁的再订阅用户，年一般是新用户，建议分用户类型看看
select subscription_period
     ,count(uuid) uv
     ,round(sum(payment)/count(uuid),2) payment
     ,round((1+sum(order_num_af))/count(uuid),2) order_num_365
     ,round((sum(payment)+sum(payment_af))/count(uuid),2) payment_365
from
(

--     select a.standard_order_date,a.subscription_period,a.uuid,a.payment_price_usd
--         ,b.standard_order_date standard_order_date_af
--         ,b.subscription_period subscription_period_af
--         ,b.subscription_user_type subscription_user_type_af
--         ,b.payment_price_usd payment_price_usd_af
    select a.standard_order_date,a.subscription_period,a.uuid
        ,max(a.payment_price_usd) payment
        ,sum(b.payment_price_usd) payment_af
        ,count(distinct b.order_id) order_num_af
    from
    (
        select standard_order_date,subscription_period,uuid,original_order_id,order_id,payment_price_usd
        from `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp`
        where standard_order_date between '2024-01-01' and '2024-06-30'
            and app_id in('BeautyPlus')
            and subscription_user_type in ('first_time_subscription','first_time_return_subscription')
            -- and platform='IOS'
    ) a
    left join
    (
        select standard_order_date,subscription_period,subscription_user_type,uuid,original_order_id,order_id,payment_price_usd
        from `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp`
        where standard_order_date between '2024-01-01' and date_add('2024-06-30',interval 364 day)
            and app_id in('BeautyPlus')
    ) b
    on a.uuid=b.uuid and b.standard_order_date between date_add(a.standard_order_date,interval 1 day) and date_add(a.standard_order_date,interval 364 day)
    group by 1,2,3
)
where order_num_af<20
group by 1


-- 取新增用户口径
-- 对于新用户，年高于月，对于普通用户，年略高于月，再订阅用户，年低于月。说明对于新用户这种留存不稳定的，要尽量用年去留住，但对于比较活跃的老用户，不用过度求于年
select sub_user_type
     ,subscription_period
     ,count(uuid) uv
     ,round(sum(payment)/count(uuid),2) payment
     ,round(sum(payment_af)/count(uuid),2) payment_365
     ,round(sum(order_num_af)/count(uuid),2) order_num_365
from
(
    select a.standard_order_date,a.subscription_period,a.uuid,a.sub_user_type,max(a.payment_price_usd) payment
        ,sum(b.payment_price_usd) payment_af
        ,count(distinct b.order_id) order_num_af
    from
    (
--         select standard_order_date,subscription_period,uuid,original_order_id,order_id,payment_price_usd
--         from `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp`
--         where standard_order_date between '2024-01-01' and '2024-06-30'
--             and app_id in('BeautyPlus')
--             and subscription_user_type in ('first_time_subscription','first_time_return_subscription')
--             -- and platform='IOS'

        select standard_order_date,sku_type subscription_period,sub_user_type
             ,new_uuid uuid,purchase_order_id,payment_price_usd
        from `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_abtest`
        where date between '2024-01-01' and '2024-06-30'
            and event_name in ('subscription_try_suc')
            and standard_order_date is not null and purchase_date is not null
    ) a
    left join
    (
        select standard_order_date,subscription_period,subscription_user_type,uuid,original_order_id,order_id,payment_price_usd
        from `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp`
        where standard_order_date between '2024-01-01' and date_add('2024-06-30',interval 364 day)
            and app_id in('BeautyPlus')
    ) b
    on a.uuid=b.uuid and b.standard_order_date between date_add(a.standard_order_date,interval 0 day) and date_add(a.standard_order_date,interval 364 day)
    group by 1,2,3,4
)
where order_num_af<20 and payment_af>0
group by 1,2
order by 1,2