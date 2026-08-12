
drop table if exists beautyplus-bc0ed.temp.winne_subscription_error_vpu;
create table beautyplus-bc0ed.temp.winne_subscription_error_vpu as

with goal_users as
(
    select '20-error' types,v.uuid
        ,max(date) date_flag
    from beautyplus-bc0ed.temp.winne_vpu v
    join `dataintegration-265403.stat.stat_active_advice_detail_d` s
    on v.date=s.event_date_hk and v.uuid=s.uuid
    where v.date between '2020-12-04' and '2020-12-07'
        and v.platform='IOS'
    group by 1,2

    union all

    select '20-normal' types,v.uuid
        ,max(date) date_flag
    from beautyplus-bc0ed.temp.winne_vpu v
    join `dataintegration-265403.stat.stat_active_advice_detail_d` s
    on v.date=s.event_date_hk and v.uuid=s.uuid
    where v.date between '2020-11-20' and '2020-11-23'
        and v.platform='IOS'
    group by 1,2
)
,
-- 算之后的订单数+收入（不管是不是同一笔了。毕竟是不是同一笔有那么重要吗）
af_orders as
(
    select g.types,g.uuid
        ,count(distinct case when b.order_status in (1,2) then b.order_id end) future_order_num
        ,sum(case when b.order_status not in (0) then b.payment_price_usd end) future_order_revenue
        ,count(distinct case when b.order_status in (1,2) and b.standard_order_date between date_add(date_flag,interval 1 day)
                                and date_add(date_flag,interval 365 day) then b.order_id end) order_num_year_1
        ,sum(case when b.order_status not in (0) and b.standard_order_date between date_add(date_flag,interval 1 day)
                                and date_add(date_flag,interval 365 day) then b.payment_price_usd end) order_revenue_year_1
        ,count(distinct case when b.order_status in (1,2) and b.standard_order_date between date_add(date_flag,interval 365+1 day)
                                and date_add(date_flag,interval 365*2 day) then b.order_id end) order_num_year_2
        ,sum(case when b.order_status not in (0) and b.standard_order_date between date_add(date_flag,interval 365+1 day)
                                and date_add(date_flag,interval 365*2 day) then b.payment_price_usd end) order_revenue_year_2
        ,count(distinct case when b.order_status in (1,2) and b.standard_order_date between date_add(date_flag,interval 365*2+1 day)
                                and date_add(date_flag,interval 365*3 day) then b.order_id end) order_num_year_3
        ,sum(case when b.order_status not in (0) and b.standard_order_date between date_add(date_flag,interval 365*2+1 day)
                                and date_add(date_flag,interval 365*3 day) then b.payment_price_usd end) order_revenue_year_3
        ,count(distinct case when b.order_status in (1,2) and b.standard_order_date between date_add(date_flag,interval 365*3+1 day)
                                and date_add(date_flag,interval 365*4 day) then b.order_id end) order_num_year_4
        ,sum(case when b.order_status not in (0) and b.standard_order_date between date_add(date_flag,interval 365*3+1 day)
                                and date_add(date_flag,interval 365*4 day) then b.payment_price_usd end) order_revenue_year_4

        ,count(distinct case when b.order_status in (1,2) and b.standard_order_date between date_add(date_flag,interval 1 day)
                                and date_add(date_flag,interval 365 day) and b.subscription_period='1-year' then b.order_id end) next_year_year_sku
    ,date_diff(current_date(),max(case when b.order_status in (1,2) then b.standard_order_date end),day) last_order_day
    from goal_users g
    left join
    (
        select *
        from `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp`
        where standard_order_date>'2020-11-01' and app_id in('BeautyPlus')
    ) b
    on g.uuid=b.uuid
        and b.standard_order_date>g.date_flag
    group by 1,2
)
,
-- 之后的活跃情况
af_active as
(
    select g.types,g.uuid
        ,count(distinct b.event_date_hk) future_active_days
        ,count(distinct case when b.event_date_hk between date_add(date_flag,interval 1 day)
                                and date_add(date_flag,interval 365 day) then b.event_date_hk end) active_year_1
        ,count(distinct case when b.event_date_hk between date_add(date_flag,interval 365+1 day)
                                and date_add(date_flag,interval 365*2 day) then b.event_date_hk end) active_year_2
        ,count(distinct case when b.event_date_hk between date_add(date_flag,interval 365*2+1 day)
                                and date_add(date_flag,interval 365*3 day) then b.event_date_hk end) active_year_3
        ,count(distinct case when b.event_date_hk between date_add(date_flag,interval 365*3+1 day)
                                and date_add(date_flag,interval 365*4 day) then b.event_date_hk end) active_year_4
        ,date_diff(current_date(),max(b.event_date_hk),day) last_active_day
    from goal_users g
    left join
    (
        select *
        from `dataintegration-265403.stat.stat_active_advice_detail_d`
        where event_date_hk>'2020-11-01' and app_name in('BeautyPlus')
    ) b
    on g.uuid=b.uuid
        and b.event_date_hk>g.date_flag
    group by 1,2
)

SELECT g.*,s.future_order_num,s.future_order_revenue,s.last_order_day
        ,s.order_num_year_1,s.order_num_year_2,s.order_num_year_3,s.order_num_year_4
        ,s.order_revenue_year_1,s.order_revenue_year_2,s.order_revenue_year_3,s.order_revenue_year_4,s.next_year_year_sku
        ,a.future_active_days,a.last_active_day
        ,a.active_year_1,a.active_year_2,a.active_year_3,a.active_year_4
FROM goal_users g
left join af_orders s
on g.types=s.types and g.uuid=s.uuid
left join af_active a
on g.types=a.types and g.uuid=a.uuid



select types
        ,count(distinct uuid) uv
        ,round(count(distinct case when future_order_num>0 then uuid end)/count(distinct uuid),4) future_order_ratio
        ,round(sum(future_order_num)/count(distinct case when future_order_num>0 then uuid end),4) future_order_num_avg
        ,round(sum(future_order_revenue)/count(distinct case when future_order_num>0 then uuid end),4) future_order_revenue_avg
        ,round(avg(last_order_day),4) last_order_day
        ,round(count(distinct case when order_num_year_1>0 then uuid end)/count(distinct uuid),4) order_year_1_ratio
        ,round(count(distinct case when order_num_year_2>0 then uuid end)/count(distinct uuid),4) order_year_2_ratio
        ,round(count(distinct case when order_num_year_3>0 then uuid end)/count(distinct uuid),4) order_year_3_ratio
        ,round(count(distinct case when order_num_year_4>0 then uuid end)/count(distinct uuid),4) order_year_4_ratio
        ,round(sum(order_num_year_1)/count(distinct case when order_num_year_1>0 then uuid end),4) order_num_avg_year_1
        ,round(sum(order_num_year_2)/count(distinct case when order_num_year_2>0 then uuid end),4) order_num_avg_year_2
        ,round(sum(order_num_year_3)/count(distinct case when order_num_year_3>0 then uuid end),4) order_num_avg_year_3
        ,round(sum(order_num_year_4)/count(distinct case when order_num_year_4>0 then uuid end),4) order_num_avg_year_4
        ,round(sum(order_revenue_year_1)/count(distinct case when order_num_year_1>0 then uuid end),4) order_bookings_avg_year_1
        ,round(sum(order_revenue_year_2)/count(distinct case when order_num_year_2>0 then uuid end),4) order_bookings_avg_year_2
        ,round(sum(order_revenue_year_3)/count(distinct case when order_num_year_3>0 then uuid end),4) order_bookings_avg_year_3
        ,round(sum(order_revenue_year_4)/count(distinct case when order_num_year_4>0 then uuid end),4) order_bookings_avg_year_4

        ,round(count(distinct case when future_active_days>0 then uuid end)/count(distinct uuid),4) future_active_ratio
        ,round(sum(future_active_days)/count(distinct case when future_active_days>0 then uuid end),4) future_active_days_avg
        ,round(avg(last_active_day),4) last_active_day
        ,round(count(distinct case when active_year_1>0 then uuid end)/count(distinct uuid),4) is_active_year_1_ratio
        ,round(count(distinct case when active_year_2>0 then uuid end)/count(distinct uuid),4) is_active_year_2_ratio
        ,round(count(distinct case when active_year_3>0 then uuid end)/count(distinct uuid),4) is_active_year_3_ratio
        ,round(count(distinct case when active_year_4>0 then uuid end)/count(distinct uuid),4) is_active_year_4_ratio
        ,round(sum(active_year_1)/count(distinct case when active_year_1>0 then uuid end),4) active_day_avg_year_1
        ,round(sum(active_year_2)/count(distinct case when active_year_2>0 then uuid end),4) active_day_avg_year_2
        ,round(sum(active_year_3)/count(distinct case when active_year_3>0 then uuid end),4) active_day_avg_year_3
        ,round(sum(active_year_4)/count(distinct case when active_year_4>0 then uuid end),4) active_day_avg_year_4
from beautyplus-bc0ed.temp.winne_subscription_error_vpu
where types in ('20-error','20-normal')
group by 1
order by 1

