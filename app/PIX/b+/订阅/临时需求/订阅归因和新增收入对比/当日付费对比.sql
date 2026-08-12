
-- 大概差距，除了埋点会漏，还有宽限期的问题，订阅归因表应该超过时间的试用转付费就不追溯了，例如834172496。以及两者对新增的定义不太一样，收入表根据subscription_user_type，但看起来并不完全等于客户端新增
select coalesce(a.purchase_date,b.standard_order_date) purchase_date
    ,coalesce(a.original_order_id,b.original_order_id) original_order_id
    ,coalesce(a.purchase_order_id,b.order_id) purchase_order_id
    ,coalesce(a.new_uuid,b.uuid) uuid
    ,coalesce(a.sub_success_offer_type,b.subscription_user_type) sub_success_offer_type
    ,coalesce(a.sku,b.sku) sku
    ,coalesce(a.payment_price_usd,b.payment_price_usd) payment_price_usd
from
(
select a.date,a.sub_success_offer_type,a.sku,a.new_uuid,a.user_pseudo_id
     ,a.original_order_id,a.order_id,a.standard_order_date
     ,a.purchase_date,a.purchase_order_id,a.payment_price_usd
--      ,date_diff(a.purchase_date,a.standard_order_date,day) trial_days
from `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_abtest` a
WHERE a.purchase_date >=  '2025-06-01'
    and event_name in ('subscription_try_suc')
    and standard_order_date is not null
    and purchase_date is not null
) a
full join
(
select standard_order_date,original_order_id,uuid,sku,order_id,payment_price_usd,subscription_user_type
from `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp`
where standard_order_date >= '2025-06-01'
    and app_id in ('BeautyPlus')
    and subscription_user_type in ('intro pay as you go','trial mix pay up front','pay up front','first_time_return_subscription','first_time_subscription')
    and order_status=1
) b
on a.new_uuid=b.uuid and a.purchase_order_id=b.order_id and a.purchase_date=b.standard_order_date
where a.new_uuid is null
;


select date,event_name,sku_type,user_pseudo_id,sku,new_uuid,original_order_id,order_id,standard_order_date
    ,purchase_date,purchase_order_id,payment_price_usd,sub_success_offer_type
from `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_abtest` a
WHERE a.date >=  '2025-05-01'
    and a.new_uuid='834172496'
;
select standard_order_date,subscription_period,original_order_id,order_id,uuid,order_status,payment_price_usd,sku_price,sku,subscription_user_type
from `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp`
where standard_order_date >= '2025-01-01'
    and app_id in ('BeautyPlus')
    and uuid='834172496'
order by standard_order_date
