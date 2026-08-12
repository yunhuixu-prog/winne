with first_date as
(
    select
        a.app_id, a.subscription_period, a.original_order_id, a.order_id, a.subscription_user_type
        , date(a.standard_order_date) as standard_order_date
        , date(b.standard_order_date) as first_day
        ,case when a.subscription_period = '1-year' then DATE_DIFF(date(a.standard_order_date), date(b.standard_order_date), year)
              when a.subscription_period = '1-month' then DATE_DIFF(date(a.standard_order_date), date(b.standard_order_date), month)
              when a.subscription_period = '1-week' then DATE_DIFF(date(a.standard_order_date), date(b.standard_order_date), week)
              when a.subscription_period = '3-month' then DATE_DIFF(date(a.standard_order_date), date(b.standard_order_date), quarter)
              when a.subscription_period = '6-month' then cast(safe_divide(DATE_DIFF(date(a.standard_order_date), date(b.standard_order_date), month), 6) as int64)
              end as by_period

    from
    (
        select app_id, subscription_period, original_order_id, order_id,  standard_order_date, subscription_user_type
        from `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp`
    ) a
    left join
    (
        select distinct app_id, subscription_period, original_order_id, standard_order_date,
                    ifnull(lead(standard_order_date) over(partition by app_id, original_order_id,subscription_period order by standard_order_date), '2099-12-31') as next_interval
        from  `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp`
        where  subscription_user_type in ('first_time_subscription','first_time_return_subscription')
    ) b
    on a.app_id = b.app_id and a.original_order_id=b.original_order_id and a.subscription_period = b.subscription_period
    where a.standard_order_date >= b.standard_order_date and a.standard_order_date < b.next_interval
)

select *
from first_date
where original_order_id='180000780424279'



