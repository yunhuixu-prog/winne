-- puriplus
-- 首页miniapp的曝光量
-- 首页miniapp的点击量
-- 进入首页的用户数 uv&pv homepage
-- 首页点击开始的用户数 uv&pv start
-- 进入选择边框页的用户数 uv&pv style_page
-- 选择边框页点击边框的用户数 uv&pv frame
-- 进入拍中页的用户数 uv&pv shoot_page
-- 拍中页点击拍照的用户数 uv&pv shoot
-- 拍中页点击拍照完成的用户数 uv&pv shoot_success
-- 进入美颜页的用户数 uv&pv edit_beauty_page
-- 美颜页点击跳过的用户数 edit_beauty_page & skip
-- 美颜页点击功能的用户数 edit_beauty_page & function
-- 美颜页点击功能确认的用户数 edit_beauty_page & tick
-- 进入美型页的用户数 uv&pv edit_figure_page
-- 美型页点击跳过的用户数 edit_figure_page & skip
-- 美型页点击功能的用户数 edit_figure_page & function
-- 美型页点击功能确认的用户数 edit_figure_page & tick
-- 进入美体页（仅机器二）的用户数 uv&pv edit_body_page
-- 美体页（仅机器二）点击跳过的用户数 edit_body_page & skip
-- 美体页（仅机器二）点击功能的用户数 edit_body_page & function
-- 美体页（仅机器二）点击功能确认的用户数 edit_body_page & tick
-- 进入妆容页的用户数 uv&pv edit_makeup_page
-- 妆容页点击跳过的用户数 edit_makeup_page & skip
-- 妆容页点击功能的用户数 edit_makeup_page & function
-- 妆容页点击功能确认的用户数 edit_makeup_page & tick
-- 进入装饰页的用户数 uv&pv edit_decorate_page
-- 装饰页点击跳过的用户数 edit_decorate_page & generate
-- 装饰页点击功能的用户数 edit_decorate_page & function
-- 装饰页点击功能确认的用户数 edit_decorate_page & tick
-- 进入出图页的用户数 uv&pv publish_page
-- 成功保存的用户数 zero_save,none_zero_save,share_for_free
-- 进入分享页面 uv&pv share_module
-- 点击分享的用户数 uv&pv share

-- 积分消耗人数&金额


with event as
(
    select
        event_date
        ,platform
        ,event_timestamp
        ,case when event_name in ('h5_page_event_bd','h5_page_event') then 'h5_page_event_bd'
              when event_name in ('h5_page_button_clk_bd','h5_page_button_clk') then 'h5_page_button_clk_bd'
              when event_name in ('h5_credit_consume_bd','h5_credit_consume') then 'h5_credit_consume_bd'
        end event_name
        ,event_params
        ,user_properties
        ,user_pseudo_id
        ,geo.country
        ,app_name
    from
        -- `beautyplus-bc0ed.analytics.ods_dz_events_tv`('2023-09-28', '2023-10-08')
        -- `beautyplus-bc0ed.analytics.ods_dz_events_tv`('2023-10-17', '2023-10-30')
        `dataintegration-265403.analytics.dwd_dzp_events_function`('2024-07-19', '2024-10-19', 'beautyplus,airbrush', false)
    where
        event_name in ('h5_page_event_bd','h5_page_button_clk_bd','h5_credit_consume_bd','h5_page_event','h5_page_button_clk','h5_credit_consume') --,'home_content_show_f_bd','home_content_clk_bd')
)
,
event_pre as
(
    select
        app_name
        ,event_date
        ,platform
        ,country
        ,event_name
        ,func.getParams(event_params,'lang').string_value lang
        ,func.getParams(event_params,'project').string_value project
--         ,func.getParams(event_params,'内容ID').string_value miniapp_content_id
        ,func.getParams(event_params,'page_id').string_value page_id
        ,func.getParams(event_params,'button_type').string_value button_type
        ,func.getParams(event_params,'machine').string_value machine
        ,func.getParams(event_params,'theme').string_value theme
        ,func.getParams(event_params,'theme_type').string_value theme_type
        ,func.getParams(event_params,'photo_num').string_value photo_num
        ,cast(func.getParams(event_params,'credit_amount').string_value as int64) credit_amount
        ,func.getParams(event_params,'order_id').string_value order_id
        ,func.getUserprop(user_properties,'hwgid').string_value hwgid
        ,func.getUserprop(user_properties,'UserPaymentStatus').string_value is_pay
        ,user_pseudo_id
        ,count(1) pv
    from
        event
    where
        case
--                 when event_name in ('home_content_show_f_bd','home_content_clk_bd') then (func.getParams(event_params,'模块类型').string_value='miniapp' and func.getParams(event_params,'内容ID').string_value in ('BP_MIN_00000044','BP_MIN_00000045'))
                when event_name in ('h5_page_event_bd','h5_page_button_clk_bd','h5_credit_consume_bd') then func.getParams(event_params,'project').string_value='puriplus'
                else 1=1
                end
    group by
        1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18
)
,
-- 取当天进入首页时的订阅状态
user_payment_status as
(
    select app_name,event_date,user_pseudo_id,min(case when is_pay in ('Paying') or is_pay is null then is_pay else 'Non-paying' end) is_pay
    from event_pre
    where event_name in ('h5_page_event_bd','h5_page_event') and page_id='homepage'
    group by 1,2,3
)

select
    e.app_name
    ,e.event_date
    ,e.event_name
    ,case when e.machine='1' then 'Clear Diary'
          when e.machine='2' then 'Sweetie'
          when e.machine='3' then 'Kawaii Party'
          when e.machine='4' then 'Life 4 Grid'
    end machine
--     ,case when lang in ('ko','ja','th') then '日韩版'
--           when lang in ('en') then '欧美版'
--           when lang is null then 'null'
--     else '其他' end image_type
--     ,e.is_pay
--     ,case when e.is_pay in ('Paying') or e.is_pay is null then e.is_pay else 'Non-paying' end is_pay
    ,p.is_pay
    ,case
--             when event_name='home_content_show_f_bd' then '1 首页miniapp的曝光'
--             when event_name='home_content_clk_bd' then '2 首页miniapp的点击'
            when event_name='h5_page_event_bd' and page_id='homepage' then '3-0 进入miniapp首页'
            when event_name='h5_page_button_clk_bd' and button_type in ('start') then '3-1-1 点击「shoot」'
            when event_name='h5_page_button_clk_bd' and button_type='genetrated_items' then '3-1-2 点击genetrated_items'
            when event_name='h5_page_event_bd' and page_id='style_page' then '4-0 进入选择边框页'
            when event_name='h5_page_button_clk_bd' and button_type='frame' then '4-1 点击选择边框'
            when event_name='h5_page_event_bd' and page_id='shoot_page' then '5-0 进入拍中页'
            when event_name='h5_page_button_clk_bd' and button_type='shoot' then '5-1 点击拍摄'
            when event_name='h5_page_button_clk_bd' and button_type='shoot_success' then '5-2 点击拍摄完成'
            when event_name='h5_page_event_bd' and page_id='edit_beauty_page' then '6-0-0 进入美颜页'
            when event_name='h5_page_button_clk_bd' and page_id='edit_beauty_page' and button_type='skip' then '6-0-1 美颜页点击跳过'
            when event_name='h5_page_button_clk_bd' and page_id='edit_beauty_page' and button_type='function' then '6-0-1-1 美颜页点击具体功能'
            when event_name='h5_page_button_clk_bd' and page_id='edit_beauty_page' and button_type='tick' then '6-0-1-2 美颜页点击功能确认'
            when event_name='h5_page_event_bd' and page_id='edit_figure_page' then '6-1 进入美型页'
            when event_name='h5_page_button_clk_bd' and page_id='edit_figure_page' and button_type='skip' then '6-1-1 美型页点击跳过'
            when event_name='h5_page_button_clk_bd' and page_id='edit_figure_page' and button_type='function' then '6-1-1-1 美型页点击具体功能'
            when event_name='h5_page_button_clk_bd' and page_id='edit_figure_page' and button_type='tick' then '6-1-1-2 美型页点击功能确认'
            when event_name='h5_page_event_bd' and page_id='edit_body_page' then '6-2 进入美体页'
            when event_name='h5_page_button_clk_bd' and page_id='edit_body_page' and button_type='skip' then '6-2-1 美体页点击跳过'
            when event_name='h5_page_button_clk_bd' and page_id='edit_body_page' and button_type='function' then '6-2-1-1 美体页点击具体功能'
            when event_name='h5_page_button_clk_bd' and page_id='edit_body_page' and button_type='tick' then '6-2-1-2 美体页点击功能确认'
            when event_name='h5_page_event_bd' and page_id='edit_makeup_page' then '6-3 进入妆容页'
            when event_name='h5_page_button_clk_bd' and page_id='edit_makeup_page' and button_type='skip' then '6-3-1 妆容页点击跳过'
            when event_name='h5_page_button_clk_bd' and page_id='edit_makeup_page' and button_type='function' then '6-3-1-1 妆容页点击具体功能'
            when event_name='h5_page_button_clk_bd' and page_id='edit_makeup_page' and button_type='tick' then '6-3-1-2 妆容页点击功能确认'
            when event_name='h5_page_event_bd' and page_id='edit_decorate_page' then '6-4 进入装饰页'
            when event_name='h5_page_button_clk_bd' and page_id='edit_decorate_page' and button_type='generate' then '6-4-1 装饰页点击生成'
            when event_name='h5_page_button_clk_bd' and page_id='edit_decorate_page' and button_type='function' then '6-4-1-1 装饰页点击具体功能'
            when event_name='h5_page_button_clk_bd' and page_id='edit_decorate_page' and button_type='tick' then '6-4-1-2 装饰页点击功能确认'
            when event_name='h5_page_event_bd' and page_id='publish_page' then '7 进入出图页'
            when event_name='h5_credit_consume_bd'  then '8 保存成功'
            when event_name='h5_page_button_clk_bd' and button_type='share' then '9 点击分享按钮'
            else event_name
            end ch_event_name
    ,project
--     ,miniapp_content_id
    -- ,page_id
    -- ,button_type
    -- ,theme
    ,count(distinct e.user_pseudo_id) uv
    ,sum(pv) pv
from
    event_pre e
    join `dataintegration-265403.stat.stat_active_advice_detail_d` b on e.user_pseudo_id=b.user_pseudo_id and b.event_date_hk=e.event_date and e.app_name=b.app_name
    left join user_payment_status p on e.user_pseudo_id=p.user_pseudo_id and p.event_date=e.event_date and e.app_name=p.app_name
where
    hwgid not in ('2612801374','2584503074','2602108161','2588980053','2564483745','2604748400','2605846472','2579895832','2581423417','2562134868','2574054426','2618205088','2576245389','2618941525','2613607104','2563982682','2619999455','2405592903','2602265058','2564972859','2522045495','2603262761','2568172418','2400777855','2550386417','2619110102','2619987882','2612303390','2526100843','2619988205','2576247682','2567417560','2620060278','2578336951','2605846496','2551444229','2621443191','2474249969','2622802284','2597210926')
group by
    1,2,3,4,5,6,7






-- 素材使用数据
with event as
(
    select
        event_date
        ,platform
        ,event_timestamp
        ,case when event_name in ('h5_page_event_bd','h5_page_event') then 'h5_page_event_bd'
              when event_name in ('h5_page_button_clk_bd','h5_page_button_clk') then 'h5_page_button_clk_bd'
              when event_name in ('h5_credit_consume_bd','h5_credit_consume') then 'h5_credit_consume_bd'
        end event_name
        ,func.getParams(event_params,'lang').string_value lang
        ,func.getParams(event_params,'project').string_value project
        ,func.getParams(event_params,'page_id').string_value page_id
        ,func.getParams(event_params,'button_type').string_value button_type
        ,func.getParams(event_params,'machine').string_value machine
        ,func.getParams(event_params,'theme').string_value theme
        ,func.getParams(event_params,'theme_type').string_value theme_type
        ,func.getParams(event_params,'photo_num').string_value photo_num
        ,func.getParams(event_params,'function').string_value function_name
        ,func.getParams(event_params,'materia_id_1').string_value material_id_1
        ,func.getParams(event_params,'materia_id_2').string_value material_id_2
        ,func.getParams(event_params,'materia_id_3').string_value material_id_3
        ,func.getParams(event_params,'materia_id_4').string_value material_id_4
        ,func.getParams(event_params,'materia_id_5').string_value material_id_5
        ,func.getParams(event_params,'materia_id_more').string_value material_id_more
        ,user_pseudo_id
        ,geo.country
        ,app_name
    from
        -- `beautyplus-bc0ed.analytics.ods_dz_events_tv`('2023-09-28', '2023-10-08')
        -- `beautyplus-bc0ed.analytics.ods_dz_events_tv`('2023-10-17', '2023-10-30')
        `dataintegration-265403.analytics.dwd_dzp_events_function`('2024-07-01', '2024-10-19', 'beautyplus', false)
    where
        event_name in ('h5_page_button_clk_bd')
        and func.getParams(event_params,'project').string_value='puriplus'
        and func.getParams(event_params,'button_type').string_value in ('function','tick')
)

select event_date,machine,page_id,'function' types,function_name
     ,case when button_type='function' then '功能点击'
           when button_type='tick' then '打勾确认'
     end ch_event_name
     ,count(distinct user_pseudo_id) uv
     ,sum(1) pv
from event
group by 1,2,3,4,5,6

;

select event_date,machine,page_id,function_name
     ,k
     ,count(distinct user_pseudo_id) uv
     ,sum(1) pv
from event,unnest(split(concat(coalesce(material_id_1,''),',',coalesce(material_id_2,''),',',coalesce(material_id_3,''),',',coalesce(material_id_4,''),','
            ,coalesce(material_id_5,''),',',coalesce(material_id_more,'')),',')) k
where button_type='tick' and k is not null and k != ''
group by 1,2,3,4,5

