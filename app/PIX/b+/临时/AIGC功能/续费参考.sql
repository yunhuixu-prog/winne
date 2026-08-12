with renewal_uv as
(
    select
    substr(cast(s.end_date as string),1,7) month,
    s.app_id,
    s.platform,s.country,s.subscription_period,s.is_ua,
    s.original_order_id,
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
        s1.platform,
        s2.fix_firebase_en_name country,
        s1.is_ua,
        s1.app_id,
        s1.subscription_period
        from
        (
            select *
            from `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp`
            where order_status in (1,2)
            and subscription_period in ('6-month','1-month','3-month','1-week','1-year')
            and offer_method = 'normal'
            and app_id='BeautyPlus'
        )s1
        left join
        (
            select distinct key, fix_firebase_en_name
            from `dataintegration-265403.dmi.dmi_ya_country_code`, unnest(names) key
        )s2
        on s1.country = s2.key
    )s
)

select cast(concat(month,'-01') as date)month,app_id,platform,country,
subscription_period,is_ua,original_order_id,id1 id
from renewal_uv
where month = substr(cast(date_sub('{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}',interval start month) as string),1,7)