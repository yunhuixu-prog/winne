-- AirBrush / 2026-06 / 整体 / Face-Jaw 原始参数字符串聚合
SELECT
    '整体' AS market_name,
    'Jaw' AS feature_name,
    TRIM(e.params['prf_jaw_mod']) AS raw_mod,
    COUNT(1) AS event_count
FROM stat_sdk.sdk_odz_source_data e
WHERE e.date_p BETWEEN 20260601 AND 20260630
  AND e.app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
  AND e.event_id = 'second_func_use'
  AND LOWER(TRIM(COALESCE(e.params['second_func'], ''))) = 'face'
  AND TRIM(COALESCE(e.params['prf_jaw_mod'], '')) <> ''
GROUP BY
    TRIM(e.params['prf_jaw_mod'])
