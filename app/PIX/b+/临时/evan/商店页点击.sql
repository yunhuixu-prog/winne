with event_pre as
(
    select event_date
         ,event_name
--         ,`dataintegration-265403.func`.getParams(event_params,'type').string_value type
--         ,`dataintegration-265403.func`.getParams(event_params,'button').string_value button
--         ,`dataintegration-265403.func`.getParams(event_params,'source').string_value source
--         ,`dataintegration-265403.func`.getParams(event_params,'module_type').string_value module_type
--         ,`dataintegration-265403.func`.getParams(event_params,'content_type').string_value content_type
--         ,`dataintegration-265403.func`.getParams(event_params,'from').string_value `from`
--         ,coalesce(`dataintegration-265403.func`.getParams(event_params,'子功能').string_value,
--                 `dataintegration-265403.func`.getParams(event_params,'一级子功能').string_value,
--                 `dataintegration-265403.func`.getParams(event_params,'module').string_value) function
        ,user_pseudo_id
    FROM `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-07-01','2025-07-31','beautyplus',false)
    WHERE event_name in
            ('template_shop_clk_bd','filter_store_clk_bd','sticker_shop_clk_bd','doodle_shop_clk_bd')
)


select event_name,event_date
     ,count(distinct user_pseudo_id) uv,count(1) pv
from event_pre
group by 1,2
order by 1,2