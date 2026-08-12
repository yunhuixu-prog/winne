--- Duffle素材行为：中间表
-- 查询请以date_p,app_code,event_action作为条件，使用聚簇查询更快
-- dataintegration-265403.duffle.dwd_dz_material_events_v
WITH
user_info AS (
    SELECT
        DISTINCT
        date_p,
        user_pseudo_id,
        LAST_VALUE(country) OVER(
            PARTITION BY date_p, user_pseudo_id
            ORDER BY popular_country ASC
            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
        ) AS country,
        LAST_VALUE(app_info_id) OVER(
            PARTITION BY date_p, user_pseudo_id
            ORDER BY popular_app_info_id ASC
            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
        ) AS app_info_id,
        -- MAX(app_info_id) AS app_info_id,
    FROM
    (
        SELECT
            date_p,
            user_pseudo_id,
            country,
            COUNT(1) OVER(PARTITION BY date_p, user_pseudo_id, country) popular_country,
            app_info_id,
            COUNT(1) OVER(PARTITION BY date_p, user_pseudo_id, app_info_id) popular_app_info_id,
        FROM
            `dataintegration-265403.duffle.dwd_dz_material_events`
    )
)
SELECT
  t.date_p,
  t.app_code,
  t.app_name,
  t0.version AS app_version,
  -- app_info_id
  t.user_pseudo_id,
  -- 默认老用户，修正部分无数据
  IFNULL(t2.is_new, 0) is_new,
  -- 默认Organic，修正部分无数据
  IFNULL(is_UA, 'Organic') is_UA,
  IFNULL(user_source, 'Organic') user_source,
  event_name,
  event_timestamp,
  event_action,
  t.platform,
--   t.country,
  user_info.country,
  module,
  coalesce(t1.lv1,material_lv1) AS material_lv1,
  coalesce(t1.lv2,material_lv1) AS material_lv2,
  x.material_type,
  x.material_id,
  -- 可能同时存在new_duffle和marvel中，优先new_duffle
  CASE
    WHEN material_id IN ('BV_STX_00000001', 'BV_STX_00009999') THEN '0'
    ELSE IFNULL(duffle.paid_type, marvel.paid_type)
  END AS paid_type,
  is_template
FROM
  (
    SELECT
      date_p,
      event_name,
      event_timestamp,
      event_action,
      app_code,
      CASE
        WHEN app_code = 'BP' THEN 'BeautyPlus'
        WHEN app_code = 'BV' THEN 'BeautyPlus Story'
        WHEN app_code = 'AB' THEN 'AirBrush'
        WHEN app_code = 'ABV' THEN 'AirBrush Video'
      END AS app_name,
      app_info_id,
      user_pseudo_id,
      platform,
      country,
      module,
      material_lv1,
      material_info,
      0.0 AS paid14,
      is_template
    FROM
      `dataintegration-265403.duffle.dwd_dz_material_events`
    WHERE
      app_code <> 'BV'
      OR (app_code = 'BV' AND platform <> 'WEB')
  ) t,
  UNNEST(t.material_info) x
  LEFT JOIN `dataintegration-265403.duffle_fin.dim_da_materials_level_info_v` t1 -- 关联素材分级维表获取分级素材信息
    ON t.app_code = t1.app_code
    AND x.material_id like concat(t1.material_prefix,'%')
  LEFT JOIN `dataintegration-265403.stat.stat_active_advice_detail_d_view` t2 -- 用户信息
    ON t.date_p = t2.event_date_hk
    AND t.app_name = t2.app_name
    AND t.user_pseudo_id = t2.user_pseudo_id
  LEFT JOIN `dataintegration-265403.duffle_fin.dmi_da_materials_info_v` duffle -- new_duffle素材信息，获取付费信息
    ON t.app_name = duffle.app
    AND t.platform = duffle.platform
    AND x.material_id = duffle.m_id
    AND t.date_p >= duffle.start_date
    AND t.date_p < duffle.end_date
    AND duffle.`source` = 'new_duffle'
  LEFT JOIN `dataintegration-265403.duffle_fin.dmi_da_materials_info_v` marvel -- marvel素材信息，获取付费信息
    ON t.app_name = marvel.app
    AND t.platform = marvel.platform
    AND x.material_id = marvel.m_id
    AND t.date_p >= marvel.start_date
    AND t.date_p < marvel.end_date
    AND marvel.`source` = 'marvel'
  LEFT JOIN user_info -- 关联用户信息
    ON t.date_p = user_info.date_p
    AND t.user_pseudo_id = user_info.user_pseudo_id
  LEFT JOIN `dataintegration-265403.stat_dm.dmi_dz_app_info` t0 -- 关联应用信息获取版本
    ON user_info.app_info_id = t0.uid