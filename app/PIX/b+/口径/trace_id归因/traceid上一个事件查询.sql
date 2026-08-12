with user as
(select a.*
FROM `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-05-30','2025-05-30','beautyplus',false) a
WHERE event_name in('beautifysave_bd') --,'camera_appr_bd','ai_editor_save_suc_bd'
  and `dataintegration-265403.func`.compare_is_greater_or_equal_version(app_info.version,'7.10.0')
  and `dataintegration-265403.func`.getParams(event_params,'trace_info').string_value is null
  )
select a.platform,a.event_name,count(distinct a.user_pseudo_id) uv
from

(select a.platform,a.user_pseudo_id,`dataintegration-265403.func`.getParams(a.event_params,'trace_info').string_value as trace_info,a.event_timestamp,a.event_name,
row_number() over(
        partition by a.user_pseudo_id  order by a.event_timestamp desc) rn
FROM  `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-05-30','2025-05-30','beautyplus',false) a
join user b on a.user_pseudo_id=b.user_pseudo_id and a.event_timestamp < b.event_timestamp
where
`dataintegration-265403.func`.getParams(a.event_params,'trace_info').string_value is not null) a
where
rn=1
group by 1,2
order by platform,uv desc

;


with user as
(select a.*
FROM `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-05-30','2025-05-30','beautyplus',false) a
WHERE event_name in('camera_appr_bd') --,'film_cam_appr_bd','glow_cam_appr_bd','iphone_mode_appr_bd','selfie_appr_bd','stamp_cam_appr_bd'
  and `dataintegration-265403.func`.compare_is_greater_or_equal_version(app_info.version,'7.10.0')
  and `dataintegration-265403.func`.getParams(event_params,'trace_info').string_value is null
  )
select a.platform,a.event_name,count(distinct a.user_pseudo_id) uv
from

(select a.platform,a.user_pseudo_id,`dataintegration-265403.func`.getParams(a.event_params,'trace_info').string_value as trace_info,a.event_timestamp,a.event_name,
row_number() over(
        partition by a.user_pseudo_id  order by a.event_timestamp) rn
FROM  `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-05-30','2025-05-30','beautyplus',false) a
join user b on a.user_pseudo_id=b.user_pseudo_id and a.event_timestamp > b.event_timestamp
where
`dataintegration-265403.func`.getParams(a.event_params,'trace_info').string_value is not null) a
where
rn=1
group by 1,2
order by platform,uv desc


-- ;
-- with user as
-- (select a.*
-- FROM `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-05-30','2025-05-30','beautyplus',false) a
-- WHERE event_name in('camera_appr_bd','film_cam_appr_bd','glow_cam_appr_bd','iphone_mode_appr_bd','selfie_appr_bd','stamp_cam_appr_bd') --,'film_cam_appr_bd','glow_cam_appr_bd','iphone_mode_appr_bd','selfie_appr_bd','stamp_cam_appr_bd'
--   and `dataintegration-265403.func`.compare_is_greater_or_equal_version(app_info.version,'7.10.0')
--   and `dataintegration-265403.func`.getParams(event_params,'trace_info').string_value is null
--   )
-- select a.platform,a.lose_event_name,a.event_name,count(distinct a.user_pseudo_id) uv
-- from
--
-- (select a.platform,b.event_name lose_event_name,a.user_pseudo_id,`dataintegration-265403.func`.getParams(a.event_params,'trace_info').string_value as trace_info,a.event_timestamp,a.event_name,
-- row_number() over(
--         partition by a.user_pseudo_id  order by a.event_timestamp) rn
-- FROM  `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-05-30','2025-05-30','beautyplus',false) a
-- join user b on a.user_pseudo_id=b.user_pseudo_id and a.event_timestamp > b.event_timestamp
-- where
-- `dataintegration-265403.func`.getParams(a.event_params,'trace_info').string_value is not null) a
-- where
-- rn=1
-- group by 1,2,3
-- having count(distinct a.user_pseudo_id)>100
-- order by lose_event_name,platform,uv desc
