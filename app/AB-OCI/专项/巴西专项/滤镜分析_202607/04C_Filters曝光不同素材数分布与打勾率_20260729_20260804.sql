-- AirBrush OCI | Filters distinct exposure depth and check rate
-- Period: 2026-07-29 to 2026-08-04
-- Engine: Hive on Spark
-- Exposure depth keeps exact values from 0 to 49 and groups 50 or more as 50+.

WITH profile AS
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
    WHERE date_p BETWEEN 20260729 AND 20260804
    GROUP BY date_p, gid
),
event_stream AS
(
    SELECT
        raw.date_p,
        raw.gid,
        CAST(raw.`time` AS BIGINT) AS sort_ts_ms,
        1 AS event_order,
        'ENTER' AS event_type,
        CAST(NULL AS STRING) AS material_id,
        1 AS is_enter
    FROM stat_sdk.sdk_odz_source_data raw
    WHERE raw.date_p BETWEEN 20260729 AND 20260804
      AND raw.app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
      AND raw.event_id = 'first_func_enter'
      AND LOWER(TRIM(raw.params['first_func'])) = 'filters'
      AND raw.gid IS NOT NULL
      AND raw.`time` IS NOT NULL

    UNION ALL

    SELECT
        detail.date_p,
        detail.gid,
        CAST(detail.event_timestamp AS BIGINT) * 1000 + 999 AS sort_ts_ms,
        CASE
            WHEN detail.event_type = '曝光' THEN 2
            WHEN detail.event_type = '打勾' THEN 4
            ELSE 9
        END AS event_order,
        detail.event_type,
        CASE
            WHEN detail.event_type = '打勾'
                THEN REGEXP_EXTRACT(detail.material_id, '^([^,]+)', 1)
            ELSE TRIM(detail.material_id)
        END AS material_id,
        0 AS is_enter
    FROM stat_ab.filing_onz_filter_material_event_detail detail
    WHERE detail.date_p BETWEEN 20260729 AND 20260804
      AND detail.event_type IN ('曝光', '打勾')
      AND detail.gid IS NOT NULL
      AND detail.material_id IS NOT NULL
      AND TRIM(detail.material_id) <> ''
),
sequenced_event AS
(
    SELECT
        date_p,
        gid,
        event_type,
        material_id,
        SUM(is_enter) OVER (
            PARTITION BY date_p, gid
            ORDER BY sort_ts_ms, event_order
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS filter_round_no
    FROM event_stream
),
round_base AS
(
    SELECT
        sequenced_event.date_p,
        sequenced_event.gid,
        sequenced_event.filter_round_no,
        COALESCE(profile.os_type, '未知') AS os_type,
        CASE
            WHEN profile.country IN ('巴西', 'Brazil') THEN 'Brazil'
            ELSE 'Other'
        END AS country_group,
        COALESCE(profile.is_new, 'Unknown') AS is_new,
        CASE
            WHEN profile.is_new = 'New' THEN COALESCE(profile.is_ua, 'Unknown')
            ELSE 'Not Applicable'
        END AS is_ua,
        CASE
            WHEN profile.is_subscribed = 1 THEN 'Paying'
            WHEN profile.is_subscribed = 0 THEN 'Un-Paying'
            ELSE 'Unknown'
        END AS pay_status,
        CASE
            WHEN profile.first_launch_date IS NULL THEN 'Unknown'
            WHEN meitu_datediff(sequenced_event.date_p, profile.first_launch_date) = 0 THEN 'D0'
            WHEN meitu_datediff(sequenced_event.date_p, profile.first_launch_date) BETWEEN 1 AND 3 THEN 'D1-3'
            WHEN meitu_datediff(sequenced_event.date_p, profile.first_launch_date) BETWEEN 4 AND 7 THEN 'D4-7'
            WHEN meitu_datediff(sequenced_event.date_p, profile.first_launch_date) BETWEEN 8 AND 30 THEN 'D8-30'
            WHEN meitu_datediff(sequenced_event.date_p, profile.first_launch_date) BETWEEN 31 AND 90 THEN 'D31-90'
            WHEN meitu_datediff(sequenced_event.date_p, profile.first_launch_date) > 90 THEN 'D91+'
            ELSE 'Unknown'
        END AS install_age_bucket
    FROM
    (
        SELECT * FROM sequenced_event
    ) sequenced_event
    LEFT JOIN
    (
        SELECT * FROM profile
    ) profile
      ON sequenced_event.date_p = profile.date_p
     AND sequenced_event.gid = profile.gid
    WHERE sequenced_event.event_type = 'ENTER'
),
valid_material_event AS
(
    SELECT
        date_p,
        gid,
        filter_round_no,
        event_type,
        material_id
    FROM sequenced_event
    WHERE event_type IN ('曝光', '打勾')
      AND filter_round_no > 0
),
exposure_stats AS
(
    SELECT
        date_p,
        gid,
        filter_round_no,
        COUNT(DISTINCT material_id) AS distinct_exposure_materials
    FROM valid_material_event
    WHERE event_type = '曝光'
    GROUP BY date_p, gid, filter_round_no
),
check_stats AS
(
    SELECT
        date_p,
        gid,
        filter_round_no,
        1 AS has_check
    FROM valid_material_event
    WHERE event_type = '打勾'
    GROUP BY date_p, gid, filter_round_no
),
round_metrics AS
(
    SELECT
        round_base.os_type,
        round_base.country_group,
        round_base.is_new,
        round_base.is_ua,
        round_base.pay_status,
        round_base.install_age_bucket,
        COALESCE(exposure_stats.distinct_exposure_materials, 0) AS distinct_exposure_materials,
        COALESCE(check_stats.has_check, 0) AS has_check,
        CASE
            WHEN COALESCE(exposure_stats.distinct_exposure_materials, 0) >= 50 THEN '50+'
            ELSE CAST(COALESCE(exposure_stats.distinct_exposure_materials, 0) AS STRING)
        END AS exposure_depth_bucket
    FROM
    (
        SELECT * FROM round_base
    ) round_base
    LEFT JOIN
    (
        SELECT * FROM exposure_stats
    ) exposure_stats
      ON round_base.date_p = exposure_stats.date_p
     AND round_base.gid = exposure_stats.gid
     AND round_base.filter_round_no = exposure_stats.filter_round_no
    LEFT JOIN
    (
        SELECT * FROM check_stats
    ) check_stats
      ON round_base.date_p = check_stats.date_p
     AND round_base.gid = check_stats.gid
     AND round_base.filter_round_no = check_stats.filter_round_no
)
SELECT
    os_type,
    country_group,
    is_new,
    is_ua,
    pay_status,
    install_age_bucket,
    exposure_depth_bucket,
    COUNT(1) AS filter_entry_count,
    SUM(has_check) AS checked_entry_count,
    SUM(distinct_exposure_materials) AS distinct_exposure_material_sum
FROM round_metrics
GROUP BY
    os_type,
    country_group,
    is_new,
    is_ua,
    pay_status,
    install_age_bucket,
    exposure_depth_bucket
;
