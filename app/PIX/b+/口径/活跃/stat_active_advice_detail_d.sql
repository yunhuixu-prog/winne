DECLARE run_before_days int64 DEFAULT 0;
--create or replace table  `dataintegration-265403.stat.stat_active_advice_detail_d`
--partition by event_date_hk as

WHILE run_before_days <= 5 DO 

DELETE FROM `dataintegration-265403.stat.stat_active_advice_detail_d` 
where event_date_hk =date_sub('{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}', interval run_before_days  day);

insert into
  `dataintegration-265403.stat.stat_active_advice_detail_d`
with 
-- other_4app_stat_active_advice_view as
-- (


-- SELECT * FROM (
-- with dsources as(
-- select 'pomelo' appName,event_date, event_timestamp, event_name, event_params, event_previous_timestamp, event_value_in_usd, event_bundle_sequence_id, event_server_timestamp_offset, user_id, user_pseudo_id, user_properties, user_first_touch_timestamp, user_ltv, device, geo, app_info, traffic_source, stream_id, platform, event_dimensions from `bppomelo.analytics_168405905.events_*`
-- where _TABLE_SUFFIX between  FORMAT_DATE("%Y%m%d",  DATE_SUB('{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}', INTERVAL 90 DAY))  and  FORMAT_DATE("%Y%m%d",  DATE_SUB('{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}', INTERVAL 0 DAY)) 

-- union all 
-- select 'chiccam' appName,event_date, event_timestamp, event_name, event_params, event_previous_timestamp, event_value_in_usd, event_bundle_sequence_id, event_server_timestamp_offset, user_id, user_pseudo_id, user_properties, user_first_touch_timestamp, user_ltv, device, geo, app_info, traffic_source, stream_id, platform, event_dimensions from `chiccam-ios-7cbb2.analytics_206192011.events_*`
-- where _TABLE_SUFFIX between  FORMAT_DATE("%Y%m%d",  DATE_SUB('{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}', INTERVAL 90 DAY))  and  FORMAT_DATE("%Y%m%d",  DATE_SUB('{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}', INTERVAL 0 DAY)) 
-- union all 
-- select 'airglow' appName,event_date, event_timestamp, event_name, event_params, event_previous_timestamp, event_value_in_usd, event_bundle_sequence_id, event_server_timestamp_offset, user_id, user_pseudo_id, user_properties, user_first_touch_timestamp, user_ltv, device, geo, app_info, traffic_source, stream_id, platform, event_dimensions from `airglow-d1240.analytics_210235684.events_*`
-- where _TABLE_SUFFIX between  FORMAT_DATE("%Y%m%d",  DATE_SUB('{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}', INTERVAL 90 DAY))  and  FORMAT_DATE("%Y%m%d",  DATE_SUB('{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}', INTERVAL 0 DAY)) 
-- union all 
-- select 'plusme' appName,event_date, event_timestamp, event_name, event_params, event_previous_timestamp, event_value_in_usd, event_bundle_sequence_id, event_server_timestamp_offset, user_id, user_pseudo_id, user_properties, user_first_touch_timestamp, user_ltv, device, geo, app_info, traffic_source, stream_id, platform, event_dimensions from `beautyplusme-1274.analytics_152556062.events_*`
-- where _TABLE_SUFFIX between  FORMAT_DATE("%Y%m%d",  DATE_SUB('{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}', INTERVAL 90 DAY))  and  FORMAT_DATE("%Y%m%d",  DATE_SUB('{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}', INTERVAL 0 DAY)) 
 
-- )

-- SELECT

--   m.appName,
--   m.event_date,
--   m.user_pseudo_id,
--   m.user_id gid,
--   cast(null as string) unified_id,
--    m.advertising_id,
--    cast(null as string) vendor_id,
--    cast(null as string) appsflyer_id,
--   m.platform,
--   m.category,
--   cast(null as int64) device_id,
--   m.LANGUAGE,
--   m.operating_system_version,

--   m.app_version,
--   cast(null as string) install_source,
--   cast(null as int64) geo_id,
--   CASE
--     WHEN n.user_pseudo_id IS NOT NULL THEN 1
--   ELSE
--   0
-- END
--   AS is_new,
--   country

-- FROM (
--   SELECT
--     a.appName,
--     a.event_date,
--     a.platform,
--     a.user_pseudo_id,
--     a.event_timestamp,
--     a.user_first_touch_timestamp,
--     a.category,
--     a.mobile_brand_name,
--     a.mobile_marketing_name,
--     a.mobile_os_hardware_model,
--     a.operating_system_version,
--     a.advertising_id,
--     a.LANGUAGE,
--     a.continent,
--     a.country country,
--     a.region,
--     a.city,
--     a.sub_continent,
--     a.version AS app_version,
--     a.user_id
--   FROM (
--     SELECT
--       appName,
--       platform,
--       PARSE_DATE('%Y%m%d',
--         event_date) AS event_date,
--       user_pseudo_id,
--       event_timestamp,
--       user_first_touch_timestamp,
--       device.category,
--       device.mobile_brand_name,
--       device.mobile_marketing_name,
--       device.mobile_os_hardware_model,
--       device.operating_system_version,
--       device.advertising_id,
--       device.LANGUAGE,
--       geo.continent,
--       geo.country AS country,
--       geo.region,
--       geo.city,
--       geo.sub_continent,
--       app_info.id,
--       app_info.install_store,
--       app_info.version,
--       user_id,
--       ROW_NUMBER() OVER(PARTITION BY appName,platform, PARSE_DATE('%Y%m%d', event_date),
--         user_pseudo_id
--       ORDER BY
--         event_timestamp ASC) rank
--     FROM
--       dsources
--     WHERE
--       platform IN ('ANDROID',
--         'IOS')
--       AND event_name = 'user_engagement' )a
--   WHERE
--     a.rank=1 )m
-- LEFT JOIN (
--   SELECT
--     a.appName,
--     a.event_date,
--     a.platform,
--     a.user_pseudo_id
--   FROM (
--     SELECT
--       appName,
--       platform,
--       -- DATE_SUB(event_date,INTERVAL 1 day) event_date,
--       PARSE_DATE('%Y%m%d',
--         event_date) AS event_date,
--       user_pseudo_id,
--       user_id,
--       ROW_NUMBER() OVER(PARTITION BY platform, PARSE_DATE('%Y%m%d', event_date),
--         user_pseudo_id
--       ORDER BY
--         event_timestamp ASC) rank
--     FROM
--       dsources,
--       UNNEST(event_params) AS h,
--       UNNEST(event_params) AS g
--     WHERE platform IN ('ANDROID',
--         'IOS')
--       AND event_name = 'first_open'
--       AND h.key='update_with_analytics'
--       AND h.value.int_value=0
--       AND g.key='previous_first_open_count'
--       AND g.value.int_value=0 )a
--   WHERE
--     a.rank=1 )n
-- ON
--   m.appName=n.appName and 
--   m.event_date=n.event_date
--   AND m.platform=n.platform
--   AND m.user_pseudo_id=n.user_pseudo_id
--   )

-- ),
all_app_stat_active_advice_view as
(
select
      *
 from
      `dataintegration-265403.stat.stat_active_advice_view`
--  union all
--  select
--       *
--  from
--        other_4app_stat_active_advice_view
 
),
before_append_user_source as(

select
  m.*
except(AppsFlyer_ID),
  COALESCE(k.AppsFlyer_ID,j.AppsFlyer_ID) AppsFlyer_ID,
  l.uuid,
  CASE
    WHEN is_new = 1 THEN 1 -- 新增
    WHEN s.active_days >= 1
    AND s.active_days <= 10 THEN 2 -- 低活
    WHEN s.active_days >= 11
    AND s.active_days <= 40 THEN 3 -- 中活
    WHEN s.active_days >= 41 THEN 4 -- 高活
    ELSE 5 -- 回流
  END AS user_type,
  case
    when  j.AppsFlyer_ID is not null then 'non-Organic'
    else 'Organic'
  end as is_UA

from
  (
    select
      *
    from
      all_app_stat_active_advice_view
    where
      event_date_hk =date_sub('{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}', interval run_before_days  day)
  ) m
  left join (
    select
      app_name,
      user_pseudo_id,
      count(distinct event_date_hk) active_days
    from
        all_app_stat_active_advice_view
    where
      event_date_hk between date_sub('{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}', interval 90+run_before_days  day) and date_sub('{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}', interval run_before_days  day)
    group by
      app_name,
      user_pseudo_id
  ) s on m.user_pseudo_id = s.user_pseudo_id
  and m.app_name = s.app_name
  left join (
    select *
      from 
      (SELECT
            *, 
            row_number() over(partition by app_name,user_pseudo_id  order by event_date_hk desc) rank
          FROM
            `dataintegration-265403.stat.stat_all_device_info_view`
            where  AppsFlyer_ID is not null
      )t
      where rank=1
  ) k on m.user_pseudo_id = k.user_pseudo_id
  and upper(m.app_name) = upper(k.app_name)
  left join (
    select
      distinct app_name,
      AppsFlyer_ID
    from
      `dataintegration-265403.roas_dataset.dws_dz_af_ua_info` channel
  ) j on COALESCE(k.AppsFlyer_ID,m.AppsFlyer_ID)= j.AppsFlyer_ID
  and upper(m.app_name) = upper(j.app_name)
left join `dataintegration-265403.stat.dmi_dz_idmapping` l
on m.user_pseudo_id  = l.key
)

select a1.*
      ,if(a2.uuid is not null,'Cross-promo',is_UA) user_source
      ,a2.from_app cross_promo_from_app
from before_append_user_source a1 
left join (
  select uuid,app_id,min(from_app) from_app
  from `dataintegration-265403.promo.dwd_dz_promo_newuser`
  group by uuid,app_id
) a2 on a1.uuid=a2.uuid and if(a2.app_id='AirBrush Video','AirVid',a2.app_id)=a1.app_name
;



SET run_before_days = run_before_days + 1;
END WHILE;