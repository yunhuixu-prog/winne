delete from `beautyplus-bc0ed.content_data.ads_dz_inapp_pop_data` where event_date_hk>='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=15)).strftime("%Y-%m-%d") }}'AND event_date_hk<='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}';

insert into `beautyplus-bc0ed.content_data.ads_dz_inapp_pop_data`
with 
content as (
SELECT distinct date,  upper(platform) as platform, id , title as content_title, country as content_country 
FROM `beautyplus-bc0ed.sub_dataset.beauty_plus_advert` 
where theme in ('机内推送') 
and  date>='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=15)).strftime("%Y-%m-%d") }}'AND date<='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
),
user as (
SELECT distinct  event_date , platform, user_pseudo_id, country, is_new, version
FROM `beautyplus-bc0ed.event_dataset_2.dws_dz_active_user_02` 
where event_date>='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=15)).strftime("%Y-%m-%d") }}'AND event_date<='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'

),
event as (
SELECT
event_date_hk, platform, event_name, key_name, value_name, user_pseudo_id, pv
FROM
  `beautyplus-bc0ed.content_data.dwd_dz_inapp_pop_event`
where event_date_hk>='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=15)).strftime("%Y-%m-%d") }}'AND event_date_hk<='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
union all

SELECT
event_date_hk, platform, event_name, key_name, 'all' as value_name, user_pseudo_id, sum(pv)
FROM
  `beautyplus-bc0ed.content_data.dwd_dz_inapp_pop_event`
where event_date_hk>='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=15)).strftime("%Y-%m-%d") }}'AND event_date_hk<='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
group by event_date_hk, platform, event_name, key_name, user_pseudo_id
)
,
sub_data as
(
    select
        date
        ,platform
        ,country
        ,is_new
        ,app_version
        ,event_name
        ,'pop_id' as key_name
        ,category3_mid as value_name
        ,cast(null as string) content_title
        ,cast(null as string) content_country
        ,sum(uv) uv
        ,sum(uv) pv
        ,sum(payment_price_usd) revenue
    from
--         `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_v4`
        `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_v5_temp`
    where
        data_type='category3'
        and category2='HomePage Pop'
--         and date>='2022-02-09'
        and date>='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=15)).strftime("%Y-%m-%d") }}'AND date<='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
        and event_name in ('sub_suc','sub_to_paid')
    group by
        1,2,3,4,5,6,7,8,9,10
    union all
    select
        date
        ,platform
        ,country
        ,is_new
        ,app_version
        ,event_name
        ,'pop_id' as key_name
        ,'all' as value_name
        ,cast(null as string) content_title
        ,cast(null as string) content_country
        ,sum(uv) uv
        ,sum(uv) pv
        ,sum(payment_price_usd) revenue
    from
--         `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_v4`
        `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_v5_temp`
    where
        data_type='category3'
        and category2='HomePage Pop'
--         and date>='2022-02-09'
        and date>='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=15)).strftime("%Y-%m-%d") }}'AND date<='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
        and event_name in ('sub_suc','sub_to_paid')
    group by
        1,2,3,4,5,6,7,8,9,10
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
on a.event_date_hk=b.event_date and a.platform=b.platform and a.user_pseudo_id=b.user_pseudo_id

left join content c
on a.event_date_hk=c.date and a.platform=c.platform and a.value_name=c.id

group by 1,2,3,4,5,6,7,8,9,10

union all

select * from sub_data