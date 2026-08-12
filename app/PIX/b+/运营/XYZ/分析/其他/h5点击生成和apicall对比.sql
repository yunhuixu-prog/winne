-- 用户生成次数分布

select 'ai filter' project,cast(timestamp_add(created_at, interval 8 hour) as date) date
    ,count(distinct gid) uv,count(1) api_call
from dataintegration-265403.aigc.ods_da_aigc_filter_artwork_xyz
where cast(timestamp_add(created_at, interval 8 hour) as date)>='2024-08-08'
group by 1,2
order by 1,2
;

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
        ,`dataintegration-265403.func`.getParams(event_params,'from_page').string_value from_page
        ,`dataintegration-265403.func`.getParams(event_params,'page_id').string_value page_id
        ,`dataintegration-265403.func`.getParams(event_params,'button_type').string_value button_type
        ,`dataintegration-265403.func`.getParams(event_params,'task_id').string_value task_id
        ,`dataintegration-265403.func`.getParams(event_params,'if_first').string_value if_first
        ,`dataintegration-265403.func`.getParams(event_params,'theme').string_value theme
        ,`dataintegration-265403.func`.getParams(event_params,'theme_type').string_value theme_type
        ,`dataintegration-265403.func`.getUserprop(user_properties,'UserPaymentStatus').string_value is_pay
        ,user_pseudo_id
    from
        `dataintegration-265403.analytics.dwd_dzp_events_function`('2024-08-13', '2024-08-13', 'beautyplus,airbrush,beautypluscam', false)
    where event_name in ('h5_page_button_clk_bd','h5_page_button_clk')
)

select app_name,event_date
     ,count(distinct user_pseudo_id) click_generate_uv
     ,count(distinct case when task_id!='no_task' then user_pseudo_id end) generate_uv
     ,count(1) click_generate_pv
     ,count(distinct case when task_id!='no_task' then task_id end) generate_pv
from event_pre_raw
where case when event_name in ('h5_page_button_clk_bd','h5_page_button_clk') then
        button_type in ('generate','list','retry','upload_new','to_video')
        and project = 'ai_filter'
    end
group by 1,2
order by 1,2






