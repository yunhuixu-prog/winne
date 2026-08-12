
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
    select m.*
        ,a.code
        ,case when date_diff(current_subscription_expired_date,m.event_date,DAY)>0 then 'pre'
              when date_diff(current_subscription_expired_date,m.event_date,DAY)<=0 then 'af'
        end if_expired
        ,current_sub_sku_type before_expired_sub_type
        ,before_sub_types
        ,case
        when a.code in ('10645','10647') then '对照组'
        when a.code in ('10646','10648') then '实验组'
        end as code_type
--         ,a.is_new
    from
    (
        select event_date
            ,event_timestamp
            ,platform
            ,country
            ,case when country in ('South Korea','Thailand','Japan','United States') then country else 'WW' end as region
            ,event_name
            ,coalesce(cast(func.getParams(event_params,'pop_type').int_value as string),func.getParams(event_params,'pop_type').string_value) as pop_type
            ,user_pseudo_id
            ,device_id
        from event_all
--         where event_name in  ('renewal_retain_pop_appr_bd','renewal_retain_pop_clk_bd')
        where event_name = 'renewal_retain_pop_appr_bd'
            or (event_name = 'renewal_retain_pop_clk_bd' and func.getParams(event_params,'type').string_value='accept')
    ) m
    join sub_status a
    on  m.device_id=a.device_id  and m.platform=a.platform and m.event_timestamp>=a.timestamp-15000000
)

-- select platform,code_type,event_name,pop_type,sum(num) value
-- from
-- (
select
--         event_date
--         if_expired
        event_name
        ,'all' pop_type
        ,code_type
        ,platform
--         ,before_expired_sub_type
--         ,before_sub_types
        ,count(distinct device_id) num
        ,count(1) pv
from event_ab
group by 1,2,3,4

union all

select
--         event_date
--         if_expired
        event_name
        ,pop_type
        ,code_type
        ,platform
--         ,before_expired_sub_type
--         ,before_sub_types
        ,count(distinct device_id) num
        ,count(1) pv
from event_ab
group by 1,2,3,4
-- )
-- group by 1,2,3,4
-- order by 1,2,3,4