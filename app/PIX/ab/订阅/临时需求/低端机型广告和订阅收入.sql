with ads as (
    select
        event_date
        ,user_pseudo_id
        ,sum(max_revenue) max_revenue
    from `dataintegration-265403.advertisement.dws_dzp_ad_placement_user_info`
    where app_name ='AirBrush'
        and event_date between  '2025-12-01' and '2025-12-31'
        and platform='ANDROID'
    group by 1,2
)
,
sub as (
    select event_date,user_pseudo_id
         ,max(payment_price_usd) revenue
         ,max(case when source_module='p_ads' then payment_price_usd end) revenue_ad
    from `airbrush-1324.stat.dws_airbrush_trial_sub`
    where source_module != 'all'
        and event_date between '2025-12-01' and '2025-12-31'
        and event_name = 'sub_to_paid'
        and platform='ANDROID'
    group by 1,2
)
,
active as (
    select event_date,user_pseudo_id
        ,max(round(cast(func.getParams(event_params,'ram_size').string_value as bigint)/1024,2)) as ram_size
--         ,round(cast(func.getParams(event_params,'remaining_diskspace').string_value as bigint)/1024,2) as remaining_diskspace
    from `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-12-01','2025-12-31','airbrush',false)
    where
        event_name in ('first_start') and platform='ANDROID'
    group by 1,2
)

select ac.event_date
       ,case when ac.ram_size<=3 then 1 else 0 end ram_size
       ,count(distinct ac.user_pseudo_id) uv
       ,count(distinct ad.user_pseudo_id) ad_uv
       ,count(distinct s.user_pseudo_id) sub_uv
       ,sum(ad.max_revenue) max_revenue
       ,sum(s.revenue) sub_revenue
       ,sum(s.revenue_ad) sub_ad_revenue
from active ac
left join ads ad
on ac.event_date=ad.event_date and ac.user_pseudo_id=ad.user_pseudo_id
left join sub s
on ac.event_date=s.event_date and ac.user_pseudo_id=s.user_pseudo_id
group by 1,2


