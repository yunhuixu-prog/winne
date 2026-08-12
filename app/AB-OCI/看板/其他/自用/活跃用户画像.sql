set hive.exec.dynamic.partition.mode=nonstrict;
set hive.exec.max.dynamic.partitions=800;
set hive.exec.max.dynamic.partitions.pernode=800;

INSERT OVERWRITE TABLE stat_ab.filing_odz_active_user_profile PARTITION(date_p)

SELECT
    a.gid
    ,a.os_p os_type
    ,a.country
    ,a.is_new
    ,a.is_ua
    -- 当前是否订阅：活跃时间落在订单的开始和结束之间，非当天新订阅
    ,MAX(CASE WHEN a.date_p > o.pay_date  and a.date_p <= cast(o.invalid_date as bigint) THEN 1 ELSE 0 END) AS is_subscribed
    -- 历史订阅次数与金额
    ,SUM(CASE WHEN o.pay_date < a.date_p AND cur_pay_stage=1 and cur_pay_withhold_stage=0 THEN 1 ELSE 0 END) AS hist_trial_cnt
    ,SUM(CASE WHEN o.pay_date < a.date_p AND cur_pay_withhold_stage>=1 THEN 1 ELSE 0 END) AS hist_pay_cnt
    ,MIN(l.first_launch_date) as first_launch_date
    ,a.date_p
FROM (
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
) a
LEFT JOIN (
    select
        gid
        ,pay_date
        ,invalid_date
        ,period_type
        ,device_type as os_type
        ,nvl(country_name,'未知') country_code
        ,cur_pay_stage
        ,cur_pay_withhold_stage
        ,ord_amt_usd
    from stat_vip.paid_oda_all_order_summary
    where app_id_p IN (7329803307041000000)
        and pay_date <= ${end_time}
        and is_subscribe='订阅'
        and product_sub_line = 'AirBrush'
) o
ON a.gid = o.gid
left join (
    -- 安装时间
    select
        server_id as gid,min(first_launch_date) as first_launch_date
    from stat_sdk.sdk_oda_all_device_info
    where os_p in ('ios', 'android')
    and app_key_p in (
        '7F7023B6CEC7CDED'                -- Airbrush: Android
        , 'C851ED7164B6DF0F'              -- Airbrush: ios
    )
    and date_p = ${end_time}
    and server_id > 0
    group by server_id
) l 
on a.gid = l.gid
GROUP BY
    a.gid,
    a.date_p,
    a.os_p,
    a.country,
    a.is_new,
    a.is_ua