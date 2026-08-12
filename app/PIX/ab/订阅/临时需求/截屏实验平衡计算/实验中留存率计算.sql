WITH enter AS (
    SELECT
        DISTINCT DATE(TIMESTAMP_MICROS(event_timestamp), 'Asia/Singapore') AS enter_abtest_date,
        user_pseudo_id,
        geo.country AS country,
        platform,
        func.getUserprop(user_properties, 'device_id').string_value AS device_id,
        func.getParams(event_params, 'current_abcode').string_value AS abcode,
       event_timestamp
 FROM `dataintegration-265403.analytics.dwd_dzp_events_function`('2024-09-02' ,'2024-09-23','airbrush', false) -- 此处用false 速度会更快
    WHERE event_name = 'abcode_enter_test'
        AND func.getParams(event_params, 'current_abcode').string_value IN ('10850','10851')
    )
,act as (
    select
        event_date_hk, user_pseudo_id, platform,real_device_id device_id,is_new
    from `dataintegration-265403.dwd.dwd_dzp_behavior_active_device`
    -- FROM `dataintegration-265403.stat.stat_active_advice_detail_d`
    where
        event_date_hk between '2024-09-02' and date_add('2024-09-23',interval 1 day)
        and  app_name = 'AirBrush'
)
,ad AS (
-- 取活跃用户中有进入实验的用户
    select *
    from
    (
        select
            e.user_pseudo_id,e.platform,e.abcode,e.enter_abtest_date,fa.is_new enter_new
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
select platform,code,sum(re1)/sum(re0)
from
(
SELECT
    o.platform,
    o.abcode,
    case when abcode in ('10850') then '对照组'
         when abcode in ('10851') then '实验组'
        end code,
    o.event_date_hk,
    COUNT(DISTINCT CASE WHEN DATE_DIFF(a.event_date_hk, o.event_date_hk, DAY) = 0 THEN o.user_pseudo_id END) AS re0,
    COUNT(DISTINCT CASE WHEN DATE_DIFF(a.event_date_hk, o.event_date_hk, DAY) = 1 THEN o.user_pseudo_id END) AS re1
FROM rs o -- 需要求留存的用户
LEFT JOIN act a ON o.user_pseudo_id = a.user_pseudo_id AND a.event_date_hk >= o.event_date_hk
GROUP BY 1,2,3,4
)
GROUP BY 1,2
