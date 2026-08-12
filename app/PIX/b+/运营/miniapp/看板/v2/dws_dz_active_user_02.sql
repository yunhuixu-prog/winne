
--215dag

delete from  `beautyplus-bc0ed.event_dataset_2.dws_dz_active_user_02`  where event_date>='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}'AND event_date<='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}';
insert into `beautyplus-bc0ed.event_dataset_2.dws_dz_active_user_02`
with event as (
SELECT
*
FROM
`beautyplus-bc0ed.analytics.ods_dz_events_v`m
WHERE
m.event_date>='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}'AND m.event_date<='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
)
SELECT distinct c.event_date,
c.platform,c.user_pseudo_id, b.fix_firebase_en_name as country,
case when c.is_new=1 then 'New users' else 'Old users' end as is_new, c.is_UA,
case when c.user_type=1 then 'New users'
  when c.user_type=2 then 'Low active users'
  when c.user_type=3 then 'Middle active users'
  when c.user_type=4 then 'High active users'
end as user_type,
case when d.user_pseudo_id is not null then 'Paying' else 'un-Paying' end as is_pay, e.version, de.if_high  as android_device
from
 (
    SELECT distinct  event_date_hk as event_date, platform, user_pseudo_id, country, is_new, is_UA, user_type
    FROM `dataintegration-265403.stat.stat_active_advice_detail_d`
    where app_name = 'BeautyPlus'
    and event_date_hk>='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}'AND event_date_hk<='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
   --AND FORMAT_DATE("%Y%m%d", event_date)>='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y%m%d") }}'AND FORMAT_DATE("%Y%m%d", event_date)<='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y%m%d") }}'
  )c --渠道、新老、国家
LEFT JOIN
(
  SELECT
    DISTINCT key,
    fix_firebase_en_name
  FROM
    `dataintegration-265403.dmi.dmi_ya_country_code`,
    UNNEST(names) key
 ) b
ON c.country = b.key
left join
(
SELECT distinct
  platform,
  event_date,
  user_pseudo_id
FROM
  event,
  UNNEST( user_properties ) AS h
 --where event_date>='20210420' AND event_date<='20210421'
  where h.key in ('UserPaymentStatus')
  and h.value.string_value in ('Paying')
)d --付费用户
on c.event_date=d.event_date and c.platform=d.platform and c.user_pseudo_id=d.user_pseudo_id

left join
(
SELECT
  platform,
  event_date,
  user_pseudo_id,
  max(app_info.version) as version
FROM
  event
--where event_date>='20210420' AND event_date<='20210421'
  group by
  platform,
  event_date,
  user_pseudo_id
)e --版本
on c.event_date=e.event_date and c.platform=e.platform and c.user_pseudo_id=e.user_pseudo_id

left join
(
select  platform,event_date,user_pseudo_id,if_high FROM `beautyplus-bc0ed.event_dataset_2.dws_dz_android_is_high`
where event_date>='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}'AND event_date<='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
) de
on c.event_date=de.event_date and c.platform=de.platform and c.user_pseudo_id=de.user_pseudo_id

