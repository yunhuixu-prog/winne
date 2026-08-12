drop table if exists `dataintegration-265403.temp.temp_xyz_loudou`;
create table if not exists `dataintegration-265403.temp.temp_xyz_loudou` as

with event as
(
    select
        event_date
        ,platform
        ,app_name
        ,event_timestamp
        ,event_name
        ,event_params
        ,user_properties
        ,user_pseudo_id
        ,geo.country
    from
        -- `beautyplus-bc0ed.analytics.ods_dz_events_tv`('2023-10-16', '2023-10-30')
        `dataintegration-265403.analytics.dwd_dzp_events_function`('2024-11-01', '2024-11-09', 'beautyplus,airbrush', false)
    where
        event_name in ('h5_page_event_bd','h5_page_event','h5_page_button_clk_bd','h5_page_button_clk','h5_page_view_bd','h5_page_view','h5_credit_consume_bd')
)
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
    event
where
    case    when event_name in ('h5_page_event_bd','h5_page_event','h5_page_view_bd','h5_page_view','h5_page_button_clk_bd','h5_page_button_clk','h5_credit_consume_bd')
                    then func.getParams(event_params,'project').string_value in ('AI_Pet_Portray','ai_filter','ai_portrait')
            else 1=0
            end
;

select
    e.app_name,event_date,from_page,project,e.platform
    ,case
            when event_name in ('h5_page_event_bd','h5_page_event') and page_id in ('home_page_view','homepage') then '1 进入首页'
            when event_name in ('h5_page_event_bd','h5_page_event') and project='AI_Pet_Portray' and page_id='pet_page_view' then '2 AI Pet Portrait-进入宠物选择页'
            when event_name='h5_page_event_bd' and project='AI_Pet_Portray' and page_id='guide_page_view' then '3 AI Pet Portrait-进入图片提示页'
            when event_name='h5_page_event_bd' and project='AI_Pet_Portray' and page_id='album_page_view' then '4 AI Pet Portrait-进入相册页'

--             when event_name in ('h5_page_button_clk_bd','h5_page_button_clk') and project='ai_filter' and button_type='upload' then '2 AI Filter-点击首页素材'
            when event_name in ('h5_page_event_bd','h5_page_event') and project='ai_filter' and page_id='album_page_view' then '2 AI Filter-进入相册页'
            when event_name in ('h5_page_event_bd','h5_page_event') and project='ai_filter' and page_id in ('bundle_page_view1','bundle_page_view2','confirm_page_view','video_confirm_page_view') then '3 AI Filter-进入照片确认页'

--             when event_name in ('h5_page_button_clk_bd','h5_page_button_clk') and project='ai_portrait' and button_type='image' then '2 AI Portrait-点击首页素材'
            when event_name in ('h5_page_view_bd','h5_page_view') and project='ai_portrait' and page_id='style_page' then '2 AI Portrait-进入风格生成页'
            when event_name in ('h5_page_event_bd','h5_page_event') and project='ai_portrait' and page_id='model_create_page' then '3 AI Portrait-进入模型创建页'
            when event_name in ('h5_page_button_clk_bd','h5_page_button_clk') and project='ai_portrait' and button_type='model_upload' then '4 AI Portrait-上传模型'
            when event_name in ('h5_page_button_clk_bd','h5_page_button_clk') and project='ai_portrait' and button_type='model_train' then '5 AI Portrait-训练模型'

            when event_name in ('h5_page_button_clk_bd','h5_page_button_clk') and button_type='generate' then 'last 生成效果'
            else event_name
            end ch_event_name
    -- ,page_id
    -- ,button_type
    -- ,theme
    ,null visit_uv
    ,count(distinct e.user_pseudo_id) uv
    ,count(1) pv
from
    `dataintegration-265403.temp.temp_xyz_loudou` e
    join `dataintegration-265403.stat.stat_active_advice_detail_d` b on e.user_pseudo_id=b.user_pseudo_id and b.event_date_hk=event_date and e.app_name=b.app_name
where
    hwgid not in ('2612801374','2584503074','2602108161','2588980053','2564483745','2604748400','2605846472','2579895832','2581423417','2562134868','2574054426','2618205088','2576245389','2618941525','2613607104','2563982682','2619999455','2405592903','2602265058','2564972859','2522045495','2603262761','2568172418','2400777855','2550386417','2619110102','2619987882','2612303390','2526100843','2619988205','2576247682','2567417560','2620060278','2578336951','2605846496','2551444229','2621443191')
group by
    1,2,3,4,5,6

union all

select
    e.app_name,event_date,from_page,project,e.platform
    ,'All' ch_event_name
    -- ,page_id
    -- ,button_type
    -- ,theme
    ,count(distinct case
            when event_name in ('h5_page_event_bd','h5_page_event','h5_page_view_bd','h5_page_view') and page_id in ('home_page_view','homepage','style_page','album_page_view')
            then e.user_pseudo_id
            end) visit_uv
    ,count(distinct e.user_pseudo_id) uv
    ,count(1) pv
from
    `dataintegration-265403.temp.temp_xyz_loudou` e
    join `dataintegration-265403.stat.stat_active_advice_detail_d` b on e.user_pseudo_id=b.user_pseudo_id and b.event_date_hk=event_date and e.app_name=b.app_name
where
    hwgid not in ('2612801374','2584503074','2602108161','2588980053','2564483745','2604748400','2605846472','2579895832','2581423417','2562134868','2574054426','2618205088','2576245389','2618941525','2613607104','2563982682','2619999455','2405592903','2602265058','2564972859','2522045495','2603262761','2568172418','2400777855','2550386417','2619110102','2619987882','2612303390','2526100843','2619988205','2576247682','2567417560','2620060278','2578336951','2605846496','2551444229','2621443191')
group by
    1,2,3,4,5,6

