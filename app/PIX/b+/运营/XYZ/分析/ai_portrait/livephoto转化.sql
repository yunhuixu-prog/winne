drop table if exists `dataintegration-265403.temp.temp_ai_portrait`;
create table `dataintegration-265403.temp.temp_ai_portrait` as

(
   select
        app_name
        ,event_date
        ,event_name
        ,platform
        ,`dataintegration-265403.func`.getParams(event_params,'project').string_value project
        ,`dataintegration-265403.func`.getParams(event_params,'button_type').string_value button_type
        ,`dataintegration-265403.func`.getParams(event_params,'task_id').string_value task_id
        ,`dataintegration-265403.func`.getParams(event_params,'style_id').string_value style_id
        ,`dataintegration-265403.func`.getParams(event_params,'theme').string_value theme
        ,`dataintegration-265403.func`.getParams(event_params,'theme_type').string_value theme_type
        ,user_pseudo_id
    from
        `dataintegration-265403.analytics.dwd_dzp_events_function`('2024-09-28', '2024-10-07', 'beautyplus,airbrush,beautypluscam', false)
    where event_name in ('h5_page_button_clk_bd','h5_page_button_clk')
    and `dataintegration-265403.func`.getParams(event_params,'project').string_value = 'ai_portrait'
)
;

select *
from
(
    select '1:photo generate' event_name,app_name,event_date,count(distinct user_pseudo_id) uv,count(1) pv
    from `dataintegration-265403.temp.temp_ai_portrait`
    where theme = 'Joker Smile' and button_type='generate'
    group by 1,2,3

    union all

    select '2:photo see' event_name,app_name,event_date,count(distinct user_pseudo_id) uv,count(1) pv
    from `dataintegration-265403.temp.temp_ai_portrait`
    where theme = 'Joker Smile' and button_type='thumbnail'
    group by 1,2,3

    union all

    select '3:photo to live' event_name,app_name,event_date,count(distinct user_pseudo_id) uv,count(1) pv
    from `dataintegration-265403.temp.temp_ai_portrait`
    where theme = 'Joker Smile' and button_type='to_video'
    group by 1,2,3

    union all

    select '4:live photo save' event_name,app_name,event_date,count(distinct user_pseudo_id) uv,count(1) pv
    from `dataintegration-265403.temp.temp_ai_portrait`
    where theme = 'live portrait' and button_type in ('save','save_all')
    group by 1,2,3
)
order by 3,1,2