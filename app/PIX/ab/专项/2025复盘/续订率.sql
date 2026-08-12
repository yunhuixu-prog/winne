-- 续订收入拆解
DECLARE mDATE_START DATE DEFAULT '2023-01-01';
DECLARE mDATE_END DATE DEFAULT '2025-12-31';

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
        where app_id='AirBrush'
    ) a
    left join
    (
        select distinct app_id, subscription_period, original_order_id, standard_order_date,
                    ifnull(lead(standard_order_date) over(partition by app_id, original_order_id,subscription_period order by standard_order_date), '2099-12-31') as next_interval
        from  `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp`
        where  subscription_user_type in ('first_time_subscription','first_time_return_subscription') and app_id='AirBrush'
    ) b
    on a.app_id = b.app_id and a.original_order_id=b.original_order_id and a.subscription_period = b.subscription_period
    where a.standard_order_date >= b.standard_order_date and a.standard_order_date < b.next_interval
    group by 1,2,3,4
)


select
--   date
  date_trunc(date, month) as date
  ,subscription_period
  ,case when subscription_period='1-year' and (by_period is null or by_period<=3) then by_period
        when subscription_period='1-month' and (by_period is null or by_period<=5) then by_period
    else 999
    end by_period
  ,case
        when is_renewal=1 and is_grace=0 then '1.直接续订'
        when is_renewal=1 and is_grace=1 then '2.进入宽限期后续订'
        when is_refund=1 then '3.退款'
        when is_cancell=0 or (is_cancell=1 and cancel_end_days<0) then '4.其他（主要指进入宽限期）'
        when is_cancell=1 and cancel_end_days>=0 and start_cancel_days<=7 then '5-1.后台主动取消续订-前7天'
        when is_cancell=1 and cancel_end_days>=0 and cancel_end_days<=27 and subscription_period='1-year' then '5-2.后台主动取消续订-后27天'
        when is_cancell=1 and cancel_end_days>=0 and cancel_end_days<=3 and subscription_period='1-month' then '5-2.后台主动取消续订-后3天'
        when is_cancell=1 and cancel_end_days>=0 then '5-3.后台主动取消续订-中间'
  end cancel_period
  ,case when country in ('Brazil','United States','United Kingdom') then country else 'WW'
  end country
  ,count(distinct original_order_id) expired_order_num
  ,count(distinct case when is_renewal=1 then original_order_id end) renewal_order_num
from
(
    select
        a.end_date date,a.order_id,a.original_order_id,a.uuid,a.start_date,a.platform,a.subscription_period,a.sku,a.country
        ,if(b.order_id is not null,1,0) is_cancell,standard_cancel_date
        ,DATE_DIFF(standard_cancel_date, start_date, day) start_cancel_days
        ,DATE_DIFF(end_date, standard_cancel_date, day) cancel_end_days
        ,if(refund.order_id is not null,1,0) is_refund
        ,if(a.id1 is not null,1,0) is_renewal
        ,if(c.order_id is not null,1,0) is_grace
        ,d.by_period
    from renewal_uv a
    -- 是否退订
    left join (select order_id from `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp` where app_id in('AirBrush') and order_status in (3)) refund
    on a.order_id=refund.order_id
    -- 取消续订
    left join
    (
        select standard_cancel_date,uuid,order_id
        from dataintegration-265403.user_profile.dwd_user_profile_subscription_cancel_auto_renewal
    --     where date_p='2024-08-04' and standard_cancel_date between date_sub('2024-08-04',interval 14 day) and '2024-08-04'
        where app_name='AirBrush'
    --             and date_p='2024-08-18'
    ) b
    on a.uuid=b.uuid and a.order_id=b.order_id
    -- 进入宽限期
    left join
    (
      select distinct order_id
      from `dataintegration-265403.dwd.dwd_dzp_portrait_subscription_in_grace_period`
      where event_date_hk=current_date()-2 -- and grace_enter_date>=date_sub(mDATE_END,interval 30 day)
        and app_name='AirBrush'
        and sku_type in ('1-month','1-year')
    ) c
    on a.order_id=c.order_id
    left join first_date d
    on a.order_id=d.order_id
    where a.end_date between mDATE_START and mDATE_END
)
group by 1,2,3,4,5