-- AirBrush OCI｜图片编辑二级功能操作后次日活跃留存率
-- 时间：2026-06-01 至 2026-06-30；2026-06-30 的次留读取 2026-07-01 活跃
-- 市场：整体（分市场使用同口径单独执行后合并）
-- 引擎：Hive on Spark（大表月度扫描；若需要可再按 Presto 语法改写）
-- 口径：
--   1. 分母为“操作用户日”：某用户同一天对同一功能操作多次只计 1 次；
--   2. 分子为上述用户日在次日仍有 AirBrush 活跃的用户日；
--   3. 月度留存率 = 月内次日留存用户日之和 / 月内操作用户日之和；
--   4. “整体”包含所有国家/地区；国家按操作当天活跃记录归属；
--   5. 功能名 Details 统一为 Detail，eraser 统一为 Eraser，以对齐现有工作簿。

SELECT
    '整体' AS country_dimension,
    result.function_name,
    result.enter_user_days,
    result.enter_d1_retained_user_days,
    CASE
        WHEN result.enter_user_days > 0
        THEN CAST(result.enter_d1_retained_user_days AS DOUBLE) / result.enter_user_days
    END AS enter_d1_retention_rate,
    result.check_user_days,
    result.check_d1_retained_user_days,
    CASE
        WHEN result.check_user_days > 0
        THEN CAST(result.check_d1_retained_user_days AS DOUBLE) / result.check_user_days
    END AS check_d1_retention_rate,
    result.save_user_days,
    result.save_d1_retained_user_days,
    CASE
        WHEN result.save_user_days > 0
        THEN CAST(result.save_d1_retained_user_days AS DOUBLE) / result.save_user_days
    END AS save_d1_retention_rate
FROM
(
    SELECT
        retention_base.function_name,
        SUM(CASE WHEN retention_base.enter_pv > 0 THEN 1 ELSE 0 END) AS enter_user_days,
        SUM(CASE WHEN retention_base.enter_pv > 0 AND retention_base.is_d1_retained = 1 THEN 1 ELSE 0 END) AS enter_d1_retained_user_days,
        SUM(CASE WHEN retention_base.check_pv > 0 THEN 1 ELSE 0 END) AS check_user_days,
        SUM(CASE WHEN retention_base.check_pv > 0 AND retention_base.is_d1_retained = 1 THEN 1 ELSE 0 END) AS check_d1_retained_user_days,
        SUM(CASE WHEN retention_base.save_pv > 0 THEN 1 ELSE 0 END) AS save_user_days,
        SUM(CASE WHEN retention_base.save_pv > 0 AND retention_base.is_d1_retained = 1 THEN 1 ELSE 0 END) AS save_d1_retained_user_days
    FROM
    (
            SELECT
                user_function.date_p,
                user_function.gid,
                user_function.market_name,
                user_function.function_name,
                user_function.enter_pv,
                user_function.check_pv,
                user_function.save_pv,
                CASE WHEN next_active.gid IS NOT NULL THEN 1 ELSE 0 END AS is_d1_retained
            FROM
            (
                SELECT
                    behavior.date_p,
                    behavior.gid,
                    COALESCE(country_dim.name, '未知') AS market_name,
                    behavior.function_name,
                    behavior.enter_pv,
                    behavior.check_pv,
                    behavior.save_pv
                FROM
                (
                    SELECT
                        f.date_p,
                        f.gid,
                        CASE
                            WHEN TRIM(f.sub_func_level2_name) IN ('Details', 'Detail') THEN 'Detail'
                            WHEN LOWER(TRIM(f.sub_func_level2_name)) = 'eraser' THEN 'Eraser'
                            ELSE TRIM(f.sub_func_level2_name)
                        END AS function_name,
                        SUM(CASE WHEN f.event_type = '进入' THEN f.cnt ELSE 0 END) AS enter_pv,
                        SUM(CASE WHEN f.event_type = '打勾' THEN f.cnt ELSE 0 END) AS check_pv,
                        SUM(CASE WHEN f.event_type = '保存' THEN f.cnt ELSE 0 END) AS save_pv
                    FROM stat_sdk.airbrush_mdz_tool_behavior_detail f
                    WHERE f.date_p BETWEEN 20260601 AND 20260630
                      AND f.model_p = 'image_edit'
                      AND f.tool_level = '2'
                      AND TRIM(f.sub_func_level2_name) IN (
                            'Face', 'AI Retouch', 'Eraser', 'eraser', 'Filters',
                            'Relight', 'Body', 'Makeup', 'Magic', 'AI Repair',
                            'Hair', 'Reshape', 'Adjust', 'Teeth', 'AI Replace',
                            'AI Expand', 'Glowup', 'Background', 'Resize', 'Crop',
                            'Effects', 'Smooth', 'Contour', 'Concealer', 'Wrinkle',
                            'Skin Tone', 'Detail', 'Details', 'Brighten', 'Matte',
                            'Texture', 'Acne', 'Clean Skin'
                          )
                    GROUP BY
                        f.date_p,
                        f.gid,
                        CASE
                            WHEN TRIM(f.sub_func_level2_name) IN ('Details', 'Detail') THEN 'Detail'
                            WHEN LOWER(TRIM(f.sub_func_level2_name)) = 'eraser' THEN 'Eraser'
                            ELSE TRIM(f.sub_func_level2_name)
                        END
                ) behavior
                INNER JOIN
                (
                    SELECT
                        a.date_p,
                        a.final_id AS gid,
                        MAX(a.country_id) AS country_id
                    FROM stat_sdk.sdk_odz_active a
                    WHERE a.date_p BETWEEN 20260601 AND 20260630
                      AND a.app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
                      AND a.os_p IS NOT NULL
                    GROUP BY a.date_p, a.final_id
                ) active_day
                  ON behavior.date_p = active_day.date_p
                 AND behavior.gid = active_day.gid
                LEFT JOIN
                (
                    SELECT DISTINCT
                        c.id,
                        c.name
                    FROM stat_sdk.dim_rna_ip_location c
                    WHERE c.level = '1'
                      AND c.date_p IS NOT NULL
                ) country_dim
                  ON active_day.country_id = country_dim.id
            ) user_function
            LEFT JOIN
            (
                SELECT DISTINCT
                    a1.date_p,
                    a1.final_id AS gid
                FROM stat_sdk.sdk_odz_active a1
                WHERE a1.date_p BETWEEN 20260602 AND 20260701
                  AND a1.app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
                  AND a1.os_p IS NOT NULL
            ) next_active
              ON user_function.gid = next_active.gid
             AND next_active.date_p = CAST(
                    DATE_FORMAT(
                        DATE_ADD(
                            FROM_UNIXTIME(UNIX_TIMESTAMP(CAST(user_function.date_p AS STRING), 'yyyyMMdd')),
                            1
                        ),
                        'yyyyMMdd'
                    ) AS BIGINT
                 )
    ) retention_base
    GROUP BY retention_base.function_name
) result
;
