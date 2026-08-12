
-- 举例:重复订阅事故，不主动取消续订真的会续订两次
select order_date,subscription_period,order_id,order_expire_date,order_status,payment_price_usd,sku_is_trial,offer_params.order_type
    from `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp`
    where standard_order_date >= '2020-01-01'
        and app_id in('BeautyPlus')
        -- and order_status in (1,2)
        -- and subscription_user_type in ('return_renewal','repeated_renewal') --'first_time_subscription'
        and uuid='249845635'
order by order_date
;

drop table if exists beautyplus-bc0ed.temp.winne_subscription_error;
create table beautyplus-bc0ed.temp.winne_subscription_error as

with goal_users as
(
    select '20-error' types,original_order_id,uuid
        ,count(distinct standard_order_date) order_days
        ,count(distinct order_id) order_num
        ,sum(payment_price_usd) order_revenue
        ,max(standard_order_date) standard_order_date_flag
        ,max(subscription_period) subscription_period
        ,max(platform) platform
    from `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp`
    where standard_order_date between '2020-12-04' and '2020-12-13'
        and app_id in('BeautyPlus')
        and order_status in (1,2)
--         and subscription_user_type in ('return_renewal','repeated_renewal') --'first_time_subscription'
    group by 1,2,3

    union all

    select '20-normal' types,original_order_id,uuid
        ,count(distinct standard_order_date) order_days
        ,count(distinct order_id) order_num
        ,sum(payment_price_usd) order_revenue
        ,max(standard_order_date) standard_order_date_flag
        ,max(subscription_period) subscription_period
        ,max(platform) platform
    from `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp`
    where standard_order_date between '2020-11-20' and '2020-11-29'
        and app_id in('BeautyPlus')
        and order_status in (1,2)
--         and subscription_user_type in ('return_renewal','repeated_renewal') --'first_time_subscription'
    group by 1,2,3

    union all

    select '21' types,original_order_id,uuid
        ,count(distinct standard_order_date) order_days
        ,count(distinct order_id) order_num
        ,sum(payment_price_usd) order_revenue
        ,max(standard_order_date) standard_order_date_flag
        ,max(subscription_period) subscription_period
        ,max(platform) platform
    from `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp`
    where standard_order_date between '2021-12-04' and '2021-12-13'
        and app_id in('BeautyPlus')
        and order_status in (1,2)
--         and subscription_user_type in ('return_renewal','repeated_renewal') --'first_time_subscription'
    group by 1,2,3
)
,
-- 算之后的订单数+收入（不管是不是同一笔了。毕竟是不是同一笔有那么重要吗）
af_orders as
(
    select g.types,g.original_order_id,g.uuid
        ,count(distinct case when b.order_status in (1,2) then b.order_id end) future_order_num
        ,sum(case when b.order_status not in (0) then b.payment_price_usd end) future_order_revenue
        ,count(distinct case when b.order_status in (1,2) and b.standard_order_date between date_add(standard_order_date_flag,interval 1 day)
                                and date_add(standard_order_date_flag,interval 365 day) then b.order_id end) order_num_year_1
        ,sum(case when b.order_status not in (0) and b.standard_order_date between date_add(standard_order_date_flag,interval 1 day)
                                and date_add(standard_order_date_flag,interval 365 day) then b.payment_price_usd end) order_revenue_year_1
        ,count(distinct case when b.order_status in (1,2) and b.standard_order_date between date_add(standard_order_date_flag,interval 365+1 day)
                                and date_add(standard_order_date_flag,interval 365*2 day) then b.order_id end) order_num_year_2
        ,sum(case when b.order_status not in (0) and b.standard_order_date between date_add(standard_order_date_flag,interval 365+1 day)
                                and date_add(standard_order_date_flag,interval 365*2 day) then b.payment_price_usd end) order_revenue_year_2
        ,count(distinct case when b.order_status in (1,2) and b.standard_order_date between date_add(standard_order_date_flag,interval 365*2+1 day)
                                and date_add(standard_order_date_flag,interval 365*3 day) then b.order_id end) order_num_year_3
        ,sum(case when b.order_status not in (0) and b.standard_order_date between date_add(standard_order_date_flag,interval 365*2+1 day)
                                and date_add(standard_order_date_flag,interval 365*3 day) then b.payment_price_usd end) order_revenue_year_3
        ,count(distinct case when b.order_status in (1,2) and b.standard_order_date between date_add(standard_order_date_flag,interval 365*3+1 day)
                                and date_add(standard_order_date_flag,interval 365*4 day) then b.order_id end) order_num_year_4
        ,sum(case when b.order_status not in (0) and b.standard_order_date between date_add(standard_order_date_flag,interval 365*3+1 day)
                                and date_add(standard_order_date_flag,interval 365*4 day) then b.payment_price_usd end) order_revenue_year_4

        ,count(distinct case when b.order_status in (1,2) and b.standard_order_date between date_add(standard_order_date_flag,interval 1 day)
                                and date_add(standard_order_date_flag,interval 365 day) and b.subscription_period='1-year' then b.order_id end) next_year_year_sku
    ,date_diff(current_date(),max(case when b.order_status in (1,2) then b.standard_order_date end),day) last_order_day
    from goal_users g
    left join
    (
        select *
        from `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp`
        where standard_order_date>'2020-11-01' and app_id in('BeautyPlus')
    ) b
    on g.original_order_id=b.original_order_id and g.uuid=b.uuid
        and b.standard_order_date>g.standard_order_date_flag
    group by 1,2,3
)
,
-- 之后的活跃情况
af_active as
(
    select g.types,g.original_order_id,g.uuid
        ,count(distinct b.event_date_hk) future_active_days
        ,count(distinct case when b.event_date_hk between date_add(standard_order_date_flag,interval 1 day)
                                and date_add(standard_order_date_flag,interval 365 day) then b.event_date_hk end) active_year_1
        ,count(distinct case when b.event_date_hk between date_add(standard_order_date_flag,interval 365+1 day)
                                and date_add(standard_order_date_flag,interval 365*2 day) then b.event_date_hk end) active_year_2
        ,count(distinct case when b.event_date_hk between date_add(standard_order_date_flag,interval 365*2+1 day)
                                and date_add(standard_order_date_flag,interval 365*3 day) then b.event_date_hk end) active_year_3
        ,count(distinct case when b.event_date_hk between date_add(standard_order_date_flag,interval 365*3+1 day)
                                and date_add(standard_order_date_flag,interval 365*4 day) then b.event_date_hk end) active_year_4
        ,date_diff(current_date(),max(b.event_date_hk),day) last_active_day
    from goal_users g
    left join
    (
        select *
        from `dataintegration-265403.stat.stat_active_advice_detail_d`
        where event_date_hk>'2020-11-01' and app_name in('BeautyPlus')
    ) b
    on g.uuid=b.uuid
        and b.event_date_hk>g.standard_order_date_flag
    group by 1,2,3
)

SELECT g.*,s.future_order_num,s.future_order_revenue,s.last_order_day
        ,s.order_num_year_1,s.order_num_year_2,s.order_num_year_3,s.order_num_year_4
        ,s.order_revenue_year_1,s.order_revenue_year_2,s.order_revenue_year_3,s.order_revenue_year_4,s.next_year_year_sku
        ,a.future_active_days,a.last_active_day
        ,a.active_year_1,a.active_year_2,a.active_year_3,a.active_year_4
FROM goal_users g
left join af_orders s
on g.types=s.types and g.original_order_id=s.original_order_id and g.uuid=s.uuid
left join af_active a
on g.types=a.types and g.original_order_id=a.original_order_id and g.uuid=a.uuid



select types,subscription_period
        ,count(distinct uuid) uv
        ,round(avg(coalesce(order_num,0)),4) order_num_avg
        ,round(avg(coalesce(order_revenue,0)),4) order_revenue_avg

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
from beautyplus-bc0ed.temp.winne_subscription_error
where subscription_period in ('1-month','1-year') and types in ('20-error','20-normal') and platform='IOS'
group by 1,2
order by 2,1


select types,subscription_period
        ,count(distinct uuid) uv
        ,round(count(distinct case when next_year_year_sku>0 then uuid end),4) future_year_order
        ,round(count(distinct case when next_year_year_sku>1 then uuid end),4) future_year_order_more_than_1
from beautyplus-bc0ed.temp.winne_subscription_error
where subscription_period in ('1-year') and types in ('20-error','20-normal') and platform='IOS'
group by 1,2
order by 2,1