select `dataintegration-265403.func`.getParams(event_params,'func').string_value,count(1)
    from
        `dataintegration-265403.analytics.dwd_dzp_events_function`('2024-05-04', '2024-05-05', 'beautyplus,airbrush', false)
    where event_name in ('homepage_func_show','homepage_func_click')
    -- and `dataintegration-265403.func`.getParams(event_params,'func').string_value in ('tooniverse_music_festival')
    -- limit 10
    group by 1




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
        ,`dataintegration-265403.func`.getParams(event_params,'miniapp_id').string_value miniapp_id
        ,`dataintegration-265403.func`.getParams(event_params,'func').string_value func
        ,case when app_name = 'AirBrush' then split(`dataintegration-265403.func`.getParams(event_params,'onelink_source').string_value,'=')[1]
              else `dataintegration-265403.func`.getParams(event_params,'onelink_source').string_value
         end onelink_source
        ,`dataintegration-265403.func`.getUserprop(user_properties,'UserPaymentStatus').string_value is_pay
        ,user_pseudo_id
    from
        `dataintegration-265403.analytics.dwd_dzp_events_function`('2024-04-30', '2024-05-05', 'beautyplus,airbrush', false)
    where event_name in ('homepage_func_show','homepage_func_click')
)
,
event_pre as
(
    select *
    from event_pre_raw
    where case when event_name in ('homepage_func_show','homepage_func_click') then func in (select distinct Ab_homepage_name from `dataintegration-265403.temp.dwd_da_miniapp_miniapp_name_mapping`)
            else 1=0
            end
)

    select app_name,event_name,func,count(1),count(distinct user_pseudo_id)
    from event_pre
    group by 1,2,3

    select app_name,event_date,event_name,count(1),count(distinct user_pseudo_id)
    from event_pre
    group by 1,2,3



with user_info as
(
    select
        event_date_hk
        ,app_name
        ,platform
        ,country
        ,user_pseudo_id
        ,max(is_new) is_new
        ,max(is_UA) is_UA
    from
        `dataintegration-265403.stat.stat_active_advice_detail_d`
    where
        event_date_hk between '2024-05-04' and '2024-05-07'
        and app_name in ('BeautyPlus','AirBrush')
    group by 1,2,3,4,5
)

select e.app_name,e.event_date,e.event_name,count(1),count(distinct e.user_pseudo_id)
from `dataintegration-265403.temp.dws_ds_h5_page_xyz_project_event_level_pre` e
join user_info u on e.user_pseudo_id=u.user_pseudo_id and e.event_date=u.event_date_hk and e.platform=u.platform and e.app_name=u.app_name
where event_name in ('homepage_func_show','homepage_func_click')
group by 1,2,3


select e.app_name,e.event_date,sum(exposure_uv) exposure_uv,sum(click_uv) click_uv
from `dataintegration-265403.temp.dws_ds_h5_page_xyz_project_event_level` e
where app_name='AirBrush' and project_name='AI Portrait 2.0'
group by 1,2




    select
        event_date
        ,event_name
        ,count(distinct user_pseudo_id)
        ,count(1)
    from
        `dataintegration-265403.analytics.dwd_dzp_events_function`('2024-04-30', '2024-05-08', 'beautyplus,airbrush', false)
    where
        event_name in ('h5_page_event_bd','h5_page_button_clk_bd','h5_credit_consume_bd','h5_page_event','h5_page_button_clk','h5_credit_consume')
    group by 1,2
    order by 1,2



    select event_timestamp,event_name
        ,`dataintegration-265403.func`.getParams(event_params,'project').string_value project
        ,`dataintegration-265403.func`.getParams(event_params,'page_id').string_value page_id
        ,`dataintegration-265403.func`.getParams(event_params,'button_type').string_value button_type
        ,`dataintegration-265403.func`.getParams(event_params,'machine').string_value machine
        ,`dataintegration-265403.func`.getParams(event_params,'theme').string_value theme
        ,`dataintegration-265403.func`.getParams(event_params,'photo_num').string_value photo_num
   from
        `dataintegration-265403.analytics.dwd_dzp_events_function`('2024-11-19', '2024-11-19', 'beautyplus,airbrush', false)
    where
        event_name in ('h5_page_event_bd','h5_page_button_clk_bd','h5_credit_consume_bd'
                    ,'h5_page_event','h5_page_button_clk','h5_credit_consume'
                    ,'h5_page_visit_bd','h5_page_visit'
                    ,'webview_close_bd','webview_created_bd','webview_click_bd','webview_start_fetch_bd','webview_loaded_fetch_bd'
                    'home_page_pop_clk_bd','home_page_pop_appr_bd','homepageappr_bd')
        and `dataintegration-265403.func`.getParams(event_params,'project').string_value='ai_filter'
        and user_pseudo_id='d4229ee8a34ef9198b15ae31ab3a880b'
    order by 1


select *
from
(
    select distinct project_name,user_pseudo_id
    from `dataintegration-265403.temp.dwd_ds_xyz_project_behavior` e
    where event_date='2024-11-19' and event_name in ('h5_page_visit_bd','h5_page_visit')
      and project in ('ai_filter')
) a
left join
(
    select distinct project_name,user_pseudo_id
    from `dataintegration-265403.temp.dwd_ds_xyz_project_behavior` e
    where event_date='2024-11-19' and event_name in ('h5_page_event_bd','h5_page_event')
        and page_id in ('homepage','home_page_view')
        and project in ('ai_filter')
) b
on a.user_pseudo_id=b.user_pseudo_id and a.project_name=b.project_name
where b.user_pseudo_id is null



