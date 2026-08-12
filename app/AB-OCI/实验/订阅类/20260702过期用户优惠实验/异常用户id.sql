-- 进组且历史订阅过、当前不在订阅有效期，但未命中复购优惠首页弹窗曝光的用户
SELECT
    e.gid
    ,e.os_type
    ,CASE
        WHEN e.ab_code IN ('29032','29034') THEN '对照组'
        WHEN e.ab_code IN ('29033','29035') THEN '实验组A'
    END AS code
    ,e.date_p AS enter_abtest_date
    ,e.event_timestamp AS enter_abtest_ts
FROM (
    SELECT gid, os_type, is_new, ab_code, event_timestamp, date_p
    FROM (
        SELECT gid, os_type, is_new, ab_code, event_timestamp, date_p
            ,ROW_NUMBER() OVER (PARTITION BY gid ORDER BY event_timestamp) AS ranks
        FROM stat_ab.filing_odz_abtest_active_user
        WHERE date_p BETWEEN 20260702 AND 20260715
            AND ab_code IN ('29032','29033','29034','29035')
    ) t
    WHERE ranks = 1
) e
LEFT JOIN (
    SELECT gid, date_p, is_subscribed, hist_trial_cnt, hist_pay_cnt
    FROM stat_ab.filing_odz_active_user_profile
    WHERE date_p BETWEEN 20260702 AND 20260715
) p
    ON e.gid = p.gid AND e.date_p = p.date_p
LEFT JOIN (
    SELECT DISTINCT gid
        -- ,CAST(`time`/1000 AS bigint) AS event_timestamp
    FROM stat_sdk.sdk_odz_source_data
    WHERE date_p BETWEEN 20260702 AND 20260715
        AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
        AND event_id = 'strategy_popup_show'
        AND params['strategy_name'] in ('discount_for_resubscribe_homepage','discount_for_resubscribe_sub')
) hit
    ON e.gid = hit.gid
    -- AND e.event_timestamp - 15 <= hit.event_timestamp
WHERE (
        COALESCE(p.hist_trial_cnt, 0) > 0
        OR COALESCE(p.hist_pay_cnt, 0) > 0
    )
    AND COALESCE(p.is_subscribed, 0) = 0
    AND hit.gid IS NULL
    AND e.ab_code IN ('29033','29035')
