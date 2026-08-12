-- ai合照
-- 12.04上线


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
        `dataintegration-265403.analytics.dwd_dzp_events_function`('2023-12-18', '2023-12-31', 'beautyplus', false)
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
        ,func.getParams(event_params,'source').string_value source
        ,func.getParams(event_params,'credit_amount').string_value credit_amount
        ,func.getParams(event_params,'order_id').string_value order_id
        ,func.getUserprop(user_properties,'hwgid').string_value hwgid
        ,user_pseudo_id
        ,count(1) pv
    from
        event
    where
        case    when event_name in ('h5_page_event_bd','h5_page_button_clk_bd','h5_credit_consume_bd') then func.getParams(event_params,'project').string_value='AI_Double_Photo'
                else 1=1
                end
    group by
        1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16
)


select
    event_date
    ,case   when event_name='h5_page_event_bd' and page_id='home_page_view' then '3 进入miniapp首页'
            when event_name='h5_page_button_clk_bd' and button_type='give_it_a_try' then '4 点击give_it_a_try'
            when event_name='h5_page_button_clk_bd' and button_type='generated_items' then '4 点击genetrated_items'
            when event_name='h5_page_event_bd' and page_id='guide_page_view' then '5 进入照片上传页'
            when event_name='h5_page_button_clk_bd' and button_type='person1' then '6 点击person1'
            when event_name='h5_page_button_clk_bd' and button_type='person2' then '6 点击person2'
            when event_name='h5_page_button_clk_bd' and button_type='replace' then '6 点击replace'
            when event_name='h5_page_event_bd' and page_id='album_page_view' then '7 进入相册页'
            when event_name='h5_page_button_clk_bd' and button_type='upload' then '8 点击图片上传'
            when event_name='h5_page_event_bd' and page_id='gender_page_view' then '9 进入主体选择页'
            when event_name='h5_page_event_bd' and page_id='style_page_view' then '10 进入风格选择页'
            when event_name='h5_page_button_clk_bd' and button_type='generate' then '11 点击生成效果'
            when event_name='h5_page_event_bd' and page_id='generated_page_view' then '12 进入生成记录页'
            when event_name='h5_page_button_clk_bd' and button_type='view' then '13 点击生成成功任务'
            when event_name='h5_page_event_bd' and page_id='make_page_view' then '14 进入效果图生成页面'
            when event_name='h5_page_button_clk_bd' and (button_type='save' or button_type='save_all') then '15 点击保存单张或所有图片'
            when event_name='h5_page_button_clk_bd' and (button_type='collage' or button_type='collage_all') then '16 点击去拼图'
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
    where event_date between '2023-12-18' and '2023-12-31' and miniapp_name='AI Pair Photo'
)
select event_date,'1 首页miniapp的曝光' event_name,sum(exposure_uv) uv,sum(exposure_pv) pv
from exposure_event
group by 1

union all

select event_date,'2 首页miniapp的点击' event_name,sum(click_uv) uv,sum(click_pv) pv
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
        and event_date>='2023-12-04'
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
        parse_date('%Y%m%d', event_date) >='2023-12-04'
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
        and func.getParams(event_params,'project').string_value in ('AI_Double_Photo')
    group by
        1,2,3,4,5
)

select
    event_date date
    -- ,case   when project='AI_Pet_Portray' then 'AI Pet Portrait'
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
      where event_date_hk>='2023-12-04'
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
        where event_date_hk>='2023-12-04'
    ) b
    on a.user_pseudo_id=b.user_pseudo_id and b.event_date_hk =event_date
    join credit c on a.order_id=c.order_id
    group by
        1,2
)
group by 1,2;

