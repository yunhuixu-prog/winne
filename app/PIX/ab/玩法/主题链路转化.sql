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
    `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-09-01', '2025-11-06', 'airbrush', false)
where
    event_name in ('h5_page_button_clk','h5_page_task_suc_show_f','h5_home_content_show_f','h5_home_content_clk','h5_page_event')
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


-- 区分素材id
select
--     REGEXP_REPLACE(e.theme, r'(_EU|_AS|_TH|_AS_test|_AS\+TH| Eu|_AB|（AB）)|（B+）|live photo\+', '') material_name
     case when theme like '%FigMe%' then 'FigMe'
          when theme like '%MegaMe%' then 'MegaMe'
          when theme like '%Lamigo%' then 'Lamigo'
          when theme like '%First Snow%' then 'First Snow'
          when theme like '%Hikari%' then 'Hikari'
          when theme like '%Travel_Aquamarine%' then 'Travel_Aquamarine'
          when theme like '%Sunset%' then 'Sunset'
          when theme like '%Comic_Americana%' then 'Comic_Americana'
          when theme like '%Midnight Chill%' then 'Midnight Chill'
          when theme like '%Webtoon%' then 'Webtoon'
          when theme like '%Garden%' then 'Garden'
          when theme like '%Scarlet%' then 'Scarlet'
          when theme like '%Outfit_Glamour%' then 'Outfit_Glamour'
          when theme like '%AquaFlare%' then 'AquaFlare'
          when theme like '%Afternoon%' then 'Afternoon'
    else 'Other'
    end material_name
    ,e.event_date,e.app_name,e.project
    ,count(distinct case when e.event_name in ('h5_home_content_show_f')
        then e.user_pseudo_id end) exposure_uv
    ,count(distinct case when e.event_name in ('h5_home_content_clk')
        then e.user_pseudo_id end) click_uv
    ,count(distinct case when e.event_name in ('h5_page_event')
        and e.page_id = 'confirm_page_view'
        then e.user_pseudo_id end) confirm_uv
    ,count(distinct case when e.event_name in ('h5_page_event')
        and e.page_id = 'confirm_page_view'
        then e.user_pseudo_id end) confirm_uv
    ,count(distinct case when e.event_name in ('h5_page_button_clk')
        and e.button_type in ('generate','list','retry','upload_new','to_video') and coalesce(e.task_id,'-')!='no_task'
        then e.user_pseudo_id end) generate_uv
    ,count(distinct case when e.event_name in ('h5_page_button_clk')
        and e.button_type = 'generate' and coalesce(e.task_id,'-')!='no_task'
        then e.user_pseudo_id end) generate_uv_1
    ,count(distinct case when e.event_name in ('h5_page_button_clk')
        and e.button_type in ('list','retry','upload_new','to_video') and coalesce(e.task_id,'-')!='no_task'
        then e.user_pseudo_id end) generate_uv_2
    ,count(distinct case when e.event_name in ('h5_page_button_clk')
        and e.button_type in ('save','click_save') and save_type is null
        then e.user_pseudo_id end) click_save_uv
    ,count(distinct case when e.event_name in ('h5_page_button_clk')
        and e.button_type in ('save') and save_type is not null
        then e.user_pseudo_id end) save_uv
from `dataintegration-265403.temp.winne_temp_dwd_ds_xyz_project_behavior` e
where e.project in ('ai_filter') and e.theme not like '%XYZ_AF%'
group by 1,2,3,4

;
select
--     REGEXP_REPLACE(theme, r'(_EU|_AS|_TH|_AS_test|_AS\+TH| Eu)$', '') material_name
     case when theme like '%FigMe%' then 'FigMe'
          when theme like '%MegaMe%' then 'MegaMe'
          when theme like '%Lamigo%' then 'Lamigo'
          when theme like '%First Snow%' then 'First Snow'
          when theme like '%Hikari%' then 'Hikari'
          when theme like '%Travel_Aquamarine%' then 'Travel_Aquamarine'
          when theme like '%Sunset%' then 'Sunset'
          when theme like '%Comic_Americana%' then 'Comic_Americana'
          when theme like '%Midnight Chill%' then 'Midnight Chill'
          when theme like '%Webtoon%' then 'Webtoon'
          when theme like '%Garden%' then 'Garden'
          when theme like '%Scarlet%' then 'Scarlet'
          when theme like '%Outfit_Glamour%' then 'Outfit_Glamour'
          when theme like '%AquaFlare%' then 'AquaFlare'
          when theme like '%Afternoon%' then 'Afternoon'
    else 'Other'
    end material_name
     ,a.event_date,app_name,a.project
     ,count(distinct a.user_pseudo_id) generate_uv
     ,count(distinct b.user_pseudo_id) see_generate_uv
     ,count(distinct c.user_pseudo_id) save_uv

     ,count(distinct case when a.button_type='generate' then a.user_pseudo_id end) generate_uv_1
     ,count(distinct case when a.button_type='generate' then b.user_pseudo_id end) see_generate_uv_1
     ,count(distinct case when a.button_type='generate' then c.user_pseudo_id end) save_uv_1
     ,count(distinct case when a.button_type!='generate' then a.user_pseudo_id end) generate_uv_2
     ,count(distinct case when a.button_type!='generate' then b.user_pseudo_id end) see_generate_uv_2
     ,count(distinct case when a.button_type!='generate' then c.user_pseudo_id end) save_uv_2
from
(
    select e.event_date,e.app_name,e.project,e.task_id,e.user_pseudo_id,e.theme
        ,case when button_type='generate' then 'generate' else 'other' end button_type
    from `dataintegration-265403.temp.winne_temp_dwd_ds_xyz_project_behavior` e
    where e.event_name in ('h5_page_button_clk')
        and e.button_type in ('generate','list','retry','upload_new','to_video')
        and coalesce(e.task_id,'-')!='no_task'
        and e.project in ('ai_filter')
) a
left join
(
    select event_date,project,task_id,user_pseudo_id,page_id
    from `dataintegration-265403.temp.winne_temp_dwd_ds_xyz_project_behavior`
    where event_name in ('h5_page_task_suc_show_f')
) b
on a.event_date between date_sub(b.event_date,interval 1 day) and b.event_date
       and a.project=b.project and a.task_id=b.task_id and a.user_pseudo_id=b.user_pseudo_id
left join
(
    select event_date,project,task_id,user_pseudo_id
    from `dataintegration-265403.temp.winne_temp_dwd_ds_xyz_project_behavior`
--     where event_name in ('h5_page_button_clk') and button_type in ('save','save_all','save_video','save_gif')
--         and (case when event_name in ('h5_page_button_clk') and button_type = 'save'
--                     and project = 'ai_filter' and theme_type='photo' then save_type is not null
--             else 1=1 end
--             )
    where event_name in ('h5_page_button_clk')
        and button_type in ('save') and save_type is not null
) c
on a.event_date between date_sub(c.event_date,interval 1 day) and c.event_date
       and a.project=c.project and a.task_id=c.task_id and a.user_pseudo_id=c.user_pseudo_id
group by 1,2,3,4

