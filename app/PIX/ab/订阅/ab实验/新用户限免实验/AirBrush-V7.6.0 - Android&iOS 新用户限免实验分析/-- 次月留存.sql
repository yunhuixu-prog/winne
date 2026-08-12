-- 次月留存

WITH enter AS (
    SELECT 
        DISTINCT DATE(TIMESTAMP_MICROS(event_timestamp), 'Asia/Singapore') AS event_date,
        user_pseudo_id,
        geo.country AS country,
        platform,
        func.getUserprop(user_properties, 'device_id').string_value AS device_id,
        func.getParams(event_params, 'current_abcode').string_value AS abcode,
       -- event_timestamp
 FROM `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-04-03' ,'2025-04-30','airbrush', false) -- 此处用false 速度会更快
    WHERE event_name = 'abcode_enter_test' 
        AND func.getParams(event_params, 'current_abcode').string_value IN ('11072','11073','11074','11075','11076','11077')
    )
,act as (
    select 
        event_date_hk, user_pseudo_id, platform,real_device_id device_id,is_new
        ,date_trunc(event_date_hk,month) date_m
        ,is_new
    from `dataintegration-265403.dwd.dwd_dzp_behavior_active_device`
    -- FROM `dataintegration-265403.stat.stat_active_advice_detail_d`
    where  
        event_date_hk >= '2025-04-03' -- and'2025-05-02'
        and  app_name = 'AirBrush'
    
)
,rs AS (
-- 取活跃用户中有进入实验的用户
    select 
        fa.*,abcode
    from  act fa
    join 
       enter e ON e.user_pseudo_id = fa.user_pseudo_id and e.event_date <= fa.event_date_hk 
    where e.user_pseudo_id is not null 
)

SELECT 
    o.platform,
    o.abcode,
   -- case when o.is_new = 1 then 'New user' else 'Old user' end is_new,
    o.date_m,
    COUNT(DISTINCT o.device_id) AS enter_abtest_uv,
    COUNT(DISTINCT CASE WHEN DATE_DIFF(a.date_m, o.date_m, month) = 0 THEN o.device_id END) AS re0,
    COUNT(DISTINCT CASE WHEN DATE_DIFF(a.date_m, o.date_m, month) =1  THEN o.device_id END) AS re1
     --       COUNT(DISTINCT CASE WHEN DATE_DIFF(a.event_date_hk, o.event_date, DAY) = 1 THEN o.device_id END) / COUNT(DISTINCT o.device_id) AS d1_retain_rate,

        -- COUNT(DISTINCT CASE WHEN DATE_DIFF(a.event_date_hk, o.event_date, DAY) = 1 THEN o.device_id END) / COUNT(DISTINCT CASE WHEN DATE_DIFF(a.event_date_hk, o.event_date, DAY) = 0 THEN o.device_id END) AS d1_retain_rate,

    -- COUNT(DISTINCT CASE WHEN DATE_DIFF(a.event_date_hk, o.event_date, DAY) = 1 THEN o.device_id END) / COUNT(DISTINCT o.device_id) AS d1_retain_rate,
    -- COUNT(DISTINCT CASE WHEN DATE_DIFF(a.event_date_hk, o.event_date, DAY) = 7 THEN o.device_id END) AS re7,
    -- COUNT(DISTINCT CASE WHEN DATE_DIFF(a.event_date_hk, o.event_date, DAY) = 7 THEN o.device_id END) / COUNT(DISTINCT o.device_id) AS d7_retain_rate
FROM rs o -- 需要求留存的用户
LEFT JOIN act a ON o.device_id = a.device_id AND a.date_m >= o.date_m
GROUP BY 1,2,3
ORDER BY 1,2


