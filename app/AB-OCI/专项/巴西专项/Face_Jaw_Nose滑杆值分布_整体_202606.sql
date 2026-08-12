-- AirBrush / 2026-06 / 整体
-- 事件：second_func_use，second_func=face
-- 输出：Jaw、Nose 参数字符串拆解后的原始滑杆值分布。
-- 多人脸值若以英文逗号分隔，则拆为多个独立滑杆值。
-- 下载后本地按步长 5 分箱。

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
          AND LOWER(TRIM(NVL(e.params['second_func'], ''))) = 'face'
    ) face_event
    LATERAL VIEW STACK(
        2,
        'Jaw', face_event.prf_jaw_mod,
        'Nose', face_event.prf_nose_mod
    ) feature_mod AS feature_name, raw_mod
    LATERAL VIEW EXPLODE(
        SPLIT(feature_mod.raw_mod, '\073')
    ) item_kv AS item_kv
    LATERAL VIEW EXPLODE(
        SPLIT(REGEXP_EXTRACT(item_kv.item_kv, '^[^:]+:(.*)$', 1), ',')
    ) raw_value AS raw_value
) mod_value
WHERE TRIM(NVL(mod_value.item_kv, '')) <> ''
  AND TRIM(NVL(mod_value.raw_value, '')) <> ''
  AND REGEXP_EXTRACT(mod_value.item_kv, '^([^:]+):', 1) <> ''
GROUP BY
    mod_value.feature_name,
    LOWER(TRIM(REGEXP_EXTRACT(mod_value.item_kv, '^([^:]+):', 1))),
    TRIM(mod_value.raw_value)
