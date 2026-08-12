-- 进入实验记录的时间可能和该事件发生的时间对不上，需要gap个几秒
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
        case    when app_key in ('F9B069901A7B2E8D')  then (date_p>='2024-02-02' and date_p<='2024-03-07')
                when app_key in ('C6FF0769324CD2F1') then (date_p>='2024-02-23' and date_p<='2024-03-24')
                end
        and cast(ab_code as string) in ('10481','10482','10483','10484')
        and field_type = 3 --field是3 device-id
        and app_key in ('F9B069901A7B2E8D','C6FF0769324CD2F1')
)
,
-- 限制用户进入过额度管理页
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
        and case    when platform='IOS' then (event_date>='2024-02-02' and event_date<='2024-03-07')
                    when platform='ANDROID' then (event_date>='2024-02-23' and event_date<='2024-03-24')
                    end
        and cast(meepo_abcode as string) in ('10481','10482','10483','10484')
        and device_id is not null --limit 100
)
,
ab_user as
(
    select
        a.date_p
        ,a.platform
        ,a.device_id
        ,a.code
        ,a.country
        ,a.timestamp
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
        from
            event_all
        where
            event_name in  ('credit_page_bd')
        ) m
        join abcode a on  m.device_id=a.device_id  and m.platform=a.platform and m.event_timestamp>=a.timestamp-15000000 --15s
)
-- ,
-- -- 用来检测实验分组有没有问题。。。结果实在是太出乎意料了，好的结果就是分组没有问题，666啊
-- other_user as
-- (
--     select a.*
--     from abcode a
--     left join ab_user b
--     on a.device_id=b.device_id and a.platform=b.platform
--     where b.device_id is null
-- )
,
subscription_event as
(
    select
        *
    from
        `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_abtest`
    where
        case    when platform='IOS' then (date>='2024-02-02' and date<='2024-03-07')
                when platform='ANDROID' then (date>='2024-02-23' and date<='2024-03-24')
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
        ,case   when u.code in ('10481','10483') then '对照组'
                when u.code in ('10482','10484') then '实验组'
                end code
        ,case   when category2='额度管理默认入口' then '积分订阅入口'
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
        join abcode u
        on a.device_id=u.device_id  and a.timestamp>=u.timestamp-15000000 --15s
        -- --维度功能名称映射表
        -- left join
        --     `dataintegration-265403.dmi.dmi_da_content_page_dictionary_new` b on a.category2=b.key
)


select
    '0:enter AB Test' event_name
    ,platform
--     ,case   when country in ('United States','Thailand','South Korea','Japan') then country
--             else 'WW'
--             end as region
    -- ,is_new
    ,case   when code in ('10481','10483') then '对照组'
            when code in ('10482','10484') then '实验组'
            end code
--     ,cast(null as string) source
    ,cast(null as string) sku_type
    ,cast(null as string) sku_has_trial
--     -- ,sku
--     ,cast(null as string) sku_tag
    -- ,sub_user_type
    ,count(distinct device_id) value
    ,count(1) pv
from
    abcode
-- where platform='ANDROID'
group by
    1,2,3,4,5

union all

select
    case   when event_name in ('page_event') then '1:sub enter'
            when event_name in ('subscription_clk_try') then '2:sub click'
            else event_name
            end as event_name
    ,a.platform
--     ,a.region
    -- ,is_new
    ,code
--     ,source
    ,sku_type
    ,sku_has_trial
--     -- ,sku
--     ,sku_tag
    -- ,sub_user_type
    ,count(distinct a.device_id) value
    ,count(1) pv
from
    ab_sub_event a
where
    event_name not in ('subscription_try_suc')
--     and platform='ANDROID'
group by
    1,2,3,4,5

union all

select
    '3:sub_success' as event_name
    ,a.platform
--     ,a.region
    -- ,is_new
    ,code
--     ,source
    ,sku_type
    ,sku_has_trial
--     -- ,sku
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
group by
    1,2,3,4,5

union all

select
    '4:sub_success_to_paid' as event_name
    ,a.platform
--     ,a.region
    -- ,is_new
    ,code
--     ,source
    ,sku_type
    ,sku_has_trial
--     -- ,sku
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
group by
    1,2,3,4,5

union all

select
    '5:sub_success_to_paid revenue' as event_name
    ,a.platform
--     ,a.region
    -- ,is_new
    ,code
--     ,source
    ,sku_type
    ,sku_has_trial
--     -- ,sku
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
group by
    1,2,3,4,5





