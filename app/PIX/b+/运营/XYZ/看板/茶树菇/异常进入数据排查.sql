select app_name,event_date,platform,event_name,project_name,entry,user_pseudo_id,pv
from `dataintegration-265403.temp.dwd_ds_xyz_project_behavior`
where event_date between '2024-12-29' and '2024-12-31'
  and event_name='h5_page_visit_bd'
  and project in ('AI_Pet_Portray')
  and app_name='Beauty Plus Cam'

select
    app_name,event_date,platform,event_name,entry,module_type,miniapp_id,project_name
from
    `dataintegration-265403.temp.dwd_ds_xyz_project_behavior`
where event_date between '2024-12-29' and '2024-12-31'
and user_pseudo_id='ee33cb23b1a6cc433886d13bf1e90f17'
and event_name in ('home_content_show_f_bd','home_content_clk_bd','h5_page_visit_bd')
and project_name='AI Pet Portrait'



select
    app_name
    -- ,event_date
    -- ,event_timestamp
    -- ,event_name
    ,version
    ,count(1) pv
from
    `dataintegration-265403.analytics.dwd_dzp_events_function`('2024-12-29', '2024-12-31', 'beautypluscam', false)
where event_name in ('home_content_show_f_bd')
and `dataintegration-265403.func`.getParams(event_params,'内容类型').string_value='BP_KKAA_00000038'
group by 1,2
order by 1,2

