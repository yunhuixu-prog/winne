with paid as
(
    select order_id,max(payment_price_usd) next_revenue
    from `dataintegration-265403.dwd.dwd_dap_subscription_trial_subscription_retention_daily`
    where event_date_hk='2025-11-10'
        and app_id='AirBrush'
        and standard_order_date between date_add('2025-10-25',interval 6 day) and date_add('2025-11-02',interval 8 day)
    group by 1
)

select standard_order_date,version
     ,case when hours between 3 and 8 then '3~8' else 'others' end hours
     ,sum(trial_order) trial_order
     ,sum(pay_order) pay_order
     ,round(sum(bookings),2) bookings
from
(
    select standard_order_date
        ,extract(HOUR from timestamp_add(TIMESTAMP_MILLIS(order_timestamp), interval 8 hour)) hours
        ,case when `dataintegration-265403.func`.compare_is_greater_or_equal_version(u.version,'7.19.0') then '7.19.0'
            else '<7.19.0' end version
        ,count(distinct a.order_id) trial_order
        ,count(distinct case when next_sku=sku and date_diff(date(next_order_date),standard_order_date,DAY) <= 8 then a.order_id end) pay_order
        ,sum(case when next_sku=sku and date_diff(date(next_order_date),standard_order_date,DAY) <= 8 then next_revenue end) bookings
    from `dataintegration-265403.dwd.dwd_dap_subscription_trial_subscription_retention_daily` a
    left join paid p
    on a.next_order_id=p.order_id
    left join
        (select uuid,max(app_version) version
        from `dataintegration-265403.stat.stat_active_advice_detail_d`
        where app_name='AirBrush' and event_date_hk in ('2025-10-25','2025-10-31','2025-11-01','2025-11-02')
        group by 1
        ) u
    on a.uuid=u.uuid
    where event_date_hk='2025-11-10'
        and app_id='AirBrush'
        and standard_order_date in ('2025-10-25','2025-10-31','2025-11-01','2025-11-02')
        and subscription_user_type in ('trial','intro_trial')
    --     and next_sku=sku
    --     and date_diff(date(next_order_date),standard_order_date,DAY) <= 8
    group by 1,2,3
)
group by 1,2,3
order by 1,2,3

;
select standard_order_date
--      ,version
     ,case when hours between 3 and 8 then '3~8' else 'others' end hours
     ,sum(pay_order) pay_order
     ,sum(refund_order) refund_order
     ,round(sum(refund_bookings),2) refund_bookings
from
(
    select a.standard_order_date
        ,extract(HOUR from timestamp_add(TIMESTAMP_MILLIS(order_timestamp), interval 8 hour)) hours
--         ,case when `dataintegration-265403.func`.compare_is_greater_or_equal_version(u.version,'7.19.0') then '7.19.0'
--             else '<7.19.0' end version
        ,count(distinct a.order_id) pay_order
        ,count(distinct case when p.order_id is not null then a.order_id end) refund_order
        ,sum(p.payment_price_usd) refund_bookings
    from
    (
        select distinct standard_order_date,order_timestamp,order_id,uuid
        from `dataintegration-265403.dwd.dwd_dap_subscription_trial_subscription_retention_daily`
        where event_date_hk='2025-11-10'
            and app_id='AirBrush'
            and standard_order_date in ('2025-10-25','2025-10-31','2025-11-01','2025-11-02')
            and subscription_user_type in ('first_time_subscription','first_time_return_subscription')
            and order_status!= 3
    ) a
    left join
    (
        select standard_order_date,order_id,max(payment_price_usd) payment_price_usd
        from `dataintegration-265403.dwd.dwd_dap_subscription_trial_subscription_retention_daily`
        where event_date_hk='2025-11-10'
                and app_id='AirBrush'
                and standard_order_date in ('2025-10-25','2025-10-31','2025-11-01','2025-11-02')
                and order_status= 3
        group by 1,2
    ) p
    on a.order_id=p.order_id and a.standard_order_date=p.standard_order_date
--     left join
--         (select uuid,max(app_version) version
--         from `dataintegration-265403.stat.stat_active_advice_detail_d`
--         where app_name='AirBrush' and event_date_hk in ('2025-10-25','2025-10-31','2025-11-01','2025-11-02')
--         group by 1
--         ) u
--     on a.uuid=u.uuid
    group by 1,2
)
group by 1,2
order by 1,2



