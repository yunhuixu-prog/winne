drop table if exists `dataintegration-265403.temp.winne_temp_dwd_ds_xyz_project_behavior`;
create table if not exists `dataintegration-265403.temp.winne_temp_dwd_ds_xyz_project_behavior` as

select
    event_date
    ,app_name
    ,platform
    ,event_timestamp
    ,event_name
    ,`dataintegration-265403.func`.getParams(event_params,'project').string_value project
    ,`dataintegration-265403.func`.getParams(event_params,'task_id').string_value task_id
    ,`dataintegration-265403.func`.getParams(event_params,'button_type').string_value button_type
    ,`dataintegration-265403.func`.getParams(event_params,'page_id').string_value page_id
    ,`dataintegration-265403.func`.getParams(event_params,'theme_type').string_value theme_type
    ,`dataintegration-265403.func`.getParams(event_params,'theme').string_value theme
    ,`dataintegration-265403.func`.getParams(event_params,'save_type').string_value save_type
    ,`dataintegration-265403.func`.getParams(event_params,'is_success').string_value is_success
    ,coalesce(`dataintegration-265403.func`.getParams(event_params,'material_id').string_value
                  ,`dataintegration-265403.func`.getParams(event_params,'mids_material_id').string_value) material_id
    ,`dataintegration-265403.func`.getParams(event_params,'material_type').string_value material_type
    ,`dataintegration-265403.func`.getParams(event_params,'prf_first_func').string_value prf_first_func
    ,`dataintegration-265403.func`.getParams(event_params,'first_func').string_value first_func
    ,`dataintegration-265403.func`.getUserprop(user_properties,'hwgid').string_value hwgid
    ,user_pseudo_id
    ,geo.country
from
    `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-03-15', '2025-04-06', 'beautyplus,airbrush', false)
where
    event_name in ('h5_page_button_clk','h5_page_button_clk_bd','h5_page_task_suc_show_f','h5_page_task_suc_show_f_bd'
                  ,'material_click','ai_func_use_result','edit_save')
--     or (
--         event_name in ('beauty_style_clk_bd', 'beautifysave_bd')
--         and `dataintegration-265403.func`.getParams(event_params,'style_id').string_value
--                         in (select distinct m_id from `dataintegration-265403.duffle_fin.dmi_da_materials_info_v`
--                             where remark in ('风格化-AIGC') and theme='STY')
--         )
--     or (event_name in ('material_click') and `dataintegration-265403.func`.getParams(event_params,'material_type').string_value='ai_image')
--     or (event_name in ('edit_save') and `dataintegration-265403.func`.getParams(event_params,'prf_first_func').string_value='ai_image')
--     or (event_name in ('ai_func_use_result') and `dataintegration-265403.func`.getParams(event_params,'first_func').string_value='ai_image')
;
-- 汇总
select a.event_date,app_name,'H5' types,a.project
     ,count(distinct a.user_pseudo_id) generate_uv
     ,count(distinct b.user_pseudo_id) see_generate_uv
--      ,count(distinct case when b.page_id='list_page_view' then b.user_pseudo_id end) list_see_generate_uv
--      ,count(distinct case when b.page_id='generated_page_view' then b.user_pseudo_id end) generated_see_generate_uv
     ,count(distinct c.user_pseudo_id) save_uv

--      ,count(distinct a.task_id) generate_pv
--      ,count(distinct b.task_id) see_generate_pv
--      ,count(distinct c.task_id) save_pv
from
(
    select event_date,app_name,project,task_id,user_pseudo_id,button_type
    from `dataintegration-265403.temp.winne_temp_dwd_ds_xyz_project_behavior`
    where event_name in ('h5_page_button_clk_bd','h5_page_button_clk')
        and button_type in ('non_zero_generate_upload','zero_generate_upload','non_zero_generate','zero_generate','generate','list','retry','upload_new','to_video')
        and coalesce(task_id,'-')!='no_task'
        and project in ('ai_portrait','ai_filter','AI_Pet_Portray')
        and event_date between '2025-03-15' and '2025-04-05'
) a
left join
(
    select event_date,project,task_id,user_pseudo_id,page_id
    from `dataintegration-265403.temp.winne_temp_dwd_ds_xyz_project_behavior`
    where event_name in ('h5_page_task_suc_show_f','h5_page_task_suc_show_f_bd')
) b
on a.event_date between date_sub(b.event_date,interval 1 day) and b.event_date
       and a.project=b.project and a.task_id=b.task_id and a.user_pseudo_id=b.user_pseudo_id
left join
(
    select event_date,project,task_id,user_pseudo_id
    from `dataintegration-265403.temp.winne_temp_dwd_ds_xyz_project_behavior`
    where event_name in ('h5_page_button_clk_bd','h5_page_button_clk') and button_type in ('save','save_all','save_video','save_gif')
        and (case when event_name in ('h5_page_button_clk_bd','h5_page_button_clk') and button_type = 'save'
                    and project = 'ai_filter' and event_date>='2024-12-31' and theme_type='photo' then save_type is not null
            else 1=1 end
            )
) c
on a.event_date between date_sub(c.event_date,interval 1 day) and c.event_date
       and a.project=c.project and a.task_id=c.task_id and a.user_pseudo_id=c.user_pseudo_id
group by 1,2,3,4

union all

select a.event_date,app_name,'Style' types,'ai_filter' project
     ,count(distinct a.user_pseudo_id) generate_uv
     ,count(distinct case when b.is_success='1' then b.user_pseudo_id end) see_generate_uv
--      ,count(distinct case when b.page_id='list_page_view' then b.user_pseudo_id end) list_see_generate_uv
--      ,count(distinct case when b.page_id='generated_page_view' then b.user_pseudo_id end) generated_see_generate_uv
     ,count(distinct c.user_pseudo_id) save_uv

--      ,count(distinct a.material_id) generate_pv -- 这个算的不对，是materialid和userid的汇总去重
--      ,count(distinct case when b.is_success='1' then b.material_id end) see_generate_pv
--      ,count(distinct c.material_id) save_pv
from
(
    select event_date,app_name,user_pseudo_id,material_id
    from `dataintegration-265403.temp.winne_temp_dwd_ds_xyz_project_behavior`
    where event_name in ('material_click') and material_type='ai_image'
        and event_date between '2025-03-15' and '2025-04-05'
) a
left join
(
    select event_date,user_pseudo_id,material_id,is_success
    from `dataintegration-265403.temp.winne_temp_dwd_ds_xyz_project_behavior`
    where event_name in ('ai_func_use_result') and first_func='ai_image'
) b
on a.event_date between date_sub(b.event_date,interval 0 day) and b.event_date
       and a.material_id=b.material_id and a.user_pseudo_id=b.user_pseudo_id
left join
(
    select event_date,user_pseudo_id,material_id
    from `dataintegration-265403.temp.winne_temp_dwd_ds_xyz_project_behavior`
    where event_name in ('edit_save') and prf_first_func='ai_image'
) c
on a.event_date between date_sub(c.event_date,interval 0 day) and c.event_date
       and a.material_id=c.material_id and a.user_pseudo_id=c.user_pseudo_id
group by 1,2,3,4


-- 区分素材id
select a.material_name,app_name,'H5' types,a.project
     ,count(distinct a.user_pseudo_id) generate_uv
     ,count(distinct b.user_pseudo_id) see_generate_uv
--      ,count(distinct case when b.page_id='list_page_view' then b.user_pseudo_id end) list_see_generate_uv
--      ,count(distinct case when b.page_id='generated_page_view' then b.user_pseudo_id end) generated_see_generate_uv
     ,count(distinct c.user_pseudo_id) save_uv

--      ,count(distinct a.task_id) generate_pv
--      ,count(distinct b.task_id) see_generate_pv
--      ,count(distinct c.task_id) save_pv
from
(
    select e.event_date,e.app_name,e.project,e.task_id,e.user_pseudo_id,e.button_type,coalesce(p.standard_theme,e.theme) material_name
    from `dataintegration-265403.temp.winne_temp_dwd_ds_xyz_project_behavior` e
    left join (select theme_id,max(theme) standard_theme from dataintegration-265403.dim.dim_gs_duffle_xyz_theme_standard_name group by 1) p
    on e.theme=p.theme_id
    where e.event_name in ('h5_page_button_clk_bd','h5_page_button_clk')
        and e.button_type in ('non_zero_generate_upload','zero_generate_upload','non_zero_generate','zero_generate','generate','list','retry','upload_new','to_video')
        and coalesce(e.task_id,'-')!='no_task'
        and e.project in ('ai_portrait','ai_filter','AI_Pet_Portray')
        and e.event_date between '2025-03-15' and '2025-04-05'
) a
left join
(
    select event_date,project,task_id,user_pseudo_id,page_id
    from `dataintegration-265403.temp.winne_temp_dwd_ds_xyz_project_behavior`
    where event_name in ('h5_page_task_suc_show_f','h5_page_task_suc_show_f_bd')
) b
on a.event_date between date_sub(b.event_date,interval 1 day) and b.event_date
       and a.project=b.project and a.task_id=b.task_id and a.user_pseudo_id=b.user_pseudo_id
left join
(
    select event_date,project,task_id,user_pseudo_id
    from `dataintegration-265403.temp.winne_temp_dwd_ds_xyz_project_behavior`
    where event_name in ('h5_page_button_clk_bd','h5_page_button_clk') and button_type in ('save','save_all','save_video','save_gif')
        and (case when event_name in ('h5_page_button_clk_bd','h5_page_button_clk') and button_type = 'save'
                    and project = 'ai_filter' and event_date>='2024-12-31' and theme_type='photo' then save_type is not null
            else 1=1 end
            )
) c
on a.event_date between date_sub(c.event_date,interval 1 day) and c.event_date
       and a.project=c.project and a.task_id=c.task_id and a.user_pseudo_id=c.user_pseudo_id
group by 1,2,3,4

union all

select a.material_name,app_name,'Style' types,'ai_filter' project
     ,count(distinct a.user_pseudo_id) generate_uv
     ,count(distinct case when b.is_success='1' then b.user_pseudo_id end) see_generate_uv
--      ,count(distinct case when b.page_id='list_page_view' then b.user_pseudo_id end) list_see_generate_uv
--      ,count(distinct case when b.page_id='generated_page_view' then b.user_pseudo_id end) generated_see_generate_uv
     ,count(distinct c.user_pseudo_id) save_uv

--      ,count(distinct a.material_id) generate_pv -- 这个算的不对，是materialid和userid的汇总去重
--      ,count(distinct case when b.is_success='1' then b.material_id end) see_generate_pv
--      ,count(distinct c.material_id) save_pv
from
(
    select e.event_date,e.app_name,e.user_pseudo_id,e.material_id,coalesce(p.standard_theme,st.style_name) material_name
    from `dataintegration-265403.temp.winne_temp_dwd_ds_xyz_project_behavior` e
    left join (select theme_id,max(theme) standard_theme from dataintegration-265403.dim.dim_gs_duffle_xyz_theme_standard_name group by 1) p
    on e.material_id=p.theme_id
    left join
        (select app,platform,m_id Material_id,start_date,end_date,max(name) style_name
        from `dataintegration-265403.duffle_fin.dmi_da_materials_info_v`
        where remark in ('风格化-AIGC') and theme='STY' group by 1,2,3,4,5
        ) st
    ON e.app_name = st.app
        AND e.platform = st.platform
        AND e.material_id=st.Material_id
        AND e.event_date >= st.start_date
        AND e.event_date < st.end_date
    where e.event_name in ('material_click') and e.material_type='ai_image'
        and e.event_date between '2025-03-15' and '2025-04-05'
) a
left join
(
    select event_date,user_pseudo_id,material_id,is_success
    from `dataintegration-265403.temp.winne_temp_dwd_ds_xyz_project_behavior`
    where event_name in ('ai_func_use_result') and first_func='ai_image'
) b
on a.event_date between date_sub(b.event_date,interval 0 day) and b.event_date
       and a.material_id=b.material_id and a.user_pseudo_id=b.user_pseudo_id
left join
(
    select event_date,user_pseudo_id,material_id
    from `dataintegration-265403.temp.winne_temp_dwd_ds_xyz_project_behavior`
    where event_name in ('edit_save') and prf_first_func='ai_image'
) c
on a.event_date between date_sub(c.event_date,interval 0 day) and c.event_date
       and a.material_id=c.material_id and a.user_pseudo_id=c.user_pseudo_id
group by 1,2,3,4

