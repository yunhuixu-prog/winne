with renewal as
(
    select
        event_date,
        app_name,
        platform,
        country,
        is_ua,
        subscription_period, -- sku类型:1-year 、1-month 、1-week、 3-month、 6-month
        case when subscription_user_type like '%renewal' then 'renewal' else 'new' end subscription_user_type,
        offer_method, -- 票据优惠类型:normal :标准价,无优惠 trial:免费试用 trial mix pay up front: 免费试用+初次体验价(仅安卓) pay as you go : 随用随付 pay up front : 提前支付
        order_id,
        is_due_1m , --该月是否到期 1 是 0 否
        is_due_to_renewal_subscription_period_1m, -- 该月订单到期且有下笔续订订单(不考虑升降级,含退款) 1 是 0 否
        uuid, --若使用uuid关联其他表，关联条件请带上app_name 和 platform
        original_order_id,
    from
        `dataintegration-265403.dwd.dwd_mzp_subscription_due_order_detail` -- 月到期订单明细,粒度为 event_date(月) * order_id
    where
        event_date = '2024-11-01' --筛选月日期
        and app_name='BeautyPlus'
        and subscription_period in ('1-month')
        and subscription_user_type in ('return_renewal','repeated_renewal')
        and is_due_1m = 1
)
,
--月连续续费6次以上用户
renewal_six as
(
  select uuid
  from
  (
      select uuid,count(distinct month)months
      from
      (
          select uuid,date_trunc(standard_order_date,month)month,
          from `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp`
            where order_status in (1,2)
            and subscription_period in ('1-month')
            and app_id = 'BeautyPlus'
            and subscription_user_type in ('return_renewal','repeated_renewal')
            and standard_order_date < '2024-11-01'
            and standard_order_date >= '2024-05-01'
            group by 1,2
      )
      group by 1
    )
    where months = 6
)

select count(distinct r.original_order_id),count(distinct case when f.uuid is not null then r.original_order_id end)
from renewal r  -- 到期月订单
left join renewal_six f on r.uuid = f.uuid  --连续续费6次
