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
        (date_p>='2024-01-18' and date_p<='2024-02-15')
        and cast(ab_code as string) in ('10493','10494','10495')
        and field_type = 3 --field是3 device-id
        and app_key in ('F9B069901A7B2E8D','C6FF0769324CD2F1')
)
,
user_info as -- 换成新表
(
--     select
--         a.platform
--         ,a.device_id
--         ,max(s.is_new) is_new
--         ,max(s.is_UA) is_UA
--     from
--         `dataintegration-265403.stat.stat_active_advice_detail_d` s
--     join abcode a
--     on s.event_date_hk=a.date_p and s.vendor_id=a.device_id  and s.platform=a.platform
--     where event_date_hk between '2024-01-18' and '2024-02-15'
--         and app_name='BeautyPlus'
--     group by 1,2
    select
        s.platform
        ,s.device_id
        ,max(u.is_new) is_new
        ,max(u.is_UA) is_UA
    from
        dataintegration-265403.abtest.stage_aa_meepo_enter_event s
    join abcode a
    on s.event_date=a.date_p and s.device_id=a.device_id  and s.platform=a.platform
    join `dataintegration-265403.stat.stat_active_advice_detail_d` u
    on s.event_date=u.event_date_hk and s.user_pseudo_id=u.user_pseudo_id  and s.platform=u.platform
    where event_date between '2024-01-18' and '2024-02-15'
        and s.app_name='BeautyPlus'
    group by 1,2
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
)

select *
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
    left join user_info i on a.device_id=i.device_id and a.platform=i.platform
where i.device_id is null
    and standard_order_date is not null and purchase_date is not null
    and event_name in ('subscription_try_suc')


-- 个例查询(有进入实验但无活跃？是不是根据firebaseid汇总了，有些deviceid没了？不应该这么多啊可是)
SELECT *
    FROM
    `dataintegration-265403.abtest.abtest_odz_flow`--2.第一次进入实验用户
    WHERE
        (date_p>='2024-01-18' and date_p<='2024-02-15')
        and cast(ab_code as string) in ('10493','10494','10495')
        and field_type = 3 --field是3 device-id
        and app_key in ('F9B069901A7B2E8D','C6FF0769324CD2F1')
        and field='93DCAED9-CB91-46DE-BF06-428A488C9A09'
;
select *
    from
        `dataintegration-265403.stat.stat_active_advice_detail_d` s
    where event_date_hk between '2024-01-18' and '2024-02-15'
        and app_name='BeautyPlus'
        and vendor_id='93DCAED9-CB91-46DE-BF06-428A488C9A09'


