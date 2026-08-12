-- Skin Tone 首次跳订阅页未成功用户量级、当天收入与用户分层
-- 引擎：Hive on Spark
-- 环境：OCI
-- 项目：Airbrush
-- 观察期：20260722 至 20260806
-- 全量日：20260722
--
-- 首次跳转未成功口径：
-- 1. 每个用户每天按事件时间切分订阅页会话，一次 w_subscription_enter 开启一个新会话
-- 2. 取当天第一个 source_0=f_skin_tone 的会话
-- 3. 该会话内没有 w_subscription_success 或 sub_suc，即视为首次跳转未订阅成功
-- 4. 因埋点知识库未收录订阅页关闭事件，会话结束用下一次 w_subscription_enter 推断
--
-- 收入口径：
-- 1. 当天收入为该人群在当天所有来源的 paid_ord_amt，仅统计 is_paid=1 且 paid_date=date_p
-- 2. 当天 Skin Tone 收入在上述基础上增加 source_0=f_skin_tone
-- 3. 国家 Top10 固定为截图给定的整体收入 Top10，其余合并为其他
--
-- 用户分层：
-- 平台、安装天数、国家、历史订阅情况
-- 历史订阅情况取行为日之前的订单，试用也算历史订阅过

SELECT
    result.date_p,
    result.platform,
    result.install_days_type,
    CASE
        WHEN result.country IN (
            '美国', '英国', '巴西', '澳大利亚', '加拿大',
            '德国', '墨西哥', '西班牙', '乌克兰', '以色列'
        ) THEN result.country
        ELSE '其他'
    END AS country_type,
    result.hist_sub_type,
    COUNT(1) AS target_user_uv,
    SUM(result.day_paid_user_flag) AS day_paid_user_uv,
    ROUND(SUM(result.day_revenue_usd), 2) AS day_revenue_usd,
    SUM(result.skin_tone_paid_user_flag) AS skin_tone_paid_user_uv,
    ROUND(SUM(result.skin_tone_revenue_usd), 2) AS skin_tone_revenue_usd
FROM (
    SELECT
                cohort.date_p,
                cohort.gid,
                CASE
                    WHEN LOWER(COALESCE(profile.os_type, cohort.enter_os_type)) = 'ios' THEN 'iOS'
                    WHEN LOWER(COALESCE(profile.os_type, cohort.enter_os_type)) = 'android' THEN 'Android'
                    ELSE '未知'
                END AS platform,
                CASE
                    WHEN profile.is_new = 'New' THEN '新用户'
                    WHEN profile.first_launch_date IS NULL THEN '安装天数未知'
                    WHEN meitu_datediff(cohort.date_p, profile.first_launch_date) <= 30 THEN '30天内'
                    ELSE '30天以上'
                END AS install_days_type,
                COALESCE(profile.country, cohort.enter_country, '未知') AS country,
                CASE
                    WHEN COALESCE(profile.hist_trial_cnt, 0) > 0
                      OR COALESCE(profile.hist_pay_cnt, 0) > 0
                    THEN '历史订阅过（含试用）'
                    ELSE '历史未订阅过'
                END AS hist_sub_type,
                COALESCE(revenue.day_paid_user_flag, 0) AS day_paid_user_flag,
                COALESCE(revenue.day_revenue_usd, 0.0) AS day_revenue_usd,
                COALESCE(revenue.skin_tone_paid_user_flag, 0) AS skin_tone_paid_user_flag,
                COALESCE(revenue.skin_tone_revenue_usd, 0.0) AS skin_tone_revenue_usd
            FROM (
                SELECT
                    first_skin_tone.date_p,
                    first_skin_tone.gid,
                    first_skin_tone.enter_os_type,
                    first_skin_tone.enter_country
                FROM (
                    SELECT
                        skin_tone_session.*,
                        ROW_NUMBER() OVER (
                            PARTITION BY skin_tone_session.date_p, skin_tone_session.gid
                            ORDER BY skin_tone_session.enter_timestamp
                        ) AS skin_tone_enter_rank
                    FROM (
                        SELECT
                            session_stream.date_p,
                            session_stream.gid,
                            session_stream.session_no,
                            MIN(CASE
                                WHEN session_stream.event_id = 'w_subscription_enter'
                                THEN session_stream.event_timestamp
                            END) AS enter_timestamp,
                            MAX(CASE
                                WHEN session_stream.event_id = 'w_subscription_enter'
                                THEN session_stream.source_0
                            END) AS enter_source_0,
                            MAX(CASE
                                WHEN session_stream.event_id = 'w_subscription_enter'
                                THEN session_stream.os_type
                            END) AS enter_os_type,
                            MAX(CASE
                                WHEN session_stream.event_id = 'w_subscription_enter'
                                THEN session_stream.country
                            END) AS enter_country,
                            MAX(CASE
                                WHEN session_stream.event_id IN ('w_subscription_success', 'sub_suc')
                                THEN 1 ELSE 0
                            END) AS session_success_flag
                        FROM (
                            SELECT
                                event_raw.*,
                                SUM(CASE
                                    WHEN event_raw.event_id = 'w_subscription_enter' THEN 1
                                    ELSE 0
                                END) OVER (
                                    PARTITION BY event_raw.date_p, event_raw.gid
                                    ORDER BY event_raw.event_timestamp,
                                             CASE
                                                 WHEN event_raw.event_id = 'w_subscription_enter' THEN 0
                                                 ELSE 1
                                             END
                                    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
                                ) AS session_no
                            FROM (
                                SELECT
                                    detail.date_p,
                                    detail.gid,
                                    detail.event_id,
                                    unix_timestamp(detail.event_time, 'yyyyMMddHHmmss') AS event_timestamp,
                                    detail.source_0,
                                    detail.os_type,
                                    detail.country
                                FROM stat_ab.filing_onz_sub_source_event_detail detail
                                WHERE detail.date_p BETWEEN 20260722 AND 20260806
                                  AND detail.event_id IN (
                                      'w_subscription_enter',
                                      'w_subscription_success',
                                      'sub_suc'
                                  )
                                  AND detail.gid IS NOT NULL
                            ) event_raw
                        ) session_stream
                        WHERE session_stream.session_no > 0
                        GROUP BY
                            session_stream.date_p,
                            session_stream.gid,
                            session_stream.session_no
                    ) skin_tone_session
                    WHERE skin_tone_session.enter_source_0 = 'f_skin_tone'
                ) first_skin_tone
                WHERE first_skin_tone.skin_tone_enter_rank = 1
                  AND first_skin_tone.session_success_flag = 0
            ) cohort
            LEFT JOIN (
                SELECT
                    profile_raw.date_p,
                    profile_raw.gid,
                    MAX(profile_raw.os_type) AS os_type,
                    MAX(profile_raw.country) AS country,
                    MAX(profile_raw.is_new) AS is_new,
                    MAX(profile_raw.is_subscribed) AS is_subscribed,
                    MAX(profile_raw.hist_trial_cnt) AS hist_trial_cnt,
                    MAX(profile_raw.hist_pay_cnt) AS hist_pay_cnt,
                    MIN(profile_raw.first_launch_date) AS first_launch_date
                FROM stat_ab.filing_odz_active_user_profile profile_raw
                WHERE profile_raw.date_p BETWEEN 20260722 AND 20260806
                GROUP BY profile_raw.date_p, profile_raw.gid
            ) profile
                ON cohort.date_p = profile.date_p
               AND cohort.gid = profile.gid
            LEFT JOIN (
                SELECT
                    paid.date_p,
                    paid.gid,
                    MAX(CASE
                        WHEN paid.event_id = 'sub_suc'
                         AND paid.is_paid = 1
                         AND CAST(paid.paid_date AS BIGINT) = CAST(paid.date_p AS BIGINT)
                        THEN 1 ELSE 0
                    END) AS day_paid_user_flag,
                    SUM(CASE
                        WHEN paid.event_id = 'sub_suc'
                         AND paid.is_paid = 1
                         AND CAST(paid.paid_date AS BIGINT) = CAST(paid.date_p AS BIGINT)
                        THEN COALESCE(paid.paid_ord_amt, 0.0) ELSE 0.0
                    END) AS day_revenue_usd,
                    MAX(CASE
                        WHEN paid.event_id = 'sub_suc'
                         AND paid.is_paid = 1
                         AND CAST(paid.paid_date AS BIGINT) = CAST(paid.date_p AS BIGINT)
                         AND paid.source_0 = 'f_skin_tone'
                        THEN 1 ELSE 0
                    END) AS skin_tone_paid_user_flag,
                    SUM(CASE
                        WHEN paid.event_id = 'sub_suc'
                         AND paid.is_paid = 1
                         AND CAST(paid.paid_date AS BIGINT) = CAST(paid.date_p AS BIGINT)
                         AND paid.source_0 = 'f_skin_tone'
                        THEN COALESCE(paid.paid_ord_amt, 0.0) ELSE 0.0
                    END) AS skin_tone_revenue_usd
                FROM stat_ab.filing_onz_sub_source_event_detail paid
                WHERE paid.date_p BETWEEN 20260722 AND 20260806
                  AND paid.event_id = 'sub_suc'
                  AND paid.gid IS NOT NULL
                GROUP BY paid.date_p, paid.gid
            ) revenue
                ON cohort.date_p = revenue.date_p
               AND cohort.gid = revenue.gid
            WHERE COALESCE(profile.is_subscribed, 0) = 0
) result
GROUP BY
    result.date_p,
    result.platform,
    result.install_days_type,
    CASE
        WHEN result.country IN (
            '美国', '英国', '巴西', '澳大利亚', '加拿大',
            '德国', '墨西哥', '西班牙', '乌克兰', '以色列'
        ) THEN result.country
        ELSE '其他'
    END,
    result.hist_sub_type;
