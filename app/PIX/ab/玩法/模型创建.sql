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
    ,`dataintegration-265403.func`.getUserprop(user_properties,'hwgid').string_value hwgid
    ,user_pseudo_id
    ,geo.country
from
    `dataintegration-265403.analytics.dwd_dzp_events_function`('2024-01-01', '2025-12-10', 'airbrush', false)
where
    event_name in ('h5_page_button_clk')
    and `dataintegration-265403.func`.getParams(event_params,'button_type').string_value in ('model_upload','model_train')
    and `dataintegration-265403.func`.getParams(event_params,'project').string_value = 'ai_portrait'

;
select button_type,count(distinct user_pseudo_id) uv,count(1) pv
from `dataintegration-265403.temp.winne_temp_dwd_ds_xyz_project_behavior`
group by 1