WITH t2format AS (
  SELECT
    x.date_p,
    x.app_name,
    x.app_version,
    x.platform,
    x.is_new,
    x.is_ua,
    x.user_source,
    x.country,
    CASE
      WHEN x.paid_type = '0' THEN 'free'
      WHEN x.paid_type = '1' THEN 'paid'
      WHEN x.paid_type = 'any' THEN 'any'
      WHEN x.paid_type = 'null' THEN 'Null'
      -- ELSE 'free'
      ELSE x.paid_type
    END AS paid_type,
    x.module,
    x.material_lv1 AS feature,
    x.material_lv2 AS sub_feature,
    x.material_type AS category_id,
    x.material_id,
    x.is_template,
    [STRUCT( 'pv' AS data_type,
      impression_pv AS exposure,
      click_pv AS click,
      use_pv AS CHECK,
      save_pv AS save,
      IFNULL(y.subscription, 0) AS sub,
      IFNULL(sub2paid, 0) AS sub_to_paid,
      IFNULL(paid14, 0.0) AS revenue ),
    STRUCT( 'uv' AS data_type,
      impression_uv AS exposure,
      click_uv AS click,
      use_uv AS CHECK,
      save_uv AS save,
      IFNULL(y.subscription, 0) AS sub,
      IFNULL(sub2paid, 0) AS sub_to_paid,
      IFNULL(paid14, 0.0) AS revenue ) ] AS upv,
  FROM
    `dataintegration-265403.duffle.dws_dz_material_events` x
  LEFT JOIN `dataintegration-265403.duffle.dws_dz_material_events_sub2paid` y ON
  x.date_p = y.date_p
  AND x.app_name = y.app_name
  AND x.app_version = y.app_version
  AND x.platform = y.platform
  AND x.is_new = y.is_new
  AND x.is_ua = y.is_ua
  AND coalesce(x.user_source,'') = coalesce(y.user_source,'')
  AND x.country = y.country
  AND x.paid_type = y.paid_type
  AND x.module = y.module
  AND x.material_lv1 = y.material_lv1
  AND x.material_lv2 = y.material_lv2
  AND x.material_type = y.material_type
  AND x.material_id = y.material_id
  AND ((x.is_template IS NULL AND y.is_template IS NULL) OR (x.is_template = y.is_template))
)
SELECT
  date_p,
  app_name,
  app_version,
  platform,
  is_new,
  is_ua,
  user_source,
  country,
  paid_type,
  module,
  feature,
  sub_feature,
  category_id,
  material_id,
  is_template,
  v.data_type,
  v.exposure,
  v.click,
  v.check,
  v.save,
  v.sub,
  v.sub_to_paid,
  v.revenue,
FROM
  t2format,
  UNNEST(t2format.upv) v