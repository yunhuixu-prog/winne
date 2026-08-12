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
        date_p>='2024-04-23' and date_p<='2024-05-29'
        and cast(ab_code as string) in ('10645','10646',
                                        '10647','10648')
        and field_type = 3 --field是3 device-id
        and app_key in ('F9B069901A7B2E8D','C6FF0769324CD2F1')
)
,
-- 进入实验的用户：是否订阅中，是否订阅取消，什么时候到期
sub_status as
(
    select g.*
      ,case when coalesce(s.uuid,sp.uuid) is null then 'past no order'
            when coalesce(s.current_sub_sku_type,sp.current_sub_sku_type) is null then 'now no sub'
            when coalesce(s.current_sub_sku_type,sp.current_sub_sku_type) is not null then 'now sub'
      end before_sub_types
      , coalesce(s.current_sub_sku_type,sp.current_sub_sku_type) current_sub_sku_type
      , coalesce(s.is_current_subscription_cancelled,sp.is_current_subscription_cancelled) is_current_subscription_cancelled
      , coalesce(s.current_subscription_expired_day,sp.current_subscription_expired_day) current_subscription_expired_day
      , date_add(g.date_p,interval coalesce(s.current_subscription_expired_day,sp.current_subscription_expired_day) day) current_subscription_expired_date
    from
    (
        select distinct date_p, code, device_id, platform, timestamp, m.uuid
        from abcode a
        join `dataintegration-265403.stat.dmi_dz_idmapping` m
        on a.device_id=m.key
    ) g
    left join
    (
        select event_date_hk, uuid, current_sub_sku_type, is_current_subscription_cancelled, current_subscription_expired_day
        from `dataintegration-265403.dwd.dwd_dzp_portrait_subcription_uuid`
        where event_date_hk between '2024-04-23' and '2024-05-29'
        and app_id in ('BeautyPlus')
    ) s
    on g.uuid=s.uuid and g.date_p = s.event_date_hk
    left join
    (
        select event_date_hk, uuid, current_sub_sku_type, is_current_subscription_cancelled, current_subscription_expired_day
        from `dataintegration-265403.dwd.dwd_dzp_portrait_subcription_uuid`
        where event_date_hk between '2024-04-24' and '2024-05-30'
        and app_id in ('BeautyPlus')
    ) sp
    on g.uuid=sp.uuid and g.date_p = date_sub(sp.event_date_hk,interval 1 day)
)
,
real_bookings as
(
    select  standard_order_date
      ,case when date_diff(current_subscription_expired_date,a.standard_order_date,DAY)>0 then 'pre'
            when date_diff(current_subscription_expired_date,a.standard_order_date,DAY)<=0 then 'af'
      end if_expired
      ,before_sub_types
      ,subscription_period,sku_is_trial,order_status,payment_price_usd,a.platform
      ,case
           when u.code in ('10645','10647') then '对照组'
           when u.code in ('10646','10648') then '实验组'
        end as code
      ,u.current_sub_sku_type before_expired_sub_type
      ,u.uuid
    from
    (
        select *
        from `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp`
        where standard_order_date >= '2024-04-23'
            -- and order_status in (0,1,2)
        and app_id='BeautyPlus'
            -- and subscription_period in ('6-month','1-month','3-month','1-week','1-year')
            -- and offer_method = 'normal'
    ) a
    join
    (
        select uuid
        from `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp`
        where standard_order_date >= '2024-04-23'
        and app_id='BeautyPlus'
        group by uuid
        having count(1)<=20
    ) r on a.uuid=r.uuid
    join sub_status u
    on a.standard_order_date>=u.date_p and a.uuid=u.uuid
)

select code,uuid,sum(payment_price_usd),count(1)
from real_bookings
where before_sub_types='past no order'
group by code,uuid


