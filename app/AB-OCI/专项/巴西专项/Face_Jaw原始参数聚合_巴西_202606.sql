-- AirBrush / 2026-06 / 巴西 / Face-Jaw 原始参数字符串聚合
SELECT
    '巴西' AS market_name,
    'Jaw' AS feature_name,
    TRIM(source_event.params['prf_jaw_mod']) AS raw_mod,
    COUNT(1) AS event_count
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
      AND TRIM(COALESCE(e.params['prf_jaw_mod'], '')) <> ''
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
          AND a.app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
          AND a.os_p IS NOT NULL
    ) active_user
    INNER JOIN (
        SELECT DISTINCT c.id
        FROM stat_sdk.dim_rna_ip_location c
        WHERE c.date_p = 20260630
          AND c.level = '1'
          AND c.name = '巴西'
    ) brazil
      ON active_user.country_id = brazil.id
    GROUP BY active_user.date_p, active_user.final_id
) brazil_user
  ON source_event.date_p = brazil_user.date_p
 AND source_event.gid = brazil_user.gid
GROUP BY
    TRIM(source_event.params['prf_jaw_mod'])
