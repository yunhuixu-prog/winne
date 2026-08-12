-- AirBrush / 2026-06 / 巴西、美国、英国、墨西哥
-- 口径同“Adjust子项及滑杆值分布_整体_202606.sql”。
-- 事件按 gid + date_p 关联当日活跃表确定国家，避免跨日国家漂移。
-- ENTER 为 third_func_enter 的具体子功能进入；其余行来自 second_func_use。
SELECT
    e.market_name,
    s.parameter_name,
    s.row_type,
    s.raw_value,
    COUNT(DISTINCT e.gid) AS user_count,
    COUNT(1) AS event_count
FROM (
    SELECT
        ev.date_p,
        ev.gid,
        ev.params,
        ev.event_id,
        target_user.market_name
    FROM (
        SELECT
            date_p,
            gid,
            params,
            event_id
        FROM stat_sdk.sdk_odz_source_data
        WHERE date_p BETWEEN 20260601 AND 20260630
          AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
          AND event_id IN ('second_func_use', 'third_func_enter')
          AND LOWER(TRIM(NVL(params['second_func'], ''))) = 'adjust'
    ) ev
    INNER JOIN (
        SELECT
            active_user.date_p,
            active_user.final_id AS gid,
            target_country.name AS market_name
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
            SELECT DISTINCT
                id,
                name
            FROM stat_sdk.dim_rna_ip_location
            WHERE date_p = 20260630
              AND level = '1'
              AND name IN ('巴西', '美国', '英国', '墨西哥')
        ) target_country
          ON active_user.country_id = target_country.id
        GROUP BY
            active_user.date_p,
            active_user.final_id,
            target_country.name
    ) target_user
      ON ev.date_p = target_user.date_p
     AND ev.gid = target_user.gid
) e
LATERAL VIEW STACK(
    28,
    CASE WHEN e.event_id = 'third_func_enter'
              AND TRIM(NVL(e.params['third_func'], '')) <> ''
         THEN LOWER(TRIM(e.params['third_func'])) END,
        'ENTER',
        CASE WHEN e.event_id = 'third_func_enter'
                  AND TRIM(NVL(e.params['third_func'], '')) <> ''
             THEN 'ENTER' END,
    '__TOTAL__', 'TOTAL',
        CASE WHEN e.event_id = 'second_func_use' THEN 'ALL' END,
    'contrast', 'USED',
        CASE WHEN CAST(TRIM(NVL(e.params['contrast_stat'], '')) AS DOUBLE) <> 0
             THEN 'USED' END,
    'contrast', 'VALUE',
        CASE WHEN TRIM(NVL(e.params['contrast_stat'], '')) <> ''
             THEN TRIM(e.params['contrast_stat']) END,
    'sharpness', 'USED',
        CASE WHEN CAST(TRIM(NVL(e.params['sharpness_stat'], '')) AS DOUBLE) <> 0
             THEN 'USED' END,
    'sharpness', 'VALUE',
        CASE WHEN TRIM(NVL(e.params['sharpness_stat'], '')) <> ''
             THEN TRIM(e.params['sharpness_stat']) END,
    'saturation', 'USED',
        CASE WHEN CAST(TRIM(NVL(e.params['saturation_stat'], '')) AS DOUBLE) <> 0
             THEN 'USED' END,
    'saturation', 'VALUE',
        CASE WHEN TRIM(NVL(e.params['saturation_stat'], '')) <> ''
             THEN TRIM(e.params['saturation_stat']) END,
    'highlights', 'USED',
        CASE WHEN CAST(TRIM(NVL(e.params['highlights_stat'], '')) AS DOUBLE) <> 0
             THEN 'USED' END,
    'highlights', 'VALUE',
        CASE WHEN TRIM(NVL(e.params['highlights_stat'], '')) <> ''
             THEN TRIM(e.params['highlights_stat']) END,
    'shadows', 'USED',
        CASE WHEN CAST(TRIM(NVL(e.params['shadows_stat'], '')) AS DOUBLE) <> 0
             THEN 'USED' END,
    'shadows', 'VALUE',
        CASE WHEN TRIM(NVL(e.params['shadows_stat'], '')) <> ''
             THEN TRIM(e.params['shadows_stat']) END,
    'brightness', 'USED',
        CASE WHEN CAST(TRIM(NVL(e.params['brightness_stat'], '')) AS DOUBLE) <> 0
             THEN 'USED' END,
    'brightness', 'VALUE',
        CASE WHEN TRIM(NVL(e.params['brightness_stat'], '')) <> ''
             THEN TRIM(e.params['brightness_stat']) END,
    'temperature', 'USED',
        CASE WHEN CAST(TRIM(NVL(e.params['temperature_stat'], '')) AS DOUBLE) <> 0
             THEN 'USED' END,
    'temperature', 'VALUE',
        CASE WHEN TRIM(NVL(e.params['temperature_stat'], '')) <> ''
             THEN TRIM(e.params['temperature_stat']) END,
    'fade', 'USED',
        CASE WHEN CAST(TRIM(NVL(e.params['fade_stat'], '')) AS DOUBLE) <> 0
             THEN 'USED' END,
    'fade', 'VALUE',
        CASE WHEN TRIM(NVL(e.params['fade_stat'], '')) <> ''
             THEN TRIM(e.params['fade_stat']) END,
    'grain', 'USED',
        CASE WHEN CAST(TRIM(NVL(e.params['grain_stat'], '')) AS DOUBLE) <> 0
             THEN 'USED' END,
    'grain', 'VALUE',
        CASE WHEN TRIM(NVL(e.params['grain_stat'], '')) <> ''
             THEN TRIM(e.params['grain_stat']) END,
    'ai_auto', 'USED',
        CASE WHEN TRIM(NVL(e.params['ai_auto'], '')) = '1'
             THEN 'USED' END,
    'ai_auto', 'VALUE',
        CASE WHEN TRIM(NVL(e.params['ai_auto'], '')) <> ''
             THEN LOWER(TRIM(e.params['ai_auto'])) END,
    'vignette', 'USED',
        CASE WHEN CAST(TRIM(NVL(e.params['vignette_stat'], '')) AS DOUBLE) <> 0
             THEN 'USED' END,
    'vignette', 'VALUE',
        CASE WHEN TRIM(NVL(e.params['vignette_stat'], '')) <> ''
             THEN TRIM(e.params['vignette_stat']) END,
    'deglare', 'USED',
        CASE WHEN CAST(TRIM(NVL(e.params['deglare_stat'], '')) AS DOUBLE) <> 0
             THEN 'USED' END,
    'deglare', 'VALUE',
        CASE WHEN TRIM(NVL(e.params['deglare_stat'], '')) <> ''
             THEN TRIM(e.params['deglare_stat']) END,
    'flash', 'USED',
        CASE WHEN CAST(TRIM(NVL(e.params['flash_stat'], '')) AS DOUBLE) <> 0
             THEN 'USED' END,
    'flash', 'VALUE',
        CASE WHEN TRIM(NVL(e.params['flash_stat'], '')) <> ''
             THEN TRIM(e.params['flash_stat']) END
) s AS parameter_name, row_type, raw_value
WHERE s.raw_value IS NOT NULL
GROUP BY
    e.market_name,
    s.parameter_name,
    s.row_type,
    s.raw_value
