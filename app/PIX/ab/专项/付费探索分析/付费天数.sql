-- 新用户付费天数
select
--         case when a.country in ('United States','Brazil','United Kingdom') then a.country else 'other' end country
        is_ua
        ,date_diff(first_sub_date,event_date_hk,DAY) sub_interval_day
--         ,date_diff(first_pay_date,event_date_hk,DAY) pay_interval_day
        ,count(distinct user_pseudo_id) dnu
from (
    select a.uuid,a.is_ua,a.country,a.user_pseudo_id,a.event_date_hk
            ,min(b.standard_order_date) first_sub_date
            ,min(case when revenue>0 then b.standard_order_date end) first_pay_date
    from
    (
        select
            event_date_hk
            ,country
            ,user_pseudo_id
            ,is_new
            ,is_ua
            ,uuid
        from
            `dataintegration-265403.stat.stat_active_advice_detail_d`
        where
            event_date_hk between '2024-01-01' and '2024-12-31'
            and app_name = 'AirBrush'
            and is_new=1
    ) a
    left join
    (
        select
           uuid,standard_order_date,sum(payment_price_usd) revenue,count(distinct order_id) order_num
        from `dataintegration-265403.dwd.dwd_dap_subscription_trial_subscription_retention_daily`
        where app_id ='AirBrush'
            and event_date_hk='2026-01-11'
            and standard_order_date >= '2024-01-01'
    --         and order_status in  (1,2)
        group by 1,2
    ) b
    on a.uuid=b.uuid and b.standard_order_date >= a.event_date_hk
    group by 1,2,3,4,5
) a
where date_diff(first_sub_date,event_date_hk,DAY)<=365 or first_sub_date is null
-- where date_diff(first_pay_date,event_date_hk,DAY)<=365 or first_pay_date is null
group by 1,2


;



-- 再订阅用户经历了多久订阅
select
--         case when a.country in ('United States','Brazil','United Kingdom') then a.country else 'other' end country
        date_diff(first_sub_date,event_date_hk,DAY) sub_interval_day
--         date_diff(first_pay_date,event_date_hk,DAY) pay_interval_day
        ,count(distinct uuid) uv
from (
    select a.uuid,a.event_date_hk
            ,min(b.standard_order_date) first_sub_date
            ,min(case when revenue>0 then b.standard_order_date end) first_pay_date
    from
    (
        select event_date_hk,uuid
        from `dataintegration-265403.dwd.dwd_dzp_portrait_subcription_uuid`
        where event_date_hk between '2024-01-01' and '2024-12-31' and app_id in ('AirBrush')
            and number_of_days_since_secent_order_has_expired=1 -- 过期第一天
    ) a
    left join
    (
        select
           uuid,standard_order_date,sum(payment_price_usd) revenue,count(distinct order_id) order_num
        from `dataintegration-265403.dwd.dwd_dap_subscription_trial_subscription_retention_daily`
        where app_id ='AirBrush'
            and event_date_hk='2026-01-11'
            and standard_order_date >= '2024-01-01'
    --         and order_status in  (1,2)
        group by 1,2
    ) b
    on a.uuid=b.uuid and b.standard_order_date >= a.event_date_hk
    group by 1,2
) a
where date_diff(first_sub_date,event_date_hk,DAY)<=365 or first_sub_date is null
-- where date_diff(first_pay_date,event_date_hk,DAY)<=365 or first_pay_date is null
group by 1
order by 1

