-- 活跃表，每一行代表一个用户在某一天的活跃情况
SELECT
    a.date_p, -- 日期
    a.os_p, -- 操作系统
    c.name AS country, -- 国家
    a.final_id, -- 用户标识id
    a.device_model, -- 设备型号
    a.brand, -- 品牌
    CASE WHEN new_device.final_id IS NOT NULL THEN 'New' ELSE 'Old' END AS is_new -- 是否新用户
FROM
(
    SELECT date_p, os_p, country_id, final_id, device_model, brand
    FROM stat_sdk.sdk_odz_active
    WHERE date_p BETWEEN ${start_date} AND ${end_date}
        AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
        AND os_p IS NOT NULL
) a
LEFT JOIN
-- 国家id关联国家名称
(
    SELECT DISTINCT id, name
    FROM stat_sdk.dim_rna_ip_location
    WHERE level='1' and date_p is not null
) c
ON a.country_id = c.id
LEFT JOIN
-- 关联新用户
(
    SELECT final_id, date_p
    FROM stat_sdk.sdk_odz_new_device_info
    WHERE date_p BETWEEN ${start_date} AND ${end_date}
        AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
        AND os_p IS NOT NULL
)new_device
ON a.final_id = new_device.final_id AND a.date_p = new_device.date_p

;
-- 省份城市
SELECT
    a.date_p, -- 日期
    a.os_p, -- 操作系统
    c.name AS province, -- 省份
    c.sdk_country_name AS country, -- 国家
    a.final_id, -- 用户标识id
    a.device_model, -- 设备型号
    a.brand, -- 品牌
    CASE WHEN new_device.final_id IS NOT NULL THEN 'New' ELSE 'Old' END AS is_new -- 是否新用户
FROM
(
    SELECT date_p, os_p, country_id, final_id, device_model, brand, province_id
    FROM stat_sdk.sdk_odz_active
    WHERE date_p BETWEEN 20260701 AND 20260731
        AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
        AND os_p IS NOT NULL
) a
LEFT JOIN
(
    SELECT DISTINCT id, name, sdk_country_id, sdk_country_name
    FROM stat_sdk.dim_rna_ip_location
    WHERE level='2' and date_p is not null -- level 1为国家 2为省份 3为城市
) c
ON a.province_id = c.id and a.country_id = c.sdk_country_id

