with
event_pre_raw as
(
   select
        app_name
        ,event_date
        ,event_name
        ,platform
        ,coalesce(app_info.version,'unknown') version
        ,case when `dataintegration-265403.func`.getParams(event_params,'project').string_value='BeautyPlus - PuriPlus' then 'puriplus'
            else `dataintegration-265403.func`.getParams(event_params,'project').string_value end project
        ,`dataintegration-265403.func`.getParams(event_params,'模块类型').string_value module_type
        ,`dataintegration-265403.func`.getParams(event_params,'模块ID').string_value module_id
        ,`dataintegration-265403.func`.getParams(event_params,'内容类型').string_value content_type
        ,`dataintegration-265403.func`.getParams(event_params,'内容ID').string_value content_id
        ,`dataintegration-265403.func`.getParams(event_params,'entry').string_value entry
        ,`dataintegration-265403.func`.getParams(event_params,'page_id').string_value page_id
        ,`dataintegration-265403.func`.getParams(event_params,'button_type').string_value button_type
        ,`dataintegration-265403.func`.getParams(event_params,'task_id').string_value task_id
        ,`dataintegration-265403.func`.getParams(event_params,'miniapp_id').string_value miniapp_id
        ,`dataintegration-265403.func`.getParams(event_params,'func').string_value func
        ,`dataintegration-265403.func`.getParams(event_params,'pop_id').string_value pop_id
        ,`dataintegration-265403.func`.getParams(event_params,'style_id').string_value style_id
        ,`dataintegration-265403.func`.getParams(event_params,'machine').string_value machine
        ,`dataintegration-265403.func`.getParams(event_params,'theme').string_value theme
        ,`dataintegration-265403.func`.getParams(event_params,'theme_type').string_value theme_type
        ,`dataintegration-265403.func`.getParams(event_params,'material_type').string_value material_type
        ,`dataintegration-265403.func`.getParams(event_params,'material_id').string_value material_id
        ,`dataintegration-265403.func`.getParams(event_params,'prf_first_func').string_value prf_first_func
        ,`dataintegration-265403.func`.getParams(event_params,'source_0').string_value source_0
        ,`dataintegration-265403.func`.getParams(event_params,'module_position').string_value module_position
        ,case when app_name = 'AirBrush' then split(`dataintegration-265403.func`.getParams(event_params,'onelink_source').string_value,'=')[1]
              else `dataintegration-265403.func`.getParams(event_params,'onelink_source').string_value
         end onelink_source
        ,`dataintegration-265403.func`.getUserprop(user_properties,'UserPaymentStatus').string_value is_pay
        ,user_pseudo_id
    from
        `dataintegration-265403.analytics.dwd_dzp_events_function`('{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}', '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}', 'beautyplus,airbrush,beautypluscam', false)
    where event_name in ('h5_page_event_bd','h5_page_event'
                        ,'h5_page_button_clk_bd','h5_page_button_clk'
                        )
)

select *
from event_pre_raw
where case when event_name in ('h5_page_event_bd','h5_page_event') then page_id in ('homepage','home_page_view') and project in (select distinct H5_name from `dataintegration-265403.temp.dwd_da_miniapp_miniapp_name_mapping`)
        when event_name in ('h5_page_button_clk_bd','h5_page_button_clk') then button_type in ('non_zero_generate','zero_generate','generate','list','save','save_all','share','image','frame','retry','upload_new','to_video') and project in (select distinct H5_name from `dataintegration-265403.temp.dwd_da_miniapp_miniapp_name_mapping`)
        else 1=0
        end



