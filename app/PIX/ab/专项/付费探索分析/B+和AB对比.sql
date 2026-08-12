select
    'AirBrush' App
    ,a.platform
    ,a.is_new,a.is_ua
    ,case   when country in ('Brazil', 'United States', 'United Kingdom', 'Japan') then country
            else 'else'
            end country
    ,'整体' duration
    ,round(sum(DAU)/365) DAU
    ,round(sum(enter_uv)/365) enter_uv
    ,round(sum(click_uv)/365) click_uv
    ,round(sum(sub_success_uv)/365) sub_success_uv
    ,round(sum(sub_to_paid_uv)/365) sub_to_paid_uv
    ,round(sum(trial_uv)/365) trial_uv
    ,round(sum(trial_to_paid_uv)/365) trial_to_paid_uv
    ,round(sum(sub_to_paid_revenue/365),2) sub_to_paid_revenue
from airbrush-1324.stat.dws_airbrush_subscription_overview_view a
where
    event_date between '2025-01-01' and '2025-12-31'
group by
    1,2,3,4,5,6

union all

select
    'AirBrush' App
    ,a.platform
    ,a.is_new,a.is_ua
    ,case   when country in ('Brazil', 'United States', 'United Kingdom', 'Japan') then country
            else 'else'
            end country
    ,case when duration in ('Monthly','Yearly') then duration else 'else' end duration
    ,0 DAU
    ,0 enter_uv
    ,round(sum(click_uv)/365) click_uv
    ,round(sum(sub_success_uv)/365) sub_success_uv
    ,round(sum(sub_to_paid_uv)/365) sub_to_paid_uv
    ,round(sum(trial_uv)/365) trial_uv
    ,round(sum(trial_to_paid_uv)/365) trial_to_paid_uv
    ,round(sum(sub_to_paid_revenue/365),2) sub_to_paid_revenue
from airbrush-1324.stat.dws_airbrush_subscription_overview_view a
where
    event_date between '2025-01-01' and '2025-12-31'
group by
    1,2,3,4,5,6

union all

select
    'BeautyPlus' App
    ,a.platform
    ,case when a.is_new='New-user' then 'New' when a.is_new='Old-user' then 'Old' end is_new
    ,a.is_ua
    ,case   when country in ('Brazil', 'United States', 'United Kingdom', 'Japan') then country
            else 'else'
            end country
    ,'整体' duration
    ,round(sum(case when event_name='DAU' then uv end)/365) DAU
    ,round(sum(case when event_name='Sub enter' then uv end)/365) enter_uv
    ,round(sum(case when event_name='Sub click' then uv end)/365) click_uv
    ,round(sum(case when event_name='Sub success' then uv end)/365) sub_success_uv
    ,round(sum(case when event_name='Sub success to paid' then uv end)/365) sub_to_paid_uv
    ,round(sum(case when event_name='Trial uv' then uv end)/365) trial_uv
    ,round(sum(case when event_name='Trial to paid uv' then uv end)/365) trial_to_paid_uv
    ,round(sum(case when event_name='Sub success to paid' then payment_price_usd end)/365,2) sub_to_paid_revenue
from `beautyplus-bc0ed.sub_dataset.ads_dz_sub_datatype_event` a
-- from `beautyplus-bc0ed.sub_dataset.ads_dz_sub_dtype_eventSKU` a
where
    date between '2025-01-01' and '2025-12-31'
    and edition='V6.0'
group by
    1,2,3,4,5,6

union all

select
    'BeautyPlus' App
    ,a.platform
    ,case when a.is_new='New-user' then 'New' when a.is_new='Old-user' then 'Old' end is_new
    ,a.is_ua
    ,case   when country in ('Brazil', 'United States', 'United Kingdom', 'Japan') then country
            else 'else'
            end country
    ,case when sku_type in ('12m') then 'Yearly'
          when sku_type in ('1m') then 'Monthly'
    else 'else' end duration
    ,0 DAU
    ,0 enter_uv
    ,round(sum(case when event_name='Sub click' then uv end)/365) click_uv
    ,round(sum(case when event_name='Sub success' then uv end)/365) sub_success_uv
    ,round(sum(case when event_name='Sub success to paid' then uv end)/365) sub_to_paid_uv
    ,round(sum(case when event_name='Trial uv' then uv end)/365) trial_uv
    ,round(sum(case when event_name='Trial to paid uv' then uv end)/365) trial_to_paid_uv
    ,round(sum(case when event_name='Sub success to paid' then payment_price_usd end)/365,2) sub_to_paid_revenue
-- from `beautyplus-bc0ed.sub_dataset.ads_dz_sub_datatype_event` a
from `beautyplus-bc0ed.sub_dataset.ads_dz_sub_dtype_eventSKU` a
where
    date between '2025-01-01' and '2025-12-31'
    and edition='V6.0'
group by
    1,2,3,4,5,6
;

-- 分功能




