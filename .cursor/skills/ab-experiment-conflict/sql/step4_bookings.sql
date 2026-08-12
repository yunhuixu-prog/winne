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
                    AND params['current_abcode'] IN (${abcode_in_list})
            ) e
                ON e.gid = fa.gid AND e.enter_abtest_date = fa.date_p
            WHERE fa.date_p BETWEEN ${start_date} AND ${end_date}
        ) t
        WHERE ranks = 1${enter_new_sql}
    ) eu
        ON eu.gid = subevt.gid
        AND (eu.event_ts - 15) <= subevt.event_timestamp
) sub_event_ab
GROUP BY abcode, date_p, period_duration
ORDER BY abcode, dt, types
;
