
select *
from
(
  select distinct event_date,user_pseudo_id
  from `dataintegration-265403.temp.dwd_ds_xyz_project_behavior`
  where event_date='2024-12-25' and event_name in ('h5_page_visit_bd','h5_page_visit') and project in ('AI_Pet_Portray')
) a
left join
(
  select distinct event_date,user_pseudo_id
  from `dataintegration-265403.temp.dwd_ds_xyz_project_behavior`
  where event_date='2024-12-25' and event_name in ('home_content_clk_bd','home_page_pop_clk_bd','search_miniapp_clk_bd','homepage_func_click','popup_click')
) b
on a.event_date=b.event_date and a.user_pseudo_id=b.user_pseudo_id
where b.user_pseudo_id is null




select
    app_name
    ,event_date
    ,event_timestamp
    ,event_name
    ,`dataintegration-265403.func`.getParams(event_params,'模块类型').string_value module_type
    ,`dataintegration-265403.func`.getParams(event_params,'内容类型').string_value content_type
    ,`dataintegration-265403.func`.getParams(event_params,'模块ID').string_value module_id
    ,`dataintegration-265403.func`.getParams(event_params,'内容ID').string_value content_id
    ,`dataintegration-265403.func`.getParams(event_params,'project').string_value project
from
    `dataintegration-265403.analytics.dwd_dzp_events_function`('2024-12-25', '2024-12-25', 'beautyplus', false)
where user_pseudo_id='CDB2C23B04A7474582431C30D0F0E03A'
order by event_timestamp

