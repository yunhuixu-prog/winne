-- AirBrush 巴西日活机型分布；Presto，不行切换 Hive。
-- 后续按天汇总：平台占比 = 平台日均 DAU / 总日均 DAU；
-- Android 机型占比 = 机型日均 DAU / Android 日均 DAU。
SELECT
    '巴西' AS market_name,
    a.date_p,
    a.os_p,
    COALESCE(NULLIF(TRIM(a.brand), ''), 'Unknown') AS brand,
    COALESCE(NULLIF(TRIM(a.device_model), ''), 'Unknown') AS device_model,
    COUNT(DISTINCT a.final_id) AS dau
FROM
(
    SELECT
        date_p,
        os_p,
        country_id,
        final_id,
        brand,
        device_model
    FROM stat_sdk.sdk_odz_active
    WHERE date_p BETWEEN 20260601 AND 20260630
      AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
      AND os_p IN ('android', 'ios')
      AND final_id IS NOT NULL
) a
LEFT JOIN
(
    SELECT DISTINCT
        id,
        name
    FROM stat_sdk.dim_rna_ip_location
    WHERE level = '1'
      AND date_p IS NOT NULL
) c
ON a.country_id = c.id
WHERE c.name = '巴西'
GROUP BY
    a.date_p,
    a.os_p,
    COALESCE(NULLIF(TRIM(a.brand), ''), 'Unknown'),
    COALESCE(NULLIF(TRIM(a.device_model), ''), 'Unknown')
