
-- trial大概差5%吧，估计是上报漏的吧，记得涛哥以前看过
select coalesce(a.standard_order_date,b.standard_order_date) standard_order_date
    ,coalesce(a.original_order_id,b.original_order_id) original_order_id
    ,coalesce(a.order_id,b.order_id) order_id
    ,coalesce(a.new_uuid,b.uuid) uuid
    ,coalesce(a.sub_success_offer_type,b.subscription_user_type) sub_success_offer_type
from
(
select a.date,a.sub_success_offer_type,a.sku,a.new_uuid,a.user_pseudo_id
     ,a.original_order_id,a.order_id,a.standard_order_date
--      ,a.purchase_date,a.purchase_order_id,a.payment_price_usd
from `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_abtest` a
 join `dataintegration-265403.stat.stat_active_advice_detail_d`  u
on a.user_pseudo_id=u.user_pseudo_id and a.date=u.event_date_hk and a.platform=u.platform
WHERE a.date >=  '2025-06-01'
    and u.event_date_hk >=  '2025-06-01'
    and u.app_name = 'BeautyPlus'
    and event_name in ('subscription_try_suc')
    and standard_order_date is not null
    and sub_success_offer_type in ('trial','intro_trial','promotion_trial')
) a
full join
(
select standard_order_date,original_order_id,uuid,sku,order_id,payment_price_usd,subscription_user_type
--      ,original_order_id,uuid,standard_order_date,subscription_period,payment_price_usd,sku,sku_is_trial,country,is_ua
from `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp`
where standard_order_date >= '2025-06-01'
    and app_id in ('BeautyPlus')
    and subscription_user_type in ('trial','intro_trial','trial mix pay up front')
) b
on a.new_uuid=b.uuid and a.original_order_id=b.original_order_id and a.standard_order_date=b.standard_order_date
where a.order_id is null

