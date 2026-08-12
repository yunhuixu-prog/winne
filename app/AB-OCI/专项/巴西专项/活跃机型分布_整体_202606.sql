-- AirBrush 整体月活机型分布；Presto，不行切换 Hive。
-- active_uv：2026年6月在该平台、品牌、机型组合上活跃过的去重 final_id。
-- 同一 final_id 月内若更换机型，会分别计入对应机型。
SELECT
    '整体' AS market_name,
    a.os_p,
    COALESCE(NULLIF(TRIM(a.brand), ''), 'Unknown') AS brand,
    COALESCE(NULLIF(TRIM(a.device_model), ''), 'Unknown') AS device_model,
    COUNT(DISTINCT a.final_id) AS active_uv,
    COUNT(1) AS active_user_days
FROM
(
    SELECT
        date_p,
        os_p,
        final_id,
        brand,
        device_model
    FROM stat_sdk.sdk_odz_active
    WHERE date_p BETWEEN 20260601 AND 20260630
      AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
      AND os_p IN ('android', 'ios')
      AND final_id IS NOT NULL
) a
GROUP BY
    a.os_p,
    COALESCE(NULLIF(TRIM(a.brand), ''), 'Unknown'),
    COALESCE(NULLIF(TRIM(a.device_model), ''), 'Unknown')
