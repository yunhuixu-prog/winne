--- roi预测之Duffle素材行为
-- beautyplus-bc0ed.temp.dwd_dz_roi_predict_0_material_events_v

SELECT
  t.date_p,
  t.app_name,
  t.platform,
  t.user_pseudo_id,
  t.event_action,
  t.module,
  t.material_lv1,
  t.material_type,
  t.material_id,
  -- 可能同时存在new_duffle和marvel中，优先new_duffle
  CASE
    WHEN material_id IN ('BV_STX_00000001', 'BV_STX_00009999') THEN '0'
    ELSE IFNULL(duffle.paid_type, marvel.paid_type)
  END AS paid_type,
  IFNULL(duffle.en_dam_tags, marvel.en_dam_tags) en_dam_tags,
  IFNULL(duffle.en_cms_tags, marvel.en_cms_tags) en_cms_tags,
  pv
FROM
  (
    -- 如果数量太大就限制一下目标用户
    SELECT
      date_p,
      'BeautyPlus' app_name,
      platform,
      event_action,
      user_pseudo_id,
      module,
      material_lv1,
      x.material_id,
      x.material_type,
      count(1) pv
    FROM
      `dataintegration-265403.duffle.dwd_dz_material_events`,UNNEST(material_info) x
    WHERE app_code = 'BP'
      and event_action in ('click', 'use', 'save')
    group by 1,2,3,4,5,6,7,8,9
  ) t
  LEFT JOIN `dataintegration-265403.duffle_fin.dmi_da_materials_info_v` duffle -- new_duffle素材信息，获取付费信息
    ON t.app_name = duffle.app
    AND t.platform = duffle.platform
    AND t.material_id = duffle.m_id
    AND t.date_p >= duffle.start_date
    AND t.date_p < duffle.end_date
    AND duffle.`source` = 'new_duffle'
  LEFT JOIN `dataintegration-265403.duffle_fin.dmi_da_materials_info_v` marvel -- marvel素材信息，获取付费信息
    ON t.app_name = marvel.app
    AND t.platform = marvel.platform
    AND t.material_id = marvel.m_id
    AND t.date_p >= marvel.start_date
    AND t.date_p < marvel.end_date
    AND marvel.`source` = 'marvel'
