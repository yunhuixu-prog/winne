WITH enter AS (
    SELECT
        DISTINCT DATE(TIMESTAMP_MICROS(event_timestamp), 'Asia/Singapore') AS enter_abtest_date,
        user_pseudo_id,
        geo.country AS country,
        platform,
        func.getUserprop(user_properties, 'device_id').string_value AS device_id,
        func.getParams(event_params, 'current_abcode').string_value AS abcode,
       event_timestamp
        ,`dataintegration-265403.func`.getUserprop(user_properties,'hwgid').string_value gid
 FROM `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-11-13' ,'2025-12-03','airbrush', false) -- 此处用false 速度会更快
    WHERE event_name = 'abcode_enter_test'
        AND func.getParams(event_params, 'current_abcode').string_value IN ('28450','28451','28452')
    )
,act as (
    select
        event_date_hk, user_pseudo_id, platform,real_device_id device_id,is_new,gid
    from `dataintegration-265403.dwd.dwd_dzp_behavior_active_device`
    -- FROM `dataintegration-265403.stat.stat_active_advice_detail_d`
    where
        event_date_hk between '2025-11-13' and date_add('2025-12-03',interval 1 day)
        and  app_name = 'AirBrush'
)
,ad AS (
    select
        e.user_pseudo_id,e.platform,e.abcode,e.enter_abtest_date,fa.is_new,e.event_timestamp
    from  act fa
    join
       enter e ON e.user_pseudo_id = fa.user_pseudo_id and e.enter_abtest_date = fa.event_date_hk
)
select e.enter_abtest_date,e.is_new,e.abcode
    ,count(distinct e.user_pseudo_id) uv
    ,count(distinct a.user_pseudo_id) uv_r
from ad e
left join act a
on e.enter_abtest_date=date_sub(a.event_date_hk,interval 1 day) and e.user_pseudo_id=a.user_pseudo_id
group by 1,2,3
order by 1,2,3



-- 新口径

