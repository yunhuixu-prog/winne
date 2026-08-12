with
event_pre as
(
   select
        app_name
        ,event_date
        ,event_name
        ,platform
        ,`dataintegration-265403.func`.getParams(event_params,'project').string_value project
        ,`dataintegration-265403.func`.getParams(event_params,'from_page').string_value from_page
        ,`dataintegration-265403.func`.getParams(event_params,'page_id').string_value page_id
        ,`dataintegration-265403.func`.getParams(event_params,'button_type').string_value button_type
        ,`dataintegration-265403.func`.getParams(event_params,'task_id').string_value task_id
        ,`dataintegration-265403.func`.getParams(event_params,'save_type').string_value save_type
        ,`dataintegration-265403.func`.getParams(event_params,'theme').string_value theme
        ,`dataintegration-265403.func`.getParams(event_params,'theme_type').string_value theme_type
        ,`dataintegration-265403.func`.getUserprop(user_properties,'UserPaymentStatus').string_value is_pay
        ,user_pseudo_id
    from
        `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-03-20', '2025-04-19', 'beautyplus,airbrush,beautypluscam', false)
    where event_name in ('h5_page_button_clk_bd','h5_page_button_clk')
)
,
user_info as
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
        event_date_hk between '2025-03-20' and '2025-04-19'
        and app_name in ('BeautyPlus','AirBrush','Beauty Plus Cam')
    group by 1,2,3,4,5
)

select a.event_date,a.app_name,b.save_type,generate_uv,generate_pv,save_uv,save_pv
from
(
    select e.event_date,e.app_name
        ,count(distinct e.user_pseudo_id) generate_uv
        ,count(1) generate_pv
    from event_pre e
    join user_info u on e.user_pseudo_id=u.user_pseudo_id and e.event_date=u.event_date_hk and e.platform=u.platform and e.app_name=u.app_name
    where project = 'ai_filter' and button_type in ('non_zero_generate_upload','zero_generate_upload','non_zero_generate','zero_generate','generate'
                            ,'list','retry','upload_new','to_video') and coalesce(task_id,'-')!='no_task'
    group by 1,2
) a
left join
(
    select e.event_date,e.app_name,e.save_type
        ,count(distinct e.user_pseudo_id) save_uv
        ,count(1) save_pv
    from event_pre e
    join user_info u on e.user_pseudo_id=u.user_pseudo_id and e.event_date=u.event_date_hk and e.platform=u.platform and e.app_name=u.app_name
    where button_type in ('save') and project = 'ai_filter' and save_type is not null
    group by 1,2,3
) b
on a.event_date=b.event_date and a.app_name=b.app_name









