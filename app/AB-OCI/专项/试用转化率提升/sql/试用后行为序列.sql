
SELECT
    date_p
    ,gid
    ,paid_type
    ,is_retention_1
    ,regexp_replace(
      concat_ws(',', 
          sort_array(
              collect_list(
                  concat(cast(event_time as string), '||', event_name)
              )
          )
      ), 
    '[^,]+\\|\\|', '') AS event_seq_list
FROM (
    -- 试用当日及后7天埋点行为
    SELECT
        u.date_p
        ,u.gid
        ,u.paid_type
        ,func.event_time
        ,func.event_name
        ,case when act.gid is not null then 1 else 0 end is_retention_1
    FROM (
        SELECT DISTINCT
            date_p
            ,gid
            ,CASE WHEN is_paid = 1 THEN '付费'
                  WHEN dismiss_time_type IN ('10分钟内解约', '当天10分钟后解约') THEN '当天解约'
                  WHEN dismiss_time_type IN ('非当天解约') THEN '非当天解约'
                  ELSE '其他'
                  END AS paid_type
        FROM stat_ab.filing_odz_trial_users_info_temp
        WHERE date_p BETWEEN ${start_date} AND ${end_date}
    ) u
    left join (
        select distinct final_id as gid, date_p
        from stat_sdk.sdk_odz_active
        where date_p between ${start_date} and ${end_date_a1}
            and app_key_p in ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
            and os_p is not null
    ) act
    on u.gid = act.gid and meitu_datediff(act.date_p, u.date_p) = 1
    INNER JOIN (
        -- 试用开始
        SELECT
            date_p
            ,gid
            ,UNIX_TIMESTAMP(trial_time, 'yyyyMMddHHmmss') AS event_time
            ,'start_trial' AS event_name
        FROM stat_ab.filing_odz_trial_users_info_temp
        WHERE date_p BETWEEN ${start_date} AND ${end_date}
            and trial_time IS NOT NULL

        union all 

        -- 解约
        SELECT
            date_p
            ,gid
            ,dismiss_time AS event_time
            ,'dismiss_sub' AS event_name
        FROM stat_ab.filing_odz_trial_users_info_temp
        WHERE date_p BETWEEN ${start_date} AND ${end_date}
            and dismiss_time IS NOT NULL

        union all 

    -- 试用当日及后7天埋点行为
        SELECT
            date_p
            ,gid
            ,event_time
            ,CASE
                WHEN event_id = 'popup_show' AND page_name IN ('homepage') THEN 'popup_show'
                WHEN event_id = 'popup_click' AND page_name IN ('homepage') THEN 'popup_click'
                WHEN event_id = 'first_func_enter' AND first_func NOT IN ('retouch', 'edit') THEN concat('first_func_click_', first_func)
                WHEN event_id = 'second_func_enter' AND first_func IN ('retouch', 'edit') THEN concat('second_func_click_', second_func)
                -- WHEN event_id = 'third_func_enter' THEN concat('third_func_click_', third_func)
                WHEN event_id = 'first_func_use' AND first_func NOT IN ('retouch', 'edit') THEN concat('first_func_use_', first_func)
                WHEN event_id = 'second_func_use' AND first_func IN ('retouch', 'edit') THEN concat('second_func_use_', second_func)
                WHEN event_id = 'edit_save' THEN concat('edit_save_', prf_first_func, '_', prf_second_func)
                WHEN event_id IN ('edit_enter') THEN event_id
                ELSE 'no_need'
            END AS event_name
        FROM (
            SELECT
                date_p
                ,gid
                ,event_id
                ,CAST(`time` / 1000 AS BIGINT) AS event_time
                ,params['page_name'] AS page_name
                ,params['first_func'] AS first_func
                ,params['second_func'] AS second_func
                ,params['third_func'] AS third_func
                ,params['prf_first_func'] AS prf_first_func
                ,params['prf_second_func'] AS prf_second_func
            FROM stat_sdk.sdk_odz_source_data
            WHERE date_p BETWEEN ${start_date} AND ${end_date}
                AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
                AND event_id IN (
                    'app_open_show'
                    ,'popup_show'
                    ,'popup_click'
                    ,'edit_enter'
                    ,'first_func_enter'
                    ,'second_func_enter'
                    ,'third_func_enter'
                    ,'first_func_use'
                    ,'second_func_use'
                    ,'edit_save'
                )
        ) t
    ) func
    ON u.gid = func.gid and u.date_p = func.date_p
        -- AND meitu_datediff(func.date_p, u.date_p) BETWEEN 0 AND 7
    WHERE func.event_name != 'no_need'
) seq
group by date_p
    ,gid
    ,paid_type
    ,is_retention_1
