-- miniapp 渠道数据
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
        ,app_info.version version
    from
        `dataintegration-265403.analytics.dwd_dzp_events_function`('2023-12-17', '2023-12-17', 'beautyplus', false)
    where
     event_name in ('h5_page_event_bd') --,'h5_effect_page_clk_bd','h5_home_page_clk_bd','h5_page_button_clk_bd','h5_page_clk_bd','h5_preview_save_bd','h5_result_share_bd','web_view_share_bd','share_page_clk_bd')
)
select event_date
    ,`dataintegration-265403.func`.getParams(event_params,'from_page').string_value from_page
    ,`dataintegration-265403.func`.getParams(event_params,'project').string_value project
    ,version
    ,count(distinct user_pseudo_id)
from event
where event_name in ('h5_page_event_bd')
    -- and `dataintegration-265403.func`.getParams(event_params,'project').string_value='AI_Double_Photo'
    and `dataintegration-265403.func`.getParams(event_params,'page_id').string_value='home_page_view'
group by 1,2,3,4
order by 1,3,4,2




-- 查事件表里的积分情况
with event as
(     
    select
        *    
    from
        `beautyplus-bc0ed.analytics.stage_dz_event_view` 
    where  
        parse_date('%Y%m%d', event_date) >='2023-10-16' 
        -- and platform in ('IOS','ANDROID')  
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

select sum(num) num
from  
(
    select event_date,count(distinct order_id) num
    from EVENT1 
    where event_date between '2023-10-16' and '2023-10-29'
    group by event_date
)


-- 查看积分表里的积分情况
    select
        event_date
        ,sum(credit_num)
        ,sum(payment_price_usd)
    from
        `beautyplus-bc0ed.dwd.dwd_da_credit_credit_record`
    where
        record_type=2 -- 积分消耗
        and app_name='BeautyPlus'
        and event_date between '2023-10-23' and '2023-10-24'
    group by
        1

-- 查看每天的积分数据
with user_info as 
(
    select 
        event_date_hk
        ,app_name
        ,platform
        ,country
        ,user_pseudo_id
        ,max(uuid) uuid
        ,max(is_new) is_new
        ,max(is_UA) is_UA
        ,max(app_version) app_version
    from 
        `dataintegration-265403.stat.stat_active_advice_detail_d`
    where 
        event_date_hk between date'2023-10-23' and '2023-10-24'  -- 修改查询的数据时间
        and app_name='BeautyPlus'
    group by 1,2,3,4,5
) 
,
credit as 
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
        and event_date between '2023-10-23' and '2023-10-24'
    group by
        1,2,3
)
,
credit_event as
(     
    select
        *    
    from
        `beautyplus-bc0ed.analytics.stage_dz_event_view` 
    where  
        parse_date('%Y%m%d', event_date) between '2023-10-23' and '2023-10-24'
        and platform in ('IOS','ANDROID')  
        and event_name='h5_credit_consume_bd'
)
,
dws_credit_event as
(
    select
        parse_date('%Y%m%d', event_date) event_date
        ,platform
        ,func.getParams(event_params,'project').string_value as project
        ,k order_id
        ,user_pseudo_id
        ,count(1) as pv
    from
        credit_event,unnest(split(func.getParams(event_params,'order_id').string_value,',')) k
    where
        event_name in ('h5_credit_consume_bd')
    group by 
        1,2,3,4,5
)

select
    event_date date 
    ,miniapp miniapp_name
    ,count(distinct a.user_pseudo_id) credit_use_uv
    ,sum(pv) credit_use_pv
    ,sum(credit_num) credit_num
    ,sum(payment_price_usd) payment_price_usd
from 
    dws_credit_event a
    join user_info u on a.user_pseudo_id=u.user_pseudo_id and a.event_date=u.event_date_hk and a.platform = u.platform
    join credit c on a.order_id=c.order_id
    left join (select buried_miniapp,max(miniapp) miniapp,max(status) status from `beautyplus-bc0ed.content_data.dwd_da_miniapp_status` group by 1) s on a.project=s.buried_miniapp
group by
    1,2



-- 查看save的情况
with event as
(     
    select 
        event_date
        ,event_name
        ,func.getParams(event_params,'button_type').string_value button_type
        ,func.getParams(event_params,'theme_type').string_value theme_type
        ,func.getParams(event_params,'is_bundle').string_value is_bundle
        ,user_properties
        ,user_pseudo_id
        ,geo.country
    from      
        `beautyplus-bc0ed.analytics.ods_dz_events_tv`('2023-10-07', '2023-10-08')  
    where
        event_name in ('h5_page_button_clk_bd') and func.getParams(event_params,'project').string_value='AI_Zodiac_Persona' 
)

select button_type,count(1)
from 
    event e 
where button_type like '%save%'
group by 1

-- 查看首页点击的情况

with event as
(     
    select 
        event_date
        ,func.getParams(event_params,'project').string_value project
        ,func.getParams(event_params,'内容ID').string_value miniapp_content_id
    from      
        `beautyplus-bc0ed.analytics.ods_dz_events_tv`('2023-10-07', '2023-10-08')  
    where
        event_name in ('home_content_clk_bd') and func.getParams(event_params,'模块类型').string_value='miniapp'
)

    select distinct project,miniapp_content_id
    from 
        event


-- 查看push的情况

with event as
(     
    select 
        event_date
        ,func.getParams(event_params,'project').string_value project
        ,func.getParams(event_params,'is_from_push').string_value is_from_push
    from      
        `beautyplus-bc0ed.analytics.ods_dz_events_tv`('2023-10-07', '2023-10-08')  
    where
        event_name in ('h5_page_event_bd') and func.getParams(event_params,'project').string_value='AI_Image_Photo' 
)

    select distinct is_from_push
    from 
        event

-- 查看更新了的miniapp表有没有问题
select event_date,miniapp_name,from_page --,is_pay,version,from_page
    ,sum(exposure) exposure
    ,sum(exposure_miniapp) exposure_miniapp
    ,sum(exposure_banner) exposure_banner
    ,sum(exposure_popup) exposure_popup
    ,sum(exposure_search) exposure_search
    ,sum(click) click
    ,sum(visit) visit
    ,sum(click_miniapp) click_miniapp
    ,sum(click_banner) click_banner
    ,sum(click_popup) click_popup
    ,sum(click_search) click_search
    ,sum(enter_generate_page) enter_generate_page
    ,sum(generate) generate
    ,sum(save) save
    ,sum(share) share
    ,sum(share_user) share_user
    ,sum(sub) sub
    ,sum(credit_use) credit_use
    ,sum(credit_topup_imp) credit_topup_imp
    ,sum(credit_topup_clk) credit_topup_clk
    ,sum(credit_topup_suc) credit_topup_suc
    ,sum(credit_num) credit_num
    ,sum(payment_price_usd) payment_price_usd
from `beautyplus-bc0ed.aigc.dws_dzp_aigc_h5_event_miniapp_level_v2`
where event_date>='2024-01-13'
-- and from_page='All'
and data_type='uv'
group by 1,2,3
order by 1,2,3;
select event_date,miniapp_name --,is_pay,version,from_page
    ,sum(exposure_uv) exposure_uv
    ,sum(exposure_pv) exposure_pv
    ,sum(exposure_miniapp_uv) exposure_miniapp_uv
    ,sum(exposure_miniapp_pv) exposure_miniapp_pv
    ,sum(exposure_banner_uv) exposure_banner_uv
    ,sum(exposure_popup_uv) exposure_popup_uv
    ,sum(click_uv) click_uv
    ,sum(click_miniapp_uv) click_miniapp_uv
    ,sum(click_banner_uv) click_banner_uv
    ,sum(click_popup_uv) click_popup_uv
    ,sum(enter_generate_page_uv) enter_generate_page_uv
    ,sum(enter_generate_page_pv) enter_generate_page_pv
    ,sum(generate_uv) generate_uv
    ,sum(generate_pv) generate_pv
    ,sum(save_uv) save_uv
    ,sum(share_uv) share_uv
    ,sum(share_uv_user) share_uv_user
    ,sum(sub_uv) sub_uv
    ,sum(credit_use_uv) credit_use_uv
    ,sum(credit_topup_imp_uv) credit_topup_imp_uv
    ,sum(credit_topup_clk_uv) credit_topup_clk_uv
    ,sum(credit_topup_suc_uv) credit_topup_suc_uv
    ,sum(credit_num) credit_num
    ,sum(payment_price_usd) payment_price_usd
from `beautyplus-bc0ed.content_data.dws_da_h5_event_miniapp_level`
where event_date>='2024-01-13'
group by 1,2
order by 1,2


-- 宠物写真后面步骤的uv比前面步骤多
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
        `beautyplus-bc0ed.analytics.ods_dz_events_tv`('2023-10-16', '2023-10-30')  
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
        case    when event_name in ('h5_page_event_bd','h5_page_button_clk_bd','h5_credit_consume_bd') then func.getParams(event_params,'project').string_value='AI_Pet_Portray'
                else 1=1
                end
    group by 
        1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16
)

select *
from 
(
    select e.*
    from event_pre e 
    join `dataintegration-265403.stat.stat_active_advice_detail_d` b on e.user_pseudo_id=b.user_pseudo_id and b.event_date_hk=event_date
    where hwgid not in ('2612801374','2584503074','2602108161','2588980053','2564483745','2604748400','2605846472','2579895832','2581423417','2562134868','2574054426','2618205088','2576245389','2618941525','2613607104','2563982682','2619999455','2405592903','2602265058','2564972859','2522045495','2603262761','2568172418','2400777855','2550386417','2619110102','2619987882','2612303390','2526100843','2619988205','2576247682','2567417560','2620060278','2578336951','2605846496','2551444229','2621443191')
        and (event_name='h5_page_event_bd' and page_id='guide_page_view')
) a
left join 
(
    select e.*
    from event_pre e 
    join `dataintegration-265403.stat.stat_active_advice_detail_d` b on e.user_pseudo_id=b.user_pseudo_id and b.event_date_hk=event_date
    where hwgid not in ('2612801374','2584503074','2602108161','2588980053','2564483745','2604748400','2605846472','2579895832','2581423417','2562134868','2574054426','2618205088','2576245389','2618941525','2613607104','2563982682','2619999455','2405592903','2602265058','2564972859','2522045495','2603262761','2568172418','2400777855','2550386417','2619110102','2619987882','2612303390','2526100843','2619988205','2576247682','2567417560','2620060278','2578336951','2605846496','2551444229','2621443191')
        and (event_name='h5_page_button_clk_bd' and button_type='next') 
) b
on a.user_pseudo_id=b.user_pseudo_id and a.event_date=b.event_date
where b.user_pseudo_id is null


    select event_date
        ,platform
        ,event_name
        ,event_timestamp
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
    from `beautyplus-bc0ed.analytics.ods_dz_events_tv`('2023-10-24', '2023-10-24')  
    where event_name in ('h5_page_event_bd','h5_page_button_clk_bd','h5_credit_consume_bd')
        and user_pseudo_id='C68C72F1A96F4D079A42E32A76A2A70A'


-- 查看share miniapp和其他分享的数据差别

-- 保存事件研究一下
with event as
(     
    select 
        event_date
        ,platform
        ,event_timestamp
        ,event_name
        ,func.getParams(event_params,'lang').string_value lang
        ,func.getParams(event_params,'project').string_value project
        ,func.getParams(event_params,'内容ID').string_value miniapp_content_id
        ,func.getParams(event_params,'page_id').string_value page_id
        ,func.getParams(event_params,'button_type').string_value button_type
        ,func.getParams(event_params,'is_from_push').string_value is_from_push
        ,func.getParams(event_params,'page_type').string_value page_type
        ,func.getParams(event_params,'h5_id').string_value h5_id
        ,func.getParams(event_params,'theme').string_value theme
        ,func.getParams(event_params,'source').string_value source
        ,func.getParams(event_params,'credit_amount').string_value credit_amount
        ,func.getParams(event_params,'order_id').string_value order_id
        ,func.getUserprop(user_properties,'hwgid').string_value hwgid
        ,user_pseudo_id
        ,geo.country
    from      
        -- `beautyplus-bc0ed.analytics.ods_dz_events_tv`('2023-09-28', '2023-10-08')  
        `beautyplus-bc0ed.analytics.ods_dz_events_tv`('2023-10-18', '2023-10-18')  
    where
        (event_name in ('h5_page_button_clk_bd') and func.getParams(event_params,'project').string_value in ('AI_Image_Photo','AI_Pet_Portray','BeautyPlus_AI_V3') and func.getParams(event_params,'button_type').string_value like '%share%')
        or 
        (event_name in ('web_view_share_bd') and func.getParams(event_params,'page_type').string_value is not null)
        or 
        (event_name in ('share_page_clk_bd') and func.getParams(event_params,'h5_id').string_value is not null)
)
,
event_pre as
(
    select
        event_date
        ,platform
        ,country
        ,event_name
        ,project
        ,case 
              when event_name='web_view_share_bd' then page_type
              when event_name='share_page_clk_bd' then h5_id
        end material
        ,button_type
        ,hwgid
        ,user_pseudo_id
        ,count(1) pv
    from 
        event
    where    
        hwgid not in ('2612801374','2584503074','2602108161','2588980053','2564483745','2604748400','2605846472','2579895832','2581423417','2562134868','2574054426','2618205088','2576245389','2618941525','2613607104','2563982682','2619999455','2405592903','2602265058','2564972859','2522045495','2603262761','2568172418','2400777855','2550386417','2619110102','2619987882','2612303390','2526100843','2619988205','2576247682','2567417560','2620060278','2578336951','2605846496','2551444229','2621443191')
    group by 
        1,2,3,4,5,6,7,8,9
)

select
    event_date
    ,project
    ,miniapp
    ,event_name
    ,count(distinct e.user_pseudo_id) uv
    ,count(1) pv
from 
    event_pre e 
join `dataintegration-265403.stat.stat_active_advice_detail_d` b on e.user_pseudo_id=b.user_pseudo_id and b.event_date_hk=event_date
left join 
(select material_id,max(miniapp) miniapp from `beautyplus-bc0ed.content_data.dwd_da_miniapp_material_mapping` group by 1) m 
on e.material=m.material_id
group by
    1,2,3,4


-- miniapp素材核查
with event as
(     
    select 
        event_date
        ,'generate' event_name
        ,func.getParams(event_params,'theme').string_value theme
        ,user_pseudo_id
    from      
        `beautyplus-bc0ed.analytics.ods_dz_events_tv`('2023-09-20', '2023-09-20')  
    where
        event_name in ('h5_page_button_clk_bd') 
            and func.getParams(event_params,'project').string_value='BeautyPlus_AI'
            and func.getParams(event_params,'button_type').string_value='generate'
            and func.getParams(event_params,'theme').string_value='Barbie'
    
    union all 

    select 
        event_date
        ,'click' event_name
        ,func.getParams(event_params,'theme').string_value theme
        ,user_pseudo_id
    from      
        `beautyplus-bc0ed.analytics.ods_dz_events_tv`('2023-10-18', '2023-10-19')  
    where
        event_name in ('h5_home_content_clk_bd') 
            and func.getParams(event_params,'project').string_value='BeautyPlus_AI3'
            and func.getParams(event_params,'theme').string_value='Barbie'
)

    select event_name,count(distinct user_pseudo_id) uv,count(1) pv
    from 
        event
    group by 1

-- miniapp部分素材只有点击没有曝光
    select event_date,event_timestamp,event_name,country,version,
        `dataintegration-265403.func`.getParams(event_params,'theme').string_value
    from
        `dataintegration-265403.analytics.dwd_dzp_events_function`('2023-12-25', '2023-12-31', 'beautyplus', false)
    where
        event_name in ('h5_home_content_show_f_bd','h5_home_content_clk_bd')
        and `dataintegration-265403.func`.getParams(event_params,'project').string_value='AI_Image_Photo'
        -- and `dataintegration-265403.func`.getParams(event_params,'theme').string_value in ('punk')
        and user_pseudo_id='96dcbbb0a37382c6ee43cb6904f62397'
    order by event_timestamp


