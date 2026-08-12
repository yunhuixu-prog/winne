

select a.event_date,a.platform --,a.version,a.mobile_model_name,a.operating_system_version
  ,count(distinct a.user_pseudo_id),count(distinct b.user_pseudo_id)
from
(
    select distinct event_date,user_pseudo_id,platform --,version,mobile_model_name,operating_system_version
    from  `dataintegration-265403.analytics.dwd_dzp_events_function`('2024-11-01', '2024-11-04', 'beautyplus', false)
    where (event_name in ('search_miniapp_clk_bd')
        and func.getParams(event_params, 'miniapp_id').string_value in ('BP_MIN_00000352'))
        or (event_name in ('home_content_clk_bd')
        and func.getParams(event_params, '内容类型').string_value in ('ABVC_BP_00000054','BP_KKAA_00000009'))
) a
left join
(
    select distinct event_date,user_pseudo_id,platform --,version,mobile_model_name,operating_system_version
    from  `dataintegration-265403.analytics.dwd_dzp_events_function`('2024-11-01', '2024-11-04', 'beautyplus', false)
    where event_name in ('snapid_page_event_bd')
--       and `dataintegration-265403.func`.getParams(event_params,'project').string_value='AI_Pet_Portray'
      and `dataintegration-265403.func`.getParams(event_params,'page_id').string_value in ('home_page_view')
) b
on a.event_date=b.event_date and a.user_pseudo_id=b.user_pseudo_id and a.platform=b.platform

group by 1,2 --,3,4
;



select *
from  `dataintegration-265403.analytics.dwd_dzp_events_function`('2024-11-01', '2024-11-01', 'beautyplus', false)
where event_name in ('search_miniapp_clk_bd','home_content_clk_bd','homepageappr_bd'
    ,'webview_click_bd','webview_created_bd','webview_start_fetch_bd','webview_loaded_fetch_bd','home_page_time_bd','snapid_page_event_bd','webview_close_bd')
    and user_pseudo_id='0A977F3222074060B697A1C33A97AF41'
order by event_timestamp

