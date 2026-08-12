select *
from
(
select date,platform
    ,case when (app_version >= '7.7.010' and platform='IOS') or  (app_version >= '7.7.013' and platform='ANDROID') then 'new version'
    else 'old version'
    end version_type
    ,is_ua,is_new
    ,case when date >= '2023-11-18' then 'after' else 'pre' end time
    ,sum(case when event_name in ('DAU') then  uv end) dau
    ,sum(case when event_name in ('Sub enter') then  uv end) sub_enter_uv
    ,sum(case when event_name in ('Sub click') then  uv end) sub_click_uv
    ,sum(case when event_name in ('Sub success') then  uv end) sub_success_uv
    ,sum(case when event_name in ('Sub success to paid') then  uv end) sub_to_paid_uv
    ,round(sum(case when event_name in ('Sub success to paid') then  payment_price_usd end),2) payment_price_usd
from beautyplus-bc0ed.sub_dataset.ads_dz_sub_datatype_event
where edition='V5.0'
    and ((date between '2023-10-21' and '2023-10-26') or  (date between '2023-11-03' and '2023-11-23') or (date between '2023-12-01' and '2023-12-15'))
    and platform='IOS'
    and ((app_version >= '7.7.010' and date >= '2023-11-18') or app_version < '7.7.010')
group by 1,2,3,4,5,6

union all

select date,platform
    ,case when (app_version >= '7.7.010' and platform='IOS') or  (app_version >= '7.7.013' and platform='ANDROID') then 'new version'
    else 'old version'
    end version_type
    ,is_ua,is_new
    ,case when date >= '2023-12-05' then 'after' else 'pre' end time
    ,sum(case when event_name in ('DAU') then  uv end) dau
    ,sum(case when event_name in ('Sub enter') then  uv end) sub_enter_uv
    ,sum(case when event_name in ('Sub click') then  uv end) sub_click_uv
    ,sum(case when event_name in ('Sub success') then  uv end) sub_success_uv
    ,sum(case when event_name in ('Sub success to paid') then  uv end) sub_to_paid_uv
    ,round(sum(case when event_name in ('Sub success to paid') then  payment_price_usd end),2) payment_price_usd
from beautyplus-bc0ed.sub_dataset.ads_dz_sub_datatype_event
where edition='V5.0'
    and ((date between '2023-11-14' and '2023-11-23') or (date between '2023-12-01' and '2023-12-18'))
    and platform='ANDROID'
    and ((app_version >= '7.7.013' and date >= '2023-12-05') or app_version < '7.7.013')
group by 1,2,3,4,5,6
)
order by 1,2,3,4,5,6