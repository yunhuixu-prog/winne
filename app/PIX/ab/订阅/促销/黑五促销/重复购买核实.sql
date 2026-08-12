-- select u.*,p.standard_order_date,p.standard_order_expire_date,p.order_id
select u.standard_order_date
     ,count(distinct u.uuid) uv
     ,round(sum(u.payment_price_usd),2) bookings
     ,count(distinct p.uuid) has_order_uv
     ,round(sum(case when p.uuid is not null then u.payment_price_usd end),2) has_order_bookings
from
(
    select
        app_id,uuid,standard_order_date,order_id,subscription_user_type,payment_price_usd
    from `dataintegration-265403.dwd.dwd_dap_subscription_trial_subscription_retention_daily`
    where
        app_id = 'AirBrush'
--         and order_status in (0,1)
        and subscription_user_type in ('first_time_subscription','first_time_return_subscription')
--         and event_date_hk=date_add('2025-12-08',interval 1 day)
        and event_date_hk='2025-12-04'
        and standard_order_date>='2025-01-01'
) u
left join
(
    select
        app_id,uuid,standard_order_date,order_id,payment_price_usd
        ,case when subscription_period ='lifetime' then date_add('2025-12-08',interval 1 day) else standard_order_expire_date end standard_order_expire_date
    from `dataintegration-265403.dwd.dwd_dap_subscription_trial_subscription_retention_daily`
    where
        app_id = 'AirBrush'
        and order_status in (0,1,2)
--         and event_date_hk=date_add('2025-12-08',interval 1 day)
        and event_date_hk='2025-12-04'
) p
on u.uuid=p.uuid and u.standard_order_date > p.standard_order_date  and u.standard_order_date < p.standard_order_expire_date
group by 1
order by 1
