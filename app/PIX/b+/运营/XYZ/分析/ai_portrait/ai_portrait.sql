-- ai_portrait
-- 怎么剔除测试环境啊
-- 首页miniapp的曝光量
-- 首页miniapp的点击量
-- 进入首页的用户数 uv&pv homepage
-- 首页点击图片or more的用户数 uv&pv more/image
-- 进入风格详情页的用户数 uv&pv style_page
-- 风格详情页点击上传照片的用户数 uv&pv load_photo
-- 进入相片选择页的用户数 uv&pv upload_page
-- 点击上传照片按钮的用户数 uv&pv upload_photo
-- 点击生成的用户数 uv&pv non_zero_generate_upload/zero_generate_upload
-- 进入生成记录页的用户数 uv&pv generated_page
-- 点击生成记录中的任务的用户数 uv&pv thumbnail
-- 进入效果图生成后的页面 uv&pv multi_image_page/single_image_page
-- 点击保存单张图片或所有形象照的用户数 uv&pv save or save_all
-- 点击goagain的用户数 uv&pv go_again
-- 点击去美颜的用户数 uv&pv retouch
-- 点击去点评的用户数 uv&pv feedback
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
        `dataintegration-265403.analytics.dwd_dzp_events_function`('2024-06-03', '2024-06-10', 'beautyplus,airbrush', false)
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
        ,func.getParams(event_params,'is_from_push').string_value is_from_push
        ,func.getParams(event_params,'theme').string_value theme
        ,func.getParams(event_params,'theme_type').string_value theme_type
        -- ,func.getParams(event_params,'gender').string_value gender
--         ,func.getParams(event_params,'source').string_value source
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
                when event_name in ('h5_page_event_bd','h5_page_button_clk_bd','h5_credit_consume_bd') then func.getParams(event_params,'project').string_value='ai_portrait'
                else 1=1
                end
    group by
        1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17
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
    ,if(theme_type in ('headshot','style'),theme_type,'unknown') theme_type
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
            when event_name='h5_page_event_bd' and page_id='homepage' then '3 进入miniapp首页'
            when event_name='h5_page_button_clk_bd' and button_type in ('more','image') then '4-1 点击图片/more'
            when event_name='h5_page_button_clk_bd' and button_type='genetrated_items' then '4-2 点击genetrated_items'
            when event_name='h5_page_event_bd' and page_id='style_page' then '5 进入风格详情页'
            when event_name='h5_page_button_clk_bd' and button_type='load_photo' then '6 点击选择照片'
            when event_name='h5_page_event_bd' and page_id='upload_page' then '7 进入相片选择页'
            when event_name='h5_page_button_clk_bd' and button_type='upload_photo' then '8 点击上传图片'
            when event_name='h5_page_button_clk_bd' and button_type in ('non_zero_generate_upload') then '9-1 点击14积分生成'
            when event_name='h5_page_button_clk_bd' and button_type in ('zero_generate_upload') then '9-2 点击0积分生成'
            when event_name='h5_credit_consume_bd' and credit_amount>0 then '10-1 14积分消耗成功'
            when event_name='h5_credit_consume_bd' and credit_amount=0 then '10-2 0积分消耗成功'
            when event_name='h5_page_event_bd' and page_id='generated_page' then '11 进入生成记录页'
            when event_name='h5_page_button_clk_bd' and button_type='thumbnail' then '12 点击生成任务'
            when event_name='h5_page_event_bd' and page_id in ('multi_image_page','single_image_page') then '13 进入多图/单图效果页'
            when event_name='h5_page_button_clk_bd' and (button_type='save' or button_type='save_all') then '14 点击保存单张或所有图片'
            when event_name='h5_page_button_clk_bd' and button_type='share' then '15 点击分享按钮'
            when event_name='h5_page_button_clk_bd' and button_type='go_again' then '16-1 点击go again'
            when event_name='h5_page_button_clk_bd' and button_type='retouch' then '16-2 点击去美颜'
            when event_name='h5_page_button_clk_bd' and button_type='feedback' then '16-3 点击去评价'
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



-- -- 首页曝光
-- with exposure_event as
-- (
--     select *
--     from `beautyplus-bc0ed.content_data.dws_da_h5_event_miniapp_level`
--     where event_date between '2024-06-03' and '2024-05-03' and miniapp_name='AI Studio Photo'
-- )
-- select event_date,null event_name,null image_type,'1 首页miniapp的曝光' ch_event_name,'AI_Image_Photo' project,sum(exposure_uv) uv,sum(exposure_pv) pv
-- from exposure_event
-- group by 1
--
-- union all
--
-- select event_date,null event_name,null image_type,'2 首页miniapp的点击' ch_event_name,'AI_Image_Photo' project,sum(click_uv) uv,sum(click_pv) pv
-- from exposure_event
-- group by 1
-- ;

-- 积分消耗
--aigc积分
with credit as
(
    select
        app_name
        ,order_id
        ,credit_num
        ,payment_price_usd
    from
        `beautyplus-bc0ed.dwd.dwd_da_credit_credit_record`
    where
        record_type=2 -- 积分消耗
        and app_name='BeautyPlus'
        and event_date>='2024-06-03'
    group by
        1,2,3,4

    union all

    select
        app_name
        ,order_id --d04ef5c6-ec1b-433f-9ff8-01abd4173c58/f987debe-37d7-4102-bd39-4891616c807c
        ,credits credit_num
        ,payment_price_usd
    from
        `airbrush-1324.dwd.dwd_da_credit_detail`
    where
        record_type=2 -- 积分消耗
        and app_name in ('AirBrush')
        and event_date>='2024-06-03'
    group by
        1,2,3,4
)
,
event as
(
    select
        app_name
        ,event_date
        ,platform
        ,event_timestamp
        ,event_name
        ,event_params
        ,user_properties
        ,user_pseudo_id
        ,geo.country
    from
        -- `beautyplus-bc0ed.analytics.ods_dz_events_tv`('2023-09-28', '2023-10-08')
        -- `beautyplus-bc0ed.analytics.ods_dz_events_tv`('2023-10-17', '2023-10-30')
        `dataintegration-265403.analytics.dwd_dzp_events_function`('2024-06-03', '2024-06-10', 'beautyplus,airbrush', false)
    where
        event_name in ('h5_credit_consume_bd','h5_credit_consume') --,'home_content_show_f_bd','home_content_clk_bd')
)
,
EVENT1 as
(
    select
        app_name
        ,event_date
        ,func.getParams(event_params,'project').string_value as project
        ,func.getParams(event_params,'lang').string_value lang
        ,func.getParams(event_params,'theme_type').string_value theme_type
        ,func.getParams(event_params,'theme').string_value theme
        ,k order_id
        ,user_pseudo_id
        ,count(1) as pv
    from
        event,unnest(split(func.getParams(event_params,'order_id').string_value,',')) k
    where
        event_name in ('h5_credit_consume_bd','h5_credit_consume')
        and func.getParams(event_params,'project').string_value in ('ai_portrait')
    group by
        1,2,3,4,5,6,7,8
)

select
    a.app_name
    ,event_date date
--     ,case when lang in ('ko','ja','th') then '日韩版'
--           when lang in ('en') then '欧美版'
--           when lang is null then 'null'
--     else '其他' end image_type
    ,if(theme_type in ('headshot','style'),theme_type,'unknown') theme_type
    -- ,case   when project='AI_Image_Photo' then 'AI Image Photo'
    --         else project
    --         end function
    -- ,platform
    -- ,case when is_new=1 then 'New-user' else 'Old-user' end as is_new
    -- ,country
    -- ,is_UA
    -- ,a.user_pseudo_id
--     ,if(credit_num>0,'pay','free') credit_type
    ,count(distinct a.user_pseudo_id) uv
--     ,count(distinct a.order_id) as order_num
    ,sum(pv) pv
    ,sum(credit_num) credit_num
    ,round(sum(payment_price_usd),2) payment_price_usd
from
    EVENT1 a
    join
    (
      select distinct app_name,event_date_hk,user_pseudo_id
      from `dataintegration-265403.stat.stat_active_advice_detail_d`
      where event_date_hk>='2024-06-03'
    ) b
    on a.user_pseudo_id=b.user_pseudo_id and b.event_date_hk = a.event_date and a.app_name=b.app_name
    join credit c on a.order_id=c.order_id and a.app_name=c.app_name
group by
    1,2,3
order by 1,2,3;

--
-- -- 明细
-- select date,image_type,order_num,count(distinct user_pseudo_id) num --,sum(credit_num) credit_num,sum(payment_price_usd) payment_price_usd
-- from
-- (
--     select
--         event_date date
--         ,case when lang in ('ko','ja','th') then '日韩版'
--             when lang in ('en') then '欧美版'
--             when lang is null then 'null'
--         else '其他' end image_type
--         -- ,platform
--         -- ,case when is_new=1 then 'New-user' else 'Old-user' end as is_new
--         -- ,country
--         -- ,is_UA
--         ,a.user_pseudo_id
--         ,count(distinct a.order_id) order_num
--         ,sum(pv) pv
--         ,sum(credit_num) credit_num
--         ,sum(payment_price_usd) payment_price_usd
--     from
--     EVENT1 a
--     join
--     (
--         select distinct event_date_hk,user_pseudo_id
--         from `dataintegration-265403.stat.stat_active_advice_detail_d`
--         where event_date_hk>='2023-09-28'
--     ) b
--     on a.user_pseudo_id=b.user_pseudo_id and b.event_date_hk =event_date
--     join credit c on a.order_id=c.order_id
--     group by
--         1,2,3
-- )
-- group by 1,2,3;

-- 风格订阅用户转化
-- select 'BeautyPlus' app_name,split(source2,'、')[0] theme
--     ,count(distinct uuid) sub_uv
--     ,count(distinct case when purchase_date is not null then uuid end) sub_to_pay_uv
--     ,round(sum(payment_price_usd),2) price
-- from `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_abtest`
-- where standard_order_date is not null --and purchase_date is not null
--     and event_name in ('subscription_try_suc')
--     and source2 like '%ai_portrait%'
--     and standard_order_date between '2024-06-03' and '2024-06-10'
-- group by 1,2
-- order by 1,2
--

select app_name,theme,sum(generate_success_uv) generate_success_uv,sum(credit_use_uv) credit_use_uv
     ,sum(sub_uv) sub_uv,sum(sub_pay_uv) sub_pay_uv,sum(sub_revenue) sub_revenue
from
(
    select app_name,func.getParams(event_params,'theme').string_value theme
            ,count(distinct user_pseudo_id) generate_success_uv
            ,count(distinct case when cast(func.getParams(event_params,'credit_amount').string_value as int64)>0 then user_pseudo_id end) credit_use_uv
            ,0 sub_uv
            ,0 sub_pay_uv
            ,0 sub_revenue
    from `dataintegration-265403.analytics.dwd_dzp_events_function`('2024-04-30', '2024-06-10', 'beautyplus,airbrush', false)
    where event_name in ('h5_credit_consume_bd','h5_credit_consume') and func.getParams(event_params,'project').string_value='ai_portrait'
    group by 1,2

    union all

    select 'BeautyPlus' app_name,e.theme
        ,0 generate_success_uv
        ,0 credit_use_uv
        ,count(distinct original_order_id) sub_uv
        ,count(distinct case when purchase_date is not null then original_order_id end) sub_pay_uv
        ,round(sum(case when purchase_date is not null then payment_price_usd end),2) sub_revenue
    from
    (
        select *
            ,case when source2_1 in (select distinct Bp_sub_name from `dataintegration-265403.temp.dwd_da_miniapp_miniapp_name_mapping`) then source2_1
                else source2_2
            end source2
            ,case when source2_1 in (select distinct Bp_sub_name from `dataintegration-265403.temp.dwd_da_miniapp_miniapp_name_mapping`) then source2_2
                else source2_1
            end theme
        from
        (
            select
                'BeautyPlus' app_name
                ,date
                ,platform
                ,country
                ,cur_page_type
                ,source1
                ,split(source2,'+')[0] source2_1
                ,if(ARRAY_LENGTH(split(source2,'+'))>=2,split(source2,'+')[1],null) source2_2
                ,user_pseudo_id
                ,original_order_id
                ,sku_type
                ,sku_has_trial
                ,purchase_date
                ,payment_price_usd
            from
                `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_abtest`
            where
                standard_order_date between '2024-04-30' and '2024-06-10'
                and event_name='subscription_try_suc'
                and standard_order_date is not null
                and source2 like '%ai_portrait%'
        )
    ) e
    group by 1,2

    union all

    select 'AirBrush' app_name
    --         ,event_date date
    --         ,second
            ,REPLACE(third,'_',' ') theme -- 主题
    --         ,platform
    --         ,case when is_new='New' then 1 else 0 end is_new
    --         ,country
    --         ,is_ua
            ,0 generate_success_uv
            ,0 credit_use_uv
            ,sum(sub_success_uv) sub_uv
            ,sum(sub_to_paid_uv) sub_pay_uv
            ,round(sum(sub_to_paid_revenue_sub),2) sub_revenue
    from airbrush-1324.stat.dws_airbrush_trial_sub_grads_view
    where event_date between '2024-04-30' and '2024-06-10'
        and fourth='A' and third not in ('A','all','-') and third is not null
                and second = 'ai_portraits_2'
        and sale_status not in ('credit')
    group by 1,2
)
group by 1,2

-- -- https://data.int.pixocial.com/bifrost/#/Product_Analysis/Subscription_Attribution/AirBrush_Subscription_Attribution/Third_Source
-- select 'AirBrush' app_name
-- --         ,event_date date
-- --         ,second
--         ,third -- 主题
-- --         ,platform
-- --         ,case when is_new='New' then 1 else 0 end is_new
-- --         ,country
-- --         ,is_ua
--         ,sum(sub_success_uv) sub_uv
--         ,sum(sub_to_paid_uv) sub_pay_uv
--         ,round(sum(sub_to_paid_revenue_sub),2) sub_revenue
-- from airbrush-1324.stat.dws_airbrush_trial_sub_grads_view
-- where event_date between '2024-06-03' and '2024-06-10'
--     and fourth='A' and third not in ('A','all','-') and third is not null
--             and second = 'ai_portraits_2'
--     and sale_status not in ('credit')
-- group by 1,2


-- adj onelink  cast(current_date-interval'1'day as string)
select a.app_name,a.event_date,b.is_new
     ,case when ARRAY_LENGTH(split(a.onelink_source,'='))>1 then split(a.onelink_source,'=')[1] else a.onelink_source end onelink_source
     ,count(distinct a.user_pseudo_id) uv
from
(
    select
        app_name
        ,event_name -- 标准化event_name
        ,platform -- app platform
        ,func.getParams(event_params,'onelink_source').string_value onelink_source
        ,event_date
        ,user_pseudo_id
    from
        `dataintegration-265403.analytics.dwd_dzp_events_function`('2024-06-03', '2024-06-10', 'BeautyPlus,AirBrush', false)
    where
        event_name in   ('link_app_start_bd','link_app_start')
) a
join
(
  select distinct app_name,event_date_hk,user_pseudo_id,is_new
  from `dataintegration-265403.stat.stat_active_advice_detail_d`
  where event_date_hk>='2024-06-03'
) b
on a.user_pseudo_id=b.user_pseudo_id and b.event_date_hk = a.event_date and a.app_name=b.app_name
where case when ARRAY_LENGTH(split(a.onelink_source,'='))>1 then split(a.onelink_source,'=')[1] else a.onelink_source end
          in ('1beqgntm',
                '1br3pqxh',
                '1bw3x6t9',
                '1brh3011',
                '1btl9e6f',
                '1ba2nsi3',
                '1bxlm3t7',
                '1b6gtuo9',
                '1b3rvu8g',
                '1b1gmle3',
                '1by3rpe3',
                '1blvii2z',
                '1bvd144s',
                '1b1tw7ab',
                '1bikrylo',
                '1bv8v4q9',
                '1baqu8xz',
                '1bduyqfe',
                '1bhd29by',
                '1bealja7')
group by
    1,2,3,4
order by 1,2,3,4





--
--     select
--     app_name
--     ,miniapp_name
--     ,count(distinct order_id) total_orders
--     ,count(distinct case when payment_price_usd=0 then order_id end) free_orders
--     ,sum(payment_price_usd) payment_price_usd
-- from
--     `beautyplus-bc0ed.dwd.dwd_da_credit_credit_record`
-- where
--     record_type=2 -- 积分消耗
--     and app_name in ('BeautyPlus')
--     and miniapp_name like'%Toon%'
-- group by
--     1,2
-- union all
-- select
--     app_name
--     ,function
--     ,count(distinct order_id) total_orders
--     ,count(distinct case when payment_price_usd=0 then order_id end) free_orders
--     ,sum(payment_price_usd) payment_price_usd
-- from
--     `airbrush-1324.dwd.dwd_da_credit_detail`
-- where
--     record_type=2 -- 积分消耗
--     and app_name in ('AirBrush')
--     and function like'%Toon%'
-- group by
--     1,2




-- with user_info as
-- (
--     select
--         'BeautyPlus' app_name
--         ,event_date
--         ,platform
--         ,country
--         ,user_pseudo_id
--         ,max(case when is_new='New users' then 1 else 0 end) is_new
--         ,max(is_UA) is_UA
--         ,max(is_pay) is_pay
--     from
--         `beautyplus-bc0ed.event_dataset_2.dws_dz_active_user_02`
--     where
--         event_date >= '2024-06-03'
--     group by 1,2,3,4,5
--
-- --     select app_name,event_date,user_pseudo_id,max(is_paying) is_pay
-- --     from `dataintegration-265403.temp.dau_type`
-- --     where event_date >= '2024-06-03'
-- --     group by 1,2,3
-- )
-- ,
-- event as
-- (
--     select
--         event_date
--         ,platform
--         ,event_timestamp
--         ,case when event_name in ('h5_page_event_bd','h5_page_event') then 'h5_page_event_bd'
--               when event_name in ('h5_page_button_clk_bd','h5_page_button_clk') then 'h5_page_button_clk_bd'
--               when event_name in ('h5_credit_consume_bd','h5_credit_consume') then 'h5_credit_consume_bd'
--         end event_name
--         ,event_params
--         ,user_properties
--         ,user_pseudo_id
--         ,geo.country
--         ,app_name
--     from
--         -- `beautyplus-bc0ed.analytics.ods_dz_events_tv`('2023-09-28', '2023-10-08')
--         -- `beautyplus-bc0ed.analytics.ods_dz_events_tv`('2023-10-17', '2023-10-30')
--         `dataintegration-265403.analytics.dwd_dzp_events_function`('2024-06-03', '2024-06-10', 'beautyplus,airbrush', false)
--     where
--         event_name in ('h5_page_event_bd','h5_page_button_clk_bd','h5_credit_consume_bd','h5_page_event','h5_page_button_clk','h5_credit_consume') --,'home_content_show_f_bd','home_content_clk_bd')
-- )
-- ,
-- event_pre as
-- (
--     select
--         app_name
--         ,event_date
--         ,platform
--         ,country
--         ,event_name
--         ,func.getParams(event_params,'lang').string_value lang
--         ,func.getParams(event_params,'project').string_value project
-- --         ,func.getParams(event_params,'内容ID').string_value miniapp_content_id
--         ,func.getParams(event_params,'page_id').string_value page_id
--         ,func.getParams(event_params,'button_type').string_value button_type
--         ,func.getParams(event_params,'is_from_push').string_value is_from_push
--         ,func.getParams(event_params,'theme').string_value theme
--         ,func.getParams(event_params,'theme_type').string_value theme_type
--         -- ,func.getParams(event_params,'gender').string_value gender
-- --         ,func.getParams(event_params,'source').string_value source
--         ,cast(func.getParams(event_params,'credit_amount').string_value as int64) credit_amount
--         ,func.getParams(event_params,'order_id').string_value order_id
--         ,func.getUserprop(user_properties,'hwgid').string_value hwgid
--         ,func.getUserprop(user_properties,'UserPaymentStatus').string_value is_pay
--         ,user_pseudo_id
--         ,count(1) pv
--     from
--         event
--     where
--         case
-- --                 when event_name in ('home_content_show_f_bd','home_content_clk_bd') then (func.getParams(event_params,'模块类型').string_value='miniapp' and func.getParams(event_params,'内容ID').string_value in ('BP_MIN_00000044','BP_MIN_00000045'))
--                 when event_name in ('h5_page_event_bd','h5_page_button_clk_bd','h5_credit_consume_bd') then func.getParams(event_params,'project').string_value='ai_portrait'
--                 else 1=1
--                 end
--     group by
--         1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17
-- )
--
-- select
--     e.app_name
--     ,b.is_pay
-- --     ,event_date
-- --     ,event_name
-- --     ,if(theme_type in ('headshot','style'),theme_type,'unknown') theme_type
-- --     ,case when lang in ('ko','ja','th') then '日韩版'
-- --           when lang in ('en') then '欧美版'
-- --           when lang is null then 'null'
-- --     else '其他' end image_type
--     ,case
-- --             when event_name='home_content_show_f_bd' then '1 首页miniapp的曝光'
-- --             when event_name='home_content_clk_bd' then '2 首页miniapp的点击'
--             when event_name='h5_page_event_bd' and page_id='homepage' then '3 进入miniapp首页'
--             when event_name='h5_page_button_clk_bd' and button_type in ('more','image') then '4-1 点击图片/more'
--             when event_name='h5_page_button_clk_bd' and button_type='genetrated_items' then '4-2 点击genetrated_items'
--             when event_name='h5_page_event_bd' and page_id='style_page' then '5 进入风格详情页'
--             when event_name='h5_page_button_clk_bd' and button_type='load_photo' then '6 点击选择照片'
--             when event_name='h5_page_event_bd' and page_id='upload_page' then '7 进入相片选择页'
--             when event_name='h5_page_button_clk_bd' and button_type='upload_photo' then '8 点击上传图片'
--             when event_name='h5_page_button_clk_bd' and button_type in ('non_zero_generate_upload') then '9-1 点击14积分生成'
--             when event_name='h5_page_button_clk_bd' and button_type in ('zero_generate_upload') then '9-2 点击0积分生成'
--             when event_name='h5_credit_consume_bd' and credit_amount>0 then '10-1 14积分消耗成功'
--             when event_name='h5_credit_consume_bd' and credit_amount=0 then '10-2 0积分消耗成功'
--             when event_name='h5_page_event_bd' and page_id='generated_page' then '11 进入生成记录页'
--             when event_name='h5_page_button_clk_bd' and button_type='thumbnail' then '12 点击生成任务'
--             when event_name='h5_page_event_bd' and page_id in ('multi_image_page','single_image_page') then '13 进入多图/单图效果页'
--             when event_name='h5_page_button_clk_bd' and (button_type='save' or button_type='save_all') then '14 点击保存单张或所有图片'
--             when event_name='h5_page_button_clk_bd' and button_type='share' then '15 点击分享按钮'
--             when event_name='h5_page_button_clk_bd' and button_type='go_again' then '16-1 点击go again'
--             when event_name='h5_page_button_clk_bd' and button_type='retouch' then '16-2 点击去美颜'
--             when event_name='h5_page_button_clk_bd' and button_type='feedback' then '16-3 点击去评价'
--             else event_name
--             end ch_event_name
--     ,project
-- --     ,miniapp_content_id
--     -- ,page_id
--     -- ,button_type
--     -- ,theme
--     ,count(distinct e.user_pseudo_id) uv
--     ,sum(pv) pv
-- from
--     event_pre e
--     join user_info b on e.user_pseudo_id=b.user_pseudo_id and b.event_date=e.event_date and e.app_name=b.app_name
-- where
--     hwgid not in ('2612801374','2584503074','2602108161','2588980053','2564483745','2604748400','2605846472','2579895832','2581423417','2562134868','2574054426','2618205088','2576245389','2618941525','2613607104','2563982682','2619999455','2405592903','2602265058','2564972859','2522045495','2603262761','2568172418','2400777855','2550386417','2619110102','2619987882','2612303390','2526100843','2619988205','2576247682','2567417560','2620060278','2578336951','2605846496','2551444229','2621443191','2474249969','2622802284','2597210926')
-- group by
--     1,2,3,4
-- order by 1,2,3,4
--




-- 看积分消耗国家的分布
with credit as
(
    select
        app_name
        ,order_id
        ,credit_num
        ,payment_price_usd
--         ,country
    from
        `beautyplus-bc0ed.dwd.dwd_da_credit_credit_record`
    where
        record_type=2 -- 积分消耗
        and app_name='BeautyPlus'
        and event_date>='2024-04-30'
    group by
        1,2,3,4

    union all

    select
        app_name
        ,order_id --d04ef5c6-ec1b-433f-9ff8-01abd4173c58/f987debe-37d7-4102-bd39-4891616c807c
        ,credits credit_num
        ,payment_price_usd
--         ,country
    from
        `airbrush-1324.dwd.dwd_da_credit_detail`
    where
        record_type=2 -- 积分消耗
        and app_name in ('AirBrush')
        and event_date>='2024-04-30'
    group by
        1,2,3,4
)
,
event as
(
    select
        app_name
        ,event_date
        ,platform
        ,event_timestamp
        ,event_name
        ,event_params
        ,user_properties
        ,user_pseudo_id
        ,geo.country
    from
        -- `beautyplus-bc0ed.analytics.ods_dz_events_tv`('2023-09-28', '2023-10-08')
        -- `beautyplus-bc0ed.analytics.ods_dz_events_tv`('2023-10-17', '2023-10-30')
        `dataintegration-265403.analytics.dwd_dzp_events_function`('2024-04-30', '2024-06-10', 'beautyplus,airbrush', false)
    where
        event_name in ('h5_credit_consume_bd','h5_credit_consume') --,'home_content_show_f_bd','home_content_clk_bd')
)
,
EVENT1 as
(
    select
        app_name
        ,event_date
        ,func.getParams(event_params,'project').string_value as project
        ,func.getParams(event_params,'lang').string_value lang
        ,func.getParams(event_params,'theme_type').string_value theme_type
        ,func.getParams(event_params,'theme').string_value theme
        ,k order_id
        ,user_pseudo_id
        ,count(1) as pv
    from
        event,unnest(split(func.getParams(event_params,'order_id').string_value,',')) k
    where
        event_name in ('h5_credit_consume_bd','h5_credit_consume')
        and func.getParams(event_params,'project').string_value in ('ai_portrait')
    group by
        1,2,3,4,5,6,7,8
)

select
    a.app_name
--     ,event_date date
--     ,case when lang in ('ko','ja','th') then '日韩版'
--           when lang in ('en') then '欧美版'
--           when lang is null then 'null'
--     else '其他' end image_type
--     ,if(theme_type in ('headshot','style'),theme_type,'unknown') theme_type
    ,b.country
    -- ,case   when project='AI_Image_Photo' then 'AI Image Photo'
    --         else project
    --         end function
    -- ,platform
    -- ,case when is_new=1 then 'New-user' else 'Old-user' end as is_new
    -- ,country
    -- ,is_UA
    -- ,a.user_pseudo_id
--     ,if(credit_num>0,'pay','free') credit_type
    ,count(distinct a.user_pseudo_id) uv
--     ,count(distinct a.order_id) as order_num
    ,sum(pv) pv
    ,sum(credit_num) credit_num
    ,round(sum(payment_price_usd),2) payment_price_usd
from
    EVENT1 a
    join
    (
      select distinct app_name,event_date_hk,user_pseudo_id,country
      from `dataintegration-265403.stat.stat_active_advice_detail_d`
      where event_date_hk>='2024-04-30'
    ) b
    on a.user_pseudo_id=b.user_pseudo_id and b.event_date_hk = a.event_date and a.app_name=b.app_name
    join credit c on a.order_id=c.order_id and a.app_name=c.app_name
group by
    1,2
order by 1,2;






