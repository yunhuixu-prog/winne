

select a.event_date,a.version,a.mobile_model_name,a.operating_system_version
  ,count(distinct a.user_pseudo_id),count(distinct b.user_pseudo_id)
from
(
    select distinct event_date,event_name,user_pseudo_id,version,mobile_model_name,operating_system_version
    from  `dataintegration-265403.analytics.dwd_dzp_events_function`('2024-11-01', '2024-11-01', 'beautyplus', false)
    where event_name in ('home_page_pop_clk_bd')
        and func.getParams(event_params, 'type').string_value in ('try_it')
        and func.getParams(event_params, 'pop_id').string_value in ('BP_POP_00001600')
) a
left join
(
    select distinct event_date,'enter_homepage' event_name,user_pseudo_id,version,mobile_model_name,operating_system_version
    from  `dataintegration-265403.analytics.dwd_dzp_events_function`('2024-11-01', '2024-11-01', 'beautyplus', false)
    where event_name in ('h5_page_event_bd')
      and `dataintegration-265403.func`.getParams(event_params,'project').string_value='AI_Pet_Portray'
      and `dataintegration-265403.func`.getParams(event_params,'page_id').string_value in ('home_page_view')
      and `dataintegration-265403.func`.getParams(event_params,'from_page').string_value in ('popup')
) b
on a.event_date=b.event_date and a.user_pseudo_id=b.user_pseudo_id

group by 1,2,3,4
;



select *
from  `dataintegration-265403.analytics.dwd_dzp_events_function`('2024-11-01', '2024-11-01', 'beautyplus', false)
where event_name in ('home_page_pop_clk_bd','home_page_pop_appr_bd','homepageappr_bd'
    ,'webview_click_bd','webview_created_bd','webview_start_fetch_bd','webview_loaded_fetch_bd','home_page_time_bd','h5_page_event_bd','webview_close_bd')
    and user_pseudo_id='0A977F3222074060B697A1C33A97AF41'
order by event_timestamp

