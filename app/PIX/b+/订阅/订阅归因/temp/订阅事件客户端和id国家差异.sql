with sub_event as
(
    SELECT event_date,user_pseudo_id,country
        ,`beautyplus-bc0ed.func.getParams`(event_params,'SKU_ID').string_value as SKU_ID
    from `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-04-08', '2025-04-14','beautyplus',false)
    where event_name in ('subscription_try_suc')
)
,user_info as
(
    select
        event_date_hk
        ,user_pseudo_id
        ,max(country) country
        ,max(is_new) is_new
        ,max(is_UA) is_UA
    from
        `dataintegration-265403.stat.stat_active_advice_detail_d`
    where
        event_date_hk between '2025-04-08' and '2025-04-14'
        and app_name in ('BeautyPlus')
    group by 1,2
)

select s.country country_client,u.country country_ip,s.SKU_ID,count(distinct s.user_pseudo_id) uv,count(1) pv
from sub_event s
join user_info u
on s.event_date=u.event_date_hk and s.user_pseudo_id=u.user_pseudo_id
group by 1,2,3

