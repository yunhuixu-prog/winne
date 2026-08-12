-- 功能表无时间戳，因此仅用日期匹配，注意该实验为了看新用户D0数据，仅限制进入实验当天
select
    -- a.date_p,
    b.os_type os_type
    ,case when b.ab_code in ('29019','28956') then '对照组'
        when b.ab_code in ('29020','28957') then '实验组A'
        end code
    ,b.is_new is_new
    ,a.function_name function_name
    ,count(distinct case when enter_pv > 0 then a.gid end) enter_uv
    ,count(distinct case when use_pv > 0 then a.gid end) use_uv
    ,count(distinct case when save_pv > 0 then a.gid end) save_uv
    ,sum(enter_pv) enter_pv
    ,sum(use_pv) use_pv
    ,sum(save_pv) save_pv
from (
    SELECT
            date_p,
            gid,
            case when tool_level='1' then 'All'
                 when tool_level='2' then sub_func_level2_name
            end function_name
            ,SUM(case when event_type='进入' then cnt end) enter_pv
            ,SUM(case when event_type='打勾' then cnt end) use_pv
            ,SUM(case when event_type='保存' then cnt end) save_pv
        FROM stat_sdk.airbrush_mdz_tool_behavior_detail
        WHERE date_p BETWEEN 20260525 and 20260614
            AND model_p IN ('image_edit')
            AND tool_level IN ('1','2')
            AND event_type in ('进入','打勾','保存')
            -- AND sub_func_level2_name IS NOT NULL
            -- AND TRIM(sub_func_level2_name) <> ''
        GROUP BY date_p, gid, case when tool_level='1' then 'All'
                 when tool_level='2' then sub_func_level2_name
            end
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
                WHERE date_p BETWEEN 20260525 and 20260614
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
                WHERE date_p BETWEEN 20260525 and 20260614
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
            WHERE date_p between 20260525 and 20260614
                AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
                AND event_id = 'abcode_enter_test'
                AND params['current_abcode'] in ('29019','29020','28956','28957')
        ) e ON e.gid = fa.gid and e.enter_abtest_date = fa.date_p
        where e.gid is not null
    ) t
    where ranks=1
) b
on a.gid= b.gid
where b.enter_abtest_date = a.date_p
group by b.os_type,case when b.ab_code in ('29019','28956') then '对照组'
        when b.ab_code in ('29020','28957') then '实验组A'
        end
        ,b.is_new
        ,a.function_name