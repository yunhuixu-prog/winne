-- 续订收入拆解
with renewal_uv as
(
    select
        s.end_date,s.start_date,
        s.app_id,s.country,
        s.platform,s.subscription_period,s.is_ua,
        s.original_order_id,s.order_id,s.uuid,s.sku,
        if(next_start_date > start_date
        and next_start_date <= date_add(end_date,interval 1 day) and subscription_period = next_subscription_period,s.original_order_id,null)id1,
        if(next_start_date2 > start_date
        and next_start_date2 <= date_add(end_date,interval 1 day),s.original_order_id,null)id2
    from
    (
        select
            s1.standard_order_date start_date,
            s1.standard_order_expire_date end_date,
            lead(s1.standard_order_date) over(partition by s1.original_order_id order by s1.standard_order_date) as next_start_date,
            lead(s1.standard_order_date) over(partition by s1.uuid order by s1.standard_order_date) as next_start_date2,
            lead(s1.subscription_period) over(partition by s1.original_order_id order by s1.standard_order_date) as next_subscription_period,
            s1.original_order_id,
            s1.order_id,
            s1.uuid,
            s1.platform,
            s1.is_ua,
            s1.app_id,
            s1.subscription_period,
            s1.sku,
            s1.country
        from
        (select *
        from `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp`
        where order_status in (1,2)
        and app_id='AirBrush'
        and subscription_period in ('6-month','1-month','3-month','1-week','1-year')
        and offer_method = 'normal'
        )s1
    )s
)
,
first_date as
(
    select
        a.app_id, a.subscription_period, a.original_order_id, a.order_id
--         , date(a.standard_order_date) as standard_order_date
--         , date(b.standard_order_date) as first_day
        ,max(case when a.subscription_period = '1-year' then DATE_DIFF(date(a.standard_order_date), date(b.standard_order_date), year)
              when a.subscription_period = '1-month' then DATE_DIFF(date(a.standard_order_date), date(b.standard_order_date), month)
              when a.subscription_period = '1-week' then DATE_DIFF(date(a.standard_order_date), date(b.standard_order_date), week)
              when a.subscription_period = '3-month' then DATE_DIFF(date(a.standard_order_date), date(b.standard_order_date), quarter)
              when a.subscription_period = '6-month' then cast(safe_divide(DATE_DIFF(date(a.standard_order_date), date(b.standard_order_date), month), 6) as int64)
              end) as by_period

    from
    (
        select app_id, subscription_period, original_order_id, order_id,  standard_order_date
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
    group by 1,2,3,4
)

select
      date_trunc(date, month) month
      ,case when by_period>12 then 999 else by_period end by_period
      ,is_ua
      ,case when country in ('United States','Brazil','United Kingdom') then country else 'other' end country
      ,count(distinct original_order_id) order_num
      ,count(distinct case when is_renewal = 1 then original_order_id end) renewal_order_num
from
(
    select
        a.end_date date,a.order_id,a.original_order_id,a.uuid,a.start_date,a.platform,a.subscription_period,a.sku,a.country
        ,d.by_period,a.is_ua
        ,if(a.id1 is not null,1,0) is_renewal
    from renewal_uv a
    left join first_date d
    on a.order_id=d.order_id
    where a.subscription_period='1-month'
    and end_date between '2025-01-01' and '2026-02-28'
)
group by 1,2,3,4
order by 1,2,3,4
