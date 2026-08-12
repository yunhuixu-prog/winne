-- AirBrush OCI | Brazil Filters analysis | per-entry material path
-- Period: 2026-07-01 to 2026-07-31
-- Recommended engine: Hive on Spark
--
-- Round definition:
--   date_p + gid + trace_info + the sequence number of first_func_enter(first_func='filters').
-- Material events are assigned to the latest Filters entry in the same trace.
--
-- Outputs:
--   SUMMARY        : average Filters entries per Filters user-day; average distinct exposed/clicked
--                    materials per entry; round check rate; repeated-click rate.
--   CLICK_DEPTH    : share and check rate by distinct clicked-material count per entry.
--   CHECK_RELATION : whether the final checked material was the last click, an earlier click,
--                    or had no preceding click in the same entry round.
--   REPEAT_DEPTH   : distribution of the maximum click count on one material in an entry round.

WITH raw_event AS
(
    SELECT
        raw.date_p,
        raw.gid,
        TRIM(raw.params['trace_info']) AS trace_info,
        raw.os_type,
        raw.event_id,
        CAST(raw.`time` AS BIGINT) AS event_ts,
        CASE
            WHEN raw.event_id = 'first_func_enter' THEN 1
            WHEN raw.event_id = 'material_exposure' THEN 2
            WHEN raw.event_id = 'material_click' THEN 3
            WHEN raw.event_id = 'material_check' THEN 4
            ELSE 9
        END AS event_order,
        CASE
            WHEN raw.event_id = 'first_func_enter'
             AND LOWER(TRIM(raw.params['first_func'])) = 'filters'
                THEN 1 ELSE 0
        END AS is_filter_enter,
        CASE
            WHEN raw.event_id = 'material_exposure'
             AND LOWER(TRIM(raw.params['material_type'])) = 'filters'
             AND LOWER(TRIM(raw.params['module'])) = 'edit'
                THEN 1 ELSE 0
        END AS is_filter_exposure,
        CASE
            WHEN raw.event_id = 'material_click'
             AND LOWER(TRIM(raw.params['material_type'])) = 'filters'
             AND LOWER(TRIM(raw.params['module'])) = 'edit'
                THEN 1 ELSE 0
        END AS is_filter_click,
        CASE
            WHEN raw.event_id = 'material_check'
             AND LOWER(TRIM(raw.params['material_type'])) = 'filters'
             AND LOWER(TRIM(raw.params['module'])) = 'edit'
             AND raw.params['mids_material_id'] IS NOT NULL
                THEN 1 ELSE 0
        END AS is_filter_check,
        CASE
            WHEN raw.event_id = 'material_check'
                THEN REGEXP_EXTRACT(raw.params['mids_material_id'], '^([^,]+)', 1)
            ELSE raw.params['material_id']
        END AS material_id
    FROM stat_sdk.sdk_odz_source_data raw
    WHERE raw.date_p BETWEEN 20260701 AND 20260731
      AND raw.app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
      AND raw.event_id IN (
          'first_func_enter',
          'material_exposure',
          'material_click',
          'material_check'
      )
      AND (
          (raw.event_id = 'first_func_enter'
           AND LOWER(TRIM(raw.params['first_func'])) = 'filters')
          OR (raw.event_id IN ('material_exposure', 'material_click', 'material_check')
              AND LOWER(TRIM(raw.params['material_type'])) = 'filters'
              AND LOWER(TRIM(raw.params['module'])) = 'edit')
      )
      AND raw.gid IS NOT NULL
      AND raw.params['trace_info'] IS NOT NULL
      AND TRIM(raw.params['trace_info']) <> ''
      AND raw.`time` IS NOT NULL
),
sequenced_event AS
(
    SELECT
        raw_event.*,
        SUM(is_filter_enter) OVER (
            PARTITION BY date_p, gid, trace_info
            ORDER BY event_ts, event_order
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS filter_round_no
    FROM raw_event
),
round_event AS
(
    SELECT
        date_p,
        gid,
        trace_info,
        os_type,
        filter_round_no,
        event_id,
        event_ts,
        event_order,
        is_filter_enter,
        is_filter_exposure,
        is_filter_click,
        is_filter_check,
        material_id
    FROM sequenced_event
    WHERE filter_round_no > 0
),
round_base AS
(
    SELECT
        date_p,
        gid,
        trace_info,
        filter_round_no,
        MAX(os_type) AS os_type,
        MIN(CASE WHEN is_filter_enter = 1 THEN event_ts END) AS round_enter_ts
    FROM round_event
    GROUP BY date_p, gid, trace_info, filter_round_no
    HAVING SUM(is_filter_enter) > 0
),
exposure_stats AS
(
    SELECT
        date_p,
        gid,
        trace_info,
        filter_round_no,
        COUNT(1) AS exposure_pv,
        COUNT(DISTINCT material_id) AS distinct_exposure_materials
    FROM round_event
    WHERE is_filter_exposure = 1
      AND material_id IS NOT NULL
      AND TRIM(material_id) <> ''
    GROUP BY date_p, gid, trace_info, filter_round_no
),
click_by_material AS
(
    SELECT
        date_p,
        gid,
        trace_info,
        filter_round_no,
        material_id,
        COUNT(1) AS material_click_pv
    FROM round_event
    WHERE is_filter_click = 1
      AND material_id IS NOT NULL
      AND TRIM(material_id) <> ''
    GROUP BY date_p, gid, trace_info, filter_round_no, material_id
),
click_stats AS
(
    SELECT
        date_p,
        gid,
        trace_info,
        filter_round_no,
        SUM(material_click_pv) AS click_pv,
        COUNT(1) AS distinct_click_materials,
        MAX(material_click_pv) AS max_same_material_clicks,
        MAX(CASE WHEN material_click_pv >= 2 THEN 1 ELSE 0 END) AS has_repeat_click
    FROM click_by_material
    GROUP BY date_p, gid, trace_info, filter_round_no
),
check_ranked AS
(
    SELECT
        date_p,
        gid,
        trace_info,
        filter_round_no,
        material_id AS final_check_material_id,
        event_ts AS final_check_ts,
        ROW_NUMBER() OVER (
            PARTITION BY date_p, gid, trace_info, filter_round_no
            ORDER BY event_ts DESC, event_order DESC, material_id DESC
        ) AS check_rn
    FROM round_event
    WHERE is_filter_check = 1
      AND material_id IS NOT NULL
      AND TRIM(material_id) <> ''
),
final_check AS
(
    SELECT
        date_p,
        gid,
        trace_info,
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
        click_event.trace_info,
        click_event.filter_round_no,
        click_event.material_id,
        click_event.event_ts,
        ROW_NUMBER() OVER (
            PARTITION BY click_event.date_p, click_event.gid,
                         click_event.trace_info, click_event.filter_round_no
            ORDER BY click_event.event_ts DESC,
                     click_event.event_order DESC,
                     click_event.material_id DESC
        ) AS click_rn
    FROM
    (
        SELECT *
        FROM round_event
        WHERE is_filter_click = 1
          AND material_id IS NOT NULL
          AND TRIM(material_id) <> ''
    ) click_event
    INNER JOIN
    (
        SELECT * FROM final_check
    ) final_check
      ON click_event.date_p = final_check.date_p
     AND click_event.gid = final_check.gid
     AND click_event.trace_info = final_check.trace_info
     AND click_event.filter_round_no = final_check.filter_round_no
     AND click_event.event_ts <= final_check.final_check_ts
),
last_click_before_check AS
(
    SELECT
        date_p,
        gid,
        trace_info,
        filter_round_no,
        material_id AS last_click_material_id
    FROM click_before_check_ranked
    WHERE click_rn = 1
),
checked_material_seen AS
(
    SELECT
        click_event.date_p,
        click_event.gid,
        click_event.trace_info,
        click_event.filter_round_no,
        MAX(CASE
            WHEN click_event.material_id = final_check.final_check_material_id
                THEN 1 ELSE 0
        END) AS checked_material_was_clicked
    FROM
    (
        SELECT *
        FROM round_event
        WHERE is_filter_click = 1
          AND material_id IS NOT NULL
          AND TRIM(material_id) <> ''
    ) click_event
    INNER JOIN
    (
        SELECT * FROM final_check
    ) final_check
      ON click_event.date_p = final_check.date_p
     AND click_event.gid = final_check.gid
     AND click_event.trace_info = final_check.trace_info
     AND click_event.filter_round_no = final_check.filter_round_no
     AND click_event.event_ts <= final_check.final_check_ts
    GROUP BY click_event.date_p, click_event.gid,
             click_event.trace_info, click_event.filter_round_no
),
profile AS
(
    SELECT
        date_p,
        gid,
        MAX(country) AS country
    FROM stat_ab.filing_odz_active_user_profile
    WHERE date_p BETWEEN 20260701 AND 20260731
    GROUP BY date_p, gid
),
round_metrics AS
(
    SELECT
        round_base.date_p,
        round_base.gid,
        round_base.trace_info,
        round_base.filter_round_no,
        round_base.os_type,
        profile.country,
        COALESCE(exposure_stats.exposure_pv, 0) AS exposure_pv,
        COALESCE(exposure_stats.distinct_exposure_materials, 0)
            AS distinct_exposure_materials,
        COALESCE(click_stats.click_pv, 0) AS click_pv,
        COALESCE(click_stats.distinct_click_materials, 0)
            AS distinct_click_materials,
        COALESCE(click_stats.max_same_material_clicks, 0)
            AS max_same_material_clicks,
        COALESCE(click_stats.has_repeat_click, 0) AS has_repeat_click,
        CASE WHEN final_check.final_check_ts IS NOT NULL THEN 1 ELSE 0 END AS has_check,
        CASE
            WHEN final_check.final_check_ts IS NULL THEN 'NO_CHECK'
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
     AND round_base.trace_info = exposure_stats.trace_info
     AND round_base.filter_round_no = exposure_stats.filter_round_no
    LEFT JOIN
    (
        SELECT * FROM click_stats
    ) click_stats
      ON round_base.date_p = click_stats.date_p
     AND round_base.gid = click_stats.gid
     AND round_base.trace_info = click_stats.trace_info
     AND round_base.filter_round_no = click_stats.filter_round_no
    LEFT JOIN
    (
        SELECT * FROM final_check
    ) final_check
      ON round_base.date_p = final_check.date_p
     AND round_base.gid = final_check.gid
     AND round_base.trace_info = final_check.trace_info
     AND round_base.filter_round_no = final_check.filter_round_no
    LEFT JOIN
    (
        SELECT * FROM last_click_before_check
    ) last_click_before_check
      ON round_base.date_p = last_click_before_check.date_p
     AND round_base.gid = last_click_before_check.gid
     AND round_base.trace_info = last_click_before_check.trace_info
     AND round_base.filter_round_no = last_click_before_check.filter_round_no
    LEFT JOIN
    (
        SELECT * FROM checked_material_seen
    ) checked_material_seen
      ON round_base.date_p = checked_material_seen.date_p
     AND round_base.gid = checked_material_seen.gid
     AND round_base.trace_info = checked_material_seen.trace_info
     AND round_base.filter_round_no = checked_material_seen.filter_round_no
    LEFT JOIN
    (
        SELECT * FROM profile
    ) profile
      ON round_base.date_p = profile.date_p
     AND round_base.gid = profile.gid
),
market_round_metrics AS
(
    SELECT
        'Overall' AS market,
        date_p,
        gid,
        distinct_exposure_materials,
        distinct_click_materials,
        max_same_material_clicks,
        has_repeat_click,
        has_check,
        check_relation
    FROM round_metrics

    UNION ALL

    SELECT
        'Brazil' AS market,
        date_p,
        gid,
        distinct_exposure_materials,
        distinct_click_materials,
        max_same_material_clicks,
        has_repeat_click,
        has_check,
        check_relation
    FROM round_metrics
    WHERE LOWER(COALESCE(country, '')) IN ('brazil', '巴西')
)
SELECT
    'SUMMARY' AS record_type,
    market,
    'ALL' AS dimension_value,
    COUNT(DISTINCT CONCAT(CAST(date_p AS STRING), '#', CAST(gid AS STRING)))
        AS filter_user_day_count,
    COUNT(1) AS filter_enter_round_count,
    SUM(distinct_exposure_materials) AS total_distinct_exposure_materials,
    SUM(distinct_click_materials) AS total_distinct_click_materials,
    SUM(CASE WHEN distinct_click_materials > 0 THEN 1 ELSE 0 END) AS clicked_round_count,
    SUM(has_check) AS checked_round_count,
    SUM(has_repeat_click) AS repeat_click_round_count
FROM market_round_metrics
GROUP BY market

UNION ALL

SELECT
    'CLICK_DEPTH' AS record_type,
    market,
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
FROM market_round_metrics
GROUP BY
    market,
    CASE
        WHEN distinct_click_materials >= 20 THEN '20+'
        ELSE CAST(distinct_click_materials AS STRING)
    END

UNION ALL

SELECT
    'CHECK_RELATION' AS record_type,
    market,
    check_relation AS dimension_value,
    CAST(NULL AS BIGINT) AS filter_user_day_count,
    COUNT(1) AS filter_enter_round_count,
    SUM(distinct_exposure_materials) AS total_distinct_exposure_materials,
    SUM(distinct_click_materials) AS total_distinct_click_materials,
    SUM(CASE WHEN distinct_click_materials > 0 THEN 1 ELSE 0 END) AS clicked_round_count,
    SUM(has_check) AS checked_round_count,
    SUM(has_repeat_click) AS repeat_click_round_count
FROM market_round_metrics
GROUP BY market, check_relation

UNION ALL

SELECT
    'REPEAT_DEPTH' AS record_type,
    market,
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
FROM market_round_metrics
GROUP BY
    market,
    CASE
        WHEN max_same_material_clicks >= 4 THEN '4+'
        ELSE CAST(max_same_material_clicks AS STRING)
    END
;
