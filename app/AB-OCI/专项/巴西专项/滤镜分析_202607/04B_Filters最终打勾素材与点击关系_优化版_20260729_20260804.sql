-- AirBrush OCI | Filters final checked material vs click relation
-- Period: 2026-07-29 to 2026-08-04
-- Engine: Hive on Spark
--
-- The reused material table stores timestamps in seconds.
-- A click in the same second as the final check is classified as
-- SAME_SECOND_AMBIGUOUS instead of assuming an order.

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
      AND detail.event_type IN ('点击', '打勾')
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
        event_order,
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
        END AS country,
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
material_event AS
(
    SELECT
        date_p,
        gid,
        filter_round_no,
        event_ts_sec,
        sort_ts_ms,
        event_type,
        material_id
    FROM sequenced_event
    WHERE event_type IN ('点击', '打勾')
      AND filter_round_no > 0
),
check_ranked AS
(
    SELECT
        date_p,
        gid,
        filter_round_no,
        material_id AS final_check_material_id,
        event_ts_sec AS final_check_ts_sec,
        sort_ts_ms AS final_check_sort_ts,
        ROW_NUMBER() OVER (
            PARTITION BY date_p, gid, filter_round_no
            ORDER BY sort_ts_ms DESC, material_id DESC
        ) AS check_rn
    FROM material_event
    WHERE event_type = '打勾'
),
final_check AS
(
    SELECT
        date_p,
        gid,
        filter_round_no,
        final_check_material_id,
        final_check_ts_sec,
        final_check_sort_ts
    FROM check_ranked
    WHERE check_rn = 1
),
click_by_material AS
(
    SELECT
        date_p,
        gid,
        filter_round_no,
        material_id,
        MAX(event_ts_sec) AS last_click_ts_sec
    FROM material_event
    WHERE event_type = '点击'
    GROUP BY
        date_p,
        gid,
        filter_round_no,
        material_id
),
click_before_summary AS
(
    SELECT
        final_check.date_p,
        final_check.gid,
        final_check.filter_round_no,
        final_check.final_check_material_id,
        final_check.final_check_ts_sec,
        MAX(click_by_material.last_click_ts_sec) AS max_click_ts_through_check,
        MAX(CASE
            WHEN click_by_material.material_id = final_check.final_check_material_id
                THEN click_by_material.last_click_ts_sec
            ELSE NULL
        END) AS checked_material_last_click_ts,
        COUNT(click_by_material.material_id) AS clicked_material_count_through_check
    FROM
    (
        SELECT * FROM final_check
    ) final_check
    LEFT JOIN
    (
        SELECT * FROM click_by_material
    ) click_by_material
      ON final_check.date_p = click_by_material.date_p
     AND final_check.gid = click_by_material.gid
     AND final_check.filter_round_no = click_by_material.filter_round_no
     AND click_by_material.last_click_ts_sec <= final_check.final_check_ts_sec
    GROUP BY
        final_check.date_p,
        final_check.gid,
        final_check.filter_round_no,
        final_check.final_check_material_id,
        final_check.final_check_ts_sec
),
round_relation AS
(
    SELECT
        round_base.os_type,
        round_base.country,
        round_base.is_new,
        round_base.is_ua,
        round_base.pay_status,
        round_base.install_age_bucket,
        CASE
            WHEN click_before_summary.clicked_material_count_through_check = 0 THEN 'NO_CLICK_BEFORE_CHECK'
            WHEN click_before_summary.max_click_ts_through_check = click_before_summary.final_check_ts_sec
                THEN 'SAME_SECOND_AMBIGUOUS'
            WHEN click_before_summary.checked_material_last_click_ts = click_before_summary.max_click_ts_through_check
                THEN 'FINAL_CHECK_IS_LAST_CLICK'
            WHEN click_before_summary.checked_material_last_click_ts IS NOT NULL
                THEN 'FINAL_CHECK_IS_EARLIER_CLICK'
            ELSE 'FINAL_CHECK_NOT_MATCH_CLICK'
        END AS check_relation
    FROM
    (
        SELECT * FROM click_before_summary
    ) click_before_summary
    INNER JOIN
    (
        SELECT * FROM round_base
    ) round_base
      ON click_before_summary.date_p = round_base.date_p
     AND click_before_summary.gid = round_base.gid
     AND click_before_summary.filter_round_no = round_base.filter_round_no
)
SELECT
    os_type,
    country,
    is_new,
    is_ua,
    pay_status,
    install_age_bucket,
    check_relation,
    COUNT(1) AS checked_entry_count
FROM round_relation
GROUP BY
    os_type,
    country,
    is_new,
    is_ua,
    pay_status,
    install_age_bucket,
    check_relation
;
