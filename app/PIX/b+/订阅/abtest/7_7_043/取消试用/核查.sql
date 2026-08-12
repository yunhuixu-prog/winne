-- 进入实验记录的时间可能和该事件发生的时间对不上，需要gap个几秒
with
abcode_3 as
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
        (date_p>='2024-01-18' and date_p<='2024-02-15')
        and cast(ab_code as string) in ('10493','10494','10495')
        and field_type = 3 --field是3 device-id
        and app_key in ('F9B069901A7B2E8D','C6FF0769324CD2F1')
)
,
abcode_1 as
(
    SELECT
        date_p, cast(ab_code as string) code
    , field as user_pseudo_id
    , country_id
    , case when is_app_new='2' then 'new user' when is_app_new='1' then 'old user' end as is_new
    , case when app_key in ('F9B069901A7B2E8D') then 'IOS' when app_key in ('C6FF0769324CD2F1') then 'ANDROID' end as platform,receive_time as timestamp
    FROM
    `dataintegration-265403.abtest.abtest_odz_flow`--2.第一次进入实验用户
    WHERE
        (date_p>='2024-01-18' and date_p<='2024-02-15')
        and cast(ab_code as string) in ('10493','10494','10495')
        and field_type = 1
        and app_key in ('F9B069901A7B2E8D','C6FF0769324CD2F1')
)
,
subscription_event as
(
    select *
    from `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_abtest`
    where
        (date>='2024-01-18' and date<='2024-02-15')
        and device_id is not null
        -- and source2<>'OnboardingPage'
),
ab_sub_event_1 as
(
select distinct
    a.date,
    a.platform,
    a.country,
    case
       when u.code in ('10493') then '对照组'
       when u.code in ('10494') then '实验组A'
       when u.code in ('10495') then '实验组B'
    end as code,
    source1 source,
    a.sku_type,
    a.sku_has_trial, -- 手动标记的字段，有可能不准，看板里不要用
    a.sku,
    a.sku_tag,
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
    join abcode_1 u
    on a.user_pseudo_id=u.user_pseudo_id  and a.timestamp>=u.timestamp-15000000
)
,
ab_sub_event_3 as
(
select distinct
    a.date,
    a.platform,
    a.country,
    case
       when u.code in ('10493') then '对照组'
       when u.code in ('10494') then '实验组A'
       when u.code in ('10495') then '实验组B'
    end as code,
    source1 source,
    a.sku_type,
    a.sku_has_trial, -- 手动标记的字段，有可能不准，看板里不要用
    a.sku,
    a.sku_tag,
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
    join abcode_3 u
    on a.device_id=u.device_id  and a.timestamp>=u.timestamp-15000000
)

-- select 'firebase' type,code,count(1),count(distinct user_pseudo_id),sum(payment_price_usd)
-- from ab_sub_event_1
-- group by 1,2
--
-- union all
--
-- select 'device' type,code,count(1),count(distinct device_id),sum(payment_price_usd)
-- from ab_sub_event_3
-- group by 1,2


select *
from ab_sub_event_3 a
left join ab_sub_event_1 b
on a.device_id=b.device_id and a.user_pseudo_id=b.user_pseudo_id and a.timestamp=b.timestamp
where b.device_id is null and a.event_name in ('subscription_try_suc') and a.standard_order_date is not null and a.purchase_date is not null



-- 问题用户事件表
select
        parse_date('%Y%m%d', event_date) event_date
        ,platform
        ,event_timestamp
        ,event_name
--         ,event_params
--         ,user_properties
        ,user_pseudo_id
        ,geo.country
    from
        `beautyplus-bc0ed.analytics.stage_dz_event_view`
    where
        parse_date('%Y%m%d', event_date) between '2024-02-12' and '2024-02-13'
        and func.getUserprop(user_properties,'device_id').string_value = 'F974BA09-111A-426C-B385-60EBE9499074'
order by event_timestamp









