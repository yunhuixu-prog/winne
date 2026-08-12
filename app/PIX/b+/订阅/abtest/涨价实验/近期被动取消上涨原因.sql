select date
  ,subscription_period
  ,case when sku in ('com.commsource.BeautyPlus.subscription.1year.fullprice.normal'
                    ,'com.commsource.BeautyPlus.subscription.1year.fullprice.resubscribe'
                    ,'com.commsource.BeautyPlus.subscription.1month.fullprice.normal'
                    ,'com.commsource.BeautyPlus.subscription.1month.fullprice.resubscribe'
                    ) then '实验组'
          else '对照组'
    end code
  ,case when date between '2024-08-21' and '2024-09-03' then '8.21-9.3'
                 when date between '2024-09-04' and '2024-09-17' then '9.4-9.17'
    end date_type
  ,case
        when is_renewal=1 and b.order_id is null then '1.直接续订'
        when is_renewal=1 and b.order_id is not null then '2.进入宽限期后续订'
        when is_refund=1 then '3.退款'
        when is_cancell=0 or (is_cancell=1 and cancel_end_days<0) then '4.其他（主要指进入宽限期）'
        when is_cancell=1 and cancel_end_days>=0 then '5.后台主动取消续订'
  end cancel_period
  ,count(distinct original_order_id) expired_order_num
from
(
    select *
            ,DATE_DIFF(standard_cancel_date, standard_order_date, day) start_cancel_days
            ,DATE_DIFF(standard_order_expire_date, standard_cancel_date, day) cancel_end_days
    from beautyplus-bc0ed.temp.sku_order_id_refund_renewal_data
    where date>='2024-08-01'
      and subscription_period in ('1-year','1-month')
--       and platform='IOS'
      and is_expired=1
) a
left join
(
  select distinct order_id
  from `dataintegration-265403.dwd.dwd_dzp_portrait_subscription_in_grace_period`
  where event_date_hk='2024-09-18' and grace_enter_date>='2024-08-01'
    and app_name='BeautyPlus'
    and sku_type in ('1-month','1-year')
--     and platform='IOS'
) b
on a.order_id=b.order_id
group by 1,2,3,4,5
order by 1,2,3,4,5