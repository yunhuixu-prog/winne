-- AirBrush OCI｜整体用户日场景关联汇总
-- 分析期：2026-07-01 至 2026-07-30；粒度：同一用户同一天
-- 输出一行：六类场景用户日、15组两两共用用户日、场景数分布。
-- 不使用 WITH CTE，以兼容神舟临时查询的导出包装。

SELECT
    COUNT(1) AS covered_user_days,
    SUM(flags.portrait_flag) AS portrait_user_days,
    SUM(flags.natural_flag) AS natural_user_days,
    SUM(flags.ai_flag) AS ai_user_days,
    SUM(flags.atmosphere_flag) AS atmosphere_user_days,
    SUM(flags.task_flag) AS task_user_days,
    SUM(flags.play_flag) AS play_user_days,
    SUM(flags.portrait_flag * flags.natural_flag) AS portrait_natural_user_days,
    SUM(flags.portrait_flag * flags.ai_flag) AS portrait_ai_user_days,
    SUM(flags.portrait_flag * flags.atmosphere_flag) AS portrait_atmosphere_user_days,
    SUM(flags.portrait_flag * flags.task_flag) AS portrait_task_user_days,
    SUM(flags.portrait_flag * flags.play_flag) AS portrait_play_user_days,
    SUM(flags.natural_flag * flags.ai_flag) AS natural_ai_user_days,
    SUM(flags.natural_flag * flags.atmosphere_flag) AS natural_atmosphere_user_days,
    SUM(flags.natural_flag * flags.task_flag) AS natural_task_user_days,
    SUM(flags.natural_flag * flags.play_flag) AS natural_play_user_days,
    SUM(flags.ai_flag * flags.atmosphere_flag) AS ai_atmosphere_user_days,
    SUM(flags.ai_flag * flags.task_flag) AS ai_task_user_days,
    SUM(flags.ai_flag * flags.play_flag) AS ai_play_user_days,
    SUM(flags.atmosphere_flag * flags.task_flag) AS atmosphere_task_user_days,
    SUM(flags.atmosphere_flag * flags.play_flag) AS atmosphere_play_user_days,
    SUM(flags.task_flag * flags.play_flag) AS task_play_user_days,
    SUM(CASE WHEN flags.scene_count = 1 THEN 1 ELSE 0 END) AS scene_count_1_user_days,
    SUM(CASE WHEN flags.scene_count = 2 THEN 1 ELSE 0 END) AS scene_count_2_user_days,
    SUM(CASE WHEN flags.scene_count = 3 THEN 1 ELSE 0 END) AS scene_count_3_user_days,
    SUM(CASE WHEN flags.scene_count = 4 THEN 1 ELSE 0 END) AS scene_count_4_user_days,
    SUM(CASE WHEN flags.scene_count = 5 THEN 1 ELSE 0 END) AS scene_count_5_user_days,
    SUM(CASE WHEN flags.scene_count = 6 THEN 1 ELSE 0 END) AS scene_count_6_user_days
FROM
(
    SELECT
        scene_user_day.date_p,
        scene_user_day.gid,
        MAX(CASE WHEN scene_user_day.scene = '人像结构精修' THEN 1 ELSE 0 END) AS portrait_flag,
        MAX(CASE WHEN scene_user_day.scene = '自然轻修' THEN 1 ELSE 0 END) AS natural_flag,
        MAX(CASE WHEN scene_user_day.scene = 'AI一键出片' THEN 1 ELSE 0 END) AS ai_flag,
        MAX(CASE WHEN scene_user_day.scene = '氛围出片' THEN 1 ELSE 0 END) AS atmosphere_flag,
        MAX(CASE WHEN scene_user_day.scene = '任务型工具编辑' THEN 1 ELSE 0 END) AS task_flag,
        MAX(CASE WHEN scene_user_day.scene = '玩法尝试' THEN 1 ELSE 0 END) AS play_flag,
        COUNT(1) AS scene_count
    FROM
    (
        SELECT
            scene_rows.date_p,
            scene_rows.gid,
            scene_rows.scene
        FROM
        (
            SELECT
                normalized.date_p,
                normalized.gid,
                normalized.enter_pv,
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
                        WHEN LOWER(TRIM(behavior.sub_func_level2_name)) IN ('details', 'detail') THEN 'detail'
                        WHEN LOWER(TRIM(behavior.sub_func_level2_name)) IN ('ai-retouch', 'ai_retouch', 'airetouch') THEN 'ai retouch'
                        WHEN LOWER(TRIM(behavior.sub_func_level2_name)) IN ('ai-repair', 'ai_repair') THEN 'ai repair'
                        WHEN LOWER(TRIM(behavior.sub_func_level2_name)) IN ('ai-expand', 'ai_expand') THEN 'ai expand'
                        WHEN LOWER(TRIM(behavior.sub_func_level2_name)) IN ('ai-replace', 'ai_replace') THEN 'ai replace'
                        WHEN LOWER(TRIM(behavior.sub_func_level2_name)) IN ('facefix', 'face_fix') THEN 'face fix'
                        WHEN LOWER(TRIM(behavior.sub_func_level2_name)) IN ('skin_tone', 'skintone') THEN 'skin tone'
                        WHEN LOWER(TRIM(behavior.sub_func_level2_name)) = 'glow up' THEN 'glowup'
                        WHEN LOWER(TRIM(behavior.sub_func_level2_name)) IN ('aiimage', 'ai_image') THEN 'ai image'
                        WHEN LOWER(TRIM(behavior.sub_func_level2_name)) IN ('aitattoo', 'ai_tattoo') THEN 'ai tattoo'
                        ELSE LOWER(REGEXP_REPLACE(TRIM(behavior.sub_func_level2_name), '_', ' '))
                    END AS function_name,
                    SUM(CASE WHEN behavior.event_type = '进入' THEN behavior.cnt ELSE 0 END) AS enter_pv
                FROM stat_sdk.airbrush_mdz_tool_behavior_detail behavior
                WHERE behavior.date_p BETWEEN 20260701 AND 20260730
                  AND behavior.model_p = 'image_edit'
                  AND behavior.tool_level = '2'
                  AND behavior.event_type = '进入'
                  AND behavior.cnt > 0
                  AND behavior.gid IS NOT NULL
                  AND behavior.sub_func_level2_name IS NOT NULL
                  AND TRIM(behavior.sub_func_level2_name) <> ''
                GROUP BY
                    behavior.date_p,
                    behavior.gid,
                    CASE
                        WHEN LOWER(TRIM(behavior.sub_func_level2_name)) IN ('details', 'detail') THEN 'detail'
                        WHEN LOWER(TRIM(behavior.sub_func_level2_name)) IN ('ai-retouch', 'ai_retouch', 'airetouch') THEN 'ai retouch'
                        WHEN LOWER(TRIM(behavior.sub_func_level2_name)) IN ('ai-repair', 'ai_repair') THEN 'ai repair'
                        WHEN LOWER(TRIM(behavior.sub_func_level2_name)) IN ('ai-expand', 'ai_expand') THEN 'ai expand'
                        WHEN LOWER(TRIM(behavior.sub_func_level2_name)) IN ('ai-replace', 'ai_replace') THEN 'ai replace'
                        WHEN LOWER(TRIM(behavior.sub_func_level2_name)) IN ('facefix', 'face_fix') THEN 'face fix'
                        WHEN LOWER(TRIM(behavior.sub_func_level2_name)) IN ('skin_tone', 'skintone') THEN 'skin tone'
                        WHEN LOWER(TRIM(behavior.sub_func_level2_name)) = 'glow up' THEN 'glowup'
                        WHEN LOWER(TRIM(behavior.sub_func_level2_name)) IN ('aiimage', 'ai_image') THEN 'ai image'
                        WHEN LOWER(TRIM(behavior.sub_func_level2_name)) IN ('aitattoo', 'ai_tattoo') THEN 'ai tattoo'
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
    GROUP BY scene_user_day.date_p, scene_user_day.gid
) flags

