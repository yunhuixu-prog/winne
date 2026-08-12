-- AirBrush / 2026-06 / 巴西 vs 整体 / Adjust、Filters、Relight 同日使用组合
-- 建议引擎：Hive on Spark
--
-- 数据源：stat_sdk.airbrush_mdz_tool_behavior_detail（功能表）
-- 核心口径：
-- 1. 分析单元：同一 gid + date_p（用户日），同一天多次修图合并。
-- 2. 功能“使用”：event_type = '打勾' 且 cnt > 0。
-- 3. 不区分功能使用先后，拆成七类互斥组合。
-- 4. light_combo_share：组合用户日 / 至少使用 Adjust、Filters、Relight 之一的用户日。
-- 5. all_function_share：组合用户日 / 当天使用过任一二级功能的用户日。
-- 6. 整体包含巴西；巴西按功能表 country_id 关联国家维表识别。
-- 7. 不使用 WITH，规避神舟临时查询在 CTE 后插入结果写出语句导致的解析失败。

SELECT
    combo.light_combo,
    COUNT(1) AS overall_combo_user_days,
    COUNT(1) * 1.0
        / MAX(combo.overall_light_user_days) AS overall_light_combo_share,
    SUM(combo.is_brazil) AS brazil_combo_user_days,
    SUM(combo.is_brazil) * 1.0
        / MAX(combo.brazil_light_user_days) AS brazil_light_combo_share,
    (
        SUM(combo.is_brazil) * 1.0 / MAX(combo.brazil_light_user_days)
        - COUNT(1) * 1.0 / MAX(combo.overall_light_user_days)
    ) * 100 AS light_combo_gap_pp,
    (
        SUM(combo.is_brazil) * 1.0 / MAX(combo.brazil_light_user_days)
    ) / (
        COUNT(1) * 1.0 / MAX(combo.overall_light_user_days)
    ) AS brazil_vs_overall_light_combo_index,
    COUNT(1) * 1.0
        / MAX(combo.overall_any_function_user_days)
        AS overall_all_function_share,
    SUM(combo.is_brazil) * 1.0
        / MAX(combo.brazil_any_function_user_days)
        AS brazil_all_function_share,
    (
        SUM(combo.is_brazil) * 1.0
            / MAX(combo.brazil_any_function_user_days)
        - COUNT(1) * 1.0
            / MAX(combo.overall_any_function_user_days)
    ) * 100 AS all_function_share_gap_pp
FROM (
    SELECT
        labeled.user_day_id,
        labeled.is_brazil,
        labeled.light_combo,
        COUNT(1) OVER () AS overall_any_function_user_days,
        SUM(labeled.is_brazil) OVER () AS brazil_any_function_user_days,
        SUM(
            CASE WHEN labeled.light_combo IS NOT NULL THEN 1 ELSE 0 END
        ) OVER () AS overall_light_user_days,
        SUM(
            CASE
                WHEN labeled.light_combo IS NOT NULL
                 AND labeled.is_brazil = 1 THEN 1
                ELSE 0
            END
        ) OVER () AS brazil_light_user_days
    FROM (
        SELECT
            flags.user_day_id,
            flags.is_brazil,
            CASE
                WHEN flags.used_adjust = 1
                 AND flags.used_filters = 0
                 AND flags.used_relight = 0
                    THEN 'Adjust only'
                WHEN flags.used_adjust = 0
                 AND flags.used_filters = 1
                 AND flags.used_relight = 0
                    THEN 'Filters only'
                WHEN flags.used_adjust = 0
                 AND flags.used_filters = 0
                 AND flags.used_relight = 1
                    THEN 'Relight only'
                WHEN flags.used_adjust = 1
                 AND flags.used_filters = 1
                 AND flags.used_relight = 0
                    THEN 'Adjust + Filters'
                WHEN flags.used_adjust = 1
                 AND flags.used_filters = 0
                 AND flags.used_relight = 1
                    THEN 'Adjust + Relight'
                WHEN flags.used_adjust = 0
                 AND flags.used_filters = 1
                 AND flags.used_relight = 1
                    THEN 'Filters + Relight'
                WHEN flags.used_adjust = 1
                 AND flags.used_filters = 1
                 AND flags.used_relight = 1
                    THEN 'Adjust + Filters + Relight'
                ELSE NULL
            END AS light_combo
        FROM (
            SELECT
                user_features.user_day_id,
                MAX(user_features.feature_is_brazil) AS is_brazil,
                MAX(
                    CASE
                        WHEN user_features.function_name = 'Adjust' THEN 1
                        ELSE 0
                    END
                ) AS used_adjust,
                MAX(
                    CASE
                        WHEN user_features.function_name = 'Filters' THEN 1
                        ELSE 0
                    END
                ) AS used_filters,
                MAX(
                    CASE
                        WHEN user_features.function_name = 'Relight' THEN 1
                        ELSE 0
                    END
                ) AS used_relight
            FROM (
                SELECT
                    feature_rows.date_p,
                    feature_rows.gid,
                    CONCAT(
                        CAST(feature_rows.date_p AS STRING),
                        '#',
                        CAST(feature_rows.gid AS STRING)
                    ) AS user_day_id,
                    feature_rows.function_name,
                    MAX(feature_rows.row_is_brazil) AS feature_is_brazil
                FROM (
                    SELECT
                        behavior.date_p,
                        behavior.gid,
                        CASE WHEN brazil.id IS NOT NULL THEN 1 ELSE 0 END
                            AS row_is_brazil,
                        CASE
                            WHEN TRIM(behavior.sub_func_level2_name)
                                 IN ('Details', 'Detail')
                                THEN 'Detail'
                            WHEN LOWER(TRIM(behavior.sub_func_level2_name))
                                 = 'eraser'
                                THEN 'Eraser'
                            ELSE TRIM(behavior.sub_func_level2_name)
                        END AS function_name
                    FROM (
                        SELECT
                            f.date_p,
                            f.gid,
                            f.country_id,
                            f.sub_func_level2_name
                        FROM stat_sdk.airbrush_mdz_tool_behavior_detail f
                        WHERE f.date_p BETWEEN 20260601 AND 20260630
                          AND f.model_p = 'image_edit'
                          AND f.tool_level = '2'
                          AND f.event_type = '打勾'
                          AND f.cnt > 0
                          AND f.gid IS NOT NULL
                          AND f.sub_func_level2_name IS NOT NULL
                          AND TRIM(f.sub_func_level2_name) <> ''
                    ) behavior
                    LEFT JOIN (
                        SELECT DISTINCT
                            c.id
                        FROM stat_sdk.dim_rna_ip_location c
                        WHERE c.date_p = 20260630
                          AND c.level = '1'
                          AND c.name = '巴西'
                    ) brazil
                      ON behavior.country_id = brazil.id
                ) feature_rows
                GROUP BY
                    feature_rows.date_p,
                    feature_rows.gid,
                    feature_rows.function_name
            ) user_features
            GROUP BY user_features.user_day_id
        ) flags
    ) labeled
) combo
WHERE combo.light_combo IS NOT NULL
  AND combo.overall_light_user_days > 0
  AND combo.brazil_light_user_days > 0
  AND combo.overall_any_function_user_days > 0
  AND combo.brazil_any_function_user_days > 0
GROUP BY combo.light_combo
;
