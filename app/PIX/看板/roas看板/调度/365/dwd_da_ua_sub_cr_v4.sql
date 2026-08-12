--2022/07/11 更新了 试用优惠到标准价转化，优惠价到标准价转化 的数据清洗口径，不能用了 range_group，直接追踪下一笔正价
--计算指标 install_first_sub_is_trial_to_paid、install_first_time_trial- mix in trail to standard paid、install_first_sub_is_promotional_to_ paid、install_first_sub_is_promotional_to_standard paid
delete from `dataintegration-265403.roas_dataset_v4.dwd_da_ua_sub_cr_v4` where 1=1;
insert into `dataintegration-265403.roas_dataset_v4.dwd_da_ua_sub_cr_v4`

with sub as
(
SELECT  distinct * except(offer_params),concat(offer_params.offer_duration,offer_params.offer_unit) as offer_period, offer_params.numberOfPeriods as offer_times
FROM `dataintegration-265403.roas_dataset_v4.dwd_da_ua_sub_pre_v4`
where product in ('subscription')
),
first_sub as (
  select
  *,
  case when  offer_method like 'trial%'  and order_status=0 then  'install_first_sub_is_trial'
   when  offer_method like '%pay%'  and order_status>=1 and order_status<=2 then  'install_first_sub_is_promotional'
   --when  offer_mark in ('normal') then  'install_first_sub_is_standard'
  end as sub_event
  from sub
  where num=1  and  offer_mark not in ('normal')
),
sub_to_paid_r1 as (
select
* except(sub_event,num),
case when g.sub_event in ('install_first_sub_is_trial') then 'install_first_sub_is_trial_to_paid'
when g.sub_event in ('install_first_sub_is_promotional') then 'install_first_sub_is_promotional_to_paid'
else 'other' end as sub_event
from
    (
    select
      a.app_id,
      a.platform,
      a.country,
      a.Media_Source,
      a.Campaign,
      a.Keywords,
      a.Site_ID,
      a.IOS_OS_Version,
      a.Attributed_Touch_Time,

      a.original_order_id,
      a.sub_event,
      a.sku,
      a.subscription_period,
      a.sku_is_trial,

      a.order_id, --as sub_order_id,
      a.range_group ,
      a.subscription_user_type, -- as sub_subscription_user_type,
      a.order_status,-- as sub_order_status,
      a.offer_mark,--as sub_offer_mark,
      a.offer_method, -- as sub_offer_method,
      a.offer_period, -- as sub_offer_period,
      a.offer_times, -- as sub_offer_times,
      a.standard_order_date, --as sub_date
      a.standard_order_expire_date, --as sub_exp_date,
      a.payment_price_usd,

      p.order_id as next_order_id,
      p.range_group as next_range_group,
      p.subscription_user_type as next_subscription_user_type,
      p.order_status as next_order_status,
      p.offer_mark as next_offer_mark,
      p.offer_method  as next_offer_method,
      p.offer_period  as next_offer_period,
      p.offer_times  as next_offer_times,
      p.standard_order_date as next_standard_order_date,
      p.standard_order_expire_date as next_standard_order_expire_date,
      p.payment_price_usd as next_payment_price_usd,
      --'install_first_time_sub_to_paid' as sub_event,
      ROW_NUMBER() OVER(partition by a.app_id,a.platform,a.original_order_id ORDER BY p.standard_order_date) AS num,
      a.Campaign_ID,
      a.Keyword_ID,
      a.Ad_Group,
      a.Ad_Group_ID
    from first_sub  a

    join
      (
      SELECT
      n.*
      FROM
       sub n
      WHERE
        order_status>=1 and order_status<=2
      )p
    on  a.app_id=p.app_id and a.platform=p.platform  and a.original_order_id=p.original_order_id  and a.sku=p.sku
    --and a.Media_Source=p.Media_Source and a.Campaign=b.Campaign and a.Site_ID=b.Site_ID and a.Attributed_Touch_Time=p.Attributed_Touch_Time
    where  p.standard_order_date<=a.standard_order_expire_date and  p.standard_order_date>=a.standard_order_date
    and a.order_id!=p.order_id and a.sub_event in ('install_first_sub_is_trial','install_first_sub_is_promotional')
    )g
    where g.num =1

) ,
mix_in_trial_to_standard_paid_r2 as
(
select *except(num) from
(
select
      a.app_id,
      a.platform,
      a.country,
      a.Media_Source,
      a.Campaign,
      a.Keywords,
      a.Site_ID,
      a.IOS_OS_Version,
      a.Attributed_Touch_Time,

      a.original_order_id,
      --a.sub_event,
      a.sku,
      a.subscription_period,
      a.sku_is_trial,

      a.order_id,
      a.range_group ,
      a.subscription_user_type,
      a.order_status,
      a.offer_mark,
      a.offer_method,
      a.offer_period,
      a.offer_times,
      a.standard_order_date,
      a.standard_order_expire_date,
      a.payment_price_usd,

      p.order_id as next_order_id,
      p.range_group as next_range_group,
      p.subscription_user_type as next_subscription_user_type,
      p.order_status as next_order_status,
      p.offer_mark as next_offer_mark,
      p.offer_method  as next_offer_method,
      p.offer_period  as next_offer_period,
      p.offer_times  as next_offer_times,
      p.standard_order_date as next_standard_order_date,
      p.standard_order_expire_date as next_standard_order_expire_date,
      p.payment_price_usd as next_payment_price_usd,
      'install_first_time_trial_mix_in_trail_to_standard_paid' as sub_event,
      ROW_NUMBER() OVER(partition by a.app_id,a.platform,a.original_order_id ORDER BY p.standard_order_date) AS num,
      a.Campaign_ID,
      a.Keyword_ID,
      a.Ad_Group,
      a.Ad_Group_ID

from
    (
   select
  m.*,
  --'install_first_time_sub-trial mix pay up front0' as sub_event
  from sub_to_paid_r1 m
  where m.next_offer_mark like '%mix%'
  --where m.paid_offer_mark in ('trial mix pay up front1') and m.sub_offer_mark in ('trial mix pay up front0')
    )a
join
  (
  SELECT
  n.*
  FROM
   sub n
  WHERE
    order_status>=1 and order_status<=2
  )p
on  a.app_id=p.app_id and a.platform=p.platform  and a.original_order_id=p.original_order_id  and a.sku=p.sku
--and a.Media_Source=p.Media_Source and a.Campaign=b.Campaign and a.Site_ID=b.Site_ID and a.Attributed_Touch_Time=p.Attributed_Touch_Time
where  --p.standard_order_date<=a.next_standard_order_expire_date and
-- and p.range_group=a.next_range_group
p.standard_order_date>=a.next_standard_order_date  and p.offer_mark in ('normal')
and a.next_order_id!=p.order_id
)g
where g.num =1
--g.original_order_id in ('340000598245124') and
),
promotional_to_standard_paid_r2 as (
select
* except(sub_event,num),
case --when g.sub_event in ('install_first_sub_is_trial') then 'install_first_sub_is_trial_to_paid'
when g.sub_event in ('install_first_sub_is_promotional') then 'install_first_sub_is_promotional_to_standard_paid'
else 'other' end as sub_event
from
    (
    select
      a.app_id,
      a.platform,
      a.country,
      a.Media_Source,
      a.Campaign,
      a.Keywords,
      a.Site_ID,
      a.IOS_OS_Version,
      a.Attributed_Touch_Time,

      a.original_order_id,
      a.sub_event,
      a.sku,
      a.subscription_period,
      a.sku_is_trial,

      a.order_id, --as sub_order_id,
      a.range_group,
      a.subscription_user_type, -- as sub_subscription_user_type,
      a.order_status,-- as sub_order_status,
      a.offer_mark,--as sub_offer_mark,
      a.offer_method, -- as sub_offer_method,
      a.offer_period, -- as sub_offer_period,
      a.offer_times, -- as sub_offer_times,
      a.standard_order_date, --as sub_date
      a.standard_order_expire_date, --as sub_exp_date,
      a.payment_price_usd,

      p.order_id as next_order_id,
      p.range_group as next_range_group,
      p.subscription_user_type as next_subscription_user_type,
      p.order_status as next_order_status,
      p.offer_mark as next_offer_mark,
      p.offer_method  as next_offer_method,
      p.offer_period  as next_offer_period,
      p.offer_times  as next_offer_times,
      p.standard_order_date as next_standard_order_date,
      p.standard_order_expire_date as next_standard_order_expire_date,
      p.payment_price_usd as next_payment_price_usd,
      --'install_first_time_sub_to_paid' as sub_event,
      ROW_NUMBER() OVER(partition by a.app_id,a.platform,a.original_order_id ORDER BY p.standard_order_date) AS num,
      a.Campaign_ID,
      a.Keyword_ID,
      a.Ad_Group,
      a.Ad_Group_ID
    from first_sub  a

    join
      (
      SELECT
      n.*
      FROM
       sub n
      WHERE
        order_status>=1 and order_status<=2
      )p
    on  a.app_id=p.app_id and a.platform=p.platform  and a.original_order_id=p.original_order_id  and a.sku=p.sku
    --and a.Media_Source=p.Media_Source and a.Campaign=b.Campaign and a.Site_ID=b.Site_ID and a.Attributed_Touch_Time=p.Attributed_Touch_Time
    where  --p.standard_order_date<=a.standard_order_expire_date and
-- and p.range_group=a.range_group
    p.standard_order_date>=a.standard_order_date   and p.offer_mark in ('normal')
    and a.order_id!=p.order_id and a.sub_event in ('install_first_sub_is_promotional')
    )g
    where g.num =1

)

select a.* from sub_to_paid_r1 a --'install_first_sub_is_trial_to_paid' 包含优惠类型是试用、试用+提前支付、试用+随用随付；'install_first_sub_is_promotional_to_paid' 包含优惠类型是随用随付、提前支付

union all

select c.* from promotional_to_standard_paid_r2 c --'install_first_sub_is_promotional_to_standard_paid'包含优惠类型是随用随付、提前支付

union all

select b.*except(sub_event),'install_first_time_trial_to_standard_paid' as sub_event from mix_in_trial_to_standard_paid_r2 b --'install_first_time_trial_to_standard_paid'这里只有优惠类型是试用+提前支付、试用+随用随付（这里不包含优惠类型仅试用情况，以下指标有统计）

union all

select d.*except(sub_event),
case when d.sub_event in ('install_first_sub_is_trial_to_paid')  then 'install_first_time_trial_to_standard_paid' --'install_first_time_trial_to_standard_paid'这里只有优惠类型是试用
--when d.sub_event in ('install_first_sub_is_promotional_to_paid')  then 'install_first_time_promotional_to_standard_paid' --说明这里应去掉，已经包含在 promotional_to_standard_paid_r2
end as sub_event from sub_to_paid_r1 d
where d.next_offer_mark in ('normal') and  d.sub_event in ('install_first_sub_is_trial_to_paid')

----------
union all
select e.*except(sub_event),'install_first_time_sub_to_paid' as sub_event from sub_to_paid_r1 e
where sub_event in ('install_first_sub_is_trial_to_paid')
--旧版本“包含优惠类型是试用、试用+提前支付、试用+随用随付，随用随付、提前支付（首次订阅是标准价统计在另一张表）” --错误 随用随付和提前支付直接='install_first_time_sub_to_paid'不需要再追踪下一笔付费转化
--update2022/11/23 byzxy:仅包含优惠类型是试用、试用+提前支付、试用+随用随付，（首次订阅是标准价统计在另一张表，首次付费是优惠价（随用随付、提前支付）统计在另一张表）；


union all
select f.*except(sub_event),'install_first_time_sub_to_standard_paid' as sub_event from mix_in_trial_to_standard_paid_r2 f --包含优惠类型是试用+提前支付、试用+随用随付

union all
select g.*except(sub_event),'install_first_time_sub_to_standard_paid' as sub_event
from sub_to_paid_r1 g
where g.next_offer_mark in ('normal') and  sub_event in ('install_first_sub_is_trial_to_paid') --包含优惠类型仅试用

union all

select  h.*except(sub_event),'install_first_time_sub_to_standard_paid' as sub_event from promotional_to_standard_paid_r2 h --包含优惠类型是随用随付、提前支付
--'install_first_time_sub_to_standard_paid'（首次订阅是标准价统计在另一张表）；

---23/08新增指标
union all
select e.*except(sub_event),'install_first_paid' as sub_event from sub_to_paid_r1 e
where sub_event in ('install_first_sub_is_trial_to_paid')
--旧版本“包含优惠类型是试用、试用+提前支付、试用+随用随付，随用随付、提前支付（首次订阅是标准价统计在另一张表）” --错误 随用随付和提前支付直接='install_first_time_sub_to_paid'不需要再追踪下一笔付费转化
--update2022/11/23 byzxy:仅包含优惠类型是试用、试用+提前支付、试用+随用随付，（首次订阅是标准价统计在另一张表，首次付费是优惠价（随用随付、提前支付）统计在另一张表）；

