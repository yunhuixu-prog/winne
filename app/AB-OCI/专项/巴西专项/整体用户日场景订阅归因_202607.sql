-- AirBrush OCI｜整体用户日场景直接归因订阅链路
-- 分析期：2026-07-01 至 2026-07-30；粒度：同一用户同一天同一场景
-- Skin 取 fourth_source，AIGC 统一归入 AI Image，其余取 third_source。
-- 不使用 WITH CTE，以兼容神舟临时查询的导出包装。

SELECT
    sub_user_day.scene,
    SUM(sub_user_day.sub_enter_pv) AS sub_enter_pv,
    SUM(sub_user_day.sub_enter_uv) AS sub_enter_user_days,
    SUM(sub_user_day.sub_suc_uv) AS sub_suc_user_days,
    SUM(sub_user_day.sub_paid_uv) AS sub_paid_user_days,
    SUM(sub_user_day.sub_gross) AS sub_gross
FROM
(
    SELECT
        scene_source.date_p,
        scene_source.gid,
        scene_source.scene,
        SUM(CASE WHEN scene_source.event_id = 'sub_enter' THEN 1 ELSE 0 END) AS sub_enter_pv,
        MAX(CASE WHEN scene_source.event_id = 'sub_enter' THEN 1 ELSE 0 END) AS sub_enter_uv,
        MAX(CASE WHEN scene_source.event_id = 'sub_suc' THEN 1 ELSE 0 END) AS sub_suc_uv,
        MAX(
            CASE
                WHEN scene_source.event_id = 'sub_suc' AND scene_source.is_paid = 1 THEN 1
                ELSE 0
            END
        ) AS sub_paid_uv,
        SUM(
            CASE
                WHEN scene_source.event_id = 'sub_suc' AND scene_source.is_paid = 1
                    THEN COALESCE(scene_source.devide_paid_ord_amt, 0)
                ELSE 0
            END
        ) AS sub_gross
    FROM
    (
        SELECT
            source_normalized.date_p,
            source_normalized.gid,
            source_normalized.event_id,
            source_normalized.is_paid,
            source_normalized.devide_paid_ord_amt,
            CASE
                WHEN source_normalized.function_name IN ('reshape','face','body','muscle','stretch')
                    THEN '人像结构精修'
                WHEN source_normalized.function_name IN (
                    'skin','smooth','acne','skin tone','makeup','teeth','brighten',
                    'concealer','wrinkle','contour','matte','detail','details','blemish',
                    'eye brighten','dark circles','plump','clean skin','redness fix'
                ) THEN '自然轻修'
                WHEN source_normalized.function_name IN ('magic','ai retouch','glowup','preset','expression')
                    THEN 'AI一键出片'
                WHEN source_normalized.function_name IN (
                    'filters','filter','relight','bokeh','prism','glitter','effects',
                    'effect','adjust','crop','resize','blur','texture'
                ) THEN '氛围出片'
                WHEN source_normalized.function_name IN (
                    'eraser','ai replace','ai expand','background','ai repair',
                    'stamp','face fix','text','select area','background adjust'
                ) THEN '任务型工具编辑'
                WHEN source_normalized.function_name IN (
                    'hair','ai image','ai tattoo','hair dye','hair enrich','hairstyles',
                    'hairdye finetune','enrich','volume','mykit'
                ) THEN '玩法尝试'
                ELSE NULL
            END AS scene
        FROM
        (
            SELECT
                sub.date_p,
                sub.gid,
                sub.event_id,
                sub.is_paid,
                sub.devide_paid_ord_amt,
                CASE
                    WHEN sub.third_source = 'Skin'
                        THEN LOWER(REGEXP_REPLACE(TRIM(sub.fourth_source), '_', ' '))
                    WHEN sub.first_source = 'AIGC'
                        THEN 'ai image'
                    ELSE LOWER(REGEXP_REPLACE(TRIM(sub.third_source), '_', ' '))
                END AS function_name
            FROM stat_ab.filing_onz_sub_source_event_detail_level sub
            WHERE sub.date_p BETWEEN 20260701 AND 20260730
              AND sub.event_id IN ('sub_enter', 'sub_suc')
              AND sub.gid IS NOT NULL
        ) source_normalized
    ) scene_source
    INNER JOIN
    (
        SELECT profile.date_p, profile.gid
        FROM stat_ab.filing_odz_active_user_profile profile
        WHERE profile.date_p BETWEEN 20260701 AND 20260730
          AND profile.gid IS NOT NULL
        GROUP BY profile.date_p, profile.gid
    ) profile_scope
      ON scene_source.date_p = profile_scope.date_p
     AND scene_source.gid = profile_scope.gid
    WHERE scene_source.scene IS NOT NULL
    GROUP BY scene_source.date_p, scene_source.gid, scene_source.scene
) sub_user_day
GROUP BY sub_user_day.scene

