with renewal_uv as
(
    select
        s.update_date,
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
            s1.update_date,
            s1.standard_order_date start_date,
            s1.standard_order_expire_date end_date,
            lead(s1.standard_order_date) over(partition by s1.update_date,s1.original_order_id order by s1.standard_order_date) as next_start_date,
            lead(s1.standard_order_date) over(partition by s1.update_date,s1.uuid order by s1.standard_order_date) as next_start_date2,
            lead(s1.subscription_period) over(partition by s1.update_date,s1.original_order_id order by s1.standard_order_date) as next_subscription_period,
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
        from `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp_history_backup`
        where update_date between '2024-07-01' and '2024-09-18'
        and order_status in (1,2)
        and app_id='BeautyPlus'
        and subscription_period in ('6-month','1-month','3-month','1-week','1-year')
        and offer_method = 'normal'
        )s1
    )s
)

select update_date,end_date
        ,DATE_DIFF(update_date, end_date, day) update_days,subscription_period
        ,count(distinct original_order_id) expired_order_num
        ,count(distinct id1) renewal_order_num
from renewal_uv
where end_date between '2024-07-01' and '2024-07-31' and update_date>end_date
group by 1,2,3,4
order by 1,2,3,4

