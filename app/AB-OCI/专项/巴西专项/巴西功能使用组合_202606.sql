-- AirBrush / 2026-06 / 巴西 vs 整体 / 二级功能同日共现
-- 建议引擎：Hive on Spark
--
-- 数据源：stat_sdk.airbrush_mdz_tool_behavior_detail（功能表）
-- 核心口径：
-- 1. 分析单元：同一 gid + date_p（用户日），同一天多次修图合并。
-- 2. 功能“使用”：event_type = '打勾' 且 cnt > 0。
-- 3. X 与 Y 共现：同一用户日同时使用 X、Y，不区分先后。
-- 4. co_usage_share = 同时使用 X、Y 的用户日 / 使用 X 的用户日。
-- 5. pair_share = 同时使用 X、Y 的用户日 / 当天使用过任一二级功能的用户日。
-- 6. affinity（组合 lift）> 1 表示两项功能相较独立使用预期更容易共同出现。
-- 7. 整体包含巴西；巴西按功能表 country_id 关联国家维表识别。
-- 8. 不使用 WITH，规避神舟临时查询在 CTE 后插入结果写出语句导致的解析失败。

SELECT
    pair.feature_x,
    pair.feature_y,
    pair.overall_x_user_days,
    pair.overall_pair_user_days,
    pair.overall_pair_user_days * 1.0
        / pair.overall_x_user_days AS overall_co_usage_share,
    pair.brazil_x_user_days,
    pair.brazil_pair_user_days,
    pair.brazil_pair_user_days * 1.0
        / pair.brazil_x_user_days AS brazil_co_usage_share,
    (
        pair.brazil_pair_user_days * 1.0 / pair.brazil_x_user_days
        - pair.overall_pair_user_days * 1.0 / pair.overall_x_user_days
    ) * 100 AS co_usage_gap_pp,
    (
        pair.brazil_pair_user_days * 1.0 / pair.brazil_x_user_days
    ) / (
        pair.overall_pair_user_days * 1.0 / pair.overall_x_user_days
    ) AS brazil_vs_overall_co_usage_index,
    pair.overall_pair_user_days * 1.0
        / pair.overall_any_function_user_days AS overall_pair_share,
    pair.brazil_pair_user_days * 1.0
        / pair.brazil_any_function_user_days AS brazil_pair_share,
    (
        pair.brazil_pair_user_days * 1.0
            / pair.brazil_any_function_user_days
        - pair.overall_pair_user_days * 1.0
            / pair.overall_any_function_user_days
    ) * 100 AS pair_share_gap_pp,
    (
        pair.overall_pair_user_days * 1.0
            / pair.overall_any_function_user_days
    ) / (
        (pair.overall_x_user_days * 1.0
            / pair.overall_any_function_user_days)
        * (pair.overall_y_user_days * 1.0
            / pair.overall_any_function_user_days)
    ) AS overall_affinity,
    (
        pair.brazil_pair_user_days * 1.0
            / pair.brazil_any_function_user_days
    ) / (
        (pair.brazil_x_user_days * 1.0
            / pair.brazil_any_function_user_days)
        * (pair.brazil_y_user_days * 1.0
            / pair.brazil_any_function_user_days)
    ) AS brazil_affinity,
    (
        pair.brazil_pair_user_days * 1.0
            / pair.brazil_any_function_user_days
    ) / (
        pair.overall_pair_user_days * 1.0
            / pair.overall_any_function_user_days
    ) AS brazil_vs_overall_pair_index
FROM (
    SELECT
        feature_x.function_name AS feature_x,
        feature_y.function_name AS feature_y,
        MAX(feature_x.overall_function_user_days) AS overall_x_user_days,
        MAX(feature_x.brazil_function_user_days) AS brazil_x_user_days,
        MAX(feature_y.overall_function_user_days) AS overall_y_user_days,
        MAX(feature_y.brazil_function_user_days) AS brazil_y_user_days,
        MAX(feature_x.overall_any_function_user_days)
            AS overall_any_function_user_days,
        MAX(feature_x.brazil_any_function_user_days)
            AS brazil_any_function_user_days,
        COUNT(1) AS overall_pair_user_days,
        SUM(CASE WHEN feature_x.is_brazil = 1 THEN 1 ELSE 0 END)
            AS brazil_pair_user_days
    FROM (
        SELECT
            feature_ranked.date_p,
            feature_ranked.gid,
            feature_ranked.function_name,
            feature_ranked.is_brazil,
            COUNT(1) OVER (
                PARTITION BY feature_ranked.function_name
            ) AS overall_function_user_days,
            SUM(feature_ranked.is_brazil) OVER (
                PARTITION BY feature_ranked.function_name
            ) AS brazil_function_user_days,
            SUM(
                CASE
                    WHEN feature_ranked.user_day_row_number = 1 THEN 1
                    ELSE 0
                END
            ) OVER () AS overall_any_function_user_days,
            SUM(
                CASE
                    WHEN feature_ranked.user_day_row_number = 1
                     AND feature_ranked.is_brazil = 1 THEN 1
                    ELSE 0
                END
            ) OVER () AS brazil_any_function_user_days
        FROM (
            SELECT
                feature_market.date_p,
                feature_market.gid,
                feature_market.function_name,
                feature_market.is_brazil,
                ROW_NUMBER() OVER (
                    PARTITION BY feature_market.date_p, feature_market.gid
                    ORDER BY feature_market.function_name
                ) AS user_day_row_number
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
        ) feature_ranked
    ) feature_x
    INNER JOIN (
        SELECT
            feature_market.date_p,
            feature_market.gid,
            feature_market.function_name,
            feature_market.is_brazil,
            COUNT(1) OVER (
                PARTITION BY feature_market.function_name
            ) AS overall_function_user_days,
            SUM(feature_market.is_brazil) OVER (
                PARTITION BY feature_market.function_name
            ) AS brazil_function_user_days
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
    ) feature_y
      ON feature_x.date_p = feature_y.date_p
     AND feature_x.gid = feature_y.gid
     AND feature_x.function_name <> feature_y.function_name
    GROUP BY
        feature_x.function_name,
        feature_y.function_name
) pair
WHERE pair.overall_x_user_days > 0
  AND pair.brazil_x_user_days > 0
  AND pair.overall_y_user_days > 0
  AND pair.brazil_y_user_days > 0
  AND pair.overall_any_function_user_days > 0
  AND pair.brazil_any_function_user_days > 0
;
