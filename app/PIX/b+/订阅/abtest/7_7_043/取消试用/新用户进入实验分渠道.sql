-- 进入实验记录的时间可能和该事件发生的时间对不上，需要gap个几秒
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
        (date_p>='2024-01-18' and date_p<='2024-02-14')
        and cast(ab_code as string) in ('10493','10494','10495')
        and field_type = 3 --field是3 device-id
        and app_key in ('F9B069901A7B2E8D','C6FF0769324CD2F1')
)
,
user_info as
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
--     where event_date_hk between '2024-01-18' and '2024-02-14'
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
    where event_date between '2024-01-18' and '2024-02-14'
        and s.app_name='BeautyPlus'
    group by 1,2
)


select date_p date
    ,'0:enter_ab_test' event_name
    ,a.platform
    ,'null' region
    ,a.is_new
    ,i.is_UA is_UA
    ,case when a.code in ('10493') then '对照组'
        when a.code in ('10494') then '实验组A'
        when a.code in ('10495') then '实验组B'
    end as code
--     ,'null' source
    ,'null' sku_type
    ,'null' sku_has_trial
--     ,'null' sku
--     ,'null' sku_tag
    ,'null' sub_user_type
    ,count(distinct a.device_id) value
    ,count(1) pv
from abcode a
left join user_info i on a.device_id=i.device_id and a.platform=i.platform
group by 1,2,3,4,5,6,7,8,9,10



