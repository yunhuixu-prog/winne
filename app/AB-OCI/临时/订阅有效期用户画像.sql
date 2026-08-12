-- 订阅有效期活跃用户画像（用户粒度 × 活跃日）
-- 引擎：Hive（不行再切 Presto）；占位：${start_date} ${end_date} ${now_time}（yyyyMMdd）
-- 人群：活跃日处于订阅有效期内（date_p > pay_date 且 date_p <= invalid_date）
-- 画像：
--   1) first_launch_date          安装时间（设备维表）
--   2) hist_trial_cnt / hist_pay_cnt / hist_sub_cnt  历史试用/付费/合计订阅次数（活跃日前）
--   3) is_dismissed               当前有效期内合约是否已解约（1=已解约，0=未解约）
--   4) save_second_func_list      活跃当天保存过的二级功能 list（功能行为表 tool_level=2）
-- 依据：口径/活跃用户订阅状态.sql、说明/订阅表.sql、说明/其他表.sql、
--       实验/Face限免实验/进一步/老用户保存行为分析.sql

SELECT
    u.date_p
    ,u.gid
    ,u.os_p
    ,u.country
    ,l.first_launch_date
    ,u.hist_trial_cnt
    ,u.hist_pay_cnt
    ,u.hist_trial_cnt + u.hist_pay_cnt AS hist_sub_cnt
    ,u.is_dismissed
    ,CASE WHEN u.is_dismissed = 1 THEN '已解约' ELSE '未解约' END AS dismiss_status
    ,COALESCE(s.save_second_func_list, '') AS save_second_func_list
    ,COALESCE(s.save_second_func_cnt, 0) AS save_second_func_cnt
FROM (
    SELECT
        a.date_p
        ,a.gid
        ,a.os_p
        ,a.country
        ,MAX(
            CASE
                WHEN a.date_p > o.pay_date
                    AND a.date_p <= CAST(o.invalid_date AS BIGINT) THEN 1
                ELSE 0
            END
        ) AS is_subscribed
        ,SUM(
            CASE
                WHEN o.pay_date < a.date_p
                    AND o.cur_pay_stage = 1
                    AND o.cur_pay_withhold_stage = 0 THEN 1
                ELSE 0
            END
        ) AS hist_trial_cnt
        ,SUM(
            CASE
                WHEN o.pay_date < a.date_p
                    AND o.cur_pay_withhold_stage >= 1 THEN 1
                ELSE 0
            END
        ) AS hist_pay_cnt
        -- 当前仍在有效期内的合约，是否已出现解约记录
        ,MAX(
            CASE
                WHEN a.date_p > o.pay_date
                    AND a.date_p <= CAST(o.invalid_date AS BIGINT)
                    AND d.contract_id IS NOT NULL THEN 1
                ELSE 0
            END
        ) AS is_dismissed
    FROM (
        SELECT
            act.date_p
            ,act.os_p
            ,c.name AS country
            ,act.final_id AS gid
        FROM (
            SELECT date_p, os_p, country_id, final_id
            FROM stat_sdk.sdk_odz_active
            WHERE date_p BETWEEN ${start_date} AND ${end_date}
                AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
                AND os_p IS NOT NULL
        ) act
        LEFT JOIN (
            SELECT DISTINCT id, name
            FROM stat_sdk.dim_rna_ip_location
            WHERE level = '1'
                AND date_p IS NOT NULL
        ) c
            ON act.country_id = c.id
    ) a
    LEFT JOIN (
        SELECT
            gid
            ,pay_date
            ,invalid_date
            ,contract_id
            ,cur_pay_stage
            ,cur_pay_withhold_stage
        FROM stat_vip.paid_oda_all_order_summary
        WHERE app_id_p IN (7329803307041000000)
            AND pay_date <= ${end_date}
            AND is_subscribe = '订阅'
            AND product_sub_line = 'AirBrush'
    ) o
        ON a.gid = o.gid
    LEFT JOIN (
        SELECT
            contract_id
            ,MIN(CAST(dismiss_date AS BIGINT)) AS dismiss_date
        FROM stat_vip.paid_oda_vip_tb_contract
        WHERE date_p = ${now_time}
            AND app_id_p NOT IN (-1)
            AND commodity_id_P NOT IN (-1)
            AND contract_status = 3
            AND dismiss_date IS NOT NULL
        GROUP BY contract_id
    ) d
        ON o.contract_id = d.contract_id
        AND CAST(d.dismiss_date AS BIGINT) <= a.date_p
    GROUP BY
        a.date_p
        ,a.gid
        ,a.os_p
        ,a.country
) u
LEFT JOIN (
    SELECT
        server_id AS gid
        ,MIN(first_launch_date) AS first_launch_date
    FROM stat_sdk.sdk_oda_all_device_info
    WHERE os_p IN ('ios', 'android')
        AND app_key_p IN ('7F7023B6CEC7CDED', 'C851ED7164B6DF0F')
        AND date_p = ${now_time}
        AND server_id > 0
    GROUP BY server_id
) l
    ON u.gid = l.gid
LEFT JOIN (
    SELECT
        date_p
        ,gid
        ,CONCAT_WS(',', SORT_ARRAY(COLLECT_SET(sub_func_level2_name))) AS save_second_func_list
        ,COUNT(DISTINCT sub_func_level2_name) AS save_second_func_cnt
    FROM (
        SELECT
            date_p
            ,gid
            ,sub_func_level2_name
        FROM stat_sdk.airbrush_mdz_tool_behavior_detail
        WHERE date_p BETWEEN ${start_date} AND ${end_date}
            AND model_p IN ('image_edit')
            AND tool_level IN ('2')
            AND event_type = '保存'
            AND sub_func_level2_name IS NOT NULL
            AND TRIM(sub_func_level2_name) <> ''
        GROUP BY date_p, gid, sub_func_level2_name
    ) f0
    GROUP BY date_p, gid
) s
    ON u.date_p = s.date_p
    AND u.gid = s.gid
WHERE u.is_subscribed = 1
;
