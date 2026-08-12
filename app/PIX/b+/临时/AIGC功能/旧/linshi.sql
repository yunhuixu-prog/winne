--1
select ss.month,ss.period,sum(first_paying_users)first_paying_users
from
(
--订阅购买
 select e.month,o.period,count(distinct e.user_pseudo_id)first_paying_users
 from
 (
 select date_trunc(date(timestamp_micros(event_timestamp), 'Asia/Singapore'),month)month,
user_pseudo_id, func.getParams(event_params,'order_id').string_value order_id
 from `airbrush-1324.analytics_152810936.events_*`
 where _table_suffix >= '20221231'
 and date(timestamp_micros(event_timestamp), 'Asia/Singapore') >= '2023-01-01'
 and date(timestamp_micros(event_timestamp), 'Asia/Singapore') <= '2024-01-31'
 and event_name in ('w_subscription_success')
 and ((func.getParams(event_params,'source_module').string_value='p_homepage' and
func.getParams(event_params,'source_0').string_value like 'ai_%') or func.getParams(event_params,'source_module').string_value='AIGC' )
 group by 1,2,3
 )e
 join
 (
 select order_id,'sub' period
 from `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp`
 where app_id ='AirBrush'
 and order_status = 1
​
 union all
--单次购买
 select order_id,'time' period
 from `dataintegration-265403.purchase.dwd_da_purchase_daily`
 where app_id ='AirBrush'
 and order_status = 1
​
 )o
 on e.order_id = o.order_id
 group by 1,2
​
)ss
group by 1,2
order by 1,2