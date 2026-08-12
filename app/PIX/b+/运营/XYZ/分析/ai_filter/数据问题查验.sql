-- 免费视频协议页也报的照片协议页

drop table if exists beautyplus-bc0ed.temp.temp_winne_test;
create table beautyplus-bc0ed.temp.temp_winne_test as

    select
        app_name
        ,event_date
        ,platform
        ,event_timestamp
        ,case when event_name in ('h5_page_event_bd','h5_page_event') then 'h5_page_event_bd'
              when event_name in ('h5_page_button_clk_bd','h5_page_button_clk') then 'h5_page_button_clk_bd'
              when event_name in ('h5_credit_consume_bd','h5_credit_consume') then 'h5_credit_consume_bd'
        end event_name
        ,func.getParams(event_params,'lang').string_value lang
        ,func.getParams(event_params,'project').string_value project
--         ,func.getParams(event_params,'内容ID').string_value miniapp_content_id
        ,func.getParams(event_params,'page_id').string_value page_id
        ,func.getParams(event_params,'button_type').string_value button_type
--         ,func.getParams(event_params,'is_from_push').string_value is_from_push
        ,func.getParams(event_params,'theme').string_value theme
        ,func.getParams(event_params,'theme_type').string_value theme_type
        ,coalesce(`dataintegration-265403.func`.getParams(event_params,'is_bundle').string_value,cast(`dataintegration-265403.func`.getParams(event_params,'is_bundle').int_value as string)) as is_bundle
        ,coalesce(`dataintegration-265403.func`.getParams(event_params,'is_pay').string_value,cast(`dataintegration-265403.func`.getParams(event_params,'is_pay').int_value as string)) as is_pay
        ,func.getParams(event_params,'source').string_value source
        ,cast(func.getParams(event_params,'credit_amount').string_value as int64) credit_amount
        ,func.getParams(event_params,'order_id').string_value order_id
        ,func.getUserprop(user_properties,'hwgid').string_value hwgid
        ,func.getUserprop(user_properties,'UserPaymentStatus').string_value sub_status
        ,user_pseudo_id
    from
        `dataintegration-265403.analytics.dwd_dzp_events_function`('2024-06-10', '2024-06-12', 'beautyplus,airbrush', false)
    where
        event_name in ('h5_page_event_bd','h5_page_button_clk_bd','h5_credit_consume_bd','h5_page_event','h5_page_button_clk','h5_credit_consume')
        and func.getParams(event_params,'project').string_value='ai_filter'
;

select *
from
    (select distinct event_date,user_pseudo_id from beautyplus-bc0ed.temp.temp_winne_test where event_name='h5_page_event_bd' and page_id='confirm_page_view') a
left join
    (select distinct event_date,user_pseudo_id from beautyplus-bc0ed.temp.temp_winne_test where event_name='h5_page_button_clk_bd' and button_type='upload' and theme_type='photo' and is_bundle='0') b
on a.event_date=b.event_date and a.user_pseudo_id=b.user_pseudo_id
where b.user_pseudo_id is not null



-- select * from beautyplus-bc0ed.temp.temp_winne_test where user_pseudo_id='0266bfc9fb61fd8fd62ea040614d7caf' order by event_timestamp



