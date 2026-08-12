set hive.exec.dynamic.partition.mode=nonstrict;
set hive.exec.max.dynamic.partitions =500;
set hive.exec.max.dynamic.partitions.pernode=500;
WITH
dau_tmp AS (
    SELECT
        a.date_p,
        a.os_p,
        c.name AS country,
        a.final_id,
        CASE WHEN new_device.final_id IS NOT NULL THEN 'New' ELSE 'Old' END AS is_new
    FROM
  ( SELECT date_p, os_p, country_id, final_id
      FROM stat_sdk.sdk_odz_active
      WHERE date_p BETWEEN ${start_date} AND ${end_date}
        AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
        AND os_p IS NOT NULL) a
    LEFT JOIN
  ( SELECT DISTINCT id, name
      FROM stat_sdk.dim_rna_ip_location
      WHERE level='1' and date_p is not null) c

    ON a.country_id = c.id
    LEFT JOIN (SELECT final_id, date_p
    FROM stat_sdk.sdk_odz_new_device_info
    WHERE date_p BETWEEN ${start_date} AND ${end_date}
      AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
      AND os_p IS NOT NULL)new_device

        ON a.final_id = new_device.final_id AND a.date_p = new_device.date_p

),
r1 AS (
    SELECT
        CAST(FROM_UNIXTIME(UNIX_TIMESTAMP(CAST(date_p AS STRING), 'yyyyMMdd') - 86400, 'yyyyMMdd') AS BIGINT) AS date_p,
        final_id
    FROM dau_tmp
),
r7 AS (
    SELECT
        CAST(FROM_UNIXTIME(UNIX_TIMESTAMP(CAST(date_p AS STRING), 'yyyyMMdd') - 7*86400, 'yyyyMMdd') AS BIGINT) AS date_p,
        final_id
    FROM dau_tmp
),
r30 AS (
    SELECT
        CAST(FROM_UNIXTIME(UNIX_TIMESTAMP(CAST(date_p AS STRING), 'yyyyMMdd') - 30*86400, 'yyyyMMdd') AS BIGINT) AS date_p,
        final_id
    FROM dau_tmp
)

INSERT OVERWRITE TABLE stat_ab.filing_adz_active_retention PARTITION(date_p)

SELECT
    COALESCE(os_p,'整体') AS os_p,
    COALESCE(country,'整体') AS country,
    COALESCE(is_new,'整体') AS is_new,
    sum(dau)AS dau,
    sum(r1)AS r1,
    sum(r7)AS r7,
    sum(r30)AS r30,
    date_p
    from(
SELECT
    COALESCE(d.os_p,'unknow') AS os_p,
    COALESCE(d.country,'unknow') AS country,
    COALESCE(d.is_new,'unknow') AS is_new,
    COUNT(DISTINCT d.final_id) AS dau,
    COUNT(DISTINCT r1.final_id) AS r1,
    COUNT(DISTINCT r7.final_id) AS r7,
    COUNT(DISTINCT r30.final_id) AS r30,
    d.date_p
FROM (select * from dau_tmp) d
LEFT JOIN (select * from r1) r1 ON d.final_id = r1.final_id AND d.date_p = r1.date_p
LEFT JOIN (select * from r7) r7 ON d.final_id = r7.final_id AND d.date_p = r7.date_p
LEFT JOIN (select * from r30) r30 ON d.final_id = r30.final_id AND d.date_p = r30.date_p
GROUP BY d.date_p, d.os_p, d.country, d.is_new)AS base
GROUP BY date_p, os_p, country, is_new
WITH CUBE
HAVING date_p IS NOT NULL;
