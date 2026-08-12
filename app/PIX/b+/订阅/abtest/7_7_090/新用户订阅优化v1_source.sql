-- 进入实验记录的时间可能和该事件发生的时间对不上，需要gap个几秒
with abcode as
(
    select
        date_p
        ,cast(ab_code as string) code
        ,field as device_id
        ,country_id
        ,country
        ,b.user_pseudo_id
        ,case when is_app_new='2' then 'new user' when is_app_new='1' then 'old user' end as is_new
        ,case when app_key in ('F9B069901A7B2E8D') then 'IOS' when app_key in ('C6FF0769324CD2F1') then 'ANDROID' end as platform,receive_time as timestamp
    from
        `dataintegration-265403.abtest.abtest_odz_flow` a --2.第一次进入实验用户
--         left join
        join
            (select
                        event_date
                        ,device_id
                        ,user_pseudo_id
                        ,max(country) country
                    from
                        `dataintegration-265403.abtest.stage_aa_meepo_enter_event`
                    group by
                        1,2,3 ) b on a.date_p = b.event_date and a.field = b.device_id
     where
        case    when app_key in ('F9B069901A7B2E8D')  then (date_p between '2024-05-06' and '2024-06-03')
                when app_key in ('C6FF0769324CD2F1') then (date_p between '2024-05-06' and '2024-06-03')
                end
        and cast(ab_code as string) in ('10639','10640','10642','10643')
        and field_type = 3 --field是3 device-id
        and app_key in ('F9B069901A7B2E8D','C6FF0769324CD2F1')
)
,
user_info as
(
    select
        s.date_p
        ,s.platform
        ,s.device_id
        ,s.code
        ,s.country
        ,s.timestamp
        ,max(u.is_new) is_new
        ,max(u.is_UA) is_UA
    from
        abcode s
    join `dataintegration-265403.stat.stat_active_advice_detail_d` u
    on s.date_p=u.event_date_hk and s.user_pseudo_id=u.user_pseudo_id  and s.platform=u.platform
    group by 1,2,3,4,5,6
)
,
-- -- 限制用户进入过额度管理页
-- event_all as
-- (
--     select
--         event_date
--         ,event_name
--         ,event_params
--         ,receive_time as event_timestamp
--         ,platform
--         ,meepo_abcode
--         ,device_id
--         ,country
--         ,user_pseudo_id
--     from
--         `dataintegration-265403.abtest.stage_aa_meepo_abcountgt1_event`
--     where
--         app_name in ('BeautyPlus')
--         and case    when platform='IOS' then (event_date between '2024-05-06' and '2024-06-03')
--                     when platform='ANDROID' then (event_date between '2024-05-06' and '2024-06-03')
--                     end
--         and cast(meepo_abcode as string) in ('10639','10640','10642','10643')
--         and device_id is not null --limit 100
-- )
-- ,
-- ab_user as
-- (
--     select
--         a.date_p
--         ,a.platform
--         ,a.device_id
--         ,a.code
--         ,a.country
--         ,a.timestamp
--         ,a.is_new
--     from
--         (select
--             event_date
--             ,event_timestamp
--             ,platform
--             ,country
--             ,event_name
--             ,user_pseudo_id
--             ,device_id
--         from
--             event_all
--         where
--             event_name in  ('credit_page_bd')
--         ) m
--         join abcode a on  m.device_id=a.device_id  and m.platform=a.platform and m.event_timestamp>=a.timestamp-15000000 --15s
-- )
-- ,
subscription_event as
(
    select
        *
    from
        `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_abtest`
    where
        case    when platform='IOS' then (date between '2024-05-06' and '2024-06-03')
                when platform='ANDROID' then (date between '2024-05-06' and '2024-06-03')
                end
        -- and meepo_abcode>=10146 and  meepo_abcode<=10153
        -- and cast(meepo_abcode as string) in ('10256', '10257','10258','10259')
        and device_id is not null
        -- and source2<>'OnboardingPage'
)
,
ab_sub_event as
(
    select distinct
        a.date
        ,a.platform
        ,a.country
        ,case when a.country in ('South Korea','Thailand','Japan','United States') then a.country else 'WW' end as region
        ,case   when u.code in ('10639','10642') then '对照组'
                when u.code in ('10640','10643') then '实验组A'
                end code
        ,case   when source2 in ('首页订阅横幅','修图编辑页-默认入口','自拍页新用户icon') then '倒计时横幅'
                else 'others'
                end source
        ,a.sku_type
        ,a.sku_has_trial
        ,a.sku
        ,a.sku_tag
        ,a.sub_user_type
        ,a.event_name
        ,source2
        -- ,a.category1
        ,u.is_new
        ,u.is_ua
        ,a.user_pseudo_id
        ,a.device_id
        ,new_uuid
        ,a.payment_price_usd
        ,purchase_date
        ,standard_order_date
        ,cur_page_type
        ,a.timestamp
    from
        (select distinct
            date
            ,event_timestamp timestamp
            ,device_id
            ,platform
            ,country
            ,sku_type
            ,sku_has_trial
            ,sku
            ,sku_tag
            ,sub_user_type
            ,payment_price_usd
            ,event_name
            ,source2
            -- ,s.category1 -- 如果不用unnest怎么取，agg里面的几列是同时在一行的，类似[<列1-值1,列2-值1>,<列1-值2,列2-值2>]
            ,s.category2
            ,user_pseudo_id
            ,new_uuid
            ,purchase_date
            ,standard_order_date
            ,cur_page_type
        from
            subscription_event ,unnest(agg) as s
        )a
        --关联实验时机
        join user_info u
        on a.device_id=u.device_id  and a.timestamp>=u.timestamp-15000000 --15s
        -- --维度功能名称映射表
        -- left join
        --     `dataintegration-265403.dmi.dmi_da_content_page_dictionary_new` b on a.category2=b.key
)

-- select code,event_name,sum(value) value
-- from
-- (
select
    cast(date_p as date) date
    ,'0:enter AB Test' event_name
    ,platform
--     ,case   when country in ('United States','Thailand','South Korea','Japan') then country
--             else 'WW'
--             end as region
    ,is_ua
    ,case   when code in ('10639','10642') then '对照组'
            when code in ('10640','10643') then '实验组A'
            end code
    ,cast(null as string) source
    ,cast(null as string) sku_type
    ,cast(null as string) sku_has_trial
    -- ,sku
--     ,cast(null as string) sku_tag
    -- ,sub_user_type
    ,count(distinct device_id) value
    ,count(1) pv
from
    user_info
-- where platform='ANDROID'
-- where platform='IOS'
group by
    1,2,3,4,5,6,7,8

union all

select
    date
    ,case   when event_name in ('page_event') then '1:sub enter'
            when event_name in ('subscription_clk_try') then '2:sub click'
            else event_name
            end as event_name
    ,a.platform
--     ,a.region
    ,is_ua
    ,code
    ,source
    ,sku_type
    ,sku_has_trial
    -- ,sku
--     ,sku_tag
    -- ,sub_user_type
    ,count(distinct a.device_id) value
    ,count(1) pv
from
    ab_sub_event a
where
    event_name not in ('subscription_try_suc')
--     and platform='ANDROID'
--     and platform='IOS'
group by
    1,2,3,4,5,6,7,8

union all

select
    date
    ,'3:sub_success' as event_name
    ,a.platform
--     ,a.region
    ,is_ua
    ,code
    ,source
    ,sku_type
    ,sku_has_trial
    -- ,sku
--     ,sku_tag
    -- ,sub_user_type
    ,count(distinct a.device_id) value
    ,count(1) pv
from
    ab_sub_event a
where
    standard_order_date is not null
    and event_name in ('subscription_try_suc')
--     and platform='ANDROID'
--     and platform='IOS'
group by
    1,2,3,4,5,6,7,8

union all

select
    date
    ,'4:sub_success_to_paid' as event_name
    ,a.platform
--     ,a.region
    ,is_ua
    ,code
    ,source
    ,sku_type
    ,sku_has_trial
    -- ,sku
--     ,sku_tag
    -- ,sub_user_type
    ,count(distinct a.device_id) value
    ,count(1) pv
from
    ab_sub_event a
where
    standard_order_date is not null and purchase_date is not null
    and event_name in ('subscription_try_suc')
--     and platform='ANDROID'
--     and platform='IOS'
group by
    1,2,3,4,5,6,7,8

union all

select
    date
    ,'5:sub_success_to_paid revenue' as event_name
    ,a.platform
--     ,a.region
    ,is_ua
    ,code
    ,source
    ,sku_type
    ,sku_has_trial
    -- ,sku
--     ,sku_tag
    -- ,sub_user_type
    ,round(sum(payment_price_usd),2) value
    ,count(1) pv
from
    ab_sub_event a
where
    standard_order_date is not null and purchase_date is not null
    and event_name in ('subscription_try_suc')
--     and platform='ANDROID'
--     and platform='IOS'
group by
    1,2,3,4,5,6,7,8
-- )
-- group by 1,2
-- order by 1,2


-- select *
-- from
--     ab_sub_event a
-- where
--     standard_order_date is not null and purchase_date is not null
--     and event_name in ('subscription_try_suc')
-- --     and platform='ANDROID'
--     and platform='IOS'
--     and sku_type is null

