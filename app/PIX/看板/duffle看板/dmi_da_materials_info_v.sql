WITH
fix_icon_ratio AS (
  SELECT
    DISTINCT icon,
    LAST_VALUE(icon_ratio) OVER(PARTITION BY icon ORDER BY start_date) icon_ratio
  FROM `dataintegration-265403.duffle_fin.dmi_da_materials_info`
  WHERE
    icon IS NOT NULL
    AND icon_ratio IS NOT NULL
    AND icon_ratio <> ''
)
SELECT
    CASE
        WHEN app_id IN('103', '104', '50001') THEN 'BeautyPlus'
        WHEN app_id IN('121', '122') THEN 'Pomelo'
        WHEN app_id IN('123', '124') THEN 'AirVid'
        WHEN app_id IN('125', '126') THEN 'VCUS'
        WHEN app_id IN('109', '110') THEN 'AirBrush'
        WHEN app_id IN('20001', '10001') THEN 'BeautyPlus Story'
        WHEN app_id IN('20004','50009','10004') THEN 'ThemeU'
        WHEN app_id IN('10013','20013') THEN 'AirBrush Video'
    END AS app,
    app_id,
    platform,
    version_type,
    `version`,
    IF (`period` = 1, '1970-01-01', `start_date`) `start_date`,
    end_date,
    `period`,
    theme,
    m_id,
    c_id,
    `name`,
    t.icon,
    IFNULL(t.icon_ratio, t1.icon_ratio) icon_ratio,
    old_id,
    pack_id,
    tag_id,
    attr_id,
    paid_type,
    is_ip,
    is_recommend,
    available,
    is_hot,
    is_new,
    region_case,
    region_country,
    online_at,
    offline_at,
    created_at,
    updated_at,
    deleted_at,
    is_list_display,
    is_new_time,
    `source`,
    tags,
    SPLIT(tag_id, ',') AS material_type,
    -- 取tags值
    ARRAY_TO_STRING(ARRAY(
      SELECT
        JSON_VALUE(t, '$.tags')
      FROM UNNEST(JSON_EXTRACT_ARRAY(tags)) AS t
      WHERE
        JSON_VALUE(t, '$.tags') IS NOT NULL
        AND JSON_VALUE(t, '$.tags') <> ''
    ), ',') dam_tags,
    -- 取tags值 英文
    ARRAY_TO_STRING(ARRAY(
      SELECT
        JSON_VALUE(t, '$.tags')
      FROM UNNEST(JSON_EXTRACT_ARRAY(tags)) AS t
      WHERE
        JSON_VALUE(t, '$.tags') IS NOT NULL
        AND JSON_VALUE(t, '$.tags') <> ''
        and JSON_VALUE(t, '$.lang') = 'en'
    ), ',') en_dam_tags,
    -- 取cms_tags值
    ARRAY_TO_STRING(ARRAY(
      SELECT
        JSON_VALUE(t, '$.tags')
      FROM UNNEST(JSON_EXTRACT_ARRAY(cms_tags)) AS t
      WHERE
        JSON_VALUE(t, '$.tags') IS NOT NULL
        AND JSON_VALUE(t, '$.tags') <> ''
    ), ',') cms_tags,
    -- 取cms_tags值 英文
    ARRAY_TO_STRING(ARRAY(
      SELECT
        JSON_VALUE(t, '$.tags')
      FROM UNNEST(JSON_EXTRACT_ARRAY(cms_tags)) AS t
      WHERE
        JSON_VALUE(t, '$.tags') IS NOT NULL
        AND JSON_VALUE(t, '$.tags') <> ''
        and JSON_VALUE(t, '$.lang') = 'en'
    ), ',') en_cms_tags,
    copyright_owner, --版权人
    creator --创作者
FROM
  `dataintegration-265403.duffle_fin.dmi_da_materials_info` t
LEFT JOIN fix_icon_ratio t1
ON t.icon = t1.icon
-- where length(cms_tags) > 0