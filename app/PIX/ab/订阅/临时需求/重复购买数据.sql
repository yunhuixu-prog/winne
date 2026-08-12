--uv	more_order_uv
--1457437	39342
-- 截止到2025年11月17日还在有效期内的用户中，有 39342 个用户有多笔订单同时生效
select
    count(distinct appuserid) uv
    ,count(distinct case when order_pv >1 then appuserid end) more_order_uv
from
(
select
   appuserid,count(distinct o_original_order_id) order_pv
from `dataintegration-265403.dwd.dwd_dap_subscription_trial_subscription_retention_daily`
where app_id ='AirBrush'
and standard_order_expire_date >='2025-11-17' and standard_order_date < '2025-11-17'
and event_date_hk='2025-11-17'
and order_status in  (1,2)
and order_is_cancel=0
-- and lower(aw_user_id) not like 'saas%'
-- and lower(aw_user_id) not like '%|%'
and order_id not in(
  select distinct order_id
from `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp`
where app_id ='AirBrush' and order_status = 3
  )
group by 1
)
order by 2 desc