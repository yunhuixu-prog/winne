select
    -- a.date_p,
    -- a.os_type os_type
    case when b.ab_code in ('28808') then '对照组'
        when b.ab_code in ('28809') then '实验组A'
        when b.ab_code in ('28810') then '实验组B'
        end code
    ,a.event_id event_id
    ,count(distinct a.gid) uv
    ,count(1) pv
from (
    SELECT date_p,event_id
        ,CAST(`time`/1000 AS bigint) event_timestamp
        ,sdk_type os_type,gid
    FROM stat_sdk.sdk_odz_source_data
    WHERE date_p between 20260409 and 20260427
        AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
        AND (
                (event_id in ('second_func_use')
                    and params['first_func']='edit'
                    and params['second_func']='ai_repair')
                or 
                (event_id in ('ai_func_use_result')
                    and params['first_func']='edit'
                    and params['second_func']='ai_repair'
                    and params['is_success']='1')
        )
) a
join (
    select *
    from
    (
        select
            fa.gid,fa.os_p os_type,fa.country,fa.is_new
            ,e.ab_code,e.enter_abtest_date,e.event_timestamp
            ,row_number() over(partition by e.gid order by event_timestamp) ranks
        from (
            SELECT
                a.date_p,
                a.os_p,
                c.name AS country,
                a.final_id gid,
                CASE WHEN new_device.final_id IS NOT NULL THEN 'New' ELSE 'Old' END AS is_new
            FROM
            (
                SELECT date_p, os_p, country_id, final_id
                FROM stat_sdk.sdk_odz_active
                WHERE date_p BETWEEN 20260409 and 20260427
                    AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
                    AND os_p IS NOT NULL
            ) a
            LEFT JOIN
            (
                SELECT DISTINCT id, name
                FROM stat_sdk.dim_rna_ip_location
                WHERE level='1' and date_p is not null
            ) c
            ON a.country_id = c.id
            LEFT JOIN
            (
                SELECT final_id, date_p
                FROM stat_sdk.sdk_odz_new_device_info
                WHERE date_p BETWEEN 20260409 and 20260427
                AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
                AND os_p IS NOT NULL
            )new_device
            ON a.final_id = new_device.final_id AND a.date_p = new_device.date_p
        ) fa
        join (
            SELECT date_p enter_abtest_date
                ,CAST(`time`/1000 AS bigint) event_timestamp
                ,sdk_type os_type,gid
                ,params['current_abcode'] ab_code
            FROM stat_sdk.sdk_odz_source_data
            WHERE date_p between 20260409 and 20260427
                AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
                AND event_id = 'abcode_enter_test'
                AND params['current_abcode'] in ('28808','28809','28810')
        ) e ON e.gid = fa.gid and e.enter_abtest_date = fa.date_p
        where e.gid is not null
    ) t
    where ranks=1
) b
on a.gid= b.gid
where b.event_timestamp-15 <= a.event_timestamp
group by case when b.ab_code in ('28808') then '对照组'
        when b.ab_code in ('28809') then '实验组A'
        when b.ab_code in ('28810') then '实验组B'
        end
        ,a.event_id