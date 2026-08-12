

with event as
(
    select
        event_date
        ,platform
        ,event_timestamp
        ,event_name
        ,event_params
        ,user_properties
        ,user_pseudo_id
        ,geo.country
    from
        -- `beautyplus-bc0ed.analytics.ods_dz_events_tv`('2023-10-16', '2023-10-30')
        `dataintegration-265403.analytics.dwd_dzp_events_function`('2024-10-29', '2024-11-09', 'beautyplus', false)
    where
        event_name in ('h5_page_event_bd','h5_page_button_clk_bd','h5_credit_consume_bd','webview_close_bd','webview_created_bd')
)
,
event_pre as
(
    select
        event_date
        ,platform
        ,country
        ,event_name
        ,func.getParams(event_params,'lang').string_value lang
        ,func.getParams(event_params,'project').string_value project
        ,func.getParams(event_params,'内容ID').string_value miniapp_content_id
        ,func.getParams(event_params,'page_id').string_value page_id
        ,func.getParams(event_params,'button_type').string_value button_type
        ,func.getParams(event_params,'theme_type').string_value theme_type
        ,func.getParams(event_params,'is_from_push').string_value is_from_push
        ,func.getParams(event_params,'from_page').string_value from_page
        ,func.getParams(event_params,'theme').string_value theme
        ,func.getParams(event_params,'url').string_value url
        ,func.getParams(event_params,'source').string_value source
        ,func.getParams(event_params,'credit_amount').string_value credit_amount
        ,func.getParams(event_params,'order_id').string_value order_id
        ,func.getUserprop(user_properties,'hwgid').string_value hwgid
        ,user_pseudo_id
        ,count(1) pv
    from
        event
    where
        case    when event_name in ('h5_page_event_bd','h5_page_button_clk_bd','h5_credit_consume_bd') then func.getParams(event_params,'project').string_value='AI_Pet_Portray'
                when event_name in ('webview_close_bd','webview_created_bd') then func.getParams(event_params,'url').string_value = 'https://h5.mr.pixocial.com/2023/ai_pet_portraits/'
                else 1=1
                end
    group by
        1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19
)


select
    event_date,from_page,e.platform
    ,case
            when event_name='h5_page_event_bd' and page_id='home_page_view' then '3 进入首页'
            when event_name='webview_created_bd' then '3-1 进入H5'
            when event_name='webview_close_bd' then '3-2 退出H5'
--             when event_name='h5_page_button_clk_bd' and button_type='get_start' then '4-1 点击get_start'
--             when event_name='h5_page_button_clk_bd' and button_type='genetrated_items' then '4-2 点击genetrated_items'
            when event_name='h5_page_event_bd' and page_id='pet_page_view' then '4-1 进入宠物选择页'
            when event_name='h5_page_button_clk_bd' and button_type='next' then '4-2 点击爪子icon选择宠物大类和设定'
            when event_name='h5_page_event_bd' and page_id='guide_page_view' then '5-1 进入图片提示页'
            when event_name='h5_page_button_clk_bd' and button_type='album' then '5-2 点击选择图片'
            when event_name='h5_page_event_bd' and page_id='album_page_view' then '6-1 进入相册页'
            when event_name='h5_page_button_clk_bd' and button_type='upload' then '6-2 上传图片'
--             when event_name='h5_page_event_bd' and page_id='style_page_view' then '6 进入风格选择页'
            when event_name='h5_page_button_clk_bd' and button_type='generate' then '7-1 生成效果'
            when event_name='h5_page_event_bd' and page_id='generated_page_view' then '7-2 进入生成记录页'

            when event_name='h5_page_button_clk_bd' and button_type='view' then '8-1 点击生成任务'
            when event_name='h5_page_button_clk_bd' and button_type in ('save_all','save','save_video') then '8-2 保存图片/视频'
            when event_name='h5_page_button_clk_bd' and button_type='photo_to_video' then '8-3 点击图片生成视频'
            else event_name
            end ch_event_name
    ,case
            when event_name='h5_page_button_clk_bd' and button_type='view' and theme_type='photo' then '8-1-1 点击图片生成任务'
            when event_name='h5_page_button_clk_bd' and button_type in ('save_all','save') then '8-1-2 保存图片'
            when event_name='h5_page_button_clk_bd' and button_type='photo_to_video' then '8-1-3 点击图片生成视频'
            when event_name='h5_page_button_clk_bd' and button_type in ('collage','collage_all') then '8-1-4 点击去拼图'
            when event_name='h5_page_button_clk_bd' and button_type='view' and theme_type='video' then '8-2-1 点击视频生成任务'
            when event_name='h5_page_button_clk_bd' and button_type='save_video' then '8-2-2 保存视频'
            when event_name='h5_page_button_clk_bd' and button_type='edit_video' then '8-2-3 编辑视频'
            else event_name
            end ch_type_event_name
    -- ,page_id
    -- ,button_type
    -- ,theme
    ,count(distinct e.user_pseudo_id) uv
    ,sum(pv) pv
from
    event_pre e
    join `dataintegration-265403.stat.stat_active_advice_detail_d` b on e.user_pseudo_id=b.user_pseudo_id and b.event_date_hk=event_date
where
    hwgid not in ('2612801374','2584503074','2602108161','2588980053','2564483745','2604748400','2605846472','2579895832','2581423417','2562134868','2574054426','2618205088','2576245389','2618941525','2613607104','2563982682','2619999455','2405592903','2602265058','2564972859','2522045495','2603262761','2568172418','2400777855','2550386417','2619110102','2619987882','2612303390','2526100843','2619988205','2576247682','2567417560','2620060278','2578336951','2605846496','2551444229','2621443191')
group by
    1,2,3,4,5

union all

select
    event_date,from_page,e.platform
    ,case
            when event_name='h5_page_event_bd' and page_id='home_page_view' then '3 进入首页'
            when event_name='webview_created_bd' then '3-1 进入H5'
            when event_name='webview_close_bd' then '3-2 退出H5'
--             when event_name='h5_page_button_clk_bd' and button_type='get_start' then '4-1 点击get_start'
--             when event_name='h5_page_button_clk_bd' and button_type='genetrated_items' then '4-2 点击genetrated_items'
            when event_name='h5_page_event_bd' and page_id='pet_page_view' then '4-1 进入宠物选择页'
            when event_name='h5_page_button_clk_bd' and button_type='next' then '4-2 点击爪子icon选择宠物大类和设定'
            when event_name='h5_page_event_bd' and page_id='guide_page_view' then '5-1 进入图片提示页'
            when event_name='h5_page_button_clk_bd' and button_type='album' then '5-2 点击选择图片'
            when event_name='h5_page_event_bd' and page_id='album_page_view' then '6-1 进入相册页'
            when event_name='h5_page_button_clk_bd' and button_type='upload' then '6-2 上传图片'
--             when event_name='h5_page_event_bd' and page_id='style_page_view' then '6 进入风格选择页'
            when event_name='h5_page_button_clk_bd' and button_type='generate' then '7-1 生成效果'
            when event_name='h5_page_event_bd' and page_id='generated_page_view' then '7-2 进入生成记录页'

            when event_name='h5_page_button_clk_bd' and button_type='view' then '8-1 点击生成成功任务'
            when event_name='h5_page_button_clk_bd' and button_type in ('save_all','save','save_video') then '8-2 保存图片/视频'
            when event_name='h5_page_button_clk_bd' and button_type='photo_to_video' then '8-3 点击图片生成视频'
            else event_name
            end ch_event_name
    ,'all' ch_type_event_name
    -- ,page_id
    -- ,button_type
    -- ,theme
    ,count(distinct e.user_pseudo_id) uv
    ,sum(pv) pv
from
    event_pre e
    join `dataintegration-265403.stat.stat_active_advice_detail_d` b on e.user_pseudo_id=b.user_pseudo_id and b.event_date_hk=event_date
where
    hwgid not in ('2612801374','2584503074','2602108161','2588980053','2564483745','2604748400','2605846472','2579895832','2581423417','2562134868','2574054426','2618205088','2576245389','2618941525','2613607104','2563982682','2619999455','2405592903','2602265058','2564972859','2522045495','2603262761','2568172418','2400777855','2550386417','2619110102','2619987882','2612303390','2526100843','2619988205','2576247682','2567417560','2620060278','2578336951','2605846496','2551444229','2621443191')
group by
    1,2,3,4,5


;


with event as
(
    select
        event_date
        ,platform
        ,event_timestamp
        ,event_name
        ,event_params
        ,user_properties
        ,user_pseudo_id
        ,geo.country
    from
        -- `beautyplus-bc0ed.analytics.ods_dz_events_tv`('2023-10-16', '2023-10-30')
        `dataintegration-265403.analytics.dwd_dzp_events_function`('2024-10-29', '2024-11-09', 'beautyplus', false)
    where
        event_name in ('h5_page_event_bd','h5_page_button_clk_bd')
)
,
event_pre as
(
    select
        event_date
        ,platform
        ,country
        ,event_name
        ,func.getParams(event_params,'lang').string_value lang
        ,func.getParams(event_params,'project').string_value project
        ,func.getParams(event_params,'内容ID').string_value miniapp_content_id
        ,func.getParams(event_params,'page_id').string_value page_id
        ,func.getParams(event_params,'type').string_value type
        ,func.getParams(event_params,'button_type').string_value button_type
        ,func.getParams(event_params,'theme_type').string_value theme_type
        ,func.getParams(event_params,'theme').string_value theme
        ,func.getParams(event_params,'is_from_push').string_value is_from_push
        ,func.getParams(event_params,'from_page').string_value from_page
        ,func.getParams(event_params,'url').string_value url
        ,func.getParams(event_params,'source').string_value source
        ,func.getParams(event_params,'credit_amount').string_value credit_amount
        ,func.getParams(event_params,'order_id').string_value order_id
        ,func.getUserprop(user_properties,'hwgid').string_value hwgid
        ,user_pseudo_id
        ,count(1) pv
    from
        event
    where
        case    when event_name in ('h5_page_event_bd','h5_page_button_clk_bd','h5_credit_consume_bd') then func.getParams(event_params,'project').string_value='AI_Pet_Portray'
                when event_name in ('webview_close_bd','webview_created_bd') then func.getParams(event_params,'url').string_value = 'https://h5.mr.pixocial.com/2023/ai_pet_portraits/'
                else 1=1
                end
    group by
        1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20
)


select
    event_date,replace(replace(k,'_dog',''),'_cat','') k,type
    ,case
            when event_name='h5_page_event_bd' and page_id='pet_page_view' then '4-1 进入宠物选择页'
            when event_name='h5_page_button_clk_bd' and button_type='next' then '4-2 点击爪子icon选择宠物大类和设定'
            when event_name='h5_page_event_bd' and page_id='guide_page_view' then '5-1 进入图片提示页'
            when event_name='h5_page_button_clk_bd' and button_type='album' then '5-2 点击选择图片'
            when event_name='h5_page_event_bd' and page_id='album_page_view' then '6-1 进入相册页'
            when event_name='h5_page_button_clk_bd' and button_type='upload' then '6-2 上传图片'
--             when event_name='h5_page_event_bd' and page_id='style_page_view' then '6 进入风格选择页'
            when event_name='h5_page_button_clk_bd' and button_type='generate' then '7-1 生成效果'
            when event_name='h5_page_event_bd' and page_id='generated_page_view' then '7-2 进入生成记录页'

            when event_name='h5_page_button_clk_bd' and button_type='view' then '8-1 点击生成任务'
            when event_name='h5_page_button_clk_bd' and button_type in ('save_all','save','save_video') then '8-2 保存图片/视频'
            when event_name='h5_page_button_clk_bd' and button_type='photo_to_video' then '8-3 点击图片生成视频'
            else event_name
            end ch_event_name
    -- ,page_id
    -- ,button_type
    -- ,theme
    ,count(distinct e.user_pseudo_id) uv
    ,sum(pv) pv
from
    event_pre e,unnest(split(coalesce(theme,''),',')) k
    join `dataintegration-265403.stat.stat_active_advice_detail_d` b on e.user_pseudo_id=b.user_pseudo_id and b.event_date_hk=event_date
where
    hwgid not in ('2612801374','2584503074','2602108161','2588980053','2564483745','2604748400','2605846472','2579895832','2581423417','2562134868','2574054426','2618205088','2576245389','2618941525','2613607104','2563982682','2619999455','2405592903','2602265058','2564972859','2522045495','2603262761','2568172418','2400777855','2550386417','2619110102','2619987882','2612303390','2526100843','2619988205','2576247682','2567417560','2620060278','2578336951','2605846496','2551444229','2621443191')
group by
    1,2,3,4
;





















-- 异常排查
with homepage_event as
(
    select
        event_date
        ,platform
        ,event_timestamp
        ,event_name
        ,event_params
        ,user_properties
        ,user_pseudo_id
        ,geo.country
    from
        -- `beautyplus-bc0ed.analytics.ods_dz_events_tv`('2023-10-16', '2023-10-30')
        `dataintegration-265403.analytics.dwd_dzp_events_function`('2024-11-01', '2024-11-01', 'beautyplus', false)
    where
        event_name in ('h5_page_event_bd')
        and func.getParams(event_params,'page_id').string_value='home_page_view'
)
,
home_page_event as
(
    select
        event_date
        ,platform
        ,event_timestamp
        ,event_name
        ,event_params
        ,user_properties
        ,user_pseudo_id
        ,geo.country
    from
        -- `beautyplus-bc0ed.analytics.ods_dz_events_tv`('2023-10-16', '2023-10-30')
        `dataintegration-265403.analytics.dwd_dzp_events_function`('2024-11-01', '2024-11-01', 'beautyplus', false)
    where
        event_name in ('home_page_pop_clk_bd')
        and func.getParams(event_params,'type').string_value in ('try_it')
        and func.getParams(event_params,'pop_id').string_value in ('BP_POP_00001600')
)
,url_event as
(
    select
        event_date
        ,platform
        ,event_timestamp
        ,event_name
        ,event_params
        ,user_properties
        ,user_pseudo_id
        ,geo.country
    from
        -- `beautyplus-bc0ed.analytics.ods_dz_events_tv`('2023-10-16', '2023-10-30')
        `dataintegration-265403.analytics.dwd_dzp_events_function`('2024-11-01', '2024-11-01', 'beautyplus', false)
    where event_name in ('webview_created_bd') and func.getParams(event_params,'url').string_value = 'https://h5.mr.pixocial.com/2023/ai_pet_portraits/'
)

select *
from homepage_event h
left join url_event u
on h.user_pseudo_id=u.user_pseudo_id and h.event_date=u.event_date
where u.user_pseudo_id is null


select
    event_date
    ,platform
    ,event_timestamp
    ,event_name
    ,event_params
    ,user_properties
    ,user_pseudo_id
    ,geo.country
from
    -- `beautyplus-bc0ed.analytics.ods_dz_events_tv`('2023-10-16', '2023-10-30')
    `dataintegration-265403.analytics.dwd_dzp_events_function`('2024-10-30', '2024-10-30', 'beautyplus', false)
where event_name in ('home_page_pop_clk_bd','home_page_pop_appr_bd','homepageappr_bd'
    ,'webview_click_bd','webview_created_bd','webview_start_fetch_bd','webview_loaded_fetch_bd','home_page_time_bd','h5_page_event_bd','webview_close_bd')
    and user_pseudo_id='C0DC0C3F6D374C0A904A4E54D9C09CC8'
order by event_timestamp
