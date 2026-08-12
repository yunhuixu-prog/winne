drop table if exists dataintegration-265403.temp.winne_temp_pop_event;
create table dataintegration-265403.temp.winne_temp_pop_event as

select event_date,event_name,platform,event_timestamp,user_pseudo_id,app_info.version
    ,func.getParams(event_params,'pop_id').string_value as pop_id
    ,func.getParams(event_params,'pop_name').string_value as pop_name
    ,func.getParams(event_params,'page_name').string_value as page_name
from `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-01-01','2025-12-31','airbrush',false)
where
    event_name in ('popup_show','popup_click')
;

select is_paying,install_days_type,expire_days_type,pop_show_pv
     ,sum(uv) uv
     ,sum(sub_uv) sub_uv
     ,sum(pop_click_uv) pop_click_uv
from
(
select u.event_date,u.is_paying
       ,case when u.is_new=1 then '0:new-users'
              when u.install_days<=30 then '1:1~30 users'
        else '2:30+ users' end install_days_type
        ,case when is_paying='no paying' then '0:no paying'
              when expire_days<=30 then '1:1~30 expire'
              when expire_days<=90 then '2:31~90 expire'
        else '3:90+ expire' end expire_days_type
        ,case when coalesce(pop_show_pv,0)<=2 then coalesce(pop_show_pv,0)
        else 999 end pop_show_pv
        ,count(distinct u.user_pseudo_id) uv
        ,count(distinct case when pop_click_pv>=1 and page_name='homepage' then u.user_pseudo_id end) pop_click_uv
        ,count(distinct case when is_sub=1 then u.user_pseudo_id end) sub_uv
from `dataintegration-265403.temp.winne_temp_day_type_2` u
left join
(
    select event_date,user_pseudo_id,page_name
        ,count(case when event_name='popup_show' then 1 end) pop_show_pv
        ,count(case when event_name='popup_click' then 1 end) pop_click_pv
    from dataintegration-265403.temp.winne_temp_pop_event
    where page_name in ('homepage')
    group by 1,2,3
) f
on u.event_date=f.event_date and u.user_pseudo_id=f.user_pseudo_id
where u.event_date between '2025-01-01' and '2025-12-31'
group by 1,2,3,4,5
)
group by 1,2,3,4