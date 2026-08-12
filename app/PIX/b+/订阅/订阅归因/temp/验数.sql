
select a.*
     ,b.uv adjust_uv
     ,b.bookings adjust_bookings
     ,b.share_bookings adjust_share_bookings
from
(
    select date,event_name,sum(uv) uv,round(sum(payment_price_usd)) bookings,round(sum(Share_Revenue)) share_bookings
    from beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_v5_temp
    WHERE date between '2025-01-01' and '2025-01-15' and data_type in ('category1')
    group by 1,2
) a
left join
(
    select date,event_name,sum(uv) uv,round(sum(payment_price_usd)) bookings,round(sum(source_amount_proportion)) share_bookings
    from beautyplus-bc0ed.temp.ads_spm_trial_subscription_v5_temp
    WHERE date between '2025-01-01' and '2025-01-15' and data_type in ('category1')
    group by 1,2
) b
on a.event_name=b.event_name and a.date=b.date



select *
from beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_temp
WHERE date between '2025-01-01' and '2025-01-15'
    and event_name in ('subscription_try_suc')
    and standard_order_date is not null
--     and sku_has_trial IN ('has_trial')
    and sub_success_offer_type not in ('trial','intro_trial','promotion_trial')
    and (standard_order_date!=purchase_date or purchase_date is null)


-- 和收入看板试用人数对比
select date,count(distinct user_pseudo_id) uv
from beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_temp
WHERE date between '2025-01-01' and '2025-01-15'
    and event_name in ('subscription_try_suc')
    and standard_order_date is not null
--     and sku_has_trial IN ('has_trial')
    and sub_success_offer_type in ('trial','intro_trial','promotion_trial')
group by 1
order by 1
;
select
    standard_order_date,count(distinct uuid) uv
from `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp`
where standard_order_date between '2025-01-01' and '2025-01-15'
    and app_id in('BeautyPlus')
    and order_status in (0)
group by 1
order by 1


-- select *
select coalesce(a.date,b.date) date
    ,count(distinct a.uuid) uv_a
    ,count(distinct b.uuid) uv_b
    ,count(distinct case when a.uuid is not null then b.uuid end) uv_ab
from
(
    select distinct standard_order_date date,uuid,original_order_id,order_id
    from `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp`
    where standard_order_date between '2025-01-01' and '2025-01-15'
        and app_id in('BeautyPlus')
        and order_status in (0)
) a
full join
(
    select distinct date,new_uuid uuid,original_order_id,order_id
    from beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_temp
    WHERE date between '2025-01-01' and '2025-01-15'
        and event_name in ('subscription_try_suc')
        and standard_order_date is not null
    --     and sku_has_trial IN ('has_trial')
        and sub_success_offer_type in ('trial','intro_trial','promotion_trial')
) b
on a.date=b.date and a.uuid=b.uuid --and a.original_order_id=b.original_order_id and a.order_id=b.order_id
-- where a.date is null or b.date is null
-- where a.date is not null and b.date is not null
group by 1
order by 1

-- 是真的事件表里找不到哎
select
    app_name
    ,event_date
    ,platform
    ,event_timestamp
    ,event_name
from
    `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-01-01', '2025-01-02', 'beautyplus', false)
where
    user_pseudo_id='90507be17ca801592d9b90b6e949f2e1'
    -- user_id='249193794'
    -- func.getUserprop(user_properties,'appsflyer_id').string_value='1692279189239-3343114'
order by event_timestamp
