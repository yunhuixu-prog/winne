--2.更细分的核心会员功能对续费率提升/降低的影响限
--月续费在11月份到期
with renewal as (
  select
   event_date,
   platform,
   country,
   is_ua,
   subscription_period, -- sku类型:1-year 、1-month 、1-week、 3-month、 6-month
   offer_method, -- 票据优惠类型:normal :标准价,无优惠 trial:免费试用 trial mix pay up front: 免费试用+初次体验价(仅安卓) pay as you go : 随用随付 pay up front : 提前支付
   order_id,
   is_due_1m , --该月是否到期 1 是 0 否
   is_due_to_renewal_subscription_period_1m, -- 该月订单到期且有下笔续订订单(不考虑升降级,含退款) 1 是 0 否
   uuid, --若使用uuid关联其他表，关联条件请带上app_name 和 platform
   original_order_id,subscription_user_type
   from
   `dataintegration-265403.dwd.dwd_mzp_subscription_due_order_detail` -- 月到期订单明细,粒度为 event_date(月) * order_id
   where event_date = '2024-11-01' --筛选月日期
   and app_name = 'AirBrush'
   and subscription_period in ('1-month')
   and is_due_1m = 1
   and subscription_user_type in ('return_renewal','repeated_renewal')
   --and uuid = '255049928'
),
--月连续续费6次以上用户
renewal_six as (
  select uuid
  from
  (select uuid,count(distinct month)months
  from
  (select uuid,date_trunc(standard_order_date,month)month,
  from `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp`
    where order_status in (1,2)
    and subscription_period in ('1-month')
    and app_id = 'AirBrush'
    and subscription_user_type in ('return_renewal','repeated_renewal')
    and standard_order_date < '2024-11-01'
    and standard_order_date >= '2024-05-01'
    group by 1,2
  )
  group by 1
)
where months = 6
),
--订阅来源
source as (
  select *
  from
  (
      select
          event_date,user_pseudo_id
          ,concat(cat,'-',func) func
          ,cat -- 'Video' 'Edit' 'Camera'
          ,rank()over(PARTITION by user_pseudo_id order by event_date desc)ranks
      from   `airbrush-1324.temp.zm_vip_sub_func_20250417`
      where event_date <= '2024-04-30'
  )
  where ranks = 1
),
act as (
  select event_date_hk event_date,user_pseudo_id,uuid,is_new,platform,is_ua
  from `dataintegration-265403.stat.stat_active_advice_detail_d`
  where event_date_hk <= '2024-04-30'
    and app_name = 'AirBrush'
),
deal as (
  select s.*,a.uuid
  from source s
  join act a on s.event_date = a.event_date and s.user_pseudo_id = a.user_pseudo_id
),
funcs as (
  select user_pseudo_id,uuid,platform
 ,concat(cat,'-',func) func
 ,cat
from  `airbrush-1324.temp.zm_vip_func_use_20250417`
where event_date >= '2024-11-01'
and event_date <= '2024-11-30'
group by 1,2,3,4,5
),
vip_func_nums as (
  select  uuid,platform,count(distinct func)vip_func_num
  from
  (select event_date,user_pseudo_id,uuid,platform
 ,concat(cat,'-',func) func
 ,cat
from  `airbrush-1324.temp.zm_vip_func_use_20250417`
where event_date >= '2024-11-01'
and event_date <= '2024-11-30'
  )
  group by 1,2
),
all_funcs as (
  select array_to_string(ARRAY_AGG(distinct func),",")all_func
from  funcs
)
select all_func,case when vip_func_num <= 3 or vip_func_num is null then '1~3'
when vip_func_num >=4 and vip_func_num <= 7 then '4~7'
when vip_func_num >=8 and vip_func_num <= 11 then '8~11'
when vip_func_num >=12 and vip_func_num <= 15 then '12~15'
when vip_func_num >=16 and vip_func_num <= 19 then '16~19'
when vip_func_num >=20 then '20+' else null end vip_func_num,
if_use,
count(distinct original_order_id)pre
,count(distinct if(is_due_to_renewal_subscription_period_1m = 1 ,original_order_id,null))retention
from
(
    select original_order_id,is_due_to_renewal_subscription_period_1m,uuid,vip_func_num, sub_func,all_func,
      max(if(all_func = use_func,'1','0'))if_use
    from
    (
        select *
        from
        (
            select r.original_order_id,r.is_due_to_renewal_subscription_period_1m,r.uuid,h.vip_func_num,c.func use_func,s.func sub_func
            from renewal r
            join renewal_six f on r.uuid = f.uuid  --连续续费6次
            left join vip_func_nums h on r.uuid = h.uuid and r.platform = h.platform  --11月使用会员功能数
            left join funcs c on r.uuid = c.uuid and r.platform = c.platform --11月使用具体功能
            left join deal s on  c.uuid = s.uuid  --剔除因为该功能付费
            group by 1,2,3,4,5,6
        )s cross join all_funcs a
    )r,unnest(split(all_func,',')) all_func
    where  (sub_func != all_func or sub_func is null)
    group by 1,2,3,4,5,6
)
group by 1,2,3