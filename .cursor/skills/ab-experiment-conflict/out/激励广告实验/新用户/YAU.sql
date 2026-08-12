SELECT
    os_p,
    COUNT(DISTINCT final_id) AS yau
FROM stat_sdk.sdk_odz_active
WHERE date_p BETWEEN 20250511 AND 20260511
    AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
    AND os_p IS NOT NULL
GROUP BY os_p
ORDER BY os_p
;
