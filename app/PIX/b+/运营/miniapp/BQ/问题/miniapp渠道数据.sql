with event as
(
    select
        event_date
        ,platform
        ,event_timestamp
        ,event_name
        ,event_params
        ,user_properties
        ,user_pseudo_id
        ,geo.country
        ,app_info.version version
    from
        `dataintegration-265403.analytics.dwd_dzp_events_function`('2024-01-17', '2024-01-17', 'beautyplus', false)
    where
     event_name in ('h5_page_event_bd') --,'h5_effect_page_clk_bd','h5_home_page_clk_bd','h5_page_button_clk_bd','h5_page_clk_bd','h5_preview_save_bd','h5_result_share_bd','web_view_share_bd','share_page_clk_bd')
)
select event_date
    ,`dataintegration-265403.func`.getParams(event_params,'from_page').string_value from_page
    ,`dataintegration-265403.func`.getParams(event_params,'project').string_value project
    ,version
    ,count(distinct user_pseudo_id) uv
from event
where event_name in ('h5_page_event_bd')
--     and `dataintegration-265403.func`.getParams(event_params,'project').string_value='AI_Double_Photo'
    and `dataintegration-265403.func`.getParams(event_params,'page_id').string_value='home_page_view'
group by 1,2,3,4
order by 1,3,4,2


-- 异常渠道查询
with event as
(
    select
        event_date
        ,platform
        ,event_timestamp
        ,event_name
        ,event_params
        ,user_properties
        ,user_pseudo_id
        ,geo.country
        ,app_info.version version
    from
        `dataintegration-265403.analytics.dwd_dzp_events_function`('2023-12-31', '2023-12-31', 'beautyplus', false)
    where
     event_name in ('h5_page_event_bd') --,'h5_effect_page_clk_bd','h5_home_page_clk_bd','h5_page_button_clk_bd','h5_page_clk_bd','h5_preview_save_bd','h5_result_share_bd','web_view_share_bd','share_page_clk_bd')
)
-- select event_date
--     ,`dataintegration-265403.func`.getParams(event_params,'from_page').string_value from_page
--     ,`dataintegration-265403.func`.getParams(event_params,'project').string_value project
--     ,version
--     ,count(distinct user_pseudo_id)
select *
from event
where event_name in ('h5_page_event_bd')
    and `dataintegration-265403.func`.getParams(event_params,'project').string_value='AI_Double_Photo'
    and `dataintegration-265403.func`.getParams(event_params,'page_id').string_value='home_page_view'
-- group by 1,2,3,4
-- order by 1,3,4,2
    and `dataintegration-265403.func`.getParams(event_params,'from_page').string_value is null and version='7.7.023'
limit 10



