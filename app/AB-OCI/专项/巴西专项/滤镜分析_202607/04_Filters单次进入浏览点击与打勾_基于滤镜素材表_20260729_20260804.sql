-- AirBrush OCI | Brazil Filters | per-entry material behavior
-- Period: 2026-07-29 to 2026-08-04
-- Recommended engine: Hive on Spark
--
-- Reused detail table:
--   stat_ab.filing_onz_filter_material_event_detail
--   The table already contains Filters exposure/click/check events for this period.
--
-- Segments retained in every output row:
--   os_type, country, is_new, is_ua, pay_status, install_age_bucket.
--   Overall/Brazil and other rollups are calculated locally after download.
--
-- Important limitation:
--   The reused table does not retain trace_info and stores event time in seconds.
--   Therefore one Filters round is defined as the interval from one
--   first_func_enter(first_func='filters') to the next Filters entry of the same gid/date_p.
--   If click and check happen in the same second, their order is marked SAME_SECOND_AMBIGUOUS.
--
-- Output record types:
--   SUMMARY        : entries per Filters user-day, distinct exposure/click per entry,
--                    entry check rate and repeated-click rate.
--   CLICK_DEPTH    : round share and check rate by distinct clicked-material count.
--   CHECK_RELATION : final checked material vs the last/earlier clicked material.
--   REPEAT_DEPTH   : max clicks on one material in the same Filters round.

WITH filter_enter_raw AS
(
    SELECT
        raw.date_p,
        raw.gid,
        raw.os_type,
        TRIM(raw.params['trace_info']) AS trace_info,
        CAST(raw.`time` AS BIGINT) AS enter_ts_ms,
        CAST(CAST(raw.`time` AS BIGINT) / 1000 AS BIGINT) AS enter_ts_sec
    FROM stat_sdk.sdk_odz_source_data raw
    WHERE raw.date_p BETWEEN 20260729 AND 20260804
      AND raw.app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
      AND raw.event_id = 'first_func_enter'
      AND LOWER(TRIM(raw.params['first_func'])) = 'filters'
      AND raw.gid IS NOT NULL
      AND raw.`time` IS NOT NULL
),
filter_enter_ranked AS
(
    SELECT
        filter_enter_raw.*,
        ROW_NUMBER() OVER (
            PARTITION BY date_p, gid
            ORDER BY enter_ts_ms, COALESCE(trace_info, '')
        ) AS filter_round_no,
        LEAD(enter_ts_sec) OVER (
            PARTITION BY date_p, gid
            ORDER BY enter_ts_ms, COALESCE(trace_info, '')
        ) AS next_enter_ts_sec
    FROM filter_enter_raw
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
    WHERE date_p BETWEEN 20260729 AND 20260804
    GROUP BY date_p, gid
),
round_base AS
(
    SELECT
        filter_enter_ranked.date_p,
        filter_enter_ranked.gid,
        filter_enter_ranked.filter_round_no,
        filter_enter_ranked.enter_ts_sec,
        filter_enter_ranked.next_enter_ts_sec,
        COALESCE(profile.os_type, filter_enter_ranked.os_type, '未知') AS os_type,
        COALESCE(profile.country, 'Unknown') AS country,
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
            WHEN meitu_datediff(filter_enter_ranked.date_p, profile.first_launch_date) = 0 THEN 'D0'
            WHEN meitu_datediff(filter_enter_ranked.date_p, profile.first_launch_date) BETWEEN 1 AND 3 THEN 'D1-3'
            WHEN meitu_datediff(filter_enter_ranked.date_p, profile.first_launch_date) BETWEEN 4 AND 7 THEN 'D4-7'
            WHEN meitu_datediff(filter_enter_ranked.date_p, profile.first_launch_date) BETWEEN 8 AND 30 THEN 'D8-30'
            WHEN meitu_datediff(filter_enter_ranked.date_p, profile.first_launch_date) BETWEEN 31 AND 90 THEN 'D31-90'
            WHEN meitu_datediff(filter_enter_ranked.date_p, profile.first_launch_date) > 90 THEN 'D91+'
            ELSE 'Unknown'
        END AS install_age_bucket
    FROM
    (
        SELECT * FROM filter_enter_ranked
    ) filter_enter_ranked
    LEFT JOIN
    (
        SELECT * FROM profile
    ) profile
      ON filter_enter_ranked.date_p = profile.date_p
     AND filter_enter_ranked.gid = profile.gid
),
material_event AS
(
    SELECT
        detail.date_p,
        detail.gid,
        CAST(detail.event_timestamp AS BIGINT) AS event_timestamp,
        detail.event_type,
        CASE
            WHEN detail.event_type = '打勾'
                THEN REGEXP_EXTRACT(detail.material_id, '^([^,]+)', 1)
            ELSE TRIM(detail.material_id)
        END AS material_id
    FROM stat_ab.filing_onz_filter_material_event_detail detail
    WHERE detail.date_p BETWEEN 20260729 AND 20260804
      AND detail.event_type IN ('曝光', '点击', '打勾')
      AND detail.gid IS NOT NULL
      AND detail.material_id IS NOT NULL
      AND TRIM(detail.material_id) <> ''
),
assigned_event AS
(
    SELECT
        round_base.date_p,
        round_base.gid,
        round_base.filter_round_no,
        material_event.event_timestamp,
        material_event.event_type,
        material_event.material_id
    FROM
    (
        SELECT * FROM round_base
    ) round_base
    INNER JOIN
    (
        SELECT * FROM material_event
    ) material_event
      ON round_base.date_p = material_event.date_p
     AND round_base.gid = material_event.gid
     AND material_event.event_timestamp >= round_base.enter_ts_sec
     AND (
          round_base.next_enter_ts_sec IS NULL
          OR material_event.event_timestamp < round_base.next_enter_ts_sec
     )
),
exposure_stats AS
(
    SELECT
        date_p,
        gid,
        filter_round_no,
        COUNT(1) AS exposure_pv,
        COUNT(DISTINCT material_id) AS distinct_exposure_materials
    FROM assigned_event
    WHERE event_type = '曝光'
    GROUP BY date_p, gid, filter_round_no
),
click_by_material AS
(
    SELECT
        date_p,
        gid,
        filter_round_no,
        material_id,
        COUNT(1) AS material_click_pv
    FROM assigned_event
    WHERE event_type = '点击'
    GROUP BY date_p, gid, filter_round_no, material_id
),
click_stats AS
(
    SELECT
        date_p,
        gid,
        filter_round_no,
        SUM(material_click_pv) AS click_pv,
        COUNT(1) AS distinct_click_materials,
        MAX(material_click_pv) AS max_same_material_clicks,
        MAX(CASE WHEN material_click_pv >= 2 THEN 1 ELSE 0 END) AS has_repeat_click
    FROM click_by_material
    GROUP BY date_p, gid, filter_round_no
),
check_ranked AS
(
    SELECT
        date_p,
        gid,
        filter_round_no,
        material_id AS final_check_material_id,
        event_timestamp AS final_check_ts,
        ROW_NUMBER() OVER (
            PARTITION BY date_p, gid, filter_round_no
            ORDER BY event_timestamp DESC, material_id DESC
        ) AS check_rn
    FROM assigned_event
    WHERE event_type = '打勾'
),
final_check AS
(
    SELECT
        date_p,
        gid,
        filter_round_no,
        final_check_material_id,
        final_check_ts
    FROM check_ranked
    WHERE check_rn = 1
),
click_before_check_ranked AS
(
    SELECT
        click_event.date_p,
        click_event.gid,
        click_event.filter_round_no,
        click_event.material_id,
        click_event.event_timestamp,
        ROW_NUMBER() OVER (
            PARTITION BY click_event.date_p, click_event.gid, click_event.filter_round_no
            ORDER BY click_event.event_timestamp DESC, click_event.material_id DESC
        ) AS click_rn
    FROM
    (
        SELECT *
        FROM assigned_event
        WHERE event_type = '点击'
    ) click_event
    INNER JOIN
    (
        SELECT * FROM final_check
    ) final_check
      ON click_event.date_p = final_check.date_p
     AND click_event.gid = final_check.gid
     AND click_event.filter_round_no = final_check.filter_round_no
     AND click_event.event_timestamp < final_check.final_check_ts
),
last_click_before_check AS
(
    SELECT
        date_p,
        gid,
        filter_round_no,
        material_id AS last_click_material_id,
        event_timestamp AS last_click_ts
    FROM click_before_check_ranked
    WHERE click_rn = 1
),
checked_material_seen AS
(
    SELECT
        click_event.date_p,
        click_event.gid,
        click_event.filter_round_no,
        MAX(CASE
            WHEN click_event.material_id = final_check.final_check_material_id
                THEN 1 ELSE 0
        END) AS checked_material_was_clicked
    FROM
    (
        SELECT *
        FROM assigned_event
        WHERE event_type = '点击'
    ) click_event
    INNER JOIN
    (
        SELECT * FROM final_check
    ) final_check
      ON click_event.date_p = final_check.date_p
     AND click_event.gid = final_check.gid
     AND click_event.filter_round_no = final_check.filter_round_no
     AND click_event.event_timestamp < final_check.final_check_ts
    GROUP BY click_event.date_p, click_event.gid, click_event.filter_round_no
),
same_second_click AS
(
    SELECT
        click_event.date_p,
        click_event.gid,
        click_event.filter_round_no,
        COUNT(1) AS same_second_click_pv
    FROM
    (
        SELECT *
        FROM assigned_event
        WHERE event_type = '点击'
    ) click_event
    INNER JOIN
    (
        SELECT * FROM final_check
    ) final_check
      ON click_event.date_p = final_check.date_p
     AND click_event.gid = final_check.gid
     AND click_event.filter_round_no = final_check.filter_round_no
     AND click_event.event_timestamp = final_check.final_check_ts
    GROUP BY click_event.date_p, click_event.gid, click_event.filter_round_no
),
round_metrics AS
(
    SELECT
        round_base.date_p,
        round_base.gid,
        round_base.os_type,
        round_base.country,
        round_base.is_new,
        round_base.is_ua,
        round_base.pay_status,
        round_base.install_age_bucket,
        COALESCE(exposure_stats.distinct_exposure_materials, 0)
            AS distinct_exposure_materials,
        COALESCE(click_stats.distinct_click_materials, 0)
            AS distinct_click_materials,
        COALESCE(click_stats.max_same_material_clicks, 0)
            AS max_same_material_clicks,
        COALESCE(click_stats.has_repeat_click, 0) AS has_repeat_click,
        CASE WHEN final_check.final_check_ts IS NOT NULL THEN 1 ELSE 0 END AS has_check,
        CASE
            WHEN final_check.final_check_ts IS NULL THEN 'NO_CHECK'
            WHEN COALESCE(same_second_click.same_second_click_pv, 0) > 0
                THEN 'SAME_SECOND_AMBIGUOUS'
            WHEN last_click_before_check.last_click_material_id
                   = final_check.final_check_material_id
                THEN 'CHECK_IS_LAST_CLICK'
            WHEN COALESCE(checked_material_seen.checked_material_was_clicked, 0) = 1
                THEN 'CHECK_WAS_EARLIER_CLICK'
            ELSE 'CHECK_WITHOUT_PREVIOUS_CLICK'
        END AS check_relation
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
        SELECT * FROM click_stats
    ) click_stats
      ON round_base.date_p = click_stats.date_p
     AND round_base.gid = click_stats.gid
     AND round_base.filter_round_no = click_stats.filter_round_no
    LEFT JOIN
    (
        SELECT * FROM final_check
    ) final_check
      ON round_base.date_p = final_check.date_p
     AND round_base.gid = final_check.gid
     AND round_base.filter_round_no = final_check.filter_round_no
    LEFT JOIN
    (
        SELECT * FROM last_click_before_check
    ) last_click_before_check
      ON round_base.date_p = last_click_before_check.date_p
     AND round_base.gid = last_click_before_check.gid
     AND round_base.filter_round_no = last_click_before_check.filter_round_no
    LEFT JOIN
    (
        SELECT * FROM checked_material_seen
    ) checked_material_seen
      ON round_base.date_p = checked_material_seen.date_p
     AND round_base.gid = checked_material_seen.gid
     AND round_base.filter_round_no = checked_material_seen.filter_round_no
    LEFT JOIN
    (
        SELECT * FROM same_second_click
    ) same_second_click
      ON round_base.date_p = same_second_click.date_p
     AND round_base.gid = same_second_click.gid
     AND round_base.filter_round_no = same_second_click.filter_round_no
),
segmented_round_metrics AS
(
    SELECT
        date_p,
        gid,
        os_type,
        country,
        is_new,
        is_ua,
        pay_status,
        install_age_bucket,
        distinct_exposure_materials,
        distinct_click_materials,
        max_same_material_clicks,
        has_repeat_click,
        has_check,
        check_relation
    FROM round_metrics
)
SELECT
    'SUMMARY' AS record_type,
    os_type,
    country,
    is_new,
    is_ua,
    pay_status,
    install_age_bucket,
    'ALL' AS dimension_value,
    COUNT(DISTINCT CONCAT(CAST(date_p AS STRING), '#', CAST(gid AS STRING)))
        AS filter_user_day_count,
    COUNT(1) AS filter_enter_round_count,
    SUM(distinct_exposure_materials) AS total_distinct_exposure_materials,
    SUM(distinct_click_materials) AS total_distinct_click_materials,
    SUM(CASE WHEN distinct_click_materials > 0 THEN 1 ELSE 0 END) AS clicked_round_count,
    SUM(has_check) AS checked_round_count,
    SUM(has_repeat_click) AS repeat_click_round_count
FROM segmented_round_metrics
GROUP BY os_type, country, is_new, is_ua, pay_status, install_age_bucket

UNION ALL

SELECT
    'CLICK_DEPTH' AS record_type,
    os_type,
    country,
    is_new,
    is_ua,
    pay_status,
    install_age_bucket,
    CASE
        WHEN distinct_click_materials >= 20 THEN '20+'
        ELSE CAST(distinct_click_materials AS STRING)
    END AS dimension_value,
    CAST(NULL AS BIGINT) AS filter_user_day_count,
    COUNT(1) AS filter_enter_round_count,
    SUM(distinct_exposure_materials) AS total_distinct_exposure_materials,
    SUM(distinct_click_materials) AS total_distinct_click_materials,
    SUM(CASE WHEN distinct_click_materials > 0 THEN 1 ELSE 0 END) AS clicked_round_count,
    SUM(has_check) AS checked_round_count,
    SUM(has_repeat_click) AS repeat_click_round_count
FROM segmented_round_metrics
GROUP BY
    os_type,
    country,
    is_new,
    is_ua,
    pay_status,
    install_age_bucket,
    CASE
        WHEN distinct_click_materials >= 20 THEN '20+'
        ELSE CAST(distinct_click_materials AS STRING)
    END

UNION ALL

SELECT
    'CHECK_RELATION' AS record_type,
    os_type,
    country,
    is_new,
    is_ua,
    pay_status,
    install_age_bucket,
    check_relation AS dimension_value,
    CAST(NULL AS BIGINT) AS filter_user_day_count,
    COUNT(1) AS filter_enter_round_count,
    SUM(distinct_exposure_materials) AS total_distinct_exposure_materials,
    SUM(distinct_click_materials) AS total_distinct_click_materials,
    SUM(CASE WHEN distinct_click_materials > 0 THEN 1 ELSE 0 END) AS clicked_round_count,
    SUM(has_check) AS checked_round_count,
    SUM(has_repeat_click) AS repeat_click_round_count
FROM segmented_round_metrics
GROUP BY os_type, country, is_new, is_ua, pay_status, install_age_bucket, check_relation

UNION ALL

SELECT
    'REPEAT_DEPTH' AS record_type,
    os_type,
    country,
    is_new,
    is_ua,
    pay_status,
    install_age_bucket,
    CASE
        WHEN max_same_material_clicks >= 4 THEN '4+'
        ELSE CAST(max_same_material_clicks AS STRING)
    END AS dimension_value,
    CAST(NULL AS BIGINT) AS filter_user_day_count,
    COUNT(1) AS filter_enter_round_count,
    SUM(distinct_exposure_materials) AS total_distinct_exposure_materials,
    SUM(distinct_click_materials) AS total_distinct_click_materials,
    SUM(CASE WHEN distinct_click_materials > 0 THEN 1 ELSE 0 END) AS clicked_round_count,
    SUM(has_check) AS checked_round_count,
    SUM(has_repeat_click) AS repeat_click_round_count
FROM segmented_round_metrics
GROUP BY
    os_type,
    country,
    is_new,
    is_ua,
    pay_status,
    install_age_bucket,
    CASE
        WHEN max_same_material_clicks >= 4 THEN '4+'
        ELSE CAST(max_same_material_clicks AS STRING)
    END
;
