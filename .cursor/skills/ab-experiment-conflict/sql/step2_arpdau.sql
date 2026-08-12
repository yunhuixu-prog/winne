-- step2 arpdau；新用户过滤见占位符 enter_new_sql（run_conflict_steps.py）
SELECT
    abcode,
    SUM(active_users) AS active_dau,
    SUM(sub_bookings) + SUM(ad_bookings) AS bookings,
    ROUND((SUM(sub_bookings) + SUM(ad_bookings)) / NULLIF(SUM(active_users), 0), 4) AS arpdau
FROM (
    SELECT
        date_p AS dt,
        abcode,
        COUNT(DISTINCT gid) AS active_users,
        CAST(0.0 AS double) AS sub_bookings,
        CAST(0.0 AS double) AS ad_bookings
    FROM (
        SELECT fa.date_p, fa.gid, e.abcode
        FROM (
            SELECT date_p, os_p, country_id, final_id AS gid
            FROM stat_sdk.sdk_odz_active
            WHERE date_p BETWEEN ${start_date} AND ${end_date_p7}
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
                        WHERE date_p BETWEEN ${start_date} AND ${end_date_p7}
                            AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
                            AND os_p IS NOT NULL
                    ) a2
                    LEFT JOIN (
                        SELECT final_id, date_p
                        FROM stat_sdk.sdk_odz_new_device_info
                        WHERE date_p BETWEEN ${start_date} AND ${end_date_p7}
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
                WHERE fa2.date_p BETWEEN ${start_date} AND ${end_date}
            ) t
            WHERE ranks = 1${enter_new_sql}
        ) e
            ON e.gid = fa.gid AND e.enter_abtest_date <= fa.date_p
    ) active_ab
    GROUP BY date_p, abcode

    UNION ALL

    SELECT
        p.pay_date AS dt,
        e.abcode,
        0 AS active_users,
        SUM(p.ord_amt_usd) AS sub_bookings,
        CAST(0.0 AS double) AS ad_bookings
    FROM (
        select pay_date, gid, ord_amt_usd
        from stat_vip.paid_oda_all_order_summary
        where app_id_p IN (7329803307041000000)
            and product_sub_line = 'AirBrush'
            and is_subscribe = '订阅'
            and pay_date BETWEEN ${start_date} AND ${end_date_p7}
    ) p
    JOIN (
        SELECT gid, abcode, enter_abtest_date
        FROM (
            SELECT
                e2.gid,
                e2.abcode,
                e2.enter_abtest_date,
                fa3.is_new AS enter_new,
                row_number() OVER (PARTITION BY e2.gid ORDER BY e2.event_ts) AS ranks
            FROM (
                SELECT
                    a3.date_p,
                    a3.final_id AS gid,
                    CASE WHEN nd3.final_id IS NOT NULL THEN 1 ELSE 0 END AS is_new
                FROM (
                    SELECT date_p, final_id
                    FROM stat_sdk.sdk_odz_active
                    WHERE date_p BETWEEN ${start_date} AND ${end_date_p7}
                        AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
                        AND os_p IS NOT NULL
                ) a3
                LEFT JOIN (
                    SELECT final_id, date_p
                    FROM stat_sdk.sdk_odz_new_device_info
                    WHERE date_p BETWEEN ${start_date} AND ${end_date_p7}
                        AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
                        AND os_p IS NOT NULL
                ) nd3
                    ON a3.final_id = nd3.final_id AND a3.date_p = nd3.date_p
            ) fa3
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
            ) e2
                ON e2.gid = fa3.gid AND e2.enter_abtest_date = fa3.date_p
            WHERE fa3.date_p BETWEEN ${start_date} AND ${end_date}
        ) t3
        WHERE ranks = 1${enter_new_sql}
    ) e
    ON e.gid = p.gid AND e.enter_abtest_date <= p.pay_date
    GROUP BY p.pay_date, e.abcode
) u
GROUP BY abcode
HAVING abcode IS NOT NULL
ORDER BY abcode
;
