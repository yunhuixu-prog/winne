-- AirBrush OCI｜巴西滤镜专项｜每次打勾滑杆值分布
-- 分析期：2026-07-01～2026-07-31
-- 建议引擎：Hive on Spark
--
-- 观察粒度：每条 Filters material_check 事件。
-- 不按编辑会话去重、不限制每个 trace_info 的最后一次打勾。
-- filters_value为打勾时的最终滑杆值；缺失不等于未调整，因为部分素材没有滑杆。
-- default_value_source仅标识默认值来源：server_default / user_memory；
-- 它不能单独证明用户是否在本次编辑中手动改动了滑杆。

SELECT
    CASE WHEN LOWER(COALESCE(profile.country, '')) IN ('巴西', 'brazil')
         THEN 'Brazil' ELSE 'Other' END AS country_group,
    COALESCE(profile.os_type, check_event.os_type, '未知') AS os_type,
    COALESCE(profile.is_new, 'Unknown') AS is_new,
    CASE
        WHEN profile.is_new = 'New' THEN COALESCE(profile.is_ua, 'Unknown')
        ELSE 'Not Applicable'
    END AS is_ua,
    CASE
        WHEN profile.first_launch_date IS NULL THEN 'Unknown'
        WHEN meitu_datediff(check_event.date_p, profile.first_launch_date) = 0 THEN 'D0'
        WHEN meitu_datediff(check_event.date_p, profile.first_launch_date) BETWEEN 1 AND 3 THEN 'D1-3'
        WHEN meitu_datediff(check_event.date_p, profile.first_launch_date) BETWEEN 4 AND 7 THEN 'D4-7'
        WHEN meitu_datediff(check_event.date_p, profile.first_launch_date) BETWEEN 8 AND 30 THEN 'D8-30'
        WHEN meitu_datediff(check_event.date_p, profile.first_launch_date) BETWEEN 31 AND 90 THEN 'D31-90'
        WHEN meitu_datediff(check_event.date_p, profile.first_launch_date) > 90 THEN 'D91+'
        ELSE 'Unknown'
    END AS install_age_bucket,
    CASE WHEN profile.is_subscribed = 1 THEN 'Paying' ELSE 'Un-Paying' END AS pay_status,
    check_event.material_id,
    check_event.material_id AS material_name_key,
    check_event.category_id,
    check_event.category_id AS category_name_key,
    CASE
        WHEN check_event.default_value_source IS NULL
          OR TRIM(check_event.default_value_source) = '' THEN 'Missing'
        ELSE LOWER(TRIM(check_event.default_value_source))
    END AS default_value_source,
    CASE
        WHEN check_event.filters_value_raw IS NULL
          OR TRIM(check_event.filters_value_raw) = '' THEN 'Missing'
        ELSE check_event.filters_value_raw
    END AS filters_value_raw,
    CAST(COUNT(1) AS BIGINT) AS material_check_pv
FROM
(
    SELECT
        raw.date_p,
        raw.gid,
        raw.os_type,
        REGEXP_EXTRACT(raw.params['mids_material_id'], '^([^,]+)', 1) AS material_id,
        REGEXP_EXTRACT(raw.params['mids_category_id'], '^([^,]+)', 1) AS category_id,
        raw.params['default_value_source'] AS default_value_source,
        raw.params['filters_value'] AS filters_value_raw
    FROM stat_sdk.sdk_odz_source_data raw
    WHERE raw.date_p BETWEEN 20260701 AND 20260731
      AND raw.app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
      AND raw.event_id = 'material_check'
      AND raw.params['module'] = 'edit'
      AND LOWER(TRIM(raw.params['material_type'])) = 'filters'
      AND raw.params['mids_material_id'] IS NOT NULL
      AND raw.gid IS NOT NULL
) check_event
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
  ON check_event.date_p = profile.date_p
 AND check_event.gid = profile.gid
GROUP BY
    CASE WHEN LOWER(COALESCE(profile.country, '')) IN ('巴西', 'brazil')
         THEN 'Brazil' ELSE 'Other' END,
    COALESCE(profile.os_type, check_event.os_type, '未知'),
    COALESCE(profile.is_new, 'Unknown'),
    CASE WHEN profile.is_new = 'New' THEN COALESCE(profile.is_ua, 'Unknown') ELSE 'Not Applicable' END,
    CASE
        WHEN profile.first_launch_date IS NULL THEN 'Unknown'
        WHEN meitu_datediff(check_event.date_p, profile.first_launch_date) = 0 THEN 'D0'
        WHEN meitu_datediff(check_event.date_p, profile.first_launch_date) BETWEEN 1 AND 3 THEN 'D1-3'
        WHEN meitu_datediff(check_event.date_p, profile.first_launch_date) BETWEEN 4 AND 7 THEN 'D4-7'
        WHEN meitu_datediff(check_event.date_p, profile.first_launch_date) BETWEEN 8 AND 30 THEN 'D8-30'
        WHEN meitu_datediff(check_event.date_p, profile.first_launch_date) BETWEEN 31 AND 90 THEN 'D31-90'
        WHEN meitu_datediff(check_event.date_p, profile.first_launch_date) > 90 THEN 'D91+'
        ELSE 'Unknown'
    END,
    CASE WHEN profile.is_subscribed = 1 THEN 'Paying' ELSE 'Un-Paying' END,
    check_event.material_id,
    check_event.category_id,
    CASE
        WHEN check_event.default_value_source IS NULL
          OR TRIM(check_event.default_value_source) = '' THEN 'Missing'
        ELSE LOWER(TRIM(check_event.default_value_source))
    END,
    CASE
        WHEN check_event.filters_value_raw IS NULL OR TRIM(check_event.filters_value_raw) = '' THEN 'Missing'
        ELSE check_event.filters_value_raw
    END
;
