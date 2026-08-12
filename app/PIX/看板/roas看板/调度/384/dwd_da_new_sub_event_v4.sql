-- create table `dataintegration-265403.roas_dataset_v4.dwd_da_new_sub_event_v4` as
delete from `dataintegration-265403.roas_dataset_v4.dwd_da_new_sub_event_v4` where 1=1;
insert into `dataintegration-265403.roas_dataset_v4.dwd_da_new_sub_event_v4`
with sub as
(
SELECT  distinct * except(offer_params),concat(offer_params.offer_duration,offer_params.offer_unit) as offer_period, offer_params.numberOfPeriods as offer_times
FROM `dataintegration-265403.roas_dataset_v4.dwd_da_new_sub_pre_v4`
where product in ('subscription')
),

first_sub as (

select
      a.app_id,
      a.platform,
      a.country,   a.is_UA,
     /* a.Media_Source,
      a.Campaign,
      a.Keywords,
      a.Site_ID,
      a.IOS_OS_Version,*/
      a.Attributed_Touch_Time,

      a.original_order_id,
      a.sub_event,
      a.sku,
      a.subscription_period,
      a.sku_is_trial,

      a.order_id, --as sub_order_id,
      a.subscription_user_type, -- as sub_subscription_user_type,
      a.order_status,-- as sub_order_status,
      a.offer_mark,--as sub_offer_mark,
      a.offer_method, -- as sub_offer_method,
      a.offer_period, -- as sub_offer_period,
      a.offer_times, -- as sub_offer_times,
      a.standard_order_date, --as sub_date
      a.standard_order_expire_date, --as sub_exp_date,
      a.payment_price_usd,

      '-' as next_order_id,
      '-' as next_subscription_user_type,
      '-' as next_order_status,
      '-' as next_offer_mark,
      '-' as next_offer_method,
      '-' as next_offer_period,
      '-' as next_offer_times,
      '-' as next_standard_order_date,
      '-' as next_standard_order_expire_date,
      '-' as next_payment_price_usd,
from
    (
   select
  *,
  'install_first_time_sub' as sub_event,
  from sub
  where num=1

  union all
  select
  *,
  case when  offer_method like 'trial%'  and order_status=0 then  'install_first_sub_is_trial'
   when  offer_method like '%pay%'  and order_status>=1 and order_status<=2 then  'install_first_sub_is_promotional'
   when  offer_mark in ('normal') then  'install_first_sub_is_standard'
  end as sub_event
  from sub
  where num=1

  union all
  select
  *,
  'install_first_time_sub_to_paid' as sub_event,--订阅到付费，情况1首次订阅是标准价
  from sub
  where num=1 and offer_mark in ('normal')
 union all
  select
  *,
  'install_first_time_sub_to_paid' as sub_event,--订阅到付费，情况2首次订阅是促销付费 update 2022/11/23
  from sub
  where num=1 and offer_method like '%pay%'  and order_status>=1 and order_status<=2
  union all
  select
  *,
  'install_first_time_sub_to_standard_paid' as sub_event,--订阅到标准价付费，情况1首次订阅是标准价
  from sub
  where num=1 and offer_mark in ('normal')


  union all

   select
  *,
  'sub_revenue' as sub_event,
  from sub
  WHERE order_status>=1 and  order_status<=2

  union all

   select
  *,
  'sub_revenue_365' as sub_event,
  from sub
  WHERE order_status>=1 and  order_status<=2
  and
    standard_order_date < date_add(Attributed_Touch_Time,interval 1 year)  -- 订阅日期要距离新增日期小于1年

  union all
   select
  *,
  'promotional_paid_revenue' as sub_event,
  from sub
  WHERE offer_method like '%pay%'  and order_status>=1 and order_status<=2

 union all
   select
  *,
  'standard_paid_revenue' as sub_event,
  from sub
  WHERE offer_mark in ('normal') and order_status>=1 and order_status<=2
  ---23/08新增指标
  union all
     select
  *,
  'install_first_purchase' as sub_event,
  from sub
  where num=1

  union all
  select
  *,
  'install_first_paid' as sub_event,--订阅到付费，情况1首次订阅是标准价
  from sub
  where num=1 and offer_mark in ('normal')

  union all
  select
  *,
  'install_first_paid' as sub_event,--订阅到付费，情况2首次订阅是促销付费 update 2022/11/23
  from sub
  where num=1 and offer_method like '%pay%'  and order_status>=1 and order_status<=2

)a
)

select * from first_sub
