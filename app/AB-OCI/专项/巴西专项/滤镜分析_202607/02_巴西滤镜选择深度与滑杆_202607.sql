-- AirBrush OCI｜巴西滤镜专项｜编辑会话路径与选择深度
-- 分析期：2026-07-01～2026-07-31
-- 建议引擎：Hive on Spark
--
-- 编辑会话口径：date_p + gid + trace_info。
-- 最终选择：同一编辑会话内最后一次 Filters material_check。
-- 整段浏览：同一 trace_info 内、最终打勾前的全部 Filters 点击。
-- 最后一轮浏览：同一 trace_info 内、最后一次 first_func_enter(filters)
--              到最终打勾之间的点击。
-- 最终结果：同一 trace_info 内、最终打勾之后的保存和订阅事件。
--
-- 实现说明：原方案将最终打勾表回连整段事件，产生大规模中间结果；
-- 本版只扫描一次原始事件，用窗口函数在 trace 内广播最终打勾时间和最近进入时间，
-- 业务口径保持不变。滑杆分布另见 02B SQL。

WITH raw_event AS
(
    SELECT
        raw.date_p,
        raw.gid,
        TRIM(raw.params['trace_info']) AS trace_info,
        raw.os_type,
        raw.event_id,
        CAST(raw.`time` AS BIGINT) AS event_ts,
        LOWER(TRIM(raw.params['first_func'])) AS first_func,
        LOWER(TRIM(raw.params['material_type'])) AS material_type,
        CASE
            WHEN raw.event_id = 'material_check'
                THEN REGEXP_EXTRACT(raw.params['mids_material_id'], '^([^,]+)', 1)
            ELSE raw.params['material_id']
        END AS material_id,
        CASE
            WHEN raw.event_id = 'material_check'
             AND raw.params['module'] = 'edit'
             AND LOWER(TRIM(raw.params['material_type'])) = 'filters'
             AND raw.params['mids_material_id'] IS NOT NULL
                THEN 1 ELSE 0
        END AS is_filter_check,
        CASE
            WHEN raw.event_id = 'first_func_enter'
             AND LOWER(TRIM(raw.params['first_func'])) = 'filters'
                THEN 1 ELSE 0
        END AS is_filter_enter,
        CASE
            WHEN raw.event_id = 'material_click'
             AND LOWER(TRIM(raw.params['material_type'])) = 'filters'
                THEN 1 ELSE 0
        END AS is_filter_click
    FROM stat_sdk.sdk_odz_source_data raw
    WHERE raw.date_p BETWEEN 20260701 AND 20260731
      AND raw.app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
      AND raw.event_id IN (
          'first_func_enter',
          'material_click',
          'material_check',
          'edit_save',
          'w_subscription_enter',
          'w_subscription_click',
          'w_subscription_success'
      )
      AND (
          (raw.event_id = 'first_func_enter'
           AND LOWER(TRIM(raw.params['first_func'])) = 'filters')
          OR (raw.event_id = 'material_click'
              AND LOWER(TRIM(raw.params['material_type'])) = 'filters')
          OR (raw.event_id = 'material_check'
              AND raw.params['module'] = 'edit'
              AND LOWER(TRIM(raw.params['material_type'])) = 'filters'
              AND raw.params['mids_material_id'] IS NOT NULL)
          OR raw.event_id IN (
              'edit_save',
              'w_subscription_enter',
              'w_subscription_click',
              'w_subscription_success'
          )
      )
      AND raw.gid IS NOT NULL
      AND raw.params['trace_info'] IS NOT NULL
      AND TRIM(raw.params['trace_info']) <> ''
),
sequenced_1 AS
(
    SELECT
        raw_event.*,
        MAX(CASE WHEN is_filter_check = 1 THEN event_ts END) OVER (
            PARTITION BY date_p, gid, trace_info
        ) AS final_check_ts,
        SUM(is_filter_check) OVER (
            PARTITION BY date_p, gid, trace_info
        ) AS filter_check_pv_in_trace,
        MAX(CASE WHEN is_filter_enter = 1 THEN event_ts END) OVER (
            PARTITION BY date_p, gid, trace_info
            ORDER BY event_ts
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS last_filter_enter_so_far
    FROM raw_event
),
sequenced_2 AS
(
    SELECT
        sequenced_1.*,
        MAX(CASE
            WHEN is_filter_check = 1 AND event_ts = final_check_ts
                THEN last_filter_enter_so_far
        END) OVER (
            PARTITION BY date_p, gid, trace_info
        ) AS final_filter_enter_ts
    FROM sequenced_1
    WHERE final_check_ts IS NOT NULL
),
trace_summary AS
(
    SELECT
        date_p,
        gid,
        trace_info,
        MAX(os_type) AS os_type,
        MAX(final_check_ts) AS final_check_ts,
        MAX(final_filter_enter_ts) AS final_filter_enter_ts,
        MAX(filter_check_pv_in_trace) AS filter_check_pv_in_trace,
        CASE WHEN MAX(final_filter_enter_ts) IS NOT NULL THEN 1 ELSE 0 END AS has_filter_enter,
        SUM(CASE
            WHEN is_filter_enter = 1 AND event_ts <= final_check_ts THEN 1 ELSE 0
        END) AS filter_enter_pv_before_check,
        SUM(CASE
            WHEN is_filter_click = 1 AND event_ts <= final_check_ts THEN 1 ELSE 0
        END) AS trace_click_pv_before_check,
        COUNT(DISTINCT CASE
            WHEN is_filter_click = 1 AND event_ts <= final_check_ts THEN material_id
        END) AS trace_distinct_click_materials_before_check,
        SUM(CASE
            WHEN is_filter_click = 1
             AND final_filter_enter_ts IS NOT NULL
             AND event_ts BETWEEN final_filter_enter_ts AND final_check_ts
                THEN 1 ELSE 0
        END) AS round_click_pv,
        COUNT(DISTINCT CASE
            WHEN is_filter_click = 1
             AND final_filter_enter_ts IS NOT NULL
             AND event_ts BETWEEN final_filter_enter_ts AND final_check_ts
                THEN material_id
        END) AS round_distinct_click_materials,
        CASE WHEN MAX(CASE
            WHEN event_id = 'edit_save' AND event_ts >= final_check_ts THEN 1 ELSE 0
        END) = 1 THEN 1 ELSE 0 END AS has_save_after_check,
        MIN(CASE
            WHEN event_id = 'edit_save' AND event_ts >= final_check_ts
                THEN event_ts - final_check_ts
        END) AS check_to_save_ms,
        MAX(CASE
            WHEN event_id = 'w_subscription_enter' AND event_ts >= final_check_ts
                THEN 1 ELSE 0
        END) AS has_subscription_enter_after_check,
        MAX(CASE
            WHEN event_id = 'w_subscription_click' AND event_ts >= final_check_ts
                THEN 1 ELSE 0
        END) AS has_subscription_click_after_check,
        MAX(CASE
            WHEN event_id = 'w_subscription_success' AND event_ts >= final_check_ts
                THEN 1 ELSE 0
        END) AS has_subscription_success_after_check
    FROM sequenced_2
    GROUP BY date_p, gid, trace_info
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
    WHERE date_p BETWEEN 20260701 AND 20260731
    GROUP BY date_p, gid
),
enriched AS
(
    SELECT
        CASE WHEN LOWER(COALESCE(profile.country, '')) IN ('巴西', 'brazil')
             THEN 'Brazil' ELSE 'Other' END AS country_group,
        COALESCE(profile.os_type, trace_summary.os_type, '未知') AS os_type,
        COALESCE(profile.is_new, 'Unknown') AS is_new,
        CASE
            WHEN profile.is_new = 'New' THEN COALESCE(profile.is_ua, 'Unknown')
            ELSE 'Not Applicable'
        END AS is_ua,
        CASE
            WHEN profile.first_launch_date IS NULL THEN 'Unknown'
            WHEN meitu_datediff(trace_summary.date_p, profile.first_launch_date) = 0 THEN 'D0'
            WHEN meitu_datediff(trace_summary.date_p, profile.first_launch_date) BETWEEN 1 AND 3 THEN 'D1-3'
            WHEN meitu_datediff(trace_summary.date_p, profile.first_launch_date) BETWEEN 4 AND 7 THEN 'D4-7'
            WHEN meitu_datediff(trace_summary.date_p, profile.first_launch_date) BETWEEN 8 AND 30 THEN 'D8-30'
            WHEN meitu_datediff(trace_summary.date_p, profile.first_launch_date) BETWEEN 31 AND 90 THEN 'D31-90'
            WHEN meitu_datediff(trace_summary.date_p, profile.first_launch_date) > 90 THEN 'D91+'
            ELSE 'Unknown'
        END AS install_age_bucket,
        CASE WHEN profile.is_subscribed = 1 THEN 'Paying' ELSE 'Un-Paying' END AS pay_status,
        trace_summary.final_check_ts,
        trace_summary.final_filter_enter_ts,
        trace_summary.filter_check_pv_in_trace,
        trace_summary.has_filter_enter,
        trace_summary.filter_enter_pv_before_check,
        trace_summary.trace_click_pv_before_check,
        trace_summary.trace_distinct_click_materials_before_check,
        trace_summary.round_click_pv,
        trace_summary.round_distinct_click_materials,
        trace_summary.has_save_after_check,
        trace_summary.check_to_save_ms,
        trace_summary.has_subscription_enter_after_check,
        trace_summary.has_subscription_click_after_check,
        trace_summary.has_subscription_success_after_check
    FROM
    (
        SELECT * FROM trace_summary
    ) trace_summary
    LEFT JOIN
    (
        SELECT * FROM profile
    ) profile
      ON trace_summary.date_p = profile.date_p
     AND trace_summary.gid = profile.gid
)
SELECT
    country_group,
    os_type,
    is_new,
    is_ua,
    install_age_bucket,
    pay_status,
    has_filter_enter,
    CASE WHEN filter_enter_pv_before_check >= 10 THEN 10 ELSE filter_enter_pv_before_check END
        AS filter_enter_pv_capped,
    CASE WHEN filter_check_pv_in_trace >= 10 THEN 10 ELSE filter_check_pv_in_trace END
        AS filter_check_pv_capped,
    CASE WHEN trace_click_pv_before_check >= 20 THEN 20 ELSE trace_click_pv_before_check END
        AS trace_click_pv_capped,
    CASE WHEN trace_distinct_click_materials_before_check >= 20 THEN 20
         ELSE trace_distinct_click_materials_before_check END
        AS trace_distinct_click_materials_capped,
    CASE WHEN round_click_pv >= 20 THEN 20 ELSE round_click_pv END AS round_click_pv_capped,
    CASE WHEN round_distinct_click_materials >= 20 THEN 20 ELSE round_distinct_click_materials END
        AS round_distinct_click_materials_capped,
    CASE
        WHEN has_filter_enter = 0 THEN 'Unknown'
        WHEN final_check_ts - final_filter_enter_ts < 5000 THEN '0-5s'
        WHEN final_check_ts - final_filter_enter_ts < 15000 THEN '5-15s'
        WHEN final_check_ts - final_filter_enter_ts < 30000 THEN '15-30s'
        WHEN final_check_ts - final_filter_enter_ts < 60000 THEN '30-60s'
        WHEN final_check_ts - final_filter_enter_ts < 180000 THEN '60-180s'
        ELSE '180s+'
    END AS entry_to_check_bucket,
    has_save_after_check,
    CASE
        WHEN has_save_after_check = 0 THEN 'No Save'
        WHEN check_to_save_ms < 5000 THEN '0-5s'
        WHEN check_to_save_ms < 15000 THEN '5-15s'
        WHEN check_to_save_ms < 30000 THEN '15-30s'
        WHEN check_to_save_ms < 60000 THEN '30-60s'
        WHEN check_to_save_ms < 180000 THEN '60-180s'
        ELSE '180s+'
    END AS check_to_save_bucket,
    has_subscription_enter_after_check,
    has_subscription_click_after_check,
    has_subscription_success_after_check,
    CAST(COUNT(1) AS BIGINT) AS edit_trace_count
FROM enriched
GROUP BY
    country_group,
    os_type,
    is_new,
    is_ua,
    install_age_bucket,
    pay_status,
    has_filter_enter,
    CASE WHEN filter_enter_pv_before_check >= 10 THEN 10 ELSE filter_enter_pv_before_check END,
    CASE WHEN filter_check_pv_in_trace >= 10 THEN 10 ELSE filter_check_pv_in_trace END,
    CASE WHEN trace_click_pv_before_check >= 20 THEN 20 ELSE trace_click_pv_before_check END,
    CASE WHEN trace_distinct_click_materials_before_check >= 20 THEN 20
         ELSE trace_distinct_click_materials_before_check END,
    CASE WHEN round_click_pv >= 20 THEN 20 ELSE round_click_pv END,
    CASE WHEN round_distinct_click_materials >= 20 THEN 20 ELSE round_distinct_click_materials END,
    CASE
        WHEN has_filter_enter = 0 THEN 'Unknown'
        WHEN final_check_ts - final_filter_enter_ts < 5000 THEN '0-5s'
        WHEN final_check_ts - final_filter_enter_ts < 15000 THEN '5-15s'
        WHEN final_check_ts - final_filter_enter_ts < 30000 THEN '15-30s'
        WHEN final_check_ts - final_filter_enter_ts < 60000 THEN '30-60s'
        WHEN final_check_ts - final_filter_enter_ts < 180000 THEN '60-180s'
        ELSE '180s+'
    END,
    has_save_after_check,
    CASE
        WHEN has_save_after_check = 0 THEN 'No Save'
        WHEN check_to_save_ms < 5000 THEN '0-5s'
        WHEN check_to_save_ms < 15000 THEN '5-15s'
        WHEN check_to_save_ms < 30000 THEN '15-30s'
        WHEN check_to_save_ms < 60000 THEN '30-60s'
        WHEN check_to_save_ms < 180000 THEN '60-180s'
        ELSE '180s+'
    END,
    has_subscription_enter_after_check,
    has_subscription_click_after_check,
    has_subscription_success_after_check
;
