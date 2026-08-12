-- AirBrush OCI｜滤镜素材用户日宽表｜供 Python 计算严格 D1 / D7 复用
-- 粒度：用户 × 日期 × 素材 × 分类；同一用户同一天重复打勾同素材只计一次。

WITH material_use AS
(
    SELECT
        raw.date_p,
        raw.gid,
        MAX(raw.os_type) AS event_os_type,
        REGEXP_EXTRACT(raw.params['mids_material_id'], '^([^,]+)', 1) AS material_id,
        REGEXP_EXTRACT(raw.params['mids_category_id'], '^([^,]+)', 1) AS category_id
    FROM stat_sdk.sdk_odz_source_data raw
    WHERE raw.date_p BETWEEN 20260701 AND 20260707
      AND raw.app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
      AND raw.event_id = 'material_check'
      AND raw.params['module'] = 'edit'
      AND LOWER(TRIM(raw.params['material_type'])) = 'filters'
      AND raw.params['mids_material_id'] IS NOT NULL
      AND TRIM(raw.params['mids_material_id']) <> ''
      AND raw.gid IS NOT NULL
    GROUP BY
        raw.date_p,
        raw.gid,
        REGEXP_EXTRACT(raw.params['mids_material_id'], '^([^,]+)', 1),
        REGEXP_EXTRACT(raw.params['mids_category_id'], '^([^,]+)', 1)
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
    WHERE date_p BETWEEN 20260701 AND 20260707
    GROUP BY date_p, gid
)
SELECT
    material_use.date_p,
    material_use.gid,
    CASE WHEN LOWER(COALESCE(profile.country, '')) IN ('巴西', 'brazil')
         THEN 'Brazil' ELSE 'Other' END AS country_group,
    COALESCE(profile.os_type, material_use.event_os_type, '未知') AS os_type,
    COALESCE(profile.is_new, 'Unknown') AS is_new,
    CASE
        WHEN profile.is_new = 'New' THEN COALESCE(profile.is_ua, 'Unknown')
        ELSE 'Not Applicable'
    END AS is_ua,
    CASE
        WHEN profile.first_launch_date IS NULL THEN 'Unknown'
        WHEN meitu_datediff(material_use.date_p, profile.first_launch_date) = 0 THEN 'D0'
        WHEN meitu_datediff(material_use.date_p, profile.first_launch_date) BETWEEN 1 AND 3 THEN 'D1-3'
        WHEN meitu_datediff(material_use.date_p, profile.first_launch_date) BETWEEN 4 AND 7 THEN 'D4-7'
        WHEN meitu_datediff(material_use.date_p, profile.first_launch_date) BETWEEN 8 AND 30 THEN 'D8-30'
        WHEN meitu_datediff(material_use.date_p, profile.first_launch_date) BETWEEN 31 AND 90 THEN 'D31-90'
        WHEN meitu_datediff(material_use.date_p, profile.first_launch_date) > 90 THEN 'D91+'
        ELSE 'Unknown'
    END AS install_age_bucket,
    CASE WHEN profile.is_subscribed = 1 THEN 'Paying' ELSE 'Un-Paying' END AS pay_status,
    material_use.material_id,
    material_use.category_id
FROM material_use
LEFT JOIN profile
  ON material_use.date_p = profile.date_p
 AND material_use.gid = profile.gid
;
