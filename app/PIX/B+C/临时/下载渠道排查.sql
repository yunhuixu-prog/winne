

-- 不同渠道进入首页数据
select
    event_date
    ,func.getUserprop(user_properties,'download_source').string_value download_source
    ,count(distinct user_pseudo_id) uv
    ,count(1) pv
from
    `dataintegration-265403.analytics.dwd_dzp_events_function`('2024-03-01', '2024-03-11', 'beautypluscam', false)
where event_name in ('homepageappr_bd') -- first_open 这种google自带事件没有
and app_info.version>='7.7.015'
group by 1,2

select first_event_day,download_source,count(distinct user_pseudo_id) num
from
(
select a.user_pseudo_id,download_source,max(vendor_id) vendor_id,max(advertising_id) advertising_id,min(event_date) first_event_day
from
(
    select event_date,event_timestamp,user_pseudo_id,vendor_id,advertising_id
        ,func.getUserprop(user_properties,'download_source').string_value download_source
    from
        `dataintegration-265403.analytics.dwd_dzp_events_function`('2024-01-01', '2024-03-11', 'beautypluscam', false)
    where event_name in ('homepageappr_bd') -- first_open 这种google自带事件没有
    and app_info.version>='7.7.015'
    and func.getUserprop(user_properties,'download_source').string_value in ('uptodown','apkpure','web')
) a
-- left join
-- (
--     select user_pseudo_id,min(event_date_hk) as first_active_day
--     from `dataintegration-265403.stat.stat_active_advice_detail_d`
--     where event_date_hk>='2024-01-01' and app_name = 'Beauty Plus Cam' and app_version>='7.7.015'
--     group by 1
-- ) b
-- on a.user_pseudo_id=b.user_pseudo_id
group by 1,2
)
group by 1,2
order by 1,2


-- adjust渠道下载数据
select installed_date_hk,network_name,count(distinct gps_adid) uv,count(1) pv
    from
        `dataintegration-265403.adjust_data_export.ods_adjust_raw_data_install_v`
    where
        installed_date_hk >='2024-02-01'
        and app_name_dashboard in ('BeautyPlus Cam')
group by 1,2
order by 1,2


-- 不同渠道进入首页明细
select a.*,b.*
from
(
    select a.*,first_active_day
    from
    (
        select event_date,event_timestamp,user_pseudo_id,vendor_id,advertising_id
            ,func.getUserprop(user_properties,'download_source').string_value download_source
        from
            `dataintegration-265403.analytics.dwd_dzp_events_function`('2024-03-01', '2024-03-11', 'beautypluscam', false)
        where event_name in ('homepageappr_bd') -- first_open 这种google自带事件没有
        and app_info.version>='7.7.015'
        and func.getUserprop(user_properties,'download_source').string_value in ('uptodown','apkpure','web')
    ) a
    left join
    (
        select user_pseudo_id,min(event_date_hk) as first_active_day
        from `dataintegration-265403.stat.stat_active_advice_detail_d`
        where event_date_hk>='2024-02-01' and app_name = 'Beauty Plus Cam' and app_version>='7.7.015'
        group by 1
    ) b
    on a.user_pseudo_id=b.user_pseudo_id
) a
full join
(
    select installed_date_hk,network_name,idfv,idfa,gps_adid,fire_adid,android_id
    from `dataintegration-265403.adjust_data_export.ods_adjust_raw_data_install_v`
    where installed_date_hk >='2024-02-01'
        and app_name_dashboard in ('BeautyPlus Cam')
        and
)b
  on a.vendor_id=b.idfv
  or a.advertising_id=b.idfa
  or a.advertising_id=b.gps_adid
  or a.advertising_id=b.fire_adid
  or a.advertising_id=b.android_id





