-- AirBrush / 2026-06 / 巴西
-- 口径同整体优化版；事件按 gid + date_p 关联当日活跃表确定国家。
SELECT
    '巴西' AS market_name,
    date_p,
    SUM(adjust_enter) AS adjust_enter,
    SUM(brightness_enter) AS brightness_enter,
    SUM(brightness_used) AS brightness_used,
    SUM(highlights_enter) AS highlights_enter,
    SUM(highlights_used) AS highlights_used,
    SUM(shadows_enter) AS shadows_enter,
    SUM(shadows_used) AS shadows_used,
    SUM(contrast_enter) AS contrast_enter,
    SUM(contrast_used) AS contrast_used,
    SUM(saturation_enter) AS saturation_enter,
    SUM(saturation_used) AS saturation_used,
    SUM(sharpness_enter) AS sharpness_enter,
    SUM(sharpness_used) AS sharpness_used,
    SUM(temperature_enter) AS temperature_enter,
    SUM(temperature_used) AS temperature_used,
    SUM(auto_enter) AS auto_enter,
    SUM(auto_used) AS auto_used,
    SUM(flash_enter) AS flash_enter,
    SUM(flash_used) AS flash_used,
    SUM(grain_enter) AS grain_enter,
    SUM(grain_used) AS grain_used,
    SUM(fade_enter) AS fade_enter,
    SUM(fade_used) AS fade_used,
    SUM(deglare_enter) AS deglare_enter,
    SUM(deglare_used) AS deglare_used,
    SUM(vignette_enter) AS vignette_enter,
    SUM(vignette_used) AS vignette_used
FROM (
    SELECT
        e.date_p,
        e.gid,
        MAX(CASE WHEN e.event_id = 'second_func_enter' THEN 1 ELSE 0 END)
            AS adjust_enter,
        MAX(CASE WHEN e.event_id = 'third_func_enter'
                      AND LOWER(TRIM(NVL(e.params['third_func'], ''))) = 'brightness'
                 THEN 1 ELSE 0 END) AS brightness_enter,
        MAX(CASE WHEN e.event_id = 'second_func_use'
                      AND CAST(TRIM(NVL(e.params['brightness_stat'], '')) AS DOUBLE) <> 0
                 THEN 1 ELSE 0 END) AS brightness_used,
        MAX(CASE WHEN e.event_id = 'third_func_enter'
                      AND LOWER(TRIM(NVL(e.params['third_func'], ''))) = 'highlights'
                 THEN 1 ELSE 0 END) AS highlights_enter,
        MAX(CASE WHEN e.event_id = 'second_func_use'
                      AND CAST(TRIM(NVL(e.params['highlights_stat'], '')) AS DOUBLE) <> 0
                 THEN 1 ELSE 0 END) AS highlights_used,
        MAX(CASE WHEN e.event_id = 'third_func_enter'
                      AND LOWER(TRIM(NVL(e.params['third_func'], ''))) = 'shadows'
                 THEN 1 ELSE 0 END) AS shadows_enter,
        MAX(CASE WHEN e.event_id = 'second_func_use'
                      AND CAST(TRIM(NVL(e.params['shadows_stat'], '')) AS DOUBLE) <> 0
                 THEN 1 ELSE 0 END) AS shadows_used,
        MAX(CASE WHEN e.event_id = 'third_func_enter'
                      AND LOWER(TRIM(NVL(e.params['third_func'], ''))) = 'contrast'
                 THEN 1 ELSE 0 END) AS contrast_enter,
        MAX(CASE WHEN e.event_id = 'second_func_use'
                      AND CAST(TRIM(NVL(e.params['contrast_stat'], '')) AS DOUBLE) <> 0
                 THEN 1 ELSE 0 END) AS contrast_used,
        MAX(CASE WHEN e.event_id = 'third_func_enter'
                      AND LOWER(TRIM(NVL(e.params['third_func'], ''))) = 'saturation'
                 THEN 1 ELSE 0 END) AS saturation_enter,
        MAX(CASE WHEN e.event_id = 'second_func_use'
                      AND CAST(TRIM(NVL(e.params['saturation_stat'], '')) AS DOUBLE) <> 0
                 THEN 1 ELSE 0 END) AS saturation_used,
        MAX(CASE WHEN e.event_id = 'third_func_enter'
                      AND LOWER(TRIM(NVL(e.params['third_func'], ''))) = 'sharpness'
                 THEN 1 ELSE 0 END) AS sharpness_enter,
        MAX(CASE WHEN e.event_id = 'second_func_use'
                      AND CAST(TRIM(NVL(e.params['sharpness_stat'], '')) AS DOUBLE) <> 0
                 THEN 1 ELSE 0 END) AS sharpness_used,
        MAX(CASE WHEN e.event_id = 'third_func_enter'
                      AND LOWER(TRIM(NVL(e.params['third_func'], ''))) = 'temperature'
                 THEN 1 ELSE 0 END) AS temperature_enter,
        MAX(CASE WHEN e.event_id = 'second_func_use'
                      AND CAST(TRIM(NVL(e.params['temperature_stat'], '')) AS DOUBLE) <> 0
                 THEN 1 ELSE 0 END) AS temperature_used,
        MAX(CASE WHEN e.event_id = 'third_func_enter'
                      AND LOWER(TRIM(NVL(e.params['third_func'], ''))) = 'auto'
                 THEN 1 ELSE 0 END) AS auto_enter,
        MAX(CASE WHEN e.event_id = 'second_func_use'
                      AND TRIM(NVL(e.params['ai_auto'], '')) = '1'
                 THEN 1 ELSE 0 END) AS auto_used,
        MAX(CASE WHEN e.event_id = 'third_func_enter'
                      AND LOWER(TRIM(NVL(e.params['third_func'], ''))) = 'flash'
                 THEN 1 ELSE 0 END) AS flash_enter,
        MAX(CASE WHEN e.event_id = 'second_func_use'
                      AND CAST(TRIM(NVL(e.params['flash_stat'], '')) AS DOUBLE) <> 0
                 THEN 1 ELSE 0 END) AS flash_used,
        MAX(CASE WHEN e.event_id = 'third_func_enter'
                      AND LOWER(TRIM(NVL(e.params['third_func'], ''))) = 'grain'
                 THEN 1 ELSE 0 END) AS grain_enter,
        MAX(CASE WHEN e.event_id = 'second_func_use'
                      AND CAST(TRIM(NVL(e.params['grain_stat'], '')) AS DOUBLE) <> 0
                 THEN 1 ELSE 0 END) AS grain_used,
        MAX(CASE WHEN e.event_id = 'third_func_enter'
                      AND LOWER(TRIM(NVL(e.params['third_func'], ''))) = 'fade'
                 THEN 1 ELSE 0 END) AS fade_enter,
        MAX(CASE WHEN e.event_id = 'second_func_use'
                      AND CAST(TRIM(NVL(e.params['fade_stat'], '')) AS DOUBLE) <> 0
                 THEN 1 ELSE 0 END) AS fade_used,
        MAX(CASE WHEN e.event_id = 'third_func_enter'
                      AND LOWER(TRIM(NVL(e.params['third_func'], ''))) = 'deglare'
                 THEN 1 ELSE 0 END) AS deglare_enter,
        MAX(CASE WHEN e.event_id = 'second_func_use'
                      AND CAST(TRIM(NVL(e.params['deglare_stat'], '')) AS DOUBLE) <> 0
                 THEN 1 ELSE 0 END) AS deglare_used,
        MAX(CASE WHEN e.event_id = 'third_func_enter'
                      AND LOWER(TRIM(NVL(e.params['third_func'], ''))) = 'vignette'
                 THEN 1 ELSE 0 END) AS vignette_enter,
        MAX(CASE WHEN e.event_id = 'second_func_use'
                      AND CAST(TRIM(NVL(e.params['vignette_stat'], '')) AS DOUBLE) <> 0
                 THEN 1 ELSE 0 END) AS vignette_used
    FROM (
        SELECT
            ev.date_p,
            ev.gid,
            ev.params,
            ev.event_id
        FROM (
            SELECT
                date_p,
                gid,
                params,
                event_id
            FROM stat_sdk.sdk_odz_source_data
            WHERE date_p BETWEEN 20260604 AND 20260605
              AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
              AND event_id IN ('second_func_enter', 'third_func_enter', 'second_func_use')
              AND LOWER(TRIM(NVL(params['second_func'], ''))) = 'adjust'
        ) ev
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
                WHERE date_p BETWEEN 20260604 AND 20260605
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
          ON ev.date_p = brazil_user.date_p
         AND ev.gid = brazil_user.gid
    ) e
    GROUP BY
        e.date_p,
        e.gid
) user_day
GROUP BY
    date_p
