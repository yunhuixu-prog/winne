with dau_type as
(
    select app_name,u.event_date,u.user_pseudo_id,country
            ,max(if(p.uuid is not null,1,0)) is_now_paying_or_trial
            ,max(if(t.user_pseudo_id is not null,1,0)) today_sub
    from
    (
        select app_name,
            event_date_hk event_date
            ,platform
            ,user_pseudo_id
            ,uuid
            ,max(country) country
        from `dataintegration-265403.stat.stat_active_advice_detail_d`
        where
            event_date_hk between '2024-01-01' and '2025-11-05'
            and app_name in('AirBrush')
        group by 1,2,3,4,5
    )u
    left join
    (
        select
            app_id,uuid,standard_order_date,order_id,payment_price_usd sub_revenue
            ,case when subscription_period ='lifetime' then '2025-11-05' else standard_order_expire_date end standard_order_expire_date
        from `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp`
        where
            app_id in('AirBrush')
            and order_status in (0,1,2)
        group by 1,2,3,4,5,6
    )p on u.uuid = p.uuid and u.event_date > p.standard_order_date  and u.event_date <= p.standard_order_expire_date and u.app_name=p.app_id
    left join
    (
        select distinct event_date,user_pseudo_id
        from `dataintegration-265403.analytics.dwd_dzp_events_function`('2024-01-01','2025-11-05','airbrush',false)
        where
            event_name in  ('w_subscription_success')
    )t on u.user_pseudo_id = t.user_pseudo_id and u.event_date=t.event_date
    group by 1,2,3,4
)
,his_sub_status as
(
    select app_name,u.event_date,u.user_pseudo_id,country
            ,max(case when order_status=0 then 1 else 0 end) has_trial
            ,max(case when order_status in (1,2) then 1 else 0 end) has_paid
    from
    (
        select app_name,
            event_date_hk event_date
            ,platform
            ,user_pseudo_id
            ,uuid
            ,max(country) country
        from `dataintegration-265403.stat.stat_active_advice_detail_d`
        where
            event_date_hk between '2024-01-01' and '2025-11-05'
            and app_name in('AirBrush')
        group by 1,2,3,4,5
    )u
    left join
    (
        select
            app_id,uuid,standard_order_date,order_status
        from `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp`
        where
            app_id in('AirBrush')
    )h on u.uuid = h.uuid and u.app_name=h.app_id and h.standard_order_date<u.event_date
    group by 1,2,3,4
)



select d.app_name,d.event_date
    ,case when is_now_paying_or_trial= 1 then 'now_paying_or_trial'
                  when h.has_paid = 1 then 'his_paying'
                  when h.has_trial = 1 then 'his_trial'
    else 'no paying'
    end is_paying
--      ,case when country in ('United States','Brazil','United Kingdom') then country else 'Others' end country
     ,count(distinct d.user_pseudo_id) uv
     ,count(distinct case when today_sub=1 then d.user_pseudo_id end) pay_uv
from dau_type d
left join his_sub_status h
on d.app_name=h.app_name and d.event_date=h.event_date and d.user_pseudo_id=h.user_pseudo_id
group by 1,2,3



