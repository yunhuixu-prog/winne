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
        event_date_hk>='2023-10-10'
        -- event_date_hk>='2023-09-14'
        and app_name='BeautyPlus'
--         and credit_num>0
    group by 1,2,3
)
,
credit as
(
    select
        event_date
        ,order_id
        ,user_id
        ,credit_num
        ,payment_price_usd
    from
        `beautyplus-bc0ed.dwd.dwd_da_credit_credit_record`
    where
        record_type=2 -- 积分消耗
        and app_name='BeautyPlus'
        -- and event_date>='2023-09-14'
        and event_date >= '2023-10-10'
    group by
        1,2,3,4,5
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
        parse_date('%Y%m%d', event_date) >='2023-10-10'
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
        -- and func.getParams(event_params,'project').string_value in ('AI_Zodiac_Persona','AI_Image_Photo','AI_Pet_Portray','BeautyPlus_AI_V3')
    group by
        1,2,3,4,5
)

select
--     coalesce(a.event_date,c.event_date) event_date
--     ,count(distinct a.order_id) order_num_eve
--     ,count(distinct c.order_id) order_num_cre
--     ,count(distinct case when a.order_id is not null then c.order_id end) oder_num_all
--     ,sum(case when a.order_id is not null then credit_num end) credit_num_has_event
--     ,sum(credit_num) credit_num_all_event
--     ,sum(payment_price_usd) payment_price_usd
    *
from
    EVENT1 a
    join user_info b on a.user_pseudo_id=b.user_pseudo_id and b.event_date_hk =event_date and a.platform=b.platform
    full join credit c on a.order_id=c.order_id
where a.order_id is null
-- group by 1