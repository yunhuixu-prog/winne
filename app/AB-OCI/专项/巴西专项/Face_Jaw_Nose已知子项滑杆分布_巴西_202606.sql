-- AirBrush / 2026-06 / 巴西
-- 已知子项：Jaw 7项、Nose 6项；多人脸逗号值下载后本地拆分。
SELECT
    '巴西' AS market_name,
    slider_value.feature_name,
    slider_value.subitem_name,
    slider_value.raw_value,
    COUNT(1) AS value_count
FROM (
    SELECT
        source_event.gid,
        source_event.params['prf_jaw_mod'] AS jaw_mod,
        source_event.params['prf_nose_mod'] AS nose_mod
    FROM (
        SELECT
            e.date_p,
            e.gid,
            e.params
        FROM stat_sdk.sdk_odz_source_data e
        WHERE e.date_p BETWEEN 20260601 AND 20260630
          AND e.app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
          AND e.event_id = 'second_func_use'
          AND LOWER(TRIM(NVL(e.params['second_func'], ''))) = 'face'
    ) source_event
    INNER JOIN (
        SELECT
            active_user.date_p,
            active_user.final_id AS gid
        FROM (
            SELECT
                a.date_p,
                a.final_id,
                a.country_id
            FROM stat_sdk.sdk_odz_active a
            WHERE a.date_p BETWEEN 20260601 AND 20260630
              AND a.app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
              AND a.os_p IS NOT NULL
        ) active_user
        INNER JOIN (
            SELECT DISTINCT c.id
            FROM stat_sdk.dim_rna_ip_location c
            WHERE c.date_p = 20260630
              AND c.level = '1'
              AND c.name = '巴西'
        ) brazil
          ON active_user.country_id = brazil.id
        GROUP BY active_user.date_p, active_user.final_id
    ) brazil_user
      ON source_event.date_p = brazil_user.date_p
     AND source_event.gid = brazil_user.gid
) face_event
LATERAL VIEW STACK(
    13,
    'Jaw', 'chin',
        REGEXP_EXTRACT(face_event.jaw_mod, '(^|\\073)chin:([^\\073]*)', 2),
    'Jaw', 'double_chin',
        REGEXP_EXTRACT(face_event.jaw_mod, '(^|\\073)double_chin:([^\\073]*)', 2),
    'Jaw', 'jaw',
        REGEXP_EXTRACT(face_event.jaw_mod, '(^|\\073)jaw:([^\\073]*)', 2),
    'Jaw', 'jaw_line',
        REGEXP_EXTRACT(face_event.jaw_mod, '(^|\\073)jaw_line:([^\\073]*)', 2),
    'Jaw', 'length',
        REGEXP_EXTRACT(face_event.jaw_mod, '(^|\\073)length:([^\\073]*)', 2),
    'Jaw', 'jaw_shape',
        REGEXP_EXTRACT(face_event.jaw_mod, '(^|\\073)jaw_shape:([^\\073]*)', 2),
    'Jaw', 'double_chin_pro',
        REGEXP_EXTRACT(face_event.jaw_mod, '(^|\\073)double_chin_pro:([^\\073]*)', 2),
    'Nose', 'size',
        REGEXP_EXTRACT(face_event.nose_mod, '(^|\\073)size:([^\\073]*)', 2),
    'Nose', 'length',
        REGEXP_EXTRACT(face_event.nose_mod, '(^|\\073)length:([^\\073]*)', 2),
    'Nose', 'width',
        REGEXP_EXTRACT(face_event.nose_mod, '(^|\\073)width:([^\\073]*)', 2),
    'Nose', 'bridge',
        REGEXP_EXTRACT(face_event.nose_mod, '(^|\\073)bridge:([^\\073]*)', 2),
    'Nose', 'tip',
        REGEXP_EXTRACT(face_event.nose_mod, '(^|\\073)tip:([^\\073]*)', 2),
    'Nose', 'root',
        REGEXP_EXTRACT(face_event.nose_mod, '(^|\\073)root:([^\\073]*)', 2)
) slider_value AS feature_name, subitem_name, raw_value
WHERE TRIM(NVL(slider_value.raw_value, '')) <> ''
GROUP BY
    slider_value.feature_name,
    slider_value.subitem_name,
    slider_value.raw_value
