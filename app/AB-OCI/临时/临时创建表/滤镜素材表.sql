-- =============================================================================
-- 滤镜素材事件明细（曝光 / 点击 / 打勾）
-- 口径依据：app/AB-OCI/说明/素材表.sql、看板/功能素材/素材/1素材明细.sql
-- 数据源：stat_sdk.sdk_odz_source_data（module=edit，material_type=filters）
-- 用户维度：stat_ab.filing_odz_active_user_profile（新老 / 渠道 is_ua / 国家 / 当日付费 is_subscribed / 安装日）
-- 粒度：一条埋点一行；单事件单 material_id，不做逗号拆分
--
-- 神舟回刷（勿一次跑全量，按 7 天一片 INSERT OVERWRITE，仅覆盖该片 date_p 分区）：
--   20260701～20260707 | 20260708～20260714 | 20260715～20260721
--   20260722～20260728 | 20260729～20260804（至业务昨日，脚本会自动算昨天）
-- 一键切片：python3 app/AB-OCI/临时/临时创建表/run_filter_material_backfill_chunks.py
-- 引擎：Hive on Spark；项目 Airbrush；环境 oci
-- =============================================================================

SET hive.exec.dynamic.partition = true;
SET hive.exec.dynamic.partition.mode = nonstrict;

INSERT OVERWRITE TABLE stat_ab.filing_onz_filter_material_event_detail PARTITION (date_p)
SELECT
    evt.gid,
    evt.event_timestamp,
    evt.material_id,
    evt.event_type,
    evt.category_id,
    COALESCE(prof.os_type, '未知') AS os_type,
    COALESCE(prof.is_new, 'Unknown') AS is_new,
    COALESCE(prof.is_ua, 'Unknown') AS is_ua,
    COALESCE(prof.country, 'Unknown') AS country,
    CASE
        WHEN prof.is_subscribed = 1 THEN 'Paying'
        WHEN prof.is_subscribed = 0 THEN 'Un-Paying'
        ELSE 'Unknown'
    END AS pay_status,
    CAST(prof.first_launch_date AS BIGINT) AS first_launch_date,
    CAST(
        CASE
            WHEN prof.first_launch_date IS NULL THEN NULL
            ELSE meitu_datediff(evt.date_p, prof.first_launch_date)
        END AS INT
    ) AS install_age_days,
    evt.default_value_source,
    evt.filters_value,
    evt.date_p
FROM (
    SELECT
        raw.date_p,
        raw.gid,
        raw.os_type,
        CAST(CAST(raw.event_time_ms AS BIGINT) / 1000 AS BIGINT) AS event_timestamp,
        raw.event_type,
        TRIM(raw.material_id) AS material_id,
        TRIM(raw.category_id) AS category_id,
        raw.default_value_source,
        raw.filters_value
    FROM (
            SELECT
                s.date_p,
                s.gid,
                s.os_type,
                s.`time` AS event_time_ms,
                '曝光' AS event_type,
                s.params['material_id'] AS material_id,
                s.params['category_id'] AS category_id,
                CAST(NULL AS STRING) AS default_value_source,
                CAST(NULL AS STRING) AS filters_value
            FROM stat_sdk.sdk_odz_source_data s
            WHERE s.date_p BETWEEN ${start_time} AND ${end_time}
                AND s.app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
                AND s.event_id = 'material_exposure'
                AND s.params['module'] = 'edit'
                AND s.params['material_type'] = 'filters'
                AND s.params['material_id'] IS NOT NULL
                AND TRIM(s.params['material_id']) <> ''
                AND s.gid IS NOT NULL

            UNION ALL

            SELECT
                s.date_p,
                s.gid,
                s.os_type,
                s.`time` AS event_time_ms,
                '点击' AS event_type,
                s.params['material_id'] AS material_id,
                s.params['category_id'] AS category_id,
                CAST(NULL AS STRING) AS default_value_source,
                CAST(NULL AS STRING) AS filters_value
            FROM stat_sdk.sdk_odz_source_data s
            WHERE s.date_p BETWEEN ${start_time} AND ${end_time}
                AND s.app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
                AND s.event_id = 'material_click'
                AND s.params['module'] = 'edit'
                AND s.params['material_type'] = 'filters'
                AND s.params['material_id'] IS NOT NULL
                AND TRIM(s.params['material_id']) <> ''
                AND s.gid IS NOT NULL

            UNION ALL

            SELECT
                s.date_p,
                s.gid,
                s.os_type,
                s.`time` AS event_time_ms,
                '打勾' AS event_type,
                s.params['mids_material_id'] AS material_id,
                s.params['mids_category_id'] AS category_id,
                s.params['default_value_source'] AS default_value_source,
                s.params['filters_value'] AS filters_value
            FROM stat_sdk.sdk_odz_source_data s
            WHERE s.date_p BETWEEN ${start_time} AND ${end_time}
                AND s.app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
                AND s.event_id = 'material_check'
                AND s.params['module'] = 'edit'
                AND s.params['material_type'] = 'filters'
                AND s.params['mids_material_id'] IS NOT NULL
                AND TRIM(s.params['mids_material_id']) <> ''
                AND s.gid IS NOT NULL
    ) raw
) evt
    LEFT JOIN (
        SELECT
            p.date_p,
            p.gid,
            MAX(p.country) AS country,
            MAX(p.os_type) AS os_type,
            MAX(p.is_new) AS is_new,
            MAX(p.is_ua) AS is_ua,
            MAX(p.is_subscribed) AS is_subscribed,
            MIN(p.first_launch_date) AS first_launch_date
        FROM stat_ab.filing_odz_active_user_profile p
        WHERE p.date_p BETWEEN ${start_time} AND ${end_time}
        GROUP BY p.date_p, p.gid
    ) prof
        ON evt.date_p = prof.date_p
        AND evt.gid = prof.gid
;
