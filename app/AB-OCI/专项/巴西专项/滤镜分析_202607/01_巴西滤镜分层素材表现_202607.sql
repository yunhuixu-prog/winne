-- AirBrush OCI｜巴西滤镜专项｜素材漏斗、商业化及用户分层
-- 分析期：2026-07-01～2026-07-31
-- 建议引擎：Hive on Spark
--
-- 输出：
--   FILTER_EVENT：素材曝光/点击/打勾/保存/订阅成功/订阅转付费；
--   FILTER_FUNCTION：Filters二级功能进入/打勾/保存；
--   DAU：各完整分层的DAU分母。
--
-- 注意：
--   1. 整体由下载后对country分组重新汇总，不在SQL中用ROLLUP生成；
--   2. Android品牌/机型仅对巴西输出，且只保留打勾、保存事件的机型；
--   3. 素材收入沿用现有素材表归因，一笔订单含多素材时不能跨素材直接求和。

SELECT
    'FILTER_EVENT' AS record_type,
    CAST(event_base.date_p AS BIGINT) AS date_p,
    COALESCE(profile.country, event_base.country, '未知') AS country,
    COALESCE(profile.os_type, event_base.os_type, '未知') AS os_type,
    COALESCE(profile.is_new, event_base.is_new, 'Unknown') AS is_new,
    CASE
        WHEN COALESCE(profile.is_new, event_base.is_new) IN ('New', '新用户')
            THEN COALESCE(profile.is_ua, event_base.is_ua, 'Unknown')
        ELSE 'Not Applicable'
    END AS is_ua,
    CASE
        WHEN profile.first_launch_date IS NULL
            THEN 'Unknown'
        WHEN meitu_datediff(event_base.date_p, profile.first_launch_date) = 0
            THEN 'D0'
        WHEN meitu_datediff(event_base.date_p, profile.first_launch_date)
             BETWEEN 1 AND 3 THEN 'D1-3'
        WHEN meitu_datediff(event_base.date_p, profile.first_launch_date)
             BETWEEN 4 AND 7 THEN 'D4-7'
        WHEN meitu_datediff(event_base.date_p, profile.first_launch_date)
             BETWEEN 8 AND 30 THEN 'D8-30'
        WHEN meitu_datediff(event_base.date_p, profile.first_launch_date)
             BETWEEN 31 AND 90 THEN 'D31-90'
        WHEN meitu_datediff(event_base.date_p, profile.first_launch_date) > 90
            THEN 'D91+'
        ELSE 'Unknown'
    END AS install_age_bucket,
    CASE
        WHEN profile.is_subscribed = 1 THEN 'Paying'
        ELSE 'Un-Paying'
    END AS pay_status,
    CASE
        WHEN COALESCE(profile.country, event_base.country) = '巴西'
         AND LOWER(COALESCE(profile.os_type, event_base.os_type)) = 'android'
         AND event_base.event_type IN ('打勾', '保存')
            THEN COALESCE(active_extra.brand, 'Unknown')
        ELSE 'Not Applicable'
    END AS brand,
    CASE
        WHEN COALESCE(profile.country, event_base.country) = '巴西'
         AND LOWER(COALESCE(profile.os_type, event_base.os_type)) = 'android'
         AND event_base.event_type IN ('打勾', '保存')
            THEN COALESCE(active_extra.device_model, 'Unknown')
        ELSE 'Not Applicable'
    END AS device_model,
    event_base.material_id,
    event_base.material_name,
    event_base.category_id,
    event_base.category_name,
    event_base.event_type,
    CAST(COUNT(DISTINCT event_base.gid) AS BIGINT) AS event_uv,
    CAST(SUM(event_base.event_pv) AS BIGINT) AS event_pv,
    CAST(SUM(event_base.paid_ord_amt) AS DOUBLE) AS paid_ord_amt
FROM
(
    SELECT
        info.date_p,
        info.exp_uv AS gid,
        info.os_type,
        info.country,
        info.is_new,
        info.is_ua,
        info.material_id,
        info.material_name,
        info.category_id,
        info.category_name,
        '曝光' AS event_type,
        CAST(COALESCE(info.exp_pv, 0) AS BIGINT) AS event_pv,
        CAST(0 AS DOUBLE) AS paid_ord_amt
    FROM stat_material.material_adz_beidou_stat_info info
    WHERE info.date_p BETWEEN 20260701 AND 20260731
      AND LOWER(TRIM(info.feature)) = 'filters'
      AND info.exp_uv IS NOT NULL
      AND info.material_id IS NOT NULL
      AND info.material_id NOT IN ('-1', 'none', '整体')

    UNION ALL

    SELECT
        info.date_p,
        info.click_uv AS gid,
        info.os_type,
        info.country,
        info.is_new,
        info.is_ua,
        info.material_id,
        info.material_name,
        info.category_id,
        info.category_name,
        '点击' AS event_type,
        CAST(COALESCE(info.click_pv, 0) AS BIGINT) AS event_pv,
        CAST(0 AS DOUBLE) AS paid_ord_amt
    FROM stat_material.material_adz_beidou_stat_info info
    WHERE info.date_p BETWEEN 20260701 AND 20260731
      AND LOWER(TRIM(info.feature)) = 'filters'
      AND info.click_uv IS NOT NULL
      AND info.material_id IS NOT NULL
      AND info.material_id NOT IN ('-1', 'none', '整体')

    UNION ALL

    SELECT
        info.date_p,
        info.use_uv AS gid,
        info.os_type,
        info.country,
        info.is_new,
        info.is_ua,
        info.material_id,
        info.material_name,
        info.category_id,
        info.category_name,
        '打勾' AS event_type,
        CAST(COALESCE(info.use_pv, 0) AS BIGINT) AS event_pv,
        CAST(0 AS DOUBLE) AS paid_ord_amt
    FROM stat_material.material_adz_beidou_stat_info info
    WHERE info.date_p BETWEEN 20260701 AND 20260731
      AND LOWER(TRIM(info.feature)) = 'filters'
      AND info.use_uv IS NOT NULL
      AND info.material_id IS NOT NULL
      AND info.material_id NOT IN ('-1', 'none', '整体')

    UNION ALL

    SELECT
        info.date_p,
        info.save_uv AS gid,
        info.os_type,
        info.country,
        info.is_new,
        info.is_ua,
        info.material_id,
        info.material_name,
        info.category_id,
        info.category_name,
        '保存' AS event_type,
        CAST(COALESCE(info.save_pv, 0) AS BIGINT) AS event_pv,
        CAST(0 AS DOUBLE) AS paid_ord_amt
    FROM stat_material.material_adz_beidou_stat_info info
    WHERE info.date_p BETWEEN 20260701 AND 20260731
      AND LOWER(TRIM(info.feature)) = 'filters'
      AND info.save_uv IS NOT NULL
      AND info.material_id IS NOT NULL
      AND info.material_id NOT IN ('-1', 'none', '整体')

    UNION ALL

    SELECT
        info.date_p,
        info.sub_uv AS gid,
        info.os_type,
        info.country,
        info.is_new,
        info.is_ua,
        info.material_id,
        info.material_name,
        info.category_id,
        info.category_name,
        '订阅成功' AS event_type,
        CAST(COALESCE(info.sub_pv, 0) AS BIGINT) AS event_pv,
        CAST(0 AS DOUBLE) AS paid_ord_amt
    FROM stat_material.material_adz_beidou_stat_info info
    WHERE info.date_p BETWEEN 20260701 AND 20260731
      AND LOWER(TRIM(info.feature)) = 'filters'
      AND info.sub_uv IS NOT NULL
      AND info.material_id IS NOT NULL
      AND info.material_id NOT IN ('-1', 'none', '整体')

    UNION ALL

    SELECT
        info.date_p,
        info.sub_pay_uv AS gid,
        info.os_type,
        info.country,
        info.is_new,
        info.is_ua,
        info.material_id,
        info.material_name,
        info.category_id,
        info.category_name,
        '订阅转付费' AS event_type,
        CAST(1 AS BIGINT) AS event_pv,
        CAST(COALESCE(info.paid_ord_amt, 0) AS DOUBLE) AS paid_ord_amt
    FROM stat_material.material_adz_beidou_stat_info info
    WHERE info.date_p BETWEEN 20260701 AND 20260731
      AND LOWER(TRIM(info.feature)) = 'filters'
      AND info.sub_pay_uv IS NOT NULL
      AND COALESCE(info.paid_ord_amt, 0) > 0
      AND info.material_id IS NOT NULL
      AND info.material_id NOT IN ('-1', 'none', '整体')
) event_base
LEFT JOIN
(
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
    WHERE profile.date_p BETWEEN 20260701 AND 20260731
    GROUP BY profile.date_p, profile.gid
) profile
  ON event_base.date_p = profile.date_p
 AND event_base.gid = profile.gid
LEFT JOIN
(
    SELECT
        active.date_p,
        active.final_id AS gid,
        MAX(active.brand) AS brand,
        MAX(active.device_model) AS device_model
    FROM stat_sdk.sdk_odz_active active
    WHERE active.date_p BETWEEN 20260701 AND 20260731
      AND active.app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
      AND active.os_p IS NOT NULL
    GROUP BY active.date_p, active.final_id
) active_extra
  ON event_base.date_p = active_extra.date_p
 AND event_base.gid = active_extra.gid
WHERE event_base.gid IS NOT NULL
  AND event_base.gid <> ''
GROUP BY
    event_base.date_p,
    COALESCE(profile.country, event_base.country, '未知'),
    COALESCE(profile.os_type, event_base.os_type, '未知'),
    COALESCE(profile.is_new, event_base.is_new, 'Unknown'),
    CASE
        WHEN COALESCE(profile.is_new, event_base.is_new) IN ('New', '新用户')
            THEN COALESCE(profile.is_ua, event_base.is_ua, 'Unknown')
        ELSE 'Not Applicable'
    END,
    CASE
        WHEN profile.first_launch_date IS NULL THEN 'Unknown'
        WHEN meitu_datediff(event_base.date_p, profile.first_launch_date) = 0 THEN 'D0'
        WHEN meitu_datediff(event_base.date_p, profile.first_launch_date) BETWEEN 1 AND 3 THEN 'D1-3'
        WHEN meitu_datediff(event_base.date_p, profile.first_launch_date) BETWEEN 4 AND 7 THEN 'D4-7'
        WHEN meitu_datediff(event_base.date_p, profile.first_launch_date) BETWEEN 8 AND 30 THEN 'D8-30'
        WHEN meitu_datediff(event_base.date_p, profile.first_launch_date) BETWEEN 31 AND 90 THEN 'D31-90'
        WHEN meitu_datediff(event_base.date_p, profile.first_launch_date) > 90 THEN 'D91+'
        ELSE 'Unknown'
    END,
    CASE WHEN profile.is_subscribed = 1 THEN 'Paying' ELSE 'Un-Paying' END,
    CASE
        WHEN COALESCE(profile.country, event_base.country) = '巴西'
         AND LOWER(COALESCE(profile.os_type, event_base.os_type)) = 'android'
         AND event_base.event_type IN ('打勾', '保存')
            THEN COALESCE(active_extra.brand, 'Unknown')
        ELSE 'Not Applicable'
    END,
    CASE
        WHEN COALESCE(profile.country, event_base.country) = '巴西'
         AND LOWER(COALESCE(profile.os_type, event_base.os_type)) = 'android'
         AND event_base.event_type IN ('打勾', '保存')
            THEN COALESCE(active_extra.device_model, 'Unknown')
        ELSE 'Not Applicable'
    END,
    event_base.material_id,
    event_base.material_name,
    event_base.category_id,
    event_base.category_name,
    event_base.event_type

UNION ALL

SELECT
    'FILTER_FUNCTION' AS record_type,
    CAST(behavior.date_p AS BIGINT) AS date_p,
    COALESCE(profile.country, '未知') AS country,
    COALESCE(profile.os_type, '未知') AS os_type,
    COALESCE(profile.is_new, 'Unknown') AS is_new,
    CASE
        WHEN profile.is_new = 'New' THEN COALESCE(profile.is_ua, 'Unknown')
        ELSE 'Not Applicable'
    END AS is_ua,
    CASE
        WHEN profile.first_launch_date IS NULL THEN 'Unknown'
        WHEN meitu_datediff(behavior.date_p, profile.first_launch_date) = 0 THEN 'D0'
        WHEN meitu_datediff(behavior.date_p, profile.first_launch_date) BETWEEN 1 AND 3 THEN 'D1-3'
        WHEN meitu_datediff(behavior.date_p, profile.first_launch_date) BETWEEN 4 AND 7 THEN 'D4-7'
        WHEN meitu_datediff(behavior.date_p, profile.first_launch_date) BETWEEN 8 AND 30 THEN 'D8-30'
        WHEN meitu_datediff(behavior.date_p, profile.first_launch_date) BETWEEN 31 AND 90 THEN 'D31-90'
        WHEN meitu_datediff(behavior.date_p, profile.first_launch_date) > 90 THEN 'D91+'
        ELSE 'Unknown'
    END AS install_age_bucket,
    CASE WHEN profile.is_subscribed = 1 THEN 'Paying' ELSE 'Un-Paying' END AS pay_status,
    'Not Applicable' AS brand,
    'Not Applicable' AS device_model,
    'FUNCTION_ALL' AS material_id,
    'Filters' AS material_name,
    'FUNCTION_ALL' AS category_id,
    'Filters' AS category_name,
    CONCAT('功能', behavior.event_type) AS event_type,
    CAST(COUNT(DISTINCT behavior.gid) AS BIGINT) AS event_uv,
    CAST(SUM(behavior.cnt) AS BIGINT) AS event_pv,
    CAST(0 AS DOUBLE) AS paid_ord_amt
FROM
(
    SELECT
        tool.date_p,
        tool.gid,
        tool.event_type,
        tool.cnt
    FROM stat_sdk.airbrush_mdz_tool_behavior_detail tool
    WHERE tool.date_p BETWEEN 20260701 AND 20260731
      AND tool.model_p = 'image_edit'
      AND tool.tool_level = '2'
      AND LOWER(TRIM(tool.sub_func_level2_name)) IN ('filters', 'filter')
      AND tool.event_type IN ('进入', '打勾', '保存')
      AND tool.cnt > 0
      AND tool.gid IS NOT NULL
) behavior
LEFT JOIN
(
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
    WHERE profile.date_p BETWEEN 20260701 AND 20260731
    GROUP BY profile.date_p, profile.gid
) profile
  ON behavior.date_p = profile.date_p
 AND behavior.gid = profile.gid
GROUP BY
    behavior.date_p,
    COALESCE(profile.country, '未知'),
    COALESCE(profile.os_type, '未知'),
    COALESCE(profile.is_new, 'Unknown'),
    CASE WHEN profile.is_new = 'New' THEN COALESCE(profile.is_ua, 'Unknown') ELSE 'Not Applicable' END,
    CASE
        WHEN profile.first_launch_date IS NULL THEN 'Unknown'
        WHEN meitu_datediff(behavior.date_p, profile.first_launch_date) = 0 THEN 'D0'
        WHEN meitu_datediff(behavior.date_p, profile.first_launch_date) BETWEEN 1 AND 3 THEN 'D1-3'
        WHEN meitu_datediff(behavior.date_p, profile.first_launch_date) BETWEEN 4 AND 7 THEN 'D4-7'
        WHEN meitu_datediff(behavior.date_p, profile.first_launch_date) BETWEEN 8 AND 30 THEN 'D8-30'
        WHEN meitu_datediff(behavior.date_p, profile.first_launch_date) BETWEEN 31 AND 90 THEN 'D31-90'
        WHEN meitu_datediff(behavior.date_p, profile.first_launch_date) > 90 THEN 'D91+'
        ELSE 'Unknown'
    END,
    CASE WHEN profile.is_subscribed = 1 THEN 'Paying' ELSE 'Un-Paying' END,
    behavior.event_type

UNION ALL

SELECT
    'DAU' AS record_type,
    CAST(profile_base.date_p AS BIGINT) AS date_p,
    COALESCE(profile_base.country, '未知') AS country,
    COALESCE(profile_base.os_type, '未知') AS os_type,
    COALESCE(profile_base.is_new, 'Unknown') AS is_new,
    CASE
        WHEN profile_base.is_new = 'New' THEN COALESCE(profile_base.is_ua, 'Unknown')
        ELSE 'Not Applicable'
    END AS is_ua,
    CASE
        WHEN profile_base.first_launch_date IS NULL THEN 'Unknown'
        WHEN meitu_datediff(profile_base.date_p, profile_base.first_launch_date) = 0 THEN 'D0'
        WHEN meitu_datediff(profile_base.date_p, profile_base.first_launch_date) BETWEEN 1 AND 3 THEN 'D1-3'
        WHEN meitu_datediff(profile_base.date_p, profile_base.first_launch_date) BETWEEN 4 AND 7 THEN 'D4-7'
        WHEN meitu_datediff(profile_base.date_p, profile_base.first_launch_date) BETWEEN 8 AND 30 THEN 'D8-30'
        WHEN meitu_datediff(profile_base.date_p, profile_base.first_launch_date) BETWEEN 31 AND 90 THEN 'D31-90'
        WHEN meitu_datediff(profile_base.date_p, profile_base.first_launch_date) > 90 THEN 'D91+'
        ELSE 'Unknown'
    END AS install_age_bucket,
    CASE WHEN profile_base.is_subscribed = 1 THEN 'Paying' ELSE 'Un-Paying' END AS pay_status,
    CASE
        WHEN profile_base.country = '巴西'
         AND LOWER(profile_base.os_type) = 'android'
            THEN COALESCE(active_extra.brand, 'Unknown')
        ELSE 'Not Applicable'
    END AS brand,
    CASE
        WHEN profile_base.country = '巴西'
         AND LOWER(profile_base.os_type) = 'android'
            THEN COALESCE(active_extra.device_model, 'Unknown')
        ELSE 'Not Applicable'
    END AS device_model,
    'DAU' AS material_id,
    'DAU' AS material_name,
    'DAU' AS category_id,
    'DAU' AS category_name,
    'DAU' AS event_type,
    CAST(COUNT(DISTINCT profile_base.gid) AS BIGINT) AS event_uv,
    CAST(COUNT(DISTINCT profile_base.gid) AS BIGINT) AS event_pv,
    CAST(0 AS DOUBLE) AS paid_ord_amt
FROM
(
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
    WHERE profile.date_p BETWEEN 20260701 AND 20260731
    GROUP BY profile.date_p, profile.gid
) profile_base
LEFT JOIN
(
    SELECT
        active.date_p,
        active.final_id AS gid,
        MAX(active.brand) AS brand,
        MAX(active.device_model) AS device_model
    FROM stat_sdk.sdk_odz_active active
    WHERE active.date_p BETWEEN 20260701 AND 20260731
      AND active.app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
      AND active.os_p IS NOT NULL
    GROUP BY active.date_p, active.final_id
) active_extra
  ON profile_base.date_p = active_extra.date_p
 AND profile_base.gid = active_extra.gid
GROUP BY
    profile_base.date_p,
    COALESCE(profile_base.country, '未知'),
    COALESCE(profile_base.os_type, '未知'),
    COALESCE(profile_base.is_new, 'Unknown'),
    CASE WHEN profile_base.is_new = 'New' THEN COALESCE(profile_base.is_ua, 'Unknown') ELSE 'Not Applicable' END,
    CASE
        WHEN profile_base.first_launch_date IS NULL THEN 'Unknown'
        WHEN meitu_datediff(profile_base.date_p, profile_base.first_launch_date) = 0 THEN 'D0'
        WHEN meitu_datediff(profile_base.date_p, profile_base.first_launch_date) BETWEEN 1 AND 3 THEN 'D1-3'
        WHEN meitu_datediff(profile_base.date_p, profile_base.first_launch_date) BETWEEN 4 AND 7 THEN 'D4-7'
        WHEN meitu_datediff(profile_base.date_p, profile_base.first_launch_date) BETWEEN 8 AND 30 THEN 'D8-30'
        WHEN meitu_datediff(profile_base.date_p, profile_base.first_launch_date) BETWEEN 31 AND 90 THEN 'D31-90'
        WHEN meitu_datediff(profile_base.date_p, profile_base.first_launch_date) > 90 THEN 'D91+'
        ELSE 'Unknown'
    END,
    CASE WHEN profile_base.is_subscribed = 1 THEN 'Paying' ELSE 'Un-Paying' END,
    CASE
        WHEN profile_base.country = '巴西' AND LOWER(profile_base.os_type) = 'android'
            THEN COALESCE(active_extra.brand, 'Unknown')
        ELSE 'Not Applicable'
    END,
    CASE
        WHEN profile_base.country = '巴西' AND LOWER(profile_base.os_type) = 'android'
            THEN COALESCE(active_extra.device_model, 'Unknown')
        ELSE 'Not Applicable'
    END
;
