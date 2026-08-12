-- AirBrush OCI｜巴西 vs 整体用户日场景对比汇总
-- 引擎：Hive on Spark
-- 分析期：2026-07-01 至 2026-07-30（与《巴西用户日场景分析》一致）
-- 粒度：同一用户同一天；整体包含巴西
--
-- 输出 record_type：
--   SCENE_METRIC       场景核心指标及分层指标
--   SCENE_COUNT        每日使用场景数分布
--   SCENE_PAIR         两两场景共用、Jaccard、Lift
--   SCENE_COMBO        多场景组合
--   FUNCTION_METRIC    场景内功能表现
--   SCENE_SUBSCRIPTION 场景直接归因订阅链路
--
-- 场景映射与 analyze_brazil_daily_scenes.py 保持一致；
-- 玩法尝试中的部分 Hair 子功能打勾/保存回传不完整，相关漏斗仅供方向判断。

WITH profile_base AS (
    SELECT
        profile.date_p,
        profile.gid,
        MAX(profile.country) AS country,
        MAX(profile.os_type) AS os_type,
        MAX(profile.is_new) AS is_new,
        MAX(profile.is_ua) AS is_ua,
        MAX(profile.is_subscribed) AS is_subscribed,
        MIN(profile.first_launch_date) AS first_launch_date
    FROM stat_ab.filing_odz_active_user_profile profile
    WHERE profile.date_p BETWEEN 20260701 AND 20260730
      AND profile.gid IS NOT NULL
    GROUP BY profile.date_p, profile.gid
),

profile_retention AS (
    SELECT
        p.date_p,
        p.gid,
        p.country,
        p.os_type,
        p.is_new,
        p.is_ua,
        p.is_subscribed,
        p.first_launch_date,
        CASE WHEN d1.gid IS NOT NULL THEN 1 ELSE 0 END AS d1_active,
        CASE WHEN d7.gid IS NOT NULL THEN 1 ELSE 0 END AS d7_active,
        CASE WHEN p.date_p <= 20260729 THEN 1 ELSE 0 END AS d1_mature,
        CASE WHEN p.date_p <= 20260723 THEN 1 ELSE 0 END AS d7_mature,
        CASE
            WHEN p.first_launch_date IS NULL
              OR meitu_datediff(p.date_p, p.first_launch_date) < 0
                THEN 'Unknown'
            WHEN meitu_datediff(p.date_p, p.first_launch_date) = 0
                THEN 'D0'
            WHEN meitu_datediff(p.date_p, p.first_launch_date) BETWEEN 1 AND 3
                THEN 'D1-3'
            WHEN meitu_datediff(p.date_p, p.first_launch_date) BETWEEN 4 AND 7
                THEN 'D4-7'
            WHEN meitu_datediff(p.date_p, p.first_launch_date) BETWEEN 8 AND 30
                THEN 'D8-30'
            WHEN meitu_datediff(p.date_p, p.first_launch_date) BETWEEN 31 AND 90
                THEN 'D31-90'
            ELSE 'D91+'
        END AS install_age_bucket
    FROM profile_base p
    LEFT JOIN profile_base d1
      ON p.gid = d1.gid
     AND meitu_datediff(d1.date_p, p.date_p) = 1
    LEFT JOIN profile_base d7
      ON p.gid = d7.gid
     AND meitu_datediff(d7.date_p, p.date_p) = 7
),

profile_market AS (
    SELECT
        '整体' AS market,
        p.date_p,
        p.gid,
        p.country,
        p.os_type,
        p.is_new,
        p.is_ua,
        p.is_subscribed,
        p.install_age_bucket,
        p.d1_active,
        p.d7_active,
        p.d1_mature,
        p.d7_mature
    FROM profile_retention p

    UNION ALL

    SELECT
        '巴西' AS market,
        p.date_p,
        p.gid,
        p.country,
        p.os_type,
        p.is_new,
        p.is_ua,
        p.is_subscribed,
        p.install_age_bucket,
        p.d1_active,
        p.d7_active,
        p.d1_mature,
        p.d7_mature
    FROM profile_retention p
    WHERE p.country = '巴西'
),

profile_segment_raw AS (
    SELECT
        p.market,
        p.date_p,
        p.gid,
        p.d1_active,
        p.d7_active,
        p.d1_mature,
        p.d7_mature,
        segment_dimension,
        segment_value
    FROM profile_market p
    LATERAL VIEW STACK(
        6,
        '整体', '整体',
        '平台', COALESCE(p.os_type, '未知'),
        '新老', COALESCE(p.is_new, '未知'),
        '新用户来源', CASE
            WHEN p.is_new = 'New' AND LOWER(COALESCE(p.is_ua, '')) = 'organic'
                THEN '自然新用户'
            WHEN p.is_new = 'New' AND LOWER(COALESCE(p.is_ua, '')) IN ('non-organic', 'non organic')
                THEN '渠道新用户'
            ELSE NULL
        END,
        '安装龄', COALESCE(p.install_age_bucket, 'Unknown'),
        '付费状态', CASE WHEN p.is_subscribed = 1 THEN 'Paying' ELSE 'Un-Paying' END
    ) seg AS segment_dimension, segment_value
),

profile_segment AS (
    SELECT *
    FROM profile_segment_raw
    WHERE segment_value IS NOT NULL
),

dau_segment AS (
    SELECT
        market,
        segment_dimension,
        segment_value,
        COUNT(1) AS dau_user_days
    FROM profile_segment
    GROUP BY market, segment_dimension, segment_value
),

function_base AS (
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
),

function_scene AS (
    SELECT
        f.*,
        CASE
            WHEN f.function_name IN ('reshape','face','body','muscle','stretch')
                THEN '人像结构精修'
            WHEN f.function_name IN (
                'skin','smooth','acne','skin tone','makeup','teeth','brighten',
                'concealer','wrinkle','contour','matte','detail','blemish',
                'eye brighten','dark circles','plump','clean skin','redness fix'
            ) THEN '自然轻修'
            WHEN f.function_name IN ('magic','ai retouch','glowup','preset','expression')
                THEN 'AI一键出片'
            WHEN f.function_name IN (
                'filters','filter','relight','bokeh','prism','glitter','effects',
                'effect','adjust','crop','resize','blur','texture'
            ) THEN '氛围出片'
            WHEN f.function_name IN (
                'eraser','ai replace','ai expand','background','ai repair',
                'stamp','face fix','text','select area','background adjust'
            ) THEN '任务型工具编辑'
            WHEN f.function_name IN (
                'hair','ai image','ai tattoo','hair dye','hair enrich','hairstyles',
                'hairdye finetune','enrich','volume','mykit'
            ) THEN '玩法尝试'
            ELSE NULL
        END AS scene
    FROM function_base f
),

scene_user_day AS (
    SELECT
        p.market,
        p.date_p,
        p.gid,
        f.scene,
        SUM(f.enter_pv) AS enter_pv,
        SUM(f.check_pv) AS check_pv,
        SUM(f.save_pv) AS save_pv,
        COUNT(1) AS function_count
    FROM profile_market p
    INNER JOIN function_scene f
      ON p.date_p = f.date_p
     AND p.gid = f.gid
    WHERE f.scene IS NOT NULL
      AND f.enter_pv > 0
    GROUP BY p.market, p.date_p, p.gid, f.scene
),

scene_segment_metric AS (
    SELECT
        s.market,
        p.segment_dimension,
        p.segment_value,
        s.scene,
        COUNT(1) AS scene_user_days,
        SUM(s.enter_pv) AS enter_pv,
        SUM(CASE WHEN s.check_pv > 0 THEN 1 ELSE 0 END) AS check_user_days,
        SUM(CASE WHEN s.save_pv > 0 THEN 1 ELSE 0 END) AS save_user_days,
        SUM(s.function_count) AS function_count_sum,
        SUM(p.d1_mature) AS d1_sample_user_days,
        SUM(p.d1_active * p.d1_mature) AS d1_retained_user_days,
        SUM(p.d7_mature) AS d7_sample_user_days,
        SUM(p.d7_active * p.d7_mature) AS d7_retained_user_days
    FROM scene_user_day s
    INNER JOIN profile_segment p
      ON s.market = p.market
     AND s.date_p = p.date_p
     AND s.gid = p.gid
    GROUP BY s.market, p.segment_dimension, p.segment_value, s.scene
),

scene_metric AS (
    SELECT
        s.market,
        s.segment_dimension,
        s.segment_value,
        s.scene,
        d.dau_user_days,
        s.scene_user_days,
        s.scene_user_days / d.dau_user_days AS scene_penetration,
        s.enter_pv,
        s.enter_pv / s.scene_user_days AS enter_frequency,
        s.check_user_days,
        s.check_user_days / s.scene_user_days AS enter_check_rate,
        s.save_user_days,
        s.save_user_days / s.scene_user_days AS enter_save_rate,
        s.save_user_days / s.check_user_days AS check_save_rate,
        s.function_count_sum / s.scene_user_days AS avg_function_count,
        s.d1_sample_user_days,
        s.d1_retained_user_days,
        s.d1_retained_user_days / s.d1_sample_user_days AS d1_retention_rate,
        s.d7_sample_user_days,
        s.d7_retained_user_days,
        s.d7_retained_user_days / s.d7_sample_user_days AS d7_retention_rate
    FROM scene_segment_metric s
    INNER JOIN dau_segment d
      ON s.market = d.market
     AND s.segment_dimension = d.segment_dimension
     AND s.segment_value = d.segment_value
),

user_day_flags AS (
    SELECT
        market,
        date_p,
        gid,
        MAX(CASE WHEN scene = '人像结构精修' THEN 1 ELSE 0 END) AS portrait_flag,
        MAX(CASE WHEN scene = '自然轻修' THEN 1 ELSE 0 END) AS natural_flag,
        MAX(CASE WHEN scene = 'AI一键出片' THEN 1 ELSE 0 END) AS ai_flag,
        MAX(CASE WHEN scene = '氛围出片' THEN 1 ELSE 0 END) AS atmosphere_flag,
        MAX(CASE WHEN scene = '任务型工具编辑' THEN 1 ELSE 0 END) AS task_flag,
        MAX(CASE WHEN scene = '玩法尝试' THEN 1 ELSE 0 END) AS play_flag
    FROM scene_user_day
    GROUP BY market, date_p, gid
),

user_day_scene_count AS (
    SELECT
        market,
        date_p,
        gid,
        portrait_flag,
        natural_flag,
        ai_flag,
        atmosphere_flag,
        task_flag,
        play_flag,
        portrait_flag + natural_flag + ai_flag + atmosphere_flag + task_flag + play_flag
            AS scene_count,
        CONCAT_WS(
            ' + ',
            CASE WHEN portrait_flag = 1 THEN '人像结构精修' END,
            CASE WHEN natural_flag = 1 THEN '自然轻修' END,
            CASE WHEN ai_flag = 1 THEN 'AI一键出片' END,
            CASE WHEN atmosphere_flag = 1 THEN '氛围出片' END,
            CASE WHEN task_flag = 1 THEN '任务型工具编辑' END,
            CASE WHEN play_flag = 1 THEN '玩法尝试' END
        ) AS scene_combo
    FROM user_day_flags
),

scene_count_metric AS (
    SELECT
        c.market,
        c.scene_count,
        COUNT(1) AS user_days,
        MAX(d.dau_user_days) AS dau_user_days,
        COUNT(1) / MAX(d.dau_user_days) AS share_of_dau
    FROM user_day_scene_count c
    INNER JOIN dau_segment d
      ON c.market = d.market
     AND d.segment_dimension = '整体'
     AND d.segment_value = '整体'
    GROUP BY c.market, c.scene_count
),

scene_combo_metric AS (
    SELECT
        c.market,
        c.scene_combo,
        c.scene_count,
        COUNT(1) AS user_days,
        MAX(d.dau_user_days) AS dau_user_days,
        COUNT(1) / MAX(d.dau_user_days) AS share_of_dau
    FROM user_day_scene_count c
    INNER JOIN dau_segment d
      ON c.market = d.market
     AND d.segment_dimension = '整体'
     AND d.segment_value = '整体'
    GROUP BY c.market, c.scene_combo, c.scene_count
),

pair_long AS (
    SELECT
        c.market,
        c.date_p,
        c.gid,
        scene_1,
        scene_2,
        scene_1_flag,
        scene_2_flag,
        pair_flag
    FROM user_day_scene_count c
    LATERAL VIEW STACK(
        15,
        '人像结构精修','自然轻修',portrait_flag,natural_flag,portrait_flag*natural_flag,
        '人像结构精修','AI一键出片',portrait_flag,ai_flag,portrait_flag*ai_flag,
        '人像结构精修','氛围出片',portrait_flag,atmosphere_flag,portrait_flag*atmosphere_flag,
        '人像结构精修','任务型工具编辑',portrait_flag,task_flag,portrait_flag*task_flag,
        '人像结构精修','玩法尝试',portrait_flag,play_flag,portrait_flag*play_flag,
        '自然轻修','AI一键出片',natural_flag,ai_flag,natural_flag*ai_flag,
        '自然轻修','氛围出片',natural_flag,atmosphere_flag,natural_flag*atmosphere_flag,
        '自然轻修','任务型工具编辑',natural_flag,task_flag,natural_flag*task_flag,
        '自然轻修','玩法尝试',natural_flag,play_flag,natural_flag*play_flag,
        'AI一键出片','氛围出片',ai_flag,atmosphere_flag,ai_flag*atmosphere_flag,
        'AI一键出片','任务型工具编辑',ai_flag,task_flag,ai_flag*task_flag,
        'AI一键出片','玩法尝试',ai_flag,play_flag,ai_flag*play_flag,
        '氛围出片','任务型工具编辑',atmosphere_flag,task_flag,atmosphere_flag*task_flag,
        '氛围出片','玩法尝试',atmosphere_flag,play_flag,atmosphere_flag*play_flag,
        '任务型工具编辑','玩法尝试',task_flag,play_flag,task_flag*play_flag
    ) pairs AS scene_1, scene_2, scene_1_flag, scene_2_flag, pair_flag
),

pair_metric AS (
    SELECT
        p.market,
        p.scene_1,
        p.scene_2,
        SUM(p.scene_1_flag) AS scene_1_user_days,
        SUM(p.scene_2_flag) AS scene_2_user_days,
        SUM(p.pair_flag) AS pair_user_days,
        SUM(p.pair_flag) / SUM(p.scene_1_flag) AS scene_1_to_2_rate,
        SUM(p.pair_flag) /
            (SUM(p.scene_1_flag) + SUM(p.scene_2_flag) - SUM(p.pair_flag)) AS jaccard,
        (SUM(p.pair_flag) / SUM(p.scene_1_flag)) /
            (SUM(p.scene_2_flag) / MAX(d.dau_user_days)) AS lift
    FROM pair_long p
    INNER JOIN dau_segment d
      ON p.market = d.market
     AND d.segment_dimension = '整体'
     AND d.segment_value = '整体'
    GROUP BY p.market, p.scene_1, p.scene_2
),

function_metric AS (
    SELECT
        p.market,
        f.scene,
        f.function_name,
        COUNT(1) AS enter_user_days,
        SUM(f.enter_pv) AS enter_pv,
        SUM(CASE WHEN f.check_pv > 0 THEN 1 ELSE 0 END) AS check_user_days,
        SUM(CASE WHEN f.save_pv > 0 THEN 1 ELSE 0 END) AS save_user_days,
        SUM(CASE WHEN f.check_pv > 0 THEN 1 ELSE 0 END) / COUNT(1) AS enter_check_rate,
        SUM(CASE WHEN f.save_pv > 0 THEN 1 ELSE 0 END) / COUNT(1) AS enter_save_rate
    FROM profile_market p
    INNER JOIN function_scene f
      ON p.date_p = f.date_p
     AND p.gid = f.gid
    WHERE f.scene IS NOT NULL
      AND f.enter_pv > 0
    GROUP BY p.market, f.scene, f.function_name
),

sub_source_function AS (
    SELECT
        sub.date_p,
        sub.gid,
        sub.event_id,
        sub.is_paid,
        sub.devide_paid_ord_amt,
        CASE
            WHEN sub.third_source = 'Skin' THEN LOWER(TRIM(sub.fourth_source))
            WHEN sub.first_source = 'AIGC' THEN 'ai image'
            ELSE LOWER(TRIM(sub.third_source))
        END AS function_name
    FROM stat_ab.filing_onz_sub_source_event_detail_level sub
    WHERE sub.date_p BETWEEN 20260701 AND 20260730
      AND sub.event_id IN ('sub_enter', 'sub_suc')
      AND sub.gid IS NOT NULL
),

sub_source_scene AS (
    SELECT
        s.*,
        CASE
            WHEN s.function_name IN ('reshape','face','body','muscle','stretch')
                THEN '人像结构精修'
            WHEN s.function_name IN (
                'skin','smooth','acne','skin tone','makeup','teeth','brighten',
                'concealer','wrinkle','contour','matte','detail','details','blemish',
                'eye brighten','dark circles','plump','clean skin','redness fix'
            ) THEN '自然轻修'
            WHEN s.function_name IN ('magic','ai retouch','glowup','preset','expression')
                THEN 'AI一键出片'
            WHEN s.function_name IN (
                'filters','filter','relight','bokeh','prism','glitter','effects',
                'effect','adjust','crop','resize','blur','texture'
            ) THEN '氛围出片'
            WHEN s.function_name IN (
                'eraser','ai replace','ai expand','background','ai repair',
                'stamp','face fix','text','select area','background adjust'
            ) THEN '任务型工具编辑'
            WHEN s.function_name IN (
                'hair','ai image','ai tattoo','hair dye','hair enrich','hairstyles',
                'hairdye finetune','enrich','volume','mykit'
            ) THEN '玩法尝试'
            ELSE NULL
        END AS scene
    FROM sub_source_function s
),

sub_user_day_scene AS (
    SELECT
        p.market,
        s.date_p,
        s.gid,
        s.scene,
        SUM(CASE WHEN s.event_id = 'sub_enter' THEN 1 ELSE 0 END) AS sub_enter_pv,
        MAX(CASE WHEN s.event_id = 'sub_enter' THEN 1 ELSE 0 END) AS sub_enter_uv,
        MAX(CASE WHEN s.event_id = 'sub_suc' THEN 1 ELSE 0 END) AS sub_suc_uv,
        MAX(CASE WHEN s.event_id = 'sub_suc' AND s.is_paid = 1 THEN 1 ELSE 0 END) AS sub_paid_uv,
        SUM(CASE
            WHEN s.event_id = 'sub_suc' AND s.is_paid = 1
                THEN COALESCE(s.devide_paid_ord_amt, 0)
            ELSE 0
        END) AS sub_gross
    FROM profile_market p
    INNER JOIN sub_source_scene s
      ON p.date_p = s.date_p
     AND p.gid = s.gid
    WHERE s.scene IS NOT NULL
    GROUP BY p.market, s.date_p, s.gid, s.scene
),

sub_scene_metric AS (
    SELECT
        market,
        scene,
        SUM(sub_enter_pv) AS sub_enter_pv,
        SUM(sub_enter_uv) AS sub_enter_user_days,
        SUM(sub_suc_uv) AS sub_suc_user_days,
        SUM(sub_paid_uv) AS sub_paid_user_days,
        SUM(sub_gross) AS sub_gross
    FROM sub_user_day_scene
    GROUP BY market, scene
)

SELECT
    'SCENE_METRIC' AS record_type,
    s.market,
    s.segment_dimension AS dimension,
    s.segment_value AS segment,
    s.scene,
    CAST(NULL AS STRING) AS scene_2,
    CAST(NULL AS STRING) AS item,
    s.dau_user_days,
    s.scene_user_days,
    s.scene_penetration,
    s.enter_pv,
    s.enter_frequency,
    s.check_user_days,
    s.enter_check_rate,
    s.save_user_days,
    s.enter_save_rate,
    s.check_save_rate,
    s.avg_function_count,
    s.d1_sample_user_days,
    s.d1_retained_user_days,
    s.d1_retention_rate,
    s.d7_sample_user_days,
    s.d7_retained_user_days,
    s.d7_retention_rate,
    CAST(NULL AS BIGINT) AS pair_user_days,
    CAST(NULL AS DOUBLE) AS conditional_rate,
    CAST(NULL AS DOUBLE) AS jaccard,
    CAST(NULL AS DOUBLE) AS lift,
    CAST(NULL AS BIGINT) AS sub_enter_pv,
    CAST(NULL AS BIGINT) AS sub_enter_user_days,
    CAST(NULL AS BIGINT) AS sub_suc_user_days,
    CAST(NULL AS BIGINT) AS sub_paid_user_days,
    CAST(NULL AS DOUBLE) AS sub_gross
FROM scene_metric s

UNION ALL

SELECT
    'SCENE_COUNT' AS record_type,
    c.market,
    '整体' AS dimension,
    '整体' AS segment,
    CAST(NULL AS STRING) AS scene,
    CAST(NULL AS STRING) AS scene_2,
    CAST(c.scene_count AS STRING) AS item,
    c.dau_user_days,
    c.user_days AS scene_user_days,
    c.share_of_dau AS scene_penetration,
    CAST(NULL AS BIGINT) AS enter_pv,
    CAST(NULL AS DOUBLE) AS enter_frequency,
    CAST(NULL AS BIGINT) AS check_user_days,
    CAST(NULL AS DOUBLE) AS enter_check_rate,
    CAST(NULL AS BIGINT) AS save_user_days,
    CAST(NULL AS DOUBLE) AS enter_save_rate,
    CAST(NULL AS DOUBLE) AS check_save_rate,
    CAST(NULL AS DOUBLE) AS avg_function_count,
    CAST(NULL AS BIGINT) AS d1_sample_user_days,
    CAST(NULL AS BIGINT) AS d1_retained_user_days,
    CAST(NULL AS DOUBLE) AS d1_retention_rate,
    CAST(NULL AS BIGINT) AS d7_sample_user_days,
    CAST(NULL AS BIGINT) AS d7_retained_user_days,
    CAST(NULL AS DOUBLE) AS d7_retention_rate,
    CAST(NULL AS BIGINT) AS pair_user_days,
    CAST(NULL AS DOUBLE) AS conditional_rate,
    CAST(NULL AS DOUBLE) AS jaccard,
    CAST(NULL AS DOUBLE) AS lift,
    CAST(NULL AS BIGINT) AS sub_enter_pv,
    CAST(NULL AS BIGINT) AS sub_enter_user_days,
    CAST(NULL AS BIGINT) AS sub_suc_user_days,
    CAST(NULL AS BIGINT) AS sub_paid_user_days,
    CAST(NULL AS DOUBLE) AS sub_gross
FROM scene_count_metric c

UNION ALL

SELECT
    'SCENE_PAIR' AS record_type,
    p.market,
    '整体' AS dimension,
    '整体' AS segment,
    p.scene_1 AS scene,
    p.scene_2,
    CAST(NULL AS STRING) AS item,
    CAST(NULL AS BIGINT) AS dau_user_days,
    p.scene_1_user_days AS scene_user_days,
    CAST(NULL AS DOUBLE) AS scene_penetration,
    CAST(NULL AS BIGINT) AS enter_pv,
    CAST(NULL AS DOUBLE) AS enter_frequency,
    p.scene_2_user_days AS check_user_days,
    CAST(NULL AS DOUBLE) AS enter_check_rate,
    CAST(NULL AS BIGINT) AS save_user_days,
    CAST(NULL AS DOUBLE) AS enter_save_rate,
    CAST(NULL AS DOUBLE) AS check_save_rate,
    CAST(NULL AS DOUBLE) AS avg_function_count,
    CAST(NULL AS BIGINT) AS d1_sample_user_days,
    CAST(NULL AS BIGINT) AS d1_retained_user_days,
    CAST(NULL AS DOUBLE) AS d1_retention_rate,
    CAST(NULL AS BIGINT) AS d7_sample_user_days,
    CAST(NULL AS BIGINT) AS d7_retained_user_days,
    CAST(NULL AS DOUBLE) AS d7_retention_rate,
    p.pair_user_days,
    p.scene_1_to_2_rate AS conditional_rate,
    p.jaccard,
    p.lift,
    CAST(NULL AS BIGINT) AS sub_enter_pv,
    CAST(NULL AS BIGINT) AS sub_enter_user_days,
    CAST(NULL AS BIGINT) AS sub_suc_user_days,
    CAST(NULL AS BIGINT) AS sub_paid_user_days,
    CAST(NULL AS DOUBLE) AS sub_gross
FROM pair_metric p

UNION ALL

SELECT
    'SCENE_COMBO' AS record_type,
    c.market,
    '整体' AS dimension,
    '整体' AS segment,
    CAST(NULL AS STRING) AS scene,
    CAST(NULL AS STRING) AS scene_2,
    c.scene_combo AS item,
    c.dau_user_days,
    c.user_days AS scene_user_days,
    c.share_of_dau AS scene_penetration,
    CAST(NULL AS BIGINT) AS enter_pv,
    CAST(c.scene_count AS DOUBLE) AS enter_frequency,
    CAST(NULL AS BIGINT) AS check_user_days,
    CAST(NULL AS DOUBLE) AS enter_check_rate,
    CAST(NULL AS BIGINT) AS save_user_days,
    CAST(NULL AS DOUBLE) AS enter_save_rate,
    CAST(NULL AS DOUBLE) AS check_save_rate,
    CAST(NULL AS DOUBLE) AS avg_function_count,
    CAST(NULL AS BIGINT) AS d1_sample_user_days,
    CAST(NULL AS BIGINT) AS d1_retained_user_days,
    CAST(NULL AS DOUBLE) AS d1_retention_rate,
    CAST(NULL AS BIGINT) AS d7_sample_user_days,
    CAST(NULL AS BIGINT) AS d7_retained_user_days,
    CAST(NULL AS DOUBLE) AS d7_retention_rate,
    CAST(NULL AS BIGINT) AS pair_user_days,
    CAST(NULL AS DOUBLE) AS conditional_rate,
    CAST(NULL AS DOUBLE) AS jaccard,
    CAST(NULL AS DOUBLE) AS lift,
    CAST(NULL AS BIGINT) AS sub_enter_pv,
    CAST(NULL AS BIGINT) AS sub_enter_user_days,
    CAST(NULL AS BIGINT) AS sub_suc_user_days,
    CAST(NULL AS BIGINT) AS sub_paid_user_days,
    CAST(NULL AS DOUBLE) AS sub_gross
FROM scene_combo_metric c

UNION ALL

SELECT
    'FUNCTION_METRIC' AS record_type,
    f.market,
    '整体' AS dimension,
    '整体' AS segment,
    f.scene,
    CAST(NULL AS STRING) AS scene_2,
    f.function_name AS item,
    CAST(NULL AS BIGINT) AS dau_user_days,
    f.enter_user_days AS scene_user_days,
    CAST(NULL AS DOUBLE) AS scene_penetration,
    f.enter_pv,
    CAST(NULL AS DOUBLE) AS enter_frequency,
    f.check_user_days,
    f.enter_check_rate,
    f.save_user_days,
    f.enter_save_rate,
    f.save_user_days / f.check_user_days AS check_save_rate,
    CAST(NULL AS DOUBLE) AS avg_function_count,
    CAST(NULL AS BIGINT) AS d1_sample_user_days,
    CAST(NULL AS BIGINT) AS d1_retained_user_days,
    CAST(NULL AS DOUBLE) AS d1_retention_rate,
    CAST(NULL AS BIGINT) AS d7_sample_user_days,
    CAST(NULL AS BIGINT) AS d7_retained_user_days,
    CAST(NULL AS DOUBLE) AS d7_retention_rate,
    CAST(NULL AS BIGINT) AS pair_user_days,
    CAST(NULL AS DOUBLE) AS conditional_rate,
    CAST(NULL AS DOUBLE) AS jaccard,
    CAST(NULL AS DOUBLE) AS lift,
    CAST(NULL AS BIGINT) AS sub_enter_pv,
    CAST(NULL AS BIGINT) AS sub_enter_user_days,
    CAST(NULL AS BIGINT) AS sub_suc_user_days,
    CAST(NULL AS BIGINT) AS sub_paid_user_days,
    CAST(NULL AS DOUBLE) AS sub_gross
FROM function_metric f

UNION ALL

SELECT
    'SCENE_SUBSCRIPTION' AS record_type,
    s.market,
    '整体' AS dimension,
    '整体' AS segment,
    s.scene,
    CAST(NULL AS STRING) AS scene_2,
    CAST(NULL AS STRING) AS item,
    CAST(NULL AS BIGINT) AS dau_user_days,
    CAST(NULL AS BIGINT) AS scene_user_days,
    CAST(NULL AS DOUBLE) AS scene_penetration,
    CAST(NULL AS BIGINT) AS enter_pv,
    CAST(NULL AS DOUBLE) AS enter_frequency,
    CAST(NULL AS BIGINT) AS check_user_days,
    CAST(NULL AS DOUBLE) AS enter_check_rate,
    CAST(NULL AS BIGINT) AS save_user_days,
    CAST(NULL AS DOUBLE) AS enter_save_rate,
    CAST(NULL AS DOUBLE) AS check_save_rate,
    CAST(NULL AS DOUBLE) AS avg_function_count,
    CAST(NULL AS BIGINT) AS d1_sample_user_days,
    CAST(NULL AS BIGINT) AS d1_retained_user_days,
    CAST(NULL AS DOUBLE) AS d1_retention_rate,
    CAST(NULL AS BIGINT) AS d7_sample_user_days,
    CAST(NULL AS BIGINT) AS d7_retained_user_days,
    CAST(NULL AS DOUBLE) AS d7_retention_rate,
    CAST(NULL AS BIGINT) AS pair_user_days,
    CAST(NULL AS DOUBLE) AS conditional_rate,
    CAST(NULL AS DOUBLE) AS jaccard,
    CAST(NULL AS DOUBLE) AS lift,
    s.sub_enter_pv,
    s.sub_enter_user_days,
    s.sub_suc_user_days,
    s.sub_paid_user_days,
    s.sub_gross
FROM sub_scene_metric s
;
