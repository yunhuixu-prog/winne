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
        date_p>='2023-10-18' and date_p<='2023-11-06'
        and cast(ab_code as string) in ('10322','10323','10324','10325')
        and field_type = 3 --field是3 device-id
        and app_key in ('F9B069901A7B2E8D','C6FF0769324CD2F1')
)
,
subscription_event as
(
    select *
    from `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_abtest` ,unnest(agg) as s
    where date>='2023-10-18' and date<='2023-12-31'
        -- and meepo_abcode>=10146 and  meepo_abcode<=10153
        -- and cast(meepo_abcode as string) in ('10256', '10257','10258','10259')
        and device_id is not null
        -- and source2<>'OnboardingPage'
),
ab_sub_event as
(
select
    a.date,
    a.platform,
    --u.country,
    u.date_p enter_abtest_date,
    case
       when u.code in ('10322','10324') then '对照组'
       when u.code in ('10323','10325') then '实验组'
    end as code,
    case
        when b.english_name is not null then b.english_name
        when a.category1 in ('feature','material') then 'others'
        else a.category2 end as category2,
    case when category2 in ('订阅页挽留策略-试用弹窗','订阅页挽留策略-优惠弹窗','订阅页挽留策略') then '订阅页挽留'
      else '其他'
      end source,
    a.sku_type,
    a.sku_has_trial,
    a.sku,
    a.sku_tag,
    a.sub_user_type,
    a.event_name,
    source2,
    a.category1,
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
            --country,
            sku_type,
            sku_has_trial,
            sku,
            sku_tag,
            sub_user_type,
            payment_price_usd,
            event_name,
            source2,
            s.category1,
            s.category2,
            user_pseudo_id,
            new_uuid,
            purchase_date,
            standard_order_date,
            cur_page_type

        FROM
            subscription_event,unnest(agg) as s

            )a
    --关联实验时机
    join abcode u
    on a.device_id=u.device_id  and a.timestamp>=u.timestamp

    --维度功能名称映射表
    left join
        `dataintegration-265403.dim.dim_aa_content_dict` b on a.category2=b.key
)


select  enter_abtest_date
    ,date_diff(date,enter_abtest_date,day) days
    ,a.platform
    -- ,a.country ,is_new
    ,code
    -- ,source
    -- ,sku_type
    -- ,sku_has_trial
    -- ,sku
    -- ,sku_tag
    -- ,sub_user_type
    ,count(distinct case when event_name in ('page_event') then a.device_id end) sub_enter_uv
    ,count(distinct case when event_name in ('subscription_clk_try') then a.device_id end) sub_click_uv
    ,count(distinct case when event_name in ('subscription_try_suc') and standard_order_date is not null then a.device_id end) sub_success_uv
    ,count(distinct case when event_name in ('subscription_try_suc') and standard_order_date is not null and purchase_date is not null then a.device_id end) sub_paid_uv
    ,sum(case when event_name in ('subscription_try_suc') and standard_order_date is not null and purchase_date is not null then a.payment_price_usd end) sub_bookings
from
  ab_sub_event a
group by 1,2,3,4


