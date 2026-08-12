-- AirBrush / 2026-06 / 整体
-- 已知子项：Jaw 7项、Nose 6项；多人脸逗号值下载后本地拆分。
SELECT
    '整体' AS market_name,
    slider_value.feature_name,
    slider_value.subitem_name,
    slider_value.raw_value,
    COUNT(1) AS value_count
FROM (
    SELECT
        e.gid,
        e.params['prf_jaw_mod'] AS jaw_mod,
        e.params['prf_nose_mod'] AS nose_mod
    FROM stat_sdk.sdk_odz_source_data e
    WHERE e.date_p BETWEEN 20260601 AND 20260630
      AND e.app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
      AND e.event_id = 'second_func_use'
      AND LOWER(TRIM(NVL(e.params['second_func'], ''))) = 'face'
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
