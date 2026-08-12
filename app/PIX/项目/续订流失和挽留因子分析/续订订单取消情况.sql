-- 当前订阅数/退订数
DECLARE mDATE_START DATE DEFAULT '2024-07-02';
DECLARE mDATE_END DATE DEFAULT '2024-09-30';

DECLARE mDATE DATE DEFAULT mDATE_START;

WHILE mDATE >= mDATE_START AND mDATE <= mDATE_END DO

delete from dataintegration-265403.temp.renewal_order_id_loss_data where date = mDATE;
insert into dataintegration-265403.temp.renewal_order_id_loss_data

-- DECLARE mDATE DATE DEFAULT '2024-07-01';
-- drop table if exists dataintegration-265403.temp.renewal_order_id_loss_data;
-- create table dataintegration-265403.temp.renewal_order_id_loss_data as

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
        and app_id in ('BeautyPlus','AirBrush')
        and subscription_period in ('6-month','1-month','3-month','1-week','1-year')
        and offer_method = 'normal'
    --         and sku in ('com.commsource.BeautyPlus.subscription.1year.fullprice.tier1low','beautyplus.subs.month12.func00.lev00.ver2'
    --                     ,'beautyplus.subs.month12.func00.lev00.ver25','beautyplus.subs.month12.func00.lev00.ver31'
    --                     ,'com.commsource.BeautyPlus.subscription.1year.fullprice.normal','com.commsource.BeautyPlus.subscription.1year.fullprice.resubscribe'
    --                     ,'beautyplus.subs.month12.func00.lev00.ver26','beautyplus.subs.month12.func00.lev00.ver32'
    --
    --                     ,'beautyplus.subs.month1.func00.lev00.ver0','beautyplus.subs.month1.func00.lev00.ver4'
    --                     ,'beautyplus.subs.month12.func00.lev00.ver25','beautyplus.subs.month1.func00.lev00.ver27'
    --                     ,'com.commsource.BeautyPlus.subscription.1month.fullprice.normal','com.commsource.BeautyPlus.subscription.1month.fullprice.resubscribe'
    --                     ,'beautyplus.subs.month1.func00.lev00.ver28','beautyplus.subs.month1.func00.lev00.ver34'
    --                     )
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
    mDATE date,a.app_id,a.order_id,a.original_order_id,a.uuid,a.standard_order_date,a.standard_order_expire_date,a.platform,a.subscription_period,a.sku,a.country
    ,max(f.by_period) by_period
    ,max(if(refund.order_id is not null,1,0)) is_refund
    ,max(if(b.order_id is not null and standard_cancel_date<=mDATE,1,0)) is_now_cancell
    ,max(if(b.order_id is not null and standard_cancel_date=mDATE,1,0)) is_today_cancell
    ,max(if(b.order_id is not null and standard_cancel_date between date_add(mDATE,interval 1 day) and date_add(mDATE,interval 1 day),1,0)) is_cancell_future_1
    ,max(if(b.order_id is not null and standard_cancel_date between date_add(mDATE,interval 1 day) and date_add(mDATE,interval 3 day),1,0)) is_cancell_future_3
    ,max(if(b.order_id is not null and standard_cancel_date between date_add(mDATE,interval 1 day) and date_add(mDATE,interval 7 day),1,0)) is_cancell_future_7
    ,max(if(b.order_id is not null,1,0)) is_final_cancell
    ,min(standard_cancel_date) standard_cancel_date
    ,min(date_diff(standard_cancel_date,standard_order_date,day)) cancel_start_day
    ,max(date_diff(standard_order_expire_date, standard_cancel_date,day)) cancel_end_day

    -- 续订信息
    ,max(if(r.end_date=mDATE,1,0)) is_now_expired
    ,max(if(r.end_date between date_add(mDATE,interval 1 day) and date_add(mDATE,interval 1 day),1,0)) is_expired_1
    ,max(if(r.end_date between date_add(mDATE,interval 1 day) and date_add(mDATE,interval 3 day),1,0)) is_expired_3
    ,max(if(r.end_date between date_add(mDATE,interval 1 day) and date_add(mDATE,interval 7 day),1,0)) is_expired_7
    ,max(if(r.id1 is not null,1,0)) is_renewal

    ,coalesce(max(is_active_now),0) is_active_now
    ,coalesce(max(if(active_7>0,1,0)),0) is_active_7
from
(
    select *
    from `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp`
    where order_status in (1,2)
        and app_id in ('BeautyPlus','AirBrush')
        and subscription_period in ('6-month','1-month','3-month','1-week','1-year')
        and offer_method = 'normal'
        and standard_order_date<=mDATE
        and (standard_order_expire_date>=mDATE or subscription_period ='lifetime')
) a
left join (select app_id,order_id from `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp` where app_id in ('BeautyPlus','AirBrush') and order_status in (3)) refund
on a.order_id=refund.order_id and a.app_id=refund.app_id
-- 取消续订
left join
(
    select standard_cancel_date,uuid,order_id
    from dataintegration-265403.user_profile.dwd_user_profile_subscription_cancel_auto_renewal
--     where date_p='2024-08-04' and standard_cancel_date between date_sub('2024-08-04',interval 14 day) and '2024-08-04'
    where app_name in ('BeautyPlus','AirBrush')
) b
on a.uuid=b.uuid and a.order_id=b.order_id
-- 续订第几期
left join first_date f
on a.order_id=f.order_id and a.app_id=f.app_id and a.subscription_period=f.subscription_period
-- 是否到期续订
left join (select * from renewal_uv where end_date=mDATE) r
on a.order_id=r.order_id and a.app_id=r.app_id and a.subscription_period=r.subscription_period
-- 取用户近X天活跃状态
left join
(
    select app_name,uuid
        ,count(distinct case when event_date_hk = mDATE then event_date_hk end) is_active_now
        ,count(distinct case when event_date_hk between date_sub(mDATE,interval 6 day) and mDATE then event_date_hk end) active_7
    from `dataintegration-265403.stat.stat_active_advice_detail_d`
    where
        event_date_hk between date_sub(mDATE,interval 6 day) and mDATE
        and app_name in ('BeautyPlus','AirBrush')
    group by 1,2
) ac
on a.uuid=ac.uuid and a.app_id=ac.app_name
group by 1,2,3,4,5,6,7,8,9,10,11
;
SET mDATE = DATE_ADD(mDATE, INTERVAL 1 DAY);

END WHILE;



