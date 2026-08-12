-- AirBrush / 2026-06 / 整体
-- 精确日均口径优化版：先按 date_p + gid 汇总 0/1 标记，再按日期求和。
-- 避免 LATERAL VIEW 将原始事件放大 15 倍。
SELECT
    '整体' AS market_name,
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
    FROM stat_sdk.sdk_odz_source_data e
    WHERE e.date_p BETWEEN 20260626 AND 20260628
      AND e.app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
      AND e.event_id IN ('second_func_enter', 'third_func_enter', 'second_func_use')
      AND LOWER(TRIM(NVL(e.params['second_func'], ''))) = 'adjust'
    GROUP BY
        e.date_p,
        e.gid
) user_day
GROUP BY
    date_p
