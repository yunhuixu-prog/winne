SELECT count(distinct gid) uv
FROM stat_sdk.airbrush_mdz_tool_behavior_detail
WHERE date_p between 20260101 and 20260331
    AND model_p IN ('image_edit') -- , 'camera', 'sp_edit', 'H5'
    AND tool_level in ('2')
    and sub_func_level2_name='Plump'
    and event_type='进入'
;
select sum(uv) uv 
from (
SELECT date_p,count(distinct gid) uv
FROM stat_sdk.airbrush_mdz_tool_behavior_detail
WHERE date_p between 20260101 and 20260331
    AND model_p IN ('image_edit') -- , 'camera', 'sp_edit', 'H5'
    AND tool_level in ('2')
    and sub_func_level2_name='Plump'
    and event_type='进入'
group by date_p) t
;

select
    count(distinct gid) uv
from stat_ab.filing_onz_sub_source_event_detail_level
where date_p between 20260101 and 20260331
    and third_source='Plump'
    and event_id='sub_enter'
;
select sum(uv) uv 
from (
SELECT date_p,count(distinct gid) uv
FROM stat_ab.filing_onz_sub_source_event_detail_level
WHERE date_p between 20260101 and 20260331
    and third_source='Plump'
    and event_id='sub_enter'
group by date_p) t
;

select sum(uv) uv 
from (
SELECT date_p, count(distinct final_id) uv
FROM stat_sdk.sdk_odz_active
WHERE date_p BETWEEN 20250101 and 20251231
    AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
    AND os_p IS NOT NULL
group by date_p) t
;
SELECT count(distinct final_id) uv
FROM stat_sdk.sdk_odz_active
WHERE date_p BETWEEN 20250101 and 20251231
    AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
    AND os_p IS NOT NULL
;

-- pix临时跑下历史(新加的功能没救了)
select
    count(distinct user_pseudo_id) uv
from `airbrush-1324.stat.dws_airbrush_trial_sub`
where source_module != 'all'
    and event_date between '2025-01-01' and '2025-12-31'
    and event_name in ('w_subscription_enter')
    and source_00='f_body'
;
select sum(uv) uv 
from (
SELECT event_date,count(distinct user_pseudo_id) uv
FROM `airbrush-1324.stat.dws_airbrush_trial_sub`
where source_module != 'all'
    and event_date between '2025-01-01' and '2025-12-31'
    and event_name in ('w_subscription_enter')
    and source_00='f_body'
group by event_date) t

