-- 进入实验记录的时间可能和该事件发生的时间对不上，需要gap个几秒
-- 限制一下用户类型看一下进入实验的用户对不对的上(额不过算的是进入实验的用户类型，用户订阅时的类型就不一定是进入实验的了)
with
abcode as
(
    SELECT
        date_p, cast(ab_code as string) code
    , field as device_id
    , country_id
    , case when is_app_new='2' then 'new user' when is_app_new='1' then 'old user' end as is_new
    , case when app_key in ('F9B069901A7B2E8D') then 'IOS' when app_key in ('C6FF0769324CD2F1') then 'ANDROID' end as platform,receive_time as timestamp
    FROM
    `dataintegration-265403.abtest.abtest_odz_flow`--2.第一次进入实验用户
    WHERE
        ((date_p>='2023-12-27' and date_p<='2023-12-28') or (date_p>='2024-01-04' and date_p<='2024-01-17'))
        and cast(ab_code as string) in ('10374','10375','10376')
        and field_type = 3 --field是3 device-id
        and app_key in ('F9B069901A7B2E8D','C6FF0769324CD2F1')
)
,
subscription_event as
(
    select *
    from `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_abtest`
    where
--         date>='2023-12-27' and date<='2024-01-17' --android时间
        ((date>='2023-12-27' and date<='2023-12-28') or (date>='2024-01-04' and date<='2024-01-17'))
        and device_id is not null
        -- and source2<>'OnboardingPage'
),
-- 取用户初次订阅类型
user_user_tag as
(
    select
        m.platform,
        m.device_id ,
        min_by(sub_user_type,date) sub_user_type
    from
        subscription_event m
        join abcode a on m.device_id=a.device_id  and m.platform=a.platform and m.date=a.date_p
    group by
        1,2
)
,
ab_sub_event as
(
select distinct
    a.date,
    a.platform,
    a.country,
    case
       when u.code in ('10374') then '对照组'
       when u.code in ('10375') then '实验组A'
       when u.code in ('10376') then '实验组B'
    end as code,
    source1 source,
    a.sku_type,
    a.sku_has_trial, -- 手动标记的字段，有可能不准，看板里不要用
    a.sku,
    a.sku_tag,
    t.sub_user_type,
    a.event_name,
    source2,
    -- a.category1,
    u.is_new,
    a.user_pseudo_id,
    a.device_id,
    new_uuid,
    a.payment_price_usd,
    purchase_date,
    standard_order_date,
    cur_page_type,
    a.timestamp
    from
        (SELECT
            distinct
            date,
            event_timestamp timestamp,
            device_id,
            platform,
            country,
            sku_type,
            sku_has_trial,
            sku,
            sku_tag,
            sub_user_type,
            payment_price_usd,
            event_name,
            source1,
            source2,
            -- s.category1, -- 如果不用unnest怎么取，agg里面的几列是同时在一行的，类似[<列1-值1,列2-值1>,<列1-值2,列2-值2>]
            -- s.category2,
            user_pseudo_id,
            new_uuid,
            purchase_date,
            standard_order_date,
            cur_page_type

        FROM
            subscription_event --,unnest(agg) as s

            )a
    --关联实验时机
    join abcode u
    on a.device_id=u.device_id  and a.timestamp>=u.timestamp-15000000
    left join user_user_tag t on a.device_id=t.device_id and a.platform=t.platform

    -- --维度功能名称映射表
    -- left join
    --     `dataintegration-265403.dmi.dmi_da_content_page_dictionary_new` b on a.category2=b.key
)

select  date,case when  event_name in ('page_event') then '1:sub enter uv'
    when  event_name in ('subscription_clk_try') then '2:sub click uv'
    else event_name end as event_name
    ,a.platform
    ,case when country in ('Indonesia','Pakistan','Bangladesh','Nigeria','Peru') then country else 'else' end country
    -- ,is_new
    ,code
--     ,source
    ,sku_type
    ,sku_has_trial
    ,sku
--     ,sku_tag
--     ,sub_user_type
    ,count(distinct a.device_id) value
    ,count(1) pv
from
  ab_sub_event a
where
    event_name not in ('subscription_try_suc')
    and platform='ANDROID'
--     and country in ('Indonesia','Pakistan','Bangladesh','Nigeria','Peru')
    group by 1,2,3,4,5,6,7,8

union all

select  date,'3:sub_success uv' as event_name
    ,a.platform
    ,case when country in ('Indonesia','Pakistan','Bangladesh','Nigeria','Peru') then country else 'else' end country
    -- ,is_new
    ,code
--     ,source
    ,sku_type
    ,sku_has_trial
    ,sku
--     ,sku_tag
--     ,sub_user_type
    ,count(distinct a.device_id) value
    ,count(1) pv
from
  ab_sub_event a
where standard_order_date is not null
and event_name in ('subscription_try_suc')
    and platform='ANDROID'
--     and country in ('Indonesia','Pakistan','Bangladesh','Nigeria','Peru')
group by 1,2,3,4,5,6,7,8

union all

select  date,'4:sub_success_to_paid uv' as event_name
    ,a.platform
    ,case when country in ('Indonesia','Pakistan','Bangladesh','Nigeria','Peru') then country else 'else' end country
    -- ,is_new
    ,code
--     ,source
    ,sku_type
    ,sku_has_trial
    ,sku
--     ,sku_tag
--     ,sub_user_type
    ,count(distinct a.device_id) value
    ,count(1) pv
from
  ab_sub_event a
where standard_order_date is not null and purchase_date is not null
and event_name in ('subscription_try_suc')
    and platform='ANDROID'
--     and country in ('Indonesia','Pakistan','Bangladesh','Nigeria','Peru')
    group by 1,2,3,4,5,6,7,8

union all

select  date,'5:sub_success_to_paid revenue' as event_name
    ,a.platform
    ,case when country in ('Indonesia','Pakistan','Bangladesh','Nigeria','Peru') then country else 'else' end country
    -- ,is_new
    ,code
--     ,source
    ,sku_type
    ,sku_has_trial
    ,sku
--     ,sku_tag
--     ,sub_user_type
    ,round(sum(payment_price_usd),2) value
    ,count(1) pv
from
  ab_sub_event a
where standard_order_date is not null and purchase_date is not null
and event_name in ('subscription_try_suc')
    and platform='ANDROID'
--     and country in ('Indonesia','Pakistan','Bangladesh','Nigeria','Peru')
    group by 1,2,3,4,5,6,7,8


