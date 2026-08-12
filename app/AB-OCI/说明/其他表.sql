-- 安装时间
select
        server_id as gid,min(first_launch_date) as first_launch_date,
        max(meitu_datediff(${day}, first_launch_date)) as first_active_days
    from stat_sdk.sdk_oda_all_device_info
    where os_p in ('ios', 'android')
    and app_key_p in (
        '7F7023B6CEC7CDED'                -- Airbrush: Android
        , 'C851ED7164B6DF0F'              -- Airbrush: ios
    )
    and date_p = ${day}
    and server_id > 0
    group by server_id