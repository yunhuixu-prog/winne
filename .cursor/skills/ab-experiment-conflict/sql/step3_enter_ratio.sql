SELECT
    b.abcode,
    SUM(b.abtest_dau) / NULLIF(SUM(a.dau), 0) AS abtest_ratio
FROM (
    SELECT os_p, COUNT(DISTINCT final_id) AS dau
    FROM stat_sdk.sdk_odz_active
    WHERE date_p BETWEEN ${start_date} AND ${end_date}
        AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
        AND os_p IS NOT NULL
    GROUP BY os_p
) a
JOIN (
    SELECT fa.os_p, e.abcode, COUNT(DISTINCT fa.gid) AS abtest_dau
    FROM (
        SELECT date_p, os_p, final_id AS gid
        FROM stat_sdk.sdk_odz_active
        WHERE date_p BETWEEN ${start_date} AND ${end_date}
            AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
            AND os_p IS NOT NULL
    ) fa
    JOIN (
        SELECT gid, abcode, enter_abtest_date
        FROM (
            SELECT
                e.gid,
                e.abcode,
                e.enter_abtest_date,
                fa2.is_new AS enter_new,
                row_number() OVER (PARTITION BY e.gid ORDER BY e.event_ts) AS ranks
            FROM (
                SELECT
                    a2.date_p,
                    a2.final_id AS gid,
                    CASE WHEN nd2.final_id IS NOT NULL THEN 1 ELSE 0 END AS is_new
                FROM (
                    SELECT date_p, final_id
                    FROM stat_sdk.sdk_odz_active
                    WHERE date_p BETWEEN ${start_date} AND ${end_date}
                        AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
                        AND os_p IS NOT NULL
                ) a2
                LEFT JOIN (
                    SELECT final_id, date_p
                    FROM stat_sdk.sdk_odz_new_device_info
                    WHERE date_p BETWEEN ${start_date} AND ${end_date}
                        AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
                        AND os_p IS NOT NULL
                ) nd2
                    ON a2.final_id = nd2.final_id AND a2.date_p = nd2.date_p
            ) fa2
            JOIN (
                SELECT
                    date_p AS enter_abtest_date,
                    gid,
                    params['current_abcode'] AS abcode,
                    CAST(`time`/1000 AS bigint) AS event_ts
                FROM stat_sdk.sdk_odz_source_data
                WHERE date_p BETWEEN ${start_date} AND ${end_date}
                    AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
                    AND event_id = 'abcode_enter_test'
                    AND params['current_abcode'] IN (${abcode_in_list})
            ) e
                ON e.gid = fa2.gid AND e.enter_abtest_date = fa2.date_p
        ) t
        WHERE ranks = 1${enter_new_sql}
    ) e
        ON e.gid = fa.gid AND e.enter_abtest_date <= fa.date_p
    GROUP BY fa.os_p, e.abcode
) b
    ON a.os_p = b.os_p
GROUP BY b.abcode
ORDER BY b.abcode
;
