-- 老用户 · 当天功能保存数量 & 保存功能组合
-- 占位符：${start_date} ${end_date} 分析日期区间（date_p，yyyyMMdd）
-- 口径：功能表 + 活跃表（老用户判定），与 app/ab新sdk/说明 一致

-- =============================================================================
-- Part 1 汇总：当天保存功能组合分布（老用户、有保存行为）
-- =============================================================================
select save_func_cnt
    ,case when save_user_uv>500 then save_func_combo else '其他' end save_func_combo
    ,sum(save_user_uv) save_user_uv,sum(save_pv) save_pv
from (
SELECT save_func_cnt
    ,save_func_combo
    ,sum(save_user_uv) save_user_uv,sum(save_pv) save_pv
FROM (
SELECT
    date_p,
    os_p,
    -- case when country in ('美国','巴西','英国') then country else '其他' end country,
    save_func_cnt,
    save_func_combo,
    COUNT(DISTINCT gid) AS save_user_uv,
    SUM(save_pv) AS save_pv
FROM (
    SELECT
        u.date_p,
        u.gid,
        u.os_p,
        u.country,
        COUNT(DISTINCT f.sub_func_level2_name) AS save_func_cnt,
        CONCAT_WS(',', SORT_ARRAY(COLLECT_SET(f.sub_func_level2_name))) AS save_func_combo,
        SUM(f.save_pv) AS save_pv
    FROM (
        -- 老用户 + 订阅有效期用户（避免多订单重复，这里先聚合成 gid-date_p 唯一）
        SELECT
            rs.date_p,
            rs.os_p,
            rs.country,
            rs.gid
        FROM (
            SELECT
                a.date_p,
                a.os_p,
                c.name AS country,
                a.final_id AS gid,
                CASE WHEN new_device.final_id IS NOT NULL THEN 'New' ELSE 'Old' END AS is_new,
                MAX(
                    CASE
                        WHEN a.date_p > o.pay_date
                         AND a.date_p <= CAST(o.invalid_date AS bigint) THEN 1
                        ELSE 0
                    END
                ) AS is_subscribed
            FROM (
                SELECT date_p, os_p, country_id, final_id
                FROM stat_sdk.sdk_odz_active
                WHERE date_p BETWEEN ${start_date} AND ${end_date}
                    AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
                    AND os_p IS NOT NULL
            ) a
            LEFT JOIN (
                SELECT DISTINCT id, name
                FROM stat_sdk.dim_rna_ip_location
                WHERE level = '1' AND date_p IS NOT NULL
            ) c ON a.country_id = c.id
            LEFT JOIN (
                SELECT final_id, date_p
                FROM stat_sdk.sdk_odz_new_device_info
                WHERE date_p BETWEEN ${start_date} AND ${end_date}
                    AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
                    AND os_p IS NOT NULL
            ) new_device
                ON a.final_id = new_device.final_id AND a.date_p = new_device.date_p
            LEFT JOIN (
                SELECT
                    gid,
                    pay_date,
                    invalid_date
                FROM stat_vip.paid_oda_all_order_summary
                WHERE app_id_p IN (7329803307041000000)
                    AND pay_date <= ${end_date}
                    AND product_sub_line = 'AirBrush'
                    AND is_subscribe = '订阅'
            ) o
                ON a.final_id = o.gid
            GROUP BY
                a.date_p,
                a.os_p,
                c.name,
                a.final_id,
                CASE WHEN new_device.final_id IS NOT NULL THEN 'New' ELSE 'Old' END
        ) rs
        WHERE rs.is_new = 'Old'
          AND rs.is_subscribed = 1
    ) u
    INNER JOIN (
        SELECT
            date_p,
            gid,
            sub_func_level2_name,
            SUM(cnt) AS save_pv
        FROM stat_sdk.airbrush_mdz_tool_behavior_detail
        WHERE date_p BETWEEN ${start_date} AND ${end_date}
            AND model_p IN ('image_edit')
            AND tool_level IN ('2')
            AND event_type = '保存'
            AND sub_func_level2_name IS NOT NULL
            AND TRIM(sub_func_level2_name) <> ''
        GROUP BY date_p, gid, sub_func_level2_name
    ) f
        ON u.date_p = f.date_p AND u.gid = f.gid
    GROUP BY u.date_p, u.gid, u.os_p, u.country
) t
GROUP BY date_p, os_p
    -- , case when country in ('美国','巴西','英国') then country else '其他' end
    , save_func_cnt, save_func_combo
) t
GROUP BY save_func_cnt,save_func_combo
) t
GROUP BY save_func_cnt
    ,case when save_user_uv>500 then save_func_combo else '其他' end
;


-- =============================================================================
-- Part 2 Face 限免实验 · 老用户保存组合，按实验组拆分 5.8~5.26
-- =============================================================================
-- select ab_group,os_p,save_func_cnt
--     ,case when save_user_uv>10 then save_func_combo else '其他' end save_func_combo
--     ,sum(save_user_uv) save_user_uv,sum(save_pv) save_pv
-- from (
SELECT ab_group,os_p,save_func_cnt,save_func_combo
    ,sum(save_user_uv) save_user_uv,sum(save_pv) save_pv
FROM (
SELECT
    date_p,
    ab_group,
    os_p,
    save_func_cnt,
    save_func_combo,
    COUNT(DISTINCT gid) AS save_user_uv,
    SUM(save_pv) AS save_pv
FROM (
    SELECT
        u.enter_abtest_date AS date_p,
        u.gid,
        u.os_p,
        u.ab_group,
        COUNT(DISTINCT f.sub_func_level2_name) AS save_func_cnt,
        CASE
            WHEN COUNT(DISTINCT f.sub_func_level2_name) = 0 THEN '无保存'
            ELSE CONCAT_WS(',', SORT_ARRAY(COLLECT_SET(f.sub_func_level2_name)))
        END AS save_func_combo,
        COALESCE(SUM(f.save_pv), 0) AS save_pv
    FROM (
        select gid,os_p
            ,case when ab_code in ('28926','28929') then '对照组'
            when ab_code in ('28927','28930') then '实验组A'
            when ab_code in ('28928','28931') then '实验组B'
            end as ab_group,enter_abtest_date,event_timestamp
        from
        (
            select
                fa.gid,fa.os_p,fa.country,fa.is_new
                ,e.ab_code,e.enter_abtest_date,e.event_timestamp
                ,row_number() over(partition by e.gid order by event_timestamp) ranks
            from (
                SELECT
                    a.date_p,
                    a.os_p,
                    c.name AS country,
                    a.final_id gid,
                    CASE WHEN new_device.final_id IS NOT NULL THEN 'New' ELSE 'Old' END AS is_new
                FROM
                (
                    SELECT date_p, os_p, country_id, final_id
                    FROM stat_sdk.sdk_odz_active
                    WHERE date_p BETWEEN ${start_date} AND ${end_date}
                        AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
                        AND os_p IS NOT NULL
                ) a
                LEFT JOIN
                (
                    SELECT DISTINCT id, name
                    FROM stat_sdk.dim_rna_ip_location
                    WHERE level='1' and date_p is not null
                ) c
                ON a.country_id = c.id
                LEFT JOIN
                (
                    SELECT final_id, date_p
                    FROM stat_sdk.sdk_odz_new_device_info
                    WHERE date_p BETWEEN ${start_date} AND ${end_date}
                    AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
                    AND os_p IS NOT NULL
                )new_device
                ON a.final_id = new_device.final_id AND a.date_p = new_device.date_p
            ) fa
            join (
                SELECT date_p enter_abtest_date
                    ,CAST(`time`/1000 AS bigint) event_timestamp
                    ,sdk_type os_type,gid
                    ,params['current_abcode'] ab_code
                FROM stat_sdk.sdk_odz_source_data
                WHERE date_p between ${start_date} AND ${end_date}
                    AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
                    AND event_id = 'abcode_enter_test'
                    AND params['current_abcode'] in ('28926','28927','28928','28929','28930','28931')
            ) e ON e.gid = fa.gid and e.enter_abtest_date = fa.date_p
            where e.gid is not null
        ) t
        where ranks=1
    ) u
    LEFT JOIN (
        SELECT
            date_p,
            gid,
            sub_func_level2_name,
            SUM(cnt) AS save_pv
        FROM stat_sdk.airbrush_mdz_tool_behavior_detail
        WHERE date_p BETWEEN ${start_date} AND ${end_date}
            AND model_p IN ('image_edit')
            AND tool_level IN ('2')
            AND event_type = '保存'
            AND sub_func_level2_name IS NOT NULL
            AND TRIM(sub_func_level2_name) <> ''
        GROUP BY date_p, gid, sub_func_level2_name
    ) f
        ON u.enter_abtest_date = f.date_p AND u.gid = f.gid
    GROUP BY u.enter_abtest_date, u.gid, u.os_p, u.ab_group
) t
GROUP BY date_p, ab_group, os_p, save_func_cnt, save_func_combo
) t
GROUP BY ab_group,os_p,save_func_cnt,save_func_combo
-- ) t
-- GROUP BY ab_group,os_p,save_func_cnt
--     ,case when save_user_uv>10 then save_func_combo else '其他' end

