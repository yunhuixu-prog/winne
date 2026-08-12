select final_id,min(first_launch_date) first_launch_date
    from stat_sdk.sdk_oda_all_device_info
    where
        date_p = 20260331
        and app_key_p in ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
        and os_p IS NOT NULL
    group by final_id