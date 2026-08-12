--aigc积分
-- drop table if exists `beautyplus-bc0ed.temp.dws_credit_aigc_new`;
-- create table if not exists `beautyplus-bc0ed.temp.dws_credit_aigc_new`  as 
-- BeautyPlus_391_dws_aigc_new
delete from `beautyplus-bc0ed.temp.dws_credit_aigc_new` where date>= '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}';
insert into  `beautyplus-bc0ed.temp.dws_credit_aigc_new`
with user_info as 
(
    select 
        event_date_hk
        ,platform
        ,user_pseudo_id
        ,max(country) country
        ,max(is_new) is_new
        ,max(is_UA) is_UA
    from 
        `dataintegration-265403.stat.stat_active_advice_detail_d`
    where 
        event_date_hk>='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}'
        -- event_date_hk>='2023-09-14'
        and app_name='BeautyPlus'
    group by 1,2,3
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
        -- and event_date>='2023-09-14'
        and event_date >= '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}'
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
        -- parse_date('%Y%m%d', event_date) >='2023-09-14'
        parse_date('%Y%m%d', event_date) >='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}'
        and platform in ('IOS','ANDROID')  
        and event_name='h5_credit_consume_bd'
)
,
EVENT1 as
(
    select
        parse_date('%Y%m%d', event_date) event_date
        ,platform
        ,func.getParams(event_params,'project').string_value as project
        ,k order_id
        ,user_pseudo_id
        ,count(1) as pv
    from
        event,unnest(split(func.getParams(event_params,'order_id').string_value,',')) k
    where
        event_name in ('h5_credit_consume_bd')
        and func.getParams(event_params,'project').string_value in ('AI_Zodiac_Persona','AI_Image_Photo','AI_Pet_Portray','BeautyPlus_AI_V3','AI_Double_Photo','ai_portrait','ai_filter')
    group by 
        1,2,3,4,5
)

select
    event_date date 
    ,case   when project='AI_Zodiac_Persona' then 'AI Zodiac Persona'
            when project='AI_Image_Photo' then 'AI Image Photo'
            when project='AI_Pet_Portray' then 'AI Pet Portray'
            when project='BeautyPlus_AI_V3' then 'BeautyPlus_AI V3'
            when project='AI_Double_Photo' then 'AI Pair Photo'
            when project='ai_portrait' then 'AI Portrait 2.0'
            when project='ai_filter' then 'AI Filter 1.0'
            else project 
            end function
    ,a.platform
    ,case when is_new=1 then 'New-user' else 'Old-user' end as is_new
    ,country
    ,is_UA
    ,a.user_pseudo_id
    ,sum(pv) pv
    ,sum(credit_num) credit_num
    ,sum(payment_price_usd) payment_price_usd
from 
    EVENT1 a
    join user_info b on a.user_pseudo_id=b.user_pseudo_id and b.event_date_hk =event_date and a.platform=b.platform
    join credit c on a.order_id=c.order_id
group by
    1,2,3,4,5,6,7