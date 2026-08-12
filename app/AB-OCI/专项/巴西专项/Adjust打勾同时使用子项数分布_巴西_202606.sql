-- AirBrush / 巴西 / 2026-06
-- 指标：每次 Adjust 打勾（second_func_use, second_func=adjust）时，
--      同时处于非默认值的子项数量分布。
-- 使用口径沿用既有 Adjust 滑杆分析：
-- 1. 12 个滑杆参数：上报值非空且不等于 0，记为使用；
-- 2. ai_auto：上报值等于 1，记为使用；
-- 3. 一条 second_func_use 事件为一次观察，不按用户去重。
SELECT
    adjust_event.used_subfunc_count,
    COUNT(1) AS event_count
FROM (
    SELECT
        event_base.date_p,
        event_base.gid,
        (
            CASE WHEN CAST(TRIM(NVL(event_base.params['contrast_stat'], '0')) AS DOUBLE) <> 0 THEN 1 ELSE 0 END
          + CASE WHEN CAST(TRIM(NVL(event_base.params['sharpness_stat'], '0')) AS DOUBLE) <> 0 THEN 1 ELSE 0 END
          + CASE WHEN CAST(TRIM(NVL(event_base.params['saturation_stat'], '0')) AS DOUBLE) <> 0 THEN 1 ELSE 0 END
          + CASE WHEN CAST(TRIM(NVL(event_base.params['highlights_stat'], '0')) AS DOUBLE) <> 0 THEN 1 ELSE 0 END
          + CASE WHEN CAST(TRIM(NVL(event_base.params['shadows_stat'], '0')) AS DOUBLE) <> 0 THEN 1 ELSE 0 END
          + CASE WHEN CAST(TRIM(NVL(event_base.params['brightness_stat'], '0')) AS DOUBLE) <> 0 THEN 1 ELSE 0 END
          + CASE WHEN CAST(TRIM(NVL(event_base.params['temperature_stat'], '0')) AS DOUBLE) <> 0 THEN 1 ELSE 0 END
          + CASE WHEN CAST(TRIM(NVL(event_base.params['fade_stat'], '0')) AS DOUBLE) <> 0 THEN 1 ELSE 0 END
          + CASE WHEN CAST(TRIM(NVL(event_base.params['grain_stat'], '0')) AS DOUBLE) <> 0 THEN 1 ELSE 0 END
          + CASE WHEN TRIM(NVL(event_base.params['ai_auto'], '0')) = '1' THEN 1 ELSE 0 END
          + CASE WHEN CAST(TRIM(NVL(event_base.params['vignette_stat'], '0')) AS DOUBLE) <> 0 THEN 1 ELSE 0 END
          + CASE WHEN CAST(TRIM(NVL(event_base.params['deglare_stat'], '0')) AS DOUBLE) <> 0 THEN 1 ELSE 0 END
          + CASE WHEN CAST(TRIM(NVL(event_base.params['flash_stat'], '0')) AS DOUBLE) <> 0 THEN 1 ELSE 0 END
        ) AS used_subfunc_count
    FROM (
        SELECT
            source_event.date_p,
            source_event.gid,
            source_event.params
        FROM (
            SELECT
                date_p,
                gid,
                params
            FROM stat_sdk.sdk_odz_source_data
            WHERE date_p BETWEEN 20260601 AND 20260630
              AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
              AND event_id = 'second_func_use'
              AND LOWER(TRIM(NVL(params['second_func'], ''))) = 'adjust'
        ) source_event
        INNER JOIN (
            SELECT
                active_user.date_p,
                active_user.final_id AS gid
            FROM (
                SELECT
                    date_p,
                    final_id,
                    country_id
                FROM stat_sdk.sdk_odz_active
                WHERE date_p BETWEEN 20260601 AND 20260630
                  AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
                  AND os_p IS NOT NULL
            ) active_user
            INNER JOIN (
                SELECT DISTINCT id
                FROM stat_sdk.dim_rna_ip_location
                WHERE date_p = 20260630
                  AND level = '1'
                  AND name = '巴西'
            ) brazil
              ON active_user.country_id = brazil.id
            GROUP BY
                active_user.date_p,
                active_user.final_id
        ) brazil_user
          ON source_event.date_p = brazil_user.date_p
         AND source_event.gid = brazil_user.gid
    ) event_base
) adjust_event
GROUP BY
    adjust_event.used_subfunc_count
ORDER BY
    adjust_event.used_subfunc_count
