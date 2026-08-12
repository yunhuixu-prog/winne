-- AirBrush / 整体 / 2026-06
-- 与巴西查询完全一致：每条 Adjust 打勾事件为一次观察，
-- 滑杆值非空且不等于 0、或 ai_auto=1，记为使用 1 个子项。
SELECT
    adjust_event.used_subfunc_count,
    COUNT(1) AS event_count
FROM (
    SELECT
        (
            CASE WHEN CAST(TRIM(NVL(e.params['contrast_stat'], '0')) AS DOUBLE) <> 0 THEN 1 ELSE 0 END
          + CASE WHEN CAST(TRIM(NVL(e.params['sharpness_stat'], '0')) AS DOUBLE) <> 0 THEN 1 ELSE 0 END
          + CASE WHEN CAST(TRIM(NVL(e.params['saturation_stat'], '0')) AS DOUBLE) <> 0 THEN 1 ELSE 0 END
          + CASE WHEN CAST(TRIM(NVL(e.params['highlights_stat'], '0')) AS DOUBLE) <> 0 THEN 1 ELSE 0 END
          + CASE WHEN CAST(TRIM(NVL(e.params['shadows_stat'], '0')) AS DOUBLE) <> 0 THEN 1 ELSE 0 END
          + CASE WHEN CAST(TRIM(NVL(e.params['brightness_stat'], '0')) AS DOUBLE) <> 0 THEN 1 ELSE 0 END
          + CASE WHEN CAST(TRIM(NVL(e.params['temperature_stat'], '0')) AS DOUBLE) <> 0 THEN 1 ELSE 0 END
          + CASE WHEN CAST(TRIM(NVL(e.params['fade_stat'], '0')) AS DOUBLE) <> 0 THEN 1 ELSE 0 END
          + CASE WHEN CAST(TRIM(NVL(e.params['grain_stat'], '0')) AS DOUBLE) <> 0 THEN 1 ELSE 0 END
          + CASE WHEN TRIM(NVL(e.params['ai_auto'], '0')) = '1' THEN 1 ELSE 0 END
          + CASE WHEN CAST(TRIM(NVL(e.params['vignette_stat'], '0')) AS DOUBLE) <> 0 THEN 1 ELSE 0 END
          + CASE WHEN CAST(TRIM(NVL(e.params['deglare_stat'], '0')) AS DOUBLE) <> 0 THEN 1 ELSE 0 END
          + CASE WHEN CAST(TRIM(NVL(e.params['flash_stat'], '0')) AS DOUBLE) <> 0 THEN 1 ELSE 0 END
        ) AS used_subfunc_count
    FROM stat_sdk.sdk_odz_source_data e
    WHERE e.date_p BETWEEN 20260601 AND 20260630
      AND e.app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
      AND e.event_id = 'second_func_use'
      AND LOWER(TRIM(NVL(e.params['second_func'], ''))) = 'adjust'
) adjust_event
GROUP BY
    adjust_event.used_subfunc_count
ORDER BY
    adjust_event.used_subfunc_count
