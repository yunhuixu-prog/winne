-- ai宠物写真11.2-11.9一个风格限免效果分析
-- 分析思路：1.活动前 2.活动期间 3.活动后
-- 1.活动前：整体情况，转化情况，风格购买情况
-- 2.活动期间：整体情况，转化情况，免费风格使用情况（人数，是否买了其他的风格，风格购买情况买风格人数情况）
-- 3.活动后：整体情况，转化情况，之前限免的人是否后续消费，是否带动了其他人的消费
-- 4.上述如果量还可以分个类别，分个画像看看积分消耗是哪些人，限免的又是哪些人
-- 5.也许可以看看对别的miniapp的影响
-- 几个时期不好比较啊，因为不同渠道进来的差的太大了，还没有埋点细看分渠道的，不同时期不同渠道进来的占比又差的很大，导致几个时期差别很大


-- ai宠物写真

-- 首页miniapp的曝光量
-- 首页miniapp的点击量
-- 进入ai形象照首页的用户数 uv&pv home_page_view
-- 点击 get_start的用户数 uv&pv get_start
-- 点击genetrated_items的用户数 uv&pv genetrated_items
-- 进入宠物选择页的用户数 uv&pv pet_page_view
-- 点击爪子icon选择宠物大类和设定 uv&pv next
-- 进入图片提示页的用户数 uv&pv guide_page_view
-- 点击选择图片按钮的用户数 uv&pv album
-- 进入相册页的用户数 uv&pv album_page_view
-- 点击图片上传 uv&pv upload
-- 进入风格选择页的用户数 uv&pv style_page_view
-- 点击生成效果的用户数 uv generate
-- 进入生成记录页的用户数 uv&pv generated_page_view
-- 点击生成记录中处理成功任务的用户数 uv&pv view
-- 进入效果图生成后的页面 uv&pv make_page_view
-- 点击保存单张图片或所有形象照的用户数 uv&pv save or save all
-- 点击去拼图的用户数 uv&pv collage or collage_all
-- 积分消耗人数&金额


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
        `beautyplus-bc0ed.analytics.ods_dz_events_tv`('2023-11-20', '2023-11-26')  
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
        ,`dataintegration-265403.func`.getParams(event_params,'lang').string_value lang
        ,`dataintegration-265403.func`.getParams(event_params,'project').string_value project
        ,`dataintegration-265403.func`.getParams(event_params,'内容ID').string_value miniapp_content_id
        ,`dataintegration-265403.func`.getParams(event_params,'page_id').string_value page_id
        ,`dataintegration-265403.func`.getParams(event_params,'button_type').string_value button_type
        ,`dataintegration-265403.func`.getParams(event_params,'is_from_push').string_value is_from_push
        ,`dataintegration-265403.func`.getParams(event_params,'theme').string_value theme
        ,`dataintegration-265403.func`.getParams(event_params,'source').string_value source
        ,`dataintegration-265403.func`.getParams(event_params,'credit_amount').string_value credit_amount
        ,`dataintegration-265403.func`.getParams(event_params,'order_id').string_value order_id
        ,`dataintegration-265403.func`.getUserprop(user_properties,'hwgid').string_value hwgid
        ,user_pseudo_id
        ,count(1) pv
    from 
        event
    where
        case    when event_name in ('h5_page_event_bd','h5_page_button_clk_bd','h5_credit_consume_bd') then func.getParams(event_params,'project').string_value='AI_Pet_Portray'
                else 1=1
                end
    group by 
        1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16
)


select
    event_date
    ,case   when event_name='h5_page_event_bd' and page_id='home_page_view' then '3 进入miniapp首页'
            when event_name='h5_page_button_clk_bd' and button_type='get_start' then '4 点击get_start'
            when event_name='h5_page_button_clk_bd' and button_type='genetrated_items' then '4 点击genetrated_items'
            when event_name='h5_page_event_bd' and page_id='pet_page_view' then '5 进入宠物选择页'
            when event_name='h5_page_button_clk_bd' and button_type='next' then '6 点击爪子icon选择宠物大类和设定'
            when event_name='h5_page_event_bd' and page_id='guide_page_view' then '7 进入图片提示页'
            when event_name='h5_page_button_clk_bd' and button_type='album' then '8 点击选择图片'
            when event_name='h5_page_event_bd' and page_id='album_page_view' then '9 进入相册页'
            when event_name='h5_page_button_clk_bd' and button_type='upload' then '10 点击图片上传'
            when event_name='h5_page_event_bd' and page_id='style_page_view' then '11 进入风格选择页'
            when event_name='h5_page_button_clk_bd' and button_type='generate' then '12 点击生成效果'
            when event_name='h5_page_event_bd' and page_id='generated_page_view' then '13 进入生成记录页'
            when event_name='h5_page_button_clk_bd' and button_type='view' then '14 点击生成成功任务'
            when event_name='h5_page_event_bd' and page_id='make_page_view' then '15 进入效果图生成页面'
            when event_name='h5_page_button_clk_bd' and (button_type='save' or button_type='save_all') then '16 点击保存单张或所有图片'
            when event_name='h5_page_button_clk_bd' and (button_type='collage' or button_type='collage_all') then '17 点击去拼图'
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
    where event_date between '2023-11-20' and '2023-11-26' and miniapp_name='AI Pet Portrait'
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
-- 限免的人积分表似乎无记录，就看事件表有但积分表没有的吧（确认下积分表是不是没有积分=0的记录）
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
        and event_date>='2023-10-16'
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
        parse_date('%Y%m%d', event_date) >='2023-10-16'
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
        and func.getParams(event_params,'project').string_value in ('AI_Pet_Portray')
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
    ,if(c.order_id is null,'free','no_free') is_free -- 看一下是不是积分表里都是非免费的
    ,count(distinct a.user_pseudo_id) uv -- 应该没办法看买了哪个风格吧，毕竟都记录在一条里分不开
    ,count(distinct a.order_id) order_num 
    ,sum(credit_num) credit_num
    ,round(sum(payment_price_usd),2) payment_price_usd
from 
    EVENT1 a
    join 
    (
      select distinct event_date_hk,user_pseudo_id
      from `dataintegration-265403.stat.stat_active_advice_detail_d` 
      where event_date_hk>='2023-10-16'
    ) b
    on a.user_pseudo_id=b.user_pseudo_id and b.event_date_hk =event_date
    left join credit c on a.order_id=c.order_id
group by
    1,2 --,3,4,5,6,7

union all 

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
    ,'all' is_free -- 看一下是不是积分表里都是非免费的
    ,count(distinct a.user_pseudo_id) uv -- 应该没办法看买了哪个风格吧，毕竟都记录在一条里分不开
    ,count(distinct a.order_id) order_num 
    ,sum(credit_num) credit_num
    ,round(sum(payment_price_usd),2) payment_price_usd
from 
    EVENT1 a
    join 
    (
      select distinct event_date_hk,user_pseudo_id
      from `dataintegration-265403.stat.stat_active_advice_detail_d` 
      where event_date_hk>='2023-10-16'
    ) b
    on a.user_pseudo_id=b.user_pseudo_id and b.event_date_hk =event_date
    left join credit c on a.order_id=c.order_id
group by
    1,2 --,3,4,5,6,7;


-- 订单数分布明细

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
        and event_date>='2023-10-16'
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
        parse_date('%Y%m%d', event_date) >='2023-10-16'
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
        ,k types
        ,user_pseudo_id
        ,count(1) as pv
    from
        event,unnest(split(func.getParams(event_params,'source').string_value,',')) k
    where
        event_name in ('h5_credit_consume_bd')
        and func.getParams(event_params,'project').string_value in ('AI_Pet_Portray')
    group by 
        1,2,3,4,5
)

select date,type_num,count(distinct user_pseudo_id) num
from
(
    select
        event_date date 
        -- ,platform
        -- ,case when is_new=1 then 'New-user' else 'Old-user' end as is_new
        -- ,country
        -- ,is_UA
        ,a.user_pseudo_id
        ,count(distinct a.types) type_num
        ,sum(pv) pv
    from 
    EVENT1 a
    join 
    (
        select distinct event_date_hk,user_pseudo_id
        from `dataintegration-265403.stat.stat_active_advice_detail_d` 
        where event_date_hk>='2023-10-16'
    ) b
    on a.user_pseudo_id=b.user_pseudo_id and b.event_date_hk =event_date
    group by
        1,2
)
group by 1,2;


-- 各个风格消耗情况

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
        and event_date>='2023-10-16'
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
        parse_date('%Y%m%d', event_date) >='2023-10-16'
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
        ,k types
        ,user_pseudo_id
        ,count(1) as pv
    from
        event,unnest(split(func.getParams(event_params,'source').string_value,',')) k
    where
        event_name in ('h5_credit_consume_bd')
        and func.getParams(event_params,'project').string_value in ('AI_Pet_Portray')
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
    ,types
    ,count(distinct a.user_pseudo_id) uv 
from 
    EVENT1 a
    join 
    (
      select distinct event_date_hk,user_pseudo_id
      from `dataintegration-265403.stat.stat_active_advice_detail_d` 
      where event_date_hk>='2023-10-16'
    ) b
    on a.user_pseudo_id=b.user_pseudo_id and b.event_date_hk =event_date
group by
    1,2 --,3,4,5,6,7;




-- 使用了限免的用户的情况

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
        and event_date>='2023-10-16'
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
        parse_date('%Y%m%d', event_date) >='2023-10-16'
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
        -- and func.getParams(event_params,'project').string_value in ('AI_Pet_Portray')
    group by 
        1,2,3,4,5
)
,
user as 
(
    select a.user_pseudo_id,'free' user_type,
        min(event_date) event_date
    from 
    EVENT1 a
    join 
    (
        select distinct event_date_hk,user_pseudo_id
        from `dataintegration-265403.stat.stat_active_advice_detail_d` 
        where event_date_hk>='2023-10-16'
    ) b
    on a.user_pseudo_id=b.user_pseudo_id and b.event_date_hk =event_date
    left join credit c on a.order_id=c.order_id
    where c.order_id is null and project='AI_Pet_Portray' 
        and a.event_date between '2023-11-02' and '2023-11-09'
    group by
        1

    union all 

    select a.user_pseudo_id,'no free on activity' user_type,
        min(event_date) event_date
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
    where project='AI_Pet_Portray' 
        and a.event_date between '2023-11-02' and '2023-11-09'
    group by
        1
    
    union all 

    select a.user_pseudo_id,'no free before activity' user_type,
        min(event_date) event_date
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
    where project='AI_Pet_Portray' 
        and a.event_date between '2023-10-16' and '2023-11-01'
    group by
        1
)

-- 参与活动人数
select user_type,count(distinct user_pseudo_id)
from user
group by user_type;


-- 是否消费了其他&后续是否消费了
select
    -- a.event_date date,
    user_type,
    if(a.event_date=b.event_date,'today','after') buy_time 
    ,'AI_Pet_Portray' types
    ,count(distinct a.user_pseudo_id) uv 
    ,count(distinct a.order_id) order_num 
    ,sum(credit_num) credit_num
    ,round(sum(payment_price_usd),2) payment_price_usd
from 
    EVENT1 a
    join credit c on a.order_id=c.order_id
    join user b
    on a.user_pseudo_id=b.user_pseudo_id and a.event_date>=b.event_date
where project='AI_Pet_Portray'
group by
    1,2 --,3,4,5,6,7

union all 

select
    -- a.event_date date,
    user_type,
    'all' buy_time 
    ,'AI_Pet_Portray' types
    ,count(distinct a.user_pseudo_id) uv 
    ,count(distinct a.order_id) order_num 
    ,sum(credit_num) credit_num
    ,round(sum(payment_price_usd),2) payment_price_usd
from 
    EVENT1 a
    join credit c on a.order_id=c.order_id
    join user b
    on a.user_pseudo_id=b.user_pseudo_id and a.event_date>=b.event_date
where project='AI_Pet_Portray'
group by
    1,2 --,3,4,5,6,7

union all 


select
    -- a.event_date date,
    user_type,
    'all' buy_time 
    ,'all' types
    ,count(distinct a.user_pseudo_id) uv 
    ,count(distinct a.order_id) order_num 
    ,sum(credit_num) credit_num
    ,round(sum(payment_price_usd),2) payment_price_usd
from 
    EVENT1 a
    join credit c on a.order_id=c.order_id
    join user b
    on a.user_pseudo_id=b.user_pseudo_id and a.event_date>b.event_date
group by
    1,2 --,3,4,5,6,7



