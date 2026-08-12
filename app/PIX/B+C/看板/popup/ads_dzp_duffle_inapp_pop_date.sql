delete from `beauty-cam-new.duffle.ads_dzp_duffle_inapp_pop_date` where event_date_hk>='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=15)).strftime("%Y-%m-%d") }}'AND event_date_hk<='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}';

insert into `beauty-cam-new.duffle.ads_dzp_duffle_inapp_pop_date`
with
content as (
SELECT distinct date,  upper(platform) as platform, id , title as content_title, country as content_country
FROM `beautyplus-bc0ed.sub_dataset.beauty_plus_advert`
where theme in ('机内推送') and platform='ANDROID'
and  date>='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=15)).strftime("%Y-%m-%d") }}'AND date<='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
),
user as (
SELECT distinct  event_date_hk , platform, user_pseudo_id, country
       , case when is_new=1 then 'New users' else 'Old users' end as is_new
       , app_version version
FROM `dataintegration-265403.stat.stat_active_advice_detail_d`
where event_date_hk>='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=15)).strftime("%Y-%m-%d") }}'AND event_date_hk<='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
    and app_name in ('Beauty Plus Cam')

),
event as (
SELECT
event_date_hk, platform, event_name, key_name, value_name, user_pseudo_id, pv
FROM
  `beauty-cam-new.dwd.dwd_dzp_duffle_inapp_pop_event`
where event_date_hk>='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=15)).strftime("%Y-%m-%d") }}'AND event_date_hk<='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
union all

SELECT
event_date_hk, platform, event_name, key_name, 'all' as value_name, user_pseudo_id, sum(pv)
FROM
  `beauty-cam-new.dwd.dwd_dzp_duffle_inapp_pop_event`
where event_date_hk>='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=15)).strftime("%Y-%m-%d") }}'AND event_date_hk<='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
group by event_date_hk, platform, event_name, key_name, user_pseudo_id
)

SELECT
    a.event_date_hk,
    a.platform,
    b.country,
    b.is_new,
    b.version,
    a.event_name,
    a.key_name,
    a.value_name,
    c.content_title,
    c.content_country,
    count(distinct a.user_pseudo_id) as uv,
    sum(a.pv) as pv,
    0 revenue
FROM event a

join user b
on a.event_date_hk=b.event_date_hk and a.platform=b.platform and a.user_pseudo_id=b.user_pseudo_id

left join content c
on a.event_date_hk=c.date and a.platform=c.platform and a.value_name=c.id

group by 1,2,3,4,5,6,7,8,9,10
