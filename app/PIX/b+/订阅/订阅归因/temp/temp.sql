

select
    event_date
    ,count(distinct user_pseudo_id) uv
    ,count(1) pv
from
    `dataintegration-265403.analytics.dwd_dzp_events_function`('2024-02-02', '2024-02-08', 'beautyplus', false)
where event_name in ('subscription_try_suc') and platform='IOS'
group by 1

union all

select
    event_date
    ,count(distinct user_pseudo_id) uv
    ,count(1) pv
from
    `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-02-04', '2025-02-10', 'beautyplus', false)
where event_name in ('subscription_try_suc') and platform='IOS'
group by 1

