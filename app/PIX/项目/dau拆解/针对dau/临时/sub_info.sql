DECLARE mDATE_START DATE DEFAULT '2023-01-01';
DECLARE mDATE_END DATE DEFAULT '2023-01-31';
DECLARE cul_date DATE DEFAULT mDATE_START;

WHILE cul_date >= mDATE_START AND cul_date <= mDATE_END DO

delete from `dataintegration-265403.temp.dwd_dzp_portrait_subcription_uuid_temp` where event_date_hk = cul_date;
insert into `dataintegration-265403.temp.dwd_dzp_portrait_subcription_uuid_temp`

-- drop table if exists `dataintegration-265403.temp.dwd_dzp_portrait_subcription_uuid_temp`;
-- create table `dataintegration-265403.temp.dwd_dzp_portrait_subcription_uuid_temp` as

with
exclude_unnormal_uuid as (
select a.* from
`dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp` a
left join (select uuid from `dataintegration-265403.subscription.uuid_order_monitor` where order_cnt > 10 group by 1) b
on a.uuid = b.uuid
where a.standard_order_date <= cul_date and b.uuid is null and a.subscription_period != 'lifetime'
),
origin_order_data as (
select
  a.uuid,
  a.app_id,
  a.order_id,
  a.order_status,
  a.standard_order_date,
  a.standard_order_expire_date,
  a.subscription_period as sku_type,
  a.subscription_user_type,
  a.offer_method,
  b.standard_refund_date,
  --订单退款时间可能在订单有效期之后，如果进入了宽限期仍被算作是有效期内
  case when d.grace_enter_date is not null then cul_date else if(ifnull(b.standard_refund_date,'2099-12-31') > a.standard_order_expire_date,a.standard_order_expire_date,b.standard_refund_date) end valid_order_expire_date,
  c.standard_cancel_date,
  d.grace_enter_date,
  d.grace_expected_end_date,
from exclude_unnormal_uuid a
left join (select * from `dataintegration-265403.user_profile.dwd_user_profile_subscription_refund` where standard_refund_date <= cul_date ) b
on a.order_id = b.order_id
left join (select * from `dataintegration-265403.user_profile.dwd_user_profile_subscription_cancel_auto_renewal` where standard_cancel_date <= cul_date) c
on a.order_id = c.order_id
left join (select order_id,grace_enter_date,grace_expected_end_date from  `dataintegration-265403.dwd.dwd_dzp_portrait_subscription_in_grace_period` where event_date_hk = cul_date  and is_in_grace_period = 1) d
on a.order_id = d.order_id
),
uuid_history_all_order as (
  select
    uuid,
    app_id,
    count(distinct if(sku_type = '1-year',order_id,null)) as past_sub_1year_sku_type_times,
    count(distinct if(sku_type = '1-month',order_id,null)) as past_sub_1month_sku_type_times,
    count(distinct if(sku_type = '3-month',order_id,null)) as past_sub_3month_sku_type_times,
    count(distinct if(sku_type = '6-month',order_id,null)) as past_sub_6month_sku_type_times,
    count(distinct if(sku_type = '2-week',order_id,null)) as past_sub_2week_sku_type_times,
    count(distinct if(sku_type = '1-week',order_id,null)) as past_sub_1week_sku_type_times,
    count(distinct if(offer_method != 'normal' and order_status != 0,order_id,null) ) as promotional_paying_times,
    --应当只算已经生效了的天数，没有生效的天数不计入；退款
    sum(if(order_status in (1,2) and offer_method != 'normal' and standard_refund_date is null, date_diff(if(valid_order_expire_date > cul_date,cul_date, valid_order_expire_date),standard_order_date,day),0)) as valid_promotional_paying_day,
    sum(if(order_status in (1,2) and offer_method = 'normal' and standard_refund_date is null, date_diff(if(valid_order_expire_date > cul_date,cul_date, valid_order_expire_date),standard_order_date,day),0)) as valid_standard_paying_day,
    count(distinct if(order_status = 0,order_id,null)) as trial_times,
    count(distinct if(standard_cancel_date is not null,order_id,null)) as cancel_subscription_times,
    count(distinct if(standard_refund_date is not null,order_id,null)) as refund_subscription_times
  from origin_order_data
  group by 1,2
),
uuid_order as (
  --对每一个uuid选取过期时间最大的订单当作有效订单
  select
  *,
  row_number() over(partition by app_id,uuid order by valid_order_expire_date desc) rw
from origin_order_data a
qualify  rw = 1
  ),
out_of_valid as (
  select
    uuid,
    app_id,
    valid_order_expire_date
  from uuid_order
  where valid_order_expire_date < cul_date
),
valid_order as (
  select
    *
    from uuid_order
    where valid_order_expire_date >= cul_date
)
select
  cul_date as event_date_hk
  ,a.uuid
  ,a.app_id
  ,null as current_trial_day
  ,null as days_to_next_automatic_deduction
  ,null as is_current_subscription_cancelled
  ,null as current_subscription_allowance_day
  ,null as current_sub_sku_type
  ,null as current_promotional_paying_period_day
  ,null as current_standard_paying_period_day
  ,null as current_subscription_expired_day
  ,b.past_sub_1year_sku_type_times
  ,b.past_sub_1month_sku_type_times
  ,b.past_sub_6month_sku_type_times
  ,b.past_sub_2week_sku_type_times
  ,b.past_sub_1week_sku_type_times
  ,b.promotional_paying_times
  ,b.valid_promotional_paying_day
  ,b.valid_standard_paying_day
  ,b.trial_times
  ,b.cancel_subscription_times
  ,date_diff(cul_date,valid_order_expire_date, day) as number_of_days_since_secent_order_has_expired
  ,b.past_sub_3month_sku_type_times
  ,b.refund_subscription_times
  ,null as current_standard_paying_type
from out_of_valid a
left join uuid_history_all_order b
on a.uuid = b.uuid and a.app_id = b.app_id
union all
select
    cul_date as event_date_hk
  ,a.uuid
  ,a.app_id
  ,if(order_status = 0 and grace_enter_date is null, date_diff(cul_date,standard_order_date, day),null ) as current_trial_day
  ,if(standard_cancel_date is null and grace_enter_date is null, date_diff(standard_order_expire_date,cul_date, day),null ) as days_to_next_automatic_deduction
  ,if(standard_cancel_date is not null,1,0) as is_current_subscription_cancelled
  ,if(grace_enter_date is not null ,date_diff(cul_date,grace_enter_date, day),null) as current_subscription_allowance_day
  ,a.sku_type as current_sub_sku_type
  ,if(offer_method != 'normal' and order_status != 0 and grace_enter_date is null,date_diff(cul_date,standard_order_date, day),null) as current_promotional_paying_period_day
  ,if(offer_method = 'normal' and order_status != 0 and grace_enter_date is null,date_diff(cul_date,standard_order_date, day),null) as  current_standard_paying_period_day
  ,date_diff(valid_order_expire_date,cul_date, day) as current_subscription_expired_day
  ,b.past_sub_1year_sku_type_times
  ,b.past_sub_1month_sku_type_times
  ,b.past_sub_6month_sku_type_times
  ,b.past_sub_2week_sku_type_times
  ,b.past_sub_1week_sku_type_times
  ,b.promotional_paying_times
  ,b.valid_promotional_paying_day
  ,b.valid_standard_paying_day
  ,b.trial_times
  ,b.cancel_subscription_times
  ,null as number_of_days_since_secent_order_has_expired
  ,b.past_sub_3month_sku_type_times
  ,b.refund_subscription_times
  ,a.subscription_user_type as current_standard_paying_type
from valid_order a
left join uuid_history_all_order b
on a.uuid = b.uuid and a.app_id = b.app_id;

SET cul_date = DATE_ADD(cul_date, INTERVAL 1 DAY);

END WHILE;