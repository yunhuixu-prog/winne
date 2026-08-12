WITH enter AS (
    SELECT
        DISTINCT DATE(TIMESTAMP_MICROS(event_timestamp), 'Asia/Singapore') AS enter_abtest_date,
        user_pseudo_id,
        geo.country AS country,
        platform,
        func.getUserprop(user_properties, 'device_id').string_value AS device_id,
        func.getParams(event_params, 'current_abcode').string_value AS abcode,
       event_timestamp
 FROM `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-12-03' ,'2025-12-16','airbrush', false) -- 此处用false 速度会更快
    WHERE event_name = 'abcode_enter_test'
        AND func.getParams(event_params, 'current_abcode').string_value IN ('28522','28523','28524','28525','28526','28527')
    )
,act as (
    select
        event_date_hk, user_pseudo_id, platform,real_device_id device_id,is_new,country
    from `dataintegration-265403.dwd.dwd_dzp_behavior_active_device`
    -- FROM `dataintegration-265403.stat.stat_active_advice_detail_d`
    where
        event_date_hk between '2025-12-03' and date_add('2025-12-16',interval 1 day)
        and  app_name = 'AirBrush'
)
,ad AS (
-- 取活跃用户中有进入实验的用户
    select *
    from
    (
        select
            e.user_pseudo_id,e.platform,e.abcode,e.enter_abtest_date,fa.is_new enter_new,fa.country
            ,row_number() over(partition by e.user_pseudo_id order by event_timestamp) ranks
        from  act fa
        join
           enter e ON e.user_pseudo_id = fa.user_pseudo_id and e.enter_abtest_date = fa.event_date_hk
        where e.user_pseudo_id is not null
    )
    where ranks=1
)
,rs AS (
-- 取活跃用户中有进入实验的用户
    select
        fa.*,e.abcode,e.enter_abtest_date,e.enter_new
    from  act fa
    join
       ad e ON e.user_pseudo_id = fa.user_pseudo_id and e.enter_abtest_date <= fa.event_date_hk
)

SELECT
    o.platform,
    o.abcode,
    case when abcode in ('28522','28525') then '对照组'
         when abcode in ('28523','28526') then '实验组A'
         when abcode in ('28524','28527') then '实验组B'
        end code,
    o.event_date_hk,
    case when o.is_new = 1 then 'New user' when o.is_new = 0 then 'Old user' end is_new,
    case when o.country in ('United States','Brazil','United Kingdom') then o.country else 'other' end country,
--     case when o.enter_new = 1 then 'New user' when o.enter_new = 0 then 'Old user' end is_new,
--     o.event_date_hk,
    COUNT(DISTINCT case when o.event_date_hk=enter_abtest_date then o.device_id end) AS enter_abtest_uv,
    COUNT(DISTINCT o.device_id) AS enter_abtest_dau,
    COUNT(DISTINCT CASE WHEN DATE_DIFF(a.event_date_hk, o.event_date_hk, DAY) = 0 THEN o.user_pseudo_id END) AS re0,
    COUNT(DISTINCT CASE WHEN DATE_DIFF(a.event_date_hk, o.event_date_hk, DAY) = 1 THEN o.user_pseudo_id END) AS re1
     --       COUNT(DISTINCT CASE WHEN DATE_DIFF(a.event_date_hk, o.event_date, DAY) = 1 THEN o.device_id END) / COUNT(DISTINCT o.device_id) AS d1_retain_rate,

        -- COUNT(DISTINCT CASE WHEN DATE_DIFF(a.event_date_hk, o.event_date, DAY) = 1 THEN o.device_id END) / COUNT(DISTINCT CASE WHEN DATE_DIFF(a.event_date_hk, o.event_date, DAY) = 0 THEN o.device_id END) AS d1_retain_rate,

    -- COUNT(DISTINCT CASE WHEN DATE_DIFF(a.event_date_hk, o.event_date, DAY) = 1 THEN o.device_id END) / COUNT(DISTINCT o.device_id) AS d1_retain_rate,
    -- COUNT(DISTINCT CASE WHEN DATE_DIFF(a.event_date_hk, o.event_date, DAY) = 7 THEN o.device_id END) AS re7,
    -- COUNT(DISTINCT CASE WHEN DATE_DIFF(a.event_date_hk, o.event_date, DAY) = 7 THEN o.device_id END) / COUNT(DISTINCT o.device_id) AS d7_retain_rate
FROM rs o -- 需要求留存的用户
LEFT JOIN act a ON o.user_pseudo_id = a.user_pseudo_id AND a.event_date_hk >= o.event_date_hk
where o.event_date_hk between '2025-12-03' and'2025-12-16'
--     and case when o.enter_new = 1 then o.enter_abtest_date=o.event_date_hk else 1=1 end
GROUP BY 1,2,3,4,5,6
ORDER BY 1,2,3,4,5,6