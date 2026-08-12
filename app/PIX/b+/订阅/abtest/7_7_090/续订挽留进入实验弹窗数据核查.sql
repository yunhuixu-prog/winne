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
event_all as
(
    select event_date,event_name,event_params,receive_time as event_timestamp,platform,meepo_abcode,device_id,country,user_pseudo_id
    from `beautyplus-bc0ed.temp.temp_renewal_retain_abtest_event`
    where app_name in ('BeautyPlus')
        and event_date>='2024-04-23' and event_date<='2024-05-29'
--         and cast(meepo_abcode as string) in ('10645','10646',
--                                         '10647','10648')
        and device_id is not null --limit 100
),
event_ab as
(
    select a.*
        ,case
        when a.code in ('10645','10647') then '对照组'
        when a.code in ('10646','10648') then '实验组'
        end as code_type
        ,m.first_event_date
    from sub_status a
    left join
    (
        select device_id,platform,min(event_date) first_event_date,min(event_timestamp) event_timestamp
        from event_all
        where event_name = 'renewal_retain_pop_appr_bd'
--             or (event_name = 'renewal_retain_pop_clk_bd' and func.getParams(event_params,'type').string_value='accept')
        group by 1,2
    ) m
    on  m.device_id=a.device_id  and m.platform=a.platform and m.event_timestamp>=a.timestamp-15000000
)

select
    a.code_type
    ,a.before_sub_types
    ,a.is_current_subscription_cancelled
    ,if(a.current_subscription_expired_day<=60,1,0) current_subscription_expired_day
    ,case when date_diff(first_event_date,date_p,DAY)<=1 then 1
          when date_diff(first_event_date,date_p,DAY)>1 then 0
    end first_pop_time
    ,count(distinct a.device_id) value
    ,count(1) pv
from
  event_ab a
-- where
--     event_name not in ('subscription_try_suc')
group by 1,2,3,4,5
