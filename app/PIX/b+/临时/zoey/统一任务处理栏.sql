

select
    app_name
    ,event_date
    ,platform
    ,event_name
--     ,`dataintegration-265403.func`.getParams(event_params,'project').string_value category1
    ,cast(null as string) category1
    ,`dataintegration-265403.func`.getParams(event_params,'button_type').string_value category2
--     ,cast(null as string) category2
    ,count(distinct user_pseudo_id) uv
    ,count(1) pv
from
    `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-03-21', '2025-04-20', 'beautyplus', false)
where
    event_name in ('h5_page_button_clk_bd','h5_page_button_clk')
  and `dataintegration-265403.func`.getParams(event_params,'page_id').string_value='task_manager'
  and `dataintegration-265403.func`.getParams(event_params,'button_type').string_value in ('save','retouch')
group by 1,2,3,4,5,6

union all

select
    app_name
    ,event_date
    ,platform
    ,event_name
--     ,`dataintegration-265403.func`.getParams(event_params,'module').string_value category1
    ,cast(null as string) category1
    ,cast(null as string) category2
    ,count(distinct user_pseudo_id) uv
    ,count(1) pv
from
    `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-03-21', '2025-04-20', 'beautyplus', false)
where
    event_name in ('save_page_clk_bd')
  and `dataintegration-265403.func`.getParams(event_params,'clk_icon').string_value='加入作品'
group by 1,2,3,4,5,6

union all

select
    app_name
    ,event_date
    ,platform
    ,event_name
    ,cast(null as string) category1
    ,cast(null as string) category2
    ,count(distinct user_pseudo_id) uv
    ,count(1) pv
from
    `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-03-21', '2025-04-20', 'beautyplus', false)
where
    event_name in ('personal_porfolio_page_works_clk_bd')
group by 1,2,3,4,5,6
