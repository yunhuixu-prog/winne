select
    -- a.date_p,
    a.os_type os_type
    ,case when b.ab_code in ('29019','28956') then '对照组'
        when b.ab_code in ('29020','28957') then '实验组A'
        end code
    ,b.is_new is_new
    ,a.event_id event_id
    ,case when a.content in ('1','2','3','null','straight','question','trial_7','promotional') or a.content is null then a.content
    else 'others' end content
    ,a.strategy_name strategy_name
    ,b.is_onboarding is_onboarding
    ,count(distinct a.gid) uv
from (
    SELECT date_p,event_id
        ,CAST(`time`/1000 AS bigint) event_timestamp
        ,sdk_type os_type,gid
        ,params['content'] content
        ,params['strategy_name'] strategy_name
    FROM stat_sdk.sdk_odz_source_data
    WHERE date_p between 20260525 and 20260621
        AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
        AND event_id in ('question_pop_show','question_pop_submit','question_proplan_show','question_pop_sub_success'
        ,'strategy_popup_show','strategy_popup_click','strategy_popup_sub_success','edit_save')
) a
join (
    select *
    from
    (
        select
            fa.gid,fa.os_p os_type,fa.country,fa.is_new
            ,e.ab_code,e.enter_abtest_date,e.event_timestamp
            ,if(o.gid is not null,1,0) is_onboarding
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
                WHERE date_p BETWEEN 20260525 and 20260621
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
                WHERE date_p BETWEEN 20260525 and 20260621
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
            WHERE date_p between 20260525 and 20260621
                AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
                AND event_id = 'abcode_enter_test'
                AND params['current_abcode'] in ('29019','29020','28956','28957')
        ) e ON e.gid = fa.gid and e.enter_abtest_date = fa.date_p
        left join (
            SELECT distinct date_p
                ,gid
            FROM stat_sdk.sdk_odz_source_data
            WHERE date_p between 20260525 and 20260621
                AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
                AND event_id = 'enter_onboarding'
        ) o ON o.gid = fa.gid and o.date_p = e.enter_abtest_date
        where e.gid is not null
    ) t
    where ranks=1
) b
on a.gid= b.gid
where b.event_timestamp-15 <= a.event_timestamp
    -- and b.enter_abtest_date = a.date_p
group by a.os_type,case when b.ab_code in ('29019','28956') then '对照组'
        when b.ab_code in ('29020','28957') then '实验组A'
        end
        ,b.is_new
        ,a.event_id,case when a.content in ('1','2','3','null','straight','question','trial_7','promotional') or a.content is null then a.content
    else 'others' end
    ,a.strategy_name
    ,b.is_onboarding