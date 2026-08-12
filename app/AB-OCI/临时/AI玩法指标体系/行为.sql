-- ai_image 素材：次日 App 留存 + 次日 type 率 + 当日 base_uv，base_pv

SELECT
  m.date_p,  -- 日期
  m.base_type,  -- 行为类型：曝光、点击、生成成功、实际生成、保存、使用
  'ai_filter' func,
  m.material_id,  -- 素材ID
  m.base_uv, -- 行为类型对应的当日uv
  m.base_pv, -- 行为类型对应的当日pv
  m.d1_app_active_uv, -- 次日 App 留存
  m.d1_app_retention_rate, -- 次日 App 留存率：d1_app_active_uv/base_uv
--   m.d1_same_type_uv,
--   m.d1_same_type_rate,
  m.d1_exposure_uv, -- 次日曝光
  m.d1_exposure_rate, -- 次日曝光率：d1_exposure_uv/base_uv
  m.d1_click_uv, -- 次日点击
  m.d1_click_rate, -- 次日点击率：d1_click_uv/base_uv
  m.d1_gen_success_uv, -- 次日生成成功
  m.d1_gen_success_rate, -- 次日生成成功率：d1_gen_success_uv/base_uv
  m.d1_gen_actual_uv, -- 次日实际生成
  m.d1_gen_actual_rate, -- 次日实际生成率：d1_gen_actual_uv/base_uv
  m.d1_save_uv, -- 次日保存
  m.d1_save_rate, -- 次日保存率：d1_save_uv/base_uv
  m.d1_check_uv, -- 次日使用
  m.d1_check_rate -- 次日使用率：d1_check_uv/base_uv
FROM (
  SELECT
    c.date_p,
    c.base_type,
    c.material_id,
    COUNT(DISTINCT c.gid) AS base_uv,
    MAX(bp.base_pv) AS base_pv,
    COUNT(DISTINCT CASE WHEN aa.gid IS NOT NULL THEN c.gid END) AS d1_app_active_uv,
    ROUND(
      COUNT(DISTINCT CASE WHEN aa.gid IS NOT NULL THEN c.gid END)
      / COUNT(DISTINCT c.gid),
      4
    ) AS d1_app_retention_rate,
    COUNT(DISTINCT CASE WHEN d1.next_type = c.base_type THEN c.gid END) AS d1_same_type_uv,
    ROUND(
      COUNT(DISTINCT CASE WHEN d1.next_type = c.base_type THEN c.gid END)
      / COUNT(DISTINCT c.gid),
      4
    ) AS d1_same_type_rate,
    COUNT(DISTINCT CASE WHEN d1.next_type = '曝光' THEN c.gid END) AS d1_exposure_uv,
    ROUND(
      COUNT(DISTINCT CASE WHEN d1.next_type = '曝光' THEN c.gid END)
      / COUNT(DISTINCT c.gid),
      4
    ) AS d1_exposure_rate,
    COUNT(DISTINCT CASE WHEN d1.next_type = '点击' THEN c.gid END) AS d1_click_uv,
    ROUND(
      COUNT(DISTINCT CASE WHEN d1.next_type = '点击' THEN c.gid END)
      / COUNT(DISTINCT c.gid),
      4
    ) AS d1_click_rate,
    COUNT(DISTINCT CASE WHEN d1.next_type = '生成成功' THEN c.gid END) AS d1_gen_success_uv,
    ROUND(
      COUNT(DISTINCT CASE WHEN d1.next_type = '生成成功' THEN c.gid END)
      / COUNT(DISTINCT c.gid),
      4
    ) AS d1_gen_success_rate,
    COUNT(DISTINCT CASE WHEN d1.next_type = '实际生成' THEN c.gid END) AS d1_gen_actual_uv,
    ROUND(
      COUNT(DISTINCT CASE WHEN d1.next_type = '实际生成' THEN c.gid END)
      / COUNT(DISTINCT c.gid),
      4
    ) AS d1_gen_actual_rate,
    COUNT(DISTINCT CASE WHEN d1.next_type = '保存' THEN c.gid END) AS d1_save_uv,
    ROUND(
      COUNT(DISTINCT CASE WHEN d1.next_type = '保存' THEN c.gid END)
      / COUNT(DISTINCT c.gid),
      4
    ) AS d1_save_rate,
    COUNT(DISTINCT CASE WHEN d1.next_type = '使用' THEN c.gid END) AS d1_check_uv,
    ROUND(
      COUNT(DISTINCT CASE WHEN d1.next_type = '使用' THEN c.gid END)
      / COUNT(DISTINCT c.gid),
      4
    ) AS d1_check_rate
  FROM (
    SELECT
      e.date_p,
      e.type AS base_type,
      e.material_id,
      e.gid
    FROM (
      SELECT
        date_p,
        type,
        material_id,
        gid
      FROM (
        SELECT
          date_p,
          CASE
            WHEN event_id = 'material_exposure' THEN '曝光'
            WHEN event_id = 'ai_func_use_result' AND params['is_success'] = '1' THEN '生成成功'
            WHEN event_id = 'material_click' THEN '点击'
            WHEN event_id = 'material_check' THEN '使用'
            WHEN event_id = 'edit_save' THEN '保存'
          END AS type,
          CASE
            WHEN params['material_id'] IS NOT NULL THEN params['material_id']
            ELSE params['mids_material_id']
          END AS material_id,
          gid
        FROM stat_sdk.sdk_odz_source_data
        WHERE event_id IN (
            'material_exposure',
            'material_click',
            'material_check',
            'edit_save',
            'ai_func_use_result'
          )
          AND (
            params['material_type'] = 'ai_image'
            OR params['prf_material_type'] = 'ai_image'
            OR params['first_func'] = 'ai_filter'
          )
          AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
          AND date_p = '${start_date}'

        UNION ALL

        SELECT
          date_p,
          '实际生成' AS type,
          params['material_id'] AS material_id,
          gid
        FROM stat_sdk.sdk_odz_source_data
        WHERE event_id = 'ai_func_use_result'
          AND params['first_func'] = 'ai_filter'
          AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
          AND date_p = '${start_date}'
      ) event_t
      WHERE type IS NOT NULL
        AND material_id IS NOT NULL
        AND TRIM(material_id) != ''
    ) e
    GROUP BY e.date_p, e.type, e.material_id, e.gid
  ) c
  LEFT JOIN (
    SELECT
      type,
      material_id,
      COUNT(*) AS base_pv
    FROM (
      SELECT
        date_p,
        CASE
          WHEN event_id = 'material_exposure' THEN '曝光'
          WHEN event_id = 'ai_func_use_result' AND params['is_success'] = '1' THEN '生成成功'
          WHEN event_id = 'material_click' THEN '点击'
          WHEN event_id = 'material_check' THEN '使用'
          WHEN event_id = 'edit_save' THEN '保存'
        END AS type,
        CASE
          WHEN params['material_id'] IS NOT NULL THEN params['material_id']
          ELSE params['mids_material_id']
        END AS material_id,
        gid
      FROM stat_sdk.sdk_odz_source_data
      WHERE event_id IN (
          'material_exposure',
          'material_click',
          'material_check',
          'edit_save',
          'ai_func_use_result'
        )
        AND (
          params['material_type'] = 'ai_image'
          OR params['prf_material_type'] = 'ai_image'
          OR params['first_func'] = 'ai_filter'
        )
        AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
        AND date_p = '${start_date}'

      UNION ALL

      SELECT
        date_p,
        '实际生成' AS type,
        params['material_id'] AS material_id,
        gid
      FROM stat_sdk.sdk_odz_source_data
      WHERE event_id = 'ai_func_use_result'
        AND params['first_func'] = 'ai_filter'
        AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
        AND date_p = '${start_date}'
    ) event_t_pv
    WHERE type IS NOT NULL
      AND material_id IS NOT NULL
      AND TRIM(material_id) != ''
    GROUP BY type, material_id
  ) bp
    ON c.material_id = bp.material_id
   AND c.base_type = bp.type
  LEFT JOIN (
    SELECT DISTINCT CAST(a.final_id AS STRING) AS gid
    FROM stat_sdk.sdk_odz_active a
    WHERE a.date_p = '${next_date}'
      AND a.app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
      AND a.os_p IN ('ios', 'android')
  ) aa
    ON c.gid = aa.gid
  LEFT JOIN (
    SELECT
      e2.gid,
      e2.material_id,
      e2.type AS next_type
    FROM (
      SELECT
        date_p,
        type,
        material_id,
        gid
      FROM (
        SELECT
          date_p,
          CASE
            WHEN event_id = 'material_exposure' THEN '曝光'
            WHEN event_id = 'ai_func_use_result' AND params['is_success'] = '1' THEN '生成成功'
            WHEN event_id = 'material_click' THEN '点击'
            WHEN event_id = 'material_check' THEN '使用'
            WHEN event_id = 'edit_save' THEN '保存'
          END AS type,
          CASE
            WHEN params['material_id'] IS NOT NULL THEN params['material_id']
            ELSE params['mids_material_id']
          END AS material_id,
          gid
        FROM stat_sdk.sdk_odz_source_data
        WHERE event_id IN (
            'material_exposure',
            'material_click',
            'material_check',
            'edit_save',
            'ai_func_use_result'
          )
          AND (
            params['material_type'] = 'ai_image'
            OR params['prf_material_type'] = 'ai_image'
            OR params['first_func'] = 'ai_filter'
          )
          AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
          AND date_p = '${next_date}'

        UNION ALL

        SELECT
          date_p,
          '实际生成' AS type,
          params['material_id'] AS material_id,
          gid
        FROM stat_sdk.sdk_odz_source_data
        WHERE event_id = 'ai_func_use_result'
          AND params['first_func'] = 'ai_filter'
          AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
          AND date_p = '${next_date}'
      ) event_d1
      WHERE type IS NOT NULL
        AND material_id IS NOT NULL
        AND TRIM(material_id) != ''
    ) e2
    GROUP BY e2.gid, e2.material_id, e2.type
  ) d1
    ON c.gid = d1.gid
   AND c.material_id = d1.material_id
  GROUP BY c.date_p, c.base_type, c.material_id
) m
-- WHERE m.base_uv >= 10
-- ORDER BY m.date_p, m.base_type, m.base_uv DESC;
