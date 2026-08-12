select
        case when a.country in ('United States','Brazil','United Kingdom') then a.country else 'other' end country
        ,a.is_ua
        ,count(a.user_pseudo_id) dnu
        ,count(case when order_num_30>0 then a.user_pseudo_id end) sub_30_dnu
        ,count(case when revenue_30 > 0 then a.user_pseudo_id end) pay_30_dnu
        ,round(sum(revenue_30),2) pay_30_revenue
        ,count(case when order_num>0 then a.user_pseudo_id end) sub_365_dnu
        ,count(case when revenue > 0 then a.user_pseudo_id end) pay_365_dnu
        ,round(sum(revenue),2) pay_365_revenue
from (
select a.uuid,a.is_ua,a.country,a.user_pseudo_id,a.event_date_hk
        ,sum(case when b.standard_order_date between a.event_date_hk and date_add(a.event_date_hk,interval 29 day) then b.order_num end) order_num_30
        ,sum(case when b.standard_order_date between a.event_date_hk and date_add(a.event_date_hk,interval 29 day) then b.revenue end) revenue_30
        ,sum(b.order_num) order_num
        ,sum(b.revenue) revenue
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
        event_date_hk between '2024-11-01' and '2024-11-30'
--         event_date_hk between '2025-10-01' and '2025-10-31'
        and app_name = 'AirBrush'
        and is_new=1
) a
left join
(
    select
       uuid,standard_order_date,sum(payment_price_usd) revenue,count(distinct order_id) order_num
    from `dataintegration-265403.dwd.dwd_dap_subscription_trial_subscription_retention_daily`
    where app_id ='AirBrush'
        and event_date_hk='2025-12-15'
        and standard_order_date between '2024-11-01' and '2025-12-01'
--         and order_status in  (1,2)
    group by 1,2
) b
on a.uuid=b.uuid and b.standard_order_date between a.event_date_hk and date_add(a.event_date_hk,interval 364 day)
group by 1,2,3,4,5
) a
where coalesce(order_num,0)<20
group by 1,2
order by 1,2
