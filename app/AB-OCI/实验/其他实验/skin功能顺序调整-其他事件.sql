select
    -- a.date_p,
    -- a.os_type os_type
    case when b.ab_code in ('29086') then '对照组'
        when b.ab_code in ('29087') then '实验组A'
        when b.ab_code in ('29088') then '实验组B'
        end code
    -- ,b.is_new is_new
    ,a.event_id event_id
    ,third_func
    ,count(distinct case when a.event_id='third_func_use' then a.gid else null end) uv_use
    ,count(distinct case when a.event_id='third_func_enter' then a.gid else null end) uv_enter
from (
    SELECT date_p,event_id
        ,CAST(`time`/1000 AS bigint) event_timestamp
        ,sdk_type os_type,gid
        ,params['third_func'] third_func
    FROM stat_sdk.sdk_odz_source_data
    WHERE date_p between 20260702 and 20260720
        AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
        AND event_id in ('third_func_use','third_func_enter')
        and params['second_func']='skin'
) a
join (
    SELECT gid, os_type, is_new, ab_code, event_timestamp, date_p, country
    FROM (
        SELECT gid, os_type, is_new, ab_code, event_timestamp, date_p, country
            ,ROW_NUMBER() OVER (PARTITION BY gid ORDER BY event_timestamp) AS ranks
        FROM stat_ab.filing_odz_abtest_active_user
        WHERE date_p BETWEEN 20260702 AND 20260720
            AND ab_code IN ('29086','29087','29088')
    ) t
    WHERE ranks = 1
) b
on a.gid= b.gid
where b.event_timestamp-15 <= a.event_timestamp
    -- and b.enter_abtest_date = a.date_p
group by 
        -- a.os_type,
        case when b.ab_code in ('29086') then '对照组'
        when b.ab_code in ('29087') then '实验组A'
        when b.ab_code in ('29088') then '实验组B'
        end
        -- ,b.is_new
        ,a.event_id
        ,third_func

union all 

select
    -- a.date_p,
    -- a.os_type os_type
    case when b.ab_code in ('29086') then '对照组'
        when b.ab_code in ('29087') then '实验组A'
        when b.ab_code in ('29088') then '实验组B'
        end code
    -- ,b.is_new is_new
    ,a.event_id event_id
    ,'All' third_func
    ,count(distinct case when a.event_id='third_func_use' then a.gid else null end) uv_use
    ,count(distinct case when a.event_id='third_func_enter' then a.gid else null end) uv_enter
from (
    SELECT date_p,event_id
        ,CAST(`time`/1000 AS bigint) event_timestamp
        ,sdk_type os_type,gid
        ,params['third_func'] third_func
    FROM stat_sdk.sdk_odz_source_data
    WHERE date_p between 20260702 and 20260720
        AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
        AND event_id in ('third_func_use','third_func_enter')
        and params['second_func']='skin'
) a
join (
    SELECT gid, os_type, is_new, ab_code, event_timestamp, date_p, country
    FROM (
        SELECT gid, os_type, is_new, ab_code, event_timestamp, date_p, country
            ,ROW_NUMBER() OVER (PARTITION BY gid ORDER BY event_timestamp) AS ranks
        FROM stat_ab.filing_odz_abtest_active_user
        WHERE date_p BETWEEN 20260702 AND 20260720
            AND ab_code IN ('29086','29087','29088')
    ) t
    WHERE ranks = 1
) b
on a.gid= b.gid
where b.event_timestamp-15 <= a.event_timestamp
    -- and b.enter_abtest_date = a.date_p
group by 
        -- a.os_type,
        case when b.ab_code in ('29086') then '对照组'
        when b.ab_code in ('29087') then '实验组A'
        when b.ab_code in ('29088') then '实验组B'
        end
        -- ,b.is_new
        ,a.event_id
        -- ,third_func