-- 最大日期T-2
drop table if exists dataintegration-265403.temp.winne_temp_day_type;
create table dataintegration-265403.temp.winne_temp_day_type as
with his_sub_status as
(
    select app_name,u.event_date,u.user_pseudo_id,country
            ,DATE_DIFF(event_date,min(first_active_date),DAY)+1 install_days
            ,max(case when order_status=0 then 1 else 0 end) has_trial
            ,max(case when order_status in (1,2) then 1 else 0 end) has_paid
            ,max(standard_order_expire_date) last_order_expire_date
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
            event_date_hk between '2025-12-01' and '2025-12-15'
            and app_name = 'AirBrush'
        group by 1,2,3,4,5
    ) u
    left join
    (
        select
            app_id,uuid,standard_order_date,order_status
             ,case when subscription_period ='lifetime' then date_add('2025-12-15',interval 1 day) else standard_order_expire_date end standard_order_expire_date
        from `dataintegration-265403.dwd.dwd_dap_subscription_trial_subscription_retention_daily`
        where
            app_id = 'AirBrush' and event_date_hk=date_add('2025-12-15',interval 1 day)
    ) h
    on u.uuid = h.uuid and u.app_name=h.app_id and h.standard_order_date<u.event_date
    and h.standard_order_expire_date<u.event_date
    -- 历史活跃信息
    left join
    (
        select user_pseudo_id
            ,first_active_date
        from `airbrush-1324.dim.dim_dzp_portrait_firebase_id_user`
        where event_date_hk=date_add('2025-12-15',interval 1 day)
    ) a
    on u.user_pseudo_id=a.user_pseudo_id
    group by 1,2,3,4
)

select h.app_name,h.event_date,h.user_pseudo_id,h.country,h.has_trial,h.has_paid
    ,h.last_order_expire_date,DATE_DIFF(h.event_date,h.last_order_expire_date,day) expire_days,install_days
    ,count(distinct u.event_date_hk) active_days
from his_sub_status h
left join `dataintegration-265403.stat.stat_active_advice_detail_d` u
on h.user_pseudo_id=u.user_pseudo_id and u.event_date_hk > h.last_order_expire_date and u.event_date_hk < h.event_date
group by 1,2,3,4,5,6,7,8,9


;

drop table if exists dataintegration-265403.temp.winne_temp_day_type_2;
create table dataintegration-265403.temp.winne_temp_day_type_2 as
with dau_type as
(
    select app_name,u.event_date,u.user_pseudo_id,country,is_new,is_ua,platform
            ,max(if(p.uuid is not null,1,0)) is_now_paying_or_trial
--             ,max(if(t.user_pseudo_id is not null,1,0)) today_sub
            ,max(t1.is_sub) is_sub
            ,max(t1.is_sub_to_paid) is_sub_to_paid
            ,max(t1.is_trial) is_trial
            ,max(t1.is_trial_to_paid) is_trial_to_paid
            ,max(t1.is_sub_month) is_sub_month
            ,max(t1.is_sub_year) is_sub_year
            ,max(t1.is_sub_to_paid_month) is_sub_to_paid_month
            ,max(t1.is_sub_to_paid_year) is_sub_to_paid_year
            ,max(t1.revenue) revenue
    from
    (
        select app_name,
            event_date_hk event_date
            ,platform
            ,user_pseudo_id
            ,uuid
            ,is_new,is_ua
            ,max(country) country
        from `dataintegration-265403.stat.stat_active_advice_detail_d`
        where
            event_date_hk between '2025-12-01' and '2025-12-15'
            and app_name in('AirBrush')
        group by 1,2,3,4,5,6,7
    )u
    left join
    (
        select
            app_id,uuid,standard_order_date,order_id,payment_price_usd sub_revenue
            ,case when subscription_period ='lifetime' then date_add('2025-12-15',interval 1 day) else standard_order_expire_date end standard_order_expire_date
        from `dataintegration-265403.dwd.dwd_dap_subscription_trial_subscription_retention_daily`
        where
            app_id = 'AirBrush'
            and order_status in (0,1,2)
            and event_date_hk=date_add('2025-12-15',interval 1 day)
        group by 1,2,3,4,5,6
    )p
    on u.uuid = p.uuid and u.event_date > p.standard_order_date  and u.event_date < p.standard_order_expire_date and u.app_name=p.app_id
--     left join
--     (
--         select distinct event_date,user_pseudo_id
--         from `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-12-01','2025-11-02','airbrush',false)
--         where
--             event_name in  ('w_subscription_success')
--     )t on u.user_pseudo_id = t.user_pseudo_id and u.event_date=t.event_date
    left join
    (
        select event_date,user_pseudo_id
            ,max(if(event_name = 'sub_suc',1,0)) is_sub
            ,max(if(event_name = 'sub_to_paid',1,0)) is_sub_to_paid
            ,max(if(event_name = 'trial',1,0)) is_trial
            ,max(if(event_name = 'trial_to_paid',1,0)) is_trial_to_paid
            ,max(if(event_name = 'sub_to_paid',payment_price_usd,0)) revenue
            ,max(if(event_name = 'sub_suc' and duration='1month',1,0)) is_sub_month
            ,max(if(event_name = 'sub_suc' and duration='annual',1,0)) is_sub_year
            ,max(if(event_name = 'sub_to_paid' and duration='1month',1,0)) is_sub_to_paid_month
            ,max(if(event_name = 'sub_to_paid' and duration='annual',1,0)) is_sub_to_paid_year
        from `airbrush-1324.stat.dws_airbrush_trial_sub`
        where source_module = 'all'
        and event_date between '2025-12-01' and '2025-12-15'
        group by 1,2
    ) t1 on u.user_pseudo_id = t1.user_pseudo_id and u.event_date=t1.event_date
    group by 1,2,3,4,5,6,7
)

select d.app_name,d.event_date,d.platform
    ,d.country,d.user_pseudo_id,d.is_new,d.is_ua
    ,case when d.is_now_paying_or_trial= 1 then 'now_paying_or_trial'
                  when h.has_paid = 1 then 'his_paying'
                  when h.has_trial = 1 then 'his_trial'
    else 'no paying'
    end is_paying
--     ,d.today_sub
    ,d.is_sub,d.is_sub_to_paid,d.is_trial,d.is_trial_to_paid,d.revenue
    ,d.is_sub_month,d.is_sub_year,d.is_sub_to_paid_month,d.is_sub_to_paid_year
    ,h.expire_days,h.active_days expire_active_days,h.install_days
from dau_type d
left join dataintegration-265403.temp.winne_temp_day_type h
on d.app_name=h.app_name and d.event_date=h.event_date and d.user_pseudo_id=h.user_pseudo_id
;
