-- 涉及历史数据因此使用 pix 口径
-- DAU 取自 dws_airbrush_subscription_overview_view；sub_to_paid 按 payment_price_usd 拆分需用底表 dws_airbrush_trial_sub
-- 付费率 = sub_to_paid_uv / DAU
with dau as (
    select 
         event_date,
         country,
         platform,
         sum(DAU) DAU
    from airbrush-1324.stat.dws_airbrush_subscription_overview_view
    where country in ('Brazil', 'United Kingdom', 'Australia')
      and event_date between '2025-01-01' and '2026-04-30'
      and platform='IOS'
    group by 1, 2, 3
),
paid as (
    select event_date
         , country
         , platform
         , duration
        --  , round(payment_price_usd, 2) as payment_price_usd
         , count(distinct user_pseudo_id) as sub_to_paid_uv
         , round(sum(payment_price_usd), 2) as sub_to_paid_revenue
         , round(sum(payment_price_usd)/count(distinct user_pseudo_id), 1) as payment_price_usd
    from `airbrush-1324.stat.dws_airbrush_trial_sub`
    where source_module = 'all'
      and country in ('Brazil', 'United Kingdom', 'Australia')
      and event_name = 'sub_to_paid'
      and payment_price_usd > 0
      and event_date between '2025-01-01' and '2026-04-30'
      and platform='IOS'
      and duration in ('1month', 'weekly', 'annual')
    group by 1, 2, 3, 4
)
select 
    --  p.event_date event_date,
     p.country country,
     p.platform platform,
     p.duration duration,
     p.payment_price_usd payment_price_usd,
    --  COUNT(distinct p.event_date) event_date_count,
     sum(d.DAU) DAU,
     sum(p.sub_to_paid_uv) sub_to_paid_uv,
     sum(p.sub_to_paid_revenue) sub_to_paid_revenue,
     round(safe_divide(sum(p.sub_to_paid_uv), sum(d.DAU)), 6) as sub_to_paid_rate,
     round(safe_divide(sum(p.sub_to_paid_uv), 
            count(distinct p.event_date)*case when p.country = 'Australia' then 9953 
                when p.country = 'Brazil' then 201950
                when p.country = 'United Kingdom' then 34257 end), 6) as sub_to_paid_rate_2
from paid p
join dau d
  on p.event_date = d.event_date
 and p.country = d.country
 and p.platform = d.platform
group by p.country, p.platform, p.duration, p.payment_price_usd
having sum(p.sub_to_paid_uv) >= 200
order by p.country, p.platform, p.duration, p.payment_price_usd
;
-- 再根据结果筛选一下不然太奇怪了