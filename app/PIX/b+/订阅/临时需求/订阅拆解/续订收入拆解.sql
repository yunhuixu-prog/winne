-- 续订收入拆解
DECLARE mDATE_START DATE DEFAULT '2024-12-01';
DECLARE mDATE_END DATE DEFAULT '2024-12-29';

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
        and app_id='BeautyPlus'
        and subscription_period in ('6-month','1-month','3-month','1-week','1-year')
        and offer_method = 'normal'
        )s1
    )s
)

select date,subscription_period,case
        when is_renewal=1 and is_grace=0 then '1.直接续订'
        when is_renewal=1 and is_grace=1 then '2.进入宽限期后续订'
        when is_refund=1 then '3.退款'
        when is_cancell=0 or (is_cancell=1 and cancel_end_days<0) then '4.其他（主要指进入宽限期）'
        when is_cancell=1 and cancel_end_days>=0 and start_cancel_days<=7 then '5-1.后台主动取消续订-前7天'
        when is_cancell=1 and cancel_end_days>=0 and cancel_end_days<=27 then '5-2.后台主动取消续订-后27天'
        when is_cancell=1 and cancel_end_days>=0 then '5-3.后台主动取消续订-中间'
  end cancel_period
  ,count(distinct original_order_id) expired_order_num
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
    from renewal_uv a
    -- 是否退订
    left join (select order_id from `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp` where app_id in('BeautyPlus') and order_status in (3)) refund
    on a.order_id=refund.order_id
    -- 取消续订
    left join
    (
        select standard_cancel_date,uuid,order_id
        from dataintegration-265403.user_profile.dwd_user_profile_subscription_cancel_auto_renewal
    --     where date_p='2024-08-04' and standard_cancel_date between date_sub('2024-08-04',interval 14 day) and '2024-08-04'
        where app_name='BeautyPlus'
    --             and date_p='2024-08-18'
    ) b
    on a.uuid=b.uuid and a.order_id=b.order_id
    -- 进入宽限期
    left join
    (
      select distinct order_id
      from `dataintegration-265403.dwd.dwd_dzp_portrait_subscription_in_grace_period`
      where event_date_hk=current_date()-1 and grace_enter_date>=date_sub(mDATE_END,interval 30 day)
        and app_name='BeautyPlus'
        and sku_type in ('1-month','1-year')
    ) c
    on a.order_id=c.order_id
    where a.end_date between mDATE_START and mDATE_END
)
group by 1,2,3


