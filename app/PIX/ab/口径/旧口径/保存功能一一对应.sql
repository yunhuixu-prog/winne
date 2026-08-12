WITH expanded AS (
  SELECT
    event_date,
    platform,
    event_name,
    user_pseudo_id,
    SPLIT(func.getParams(event_params, 'prf_first_func').string_value, ',') AS prf_first_func_array,
    SPLIT(func.getParams(event_params, 'prf_second_func').string_value, ',') AS prf_second_func_array,
    SPLIT(func.getParams(event_params, 'prf_third_func').string_value, ',') AS prf_third_func_array
  FROM `dataintegration-265403.analytics.dwd_dzp_events_function`(
    '2025-08-03', '2025-08-09', 'AirBrush', TRUE
  )
  WHERE event_name = 'edit_save'
),
replaced AS (
  SELECT
    event_date,
    platform,
    event_name,
    user_pseudo_id,
    ARRAY(
      SELECT
        CASE
        WHEN prf_second_func = 'skin' THEN prf_third_func
        WHEN prf_second_func <> 'skin' and prf_second_func != '0' THEN prf_second_func
        ELSE prf_first_func
      END
      FROM UNNEST(prf_third_func_array) AS prf_third_func WITH OFFSET idx_third
      JOIN UNNEST(prf_second_func_array) AS prf_second_func WITH OFFSET idx_second
      ON idx_third= idx_second
      JOIN UNNEST(prf_first_func_array) AS prf_first_func WITH OFFSET idx_first
      on idx_second= idx_first
    ) AS combined_func
  FROM expanded
),
func_combos AS (
  SELECT DISTINCT
    event_date,
    user_pseudo_id,
    ARRAY_TO_STRING(
      ARRAY(SELECT DISTINCT func FROM UNNEST(combined_func)func ORDER BY func),
      '+'
    ) AS func_combo
  FROM replaced
),
new_user AS (
  SELECT event_date_hk AS event_date, platform, user_pseudo_id
  FROM `dataintegration-265403.stat.stat_active_advice_detail_d`
  WHERE app_name = 'AirBrush'
    AND is_new = 0
    AND event_date_hk BETWEEN '2025-08-03' AND '2025-08-09'
),
active AS (
  SELECT event_date_hk, platform, user_pseudo_id
  FROM `dataintegration-265403.stat.stat_active_advice_detail_d`
  WHERE app_name = 'AirBrush'
    AND event_date_hk BETWEEN '2025-08-03' AND '2025-08-10'
),
day0 AS (
  SELECT f.event_date, f.user_pseudo_id, f.func_combo
  FROM func_combos f
  JOIN new_user n
    ON f.user_pseudo_id = n.user_pseudo_id
   AND f.event_date = n.event_date
),
day0_with_day1 AS (
  SELECT
    d0.event_date,
    d0.func_combo,
    d0.user_pseudo_id,
    IF(COUNTIF(a.event_date_hk = DATE_ADD(d0.event_date, INTERVAL 1 DAY)) > 0, 1, 0) AS day1_flag
  FROM day0 d0
  LEFT JOIN active a
    ON d0.user_pseudo_id = a.user_pseudo_id
  GROUP BY d0.event_date, d0.func_combo, d0.user_pseudo_id
),
-- 先按每天计算
daily_metrics AS (
  SELECT
    event_date,
    func_combo,
    COUNT(DISTINCT user_pseudo_id) AS day0_users,
    AVG(day1_flag) AS retention_rate
  FROM day0_with_day1
  GROUP BY event_date, func_combo
)
-- 再取日均
SELECT
  func_combo,
  ROUND(AVG(day0_users), 2) AS avg_day0_users,
  ROUND(AVG(retention_rate), 4) AS avg_retention_rate
FROM daily_metrics
GROUP BY func_combo
HAVING avg_day0_users > 1000
ORDER BY avg_retention_rate DESC;