-- 首页miniapp的曝光量（目前是唯一入口）
-- 进入十二星座首页的用户数 uv&pv home_page_view
-- 转动星盘的用户数 uv&pv ?
-- 点击try now的用户数 uv&pv try
-- 进入相册页的用户数 uv&pv album_page_view
-- 进入消费页的用户数 uv&pv confirm_page_view
-- 点击 5 will be spent的用户数 uv generate
-- 进入生成loading页的用户数 uv&pv loading_page_view
-- 等待过程中退出的用户数 uv&pv exiting
-- 结果页「保存海报、保存视频」的点击数 save_poster, save video
-- 进入生成记录页的用户数 uv&pv generate_items
-- 进入留住用户页的用户数 uv&pv continue_generate
-- 在留住用户页触发挽留弹窗的用户数 uv&pv wait_popup_view

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
        -- `beautyplus-bc0ed.analytics.ods_dz_events_tv`('2023-09-25', '2023-10-08')  
        `dataintegration-265403.analytics.dwd_dzp_events_function`('2023-11-30', '2023-12-31', 'beautyplus', false)  
    where
        event_name in ('h5_page_event_bd','h5_page_button_clk_bd','h5_credit_consume_bd') -- ,'home_content_show_f_bd','home_content_clk_bd')
)
,
event_pre as
(
    select
        event_date
        ,platform
        ,country
        ,event_name
        ,func.getParams(event_params,'project').string_value project
        ,func.getParams(event_params,'内容ID').string_value miniapp_content_id
        ,func.getParams(event_params,'page_id').string_value page_id
        ,func.getParams(event_params,'button_type').string_value button_type
        ,func.getParams(event_params,'theme').string_value theme
        ,func.getParams(event_params,'source').string_value source
        ,func.getParams(event_params,'credit_amount').string_value credit_amount
        ,func.getParams(event_params,'order_id').string_value order_id
        ,func.getUserprop(user_properties,'hwgid').string_value hwgid
        ,user_pseudo_id
        ,count(1) pv
    from 
        event
    where
        case
--                 when event_name in ('home_content_show_f_bd','home_content_clk_bd') then (func.getParams(event_params,'模块类型').string_value='miniapp' and func.getParams(event_params,'内容ID').string_value in ('BP_MIN_00000042','BP_MIN_00000043'))
                when event_name in ('h5_page_event_bd','h5_page_button_clk_bd','h5_credit_consume_bd') then func.getParams(event_params,'project').string_value='AI_Zodiac_Persona'
                else 1=1
                end
    group by 
        1,2,3,4,5,6,7,8,9,10,11,12,13,14
)

select
    event_date
    ,event_name
    ,case
--             when event_name='home_content_show_f_bd' then '1 首页miniapp的曝光'
--             when event_name='home_content_clk_bd' then '2 首页miniapp的点击'
            when event_name='h5_page_event_bd' and page_id='home_page_view' then '3 进入miniapp首页'
            when event_name='h5_page_button_clk_bd' and button_type='try' then '4 点击try now'
            when event_name='h5_page_event_bd' and page_id='album_page_view' then '5 进入相册页'
            when event_name='h5_page_event_bd' and page_id='confirm_page_view' then '6 进入消费页'
            when event_name='h5_page_button_clk_bd' and button_type='generate' then '7 点击5 will be spent'
            when event_name='h5_page_event_bd' and page_id='loading_page_view' then '8 进入生成loading页'
            when event_name='h5_page_button_clk_bd' and button_type='exiting' then '9 等待过程中退出'
            when event_name='h5_page_button_clk_bd' and button_type in ('save_poster','save_video') then '10 结果页「保存海报、保存视频」'
            when event_name='h5_page_event_bd' and page_id='generated_page_view' then '11 进入生成记录页'
            when event_name='h5_page_event_bd' and page_id='retain_page_view' then '12 进入留住用户页'
            when event_name='h5_page_event_bd' and page_id='wait_popup_view2' then '13 留住用户页触发挽留弹窗'
            else event_name
            end ch_event_name
    ,project
    ,miniapp_content_id
    ,page_id
    ,button_type
    ,theme
    ,count(distinct e.user_pseudo_id) uv
    ,sum(pv) pv
from 
    event_pre e 
    join `dataintegration-265403.stat.stat_active_advice_detail_d` b on e.user_pseudo_id=b.user_pseudo_id and b.event_date_hk=event_date
where 
    hwgid not in ('2612801374','2584503074','2602108161','2588980053','2564483745','2604748400','2605846472','2579895832','2581423417','2562134868','2574054426','2618205088','2576245389')
group by
    1,2,3,4,5,6,7,8
;

with exposure_event as
(
    select *
    from `beautyplus-bc0ed.content_data.dws_da_h5_event_miniapp_level`
    where event_date between '2023-09-14' and '2023-12-31' and miniapp_name='Zodiac Persona'
)
select event_date,null event_name,'1 首页miniapp的曝光' ch_event_name,'AI_Zodiac_Persona' project
     ,null miniapp_content_id,null page_id,null button_type,null theme
     ,sum(exposure_uv) uv,sum(exposure_pv) pv
from exposure_event
group by 1

union all

select event_date,null event_name,'2 首页miniapp的点击' ch_event_name,'AI_Zodiac_Persona' project
     ,null miniapp_content_id,null page_id,null button_type,null theme
     ,sum(click_uv) uv,sum(click_pv) pv
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
        and event_date>='2023-09-14'
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
        parse_date('%Y%m%d', event_date) >='2023-09-14'
        and platform in ('IOS','ANDROID')  
        and event_name='h5_credit_consume_bd'
)
,
EVENT1 as
(
    select
        parse_date('%Y%m%d', event_date) event_date
        ,func.getParams(event_params,'project').string_value as project
        ,k order_id
        ,user_pseudo_id
        ,count(1) as pv
    from
        event,unnest(split(func.getParams(event_params,'order_id').string_value,',')) k
    where
        event_name in ('h5_credit_consume_bd')
        and func.getParams(event_params,'project').string_value in ('AI_Zodiac_Persona')
    group by 
        1,2,3,4
)

select
    event_date date 
    ,case   when project='AI_Zodiac_Persona' then 'AI Zodiac Persona'
            else project 
            end function
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
      where event_date_hk>='2023-09-14'
    ) b
    on a.user_pseudo_id=b.user_pseudo_id and b.event_date_hk =event_date
    join credit c on a.order_id=c.order_id
group by
    1,2 --,3,4,5,6,7
