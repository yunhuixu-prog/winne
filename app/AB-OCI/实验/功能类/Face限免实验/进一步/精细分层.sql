-- Face 限免实验 · 进入实验用户留存率
-- 占位符（yyyyMMdd）：
--   ${start_date}    实验开始日（进组日左界）
--   ${end_date}      实验结束日（进组日右界）
--   ${now_date}      当前日期
--   ${start_date_m30} ${start_date}-30 天（进组前30天窗口左界，用于减少扫描分区）
--   ${end_date_m1}   ${end_date}-1 天（次留可观测进组日上界）
-- 口径：活跃表.sdk_odz_active + 事件表 abcode_enter_test（与 核心指标.sql / 活跃表.sql 一致）
-- 进组：首次 abcode_enter_test 且当日活跃（enter_abtest_date = 活跃 date_p）；默认全量新老用户，可按 is_new 筛选

SELECT
    ab_group,
    is_new,
    os_p,
    case when active_days_30d<=2 then active_days_30d else 999 end active_days_30d,
    case when save_days_30d<=2 then save_days_30d else 999 end save_days_30d,
    case when save_pv_30d<=2 then save_pv_30d else 999 end save_pv_30d,
    case when face_enter_days_30d<=2 then face_enter_days_30d else 999 end face_enter_days_30d,
    case when face_enter_pv_30d<=2 then face_enter_pv_30d else 999 end face_enter_pv_30d,
    case when face_save_days_30d<=2 then face_save_days_30d else 999 end face_save_days_30d,
    case when face_sub_enter_days_30d<=2 then face_sub_enter_days_30d else 999 end face_sub_enter_days_30d,
    COUNT(DISTINCT CASE WHEN enter_abtest_date <= ${end_date_m1} THEN gid END) AS enter_uv_for_1d,
    COUNT(DISTINCT CASE WHEN enter_abtest_date <= ${end_date_m1} AND retention_1 = 1 THEN gid END) AS retention_1_uv,
    ROUND(
        COUNT(DISTINCT CASE WHEN enter_abtest_date <= ${end_date_m1} AND retention_1 = 1 THEN gid END) * 1.0
        / NULLIF(COUNT(DISTINCT CASE WHEN enter_abtest_date <= ${end_date_m1} THEN gid END), 0),
        4
    ) AS retention_1_rate
FROM (
    SELECT
        eu.gid,
        eu.ab_group,
        eu.is_new,
        eu.os_p,
        eu.enter_abtest_date,
        MAX(CASE WHEN DATEDIFF(
            FROM_UNIXTIME(UNIX_TIMESTAMP(CAST(fa.date_p AS STRING), 'yyyyMMdd')),
            FROM_UNIXTIME(UNIX_TIMESTAMP(CAST(eu.enter_abtest_date AS STRING), 'yyyyMMdd'))
        ) = 1 THEN 1 ELSE 0 END) AS retention_1,
        MAX(CASE WHEN DATEDIFF(
            FROM_UNIXTIME(UNIX_TIMESTAMP(CAST(fa.date_p AS STRING), 'yyyyMMdd')),
            FROM_UNIXTIME(UNIX_TIMESTAMP(CAST(eu.enter_abtest_date AS STRING), 'yyyyMMdd'))
        ) = 3 THEN 1 ELSE 0 END) AS retention_3,
        MAX(CASE WHEN DATEDIFF(
            FROM_UNIXTIME(UNIX_TIMESTAMP(CAST(fa.date_p AS STRING), 'yyyyMMdd')),
            FROM_UNIXTIME(UNIX_TIMESTAMP(CAST(eu.enter_abtest_date AS STRING), 'yyyyMMdd'))
        ) = 7 THEN 1 ELSE 0 END) AS retention_7,

        -- 进组前30天：活跃/保存/Face 进入&保存（天数、次数）
        COUNT(DISTINCT CASE
            WHEN DATEDIFF(
                FROM_UNIXTIME(UNIX_TIMESTAMP(CAST(eu.enter_abtest_date AS STRING), 'yyyyMMdd')),
                FROM_UNIXTIME(UNIX_TIMESTAMP(CAST(fa.date_p AS STRING), 'yyyyMMdd'))
            ) BETWEEN 1 AND 30 THEN fa.date_p
        END) AS active_days_30d,

        COUNT(DISTINCT CASE
            WHEN DATEDIFF(
                FROM_UNIXTIME(UNIX_TIMESTAMP(CAST(eu.enter_abtest_date AS STRING), 'yyyyMMdd')),
                FROM_UNIXTIME(UNIX_TIMESTAMP(CAST(fa.date_p AS STRING), 'yyyyMMdd'))
            ) BETWEEN 1 AND 30
             AND COALESCE(b.save_pv, 0) > 0 THEN fa.date_p
        END) AS save_days_30d,
        SUM(CASE
            WHEN DATEDIFF(
                FROM_UNIXTIME(UNIX_TIMESTAMP(CAST(eu.enter_abtest_date AS STRING), 'yyyyMMdd')),
                FROM_UNIXTIME(UNIX_TIMESTAMP(CAST(fa.date_p AS STRING), 'yyyyMMdd'))
            ) BETWEEN 1 AND 30 THEN COALESCE(b.save_pv, 0)
            ELSE 0
        END) AS save_pv_30d,

        COUNT(DISTINCT CASE
            WHEN DATEDIFF(
                FROM_UNIXTIME(UNIX_TIMESTAMP(CAST(eu.enter_abtest_date AS STRING), 'yyyyMMdd')),
                FROM_UNIXTIME(UNIX_TIMESTAMP(CAST(fa.date_p AS STRING), 'yyyyMMdd'))
            ) BETWEEN 1 AND 30
             AND COALESCE(b.face_enter_pv, 0) > 0 THEN fa.date_p
        END) AS face_enter_days_30d,
        SUM(CASE
            WHEN DATEDIFF(
                FROM_UNIXTIME(UNIX_TIMESTAMP(CAST(eu.enter_abtest_date AS STRING), 'yyyyMMdd')),
                FROM_UNIXTIME(UNIX_TIMESTAMP(CAST(fa.date_p AS STRING), 'yyyyMMdd'))
            ) BETWEEN 1 AND 30 THEN COALESCE(b.face_enter_pv, 0)
            ELSE 0
        END) AS face_enter_pv_30d,

        COUNT(DISTINCT CASE
            WHEN DATEDIFF(
                FROM_UNIXTIME(UNIX_TIMESTAMP(CAST(eu.enter_abtest_date AS STRING), 'yyyyMMdd')),
                FROM_UNIXTIME(UNIX_TIMESTAMP(CAST(fa.date_p AS STRING), 'yyyyMMdd'))
            ) BETWEEN 1 AND 30
             AND COALESCE(b.face_save_pv, 0) > 0 THEN fa.date_p
        END) AS face_save_days_30d,
        SUM(CASE
            WHEN DATEDIFF(
                FROM_UNIXTIME(UNIX_TIMESTAMP(CAST(eu.enter_abtest_date AS STRING), 'yyyyMMdd')),
                FROM_UNIXTIME(UNIX_TIMESTAMP(CAST(fa.date_p AS STRING), 'yyyyMMdd'))
            ) BETWEEN 1 AND 30 THEN COALESCE(b.face_save_pv, 0)
            ELSE 0
        END) AS face_save_pv_30d,

        -- 进组前30天：Face 订阅墙进入（source_module=p_edit, source_0=f_face）
        COUNT(DISTINCT CASE
            WHEN DATEDIFF(
                FROM_UNIXTIME(UNIX_TIMESTAMP(CAST(eu.enter_abtest_date AS STRING), 'yyyyMMdd')),
                FROM_UNIXTIME(UNIX_TIMESTAMP(CAST(fa.date_p AS STRING), 'yyyyMMdd'))
            ) BETWEEN 1 AND 30
             AND COALESCE(s.face_sub_enter_pv, 0) > 0 THEN fa.date_p
        END) AS face_sub_enter_days_30d,
        SUM(CASE
            WHEN DATEDIFF(
                FROM_UNIXTIME(UNIX_TIMESTAMP(CAST(eu.enter_abtest_date AS STRING), 'yyyyMMdd')),
                FROM_UNIXTIME(UNIX_TIMESTAMP(CAST(fa.date_p AS STRING), 'yyyyMMdd'))
            ) BETWEEN 1 AND 30 THEN COALESCE(s.face_sub_enter_pv, 0)
            ELSE 0
        END) AS face_sub_enter_pv_30d
    FROM (
        SELECT
            gid,
            os_p,
            is_new,
            ab_group,
            enter_abtest_date
        FROM (
            SELECT
                fa.gid,
                fa.os_p,
                fa.is_new,
                e.ab_code,
                e.enter_abtest_date,
                e.event_timestamp,
                CASE
                    WHEN e.ab_code IN ('28926', '28929') THEN '对照组'
                    WHEN e.ab_code IN ('28927', '28930') THEN '实验组A'
                    WHEN e.ab_code IN ('28928', '28931') THEN '实验组B'
                END AS ab_group,
                ROW_NUMBER() OVER (PARTITION BY e.gid ORDER BY e.event_timestamp) AS ranks
            FROM (
                SELECT
                    a.date_p,
                    a.os_p,
                    a.final_id AS gid,
                    CASE WHEN new_device.final_id IS NOT NULL THEN 'New' ELSE 'Old' END AS is_new
                FROM (
                    SELECT date_p, os_p, country_id, final_id
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
                ) new_device
                    ON a.final_id = new_device.final_id AND a.date_p = new_device.date_p
            ) fa
            JOIN (
                SELECT
                    date_p AS enter_abtest_date,
                    CAST(`time` / 1000 AS BIGINT) AS event_timestamp,
                    gid,
                    params['current_abcode'] AS ab_code
                FROM stat_sdk.sdk_odz_source_data
                WHERE date_p BETWEEN ${start_date} AND ${end_date}
                    AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
                    AND event_id = 'abcode_enter_test'
                    AND params['current_abcode'] IN ('28926', '28927', '28928', '28929', '28930', '28931')
            ) e
                ON e.gid = fa.gid AND e.enter_abtest_date = fa.date_p
            WHERE e.gid IS NOT NULL
        ) t
        WHERE ranks = 1
          -- AND is_new = 'Old'                 -- 仅老用户时取消注释
    ) eu
    LEFT JOIN (
        SELECT date_p, final_id AS gid
        FROM stat_sdk.sdk_odz_active
        WHERE date_p BETWEEN ${start_date_m30} AND ${now_date}
            AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
            AND os_p IS NOT NULL
    ) fa
        ON eu.gid = fa.gid --AND eu.enter_abtest_date <= fa.date_p
    LEFT JOIN (
        -- 功能行为聚合到 gid-date_p（tool_level=2：sub_func_level2_name 维度）
        SELECT
            date_p,
            gid,
            SUM(CASE WHEN tool_level IN ('1') and event_type = '保存' THEN cnt ELSE 0 END) AS save_pv,
            SUM(CASE WHEN tool_level IN ('2') and event_type = '进入' AND sub_func_level2_name = 'Face' THEN cnt ELSE 0 END) AS face_enter_pv,
            SUM(CASE WHEN tool_level IN ('2') and event_type = '保存' AND sub_func_level2_name = 'Face' THEN cnt ELSE 0 END) AS face_save_pv
        FROM stat_sdk.airbrush_mdz_tool_behavior_detail
        WHERE date_p BETWEEN ${start_date_m30} AND ${end_date}
            AND model_p IN ('image_edit')
            -- AND tool_level IN ('2')
            AND event_type IN ('进入', '保存')
            AND gid IS NOT NULL
        GROUP BY date_p, gid
    ) b
        ON eu.gid = b.gid AND fa.date_p = b.date_p
    LEFT JOIN (
        -- Face 订阅墙进入（订阅表.sql · filing_onz_sub_source_event_detail）
        SELECT
            date_p,
            gid,
            SUM(CASE WHEN event_id = 'w_subscription_enter' THEN 1 ELSE 0 END) AS face_sub_enter_pv
        FROM stat_ab.filing_onz_sub_source_event_detail
        WHERE date_p BETWEEN ${start_date_m30} AND ${end_date}
            AND event_id = 'w_subscription_enter'
            AND source_module = 'p_edit'
            AND source_0 = 'f_face'
            AND gid IS NOT NULL
        GROUP BY date_p, gid
    ) s
        ON eu.gid = s.gid AND fa.date_p = s.date_p
    GROUP BY eu.gid, eu.ab_group, eu.is_new, eu.os_p, eu.enter_abtest_date
) user_ret
GROUP BY ab_group, is_new, os_p
    , case when active_days_30d<=2 then active_days_30d else 999 end
    , case when save_days_30d<=2 then save_days_30d else 999 end
    , case when save_pv_30d<=2 then save_pv_30d else 999 end
    , case when face_enter_days_30d<=2 then face_enter_days_30d else 999 end
    , case when face_enter_pv_30d<=2 then face_enter_pv_30d else 999 end
    , case when face_save_days_30d<=2 then face_save_days_30d else 999 end
    , case when face_sub_enter_days_30d<=2 then face_sub_enter_days_30d else 999 end
;
