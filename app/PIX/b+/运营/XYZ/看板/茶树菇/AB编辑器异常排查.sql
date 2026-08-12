drop table if exists `dataintegration-265403.temp.winne_temp_dwd_ds_xyz_project_behavior`;
create table if not exists `dataintegration-265403.temp.winne_temp_dwd_ds_xyz_project_behavior` as

select event_date,event_name,app_name,platform
     ,`dataintegration-265403.func`.getParams(event_params,'material_id').string_value style_id
     ,user_pseudo_id
from
    `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-01-16', '2025-02-04', 'airbrush', false)
where
    (event_name in ('edit_save') and `dataintegration-265403.func`.getParams(event_params,'prf_first_func').string_value='ai_image')
    or
    (event_name in ('material_click') and `dataintegration-265403.func`.getParams(event_params,'material_type').string_value='ai_image')


select event_date,event_name
     ,count(distinct user_pseudo_id) uv,count(1) pv
     ,count(distinct case when e.style_id is not null then user_pseudo_id end) uv_1,count(case when e.style_id is not null then 1 end) pv_1
     ,count(distinct case when st.Material_id is not null then user_pseudo_id end) uv_2,count(case when st.Material_id is not null then 1 end) pv_2
from `dataintegration-265403.temp.winne_temp_dwd_ds_xyz_project_behavior` e
left join
(select app,platform,m_id Material_id,start_date,end_date,max(name) style_name
    from `dataintegration-265403.duffle_fin.dmi_da_materials_info_v`
    where remark in ('风格化-AIGC') and theme='STY' group by 1,2,3,4,5

    union all

    select 'Beauty Plus Cam' app,platform,m_id Material_id,start_date,end_date,max(name) style_name
    from `dataintegration-265403.duffle_fin.dmi_da_materials_info_v`
    where remark in ('风格化-AIGC') and theme='STY' and app='BeautyPlus' and platform='ANDROID'
    group by 1,2,3,4,5
    ) st
ON e.app_name = st.app
    AND e.platform = st.platform
    AND e.style_id=st.Material_id
    AND e.event_date >= st.start_date
    AND e.event_date < st.end_date
group by 1,2
order by 1,2


-- 修复
drop table if exists `dataintegration-265403.temp.winne_temp_dwd_ds_xyz_project_behavior`;
create table if not exists `dataintegration-265403.temp.winne_temp_dwd_ds_xyz_project_behavior` as

select event_date,event_name,app_name,platform
     ,`dataintegration-265403.func`.getParams(event_params,'material_id').string_value material_id
     ,`dataintegration-265403.func`.getParams(event_params,'mids_material_id').string_value mids_material_id
     ,user_pseudo_id
from
    `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-01-16', '2025-02-04', 'airbrush', true)
where
    event_name in ('edit_save') and `dataintegration-265403.func`.getParams(event_params,'prf_first_func').string_value='ai_image'
;
select event_date,event_name
     ,count(distinct user_pseudo_id) uv
     ,count(distinct case when e.material_id is not null then user_pseudo_id end) uv_1
     ,count(distinct case when coalesce(e.material_id,e.mids_material_id) is not null then user_pseudo_id end) uv_2
from `dataintegration-265403.temp.winne_temp_dwd_ds_xyz_project_behavior` e
group by 1,2
order by 1,2