-- AirBrush / 2026-06 / 整体
-- 口径：
-- 1. second_func_use：Adjust 打勾及滑杆最终值；
--    third_func_enter：Adjust 各三级子功能进入。
-- 2. ENTER：third_func 进入量；TOTAL：Adjust 打勾总量；
--    USED：参数为非默认值；VALUE：原始上报值。
-- 3. VALUE 下载后再按业务规则分层：有符号项 -100~100、步长5；
--    sharpness/fade/grain/vignette/flash/deglare 0~100、步长5；
--    ai_auto 仅有 0（关闭）、1（开启）、空值。
SELECT
    '整体' AS market_name,
    s.parameter_name,
    s.row_type,
    s.raw_value,
    COUNT(DISTINCT e.gid) AS user_count,
    COUNT(1) AS event_count
FROM stat_sdk.sdk_odz_source_data e
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
WHERE e.date_p BETWEEN 20260601 AND 20260630
  AND e.app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
  AND e.event_id IN ('second_func_use', 'third_func_enter')
  AND LOWER(TRIM(NVL(e.params['second_func'], ''))) = 'adjust'
  AND s.raw_value IS NOT NULL
GROUP BY
    s.parameter_name,
    s.row_type,
    s.raw_value
