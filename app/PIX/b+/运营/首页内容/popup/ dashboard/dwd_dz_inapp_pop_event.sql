--BQ跑行为
delete from `beautyplus-bc0ed.content_data.dwd_dz_inapp_pop_event` where event_date_hk>='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=4)).strftime("%Y-%m-%d") }}'AND event_date_hk<='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}';

insert into `beautyplus-bc0ed.content_data.dwd_dz_inapp_pop_event`
with 
event as(
SELECT * FROM
`beautyplus-bc0ed.analytics.ods_dz_events_v`
where event_date>='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=4)).strftime("%Y-%m-%d") }}'AND event_date<='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
)

select
    m.event_date as event_date_hk,
    m.platform, 
    m.event_name,
    m.key_name,
    m.value_name,
    m.user_pseudo_id,
    m.pv
from 
(
SELECT 
  event_date,
  platform,
  event_name,
  h.key as key_name,
  h.value.string_value as value_name,
  user_pseudo_id,
  count(1) as pv
FROM
  event m , UNNEST(event_params) as h
--and n.module in ('修图')
where m.event_name in ('home_page_pop_appr_bd')
and h.key in ('pop_id')
group by 1,2,3,4,5,6

union all 
SELECT 
  event_date,
  platform,
  event_name,
  'pop_id' as key_name,
  func.getParams(event_params,'pop_id').string_value as value_name,
  user_pseudo_id,
  count(1) as pv
FROM
  event m --, UNNEST(event_params) as h
--and n.module in ('修图')
where m.event_name in ('home_page_pop_clk_bd')
and (func.getParams(event_params,'type').string_value in ('try_it'))
group by 1,2,3,4,5,6

)m

