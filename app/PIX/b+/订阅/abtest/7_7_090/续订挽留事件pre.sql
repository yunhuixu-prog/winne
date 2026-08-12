drop table if exists `beautyplus-bc0ed.temp.temp_renewal_retain_abtest_event`;
create table if not exists `beautyplus-bc0ed.temp.temp_renewal_retain_abtest_event` as

select
        app_name,
            event_name,
            event_date,
            event_params,
            receive_time,
            user_pseudo_id,
            appsflyer_id,
            gid,
            platform,
            language ,
            country,
            app_version,
            safe_cast(e.origin_number as INT64) meepo_abcode,
            safe_cast(e.abcount as INT64)  meepo_abcount,
            device_id,
from(
  select 'BeautyPlus' as app_name,
        date(timestamp_add(timestamp_micros(event_timestamp), interval 8 hour)) as event_date,
        a.event_name,
        `beautyplus-bc0ed`.func.decodeMergeParams(event_params) event_params,
        event_timestamp as receive_time,
        a.user_pseudo_id,
        func.getUserprop(user_properties,'appsflyer_id').string_value as appsflyer_id,
        func.getUserprop(user_properties,'hwgid').string_value as gid,
        func.getUserprop(user_properties,'device_id').string_value as device_id,
        platform,
        device.language as language,
        app_info.version as app_version,
        geo.country as country,
        func.getParams(event_params,'current_abcode').string_value  ab_code,
        `beautyplus-bc0ed`.func.convertWithCh(func.getParams(event_params,'meepo_abcode').string_value , func.getParams(event_params,'meepo_abcount').string_value) as meepo,
   from
        `dataintegration-265403.analytics.dwd_dzp_events_function`('2024-04-23', '2024-05-29', 'beautyplus', false) a
    where
        event_name in ('renewal_retain_pop_appr_bd','renewal_retain_pop_clk_bd')
) a,unnest(meepo.hwResult) e
where
e.origin_number  in  ('10645','10646','10647','10648')

