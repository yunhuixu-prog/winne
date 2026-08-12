-- AirBrush OCI｜巴西滤镜素材表现｜付费用户 vs 免费用户
-- 分析期：2026-07-01 至 2026-07-31
-- 推荐引擎：Hive on Spark
--
-- 数据源：stat_ab.filing_onz_filter_material_event_detail
-- 粒度：付费状态 × 素材 × 分类
-- 付费状态为行为发生当天的状态
--   Paying    = 当天 is_subscribed = 1
--   Un-Paying = 当天 is_subscribed = 0
-- Unknown 不纳入付费与免费对比
--
-- UV口径：日期 × 用户 × 素材去重，输出总用户日及31天日均
-- 该明细表没有保存事件，因此不输出保存UV和打勾保存率
-- 素材名称、分类名称在下载后使用现有素材ID映射补充
-- Top20在本地分别按 Paying、Un-Paying 的 check_user_days 降序选取

SELECT
    material_daily.pay_status,
    material_daily.material_id,
    material_daily.category_id,
    material_daily.exposure_user_days,
    material_daily.click_user_days,
    material_daily.check_user_days,
    CAST(material_daily.exposure_user_days AS DOUBLE) / 31.0 AS exposure_uv_daily,
    CAST(material_daily.click_user_days AS DOUBLE) / 31.0 AS click_uv_daily,
    CAST(material_daily.check_user_days AS DOUBLE) / 31.0 AS check_uv_daily,
    CASE
        WHEN material_daily.exposure_user_days > 0
            THEN CAST(material_daily.click_user_days AS DOUBLE)
                / material_daily.exposure_user_days
        ELSE NULL
    END AS exposure_click_rate,
    CASE
        WHEN material_daily.click_user_days > 0
            THEN CAST(material_daily.check_user_days AS DOUBLE)
                / material_daily.click_user_days
        ELSE NULL
    END AS click_check_rate,
    CASE
        WHEN SUM(material_daily.check_user_days) OVER (
            PARTITION BY material_daily.pay_status
        ) > 0
            THEN CAST(material_daily.check_user_days AS DOUBLE)
                / SUM(material_daily.check_user_days) OVER (
                    PARTITION BY material_daily.pay_status
                )
        ELSE NULL
    END AS check_share
FROM
(
    SELECT
        detail.pay_status,
        REGEXP_EXTRACT(TRIM(detail.material_id), '^([^,]+)', 1) AS material_id,
        MAX(
            REGEXP_EXTRACT(TRIM(detail.category_id), '^([^,]+)', 1)
        ) AS category_id,
        COUNT(DISTINCT CASE
            WHEN detail.event_type = '曝光'
                THEN CONCAT(
                    CAST(detail.date_p AS STRING),
                    '_',
                    CAST(detail.gid AS STRING)
                )
        END) AS exposure_user_days,
        COUNT(DISTINCT CASE
            WHEN detail.event_type = '点击'
                THEN CONCAT(
                    CAST(detail.date_p AS STRING),
                    '_',
                    CAST(detail.gid AS STRING)
                )
        END) AS click_user_days,
        COUNT(DISTINCT CASE
            WHEN detail.event_type = '打勾'
                THEN CONCAT(
                    CAST(detail.date_p AS STRING),
                    '_',
                    CAST(detail.gid AS STRING)
                )
        END) AS check_user_days
    FROM stat_ab.filing_onz_filter_material_event_detail detail
    WHERE detail.date_p BETWEEN 20260701 AND 20260731
      AND LOWER(TRIM(COALESCE(detail.country, ''))) IN ('巴西', 'brazil')
      AND detail.pay_status IN ('Paying', 'Un-Paying')
      AND detail.event_type IN ('曝光', '点击', '打勾')
      AND detail.gid IS NOT NULL
      AND detail.material_id IS NOT NULL
      AND TRIM(detail.material_id) <> ''
      AND LOWER(TRIM(detail.material_id)) NOT IN ('-1', 'none', '整体')
    GROUP BY
        detail.pay_status,
        REGEXP_EXTRACT(TRIM(detail.material_id), '^([^,]+)', 1)
) material_daily
;
