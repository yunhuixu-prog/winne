drop table if exists `dataintegration-265403.temp.winne_dwd_ds_filter_project_position`;
create table if not exists `dataintegration-265403.temp.winne_dwd_ds_filter_project_position` as

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
    ,coalesce(func.getParams(event_params,'content_position').string_value,cast(func.getParams(event_params,'content_position').int_value as string)) content_position
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
    `dataintegration-265403.analytics.dwd_dzp_events_function`('2024-11-01', '2024-12-31', 'beautyplus,airbrush,beautypluscam', false)
where
    event_name in ('h5_page_button_clk_bd','h5_page_button_clk','h5_home_content_clk_bd','h5_home_content_clk','h5_home_content_show_f_bd','h5_home_content_show_f')
    and func.getParams(event_params,'project').string_value in ('ai_filter')
    and
        case when event_name in ('h5_home_content_clk_bd','h5_home_content_clk','h5_home_content_show_f_bd','h5_home_content_show_f') then func.getParams(event_params,'page_id').string_value in ('home_page_view')
             when event_name in ('h5_page_button_clk_bd','h5_page_button_clk') then func.getParams(event_params,'button_type').string_value in ('upload')
        else 1=1
        end

;

select
    e.app_name,e.event_date,e.module_position,e.content_position
    ,count(distinct case when event_name in ('h5_home_content_show_f_bd','h5_home_content_show_f') then e.user_pseudo_id end) exp_uv
    ,count(distinct case when event_name in ('h5_home_content_clk_bd','h5_home_content_clk') then e.user_pseudo_id end) clk_uv
from
    `dataintegration-265403.temp.winne_dwd_ds_filter_project_position` e
join `dataintegration-265403.stat.stat_active_advice_detail_d` b
on e.event_date=b.event_date_hk and e.app_name=b.app_name and e.user_pseudo_id=b.user_pseudo_id
where
    event_name in ('h5_home_content_clk_bd','h5_home_content_clk','h5_home_content_show_f_bd','h5_home_content_show_f')
group by
    1,2,3,4
;

