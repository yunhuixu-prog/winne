-- AirBrush / 2026-06 / 巴西 vs 整体 / 二级功能同日仅使用 X
-- 建议引擎：Hive on Spark
--
-- 数据源：stat_sdk.airbrush_mdz_tool_behavior_detail（功能表）
-- 口径：
-- 1. 分析单元：同一 gid + date_p（用户日），同一天多次修图合并。
-- 2. 功能“使用”：event_type = '打勾' 且 cnt > 0。
-- 3. 仅使用 X：该用户日只使用了一个二级功能，且该功能为 X。
-- 4. 整体包含巴西；巴西按功能表 country_id 关联国家维表识别。
-- 5. Details / Detail 统一为 Detail，Eraser 大小写统一。

SELECT
    user_day_function.function_name,
    COUNT(1) AS overall_x_user_days,
    SUM(user_day_function.is_brazil) AS brazil_x_user_days,
    SUM(
        CASE
            WHEN user_day_function.function_count = 1 THEN 1
            ELSE 0
        END
    ) AS overall_only_x_user_days,
    SUM(
        CASE
            WHEN user_day_function.function_count = 1
             AND user_day_function.is_brazil = 1 THEN 1
            ELSE 0
        END
    ) AS brazil_only_x_user_days
FROM (
    SELECT
        feature_market.date_p,
        feature_market.gid,
        feature_market.function_name,
        feature_market.is_brazil,
        COUNT(1) OVER (
            PARTITION BY feature_market.date_p, feature_market.gid
        ) AS function_count
    FROM (
        SELECT
            feature_grouped.date_p,
            feature_grouped.gid,
            feature_grouped.function_name,
            MAX(feature_grouped.feature_is_brazil) OVER (
                PARTITION BY feature_grouped.date_p, feature_grouped.gid
            ) AS is_brazil
        FROM (
            SELECT
                feature_rows.date_p,
                feature_rows.gid,
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
        ) feature_grouped
    ) feature_market
) user_day_function
GROUP BY
    user_day_function.function_name
ORDER BY
    brazil_x_user_days DESC
