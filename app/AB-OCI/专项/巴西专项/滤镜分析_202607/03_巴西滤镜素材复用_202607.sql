-- AirBrush OCI｜巴西滤镜专项｜素材严格 D1 / D7 复用
-- 分析期：2026-07-01～2026-07-31
-- 建议引擎：Hive on Spark
--
-- cohort 粒度：用户 × 日期 × 素材；同一用户同一天重复打勾同素材只计一次。
-- D1 成熟样本：cohort_date <= 20260730；D7 成熟样本：cohort_date <= 20260724。
-- 指标输出严格 D1 / D7 复用；先在 cohort 粒度生成标记，再做分层汇总。

WITH material_use AS
(
    SELECT
        raw.date_p,
        raw.gid,
        MAX(raw.os_type) AS os_type,
        REGEXP_EXTRACT(raw.params['mids_material_id'], '^([^,]+)', 1) AS material_id,
        REGEXP_EXTRACT(raw.params['mids_category_id'], '^([^,]+)', 1) AS category_id
    FROM stat_sdk.sdk_odz_source_data raw
    WHERE raw.date_p BETWEEN 20260701 AND 20260731
      AND raw.app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
      AND raw.event_id = 'material_check'
      AND raw.params['module'] = 'edit'
      AND LOWER(TRIM(raw.params['material_type'])) = 'filters'
      AND raw.params['mids_material_id'] IS NOT NULL
      AND raw.gid IS NOT NULL
    GROUP BY
        raw.date_p,
        raw.gid,
        REGEXP_EXTRACT(raw.params['mids_material_id'], '^([^,]+)', 1),
        REGEXP_EXTRACT(raw.params['mids_category_id'], '^([^,]+)', 1)
),
filter_use_date AS
(
    SELECT
        date_p,
        gid
    FROM material_use
    GROUP BY date_p, gid
),
material_use_date AS
(
    SELECT
        date_p,
        gid,
        material_id
    FROM material_use
    GROUP BY date_p, gid, material_id
),
cohort_base AS
(
    SELECT *
    FROM material_use
    WHERE date_p BETWEEN 20260701 AND 20260731 -- COHORT_DATE_RANGE
),
cohort_reuse AS
(
    SELECT
        cohort.date_p,
        cohort.gid,
        cohort.os_type,
        cohort.material_id,
        cohort.category_id,
        CASE WHEN d1_any.gid IS NOT NULL THEN 1 ELSE 0 END AS d1_any_filter,
        CASE WHEN d1_same.gid IS NOT NULL THEN 1 ELSE 0 END AS d1_same_material,
        CASE WHEN d7_any.gid IS NOT NULL THEN 1 ELSE 0 END AS d7_exact_any_filter,
        CASE WHEN d7_same.gid IS NOT NULL THEN 1 ELSE 0 END AS d7_exact_same_material
    FROM
    (
        SELECT * FROM cohort_base
    ) cohort
    LEFT JOIN
    (
        SELECT * FROM filter_use_date
    ) d1_any
      ON d1_any.date_p = cohort.date_p + 1
     AND d1_any.gid = cohort.gid
    LEFT JOIN
    (
        SELECT * FROM material_use_date
    ) d1_same
      ON d1_same.date_p = cohort.date_p + 1
     AND d1_same.gid = cohort.gid
     AND d1_same.material_id = cohort.material_id
    LEFT JOIN
    (
        SELECT * FROM filter_use_date
    ) d7_any
      ON d7_any.date_p = cohort.date_p + 7
     AND d7_any.gid = cohort.gid
    LEFT JOIN
    (
        SELECT * FROM material_use_date
    ) d7_same
      ON d7_same.date_p = cohort.date_p + 7
     AND d7_same.gid = cohort.gid
     AND d7_same.material_id = cohort.material_id
),
profile AS
(
    SELECT
        date_p,
        gid,
        MAX(country) AS country,
        MAX(os_type) AS os_type,
        MAX(is_new) AS is_new,
        MAX(is_ua) AS is_ua,
        MAX(is_subscribed) AS is_subscribed,
        MIN(first_launch_date) AS first_launch_date
    FROM stat_ab.filing_odz_active_user_profile
    WHERE date_p BETWEEN 20260701 AND 20260731 -- PROFILE_DATE_RANGE
    GROUP BY date_p, gid
),
enriched AS
(
    SELECT
        CASE WHEN LOWER(COALESCE(profile.country, '')) IN ('巴西', 'brazil')
             THEN 'Brazil' ELSE 'Other' END AS country_group,
        COALESCE(profile.os_type, cohort.os_type, '未知') AS os_type,
        COALESCE(profile.is_new, 'Unknown') AS is_new,
        CASE
            WHEN profile.is_new = 'New' THEN COALESCE(profile.is_ua, 'Unknown')
            ELSE 'Not Applicable'
        END AS is_ua,
        CASE
            WHEN profile.first_launch_date IS NULL THEN 'Unknown'
            WHEN meitu_datediff(cohort.date_p, profile.first_launch_date) = 0 THEN 'D0'
            WHEN meitu_datediff(cohort.date_p, profile.first_launch_date) BETWEEN 1 AND 3 THEN 'D1-3'
            WHEN meitu_datediff(cohort.date_p, profile.first_launch_date) BETWEEN 4 AND 7 THEN 'D4-7'
            WHEN meitu_datediff(cohort.date_p, profile.first_launch_date) BETWEEN 8 AND 30 THEN 'D8-30'
            WHEN meitu_datediff(cohort.date_p, profile.first_launch_date) BETWEEN 31 AND 90 THEN 'D31-90'
            WHEN meitu_datediff(cohort.date_p, profile.first_launch_date) > 90 THEN 'D91+'
            ELSE 'Unknown'
        END AS install_age_bucket,
        CASE WHEN profile.is_subscribed = 1 THEN 'Paying' ELSE 'Un-Paying' END AS pay_status,
        cohort.date_p,
        cohort.material_id,
        cohort.category_id,
        cohort.d1_any_filter,
        cohort.d1_same_material,
        cohort.d7_exact_any_filter,
        cohort.d7_exact_same_material
    FROM
    (
        SELECT * FROM cohort_reuse
    ) cohort
    LEFT JOIN
    (
        SELECT * FROM profile
    ) profile
      ON cohort.date_p = profile.date_p
     AND cohort.gid = profile.gid
)
SELECT
    country_group,
    os_type,
    is_new,
    is_ua,
    install_age_bucket,
    pay_status,
    material_id,
    material_id AS material_name_key,
    category_id,
    category_id AS category_name_key,
    CAST(COUNT(1) AS BIGINT) AS cohort_user_days,
    CAST(SUM(CASE WHEN date_p <= 20260730 THEN 1 ELSE 0 END) AS BIGINT)
        AS d1_mature_cohort_user_days,
    CAST(SUM(CASE WHEN date_p <= 20260730 THEN d1_any_filter ELSE 0 END) AS BIGINT)
        AS d1_any_filter_user_days,
    CAST(SUM(CASE WHEN date_p <= 20260730 THEN d1_same_material ELSE 0 END) AS BIGINT)
        AS d1_same_material_user_days,
    CAST(SUM(CASE WHEN date_p <= 20260724 THEN 1 ELSE 0 END) AS BIGINT)
        AS d7_mature_cohort_user_days,
    CAST(SUM(CASE WHEN date_p <= 20260724 THEN d7_exact_any_filter ELSE 0 END) AS BIGINT)
        AS d7_exact_any_filter_user_days,
    CAST(SUM(CASE WHEN date_p <= 20260724 THEN d7_exact_same_material ELSE 0 END) AS BIGINT)
        AS d7_exact_same_material_user_days
FROM enriched
GROUP BY
    country_group,
    os_type,
    is_new,
    is_ua,
    install_age_bucket,
    pay_status,
    material_id,
    category_id
;
