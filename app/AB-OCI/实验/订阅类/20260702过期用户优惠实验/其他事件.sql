SELECT
    os_type,
    code,
    is_new,
    event_id,
    pop_type,
    strategy_name,
    is_hist_sub,
    is_cur_valid_sub,
    uv,
    enter_abtest_uv
FROM (
    SELECT
        a.os_type AS os_type
        ,CASE
            WHEN b.ab_code IN ('29032','29034') THEN '对照组'
            WHEN b.ab_code IN ('29033','29035') THEN '实验组A'
        END AS code
        ,b.is_new AS is_new
        ,a.event_id AS event_id
        ,a.pop_type AS pop_type
        ,a.strategy_name AS strategy_name
        ,b.is_hist_sub AS is_hist_sub
        ,b.is_cur_valid_sub AS is_cur_valid_sub
        ,COUNT(DISTINCT a.gid) AS uv
        ,0 AS enter_abtest_uv
    FROM (
        SELECT date_p, event_id
            ,CAST(`time`/1000 AS bigint) AS event_timestamp
            ,sdk_type AS os_type, gid
            ,params['pop_type'] AS pop_type
            ,params['strategy_name'] AS strategy_name
        FROM stat_sdk.sdk_odz_source_data
        WHERE date_p BETWEEN 20260702 AND 20260715
            AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
            AND event_id IN ('strategy_popup_show','strategy_popup_click','strategy_popup_sub_success')
    ) a
    JOIN (
        SELECT
            e.gid, e.os_type, e.is_new, e.ab_code, e.event_timestamp
            ,CASE
                WHEN COALESCE(p.hist_trial_cnt, 0) > 0
                    OR COALESCE(p.hist_pay_cnt, 0) > 0
                THEN 1 ELSE 0
            END AS is_hist_sub
            ,COALESCE(p.is_subscribed, 0) AS is_cur_valid_sub
        FROM (
            SELECT gid, os_type, is_new, ab_code, event_timestamp, date_p
            FROM (
                SELECT gid, os_type, is_new, ab_code, event_timestamp, date_p
                    ,ROW_NUMBER() OVER (PARTITION BY gid ORDER BY event_timestamp) AS ranks
                FROM stat_ab.filing_odz_abtest_active_user
                WHERE date_p BETWEEN 20260702 AND 20260715
                    AND ab_code IN ('29032','29033','29034','29035')
            ) t
            WHERE ranks = 1
        ) e
        LEFT JOIN (
            SELECT gid, date_p, is_subscribed, hist_trial_cnt, hist_pay_cnt
            FROM stat_ab.filing_odz_active_user_profile
            WHERE date_p BETWEEN 20260702 AND 20260715
        ) p
            ON e.gid = p.gid AND e.date_p = p.date_p
    ) b ON a.gid = b.gid
    WHERE b.event_timestamp - 15 <= a.event_timestamp
    GROUP BY a.os_type
        ,CASE
            WHEN b.ab_code IN ('29032','29034') THEN '对照组'
            WHEN b.ab_code IN ('29033','29035') THEN '实验组A'
        END
        ,b.is_new, a.event_id, a.pop_type, a.strategy_name
        ,b.is_hist_sub, b.is_cur_valid_sub

    UNION ALL

    SELECT
        u.os_type AS os_type
        ,CASE
            WHEN u.ab_code IN ('29032','29034') THEN '对照组'
            WHEN u.ab_code IN ('29033','29035') THEN '实验组A'
        END AS code
        ,u.is_new AS is_new
        ,'无' AS event_id
        ,'无' AS pop_type
        ,'无' AS strategy_name
        ,u.is_hist_sub AS is_hist_sub
        ,u.is_cur_valid_sub AS is_cur_valid_sub
        ,0 AS uv
        ,COUNT(DISTINCT u.gid) AS enter_abtest_uv
    FROM (
        SELECT
            e.gid, e.os_type, e.is_new, e.ab_code
            ,CASE
                WHEN COALESCE(p.hist_trial_cnt, 0) > 0
                    OR COALESCE(p.hist_pay_cnt, 0) > 0
                THEN 1 ELSE 0
            END AS is_hist_sub
            ,COALESCE(p.is_subscribed, 0) AS is_cur_valid_sub
        FROM (
            SELECT gid, os_type, is_new, ab_code, date_p
            FROM (
                SELECT gid, os_type, is_new, ab_code, date_p
                    ,ROW_NUMBER() OVER (PARTITION BY gid ORDER BY event_timestamp) AS ranks
                FROM stat_ab.filing_odz_abtest_active_user
                WHERE date_p BETWEEN 20260702 AND 20260715
                    AND ab_code IN ('29032','29033','29034','29035')
            ) t
            WHERE ranks = 1
        ) e
        LEFT JOIN (
            SELECT gid, date_p, is_subscribed, hist_trial_cnt, hist_pay_cnt
            FROM stat_ab.filing_odz_active_user_profile
            WHERE date_p BETWEEN 20260702 AND 20260715
        ) p
            ON e.gid = p.gid AND e.date_p = p.date_p
    ) u
    GROUP BY u.os_type
        ,CASE
            WHEN u.ab_code IN ('29032','29034') THEN '对照组'
            WHEN u.ab_code IN ('29033','29035') THEN '实验组A'
        END
        ,u.is_new, u.is_hist_sub, u.is_cur_valid_sub
) result
