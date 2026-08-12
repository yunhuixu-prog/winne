with event as
(
    select
         event_date
        ,platform
        ,country
        ,event_name
        ,app_name
        ,version,mobile_model_name,operating_system_version
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
        `dataintegration-265403.analytics.dwd_dzp_events_function`('2024-11-01', '2024-11-09', 'beautyplus', false)
    where
        event_name in ('h5_page_event_bd','h5_page_button_clk_bd')
        and func.getParams(event_params,'project').string_value in ('AI_Pet_Portray')
)

-- select version,mobile_model_name,operating_system_version,sum(homepage) homepage,sum(nextpage) nextpage
-- from
-- (
--     select
--         event_date,e.version,e.mobile_model_name,e.operating_system_version --,e.platform,e.country
--         ,count(distinct case when event_name = 'h5_page_event_bd' and page_id='home_page_view' then e.user_pseudo_id end) homepage
--         ,count(distinct case when event_name='h5_page_event_bd' and page_id='pet_page_view' then e.user_pseudo_id end) nextpage
--     from
--         event e
--         join `dataintegration-265403.stat.stat_active_advice_detail_d` b on e.user_pseudo_id=b.user_pseudo_id and b.event_date_hk=event_date and e.app_name=b.app_name
--     where
--         hwgid not in ('2612801374','2584503074','2602108161','2588980053','2564483745','2604748400','2605846472','2579895832','2581423417','2562134868','2574054426','2618205088','2576245389','2618941525','2613607104','2563982682','2619999455','2405592903','2602265058','2564972859','2522045495','2603262761','2568172418','2400777855','2550386417','2619110102','2619987882','2612303390','2526100843','2619988205','2576247682','2567417560','2620060278','2578336951','2605846496','2551444229','2621443191')
--     group by
--         1,2,3,4
-- )
-- group by 1,2,3
-- order by 4 desc

select *
from
(
    select distinct event_date,user_pseudo_id
    from event e
    where event_name = 'h5_page_event_bd' and page_id='home_page_view'
) a
left join
(
    select distinct event_date,user_pseudo_id
    from event e
    where event_name = 'h5_page_event_bd' and page_id='pet_page_view'
) b
on a.event_date=b.event_date and a.user_pseudo_id=b.user_pseudo_id
where b.user_pseudo_id is null







select *
from  `dataintegration-265403.analytics.dwd_dzp_events_function`('2024-11-01', '2024-11-09', 'beautyplus', false)
where event_name in ('h5_page_event_bd','h5_page_button_clk_bd')
    and user_pseudo_id='0A977F3222074060B697A1C33A97AF41'
order by event_timestamp