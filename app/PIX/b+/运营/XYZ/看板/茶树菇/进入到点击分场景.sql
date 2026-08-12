
select a.event_date,a.platform,a.entry,a.miniapp_id
    ,count(distinct a.user_pseudo_id) click_uv
    ,count(distinct b.user_pseudo_id) visit_uv
from
(
  select distinct event_date,platform,user_pseudo_id
        ,case when event_name='home_content_clk_bd' and module_type in ('Banner') then 'banner'
             when event_name='home_content_clk_bd' and module_type in ('Topbanner') then 'topbanner'
             when event_name='home_content_clk_bd' and module_type in ('推荐功能') then 'topbar'
             when event_name='home_content_clk_bd' and module_type in ('XYZ') then 'AIcreativity'
             when event_name='home_page_pop_clk_bd' then 'pop'
        else 'other' end entry,miniapp_id
  from `dataintegration-265403.temp.dwd_ds_xyz_project_behavior`
  where event_date between '2025-01-01' and '2025-02-10'
    and event_name in ('home_content_clk_bd','home_page_pop_clk_bd','search_miniapp_clk_bd')
    and project_name in ('AI Filter 1.0')
    and app_name = 'BeautyPlus'
    and source='H5'
) a
left join
(
  select distinct event_date,platform,user_pseudo_id
--         ,case when entry in ('banner','topbanner','topbar','AIcreativity') then entry
--             else 'other' end entry
  from `dataintegration-265403.temp.dwd_ds_xyz_project_behavior`
  where event_date between '2025-01-01' and '2025-02-10'
    and event_name in ('h5_page_visit_bd','h5_page_visit')
    and project_name in ('AI Filter 1.0')
    and app_name = 'BeautyPlus'
    and source='H5'
) b
on a.event_date=b.event_date and a.user_pseudo_id=b.user_pseudo_id --and a.entry=b.entry
group by 1,2,3,4
order by 1,2,3,4


-- 用户粒度查询
select a.*
from
(
  select distinct event_date,platform,user_pseudo_id
        ,case when event_name='home_content_clk_bd' and module_type in ('Banner') then 'banner'
             when event_name='home_content_clk_bd' and module_type in ('Topbanner') then 'topbanner'
             when event_name='home_content_clk_bd' and module_type in ('推荐功能') then 'topbar'
             when event_name='home_content_clk_bd' and module_type in ('XYZ') then 'AIcreativity'
             when event_name='home_page_pop_clk_bd' then 'pop'
        else 'other' end entry
  from `dataintegration-265403.temp.dwd_ds_xyz_project_behavior`
  where event_date between '2025-01-15' and '2025-01-15'
    and event_name in ('home_content_clk_bd','home_page_pop_clk_bd','search_miniapp_clk_bd')
    and project_name in ('AI Filter 1.0')
    and app_name = 'BeautyPlus'
    and source='H5'
) a
left join
(
  select distinct event_date,platform,user_pseudo_id
--         ,case when entry in ('banner','topbanner','topbar','AIcreativity') then entry
--             else 'other' end entry
  from `dataintegration-265403.temp.dwd_ds_xyz_project_behavior`
  where event_date between '2025-01-15' and '2025-01-15'
    and event_name in ('h5_page_visit_bd','h5_page_visit')
    and project_name in ('AI Filter 1.0')
    and app_name = 'BeautyPlus'
    and source='H5'
) b
on a.event_date=b.event_date and a.user_pseudo_id=b.user_pseudo_id --and a.entry=b.entry
where b.user_pseudo_id is null

;

select
    app_name
    ,event_date
    ,platform
    ,event_timestamp
    ,event_name
    ,`dataintegration-265403.func`.getParams(event_params,'模块类型').string_value module_type
    ,`dataintegration-265403.func`.getParams(event_params,'内容类型').string_value content_type
    ,`dataintegration-265403.func`.getParams(event_params,'模块ID').string_value module_id
    ,`dataintegration-265403.func`.getParams(event_params,'内容ID').string_value content_id
    ,`dataintegration-265403.func`.getParams(event_params,'pop_id').string_value content_id
    ,`dataintegration-265403.func`.getParams(event_params,'type').string_value project
    ,`dataintegration-265403.func`.getParams(event_params,'url').string_value url
    ,`dataintegration-265403.func`.getParams(event_params,'page_id').string_value page_id
from
    `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-01-15', '2025-01-15', 'beautyplus', false)
where event_name in ('home_content_show_f_bd','home_content_clk_bd','home_page_pop_appr_bd','home_page_pop_clk_bd'
                        ,'h5_home_content_show_f_bd','h5_home_content_clk_bd'
                        ,'h5_page_visit_bd','h5_page_visit'
                        ,'h5_page_event_bd','h5_page_event'
                        ,'h5_page_button_clk_bd','h5_page_button_clk'
                        ,'webview_close_bd','webview_created_bd','webview_click_bd','webview_start_fetch_bd','webview_loaded_fetch_bd'
                    )
    and user_pseudo_id='AC1A8C3EBE1D4B99A2A240057020F833'
order by event_timestamp



