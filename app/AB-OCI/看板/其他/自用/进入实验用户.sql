set hive.exec.dynamic.partition.mode=nonstrict;
set hive.exec.max.dynamic.partitions=800;
set hive.exec.max.dynamic.partitions.pernode=800;

INSERT OVERWRITE TABLE stat_ab.filing_odz_abtest_active_user PARTITION(date_p)


select
    fa.gid
    ,case when fa.os_p = 'ios' then 'iOS'
        when fa.os_p = 'android' then 'Android'
        else 'unknow' end as os_type
    ,fa.country,fa.is_new,fa.is_ua
    ,e.ab_code,e.event_timestamp
    ,e.enter_abtest_date date_p
from (
    SELECT
        a.date_p,
        a.os_p,
        c.name AS country,a.is_ua,
        a.final_id gid,
        CASE WHEN new_device.final_id IS NOT NULL THEN 'New' ELSE 'Old' END AS is_new
    FROM
    (
        SELECT date_p, os_p, country_id, final_id, is_ua
        FROM stat_sdk.sdk_odz_active
        WHERE date_p BETWEEN ${start_time} and ${end_time}
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
        WHERE date_p BETWEEN ${start_time} and ${end_time}
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
    WHERE date_p between ${start_time} and ${end_time}
        AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
        AND event_id = 'abcode_enter_test'
        -- AND params['current_abcode'] in ('29019','29020','28956','28957')
) e ON e.gid = fa.gid and e.enter_abtest_date = fa.date_p
where e.gid is not null
