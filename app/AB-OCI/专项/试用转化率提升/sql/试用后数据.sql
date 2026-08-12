
SELECT
    t.user_type user_type,t.active_days_7d active_days_7d
    ,case when t.trial_day_save_pv <= 5 then t.trial_day_save_pv else 999 end trial_day_save_pv_type
    ,count(distinct t.gid) trial_uv
    ,count(distinct case when t.is_paid = 1 then t.gid end) paid_uv
FROM (
    SELECT
        t.gid
        ,t.date_p
        ,t.is_paid
        ,t.user_type
        ,coalesce(act7.active_days_7d, 0) AS active_days_7d
        ,coalesce(save0.trial_day_save_pv, 0) AS trial_day_save_pv
    FROM (
        SELECT gid, date_p, is_paid, dismiss_date, user_type
        FROM stat_ab.filing_odz_trial_users_info_temp
        WHERE date_p BETWEEN ${start_date} AND ${end_date}
            and user_type in ('3天内新用户', '历史未订阅老用户')
    ) t
    LEFT JOIN (
        -- 试用后7天活跃天数（不含试用当日，试用日起第1~7天）
        SELECT
            tr.gid
            ,tr.date_p
            ,count(distinct act.date_p) AS active_days_7d
        FROM (
            SELECT gid, date_p
            FROM stat_ab.filing_odz_trial_users_info_temp
            WHERE date_p BETWEEN ${start_date} AND ${end_date}
        ) tr
        INNER JOIN (
            SELECT final_id AS gid, date_p
            FROM stat_sdk.sdk_odz_active
            WHERE date_p BETWEEN ${start_date} AND ${end_date_p7}
                AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
                AND os_p IS NOT NULL
        ) act
            ON tr.gid = act.gid
            AND meitu_datediff(act.date_p, tr.date_p) BETWEEN 1 AND 7
        GROUP BY tr.gid, tr.date_p
    ) act7
        ON t.gid = act7.gid AND t.date_p = act7.date_p
    LEFT JOIN (
        -- 试用当天保存次数（二级功能汇总）
        SELECT
            date_p
            ,gid
            ,sum(case when event_type = '保存' then cnt end) AS trial_day_save_pv
        FROM stat_sdk.airbrush_mdz_tool_behavior_detail
        WHERE date_p BETWEEN ${start_date} AND ${end_date}
            AND model_p IN ('image_edit')
            AND tool_level IN ('1')
        GROUP BY date_p, gid
    ) save0
        ON t.gid = save0.gid AND t.date_p = save0.date_p
) t
GROUP BY
    t.user_type
    ,t.active_days_7d
    ,case when t.trial_day_save_pv <= 5 then t.trial_day_save_pv else 999 end
