-- AirBrush OCI｜巴西用户日使用场景分析｜一次性宽取数
-- 建议引擎：Hive on Spark
-- 分析期：2026-07-01 至 2026-07-30（截至 2026-07-31，取完整自然日）
-- 留存成熟：
--   D1：仅使用 2026-07-01 至 2026-07-29 的用户日；
--   D7：仅使用 2026-07-01 至 2026-07-23 的用户日。
--
-- 设计目标：
--   1. 一次神舟查询返回后续 Python 所需的尽可能完整的明细；
--   2. 不在 SQL 中固化场景映射，场景归类、组合、Lift、分层均在 Python 完成；
--   3. 避免下载全量 DAU 用户明细，DAU 仅按完整分层组合聚合输出。
--
-- record_type：
--   USER_DAY    ：一行一个巴西功能用户日，function_detail 保留各功能进入/打勾/保存 PV；
--   SUB_SOURCE  ：一行一个用户日订阅来源，保留订阅页进入、订阅成功、付费成功和毛利；
--   PAY_EVENT   ：一行一个用户付费日及代扣阶段，可在 Python 计算 D0/D7 付费；
--   DAU_SEGMENT ：一行一个日期×完整用户分层的 DAU 分母。
--
-- function_detail 格式：
--   功能名~进入PV~打勾PV~保存PV|功能名~进入PV~打勾PV~保存PV
--
-- 口径：
--   功能表：stat_sdk.airbrush_mdz_tool_behavior_detail，image_edit、tool_level=2；
--   当前付费：filing_odz_active_user_profile.is_subscribed=1；
--   新用户来源：仅对 New 使用 is_ua（Organic / non-Organic）；
--   省份：活跃表 province_id + country_id 关联 dim_rna_ip_location level=2；
--   订阅来源：Skin 取 fourth_source，AIGC 统一为 AI Image，其余取 third_source；
--   订单毛利：paid_oda_all_order_summary.ord_amt_usd。

SELECT
    'USER_DAY' AS record_type,
    CAST(f.date_p AS BIGINT) AS date_p,
    CAST(f.gid AS STRING) AS gid,
    p.os_type,
    COALESCE(province_dim.name, '未知') AS province,
    active_extra.brand,
    active_extra.device_model,
    p.is_new,
    CASE
        WHEN p.is_new = 'New' THEN COALESCE(p.is_ua, 'Unknown')
        ELSE 'Not Applicable'
    END AS is_ua,
    CAST(p.first_launch_date AS BIGINT) AS first_launch_date,
    CAST(meitu_datediff(f.date_p, p.first_launch_date) AS INT)
        AS install_age_days,
    CASE
        WHEN p.first_launch_date IS NULL
          OR meitu_datediff(f.date_p, p.first_launch_date) < 0
            THEN 'Unknown'
        WHEN meitu_datediff(f.date_p, p.first_launch_date) = 0
            THEN 'D0'
        WHEN meitu_datediff(f.date_p, p.first_launch_date) BETWEEN 1 AND 3
            THEN 'D1-3'
        WHEN meitu_datediff(f.date_p, p.first_launch_date) BETWEEN 4 AND 7
            THEN 'D4-7'
        WHEN meitu_datediff(f.date_p, p.first_launch_date) BETWEEN 8 AND 30
            THEN 'D8-30'
        WHEN meitu_datediff(f.date_p, p.first_launch_date) BETWEEN 31 AND 90
            THEN 'D31-90'
        ELSE 'D91+'
    END AS install_age_bucket,
    CASE WHEN p.is_subscribed = 1 THEN 'Paying' ELSE 'Un-Paying' END
        AS pay_status,
    CASE WHEN d1.gid IS NOT NULL THEN 1 ELSE 0 END AS d1_active,
    CASE WHEN d7.gid IS NOT NULL THEN 1 ELSE 0 END AS d7_active,
    CASE WHEN f.date_p <= 20260729 THEN 1 ELSE 0 END AS d1_mature,
    CASE WHEN f.date_p <= 20260723 THEN 1 ELSE 0 END AS d7_mature,
    f.function_detail,
    CAST(f.function_count AS INT) AS function_count,
    CAST(f.enter_function_count AS INT) AS enter_function_count,
    CAST(f.check_function_count AS INT) AS check_function_count,
    CAST(f.save_function_count AS INT) AS save_function_count,
    CAST(f.total_enter_pv AS BIGINT) AS total_enter_pv,
    CAST(f.total_check_pv AS BIGINT) AS total_check_pv,
    CAST(f.total_save_pv AS BIGINT) AS total_save_pv,
    CAST(NULL AS STRING) AS source_first,
    CAST(NULL AS STRING) AS source_second,
    CAST(NULL AS STRING) AS source_third,
    CAST(NULL AS STRING) AS source_fourth,
    CAST(NULL AS STRING) AS source_function,
    CAST(NULL AS BIGINT) AS sub_enter_pv,
    CAST(NULL AS INT) AS sub_enter_uv,
    CAST(NULL AS INT) AS sub_suc_uv,
    CAST(NULL AS INT) AS sub_paid_uv,
    CAST(NULL AS DOUBLE) AS sub_gross,
    CAST(NULL AS INT) AS pay_stage,
    CAST(NULL AS INT) AS pay_withhold_stage,
    CAST(NULL AS STRING) AS period_type,
    CAST(NULL AS STRING) AS pay_channel,
    CAST(NULL AS BIGINT) AS paid_order_count,
    CAST(NULL AS DOUBLE) AS paid_gross,
    CAST(NULL AS BIGINT) AS dau_user_days
FROM
(
    SELECT
        function_rows.date_p,
        function_rows.gid,
        CONCAT_WS(
            '|',
            ARRAY_SORT(
                COLLECT_SET(
                    CONCAT_WS(
                        '~',
                        function_rows.function_name,
                        CAST(function_rows.enter_pv AS STRING),
                        CAST(function_rows.check_pv AS STRING),
                        CAST(function_rows.save_pv AS STRING)
                    )
                )
            )
        ) AS function_detail,
        COUNT(1) AS function_count,
        SUM(CASE WHEN function_rows.enter_pv > 0 THEN 1 ELSE 0 END)
            AS enter_function_count,
        SUM(CASE WHEN function_rows.check_pv > 0 THEN 1 ELSE 0 END)
            AS check_function_count,
        SUM(CASE WHEN function_rows.save_pv > 0 THEN 1 ELSE 0 END)
            AS save_function_count,
        SUM(function_rows.enter_pv) AS total_enter_pv,
        SUM(function_rows.check_pv) AS total_check_pv,
        SUM(function_rows.save_pv) AS total_save_pv
    FROM
    (
        SELECT
            behavior.date_p,
            behavior.gid,
            CASE
                WHEN TRIM(behavior.sub_func_level2_name)
                     IN ('Details', 'Detail') THEN 'Detail'
                WHEN LOWER(TRIM(behavior.sub_func_level2_name)) = 'eraser'
                    THEN 'Eraser'
                ELSE TRIM(behavior.sub_func_level2_name)
            END AS function_name,
            SUM(
                CASE WHEN behavior.event_type = '进入'
                     THEN behavior.cnt ELSE 0 END
            ) AS enter_pv,
            SUM(
                CASE WHEN behavior.event_type = '打勾'
                     THEN behavior.cnt ELSE 0 END
            ) AS check_pv,
            SUM(
                CASE WHEN behavior.event_type = '保存'
                     THEN behavior.cnt ELSE 0 END
            ) AS save_pv
        FROM stat_sdk.airbrush_mdz_tool_behavior_detail behavior
        WHERE behavior.date_p BETWEEN 20260701 AND 20260730
          AND behavior.model_p = 'image_edit'
          AND behavior.tool_level = '2'
          AND behavior.event_type IN ('进入', '打勾', '保存')
          AND behavior.cnt > 0
          AND behavior.gid IS NOT NULL
          AND behavior.sub_func_level2_name IS NOT NULL
          AND TRIM(behavior.sub_func_level2_name) <> ''
        GROUP BY
            behavior.date_p,
            behavior.gid,
            CASE
                WHEN TRIM(behavior.sub_func_level2_name)
                     IN ('Details', 'Detail') THEN 'Detail'
                WHEN LOWER(TRIM(behavior.sub_func_level2_name)) = 'eraser'
                    THEN 'Eraser'
                ELSE TRIM(behavior.sub_func_level2_name)
            END
    ) function_rows
    GROUP BY
        function_rows.date_p,
        function_rows.gid
) f
INNER JOIN
(
    SELECT
        profile.date_p,
        profile.gid,
        MAX(profile.os_type) AS os_type,
        MAX(profile.is_new) AS is_new,
        MAX(profile.is_ua) AS is_ua,
        MAX(profile.is_subscribed) AS is_subscribed,
        MIN(profile.first_launch_date) AS first_launch_date
    FROM stat_ab.filing_odz_active_user_profile profile
    WHERE profile.date_p BETWEEN 20260701 AND 20260730
      AND profile.country = '巴西'
    GROUP BY
        profile.date_p,
        profile.gid
) p
  ON f.date_p = p.date_p
 AND f.gid = p.gid
LEFT JOIN
(
    SELECT
        active.date_p,
        active.final_id AS gid,
        MAX(active.country_id) AS country_id,
        MAX(active.province_id) AS province_id,
        MAX(active.brand) AS brand,
        MAX(active.device_model) AS device_model
    FROM stat_sdk.sdk_odz_active active
    WHERE active.date_p BETWEEN 20260701 AND 20260730
      AND active.app_key_p IN (
            'C851ED7164B6DF0F',
            '7F7023B6CEC7CDED'
          )
      AND active.os_p IS NOT NULL
    GROUP BY
        active.date_p,
        active.final_id
) active_extra
  ON f.date_p = active_extra.date_p
 AND f.gid = active_extra.gid
LEFT JOIN
(
    SELECT DISTINCT
        location.id,
        location.name,
        location.sdk_country_id
    FROM stat_sdk.dim_rna_ip_location location
    WHERE location.level = '2'
      AND location.date_p IS NOT NULL
) province_dim
  ON active_extra.province_id = province_dim.id
 AND active_extra.country_id = province_dim.sdk_country_id
LEFT JOIN
(
    SELECT DISTINCT
        active_d1.date_p,
        active_d1.final_id AS gid
    FROM stat_sdk.sdk_odz_active active_d1
    WHERE active_d1.date_p BETWEEN 20260702 AND 20260730
      AND active_d1.app_key_p IN (
            'C851ED7164B6DF0F',
            '7F7023B6CEC7CDED'
          )
      AND active_d1.os_p IS NOT NULL
) d1
  ON f.gid = d1.gid
 AND meitu_datediff(d1.date_p, f.date_p) = 1
LEFT JOIN
(
    SELECT DISTINCT
        active_d7.date_p,
        active_d7.final_id AS gid
    FROM stat_sdk.sdk_odz_active active_d7
    WHERE active_d7.date_p BETWEEN 20260708 AND 20260730
      AND active_d7.app_key_p IN (
            'C851ED7164B6DF0F',
            '7F7023B6CEC7CDED'
          )
      AND active_d7.os_p IS NOT NULL
) d7
  ON f.gid = d7.gid
 AND meitu_datediff(d7.date_p, f.date_p) = 7

UNION ALL

SELECT
    'SUB_SOURCE' AS record_type,
    CAST(source_rows.date_p AS BIGINT) AS date_p,
    CAST(source_rows.gid AS STRING) AS gid,
    CAST(NULL AS STRING) AS os_type,
    CAST(NULL AS STRING) AS province,
    CAST(NULL AS STRING) AS brand,
    CAST(NULL AS STRING) AS device_model,
    CAST(NULL AS STRING) AS is_new,
    CAST(NULL AS STRING) AS is_ua,
    CAST(NULL AS BIGINT) AS first_launch_date,
    CAST(NULL AS INT) AS install_age_days,
    CAST(NULL AS STRING) AS install_age_bucket,
    CAST(NULL AS STRING) AS pay_status,
    CAST(NULL AS INT) AS d1_active,
    CAST(NULL AS INT) AS d7_active,
    CAST(NULL AS INT) AS d1_mature,
    CAST(NULL AS INT) AS d7_mature,
    CAST(NULL AS STRING) AS function_detail,
    CAST(NULL AS INT) AS function_count,
    CAST(NULL AS INT) AS enter_function_count,
    CAST(NULL AS INT) AS check_function_count,
    CAST(NULL AS INT) AS save_function_count,
    CAST(NULL AS BIGINT) AS total_enter_pv,
    CAST(NULL AS BIGINT) AS total_check_pv,
    CAST(NULL AS BIGINT) AS total_save_pv,
    source_rows.first_source AS source_first,
    source_rows.second_source AS source_second,
    source_rows.third_source AS source_third,
    source_rows.fourth_source AS source_fourth,
    CASE
        WHEN source_rows.third_source = 'Skin'
            THEN source_rows.fourth_source
        WHEN source_rows.first_source = 'AIGC'
            THEN 'AI Image'
        ELSE source_rows.third_source
    END AS source_function,
    CAST(
        SUM(CASE WHEN source_rows.event_id = 'sub_enter' THEN 1 ELSE 0 END)
        AS BIGINT
    ) AS sub_enter_pv,
    MAX(CASE WHEN source_rows.event_id = 'sub_enter' THEN 1 ELSE 0 END)
        AS sub_enter_uv,
    MAX(CASE WHEN source_rows.event_id = 'sub_suc' THEN 1 ELSE 0 END)
        AS sub_suc_uv,
    MAX(
        CASE
            WHEN source_rows.event_id = 'sub_suc'
             AND source_rows.is_paid = 1 THEN 1
            ELSE 0
        END
    ) AS sub_paid_uv,
    CAST(
        SUM(
            CASE
                WHEN source_rows.event_id = 'sub_suc'
                 AND source_rows.is_paid = 1
                    THEN COALESCE(source_rows.devide_paid_ord_amt, 0)
                ELSE 0
            END
        ) AS DOUBLE
    ) AS sub_gross,
    CAST(NULL AS INT) AS pay_stage,
    CAST(NULL AS INT) AS pay_withhold_stage,
    CAST(NULL AS STRING) AS period_type,
    CAST(NULL AS STRING) AS pay_channel,
    CAST(NULL AS BIGINT) AS paid_order_count,
    CAST(NULL AS DOUBLE) AS paid_gross,
    CAST(NULL AS BIGINT) AS dau_user_days
FROM
(
    SELECT
        sub_detail.date_p,
        sub_detail.gid,
        sub_detail.first_source,
        sub_detail.second_source,
        sub_detail.third_source,
        sub_detail.fourth_source,
        sub_detail.event_id,
        sub_detail.is_paid,
        sub_detail.devide_paid_ord_amt
    FROM stat_ab.filing_onz_sub_source_event_detail_level sub_detail
    WHERE sub_detail.date_p BETWEEN 20260701 AND 20260730
      AND sub_detail.event_id IN ('sub_enter', 'sub_suc')
      AND sub_detail.gid IS NOT NULL
) source_rows
INNER JOIN
(
    SELECT DISTINCT
        profile.date_p,
        profile.gid
    FROM stat_ab.filing_odz_active_user_profile profile
    WHERE profile.date_p BETWEEN 20260701 AND 20260730
      AND profile.country = '巴西'
) brazil_user_day
  ON source_rows.date_p = brazil_user_day.date_p
 AND source_rows.gid = brazil_user_day.gid
GROUP BY
    source_rows.date_p,
    source_rows.gid,
    source_rows.first_source,
    source_rows.second_source,
    source_rows.third_source,
    source_rows.fourth_source,
    CASE
        WHEN source_rows.third_source = 'Skin'
            THEN source_rows.fourth_source
        WHEN source_rows.first_source = 'AIGC'
            THEN 'AI Image'
        ELSE source_rows.third_source
    END

UNION ALL

SELECT
    'PAY_EVENT' AS record_type,
    CAST(order_rows.pay_date AS BIGINT) AS date_p,
    CAST(order_rows.gid AS STRING) AS gid,
    CAST(NULL AS STRING) AS os_type,
    CAST(NULL AS STRING) AS province,
    CAST(NULL AS STRING) AS brand,
    CAST(NULL AS STRING) AS device_model,
    CAST(NULL AS STRING) AS is_new,
    CAST(NULL AS STRING) AS is_ua,
    CAST(NULL AS BIGINT) AS first_launch_date,
    CAST(NULL AS INT) AS install_age_days,
    CAST(NULL AS STRING) AS install_age_bucket,
    CAST(NULL AS STRING) AS pay_status,
    CAST(NULL AS INT) AS d1_active,
    CAST(NULL AS INT) AS d7_active,
    CAST(NULL AS INT) AS d1_mature,
    CAST(NULL AS INT) AS d7_mature,
    CAST(NULL AS STRING) AS function_detail,
    CAST(NULL AS INT) AS function_count,
    CAST(NULL AS INT) AS enter_function_count,
    CAST(NULL AS INT) AS check_function_count,
    CAST(NULL AS INT) AS save_function_count,
    CAST(NULL AS BIGINT) AS total_enter_pv,
    CAST(NULL AS BIGINT) AS total_check_pv,
    CAST(NULL AS BIGINT) AS total_save_pv,
    CAST(NULL AS STRING) AS source_first,
    CAST(NULL AS STRING) AS source_second,
    CAST(NULL AS STRING) AS source_third,
    CAST(NULL AS STRING) AS source_fourth,
    CAST(NULL AS STRING) AS source_function,
    CAST(NULL AS BIGINT) AS sub_enter_pv,
    CAST(NULL AS INT) AS sub_enter_uv,
    CAST(NULL AS INT) AS sub_suc_uv,
    CAST(NULL AS INT) AS sub_paid_uv,
    CAST(NULL AS DOUBLE) AS sub_gross,
    CAST(order_rows.cur_pay_stage AS INT) AS pay_stage,
    CAST(order_rows.cur_pay_withhold_stage AS INT) AS pay_withhold_stage,
    order_rows.period_type,
    COALESCE(order_rows.pay_channel, '未知') AS pay_channel,
    CAST(COUNT(DISTINCT order_rows.notify_pay_id) AS BIGINT)
        AS paid_order_count,
    CAST(SUM(COALESCE(order_rows.ord_amt_usd, 0)) AS DOUBLE)
        AS paid_gross,
    CAST(NULL AS BIGINT) AS dau_user_days
FROM
(
    SELECT
        orders.pay_date,
        orders.gid,
        orders.notify_pay_id,
        orders.cur_pay_stage,
        orders.cur_pay_withhold_stage,
        orders.period_type,
        orders.pay_channel,
        orders.ord_amt_usd
    FROM stat_vip.paid_oda_all_order_summary orders
    WHERE orders.app_id_p IN (7329803307041000000)
      AND orders.pay_date BETWEEN 20260701 AND 20260730
      AND orders.product_sub_line = 'AirBrush'
      AND orders.is_subscribe = '订阅'
      AND orders.cur_pay_withhold_stage >= 1
      AND orders.gid IS NOT NULL
) order_rows
INNER JOIN
(
    SELECT DISTINCT
        profile.gid
    FROM stat_ab.filing_odz_active_user_profile profile
    WHERE profile.date_p BETWEEN 20260701 AND 20260730
      AND profile.country = '巴西'
) brazil_month_users
  ON order_rows.gid = brazil_month_users.gid
GROUP BY
    order_rows.pay_date,
    order_rows.gid,
    order_rows.cur_pay_stage,
    order_rows.cur_pay_withhold_stage,
    order_rows.period_type,
    COALESCE(order_rows.pay_channel, '未知')

UNION ALL

SELECT
    'DAU_SEGMENT' AS record_type,
    CAST(segment.date_p AS BIGINT) AS date_p,
    CAST(NULL AS STRING) AS gid,
    segment.os_type,
    segment.province,
    CAST(NULL AS STRING) AS brand,
    CAST(NULL AS STRING) AS device_model,
    segment.is_new,
    segment.is_ua,
    CAST(NULL AS BIGINT) AS first_launch_date,
    CAST(NULL AS INT) AS install_age_days,
    segment.install_age_bucket,
    segment.pay_status,
    CAST(NULL AS INT) AS d1_active,
    CAST(NULL AS INT) AS d7_active,
    CAST(NULL AS INT) AS d1_mature,
    CAST(NULL AS INT) AS d7_mature,
    CAST(NULL AS STRING) AS function_detail,
    CAST(NULL AS INT) AS function_count,
    CAST(NULL AS INT) AS enter_function_count,
    CAST(NULL AS INT) AS check_function_count,
    CAST(NULL AS INT) AS save_function_count,
    CAST(NULL AS BIGINT) AS total_enter_pv,
    CAST(NULL AS BIGINT) AS total_check_pv,
    CAST(NULL AS BIGINT) AS total_save_pv,
    CAST(NULL AS STRING) AS source_first,
    CAST(NULL AS STRING) AS source_second,
    CAST(NULL AS STRING) AS source_third,
    CAST(NULL AS STRING) AS source_fourth,
    CAST(NULL AS STRING) AS source_function,
    CAST(NULL AS BIGINT) AS sub_enter_pv,
    CAST(NULL AS INT) AS sub_enter_uv,
    CAST(NULL AS INT) AS sub_suc_uv,
    CAST(NULL AS INT) AS sub_paid_uv,
    CAST(NULL AS DOUBLE) AS sub_gross,
    CAST(NULL AS INT) AS pay_stage,
    CAST(NULL AS INT) AS pay_withhold_stage,
    CAST(NULL AS STRING) AS period_type,
    CAST(NULL AS STRING) AS pay_channel,
    CAST(NULL AS BIGINT) AS paid_order_count,
    CAST(NULL AS DOUBLE) AS paid_gross,
    CAST(COUNT(DISTINCT segment.gid) AS BIGINT) AS dau_user_days
FROM
(
    SELECT
        profile_base.date_p,
        profile_base.gid,
        profile_base.os_type,
        COALESCE(province_dim.name, '未知') AS province,
        profile_base.is_new,
        CASE
            WHEN profile_base.is_new = 'New'
                THEN COALESCE(profile_base.is_ua, 'Unknown')
            ELSE 'Not Applicable'
        END AS is_ua,
        CASE
            WHEN profile_base.first_launch_date IS NULL
              OR meitu_datediff(
                    profile_base.date_p,
                    profile_base.first_launch_date
                 ) < 0
                THEN 'Unknown'
            WHEN meitu_datediff(
                    profile_base.date_p,
                    profile_base.first_launch_date
                 ) = 0
                THEN 'D0'
            WHEN meitu_datediff(
                    profile_base.date_p,
                    profile_base.first_launch_date
                 ) BETWEEN 1 AND 3
                THEN 'D1-3'
            WHEN meitu_datediff(
                    profile_base.date_p,
                    profile_base.first_launch_date
                 ) BETWEEN 4 AND 7
                THEN 'D4-7'
            WHEN meitu_datediff(
                    profile_base.date_p,
                    profile_base.first_launch_date
                 ) BETWEEN 8 AND 30
                THEN 'D8-30'
            WHEN meitu_datediff(
                    profile_base.date_p,
                    profile_base.first_launch_date
                 ) BETWEEN 31 AND 90
                THEN 'D31-90'
            ELSE 'D91+'
        END AS install_age_bucket,
        CASE
            WHEN profile_base.is_subscribed = 1 THEN 'Paying'
            ELSE 'Un-Paying'
        END AS pay_status
    FROM
    (
        SELECT
            profile.date_p,
            profile.gid,
            MAX(profile.os_type) AS os_type,
            MAX(profile.is_new) AS is_new,
            MAX(profile.is_ua) AS is_ua,
            MAX(profile.is_subscribed) AS is_subscribed,
            MIN(profile.first_launch_date) AS first_launch_date
        FROM stat_ab.filing_odz_active_user_profile profile
        WHERE profile.date_p BETWEEN 20260701 AND 20260730
          AND profile.country = '巴西'
        GROUP BY
            profile.date_p,
            profile.gid
    ) profile_base
    LEFT JOIN
    (
        SELECT
            active.date_p,
            active.final_id AS gid,
            MAX(active.country_id) AS country_id,
            MAX(active.province_id) AS province_id
        FROM stat_sdk.sdk_odz_active active
        WHERE active.date_p BETWEEN 20260701 AND 20260730
          AND active.app_key_p IN (
                'C851ED7164B6DF0F',
                '7F7023B6CEC7CDED'
              )
          AND active.os_p IS NOT NULL
        GROUP BY
            active.date_p,
            active.final_id
    ) active_extra
      ON profile_base.date_p = active_extra.date_p
     AND profile_base.gid = active_extra.gid
    LEFT JOIN
    (
        SELECT DISTINCT
            location.id,
            location.name,
            location.sdk_country_id
        FROM stat_sdk.dim_rna_ip_location location
        WHERE location.level = '2'
          AND location.date_p IS NOT NULL
    ) province_dim
      ON active_extra.province_id = province_dim.id
     AND active_extra.country_id = province_dim.sdk_country_id
) segment
GROUP BY
    segment.date_p,
    segment.os_type,
    segment.province,
    segment.is_new,
    segment.is_ua,
    segment.install_age_bucket,
    segment.pay_status
;
