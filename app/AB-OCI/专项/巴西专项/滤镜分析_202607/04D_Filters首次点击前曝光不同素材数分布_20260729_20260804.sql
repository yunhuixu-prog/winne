-- AirBrush OCI | distinct materials exposed before first click in each Filters entry
-- Period: 2026-07-29 to 2026-08-04
-- Engine: Hive on Spark
-- Material timestamps are second-level.
-- Exposures strictly earlier than the first click form the main metric.
-- Exposures in the same second as the first click are counted separately.

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
        CAST(CAST(raw.`time` AS BIGINT) / 1000 AS BIGINT) AS event_ts_sec,
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
        CAST(detail.event_timestamp AS BIGINT) AS event_ts_sec,
        CASE
            WHEN detail.event_type = '曝光' THEN 2
            WHEN detail.event_type = '点击' THEN 3
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
      AND detail.event_type IN ('曝光', '点击', '打勾')
      AND detail.gid IS NOT NULL
      AND detail.material_id IS NOT NULL
      AND TRIM(detail.material_id) <> ''
),
sequenced_event AS
(
    SELECT
        date_p,
        gid,
        sort_ts_ms,
        event_ts_sec,
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
event_with_first_click AS
(
    SELECT
        date_p,
        gid,
        filter_round_no,
        event_ts_sec,
        event_type,
        material_id,
        MIN(CASE WHEN event_type = '点击' THEN event_ts_sec ELSE NULL END) OVER (
            PARTITION BY date_p, gid, filter_round_no
        ) AS first_click_ts_sec
    FROM sequenced_event
    WHERE filter_round_no > 0
),
round_event_stats AS
(
    SELECT
        date_p,
        gid,
        filter_round_no,
        MAX(first_click_ts_sec) AS first_click_ts_sec,
        COUNT(DISTINCT CASE
            WHEN event_type = '曝光'
             AND event_ts_sec < first_click_ts_sec
                THEN material_id
            ELSE NULL
        END) AS distinct_exposure_before_first_click,
        COUNT(DISTINCT CASE
            WHEN event_type = '曝光'
             AND event_ts_sec = first_click_ts_sec
                THEN material_id
            ELSE NULL
        END) AS distinct_exposure_same_second_as_first_click,
        MAX(CASE WHEN event_type = '打勾' THEN 1 ELSE 0 END) AS has_check
    FROM event_with_first_click
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
        CASE WHEN round_event_stats.first_click_ts_sec IS NULL THEN 0 ELSE 1 END AS has_click,
        COALESCE(round_event_stats.distinct_exposure_before_first_click, 0) AS distinct_exposure_before_first_click,
        COALESCE(round_event_stats.distinct_exposure_same_second_as_first_click, 0) AS distinct_exposure_same_second_as_first_click,
        COALESCE(round_event_stats.has_check, 0) AS has_check,
        CASE
            WHEN round_event_stats.first_click_ts_sec IS NULL THEN 'NO_CLICK'
            WHEN COALESCE(round_event_stats.distinct_exposure_before_first_click, 0) >= 50 THEN '50+'
            ELSE CAST(COALESCE(round_event_stats.distinct_exposure_before_first_click, 0) AS STRING)
        END AS pre_click_exposure_bucket
    FROM
    (
        SELECT * FROM round_base
    ) round_base
    LEFT JOIN
    (
        SELECT * FROM round_event_stats
    ) round_event_stats
      ON round_base.date_p = round_event_stats.date_p
     AND round_base.gid = round_event_stats.gid
     AND round_base.filter_round_no = round_event_stats.filter_round_no
)
SELECT
    os_type,
    country_group,
    is_new,
    is_ua,
    pay_status,
    install_age_bucket,
    pre_click_exposure_bucket,
    COUNT(1) AS filter_entry_count,
    SUM(has_click) AS clicked_entry_count,
    SUM(has_check) AS checked_entry_count,
    SUM(distinct_exposure_before_first_click) AS pre_click_exposure_material_sum,
    SUM(distinct_exposure_same_second_as_first_click) AS same_second_exposure_material_sum,
    SUM(CASE
        WHEN has_click = 1
         AND distinct_exposure_same_second_as_first_click > 0
            THEN 1 ELSE 0
    END) AS clicked_entry_with_same_second_exposure_count
FROM round_metrics
GROUP BY
    os_type,
    country_group,
    is_new,
    is_ua,
    pay_status,
    install_age_bucket,
    pre_click_exposure_bucket
;
