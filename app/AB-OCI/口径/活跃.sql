SELECT
        a.date_p,
        a.os_p,
        c.name AS country,
        a.final_id,
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