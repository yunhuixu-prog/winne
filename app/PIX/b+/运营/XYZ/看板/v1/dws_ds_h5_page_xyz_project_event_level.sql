-- dws_ds_h5_page_xyz_project_event_level
-- miniapp mapping: https://docs.google.com/spreadsheets/d/1J-4FIowZHgFOVUfHR8DyLbpS6yhzaPzOJaUD5Di31G4/edit#gid=1398841059
-- `dataintegration-265403.temp.dwd_da_miniapp_material_id_mapping`
-- `dataintegration-265403.temp.dwd_da_miniapp_miniapp_name_mapping`
-- `dataintegration-265403.temp.dwd_da_miniapp_adj_link_mapping`

drop table if exists `dataintegration-265403.temp.dws_ds_h5_page_xyz_project_event_level_pre`;
create table if not exists `dataintegration-265403.temp.dws_ds_h5_page_xyz_project_event_level_pre` as

with
event_pre_raw as
(
   select
        app_name
        ,event_date
        ,event_name
        ,platform
        ,coalesce(app_info.version,'unknown') version
        ,`dataintegration-265403.func`.getParams(event_params,'project').string_value project
        ,`dataintegration-265403.func`.getParams(event_params,'模块类型').string_value module_type
        ,`dataintegration-265403.func`.getParams(event_params,'模块ID').string_value module_id
        ,`dataintegration-265403.func`.getParams(event_params,'内容类型').string_value content_type
        ,`dataintegration-265403.func`.getParams(event_params,'内容ID').string_value content_id
        ,`dataintegration-265403.func`.getParams(event_params,'from_page').string_value from_page
        ,`dataintegration-265403.func`.getParams(event_params,'page_id').string_value page_id
        ,`dataintegration-265403.func`.getParams(event_params,'button_type').string_value button_type
        ,`dataintegration-265403.func`.getParams(event_params,'miniapp_id').string_value miniapp_id
        ,`dataintegration-265403.func`.getParams(event_params,'func').string_value func
        ,`dataintegration-265403.func`.getParams(event_params,'pop_id').string_value pop_id
        ,`dataintegration-265403.func`.getParams(event_params,'theme').string_value theme
        ,`dataintegration-265403.func`.getParams(event_params,'theme_type').string_value theme_type
        ,case when app_name = 'AirBrush' then split(`dataintegration-265403.func`.getParams(event_params,'onelink_source').string_value,'=')[1]
              else `dataintegration-265403.func`.getParams(event_params,'onelink_source').string_value
         end onelink_source
        ,`dataintegration-265403.func`.getUserprop(user_properties,'UserPaymentStatus').string_value is_pay
        ,user_pseudo_id
    from
        `dataintegration-265403.analytics.dwd_dzp_events_function`('{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}', '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}', 'beautyplus,airbrush,beautypluscam', false)
    where event_name in ('home_content_show_f_bd','home_content_clk_bd'
                        ,'h5_page_event_bd','h5_page_event'
                        ,'h5_page_button_clk_bd','h5_page_button_clk'
                        ,'search_miniapp_appr_bd','search_miniapp_clk_bd'
                        ,'link_app_start_bd','link_app_start'
                        ,'homepage_func_show','homepage_func_click'
                        ,'popup_show','popup_click')
)
,
event_pre as
(
    select *
    from event_pre_raw
    where case when event_name in ('home_content_show_f_bd','home_content_clk_bd') then (module_type='miniapp' or (module_type='Banner' and content_type='miniapp') or (module_type in ('推荐功能','Topbanner','XYZ') and content_type in (select distinct Material_id from `dataintegration-265403.temp.dwd_da_miniapp_material_id_mapping` where App!='AirBrush')))
            when event_name in ('h5_page_event_bd','h5_page_event') then page_id in ('homepage','upload_page','home_page_view','confirm_page_view','video_confirm_page_view','bundle_page_view1','bundle_page_view2','edit_decorate_page') and project in (select distinct H5_name from `dataintegration-265403.temp.dwd_da_miniapp_miniapp_name_mapping`)
            when event_name in ('h5_page_button_clk_bd','h5_page_button_clk') then button_type in ('non_zero_generate_upload','zero_generate_upload','non_zero_generate','zero_generate','generate','list','save','save_all','zero_save','none_zero_save','non_zero_save','share','share_for_free') and project in (select distinct H5_name from `dataintegration-265403.temp.dwd_da_miniapp_miniapp_name_mapping`)
            when event_name in ('search_miniapp_appr_bd','search_miniapp_clk_bd') then 1=1
            when event_name in ('link_app_start_bd','link_app_start') then onelink_source in (select distinct substr(Onelink,length(Onelink)-7) from `dataintegration-265403.temp.dwd_da_miniapp_adj_link_mapping`)
            when event_name in ('homepage_func_show','homepage_func_click') then func in (select distinct Ab_homepage_name from `dataintegration-265403.temp.dwd_da_miniapp_miniapp_name_mapping`)
            when event_name in ('popup_show','popup_click') then pop_id in (select distinct Material_id from `dataintegration-265403.temp.dwd_da_miniapp_material_id_mapping` where App='AirBrush')
            else 1=0
            end
)

    select
        app_name
        ,event_date
        ,platform
        ,event_name
        ,case   when event_name in ('home_content_show_f_bd','home_content_clk_bd','home_page_pop_appr_bd','home_page_pop_clk_bd','search_miniapp_appr_bd','search_miniapp_clk_bd','popup_show','popup_click') then m.miniapp
                when event_name in ('h5_page_event_bd','h5_page_event','h5_page_button_clk_bd','h5_page_button_clk') then s.miniapp
                when event_name in ('link_app_start_bd','link_app_start') then a.miniapp
                when event_name in ('homepage_func_show','homepage_func_click') then ab.miniapp
                else coalesce(miniapp_content_id,project)
                end project_name
        ,project
        ,miniapp_content_id miniapp_id
        ,s.status
        ,page_id
        ,button_type
        ,module_type
        ,onelink_source
        ,func
        ,pop_id
        ,theme_type
        ,theme
        ,is_pay
        ,user_pseudo_id
        ,pv
    from
    (
        select
            app_name
            ,event_date
            ,platform
            ,event_name
            ,project
            ,func
            ,pop_id
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
            ,onelink_source
            ,theme_type
            ,theme
            ,case when event_name in ('h5_page_event_bd','h5_page_event','h5_page_button_clk_bd','h5_page_button_clk') then is_pay else null end is_pay
            ,user_pseudo_id
            ,count(1) pv
        from event_pre
        group by
            1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16

        union all

        SELECT
            'BeautyPlus' app_name
            ,event_date_hk event_date
            ,platform
            ,event_name
            ,null project
            ,null func
            ,null pop_id
            ,value_name miniapp_content_id
            ,null module_type
            ,null page_id
            ,null button_type
            ,null onelink_source
            ,null theme_type
            ,null theme
            ,null is_pay
            ,user_pseudo_id
            ,pv
        FROM `beautyplus-bc0ed.content_data.dwd_dz_inapp_pop_event`
        where
            event_date_hk between '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}' and '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
            and event_name in ('home_page_pop_appr_bd','home_page_pop_clk_bd')
            and key_name='pop_id' and value_name in (select distinct Material_id from `dataintegration-265403.temp.dwd_da_miniapp_material_id_mapping` where App='BeautyPlus')
    ) e
    left join (select Material_id,App,max(Project) miniapp from `dataintegration-265403.temp.dwd_da_miniapp_material_id_mapping` group by 1,2) m on e.miniapp_content_id=m.Material_id
    left join (select H5_name,max(Project) miniapp,max(Status) status from `dataintegration-265403.temp.dwd_da_miniapp_miniapp_name_mapping` group by 1) s on e.project=s.H5_name
    left join (select Ab_homepage_name,max(Project) miniapp,max(Status) status from `dataintegration-265403.temp.dwd_da_miniapp_miniapp_name_mapping` group by 1) ab on e.func=ab.Ab_homepage_name
    left join (select substr(Onelink,length(Onelink)-7) adj_t,max(Project) miniapp from `dataintegration-265403.temp.dwd_da_miniapp_adj_link_mapping` group by 1) a on e.onelink_source=a.adj_t
    where case when event_name in ('home_content_show_f_bd','home_content_clk_bd'
                ,'search_miniapp_appr_bd','search_miniapp_clk_bd','home_page_pop_appr_bd','home_page_pop_clk_bd') then m.Material_id is not null else 1=1 end
;

-- drop table if exists `dataintegration-265403.temp.dws_ds_h5_page_xyz_project_event_level`;
-- create table if not exists `dataintegration-265403.temp.dws_ds_h5_page_xyz_project_event_level` as
delete from  `dataintegration-265403.temp.dws_ds_h5_page_xyz_project_event_level`  where event_date>='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}' and event_date<='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}';
insert into `dataintegration-265403.temp.dws_ds_h5_page_xyz_project_event_level`
with user_info as
(
    select
        event_date_hk
        ,app_name
        ,platform
        ,country
        ,user_pseudo_id
        ,max(is_new) is_new
        ,max(is_UA) is_UA
    from
        `dataintegration-265403.stat.stat_active_advice_detail_d`
    where
        event_date_hk between '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}' and '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
        and app_name in ('BeautyPlus','AirBrush','Beauty Plus Cam')
    group by 1,2,3,4,5
)
,
event_result as
(
    select
        e.app_name
        ,e.event_date
        ,e.platform
        ,u.country
        ,u.is_new
        ,u.is_UA
--         ,e.is_pay
        ,case when e.is_pay in ('Paying') or e.is_pay is null then e.is_pay else 'Non-paying' end is_pay
        ,project_name
        ,coalesce(e.status,s.status) status
        ,'all' theme
        ,count(distinct case when event_name in ('home_content_show_f_bd','home_page_pop_appr_bd','search_miniapp_appr_bd','homepage_func_show','popup_show') then e.user_pseudo_id end) exposure_uv
        ,count(distinct case when event_name in ('home_content_clk_bd','home_page_pop_clk_bd','search_miniapp_clk_bd','homepage_func_click','popup_click') then e.user_pseudo_id end) click_uv
        ,count(distinct case when (event_name in ('home_content_show_f_bd') and module_type in ('miniapp','XYZ')) or event_name in ('homepage_func_show') then e.user_pseudo_id end) exposure_miniapp_uv
        ,count(distinct case when (event_name in ('home_content_clk_bd')  and module_type in ('miniapp','XYZ')) or event_name in ('homepage_func_click') then e.user_pseudo_id end) click_miniapp_uv
        ,count(distinct case when event_name in ('home_content_show_f_bd') and module_type in ('Banner','Topbanner') then e.user_pseudo_id end) exposure_banner_uv
        ,count(distinct case when event_name in ('home_content_clk_bd')  and module_type in ('Banner','Topbanner') then e.user_pseudo_id end) click_banner_uv
        ,count(distinct case when event_name in ('home_content_show_f_bd') and module_type='推荐功能' then e.user_pseudo_id end) exposure_function_uv
        ,count(distinct case when event_name in ('home_content_clk_bd')  and module_type='推荐功能' then e.user_pseudo_id end) click_function_uv
        ,count(distinct case when event_name in ('home_page_pop_appr_bd','popup_show') then e.user_pseudo_id end) exposure_popup_uv
        ,count(distinct case when event_name in ('home_page_pop_clk_bd','popup_click') then e.user_pseudo_id end) click_popup_uv
        ,count(distinct case when event_name in ('search_miniapp_appr_bd') then e.user_pseudo_id end) exposure_search_uv
        ,count(distinct case when event_name in ('search_miniapp_clk_bd') then e.user_pseudo_id end) click_search_uv

        ,count(distinct case when event_name in ('h5_page_event_bd','h5_page_event') and page_id in ('homepage','home_page_view') then e.user_pseudo_id end) visit_uv
        ,count(distinct case when event_name in ('h5_page_event_bd','h5_page_event') and page_id in ('upload_page','confirm_page_view','video_confirm_page_view','bundle_page_view1','bundle_page_view2','edit_decorate_page') then e.user_pseudo_id end) enter_generate_page_uv
        ,count(distinct case when event_name in ('h5_page_button_clk_bd','h5_page_button_clk') and (button_type like '%generate%' or button_type='list') then e.user_pseudo_id end) generate_uv
        ,count(distinct case when event_name in ('h5_page_button_clk_bd','h5_page_button_clk') and button_type like '%save%' then e.user_pseudo_id end) save_uv
        ,count(distinct case when event_name in ('h5_page_button_clk_bd','h5_page_button_clk') and button_type like '%share%' then e.user_pseudo_id end) share_uv

        ,count(distinct case when event_name in ('link_app_start_bd','link_app_start') then e.user_pseudo_id end) onelink_uv

        ,sum(case when event_name in ('home_content_show_f_bd','home_page_pop_appr_bd','search_miniapp_appr_bd','homepage_func_show','popup_show') then pv end) exposure_pv
        ,sum(case when event_name in ('home_content_clk_bd','home_page_pop_clk_bd','search_miniapp_clk_bd','homepage_func_click','popup_click') then pv end) click_pv
        ,sum(case when (event_name in ('home_content_show_f_bd') and module_type in ('miniapp','XYZ')) or event_name in ('homepage_func_show') then pv end) exposure_miniapp_pv
        ,sum(case when (event_name in ('home_content_clk_bd')  and module_type in ('miniapp','XYZ')) or event_name in ('homepage_func_click') then pv end) click_miniapp_pv
        ,sum(case when event_name in ('home_content_show_f_bd') and module_type in ('Banner','Topbanner') then pv end) exposure_banner_pv
        ,sum(case when event_name in ('home_content_clk_bd') and module_type in ('Banner','Topbanner') then pv end) click_banner_pv
        ,sum(case when event_name in ('home_content_show_f_bd') and module_type='推荐功能' then pv end) exposure_function_pv
        ,sum(case when event_name in ('home_content_clk_bd') and module_type='推荐功能' then pv end) click_function_pv
        ,sum(case when event_name in ('home_page_pop_appr_bd','popup_show') then pv end) exposure_popup_pv
        ,sum(case when event_name in ('home_page_pop_clk_bd','popup_click') then pv end) click_popup_pv
        ,sum(case when event_name in ('search_miniapp_appr_bd') then pv end) exposure_search_pv
        ,sum(case when event_name in ('search_miniapp_clk_bd') then pv end) click_search_pv

        ,sum(case when event_name in ('h5_page_event_bd','h5_page_event') and page_id in ('homepage','home_page_view') then pv end) visit_pv
        ,sum(case when event_name in ('h5_page_event_bd','h5_page_event') and page_id in ('upload_page','confirm_page_view','video_confirm_page_view','bundle_page_view1','bundle_page_view2','edit_decorate_page') then pv end) enter_generate_page_pv
        ,sum(case when event_name in ('h5_page_button_clk_bd','h5_page_button_clk') and (button_type like '%generate%' or button_type='list') then pv end) generate_pv
        ,sum(case when event_name in ('h5_page_button_clk_bd','h5_page_button_clk') and button_type like '%save%' then pv end) save_pv
        ,sum(case when event_name in ('h5_page_button_clk_bd','h5_page_button_clk') and button_type like '%share%' then pv end) share_pv

        ,sum(case when event_name in ('link_app_start_bd','link_app_start') then pv end) onelink_pv
    from
        `dataintegration-265403.temp.dws_ds_h5_page_xyz_project_event_level_pre` e
        join user_info u on e.user_pseudo_id=u.user_pseudo_id and e.event_date=u.event_date_hk and e.platform=u.platform and e.app_name=u.app_name
        left join (select Project,max(Status) status from `dataintegration-265403.temp.dwd_da_miniapp_miniapp_name_mapping` group by 1) s
        on e.project_name=s.Project
    group by
        1,2,3,4,5,6,7,8,9,10

    union all

    select
        e.app_name
        ,e.event_date
        ,e.platform
        ,u.country
        ,u.is_new
        ,u.is_UA
--         ,e.is_pay
        ,case when e.is_pay in ('Paying') or e.is_pay is null then e.is_pay else 'Non-paying' end is_pay
        ,project_name
        ,coalesce(e.status,s.status) status
        ,theme
        ,count(distinct case when event_name in ('home_content_show_f_bd','home_page_pop_appr_bd','search_miniapp_appr_bd','homepage_func_show','popup_show') then e.user_pseudo_id end) exposure_uv
        ,count(distinct case when event_name in ('home_content_clk_bd','home_page_pop_clk_bd','search_miniapp_clk_bd','homepage_func_click','popup_click') then e.user_pseudo_id end) click_uv
        ,count(distinct case when (event_name in ('home_content_show_f_bd') and module_type in ('miniapp','XYZ')) or event_name in ('homepage_func_show') then e.user_pseudo_id end) exposure_miniapp_uv
        ,count(distinct case when (event_name in ('home_content_clk_bd')  and module_type in ('miniapp','XYZ')) or event_name in ('homepage_func_click') then e.user_pseudo_id end) click_miniapp_uv
        ,count(distinct case when event_name in ('home_content_show_f_bd') and module_type in ('Banner','Topbanner') then e.user_pseudo_id end) exposure_banner_uv
        ,count(distinct case when event_name in ('home_content_clk_bd')  and module_type in ('Banner','Topbanner') then e.user_pseudo_id end) click_banner_uv
        ,count(distinct case when event_name in ('home_content_show_f_bd') and module_type='推荐功能' then e.user_pseudo_id end) exposure_function_uv
        ,count(distinct case when event_name in ('home_content_clk_bd')  and module_type='推荐功能' then e.user_pseudo_id end) click_function_uv
        ,count(distinct case when event_name in ('home_page_pop_appr_bd','popup_show') then e.user_pseudo_id end) exposure_popup_uv
        ,count(distinct case when event_name in ('home_page_pop_clk_bd','popup_click') then e.user_pseudo_id end) click_popup_uv
        ,count(distinct case when event_name in ('search_miniapp_appr_bd') then e.user_pseudo_id end) exposure_search_uv
        ,count(distinct case when event_name in ('search_miniapp_clk_bd') then e.user_pseudo_id end) click_search_uv

        ,count(distinct case when event_name in ('h5_page_event_bd','h5_page_event') and page_id in ('homepage','home_page_view') then e.user_pseudo_id end) visit_uv
        ,count(distinct case when event_name in ('h5_page_event_bd','h5_page_event') and page_id in ('upload_page','confirm_page_view','video_confirm_page_view','bundle_page_view1','bundle_page_view2','edit_decorate_page') then e.user_pseudo_id end) enter_generate_page_uv
        ,count(distinct case when event_name in ('h5_page_button_clk_bd','h5_page_button_clk') and (button_type like '%generate%' or button_type='list') then e.user_pseudo_id end) generate_uv
        ,count(distinct case when event_name in ('h5_page_button_clk_bd','h5_page_button_clk') and button_type like '%save%' then e.user_pseudo_id end) save_uv
        ,count(distinct case when event_name in ('h5_page_button_clk_bd','h5_page_button_clk') and button_type like '%share%' then e.user_pseudo_id end) share_uv

        ,count(distinct case when event_name in ('link_app_start_bd','link_app_start') then e.user_pseudo_id end) onelink_uv

        ,sum(case when event_name in ('home_content_show_f_bd','home_page_pop_appr_bd','search_miniapp_appr_bd','homepage_func_show','popup_show') then pv end) exposure_pv
        ,sum(case when event_name in ('home_content_clk_bd','home_page_pop_clk_bd','search_miniapp_clk_bd','homepage_func_click','popup_click') then pv end) click_pv
        ,sum(case when (event_name in ('home_content_show_f_bd') and module_type in ('miniapp','XYZ')) or event_name in ('homepage_func_show') then pv end) exposure_miniapp_pv
        ,sum(case when (event_name in ('home_content_clk_bd')  and module_type in ('miniapp','XYZ')) or event_name in ('homepage_func_click') then pv end) click_miniapp_pv
        ,sum(case when event_name in ('home_content_show_f_bd') and module_type in ('Banner','Topbanner') then pv end) exposure_banner_pv
        ,sum(case when event_name in ('home_content_clk_bd') and module_type in ('Banner','Topbanner') then pv end) click_banner_pv
        ,sum(case when event_name in ('home_content_show_f_bd') and module_type='推荐功能' then pv end) exposure_function_pv
        ,sum(case when event_name in ('home_content_clk_bd') and module_type='推荐功能' then pv end) click_function_pv
        ,sum(case when event_name in ('home_page_pop_appr_bd','popup_show') then pv end) exposure_popup_pv
        ,sum(case when event_name in ('home_page_pop_clk_bd','popup_click') then pv end) click_popup_pv
        ,sum(case when event_name in ('search_miniapp_appr_bd') then pv end) exposure_search_pv
        ,sum(case when event_name in ('search_miniapp_clk_bd') then pv end) click_search_pv

        ,sum(case when event_name in ('h5_page_event_bd','h5_page_event') and page_id in ('homepage','home_page_view') then pv end) visit_pv
        ,sum(case when event_name in ('h5_page_event_bd','h5_page_event') and page_id in ('upload_page','confirm_page_view','video_confirm_page_view','bundle_page_view1','bundle_page_view2','edit_decorate_page') then pv end) enter_generate_page_pv
        ,sum(case when event_name in ('h5_page_button_clk_bd','h5_page_button_clk') and (button_type like '%generate%' or button_type='list') then pv end) generate_pv
        ,sum(case when event_name in ('h5_page_button_clk_bd','h5_page_button_clk') and button_type like '%save%' then pv end) save_pv
        ,sum(case when event_name in ('h5_page_button_clk_bd','h5_page_button_clk') and button_type like '%share%' then pv end) share_pv

        ,sum(case when event_name in ('link_app_start_bd','link_app_start') then pv end) onelink_pv
    from
        `dataintegration-265403.temp.dws_ds_h5_page_xyz_project_event_level_pre` e
        join user_info u on e.user_pseudo_id=u.user_pseudo_id and e.event_date=u.event_date_hk and e.platform=u.platform and e.app_name=u.app_name
        left join (select Project,max(Status) status from `dataintegration-265403.temp.dwd_da_miniapp_miniapp_name_mapping` group by 1) s
        on e.project_name=s.Project
    group by
        1,2,3,4,5,6,7,8,9,10
)

-- daily+miniapp
select
    e.app_name
    ,e.event_date
    ,e.platform
    ,e.country
    ,e.is_new
    ,e.is_UA
    ,e.is_pay
    ,e.project_name
    ,e.status
    ,e.theme
    ,exposure_uv
    ,click_uv
    ,exposure_miniapp_uv
    ,click_miniapp_uv
    ,exposure_banner_uv
    ,click_banner_uv
    ,exposure_function_uv
    ,click_function_uv
    ,exposure_popup_uv
    ,click_popup_uv
    ,exposure_search_uv
    ,click_search_uv
    ,visit_uv
    ,enter_generate_page_uv
    ,generate_uv
    ,save_uv
    ,share_uv
    ,onelink_uv

    ,exposure_pv
    ,click_pv
    ,exposure_miniapp_pv
    ,click_miniapp_pv
    ,exposure_banner_pv
    ,click_banner_pv
    ,exposure_function_pv
    ,click_function_pv
    ,exposure_popup_pv
    ,click_popup_pv
    ,exposure_search_pv
    ,click_search_pv
    ,visit_pv
    ,enter_generate_page_pv
    ,generate_pv
    ,save_pv
    ,share_pv
    ,onelink_pv
from
    event_result e


