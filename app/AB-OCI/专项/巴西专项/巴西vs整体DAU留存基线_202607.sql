-- AirBrush OCI｜巴西 vs 整体 DAU 用户日留存基线
-- 分析期：2026-07-01 至 2026-07-30；D1成熟至07-29，D7成熟至07-23。

SELECT
    '整体' AS market,
    COUNT(1) AS dau_user_days,
    SUM(CASE WHEN base.date_p <= 20260729 THEN 1 ELSE 0 END) AS d1_sample_user_days,
    SUM(CASE WHEN base.date_p <= 20260729 AND active_d1.gid IS NOT NULL THEN 1 ELSE 0 END) AS d1_retained_user_days,
    SUM(CASE WHEN base.date_p <= 20260729 AND active_d1.gid IS NOT NULL THEN 1 ELSE 0 END)
        / SUM(CASE WHEN base.date_p <= 20260729 THEN 1 ELSE 0 END) AS d1_retention_rate,
    SUM(CASE WHEN base.date_p <= 20260723 THEN 1 ELSE 0 END) AS d7_sample_user_days,
    SUM(CASE WHEN base.date_p <= 20260723 AND active_d7.gid IS NOT NULL THEN 1 ELSE 0 END) AS d7_retained_user_days,
    SUM(CASE WHEN base.date_p <= 20260723 AND active_d7.gid IS NOT NULL THEN 1 ELSE 0 END)
        / SUM(CASE WHEN base.date_p <= 20260723 THEN 1 ELSE 0 END) AS d7_retention_rate
FROM
(
    SELECT profile.date_p, profile.gid
    FROM stat_ab.filing_odz_active_user_profile profile
    WHERE profile.date_p BETWEEN 20260701 AND 20260730
      AND profile.gid IS NOT NULL
    GROUP BY profile.date_p, profile.gid
) base
LEFT JOIN
(
    SELECT DISTINCT active.date_p, active.final_id AS gid
    FROM stat_sdk.sdk_odz_active active
    WHERE active.date_p BETWEEN 20260702 AND 20260730
      AND active.app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
      AND active.os_p IS NOT NULL
) active_d1
  ON base.gid = active_d1.gid
 AND meitu_datediff(active_d1.date_p, base.date_p) = 1
LEFT JOIN
(
    SELECT DISTINCT active.date_p, active.final_id AS gid
    FROM stat_sdk.sdk_odz_active active
    WHERE active.date_p BETWEEN 20260708 AND 20260730
      AND active.app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
      AND active.os_p IS NOT NULL
) active_d7
  ON base.gid = active_d7.gid
 AND meitu_datediff(active_d7.date_p, base.date_p) = 7

UNION ALL

SELECT
    '巴西' AS market,
    COUNT(1) AS dau_user_days,
    SUM(CASE WHEN base.date_p <= 20260729 THEN 1 ELSE 0 END) AS d1_sample_user_days,
    SUM(CASE WHEN base.date_p <= 20260729 AND active_d1.gid IS NOT NULL THEN 1 ELSE 0 END) AS d1_retained_user_days,
    SUM(CASE WHEN base.date_p <= 20260729 AND active_d1.gid IS NOT NULL THEN 1 ELSE 0 END)
        / SUM(CASE WHEN base.date_p <= 20260729 THEN 1 ELSE 0 END) AS d1_retention_rate,
    SUM(CASE WHEN base.date_p <= 20260723 THEN 1 ELSE 0 END) AS d7_sample_user_days,
    SUM(CASE WHEN base.date_p <= 20260723 AND active_d7.gid IS NOT NULL THEN 1 ELSE 0 END) AS d7_retained_user_days,
    SUM(CASE WHEN base.date_p <= 20260723 AND active_d7.gid IS NOT NULL THEN 1 ELSE 0 END)
        / SUM(CASE WHEN base.date_p <= 20260723 THEN 1 ELSE 0 END) AS d7_retention_rate
FROM
(
    SELECT profile.date_p, profile.gid
    FROM stat_ab.filing_odz_active_user_profile profile
    WHERE profile.date_p BETWEEN 20260701 AND 20260730
      AND profile.country = '巴西'
      AND profile.gid IS NOT NULL
    GROUP BY profile.date_p, profile.gid
) base
LEFT JOIN
(
    SELECT DISTINCT active.date_p, active.final_id AS gid
    FROM stat_sdk.sdk_odz_active active
    WHERE active.date_p BETWEEN 20260702 AND 20260730
      AND active.app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
      AND active.os_p IS NOT NULL
) active_d1
  ON base.gid = active_d1.gid
 AND meitu_datediff(active_d1.date_p, base.date_p) = 1
LEFT JOIN
(
    SELECT DISTINCT active.date_p, active.final_id AS gid
    FROM stat_sdk.sdk_odz_active active
    WHERE active.date_p BETWEEN 20260708 AND 20260730
      AND active.app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
      AND active.os_p IS NOT NULL
) active_d7
  ON base.gid = active_d7.gid
 AND meitu_datediff(active_d7.date_p, base.date_p) = 7
