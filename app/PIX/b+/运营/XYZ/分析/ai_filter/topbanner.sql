with event as
(
    select
         event_date
        ,platform
        ,country
        ,event_name
        ,app_name
        ,func.getParams(event_params,'lang').string_value lang
        ,func.getParams(event_params,'project').string_value project
        ,func.getParams(event_params,'内容ID').string_value miniapp_content_id
        ,func.getParams(event_params,'page_id').string_value page_id
        ,func.getParams(event_params,'button_type').string_value button_type
        ,coalesce(func.getParams(event_params,'module_position').string_value,cast(func.getParams(event_params,'module_position').int_value as string)) module_position
        ,func.getParams(event_params,'theme_type').string_value theme_type
        ,func.getParams(event_params,'is_from_push').string_value is_from_push
        ,coalesce(func.getParams(event_params,'from_page').string_value,func.getParams(event_params,'entry').string_value) from_page
        ,func.getParams(event_params,'theme').string_value theme
        ,func.getParams(event_params,'url').string_value url
        ,func.getParams(event_params,'source').string_value source
        ,func.getParams(event_params,'credit_amount').string_value credit_amount
        ,func.getParams(event_params,'order_id').string_value order_id
        ,func.getUserprop(user_properties,'hwgid').string_value hwgid
        ,user_pseudo_id
    from
        -- `beautyplus-bc0ed.analytics.ods_dz_events_tv`('2023-10-16', '2023-10-30')
        `dataintegration-265403.analytics.dwd_dzp_events_function`('2024-07-01', '2024-11-03', 'beautyplus', false)
    where
        event_name in ('h5_page_button_clk_bd','h5_page_button_clk','h5_home_content_clk_bd','h5_home_content_clk','h5_home_content_show_f_bd','h5_home_content_show_f')
        and func.getParams(event_params,'project').string_value in ('ai_filter')
        and
            case when event_name in ('h5_home_content_clk_bd','h5_home_content_clk','h5_home_content_show_f_bd','h5_home_content_show_f') then func.getParams(event_params,'page_id').string_value in ('home_page_view')
                 when event_name in ('h5_page_button_clk_bd','h5_page_button_clk') then func.getParams(event_params,'button_type').string_value in ('upload')
            else 1=1
            end
)


-- select
--     e.app_name,event_date,e.platform
--     ,count(distinct case when event_name in ('h5_page_button_clk_bd','h5_page_button_clk','h5_home_content_clk_bd','h5_home_content_clk') then e.user_pseudo_id end) theme_click
--     ,count(distinct case when event_name in ('h5_page_button_clk_bd','h5_page_button_clk') then e.user_pseudo_id end) theme_click_1
--     ,count(distinct case when event_name in ('h5_home_content_clk_bd','h5_home_content_clk') then e.user_pseudo_id end) theme_click_2
--     ,count(distinct case when event_name in ('h5_home_content_clk_bd','h5_home_content_clk') and module_position='0' then e.user_pseudo_id end) theme_topbanner_click
-- from
--     event e
--     join `dataintegration-265403.stat.stat_active_advice_detail_d` b on e.user_pseudo_id=b.user_pseudo_id and b.event_date_hk=event_date and e.app_name=b.app_name
-- where
--     hwgid not in ('2612801374','2584503074','2602108161','2588980053','2564483745','2604748400','2605846472','2579895832','2581423417','2562134868','2574054426','2618205088','2576245389','2618941525','2613607104','2563982682','2619999455','2405592903','2602265058','2564972859','2522045495','2603262761','2568172418','2400777855','2550386417','2619110102','2619987882','2612303390','2526100843','2619988205','2576247682','2567417560','2620060278','2578336951','2605846496','2551444229','2621443191')
-- group by
--     1,2,3
--
-- ;

select
    e.app_name,event_date,e.platform,e.theme
    ,count(distinct case when event_name in ('h5_home_content_show_f_bd','h5_home_content_show_f') then e.user_pseudo_id end) theme_exp
    ,count(distinct case when event_name in ('h5_home_content_clk_bd','h5_home_content_clk') then e.user_pseudo_id end) theme_click
from
    event e
    join `dataintegration-265403.stat.stat_active_advice_detail_d` b on e.user_pseudo_id=b.user_pseudo_id and b.event_date_hk=event_date and e.app_name=b.app_name
where
    hwgid not in ('2612801374','2584503074','2602108161','2588980053','2564483745','2604748400','2605846472','2579895832','2581423417','2562134868','2574054426','2618205088','2576245389','2618941525','2613607104','2563982682','2619999455','2405592903','2602265058','2564972859','2522045495','2603262761','2568172418','2400777855','2550386417','2619110102','2619987882','2612303390','2526100843','2619988205','2576247682','2567417560','2620060278','2578336951','2605846496','2551444229','2621443191')
    and event_name in ('h5_home_content_clk_bd','h5_home_content_clk','h5_home_content_show_f_bd','h5_home_content_show_f')
    and module_position='0'
group by
    1,2,3,4
;

