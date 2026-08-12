-- 8月活跃中，一个订单对应多个gid的有47,153个订单，占比2.31%
select
 count(distinct   original_order_id) pv,count(distinct case when gid_pv >1 then original_order_id end) pv_bigger_than_1
from
(
select
   original_order_id,count(distinct gid) gid_pv -- 一个订单对应几个gid
from
(
select
    distinct func.getUserprop(user_properties,'original_order_id').string_value  original_order_id
    ,func.getUserprop(user_properties,'hwgid').string_value gid
from `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-08-01','2025-08-31','airbrush', false)
)a
group by 1
)

;

-- 8月 还在订阅有效期的人数 1,039,779 订单量  1,235,378

select
count(distinct original_order_id) uv,count(distinct order_id) order_pv
from  `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp`
where
  app_id ='AirBrush'
  and order_status in (1,2)
  and (standard_order_date <= '2025-08-31'
  and standard_order_expire_date  >=  '2025-08-01' )
  and order_id  not in (
    select distinct order_id
from  `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp`
where
  app_id ='AirBrush'
  and order_status =3
  )

