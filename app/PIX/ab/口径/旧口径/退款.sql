select standard_order_date,standard_refund_date
-- select standard_order_date,count(1)
from `dataintegration-265403.dwd.dwd_dap_subscription_trial_subscription_retention_daily`
where event_date_hk='2025-11-04'  and order_status= 3 and app_id='AirBrush'
and standard_order_date='2025-10-01'
-- and standard_order_date between '2025-10-01' and '2025-11-04'
-- and standard_refund_date between '2025-10-01' and '2025-11-04'
-- group by 1
order by 1 desc