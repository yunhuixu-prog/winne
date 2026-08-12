-- `dataintegration-265403.temp.dws_ds_xyz_project_behavior_overall_v`
select
    app_name
    ,date
    ,platform
    ,country
    ,is_new
    ,is_ua
    ,project_name
    ,status
    ,entry
    ,source
    ,'uv' data_type
    ,exposure_uv exposure
    ,click_uv click
    ,exposure_miniapp_uv exposure_miniapp
    ,click_miniapp_uv click_miniapp
    ,exposure_banner_uv exposure_banner
    ,click_banner_uv click_banner
    ,exposure_function_uv exposure_function
    ,click_function_uv click_function
    ,exposure_popup_uv exposure_popup
    ,click_popup_uv click_popup
    ,exposure_search_uv exposure_search
    ,click_search_uv click_search

    ,visit_uv visit
    ,enter_generate_page_uv enter_generate_page
    ,click_generate_uv click_generate
    ,save_uv save
    ,share_uv share
    ,onelink_uv onelink
    ,sub_uv sub
    ,sub_pay_uv sub_pay
    ,sub_revenue sub_revenue
    ,generate_photo_num
    ,save_photo_num
    ,click_generate_uv click_generate_change
    ,save_uv save_change
from
    `dataintegration-265403.temp.dws_ds_xyz_project_behavior_overall`
where project_name not in ('Tooniverse','iPhone Cam')

union all

select
    app_name
    ,date
    ,platform
    ,country
    ,is_new
    ,is_ua
    ,project_name
    ,status
    ,entry
    ,source
    ,'pv' data_type
    ,exposure_pv exposure
    ,click_pv click
    ,exposure_miniapp_pv exposure_miniapp
    ,click_miniapp_pv click_miniapp
    ,exposure_banner_pv exposure_banner
    ,click_banner_pv click_banner
    ,exposure_function_pv exposure_function
    ,click_function_pv click_function
    ,exposure_popup_pv exposure_popup
    ,click_popup_pv click_popup
    ,exposure_search_pv exposure_search
    ,click_search_pv click_search

    ,visit_pv visit
    ,enter_generate_page_pv enter_generate_page
    ,click_generate_pv click_generate
    ,save_pv save
    ,share_pv share
    ,onelink_pv onelink
    ,sub_uv sub
    ,sub_pay_uv sub_pay
    ,sub_revenue sub_revenue
    ,generate_photo_num
    ,save_photo_num
    ,generate_photo_num click_generate_change
    ,save_photo_num save_change
from
    `dataintegration-265403.temp.dws_ds_xyz_project_behavior_overall`
where project_name not in ('Tooniverse','iPhone Cam')

