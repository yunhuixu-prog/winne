-- ====================================================================
-- 激励广告实验 · 冲突定量选择（Hive SQL，按 app/ab新sdk/说明 口径）
-- ====================================================================
-- 占位符（整数日期 yyyymmdd；神舟临时查询提交前替换为字面量）：
--   ${start_date}       实验开始日
--   ${end_date}         实验结束日
--   ${end_date_p90}    ${end_date} + 90 天（留存窗口右界）(目标是365天，但是由于查询限制只能查询90天，需要再调长)
--   ${end_date_p14}     ${end_date} + 14 天（订阅观察窗右界）
--   ${end_date_p7}      ${end_date} +  7 天（单用户价值窗右界）
--   ${end_date_m365}    ${end_date} - 365 天（YAU 窗口左界）(由于查询限制这个跑不了好家伙)
--   ${abcode_list} abcode 列表，例如 '28905','28906','28907'
--   AND enter_new = 1 表示进入实验时为新用户，可以取消该限制
-- abcode 列表在下方各段 IN (...) 中按需替换，例如 '11159','11160',...
--
-- ====================================================================
-- step1：计算留存率（进入实验当天活跃且当天为新用户，仅首次进入）
-- ====================================================================
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
        -- , os_type
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
                    AND params['current_abcode'] IN ('28905','28906','28907')
            ) e
                ON e.gid = fa.gid AND e.enter_abtest_date = fa.date_p
        ) t
        WHERE ranks = 1
          AND enter_new = 1
    ) enter_user
    GROUP BY enter_abtest_date, abcode --, os_type
) a
JOIN (
    SELECT
        enter_abtest_date,
        date_p AS active_date,
        abcode,
        -- os_type,
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
                        AND params['current_abcode'] IN ('28905','28906','28907')
                ) e
                    ON e.gid = fa2.gid AND e.enter_abtest_date = fa2.date_p
            ) t2
            WHERE ranks = 1
              AND enter_new = 1
        ) e
            ON e.gid = fa.gid AND e.enter_abtest_date <= fa.date_p
    ) rs
    GROUP BY
        enter_abtest_date,
        date_p,
        abcode,
        -- os_type,
        DATEDIFF(
            from_unixtime(unix_timestamp(cast(date_p AS string), 'yyyyMMdd')),
            from_unixtime(unix_timestamp(cast(enter_abtest_date AS string), 'yyyyMMdd'))
        ),
        CAST(from_unixtime(unix_timestamp(cast(date_p AS string), 'yyyyMMdd'), 'u') AS int)
) b
    ON a.enter_abtest_date = b.enter_abtest_date
   AND a.abcode = b.abcode
--    AND a.os_type = b.os_type
WHERE a.control_active0 > 1000
  AND b.control_activex > 100
  AND b.lcx > 0
;


-- ====================================================================
-- step2：单用户价值 ≈ (订阅毛利 USD + 广告收入) / 实验内活跃 DAU
-- 观察窗 [start_date, end_date+7]（含试用多 7 天）
-- ====================================================================
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
                        AND params['current_abcode'] IN ('28905','28906','28907')
                ) e
                    ON e.gid = fa2.gid AND e.enter_abtest_date = fa2.date_p
                WHERE fa2.date_p BETWEEN ${start_date} AND ${end_date}
            ) t
            WHERE ranks = 1
              AND enter_new = 1
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
                    AND params['current_abcode'] IN ('28905','28906','28907')
            ) e2
                ON e2.gid = fa3.gid AND e2.enter_abtest_date = fa3.date_p
            WHERE fa3.date_p BETWEEN ${start_date} AND ${end_date}
        ) t3
        WHERE ranks = 1
          AND enter_new = 1
    ) e
    ON e.gid = p.gid AND e.enter_abtest_date <= p.pay_date
    GROUP BY p.pay_date, e.abcode
) u
GROUP BY abcode
HAVING abcode IS NOT NULL
ORDER BY abcode
;


-- ====================================================================
-- step3：推全影响 = 进入实验活跃 DAU / 全量活跃 DAU（按 os_p）
-- ====================================================================
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
                    AND params['current_abcode'] IN ('28905','28906','28907')
            ) e
                ON e.gid = fa2.gid AND e.enter_abtest_date = fa2.date_p
        ) t
        WHERE ranks = 1
          AND enter_new = 1
    ) e
        ON e.gid = fa.gid AND e.enter_abtest_date <= fa.date_p
    GROUP BY fa.os_p, e.abcode
) b
    ON a.os_p = b.os_p
GROUP BY b.abcode
ORDER BY b.abcode
;


-- YAU：过去 365 天活跃（按 os_p）
SELECT
    os_p,
    COUNT(DISTINCT final_id) AS yau
FROM stat_sdk.sdk_odz_active
WHERE date_p BETWEEN ${end_date_m365} AND ${end_date}
    AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
    AND os_p IS NOT NULL
GROUP BY os_p
ORDER BY os_p
;


-- ====================================================================
-- step4：按日 × 周期 的付费 GMV（sub_suc 且 is_paid=1 的 paid_ord_amt）
-- 时间对齐：进入实验事件时间戳 <= 订阅成功事件时间戳 + 15 秒（与年收入估算口径一致）
-- 广告分支：TODO，占位 UNION 见下注释
-- ====================================================================
SELECT
    abcode,
    date_p AS dt,
    period_duration AS types,
    ROUND(SUM(CASE WHEN is_paid = 1 THEN paid_ord_amt END), 2) AS gmv
FROM (
    SELECT
        subevt.date_p,
        subevt.period_duration,
        subevt.is_paid,
        subevt.paid_ord_amt,
        eu.abcode
    FROM (
        SELECT
            date_p,
            gid,
            `duration` AS period_duration,
            is_paid,
            paid_ord_amt,
            unix_timestamp(event_time, 'yyyyMMddHHmmss') AS event_timestamp
        FROM stat_ab.filing_onz_sub_source_event_detail
        WHERE date_p BETWEEN ${start_date} AND ${end_date}
            AND event_id = 'sub_suc'
    ) subevt
    JOIN (
        SELECT gid, abcode, event_ts
        FROM (
            SELECT
                e.gid,
                e.abcode,
                e.event_ts,
                fa.is_new AS enter_new,
                row_number() OVER (PARTITION BY e.gid ORDER BY e.event_ts) AS ranks
            FROM (
                SELECT
                    a.date_p,
                    a.final_id AS gid,
                    CASE WHEN nd.final_id IS NOT NULL THEN 1 ELSE 0 END AS is_new
                FROM (
                    SELECT date_p, final_id
                    FROM stat_sdk.sdk_odz_active
                    WHERE date_p BETWEEN ${start_date} AND ${end_date}
                        AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
                        AND os_p IS NOT NULL
                ) a
                LEFT JOIN (
                    SELECT final_id, date_p
                    FROM stat_sdk.sdk_odz_new_device_info
                    WHERE date_p BETWEEN ${start_date} AND ${end_date}
                        AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
                        AND os_p IS NOT NULL
                ) nd
                    ON a.final_id = nd.final_id AND a.date_p = nd.date_p
            ) fa
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
                    AND params['current_abcode'] IN ('28905','28906','28907')
            ) e
                ON e.gid = fa.gid AND e.enter_abtest_date = fa.date_p
            WHERE fa.date_p BETWEEN ${start_date} AND ${end_date}
        ) t
        WHERE ranks = 1
          AND enter_new = 1
    ) eu
        ON eu.gid = subevt.gid
        AND (eu.event_ts - 15) <= subevt.event_timestamp
) sub_event_ab
GROUP BY abcode, date_p, period_duration
ORDER BY abcode, dt, types
;
