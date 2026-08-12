select subscription_period,platform,count(distinct order_id)        order_num
      from dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp
      where app_id='BeautyPlus'
--         and subscription_period='1-year'
        and order_status in (1,2)
        and standard_order_expire_date between '2024-01-01' and '2024-01-31'
group by 1,2



select platform,current_sub_sku_type,count(distinct a.uuid)
from
(
    select event_date_hk,uuid,current_sub_sku_type,current_subscription_expired_day
    from `dataintegration-265403.dwd.dwd_dzp_portrait_subcription_uuid`
    where event_date_hk between '2024-03-12' and '2024-03-12'
        and app_id='BeautyPlus'
        and is_current_subscription_cancelled=1
        and ((current_sub_sku_type = '1-year' and current_subscription_expired_day<62)
            or (current_sub_sku_type = '1-month' and current_subscription_expired_day<14))
) a
-- 当天活跃
join
(
    select
        event_date_hk
        ,uuid
        ,platform
    from
        `dataintegration-265403.stat.stat_active_advice_detail_d` e
    where
        event_date_hk between '2024-03-12' and '2024-03-12'
        and app_name='BeautyPlus'
) b
on a.uuid=b.uuid and a.event_date_hk=b.event_date_hk
group by 1,2
order by 2,1



