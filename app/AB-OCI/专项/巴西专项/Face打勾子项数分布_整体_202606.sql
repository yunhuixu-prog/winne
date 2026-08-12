-- AirBrush / 2026-06 / 整体
-- 事件：second_func_use，second_func=face；每条打勾事件为一次观察。
-- 使用判定：对应参数字符串至少有一个非 0 值。
-- Face：统计 Jaw/Nose/Face/Eyes/Lips/Eyebrows/Head 7 个三级子项。
-- Jaw：统计 chin/double_chin/jaw/jaw_line/length/jaw_shape/
--      double_chin_pro 7 个内部调整项。
-- Nose：统计 size/length/width/bridge/tip/root 6 个内部调整项。
-- Head 优先读取 head_mod；为空时兼容 prf_head_mod。

SELECT
    '整体' AS market_name,
    COUNT(1) AS total_event_count,
    SUM(CASE WHEN face_count.face_used_count = 0 THEN 1 ELSE 0 END) AS face_0,
    SUM(CASE WHEN face_count.face_used_count = 1 THEN 1 ELSE 0 END) AS face_1,
    SUM(CASE WHEN face_count.face_used_count = 2 THEN 1 ELSE 0 END) AS face_2,
    SUM(CASE WHEN face_count.face_used_count = 3 THEN 1 ELSE 0 END) AS face_3,
    SUM(CASE WHEN face_count.face_used_count = 4 THEN 1 ELSE 0 END) AS face_4,
    SUM(CASE WHEN face_count.face_used_count = 5 THEN 1 ELSE 0 END) AS face_5,
    SUM(CASE WHEN face_count.face_used_count = 6 THEN 1 ELSE 0 END) AS face_6,
    SUM(CASE WHEN face_count.face_used_count = 7 THEN 1 ELSE 0 END) AS face_7,
    SUM(CASE WHEN face_count.jaw_used_count = 0 THEN 1 ELSE 0 END) AS jaw_0,
    SUM(CASE WHEN face_count.jaw_used_count = 1 THEN 1 ELSE 0 END) AS jaw_1,
    SUM(CASE WHEN face_count.jaw_used_count = 2 THEN 1 ELSE 0 END) AS jaw_2,
    SUM(CASE WHEN face_count.jaw_used_count = 3 THEN 1 ELSE 0 END) AS jaw_3,
    SUM(CASE WHEN face_count.jaw_used_count = 4 THEN 1 ELSE 0 END) AS jaw_4,
    SUM(CASE WHEN face_count.jaw_used_count = 5 THEN 1 ELSE 0 END) AS jaw_5,
    SUM(CASE WHEN face_count.jaw_used_count = 6 THEN 1 ELSE 0 END) AS jaw_6,
    SUM(CASE WHEN face_count.jaw_used_count = 7 THEN 1 ELSE 0 END) AS jaw_7,
    SUM(CASE WHEN face_count.nose_used_count = 0 THEN 1 ELSE 0 END) AS nose_0,
    SUM(CASE WHEN face_count.nose_used_count = 1 THEN 1 ELSE 0 END) AS nose_1,
    SUM(CASE WHEN face_count.nose_used_count = 2 THEN 1 ELSE 0 END) AS nose_2,
    SUM(CASE WHEN face_count.nose_used_count = 3 THEN 1 ELSE 0 END) AS nose_3,
    SUM(CASE WHEN face_count.nose_used_count = 4 THEN 1 ELSE 0 END) AS nose_4,
    SUM(CASE WHEN face_count.nose_used_count = 5 THEN 1 ELSE 0 END) AS nose_5,
    SUM(CASE WHEN face_count.nose_used_count = 6 THEN 1 ELSE 0 END) AS nose_6
FROM (
    SELECT
        e.gid,
        (
            CASE WHEN REGEXP_EXTRACT(
                TRIM(NVL(e.params['prf_jaw_mod'], '')),
                '(^|\\073)[^:]+:[^\\073]*[1-9][^\\073]*(\\073|$)', 0
            ) <> '' THEN 1 ELSE 0 END
          + CASE WHEN REGEXP_EXTRACT(
                TRIM(NVL(e.params['prf_nose_mod'], '')),
                '(^|\\073)[^:]+:[^\\073]*[1-9][^\\073]*(\\073|$)', 0
            ) <> '' THEN 1 ELSE 0 END
          + CASE WHEN REGEXP_EXTRACT(
                TRIM(NVL(e.params['prf_face_mod'], '')),
                '(^|\\073)[^:]+:[^\\073]*[1-9][^\\073]*(\\073|$)', 0
            ) <> '' THEN 1 ELSE 0 END
          + CASE WHEN REGEXP_EXTRACT(
                TRIM(NVL(e.params['prf_eye_mod'], '')),
                '(^|\\073)[^:]+:[^\\073]*[1-9][^\\073]*(\\073|$)', 0
            ) <> '' THEN 1 ELSE 0 END
          + CASE WHEN REGEXP_EXTRACT(
                TRIM(NVL(e.params['prf_lip_mod'], '')),
                '(^|\\073)[^:]+:[^\\073]*[1-9][^\\073]*(\\073|$)', 0
            ) <> '' THEN 1 ELSE 0 END
          + CASE WHEN REGEXP_EXTRACT(
                TRIM(NVL(e.params['prf_eyebrow_mod'], '')),
                '(^|\\073)[^:]+:[^\\073]*[1-9][^\\073]*(\\073|$)', 0
            ) <> '' THEN 1 ELSE 0 END
          + CASE WHEN REGEXP_EXTRACT(
                CASE
                    WHEN TRIM(NVL(e.params['head_mod'], '')) <> ''
                    THEN TRIM(e.params['head_mod'])
                    ELSE TRIM(NVL(e.params['prf_head_mod'], ''))
                END,
                '(^|\\073)[^:]+:[^\\073]*[1-9][^\\073]*(\\073|$)', 0
            ) <> '' THEN 1 ELSE 0 END
        ) AS face_used_count,
        (
            CASE WHEN REGEXP_EXTRACT(
                TRIM(NVL(e.params['prf_jaw_mod'], '')),
                '(^|\\073)chin:[^\\073]*[1-9][^\\073]*(\\073|$)', 0
            ) <> '' THEN 1 ELSE 0 END
          + CASE WHEN REGEXP_EXTRACT(
                TRIM(NVL(e.params['prf_jaw_mod'], '')),
                '(^|\\073)double_chin:[^\\073]*[1-9][^\\073]*(\\073|$)', 0
            ) <> '' THEN 1 ELSE 0 END
          + CASE WHEN REGEXP_EXTRACT(
                TRIM(NVL(e.params['prf_jaw_mod'], '')),
                '(^|\\073)jaw:[^\\073]*[1-9][^\\073]*(\\073|$)', 0
            ) <> '' THEN 1 ELSE 0 END
          + CASE WHEN REGEXP_EXTRACT(
                TRIM(NVL(e.params['prf_jaw_mod'], '')),
                '(^|\\073)jaw_line:[^\\073]*[1-9][^\\073]*(\\073|$)', 0
            ) <> '' THEN 1 ELSE 0 END
          + CASE WHEN REGEXP_EXTRACT(
                TRIM(NVL(e.params['prf_jaw_mod'], '')),
                '(^|\\073)length:[^\\073]*[1-9][^\\073]*(\\073|$)', 0
            ) <> '' THEN 1 ELSE 0 END
          + CASE WHEN REGEXP_EXTRACT(
                TRIM(NVL(e.params['prf_jaw_mod'], '')),
                '(^|\\073)jaw_shape:[^\\073]*[1-9][^\\073]*(\\073|$)', 0
            ) <> '' THEN 1 ELSE 0 END
          + CASE WHEN REGEXP_EXTRACT(
                TRIM(NVL(e.params['prf_jaw_mod'], '')),
                '(^|\\073)double_chin_pro:[^\\073]*[1-9][^\\073]*(\\073|$)', 0
            ) <> '' THEN 1 ELSE 0 END
        ) AS jaw_used_count,
        (
            CASE WHEN REGEXP_EXTRACT(
                TRIM(NVL(e.params['prf_nose_mod'], '')),
                '(^|\\073)size:[^\\073]*[1-9][^\\073]*(\\073|$)', 0
            ) <> '' THEN 1 ELSE 0 END
          + CASE WHEN REGEXP_EXTRACT(
                TRIM(NVL(e.params['prf_nose_mod'], '')),
                '(^|\\073)length:[^\\073]*[1-9][^\\073]*(\\073|$)', 0
            ) <> '' THEN 1 ELSE 0 END
          + CASE WHEN REGEXP_EXTRACT(
                TRIM(NVL(e.params['prf_nose_mod'], '')),
                '(^|\\073)width:[^\\073]*[1-9][^\\073]*(\\073|$)', 0
            ) <> '' THEN 1 ELSE 0 END
          + CASE WHEN REGEXP_EXTRACT(
                TRIM(NVL(e.params['prf_nose_mod'], '')),
                '(^|\\073)bridge:[^\\073]*[1-9][^\\073]*(\\073|$)', 0
            ) <> '' THEN 1 ELSE 0 END
          + CASE WHEN REGEXP_EXTRACT(
                TRIM(NVL(e.params['prf_nose_mod'], '')),
                '(^|\\073)tip:[^\\073]*[1-9][^\\073]*(\\073|$)', 0
            ) <> '' THEN 1 ELSE 0 END
          + CASE WHEN REGEXP_EXTRACT(
                TRIM(NVL(e.params['prf_nose_mod'], '')),
                '(^|\\073)root:[^\\073]*[1-9][^\\073]*(\\073|$)', 0
            ) <> '' THEN 1 ELSE 0 END
        ) AS nose_used_count
    FROM stat_sdk.sdk_odz_source_data e
    WHERE e.date_p BETWEEN 20260601 AND 20260630
      AND e.app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
      AND e.event_id = 'second_func_use'
      AND LOWER(TRIM(NVL(e.params['second_func'], ''))) = 'face'
) face_count
