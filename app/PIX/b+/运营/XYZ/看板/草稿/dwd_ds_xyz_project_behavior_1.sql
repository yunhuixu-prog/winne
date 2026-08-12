
drop table if exists `dataintegration-265403.temp.t_dwd_ds_xyz_project_behavior`;
create table if not exists `dataintegration-265403.temp.t_dwd_ds_xyz_project_behavior` as

with
event_pre_raw as
(
   select
        app_name
        ,event_date
        ,event_name
        ,platform
        ,coalesce(app_info.version,'unknown') version
        ,case when `dataintegration-265403.func`.getParams(event_params,'project').string_value='BeautyPlus - PuriPlus' then 'puriplus'
            else `dataintegration-265403.func`.getParams(event_params,'project').string_value end project
        ,`dataintegration-265403.func`.getParams(event_params,'模块类型').string_value module_type
        ,`dataintegration-265403.func`.getParams(event_params,'模块ID').string_value module_id
        ,`dataintegration-265403.func`.getParams(event_params,'内容类型').string_value content_type
        ,`dataintegration-265403.func`.getParams(event_params,'内容ID').string_value content_id
        ,`dataintegration-265403.func`.getParams(event_params,'entry').string_value entry
        ,`dataintegration-265403.func`.getParams(event_params,'page_id').string_value page_id
        ,`dataintegration-265403.func`.getParams(event_params,'button_type').string_value button_type
        ,`dataintegration-265403.func`.getParams(event_params,'task_id').string_value task_id
        ,`dataintegration-265403.func`.getParams(event_params,'miniapp_id').string_value miniapp_id
        ,`dataintegration-265403.func`.getParams(event_params,'func').string_value func
        ,`dataintegration-265403.func`.getParams(event_params,'pop_id').string_value pop_id
        ,`dataintegration-265403.func`.getParams(event_params,'style_id').string_value style_id
        ,`dataintegration-265403.func`.getParams(event_params,'machine').string_value machine
        ,`dataintegration-265403.func`.getParams(event_params,'theme').string_value theme
        ,`dataintegration-265403.func`.getParams(event_params,'theme_type').string_value theme_type
        ,`dataintegration-265403.func`.getParams(event_params,'theme_category').string_value theme_category
        ,`dataintegration-265403.func`.getParams(event_params,'material_type').string_value material_type
        ,`dataintegration-265403.func`.getParams(event_params,'material_id').string_value material_id
        ,`dataintegration-265403.func`.getParams(event_params,'prf_first_func').string_value prf_first_func
        ,`dataintegration-265403.func`.getParams(event_params,'first_func').string_value first_func
        ,`dataintegration-265403.func`.getParams(event_params,'module_position').string_value module_position
        ,`dataintegration-265403.func`.getParams(event_params,'子功能').string_value detail_function
        ,case when app_name = 'AirBrush' then split(`dataintegration-265403.func`.getParams(event_params,'onelink_source').string_value,'=')[1]
              else `dataintegration-265403.func`.getParams(event_params,'onelink_source').string_value
         end onelink_source
        ,`dataintegration-265403.func`.getUserprop(user_properties,'UserPaymentStatus').string_value is_pay
        ,user_pseudo_id
    from
        `dataintegration-265403.analytics.dwd_dzp_events_function`('{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}', '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}', 'beautyplus,airbrush,beautypluscam', false)
    where event_name in ('home_content_show_f_bd','home_content_clk_bd'
                        ,'search_miniapp_appr_bd','search_miniapp_clk_bd'
                        ,'homepage_func_show','homepage_func_click'
                        ,'popup_show','popup_click'
                        ,'link_app_start_bd','link_app_start'
                        ,'h5_page_event_bd','h5_page_event'
                        ,'h5_page_button_clk_bd','h5_page_button_clk'
                        ,'h5_home_content_show_f_bd','h5_home_content_clk_bd'
                        ,'h5_home_content_show_f','h5_home_content_clk','h5_credit_consume_bd','h5_credit_consume'
                        ,'beauty_style_clk_bd','beauty_style_imp_bd','beautifysave_bd' -- b+编辑器
                        ,'ai_filter_task_creation_bd' --b+编辑器+配方生成
                        ,'beauty_appr_edit_clk_bd' -- b+进入AI创意
                        ,'material_exposure','material_click','edit_save' -- ab编辑器
                        ,'first_func_enter' -- ab进入AI创意
                        )
)
,
event_pre as
(
    select *
    from event_pre_raw
    where case when event_name in ('home_content_show_f_bd','home_content_clk_bd') then (module_type='miniapp' or (module_type='Banner' and content_type='miniapp') or (module_type in ('推荐功能','Topbanner','XYZ') and content_type in (select distinct Material_id from `dataintegration-265403.temp.dwd_da_miniapp_material_id_mapping` where App!='AirBrush')))
            when event_name in ('h5_page_event_bd','h5_page_event') then page_id in ('homepage','home_page_view','upload_page','confirm_page_view','video_confirm_page_view','bundle_page_view1','bundle_page_view2','edit_decorate_page') and project in (select distinct H5_name from `dataintegration-265403.temp.dwd_da_miniapp_miniapp_name_mapping`)
            when event_name in ('h5_page_button_clk_bd','h5_page_button_clk') then button_type in ('non_zero_generate_upload','zero_generate_upload','non_zero_generate','zero_generate','generate','list','save','save_all','share','image','frame','retry','upload_new','to_video') and project in (select distinct H5_name from `dataintegration-265403.temp.dwd_da_miniapp_miniapp_name_mapping`)
            when event_name in ('h5_home_content_show_f','h5_home_content_clk','h5_home_content_show_f_bd','h5_home_content_clk_bd','h5_credit_consume_bd','h5_credit_consume') then project in (select distinct H5_name from `dataintegration-265403.temp.dwd_da_miniapp_miniapp_name_mapping`)
            when event_name in ('search_miniapp_appr_bd','search_miniapp_clk_bd') then 1=1
            when event_name in ('link_app_start_bd','link_app_start') then onelink_source in (select distinct substr(Onelink,length(Onelink)-7) from `dataintegration-265403.temp.dwd_da_miniapp_adj_link_mapping`)
            when event_name in ('homepage_func_show','homepage_func_click') then func in (select distinct Ab_homepage_name from `dataintegration-265403.temp.dwd_da_miniapp_miniapp_name_mapping`)
            when event_name in ('popup_show','popup_click') then pop_id in (select distinct Material_id from `dataintegration-265403.temp.dwd_da_miniapp_material_id_mapping` where App='AirBrush')
            when event_name in ('beauty_style_clk_bd','beauty_style_imp_bd','beautifysave_bd') then
                    style_id in (select distinct m_id from `dataintegration-265403.duffle_fin.dmi_da_materials_info_v`
                                where remark in ('风格化-AIGC') and theme='STY')
            when event_name in ('beauty_appr_edit_clk_bd') then detail_function='风格化'
            when event_name in ('material_exposure','material_click') then material_type='ai_image'
            when event_name in ('edit_save') then prf_first_func='ai_image'
            when event_name in ('first_func_enter') then first_func='ai_image'
            when event_name in ('ai_filter_task_creation_bd') then material_id like 'BP_STY%' or material_id like 'BP_TEM'
            else 1=0
            end
)

    select
        e.app_name
        ,e.event_date
        ,e.platform
        ,e.event_name
        ,case   when event_name in ('home_content_show_f_bd','home_content_clk_bd','home_page_pop_appr_bd','home_page_pop_clk_bd','search_miniapp_appr_bd','search_miniapp_clk_bd','popup_show','popup_click') then m.miniapp
                when event_name in ('h5_page_event_bd','h5_page_event','h5_page_button_clk_bd','h5_page_button_clk','h5_home_content_show_f','h5_home_content_clk','h5_home_content_show_f_bd','h5_home_content_clk_bd','h5_credit_consume_bd','h5_credit_consume') then s.miniapp
                when event_name in ('link_app_start_bd','link_app_start') then a.miniapp
                when event_name in ('homepage_func_show','homepage_func_click') then ab.miniapp
                when event_name in ('beauty_style_clk_bd','beauty_style_imp_bd','beautifysave_bd','beauty_appr_edit_clk_bd','material_exposure','material_click','edit_save','first_func_enter','ai_filter_task_creation_bd') then 'AI Filter 1.0'
                else coalesce(miniapp_content_id,project)
                end project_name
        ,s.status
        ,entry
        ,case when event_name in ('h5_page_event_bd','h5_page_event','h5_page_button_clk_bd','h5_page_button_clk'
                                ,'h5_home_content_show_f','h5_home_content_clk','h5_home_content_show_f_bd','h5_home_content_clk_bd'
                                ,'h5_credit_consume_bd','h5_credit_consume') then 'H5'
              when event_name in ('beauty_style_clk_bd','beauty_style_imp_bd','beautifysave_bd','beauty_appr_edit_clk_bd','material_exposure','material_click','edit_save','first_func_enter') then 'Style'
              when event_name in ('ai_filter_task_creation_bd') and style_id like 'BP_STY%' then 'Style'
              when event_name in ('ai_filter_task_creation_bd') and style_id like 'BP_TEM%' then 'Template'
              when event_name in ('home_content_show_f_bd','home_content_clk_bd','home_page_pop_appr_bd','home_page_pop_clk_bd'
                                ,'search_miniapp_appr_bd','search_miniapp_clk_bd','popup_show','popup_click'
                                ,'homepage_func_show','homepage_func_click','link_app_start_bd','link_app_start') then 'All'
        end source
        ,page_id
        ,button_type
        ,module_type
        ,style_id material_id
        ,theme_type
        ,case when event_name in ('beauty_style_clk_bd','beauty_style_imp_bd','beautifysave_bd','material_exposure','material_click','edit_save','ai_filter_task_creation_bd') then style_name else theme end theme
        ,case when machine='1' then 'Clear Diary'
          when machine='2' then 'Sweetie'
          when machine='3' then 'Kawaii Party'
          when machine='4' then 'Life 4 Grid'
          else machine
        end machine
        ,module_position
        ,is_pay
        ,user_pseudo_id
        ,pv

        ,project
        ,miniapp_content_id miniapp_id
        ,onelink_source
        ,func
        ,task_id
    from
    (
        select
            app_name
            ,event_date
            ,platform
            ,event_name
            ,project
            ,case when event_name in ('h5_page_event_bd','h5_page_event','h5_page_button_clk_bd','h5_page_button_clk','h5_home_content_show_f','h5_home_content_clk','h5_home_content_show_f_bd','h5_home_content_clk_bd','h5_credit_consume_bd','h5_credit_consume') then entry else null end entry
            ,func
            ,pop_id
            ,coalesce(style_id,material_id) style_id
            ,case
                  when event_name in ('home_content_show_f_bd','home_content_clk_bd') and module_type='Banner' then module_id
                  when event_name in ('home_content_show_f_bd','home_content_clk_bd') and module_type in ('推荐功能','Topbanner','XYZ') then content_type
                  when event_name in ('search_miniapp_appr_bd','search_miniapp_clk_bd') then miniapp_id
                  when event_name in ('popup_show','popup_click') then pop_id
            else coalesce(content_id,content_type)
            end miniapp_content_id
            ,module_type
            ,page_id
            ,button_type
            ,task_id
            ,onelink_source
            ,case when project='ai_filter' then theme_type when project='ai_portrait' then theme_category end theme_type
            ,theme
            ,machine
            ,module_position
            ,case when event_name in ('h5_page_event_bd','h5_page_event','h5_page_button_clk_bd','h5_page_button_clk','h5_home_content_show_f','h5_home_content_clk','h5_home_content_show_f_bd','h5_home_content_clk_bd','h5_credit_consume_bd','h5_credit_consume') then is_pay else null end is_pay
            ,user_pseudo_id
            ,count(1) pv
        from event_pre
        group by
            1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21

        union all

        SELECT
            'BeautyPlus' app_name
            ,event_date_hk event_date
            ,platform
            ,event_name
            ,null project
            ,null entry
            ,null func
            ,null pop_id
            ,null style_id
            ,value_name miniapp_content_id
            ,null module_type
            ,null page_id
            ,null button_type
            ,null task_id
            ,null onelink_source
            ,null theme_type
            ,null theme
            ,null machine
            ,null module_position
            ,null is_pay
            ,user_pseudo_id
            ,pv
        FROM `beautyplus-bc0ed.content_data.dwd_dz_inapp_pop_event`
        where
            event_date_hk between '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}' and '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
            and event_name in ('home_page_pop_appr_bd','home_page_pop_clk_bd')
            and key_name='pop_id' and value_name in (select distinct Material_id from `dataintegration-265403.temp.dwd_da_miniapp_material_id_mapping` where App='BeautyPlus')

        union all

        SELECT
            'Beauty Plus Cam' app_name
            ,event_date_hk event_date
            ,platform
            ,event_name
            ,null project
            ,null entry
            ,null func
            ,null pop_id
            ,null style_id
            ,value_name miniapp_content_id
            ,null module_type
            ,null page_id
            ,null button_type
            ,null task_id
            ,null onelink_source
            ,null theme_type
            ,null theme
            ,null machine
            ,null module_position
            ,null is_pay
            ,user_pseudo_id
            ,pv
        FROM `beauty-cam-new.dwd.dwd_dzp_duffle_inapp_pop_event`
        where
            event_date_hk between '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}' and '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
            and event_name in ('home_page_pop_appr_bd','home_page_pop_clk_bd')
            and key_name='pop_id' and value_name in (select distinct Material_id from `dataintegration-265403.temp.dwd_da_miniapp_material_id_mapping` where App='BeautyPlus')

    ) e
    left join (select Material_id,App,max(Project) miniapp from `dataintegration-265403.temp.dwd_da_miniapp_material_id_mapping` group by 1,2) m on e.miniapp_content_id=m.Material_id
    left join (select H5_name,max(Project) miniapp,max(Status) status from `dataintegration-265403.temp.dwd_da_miniapp_miniapp_name_mapping` group by 1) s on e.project=s.H5_name
    left join (select Ab_homepage_name,max(Project) miniapp,max(Status) status from `dataintegration-265403.temp.dwd_da_miniapp_miniapp_name_mapping` group by 1) ab on e.func=ab.Ab_homepage_name
    left join (select substr(Onelink,length(Onelink)-7) adj_t,max(Project) miniapp from `dataintegration-265403.temp.dwd_da_miniapp_adj_link_mapping` group by 1) a on e.onelink_source=a.adj_t
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
    where case when event_name in ('home_content_show_f_bd','home_content_clk_bd'
                ,'search_miniapp_appr_bd','search_miniapp_clk_bd','home_page_pop_appr_bd','home_page_pop_clk_bd') then m.Material_id is not null
               when event_name in ('beauty_style_clk_bd','beauty_style_imp_bd','beautifysave_bd','material_exposure','material_click','edit_save') then st.Material_id is not null
        else 1=1 end


    union all

    select
        e.app_name
        ,e.date event_date
        ,e.platform
        ,event_action event_name
        ,'AI Filter 1.0' project_name
        ,null status
        ,null entry
        ,'Template' source
        ,null page_id
        ,null button_type
        ,null module_type
        ,e.material_id
        ,null theme_type
        ,material_name theme
        ,null machine
        ,null module_position
        ,null is_pay
        ,user_pseudo_id
        ,pv

        ,null project
        ,null miniapp_id
        ,null onelink_source
        ,null func
        ,null task_id
    from
    (
        select 'BeautyPlus' app_name,date,platform,material_id,user_pseudo_id,event_action,count(1) pv
        from `beautyplus-bc0ed.Duffle_dataset.dwd_dz_material_events_all`
        where date between '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}' and '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
            and feature='配方'
        group by 1,2,3,4,5,6

        union all

        select 'Beauty Plus Cam' app_name,date,platform,material_id,user_pseudo_id,event_action,count(1) pv
        from `beauty-cam-new.dwd.dwd_dzp_duffle_material_events_all`
        where date between '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}' and '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
            and feature='配方'
        group by 1,2,3,4,5,6
    ) e
    join (select app,platform,m_id Material_id,start_date,end_date,max(name) material_name
        from `dataintegration-265403.duffle_fin.dmi_da_materials_info_v`
        where remark in ('AI style') and theme='TEM' group by 1,2,3,4,5

        union all

        select 'Beauty Plus Cam' app,platform,m_id Material_id,start_date,end_date,max(name) material_name
        from `dataintegration-265403.duffle_fin.dmi_da_materials_info_v`
        where remark in ('AI style') and theme='TEM' and app='BeautyPlus' and platform='ANDROID'
        group by 1,2,3,4,5
        ) st
    ON e.app_name = st.app
        AND e.platform = st.platform
        AND e.material_id=st.Material_id
        AND e.date >= st.start_date
        AND e.date < st.end_date

