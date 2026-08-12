-- date:评估预测匹配的日期，取过去一年续订率预估
DECLARE mDATE_START DATE DEFAULT '2021-01-01';
DECLARE mDATE_END DATE DEFAULT '2024-09-20';

delete from dataintegration-265403.temp.ltv_renewal_predict where date between mDATE_START and mDATE_END;
insert into dataintegration-265403.temp.ltv_renewal_predict

-- drop table if exists dataintegration-265403.temp.ltv_renewal_predict;
-- create table dataintegration-265403.temp.ltv_renewal_predict as

with renewal_uv as
(
    select
        s.end_date,s.start_date,
        s.app_id,s.country,
        s.platform,s.subscription_period,s.is_ua,s.subscription_user_type,
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
            s1.subscription_user_type,
            s1.app_id,
            s1.subscription_period,
            s1.sku,
            s1.country
        from
        (select *
        from `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp`
        where order_status in (1,2)
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
        ,max(case when a.subscription_period = '1-year' then DATE_DIFF(date(a.standard_order_date), date(b.standard_order_date), year)  -- 两个订单的间隔日期必然差年了，因此可以用year
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
,
for_predict_order as
(
    select
        a.end_date,a.app_id,a.order_id,a.original_order_id,a.uuid,a.platform,a.subscription_period,a.sku,a.country,a.subscription_user_type,a.is_ua
        ,f.by_period
        ,if(id1 is not null,1,0) is_renewal
    from
    (
        select * from renewal_uv
        where end_date between date_sub(mDATE_START,interval 365 day) and mDATE_END
    ) a
    -- 当前续订第几期
    left join first_date f
    on a.order_id=f.order_id and a.app_id=f.app_id and a.subscription_period=f.subscription_period
)

select a.date,b.app_id
     ,b.platform,b.subscription_period,b.country,b.subscription_user_type,b.is_ua
     ,b.by_period
     ,count(1) sample
     ,count(case when is_renewal=1 then 1 end) renewal_num
from
(
    select distinct event_date_hk date
    from `dataintegration-265403.stat.stat_active_advice_detail_d`
    where event_date_hk between mDATE_START and mDATE_END
) a
cross join for_predict_order b
where b.end_date between date_sub(a.date,interval 365 day) and date_sub(a.date,interval 1 day)
group by 1,2,3,4,5,6,7,8

