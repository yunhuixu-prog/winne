-- AirBrush / 2026-06 / 整体 / Presto
-- second_func_use，second_func=face。
-- 动态拆解 prf_jaw_mod、prf_nose_mod 中的 key:value；
-- 多人脸逗号值拆成独立观察，下载后按步长5分箱。

SELECT
    '整体' AS market_name,
    mod_value.feature_name,
    LOWER(TRIM(REGEXP_EXTRACT(mod_value.item_kv, '^([^:]+):', 1)))
        AS subitem_name,
    TRIM(mod_value.raw_value) AS raw_value,
    COUNT(1) AS value_count
FROM (
    SELECT
        face_event.gid,
        feature_mod.feature_name,
        item_kv.item_kv,
        raw_value.raw_value
    FROM (
        SELECT
            e.gid,
            e.params['prf_jaw_mod'] AS prf_jaw_mod,
            e.params['prf_nose_mod'] AS prf_nose_mod
        FROM stat_sdk.sdk_odz_source_data e
        WHERE e.date_p BETWEEN 20260601 AND 20260630
          AND e.app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
          AND e.event_id = 'second_func_use'
          AND LOWER(TRIM(COALESCE(e.params['second_func'], ''))) = 'face'
    ) face_event
    CROSS JOIN UNNEST(
        ARRAY['Jaw', 'Nose'],
        ARRAY[face_event.prf_jaw_mod, face_event.prf_nose_mod]
    ) AS feature_mod(feature_name, raw_mod)
    CROSS JOIN UNNEST(
        SPLIT(feature_mod.raw_mod, CHR(59))
    ) AS item_kv(item_kv)
    CROSS JOIN UNNEST(
        SPLIT(REGEXP_EXTRACT(item_kv.item_kv, '^[^:]+:(.*)$', 1), ',')
    ) AS raw_value(raw_value)
) mod_value
WHERE TRIM(COALESCE(mod_value.item_kv, '')) <> ''
  AND TRIM(COALESCE(mod_value.raw_value, '')) <> ''
  AND REGEXP_EXTRACT(mod_value.item_kv, '^([^:]+):', 1) <> ''
GROUP BY
    mod_value.feature_name,
    LOWER(TRIM(REGEXP_EXTRACT(mod_value.item_kv, '^([^:]+):', 1))),
    TRIM(mod_value.raw_value)
