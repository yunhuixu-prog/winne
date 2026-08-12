
--分国家&渠道
declare cal_date default date('2024-10-20');
--分设备、SKU
with ori_order_table as (
 select
 platform,
 standard_order_date,
 --subscription_user_type,
--  subscription_period,
 is_ua,
 country,
 count(distinct original_order_id)uv,
 sum(payment_price_usd)bookings
 from `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp_history_backup`
 where update_date = date_add(cal_date,interval 1 day) and app_id in ('BeautyPlus')
 and order_status in (1,2)
 and standard_order_date >= '2024-09-01'
 and standard_order_date <= '2024-10-20'
 and concat(app_id, '-', original_order_id, '-', order_id) not in (
 select
 distinct concat(app_id, '-', original_order_id, '-', order_id)
 from
 `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp_history_backup`
 where update_date = date_add(cal_date,interval 1 day) and app_id in ('BeautyPlus')
 and subscription_user_type = 'refund'
 )
 group by 1,2,3,4--,5--,6
)

,fix_order_table as (
 select
 platform,
 standard_order_date,
 --subscription_user_type,
--  subscription_period,
 is_ua,
 country,
 count(distinct original_order_id)fix_uv,
 sum(payment_price_usd)fix_bookings
 from `dataintegration-265403.dwd.dwd_dap_subscription_trial_subscription_retention_daily`
 where event_date_hk = cal_date and app_id in ('BeautyPlus')
 and standard_order_date >= '2024-09-01'
 and standard_order_date <= '2024-10-20'
 and order_status in (1,2)
 and concat(app_id, '-', original_order_id, '-', order_id) not in (
 select
 distinct concat(app_id, '-', original_order_id, '-', order_id)
 from
 `dataintegration-265403.dwd.dwd_dap_subscription_trial_subscription_retention_daily`
 where event_date_hk = cal_date and app_id in ('BeautyPlus')
 and subscription_user_type = 'refund' )
 group by 1,2,3,4--,5--,6
),

valid_paying_users as (
 select event_date as event_date_hk,
 platform,
 is_ua,
 country,
 --subscription_user_type,
--  subscription_period,
 count(distinct original_order_id)vpu
 from(
 select
 *
 except
 (order_date, order_expire_date) --转化时区后的日期
 ,
 standard_order_date as order_date,
 case
 when subscription_period = 'lifetime' then '2099-12-31' -- AB 的lifetime 没有截止日期
 when order_status = 0 then standard_order_expire_date
 when date_sub(date_trunc(current_date, month),interval 1 month) >= '2024-05-01'
 then if(is_in_grace_period = 1,cal_date,coalesce(grace_actual_end_date,standard_order_expire_date))
 else standard_order_expire_date
 end order_expire_date
 from `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp_history_backup`
 where update_date = date_add(cal_date,interval 1 day)
 and app_id in ('BeautyPlus')
 and order_status in (1,2)
 and standard_order_date >= '2024-09-01'
 and standard_order_date <= '2024-10-20'
 and concat(app_id, '-', original_order_id, '-', order_id) not in (
 select
 distinct concat(app_id, '-', original_order_id, '-', order_id)
 from
 `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp_history_backup`
 where update_date = date_add(cal_date,interval 1 day)
 and app_id in ('BeautyPlus')
 and subscription_user_type = 'refund')

 )t,unnest(generate_date_array(order_date,order_expire_date)) as event_date
 group by 1,2,3,4
),

fix_valid_paying_users as (
 select event_date as event_date_hk,
 platform,
 is_ua,
 country,
 --subscription_user_type,
--  subscription_period,
 count(distinct original_order_id)fix_vpu
 from(
 select
 *
 except
 (order_date, order_expire_date) --转化时区后的日期
 ,
 standard_order_date as order_date,
 case
 when subscription_period = 'lifetime' then '2099-12-31' -- AB 的lifetime 没有截止日期
 when order_status = 0 then standard_order_expire_date
 when date_sub(date_trunc(current_date, month),interval 1 month) >= '2024-05-01'
 then if(is_in_grace = 1,cal_date,coalesce(grace_period_actual_end_date,standard_order_expire_date))
 else standard_order_expire_date
 end order_expire_date
 from `dataintegration-265403.dwd.dwd_dap_subscription_trial_subscription_retention_daily`
 where event_date_hk = cal_date and app_id in ('BeautyPlus')
 and standard_order_date >= '2024-09-01'
 and standard_order_date <= '2024-10-20'
 and order_status in (1,2)
 and concat(app_id, '-', original_order_id, '-', order_id) not in (
 select
 distinct concat(app_id, '-', original_order_id, '-', order_id)
 from `dataintegration-265403.dwd.dwd_dap_subscription_trial_subscription_retention_daily`
 where event_date_hk = cal_date and app_id in ('BeautyPlus')
 and subscription_user_type = 'refund')

 )t,unnest(generate_date_array(order_date,order_expire_date)) as event_date
 group by 1,2,3,4 --,5,6
),

trial as (select
 platform,
 standard_order_date,
 --subscription_user_type,
--  subscription_period,
 is_ua,
 country,
 count(distinct original_order_id)trial_uv
 from `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp_history_backup`
 where update_date = date_add(cal_date,interval 1 day) and app_id in ('BeautyPlus')
 and order_status = 0
 and standard_order_date >= '2024-09-01'
 and standard_order_date <= '2024-10-20'
 group by 1,2,3,4 --,5
),

fix_trial as (
 select
 platform,
 standard_order_date,
 --subscription_user_type,
--  if(subscription_period = '1-week','1-year',subscription_period)subscription_period,
 is_ua,
 country,
 count(distinct original_order_id)fix_trial_uv
 from `dataintegration-265403.dwd.dwd_dap_subscription_trial_subscription_retention_daily`
 where event_date_hk = cal_date and app_id in ('BeautyPlus')
 and order_status in (0)
 and standard_order_date >= '2024-09-01'
 and standard_order_date <= '2024-10-20'
 group by 1,2,3,4 --.5
)

select o.platform,o.standard_order_date,o.is_ua,o.country,o.uv,round(o.bookings) bookings
,f.fix_uv,round(f.fix_bookings) fix_bookings,v.vpu,fv.fix_vpu
-- ,t.trial_uv
-- ,ft.fix_trial_uv
from ori_order_table o
join fix_order_table f
on o.standard_order_date = f.standard_order_date
and IFNULL(CAST(o.platform AS STRING), '') = IFNULL(CAST(f.platform AS STRING), '')
--AND IFNULL(CAST(o.subscription_user_type AS STRING), '') = IFNULL(CAST(f.subscription_user_type AS STRING), '')
AND IFNULL(CAST(o.is_ua AS STRING), '') = IFNULL(CAST(f.is_ua AS STRING), '')
AND IFNULL(CAST(o.country AS STRING), '') = IFNULL(CAST(f.country AS STRING), '')
-- AND IFNULL(CAST(o.subscription_period AS STRING), '') = IFNULL(CAST(f.subscription_period AS STRING), '')
left join valid_paying_users v
on o.standard_order_date = v.event_date_hk
and IFNULL(CAST(o.platform AS STRING), '') = IFNULL(CAST(v.platform AS STRING), '')
--AND IFNULL(CAST(o.subscription_user_type AS STRING), '') = IFNULL(CAST(f.subscription_user_type AS STRING), '')
AND IFNULL(CAST(o.is_ua AS STRING), '') = IFNULL(CAST(v.is_ua AS STRING), '')
AND IFNULL(CAST(o.country AS STRING), '') = IFNULL(CAST(v.country AS STRING), '')
-- AND IFNULL(CAST(o.subscription_period AS STRING), '') = IFNULL(CAST(v.subscription_period AS STRING), '')

left join fix_valid_paying_users fv
on o.standard_order_date = fv.event_date_hk
and IFNULL(CAST(o.platform AS STRING), '') = IFNULL(CAST(fv.platform AS STRING),'')
--AND IFNULL(CAST(o.subscription_user_type AS STRING), '') = IFNULL(CAST(f.subscription_user_type AS STRING), '')
AND IFNULL(CAST(o.is_ua AS STRING), '') = IFNULL(CAST(fv.is_ua AS STRING), '')
AND IFNULL(CAST(o.country AS STRING), '') = IFNULL(CAST(fv.country AS STRING), '')
-- AND IFNULL(CAST(o.subscription_period AS STRING), '') = IFNULL(CAST(fv.subscription_period AS STRING), '')

left join trial t
on o.standard_order_date = t.standard_order_date
and IFNULL(CAST(o.platform AS STRING), '') = IFNULL(CAST(t.platform AS STRING), '')
--AND IFNULL(CAST(o.subscription_user_type AS STRING), '') = IFNULL(CAST(f.subscription_user_type AS STRING), '')
AND IFNULL(CAST(o.is_ua AS STRING), '') = IFNULL(CAST(t.is_ua AS STRING), '')
AND IFNULL(CAST(o.country AS STRING), '') = IFNULL(CAST(t.country AS STRING), '')
-- AND IFNULL(CAST(o.subscription_period AS STRING), '') = IFNULL(CAST(t.subscription_period AS STRING), '')

 left join fix_trial ft
on o.standard_order_date = ft.standard_order_date
and IFNULL(CAST(o.platform AS STRING), '') = IFNULL(CAST(ft.platform AS STRING), '')
--AND IFNULL(CAST(o.subscription_user_type AS STRING), '') = IFNULL(CAST(f.subscription_user_type AS STRING), '')
AND IFNULL(CAST(o.is_ua AS STRING), '') = IFNULL(CAST(ft.is_ua AS STRING), '')
AND IFNULL(CAST(o.country AS STRING), '') = IFNULL(CAST(ft.country AS STRING), '')
-- AND IFNULL(CAST(o.subscription_period AS STRING), '') = IFNULL(CAST(ft.subscription_period AS STRING), '')