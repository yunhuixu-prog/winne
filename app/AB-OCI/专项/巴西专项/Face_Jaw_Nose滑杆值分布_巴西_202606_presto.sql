-- AirBrush / 2026-06 / 巴西 / Presto
-- second_func_use，second_func=face。
-- 动态拆解 prf_jaw_mod、prf_nose_mod 中的 key:value；
-- 多人脸逗号值拆成独立观察，下载后按步长5分箱。

SELECT
    '巴西' AS market_name,
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
            source_event.gid,
            source_event.params['prf_jaw_mod'] AS prf_jaw_mod,
            source_event.params['prf_nose_mod'] AS prf_nose_mod
        FROM (
            SELECT
                e.date_p,
                e.gid,
                e.params
            FROM stat_sdk.sdk_odz_source_data e
            WHERE e.date_p BETWEEN 20260601 AND 20260630
              AND e.app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
              AND e.event_id = 'second_func_use'
              AND LOWER(TRIM(COALESCE(e.params['second_func'], ''))) = 'face'
        ) source_event
        INNER JOIN (
            SELECT
                active_user.date_p,
                active_user.final_id AS gid
            FROM (
                SELECT
                    a.date_p,
                    a.final_id,
                    a.country_id
                FROM stat_sdk.sdk_odz_active a
                WHERE a.date_p BETWEEN 20260601 AND 20260630
                  AND a.app_key_p IN (
                      'C851ED7164B6DF0F',
                      '7F7023B6CEC7CDED'
                  )
                  AND a.os_p IS NOT NULL
            ) active_user
            INNER JOIN (
                SELECT DISTINCT
                    c.id
                FROM stat_sdk.dim_rna_ip_location c
                WHERE c.date_p = 20260630
                  AND c.level = '1'
                  AND c.name = '巴西'
            ) brazil
              ON active_user.country_id = brazil.id
            GROUP BY
                active_user.date_p,
                active_user.final_id
        ) brazil_user
          ON source_event.date_p = brazil_user.date_p
         AND source_event.gid = brazil_user.gid
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
