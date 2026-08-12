with abcode as
(
    select
        date_p
        ,cast(ab_code as string) code
        ,field as device_id
        ,country_id
        ,country
        ,case when is_app_new='2' then 'new user' when is_app_new='1' then 'old user' end as is_new
        ,case when app_key in ('F9B069901A7B2E8D') then 'IOS' when app_key in ('C6FF0769324CD2F1') then 'ANDROID' end as platform,receive_time as timestamp
    from
        `dataintegration-265403.abtest.abtest_odz_flow` a --2.第一次进入实验用户
        left join   (select
                        event_date
                        ,device_id
                        ,max(country) country
                    from
                        `dataintegration-265403.abtest.stage_aa_meepo_enter_event`
                    group by
                        1,2 ) b on a.date_p = b.event_date and a.field = b.device_id
    where
        case    when app_key in ('F9B069901A7B2E8D')  then (date_p>='2024-02-02' and date_p<='2024-03-08')
                when app_key in ('C6FF0769324CD2F1') then (date_p>='2024-02-23' and date_p<='2024-03-24')
                end
        and cast(ab_code as string) in ('10481','10482','10483','10484')
        and field_type = 3 --field是3 device-id
        and app_key in ('F9B069901A7B2E8D','C6FF0769324CD2F1')
)
,
event_all as
(
    select
        event_date
        ,event_name
        ,event_params
        ,receive_time as event_timestamp
        ,platform
        ,meepo_abcode
        ,device_id
        ,country
        ,user_pseudo_id
    from
        `dataintegration-265403.abtest.stage_aa_meepo_abcountgt1_event`
    where
        app_name in ('BeautyPlus')
        and case    when platform='IOS' then (event_date>='2024-02-02' and event_date<='2024-03-08')
                    when platform='ANDROID' then (event_date>='2024-02-23' and event_date<='2024-03-24')
                    end
        and cast(meepo_abcode as string) in ('10481','10482','10483','10484')
        and device_id is not null --limit 100
)
,
event_ab as
(
    select
        m.event_date
        ,m.event_timestamp
        ,m.platform
        ,case   when a.country in ('United States','Thailand','South Korea','Japan') then a.country
                else 'WW'
                end as country
        ,m.event_name
        ,m.user_pseudo_id
        ,a.device_id
        ,m.credit_amount
        ,m.sku_id
        ,m.unit
        ,m.order_id
        ,a.code
        ,case   when a.code in ('10481','10483') then '对照组'
                when a.code in ('10482','10484') then '实验组'
                end as code_type
        ,a.is_new
    from
        (select
            event_date
            ,event_timestamp
            ,platform
            ,country
            ,event_name
            ,user_pseudo_id
            ,device_id
            ,func.getParams(event_params,'credit_amount').string_value credit_amount
            ,func.getParams(event_params,'sku_id').string_value sku_id
            ,func.getParams(event_params,'unit').string_value unit
            ,func.getParams(event_params,'order_id').string_value order_id
        from
            event_all
        where
            event_name in  ('credit_page_bd','credit_purchase_clk_bd','credit_purchase_suc_bd')
        ) m
        join abcode a on  m.device_id=a.device_id  and m.platform=a.platform and m.event_timestamp>=a.timestamp-15000000 --15s
)

select
    case   when event_name in ('credit_page_bd') then '6:credit enter'
            when event_name in ('credit_purchase_clk_bd') then '7:credit click'
            else event_name end as event_name
    ,a.platform
--     ,a.country region
    -- ,is_new
    ,code_type
--     ,null source
--     ,credit_amount sku_type
--     ,null sku_has_trial
--     -- ,sku
--     ,unit sku_tag
    -- ,sub_user_type
    ,count(distinct a.device_id) value
    ,count(1) pv
from
    event_ab a
where
    event_name not in ('credit_purchase_suc_bd')
--         and platform='ANDROID'
group by
    1,2,3

union all

select
    '8:credit_purchase_success' as event_name
    ,a.platform
--     ,a.country region
    -- ,is_new
    ,code_type
--     ,null source
--     ,credit_amount sku_type
--     ,null sku_has_trial
--     -- ,sku
--     ,unit sku_tag
    -- ,sub_user_type
    ,count(distinct a.device_id) value
    ,count(1) pv
from
    event_ab a
where
    event_name in ('credit_purchase_suc_bd')
--         and platform='ANDROID'
group by
    1,2,3

union all

select
    '9:credit_purchase_suc amount' as event_name
    ,a.platform
--     ,a.country region
    -- ,is_new
    ,code_type
--     ,null source
--     ,credit_amount sku_type
--     ,null sku_has_trial
--     -- ,sku
--     ,unit sku_tag
    -- ,sub_user_type
    ,round(sum(cast(unit as integer)*cast(credit_amount as integer)),2) value
    ,count(1) pv
from
    event_ab a
where
    event_name in ('credit_purchase_suc_bd')
--         and platform='ANDROID'
group by 1,2,3

union all

select
    '10:credit_purchase_suc revenue' as event_name
    ,e.platform
--     ,e.country region
    -- ,is_new
    ,code_type
--     ,null source
--     ,credit_amount sku_type
--     ,null sku_has_trial
--     -- ,sku
--     ,unit sku_tag
    -- ,sub_user_type
    ,round(sum(payment_price_usd),2) value
    ,count(1) pv
from
    event_ab e
    left join   (select
                    aw_trans_id
                    ,order_id
                from
                    `dataintegration-265403.aw_v2.stage_aw_order_log`
                where
                    app_name='BeautyPlus'
                    and order_id is not null
                    and order_id!=''
                group by
                    1,2) a on e.order_id=aw_trans_id
    join `dataintegration-265403.purchase.dwd_da_purchase_daily` o on (o.order_id=a.order_id or o.order_id=e.order_id)
where
    event_name in ('credit_purchase_suc_bd')
--         and e.platform='ANDROID'
group by
    1,2,3


