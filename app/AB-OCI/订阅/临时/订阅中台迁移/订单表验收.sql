select
   appuserid,o_original_order_id,order_id,uuid,standard_order_date,order_status,subscription_user_type,subscription_period,payment_price_usd
from `dataintegration-265403.dwd.dwd_dap_subscription_trial_subscription_retention_daily`
where app_id ='AirBrush'
-- and standard_order_date >= '2025-10-01'
and event_date_hk='2025-11-19'
-- and order_status in  (1,2)
and appuserid='2570687813'


select
  create_time,pay_date,pay_time,valid_time,invalid_time,
--   substr(a.valid_time,1,8) valid_date,

  product_line,os_type,order_id,buyer_gid,contract_id,

  period_type,ord_period_length,promotion_status,contract_promotion_status,

  pay_amount,money_unit,ord_amt,ord_before_amt,rate,

  order_type,cur_pay_stage,cur_pay_withhold_stage,new_order_flag,

  refund_time,refund_amt,refund_before_amt,refund_reason,pay_status
from
	stat_vip.paid_oda_vip_all_order
where
	date_p = 20251119
    and app_id_p IN (7329803307041000000, 7329803307042000000)
    -- and order_type=1
    and buyer_gid='2800460643'