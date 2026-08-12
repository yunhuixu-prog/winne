with event as
(
    select
        app_name
        ,event_date
        ,event_name
        ,platform
        ,coalesce(app_info.version,'unknown') version
        ,`dataintegration-265403.func`.getParams(event_params,'page_id').string_value page_id
        ,`dataintegration-265403.func`.getParams(event_params,'button_type').string_value button_type
        ,`dataintegration-265403.func`.getParams(event_params,'task_id').string_value task_id
        ,`dataintegration-265403.func`.getParams(event_params,'save_type').string_value save_type
        ,`dataintegration-265403.func`.getParams(event_params,'theme').string_value theme
        ,`dataintegration-265403.func`.getParams(event_params,'theme_type').string_value theme_type
        ,`dataintegration-265403.func`.getUserprop(user_properties,'UserPaymentStatus').string_value is_pay
        ,user_pseudo_id
    from
        `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-09-01', '2025-09-02', 'airbrush', false)
    where event_name in ('h5_page_event','h5_page_button_clk'
                        'h5_home_content_show_f','h5_home_content_clk'
                        )
    and  `dataintegration-265403.func`.getParams(event_params,'project').string_value='ai_filter'
    and `dataintegration-265403.func`.getParams(event_params,'theme').string_value like '%FigMe%'
)
-- select *
select event_date,count(distinct user_pseudo_id) uv,count(1) pv
from event
where button_type in ('generate','list','retry','upload_new','to_video') and coalesce(task_id,'-')!='no_task'
group by 1
order by 1
;



select event_name,platform,event_timestamp,user_pseudo_id,app_info.version
    ,func.getParams(event_params,'source_module').string_value as source_module
    ,func.getParams(event_params,'source_0').string_value as source_0
    ,func.getParams(event_params,'source_1').string_value as source_1
from `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-09-01','2025-09-02','airbrush',false)
where
    event_name in ('w_subscription_enter','w_subscription_click','w_subscription_success')
    and func.getParams(event_params,'source_1').string_value like '%FigMe%'




