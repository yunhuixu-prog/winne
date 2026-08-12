-- B+AI

-- 首页miniapp的曝光量
-- 首页miniapp的点击量
-- 进入B+AI首页  home_page_view
-- 点击genetrated_items  genetrated_items
-- 进入生成记录页  generated_page_view
-- 进入好评弹窗  comment_popup_view


-- 付费照片
-- 点击首页照片主题卡片  upload & theme_type='photo' and is_bundle=1
-- 点击列表页照片主题卡片  list & theme_type='photo' and is_bundle=1
-- 进入bundle协议页1(首页点击bundle)  bundle_page_view1
-- 进入bundle协议页2(列表页点击bundle)  bundle_page_view2
-- 点击生成效果  uv generate & theme_type='photo' and is_bundle=1
-- 积分消耗人数&金额 h5_credit_consume_bd & source 
-- 点击生成记录页单个item  view & theme_type='photo' and is_bundle=1
-- 进入bundle效果生成后的页面 bundle_make_page_view
-- 进入照片生成结果页 make_page_view
-- 点击保存单张图片或所有图片  save or save all & theme_type='photo'or'image' and is_bundle=1


-- 免费照片
-- 点击首页照片主题卡片  upload & theme_type='photo' and is_bundle=0
-- 进入免费照片协议页  confirm_page_view
-- 点击生成效果  generate & theme_type='photo' and is_bundle=0
-- 进入列表页(免费效果生成页) list_page_view
-- 点击保存单张图片  save & theme_type='photo' and is_bundle=0
-- 点击拼图  collage & theme_type='photo' and is_bundle=0
-- 点击列表页免费效果 list & theme_type='photo' and is_bundle=0


-- 视频
-- 点击视频主题卡片  upload & theme_type='video' 
-- 进入video协议页 video_confirm_page_view
-- 点击生成效果  uv generate & theme_type='video' 
-- 积分消耗人数&金额 h5_credit_consume_bd & source 
-- 点击生成记录页单个item view & theme_type='video' 
-- 进入视频效果生成后的页面 video_make_page_view
-- 点击生成页播放按钮 play & theme_type='video' 
-- 点击保存视频  save & theme_type='video' 



-- 每次记得看下素材视频有没有更新，积分消耗区分视频图片要手动
-- 看积分消耗的source有哪些名字
-- with event as
-- (
--     select
--         event_date
--         ,platform
--         ,event_timestamp
--         ,event_name
--         ,event_params
--         ,user_properties
--         ,user_pseudo_id
--         ,geo.country
--     from
--         -- `beautyplus-bc0ed.analytics.ods_dz_events_tv`('2023-11-01', '2023-11-04')
--         `beautyplus-bc0ed.analytics.stage_dz_event_view`
--     where
--         event_name in ('h5_credit_consume_bd')
--         and parse_date('%Y%m%d', event_date) >='2023-12-01'
-- )
-- ,
-- event_pre as
-- (
--     select
--         event_date
--         ,platform
--         ,country
--         ,event_name
--         ,func.getParams(event_params,'lang').string_value lang
--         ,func.getParams(event_params,'project').string_value project
--         ,func.getParams(event_params,'theme').string_value theme
--         ,func.getParams(event_params,'theme_type').string_value theme_type
--         ,func.getParams(event_params,'source').string_value source
--         ,func.getParams(event_params,'credit_amount').string_value credit_amount
--         ,func.getUserprop(user_properties,'hwgid').string_value hwgid
--         ,user_pseudo_id
--         ,count(1) pv
--     from
--         event
--     where
--         case    when event_name in ('h5_credit_consume_bd') then func.getParams(event_params,'project').string_value='BeautyPlus_AI_V3'
--                 else 1=1
--                 end
--     group by
--         1,2,3,4,5,6,7,8,9,10,11,12
-- )
-- select distinct source from event_pre





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
        -- `beautyplus-bc0ed.analytics.ods_dz_events_tv`('2023-11-01', '2023-11-04')  
        `dataintegration-265403.analytics.dwd_dzp_events_function`('2023-10-17', '2023-12-31', 'beautyplus', false)
    where
        event_name in ('h5_page_event_bd','h5_page_button_clk_bd','h5_credit_consume_bd')
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
        ,func.getParams(event_params,'is_from_push').string_value is_from_push
        ,func.getParams(event_params,'theme').string_value theme
        ,func.getParams(event_params,'theme_type').string_value theme_type
        ,func.getParams(event_params,'is_bundle').string_value is_bundle
        ,func.getParams(event_params,'source').string_value source
        ,func.getParams(event_params,'credit_amount').string_value credit_amount
        ,func.getParams(event_params,'order_id').string_value order_id
        ,func.getUserprop(user_properties,'hwgid').string_value hwgid
        ,user_pseudo_id
        ,count(1) pv
    from 
        event
    where
        case    when event_name in ('h5_page_event_bd','h5_page_button_clk_bd','h5_credit_consume_bd') then func.getParams(event_params,'project').string_value='BeautyPlus_AI_V3'
                else 1=1
                end
    group by 
        1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18
)

select
    event_date
    ,case   when event_name='h5_page_event_bd' and page_id='home_page_view' then '0-3 进入miniapp首页'
            when event_name='h5_page_button_clk_bd' and button_type='generated_items' then '0-4 点击genetrated_items'
            when event_name='h5_page_event_bd' and page_id='generated_page_view' then '0-5 进入生成记录页'
            when event_name='h5_page_event_bd' and page_id='comment_popup_view' then '0-6 进入好评弹窗'

            when event_name='h5_page_button_clk_bd' and button_type='upload' and theme_type='photo' and is_bundle='1' then '1-1 点击首页付费照片主题卡片'
            when event_name='h5_page_button_clk_bd' and button_type='list' and theme_type='photo' and is_bundle='1' then '1-1 点击列表页付费照片主题卡片'
            when event_name='h5_page_event_bd' and page_id='bundle_page_view1' then '1-2 进入bundle协议页1(首页点击bundle)'
            when event_name='h5_page_event_bd' and page_id='bundle_page_view2' then '1-2 进入bundle协议页2(列表页点击bundle)'
            when event_name='h5_page_button_clk_bd' and button_type='generate' and theme_type='photo' and is_bundle='1' then '1-3 点击生成效果-付费照片'
--             when event_name='h5_credit_consume_bd' and source like 'Bundle%' then '1-4 积分消耗-付费照片'
            when event_name='h5_credit_consume_bd' and source not in ('Cyberpunk','Colorful_Skull','Undead','Animeface','AnimeFace','Showa_80s','CyberpunkNew','Fireworks') then '1-4 积分消耗-付费照片'
            when event_name='h5_page_button_clk_bd' and button_type='view' and theme_type='photo' and is_bundle='1' then '1-5 点击生成记录页单个item-付费照片'
            when event_name='h5_page_event_bd' and page_id='bundle_make_page_view' then '1-6 进入bundle效果生成后的页面'
            when event_name='h5_page_event_bd' and page_id='make_page_view' then '1-7 进入照片生成结果页-付费照片'
            when event_name='h5_page_button_clk_bd' and (button_type='save' or button_type='save_all') and (theme_type='photo' or theme_type='image') and is_bundle='1' then '1-8 点击保存单张或所有图片-付费照片'

            when event_name='h5_page_button_clk_bd' and button_type='upload' and theme_type='photo' and is_bundle='0' then '2-1 点击首页免费照片主题卡片'
            when event_name='h5_page_event_bd' and page_id='confirm_page_view' then '2-2 进入免费照片协议页'
            when event_name='h5_page_button_clk_bd' and button_type='generate' and theme_type='photo' and is_bundle='0' then '2-3 点击生成效果-免费照片'
            when event_name='h5_page_event_bd' and page_id='list_page_view' then '2-4 进入免费照片生成页(列表页)'
            when event_name='h5_page_button_clk_bd' and (button_type='save' or button_type='save_all') and theme_type='photo' and is_bundle='0' then '2-5 点击保存图片-免费照片'
            when event_name='h5_page_button_clk_bd' and button_type='collage' then '2-6 点击去拼图-免费照片'
            when event_name='h5_page_button_clk_bd' and button_type='list' and theme_type='photo' and is_bundle='0' then '2-7 点击列表页免费照片主题卡片'

            when event_name='h5_page_button_clk_bd' and button_type='upload' and theme_type='video' then '3-1 点击视频主题卡片'
            when event_name='h5_page_event_bd' and page_id='video_confirm_page_view' then '3-2 进入视频协议页'
            when event_name='h5_page_button_clk_bd' and button_type='generate' and theme_type='video' then '3-3 点击生成效果-视频'
--             when event_name='h5_credit_consume_bd' and (source not like 'Bundle%') and (source not like 'Free%') then '3-4 积分消耗-视频'
            when event_name='h5_credit_consume_bd' and source in ('Cyberpunk','Colorful_Skull','Undead','Animeface','AnimeFace','Showa_80s','CyberpunkNew','Fireworks') then '3-4 积分消耗-视频'
            when event_name='h5_page_button_clk_bd' and button_type='view' and theme_type='video' then '3-5 点击生成记录页单个item-视频'
            when event_name='h5_page_event_bd' and page_id='video_make_page_view' then '3-6 进入视频效果生成后的页面'
            when event_name='h5_page_button_clk_bd' and button_type='play' then '3-7 点击生成页播放按钮'
            when event_name='h5_page_button_clk_bd' and (button_type='save' or button_type='save_all') and theme_type='video' then '3-8 点击保存视频'

            else event_name
            end ch_event_name
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
    1,2
;

-- 首页曝光 
with exposure_event as 
(
    select *
    from `beautyplus-bc0ed.content_data.dws_da_h5_event_miniapp_level`
    where event_date between '2023-11-30' and '2023-12-31' and miniapp_name='B+ AI'
)
select event_date,'0-1 首页miniapp的曝光' event_name,sum(exposure_uv) uv,sum(exposure_pv) pv
from exposure_event
group by 1

union all 

select event_date,'0-2 首页miniapp的点击' event_name,sum(click_uv) uv,sum(click_pv) pv
from exposure_event
group by 1
;

-- 积分消耗
--aigc积分
with credit as 
(
    select
        order_id
        ,credit_num
        ,payment_price_usd
    from
        `beautyplus-bc0ed.dwd.dwd_da_credit_credit_record`
    where
        record_type=2 -- 积分消耗
        and app_name='BeautyPlus'
        and event_date>='2023-10-17'
    group by
        1,2,3
)
,
event as
(     
    select
        *    
    from
        `beautyplus-bc0ed.analytics.stage_dz_event_view` 
    where  
        parse_date('%Y%m%d', event_date) >='2023-10-17'
        and platform in ('IOS','ANDROID')  
        and event_name='h5_credit_consume_bd'
)
,
EVENT1 as
(
    select
        parse_date('%Y%m%d', event_date) event_date
        ,func.getParams(event_params,'project').string_value as project
        ,func.getParams(event_params,'lang').string_value lang
        ,k order_id
        ,user_pseudo_id
        ,count(1) as pv
    from
        event,unnest(split(func.getParams(event_params,'order_id').string_value,',')) k
    where
        event_name in ('h5_credit_consume_bd')
        and func.getParams(event_params,'project').string_value in ('BeautyPlus_AI_V3')
    group by 
        1,2,3,4,5
)

select
    event_date date 
    -- ,case   when project='BeautyPlus_AI_V3' then 'B+ AI'
    --         else project 
    --         end function
    -- ,platform
    -- ,case when is_new=1 then 'New-user' else 'Old-user' end as is_new
    -- ,country
    -- ,is_UA
    -- ,a.user_pseudo_id
    ,count(distinct a.user_pseudo_id) uv
    ,sum(pv) pv
    ,sum(credit_num) credit_num
    ,round(sum(payment_price_usd),2) payment_price_usd
from 
    EVENT1 a
    join 
    (
      select distinct event_date_hk,user_pseudo_id
      from `dataintegration-265403.stat.stat_active_advice_detail_d` 
      where event_date_hk>='2023-10-17'
    ) b
    on a.user_pseudo_id=b.user_pseudo_id and b.event_date_hk =event_date
    join credit c on a.order_id=c.order_id
group by
    1 --,2,3,4,5,6,7;

-- 明细
select date,order_num,count(distinct user_pseudo_id) num,sum(credit_num) credit_num,round(sum(payment_price_usd),2) payment_price_usd
from
(
    select
        event_date date 
        -- ,platform
        -- ,case when is_new=1 then 'New-user' else 'Old-user' end as is_new
        -- ,country
        -- ,is_UA
        ,a.user_pseudo_id
        ,count(distinct a.order_id) order_num
        ,sum(pv) pv
        ,sum(credit_num) credit_num
        ,sum(payment_price_usd) payment_price_usd
    from 
    EVENT1 a
    join 
    (
        select distinct event_date_hk,user_pseudo_id
        from `dataintegration-265403.stat.stat_active_advice_detail_d` 
        where event_date_hk>='2023-10-16'
    ) b
    on a.user_pseudo_id=b.user_pseudo_id and b.event_date_hk =event_date
    join credit c on a.order_id=c.order_id
    group by
        1,2
)
group by 1,2;

