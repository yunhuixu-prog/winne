-- `dataintegration-265403.temp.dws_ds_xyz_project_behavior_by_theme_v`
-- 1245
WITH base_data AS (
  SELECT
    * EXCEPT(theme),
    -- Clean theme names
    CASE
      WHEN REGEXP_CONTAINS(theme, r'(_EU|_AS|_TH|_AS_test|_AS\+TH| Eu)$')
      THEN REGEXP_REPLACE(theme, r'(_EU|_AS|_TH|_AS_test|_AS\+TH| Eu)$', '')
      ELSE theme
    END AS theme
  FROM `dataintegration-265403.aigc.dws_dz_aigc_project_behavior_by_theme_v2`
  WHERE project_name != 'Tooniverse' AND entry = 'All'
),
standard_themes AS (
  SELECT project, theme_id, MAX(theme) AS standard_theme, MAX(icon) AS icon
  FROM `dataintegration-265403.dim.dim_gs_duffle_xyz_theme_standard_name`
  GROUP BY 1, 2
),
material_icons AS (
  SELECT app, platform, m_id AS Material_id, MAX(icon) AS icon, MAX(name) Material_name
  FROM `dataintegration-265403.duffle_fin.dmi_da_materials_info_v`
  WHERE (
    (remark IN ('AI style') AND theme = 'TEM')
--     OR (remark IN ('风格化-AIGC') AND theme = 'STY')
    OR theme = 'STY'
    OR theme = 'FRA'
  )
  GROUP BY 1, 2, 3

  UNION ALL

  SELECT 'Beauty Plus Cam' AS app, platform, m_id AS Material_id, MAX(icon) AS icon, MAX(name) Material_name
  FROM `dataintegration-265403.duffle_fin.dmi_da_materials_info_v`
  WHERE (
    (remark IN ('AI style') AND theme = 'TEM')
    OR (remark IN ('风格化-AIGC') AND theme = 'STY')
    AND app = 'BeautyPlus'
    AND platform = 'ANDROID'
  )
  GROUP BY 1, 2, 3
),
theme_packages AS (
  SELECT name, MAX(num) AS pkg_num
  FROM `dataintegration-265403.dim.dim_gs_duffle_xyz_theme_detail_pkg`
  GROUP BY 1
)
SELECT
  app_name
  ,date
  ,e.platform
  ,country
  ,CASE
    WHEN country IN ('South Korea','Thailand','Japan','United States','Indonesia','Brazil','Russia','Bangladesh','Vietnam')
    THEN country
    ELSE 'Others'
  END AS country_group
  ,is_new
  ,is_ua
  ,project_name
  ,status
  ,entry
  ,CASE WHEN source IN ('H5','Style','Template') THEN source ELSE 'Unknown' END AS source
  ,CASE WHEN theme_type = 'image' THEN 'photo' ELSE theme_type END AS theme_type
  ,COALESCE(
    COALESCE(p.standard_theme,s.Material_name),
    CASE
      WHEN e.theme LIKE 'Trending%'
        OR e.theme LIKE 'Portrait%'
        OR e.theme LIKE 'Pet%'
        OR e.theme LIKE 'Food%'
        OR e.theme LIKE 'ScenicZone%'
        OR e.theme LIKE 'Festive%'
      THEN IF(
        ARRAY_LENGTH(SPLIT(REGEXP_REPLACE(e.theme, ' ', '_'), '_')) >= 2,
        SPLIT(REGEXP_REPLACE(e.theme, ' ', '_'), '_')[OFFSET(1)],
        e.theme
      )
      ELSE e.theme
    END
  ) AS theme
  ,e.theme_id
  ,s.icon
  ,'uv' AS data_type
  ,t.pkg_num AS photo_num
  ,SUM(exposure_uv) AS exposure
  ,SUM(click_uv) AS click
  ,SUM(enter_generate_page_uv) AS enter_generate_page
  ,SUM(click_generate_uv) AS click_generate
  ,SUM(click_generate_uv) AS click_generate_change
  ,SUM(save_uv) AS save
  ,SUM(save_uv) AS save_change
  ,SUM(save_photo_num) AS save_photo_num
  ,SUM(share_uv) AS share
  ,SUM(sub_uv) AS sub
  ,SUM(sub_pay_uv) AS sub_pay
  ,SUM(sub_revenue) AS sub_revenue
FROM base_data e
LEFT JOIN standard_themes p ON e.theme_id = p.theme_id AND e.project_name = p.project
LEFT JOIN material_icons s ON e.app_name = s.app AND e.platform = s.platform AND e.theme_id = s.Material_id
LEFT JOIN theme_packages t ON e.theme = t.name
GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17

UNION ALL

SELECT
  app_name
  ,date
  ,e.platform
  ,country
  ,CASE
    WHEN country IN ('South Korea','Thailand','Japan','United States','Indonesia','Brazil','Russia','Bangladesh','Vietnam')
    THEN country
    ELSE 'Others'
  END AS country_group
  ,is_new
  ,is_ua
  ,project_name
  ,status
  ,entry
  ,CASE WHEN source IN ('H5','Style','Template') THEN source ELSE 'Unknown' END AS source
  ,CASE WHEN theme_type = 'image' THEN 'photo' ELSE theme_type END AS theme_type
  ,COALESCE(
    COALESCE(p.standard_theme,s.Material_name),
    CASE
      WHEN e.theme LIKE 'Trending%'
        OR e.theme LIKE 'Portrait%'
        OR e.theme LIKE 'Pet%'
        OR e.theme LIKE 'Food%'
        OR e.theme LIKE 'ScenicZone%'
        OR e.theme LIKE 'Festive%'
      THEN IF(
        ARRAY_LENGTH(SPLIT(REGEXP_REPLACE(e.theme, ' ', '_'), '_')) >= 2,
        SPLIT(REGEXP_REPLACE(e.theme, ' ', '_'), '_')[OFFSET(1)],
        e.theme
      )
      ELSE e.theme
    END
  ) AS theme
  ,e.theme_id
  ,s.icon
  ,'pv' AS data_type
  ,t.pkg_num AS photo_num
  ,SUM(exposure_pv) AS exposure
  ,SUM(click_pv) AS click
  ,SUM(enter_generate_page_pv) AS enter_generate_page
  ,SUM(click_generate_pv) AS click_generate
  ,SUM(generate_photo_num) AS click_generate_change
  ,SUM(save_pv) AS save
  ,SUM(save_photo_num) AS save_change
  ,SUM(save_photo_num) AS save_photo_num
  ,SUM(share_pv) AS share
  ,SUM(sub_uv) AS sub
  ,SUM(sub_pay_uv) AS sub_pay
  ,SUM(sub_revenue) AS sub_revenue
FROM base_data e
LEFT JOIN standard_themes p ON e.theme_id = p.theme_id AND e.project_name = p.project
LEFT JOIN material_icons s ON e.app_name = s.app AND e.platform = s.platform AND e.theme_id = s.Material_id
LEFT JOIN theme_packages t ON e.theme = t.name
GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17;