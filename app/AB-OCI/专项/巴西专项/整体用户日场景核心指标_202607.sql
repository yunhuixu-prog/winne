-- AirBrush OCI｜整体用户日场景核心指标
-- 分析期：2026-07-01 至 2026-07-30；粒度：同一用户同一天
-- 与《巴西用户日场景分析》保持相同场景映射、功能表与留存成熟窗口。
-- 神舟临时查询会在 SQL 外层包装导出语句，因此本查询刻意不使用 WITH CTE。

SELECT
    scene_metrics.scene,
    dau_metrics.dau_user_days,
    scene_metrics.scene_user_days,
    scene_metrics.scene_user_days / dau_metrics.dau_user_days AS scene_penetration,
    scene_metrics.enter_pv,
    scene_metrics.enter_pv / scene_metrics.scene_user_days AS enter_frequency,
    scene_metrics.check_user_days,
    scene_metrics.check_user_days / scene_metrics.scene_user_days AS enter_check_rate,
    scene_metrics.save_user_days,
    scene_metrics.save_user_days / scene_metrics.scene_user_days AS enter_save_rate,
    scene_metrics.save_user_days / scene_metrics.check_user_days AS check_save_rate,
    scene_metrics.function_count_sum / scene_metrics.scene_user_days AS avg_function_count,
    scene_metrics.d1_sample_user_days,
    scene_metrics.d1_retained_user_days,
    scene_metrics.d1_retained_user_days / scene_metrics.d1_sample_user_days AS d1_retention_rate,
    scene_metrics.d7_sample_user_days,
    scene_metrics.d7_retained_user_days,
    scene_metrics.d7_retained_user_days / scene_metrics.d7_sample_user_days AS d7_retention_rate
FROM
(
    SELECT
        scene_user_day.scene,
        COUNT(1) AS scene_user_days,
        SUM(scene_user_day.enter_pv) AS enter_pv,
        SUM(CASE WHEN scene_user_day.check_pv > 0 THEN 1 ELSE 0 END) AS check_user_days,
        SUM(CASE WHEN scene_user_day.save_pv > 0 THEN 1 ELSE 0 END) AS save_user_days,
        SUM(scene_user_day.function_count) AS function_count_sum,
        SUM(CASE WHEN scene_user_day.date_p <= 20260729 THEN 1 ELSE 0 END) AS d1_sample_user_days,
        SUM(
            CASE
                WHEN scene_user_day.date_p <= 20260729 AND active_d1.gid IS NOT NULL THEN 1
                ELSE 0
            END
        ) AS d1_retained_user_days,
        SUM(CASE WHEN scene_user_day.date_p <= 20260723 THEN 1 ELSE 0 END) AS d7_sample_user_days,
        SUM(
            CASE
                WHEN scene_user_day.date_p <= 20260723 AND active_d7.gid IS NOT NULL THEN 1
                ELSE 0
            END
        ) AS d7_retained_user_days
    FROM
    (
        SELECT
            scene_rows.date_p,
            scene_rows.gid,
            scene_rows.scene,
            SUM(scene_rows.enter_pv) AS enter_pv,
            SUM(scene_rows.check_pv) AS check_pv,
            SUM(scene_rows.save_pv) AS save_pv,
            COUNT(1) AS function_count
        FROM
        (
            SELECT
                normalized.date_p,
                normalized.gid,
                normalized.function_name,
                normalized.enter_pv,
                normalized.check_pv,
                normalized.save_pv,
                CASE
                    WHEN normalized.function_name IN ('reshape','face','body','muscle','stretch')
                        THEN '人像结构精修'
                    WHEN normalized.function_name IN (
                        'skin','smooth','acne','skin tone','makeup','teeth','brighten',
                        'concealer','wrinkle','contour','matte','detail','blemish',
                        'eye brighten','dark circles','plump','clean skin','redness fix'
                    ) THEN '自然轻修'
                    WHEN normalized.function_name IN ('magic','ai retouch','glowup','preset','expression')
                        THEN 'AI一键出片'
                    WHEN normalized.function_name IN (
                        'filters','filter','relight','bokeh','prism','glitter','effects',
                        'effect','adjust','crop','resize','blur','texture'
                    ) THEN '氛围出片'
                    WHEN normalized.function_name IN (
                        'eraser','ai replace','ai expand','background','ai repair',
                        'stamp','face fix','text','select area','background adjust'
                    ) THEN '任务型工具编辑'
                    WHEN normalized.function_name IN (
                        'hair','ai image','ai tattoo','hair dye','hair enrich','hairstyles',
                        'hairdye finetune','enrich','volume','mykit'
                    ) THEN '玩法尝试'
                    ELSE NULL
                END AS scene
            FROM
            (
                SELECT
                    behavior.date_p,
                    behavior.gid,
                    CASE
                        WHEN LOWER(TRIM(behavior.sub_func_level2_name)) IN ('details', 'detail')
                            THEN 'detail'
                        WHEN LOWER(TRIM(behavior.sub_func_level2_name)) IN ('ai-retouch', 'ai_retouch', 'airetouch')
                            THEN 'ai retouch'
                        WHEN LOWER(TRIM(behavior.sub_func_level2_name)) IN ('ai-repair', 'ai_repair')
                            THEN 'ai repair'
                        WHEN LOWER(TRIM(behavior.sub_func_level2_name)) IN ('ai-expand', 'ai_expand')
                            THEN 'ai expand'
                        WHEN LOWER(TRIM(behavior.sub_func_level2_name)) IN ('ai-replace', 'ai_replace')
                            THEN 'ai replace'
                        WHEN LOWER(TRIM(behavior.sub_func_level2_name)) IN ('facefix', 'face_fix')
                            THEN 'face fix'
                        WHEN LOWER(TRIM(behavior.sub_func_level2_name)) IN ('skin_tone', 'skintone')
                            THEN 'skin tone'
                        WHEN LOWER(TRIM(behavior.sub_func_level2_name)) = 'glow up'
                            THEN 'glowup'
                        WHEN LOWER(TRIM(behavior.sub_func_level2_name)) IN ('aiimage', 'ai_image')
                            THEN 'ai image'
                        WHEN LOWER(TRIM(behavior.sub_func_level2_name)) IN ('aitattoo', 'ai_tattoo')
                            THEN 'ai tattoo'
                        ELSE LOWER(REGEXP_REPLACE(TRIM(behavior.sub_func_level2_name), '_', ' '))
                    END AS function_name,
                    SUM(CASE WHEN behavior.event_type = '进入' THEN behavior.cnt ELSE 0 END) AS enter_pv,
                    SUM(CASE WHEN behavior.event_type = '打勾' THEN behavior.cnt ELSE 0 END) AS check_pv,
                    SUM(CASE WHEN behavior.event_type = '保存' THEN behavior.cnt ELSE 0 END) AS save_pv
                FROM stat_sdk.airbrush_mdz_tool_behavior_detail behavior
                WHERE behavior.date_p BETWEEN 20260701 AND 20260730
                  AND behavior.model_p = 'image_edit'
                  AND behavior.tool_level = '2'
                  AND behavior.event_type IN ('进入', '打勾', '保存')
                  AND behavior.cnt > 0
                  AND behavior.gid IS NOT NULL
                  AND behavior.sub_func_level2_name IS NOT NULL
                  AND TRIM(behavior.sub_func_level2_name) <> ''
                GROUP BY
                    behavior.date_p,
                    behavior.gid,
                    CASE
                        WHEN LOWER(TRIM(behavior.sub_func_level2_name)) IN ('details', 'detail')
                            THEN 'detail'
                        WHEN LOWER(TRIM(behavior.sub_func_level2_name)) IN ('ai-retouch', 'ai_retouch', 'airetouch')
                            THEN 'ai retouch'
                        WHEN LOWER(TRIM(behavior.sub_func_level2_name)) IN ('ai-repair', 'ai_repair')
                            THEN 'ai repair'
                        WHEN LOWER(TRIM(behavior.sub_func_level2_name)) IN ('ai-expand', 'ai_expand')
                            THEN 'ai expand'
                        WHEN LOWER(TRIM(behavior.sub_func_level2_name)) IN ('ai-replace', 'ai_replace')
                            THEN 'ai replace'
                        WHEN LOWER(TRIM(behavior.sub_func_level2_name)) IN ('facefix', 'face_fix')
                            THEN 'face fix'
                        WHEN LOWER(TRIM(behavior.sub_func_level2_name)) IN ('skin_tone', 'skintone')
                            THEN 'skin tone'
                        WHEN LOWER(TRIM(behavior.sub_func_level2_name)) = 'glow up'
                            THEN 'glowup'
                        WHEN LOWER(TRIM(behavior.sub_func_level2_name)) IN ('aiimage', 'ai_image')
                            THEN 'ai image'
                        WHEN LOWER(TRIM(behavior.sub_func_level2_name)) IN ('aitattoo', 'ai_tattoo')
                            THEN 'ai tattoo'
                        ELSE LOWER(REGEXP_REPLACE(TRIM(behavior.sub_func_level2_name), '_', ' '))
                    END
            ) normalized
        ) scene_rows
        INNER JOIN
        (
            SELECT profile.date_p, profile.gid
            FROM stat_ab.filing_odz_active_user_profile profile
            WHERE profile.date_p BETWEEN 20260701 AND 20260730
              AND profile.gid IS NOT NULL
            GROUP BY profile.date_p, profile.gid
        ) profile_scope
          ON scene_rows.date_p = profile_scope.date_p
         AND scene_rows.gid = profile_scope.gid
        WHERE scene_rows.scene IS NOT NULL
          AND scene_rows.enter_pv > 0
        GROUP BY scene_rows.date_p, scene_rows.gid, scene_rows.scene
    ) scene_user_day
    LEFT JOIN
    (
        SELECT DISTINCT active.date_p, active.final_id AS gid
        FROM stat_sdk.sdk_odz_active active
        WHERE active.date_p BETWEEN 20260702 AND 20260730
          AND active.app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
          AND active.os_p IS NOT NULL
    ) active_d1
      ON scene_user_day.gid = active_d1.gid
     AND meitu_datediff(active_d1.date_p, scene_user_day.date_p) = 1
    LEFT JOIN
    (
        SELECT DISTINCT active.date_p, active.final_id AS gid
        FROM stat_sdk.sdk_odz_active active
        WHERE active.date_p BETWEEN 20260708 AND 20260730
          AND active.app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
          AND active.os_p IS NOT NULL
    ) active_d7
      ON scene_user_day.gid = active_d7.gid
     AND meitu_datediff(active_d7.date_p, scene_user_day.date_p) = 7
    GROUP BY scene_user_day.scene
) scene_metrics
CROSS JOIN
(
    SELECT COUNT(1) AS dau_user_days
    FROM
    (
        SELECT profile.date_p, profile.gid
        FROM stat_ab.filing_odz_active_user_profile profile
        WHERE profile.date_p BETWEEN 20260701 AND 20260730
          AND profile.gid IS NOT NULL
        GROUP BY profile.date_p, profile.gid
    ) overall_dau
) dau_metrics

