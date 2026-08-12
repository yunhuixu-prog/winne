

select a.app_name,a.platform,subscription_user_type,count(distinct a.uuid) uv,round(sum(payment_price_usd),2) bookings
from
(
    select distinct uuid,app_name,platform
    from `dataintegration-265403.stat.stat_active_advice_detail_d`
    where event_date_hk = '2025-03-15'
        and
        (
            (app_name = 'AirBrush'
            and platform = 'ANDROID'
            and app_version <= '4.21.1')
            or
            (app_name = 'AirBrush'
            and platform = 'IOS'
            and app_version <= '4.27.2')
            or
            (app_name = 'BeautyPlus'
            and platform = 'ANDROID'
            and app_version <= '7.5.110')
            or
            (app_name = 'BeautyPlus'
            and platform = 'IOS'
            and app_version <= '7.6.021')
        )
) a
left join
(
    select distinct
      app_id,platform,uuid,subscription_user_type,order_status,payment_price_usd
    from `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp`
    where order_status in (0,1,2)
        and standard_order_date<='2025-03-15' and app_id in ('AirBrush','BeautyPlus')
        and case when  subscription_period = 'lifetime' then current_date else standard_order_expire_date end>='2025-03-15'
) b
on a.uuid=b.uuid and a.app_name=b.app_id and a.platform=b.platform
group by 1,2,3





