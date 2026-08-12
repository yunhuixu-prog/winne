-- step1：留存率（进入实验当天活跃，仅首次进入 ranks=1）
-- 新用户过滤占位符仅出现在下方两处 WHERE ranks = 1 末尾；默认替换为空，见 run_analysis.py
-- 其他占位符：${start_date} ${end_date} ${end_date_p90} ${abcode_in_list}
SELECT
    a.enter_abtest_date enter_abtest_date,
    b.active_date active_date,
    a.abcode abcode,
    b.lcx lcx,
    b.week_day week_day,
    a.control_active0 control_active0,
    b.control_activex control_activex,
    ROUND(b.control_activex / a.control_active0, 4) AS retention_rate
FROM (
    SELECT enter_abtest_date, abcode
        , COUNT(DISTINCT gid) AS control_active0
    FROM (
        SELECT gid, abcode, enter_abtest_date, os_type
        FROM (
            SELECT
                e.gid,
                e.abcode,
                e.enter_abtest_date,
                e.os_type,
                fa.is_new AS enter_new,
                row_number() OVER (PARTITION BY e.gid ORDER BY e.event_ts) AS ranks
            FROM (
                SELECT
                    a.date_p,
                    a.os_p,
                    a.final_id AS gid,
                    CASE WHEN nd.final_id IS NOT NULL THEN 1 ELSE 0 END AS is_new
                FROM (
                    SELECT date_p, os_p, country_id, final_id
                    FROM stat_sdk.sdk_odz_active
                    WHERE date_p BETWEEN ${start_date} AND ${end_date_p90}
                        AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
                        AND os_p IS NOT NULL
                ) a
                LEFT JOIN (
                    SELECT final_id, date_p
                    FROM stat_sdk.sdk_odz_new_device_info
                    WHERE date_p BETWEEN ${start_date} AND ${end_date_p90}
                        AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
                        AND os_p IS NOT NULL
                ) nd
                    ON a.final_id = nd.final_id AND a.date_p = nd.date_p
            ) fa
            JOIN (
                SELECT
                    date_p AS enter_abtest_date,
                    gid,
                    sdk_type AS os_type,
                    params['current_abcode'] AS abcode,
                    CAST(`time`/1000 AS bigint) AS event_ts
                FROM stat_sdk.sdk_odz_source_data
                WHERE date_p BETWEEN ${start_date} AND ${end_date}
                    AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
                    AND event_id = 'abcode_enter_test'
                    AND params['current_abcode'] IN (${abcode_in_list})
            ) e
                ON e.gid = fa.gid AND e.enter_abtest_date = fa.date_p
        ) t
        WHERE ranks = 1${enter_new_sql}
    ) enter_user
    GROUP BY enter_abtest_date, abcode
) a
JOIN (
    SELECT
        enter_abtest_date,
        date_p AS active_date,
        abcode,
        DATEDIFF(
            from_unixtime(unix_timestamp(cast(date_p AS string), 'yyyyMMdd')),
            from_unixtime(unix_timestamp(cast(enter_abtest_date AS string), 'yyyyMMdd'))
        ) AS lcx,
        CAST(from_unixtime(unix_timestamp(cast(date_p AS string), 'yyyyMMdd'), 'u') AS int) AS week_day,
        COUNT(DISTINCT gid) AS control_activex
    FROM (
        SELECT fa.date_p, fa.gid, e.abcode, e.enter_abtest_date, e.os_type
        FROM (
            SELECT
                a.date_p,
                a.os_p,
                a.final_id AS gid,
                CASE WHEN nd.final_id IS NOT NULL THEN 1 ELSE 0 END AS is_new
            FROM (
                SELECT date_p, os_p, country_id, final_id
                FROM stat_sdk.sdk_odz_active
                WHERE date_p BETWEEN ${start_date} AND ${end_date_p90}
                    AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
                    AND os_p IS NOT NULL
            ) a
            LEFT JOIN (
                SELECT final_id, date_p
                FROM stat_sdk.sdk_odz_new_device_info
                WHERE date_p BETWEEN ${start_date} AND ${end_date_p90}
                    AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
                    AND os_p IS NOT NULL
            ) nd
                ON a.final_id = nd.final_id AND a.date_p = nd.date_p
        ) fa
        JOIN (
            SELECT gid, abcode, enter_abtest_date, os_type
            FROM (
                SELECT
                    e.gid,
                    e.abcode,
                    e.enter_abtest_date,
                    e.os_type,
                    fa2.is_new AS enter_new,
                    row_number() OVER (PARTITION BY e.gid ORDER BY e.event_ts) AS ranks
                FROM (
                    SELECT
                        a2.date_p,
                        a2.os_p,
                        a2.final_id AS gid,
                        CASE WHEN nd2.final_id IS NOT NULL THEN 1 ELSE 0 END AS is_new
                    FROM (
                        SELECT date_p, os_p, country_id, final_id
                        FROM stat_sdk.sdk_odz_active
                        WHERE date_p BETWEEN ${start_date} AND ${end_date_p90}
                            AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
                            AND os_p IS NOT NULL
                    ) a2
                    LEFT JOIN (
                        SELECT final_id, date_p
                        FROM stat_sdk.sdk_odz_new_device_info
                        WHERE date_p BETWEEN ${start_date} AND ${end_date_p90}
                            AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
                            AND os_p IS NOT NULL
                    ) nd2
                        ON a2.final_id = nd2.final_id AND a2.date_p = nd2.date_p
                ) fa2
                JOIN (
                    SELECT
                        date_p AS enter_abtest_date,
                        gid,
                        sdk_type AS os_type,
                        params['current_abcode'] AS abcode,
                        CAST(`time`/1000 AS bigint) AS event_ts
                    FROM stat_sdk.sdk_odz_source_data
                    WHERE date_p BETWEEN ${start_date} AND ${end_date}
                        AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
                        AND event_id = 'abcode_enter_test'
                        AND params['current_abcode'] IN (${abcode_in_list})
                ) e
                    ON e.gid = fa2.gid AND e.enter_abtest_date = fa2.date_p
            ) t2
            WHERE ranks = 1${enter_new_sql}
        ) e
            ON e.gid = fa.gid AND e.enter_abtest_date <= fa.date_p
    ) rs
    GROUP BY
        enter_abtest_date,
        date_p,
        abcode,
        DATEDIFF(
            from_unixtime(unix_timestamp(cast(date_p AS string), 'yyyyMMdd')),
            from_unixtime(unix_timestamp(cast(enter_abtest_date AS string), 'yyyyMMdd'))
        ),
        CAST(from_unixtime(unix_timestamp(cast(date_p AS string), 'yyyyMMdd'), 'u') AS int)
) b
    ON a.enter_abtest_date = b.enter_abtest_date
   AND a.abcode = b.abcode
WHERE a.control_active0 > 1000
  AND b.control_activex > 100
  AND b.lcx > 0
ORDER BY abcode, enter_abtest_date, active_date, lcx
