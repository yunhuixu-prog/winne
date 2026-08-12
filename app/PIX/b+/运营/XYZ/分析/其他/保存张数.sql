with
event_pre_raw as
(
   select
        app_name
        ,event_date
        ,event_name
        ,platform
        ,coalesce(app_info.version,'unknown') version
        ,`dataintegration-265403.func`.getParams(event_params,'project').string_value project
        ,`dataintegration-265403.func`.getParams(event_params,'模块类型').string_value module_type
        ,`dataintegration-265403.func`.getParams(event_params,'模块ID').string_value module_id
        ,`dataintegration-265403.func`.getParams(event_params,'内容类型').string_value content_type
        ,`dataintegration-265403.func`.getParams(event_params,'内容ID').string_value content_id
        ,`dataintegration-265403.func`.getParams(event_params,'from_page').string_value from_page
        ,`dataintegration-265403.func`.getParams(event_params,'page_id').string_value page_id
        ,`dataintegration-265403.func`.getParams(event_params,'button_type').string_value button_type
        ,coalesce(cast(`dataintegration-265403.func`.getParams(event_params,'photo_num').string_value as int64),`dataintegration-265403.func`.getParams(event_params,'photo_num').int_value) as photo_num
        ,`dataintegration-265403.func`.getParams(event_params,'miniapp_id').string_value miniapp_id
        ,`dataintegration-265403.func`.getParams(event_params,'func').string_value func
        ,`dataintegration-265403.func`.getParams(event_params,'pop_id').string_value pop_id
        ,`dataintegration-265403.func`.getParams(event_params,'theme').string_value theme
        ,`dataintegration-265403.func`.getParams(event_params,'theme_type').string_value theme_type
        ,`dataintegration-265403.func`.getUserprop(user_properties,'UserPaymentStatus').string_value is_pay
        ,user_pseudo_id
    from
        `dataintegration-265403.analytics.dwd_dzp_events_function`('2024-06-01', '2024-06-18', 'beautyplus,airbrush', false)
    where event_name in ('h5_page_event_bd','h5_page_event'
                        ,'h5_page_button_clk_bd','h5_page_button_clk')
)
,
event_pre as
(
    select *
    from event_pre_raw
    where case when event_name in ('h5_page_event_bd','h5_page_event') then page_id in ('homepage','home_page_view') and project in (select distinct H5_name from `dataintegration-265403.temp.dwd_da_miniapp_miniapp_name_mapping`)
            when event_name in ('h5_page_button_clk_bd','h5_page_button_clk') then button_type in ('save','save_all') and project in (select distinct H5_name from `dataintegration-265403.temp.dwd_da_miniapp_miniapp_name_mapping`)
            end
)

select event_date,app_name
    ,count(distinct case when event_name in ('h5_page_event_bd','h5_page_event') and page_id in ('homepage','home_page_view') then user_pseudo_id end) visit_uv
    ,count(distinct case when event_name in ('h5_page_button_clk_bd','h5_page_button_clk') and button_type like '%save%' then user_pseudo_id end) save_uv
    ,count(case when event_name in ('h5_page_button_clk_bd','h5_page_button_clk') and button_type like '%save%' then 1 end) save_pv
    ,sum(case when event_name in ('h5_page_button_clk_bd','h5_page_button_clk') and button_type = 'save' then 1
              when event_name in ('h5_page_button_clk_bd','h5_page_button_clk') and button_type = 'save_all' then photo_num end) save_photo_num
from event_pre
group by 1,2
order by 1,2



