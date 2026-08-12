-- AirBrush AI任务表现：巴西 vs 整体
-- 时间：2026-06-01 ~ 2026-06-30
-- 事件：ai_func_use_result
-- 状态：is_success=1成功，0失败，2用户手动取消
-- 功能：second_func、third_func保留原始上报值，不做大小写、空值或名称映射
-- 耗时：time原始单位为毫秒；仅可转换为非负数的time参与平均值
-- 成功率/失败率/手动取消率的分母均为该功能的全部ai_func_use_result事件PV

SELECT
    '整体' AS market_name,
    event_detail.second_func_raw,
    event_detail.third_func_raw,
    COUNT(1) AS create_task_pv,
    COUNT(DISTINCT event_detail.gid) AS create_task_uv,
    SUM(CASE WHEN event_detail.status_raw = '1' THEN 1 ELSE 0 END) AS success_task_pv,
    SUM(CASE WHEN event_detail.status_raw = '0' THEN 1 ELSE 0 END) AS failed_task_pv,
    SUM(CASE WHEN event_detail.status_raw = '2' THEN 1 ELSE 0 END) AS manual_cancel_task_pv,
    SUM(
        CASE
            WHEN event_detail.status_raw NOT IN ('0', '1', '2')
              OR event_detail.status_raw IS NULL
            THEN 1 ELSE 0
        END
    ) AS unknown_status_task_pv,
    1.0 * SUM(CASE WHEN event_detail.status_raw = '1' THEN 1 ELSE 0 END)
        / COUNT(1) AS success_rate,
    1.0 * SUM(CASE WHEN event_detail.status_raw = '0' THEN 1 ELSE 0 END)
        / COUNT(1) AS failed_rate,
    1.0 * SUM(CASE WHEN event_detail.status_raw = '2' THEN 1 ELSE 0 END)
        / COUNT(1) AS manual_cancel_rate,
    AVG(
        CASE WHEN event_detail.status_raw = '1'
             THEN event_detail.duration_ms END
    ) AS success_avg_time_ms,
    AVG(
        CASE WHEN event_detail.status_raw = '0'
             THEN event_detail.duration_ms END
    ) AS failed_avg_time_ms,
    AVG(
        CASE WHEN event_detail.status_raw = '2'
             THEN event_detail.duration_ms END
    ) AS manual_cancel_avg_time_ms,
    SUM(
        CASE WHEN event_detail.status_raw = '1'
                   AND event_detail.duration_ms IS NOT NULL
             THEN 1 ELSE 0 END
    ) AS success_time_valid_pv,
    SUM(
        CASE WHEN event_detail.status_raw = '0'
                   AND event_detail.duration_ms IS NOT NULL
             THEN 1 ELSE 0 END
    ) AS failed_time_valid_pv,
    SUM(
        CASE WHEN event_detail.status_raw = '2'
                   AND event_detail.duration_ms IS NOT NULL
             THEN 1 ELSE 0 END
    ) AS manual_cancel_time_valid_pv
FROM (
    SELECT
        e.gid,
        e.params['second_func'] AS second_func_raw,
        e.params['third_func'] AS third_func_raw,
        e.params['is_success'] AS status_raw,
        CASE
            WHEN TRIM(NVL(e.params['time'], '')) <> ''
            THEN CAST(TRIM(e.params['time']) AS DOUBLE)
        END AS duration_ms
    FROM stat_sdk.sdk_odz_source_data e
    WHERE e.date_p BETWEEN 20260601 AND 20260630
      AND e.app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
      AND e.event_id = 'ai_func_use_result'
) event_detail
GROUP BY
    event_detail.second_func_raw,
    event_detail.third_func_raw

UNION ALL

SELECT
    '巴西' AS market_name,
    event_detail.second_func_raw,
    event_detail.third_func_raw,
    COUNT(1) AS create_task_pv,
    COUNT(DISTINCT event_detail.gid) AS create_task_uv,
    SUM(CASE WHEN event_detail.status_raw = '1' THEN 1 ELSE 0 END) AS success_task_pv,
    SUM(CASE WHEN event_detail.status_raw = '0' THEN 1 ELSE 0 END) AS failed_task_pv,
    SUM(CASE WHEN event_detail.status_raw = '2' THEN 1 ELSE 0 END) AS manual_cancel_task_pv,
    SUM(
        CASE
            WHEN event_detail.status_raw NOT IN ('0', '1', '2')
              OR event_detail.status_raw IS NULL
            THEN 1 ELSE 0
        END
    ) AS unknown_status_task_pv,
    1.0 * SUM(CASE WHEN event_detail.status_raw = '1' THEN 1 ELSE 0 END)
        / COUNT(1) AS success_rate,
    1.0 * SUM(CASE WHEN event_detail.status_raw = '0' THEN 1 ELSE 0 END)
        / COUNT(1) AS failed_rate,
    1.0 * SUM(CASE WHEN event_detail.status_raw = '2' THEN 1 ELSE 0 END)
        / COUNT(1) AS manual_cancel_rate,
    AVG(
        CASE WHEN event_detail.status_raw = '1'
             THEN event_detail.duration_ms END
    ) AS success_avg_time_ms,
    AVG(
        CASE WHEN event_detail.status_raw = '0'
             THEN event_detail.duration_ms END
    ) AS failed_avg_time_ms,
    AVG(
        CASE WHEN event_detail.status_raw = '2'
             THEN event_detail.duration_ms END
    ) AS manual_cancel_avg_time_ms,
    SUM(
        CASE WHEN event_detail.status_raw = '1'
                   AND event_detail.duration_ms IS NOT NULL
             THEN 1 ELSE 0 END
    ) AS success_time_valid_pv,
    SUM(
        CASE WHEN event_detail.status_raw = '0'
                   AND event_detail.duration_ms IS NOT NULL
             THEN 1 ELSE 0 END
    ) AS failed_time_valid_pv,
    SUM(
        CASE WHEN event_detail.status_raw = '2'
                   AND event_detail.duration_ms IS NOT NULL
             THEN 1 ELSE 0 END
    ) AS manual_cancel_time_valid_pv
FROM (
    SELECT
        ai_event.gid,
        ai_event.params['second_func'] AS second_func_raw,
        ai_event.params['third_func'] AS third_func_raw,
        ai_event.params['is_success'] AS status_raw,
        CASE
            WHEN TRIM(NVL(ai_event.params['time'], '')) <> ''
            THEN CAST(TRIM(ai_event.params['time']) AS DOUBLE)
        END AS duration_ms
    FROM (
        SELECT
            date_p,
            gid,
            params
        FROM stat_sdk.sdk_odz_source_data
        WHERE date_p BETWEEN 20260601 AND 20260630
          AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
          AND event_id = 'ai_func_use_result'
    ) ai_event
    INNER JOIN (
        SELECT
            active_user.date_p,
            active_user.final_id AS gid
        FROM (
            SELECT
                date_p,
                final_id,
                country_id
            FROM stat_sdk.sdk_odz_active
            WHERE date_p BETWEEN 20260601 AND 20260630
              AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
              AND os_p IS NOT NULL
        ) active_user
        INNER JOIN (
            SELECT DISTINCT id
            FROM stat_sdk.dim_rna_ip_location
            WHERE date_p = 20260630
              AND level = '1'
              AND name = '巴西'
        ) brazil
          ON active_user.country_id = brazil.id
        GROUP BY
            active_user.date_p,
            active_user.final_id
    ) brazil_user
      ON ai_event.date_p = brazil_user.date_p
     AND ai_event.gid = brazil_user.gid
) event_detail
GROUP BY
    event_detail.second_func_raw,
    event_detail.third_func_raw
