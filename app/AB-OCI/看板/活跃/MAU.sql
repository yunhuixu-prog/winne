  set hive.exec.dynamic.partition.mode=nonstrict;
   set hive.exec.max.dynamic.partitions=800;
  set hive.exec.max.dynamic.partitions.pernode=800;

  INSERT OVERWRITE TABLE stat_ab.filing_adz_month_retention2  PARTITION(date_p)
  
  SELECT
    COALESCE(os_p,'整体') AS os_p,
     country,
    COALESCE(is_new,'整体') AS is_new,
    COALESCE(is_ua,'整体') AS is_ua,

     sum(mau) AS mau,
    sum(next_month_retained) AS next_month_retained ,
    date_p
   from(

SELECT
    COALESCE(d.os_p,'unknow') AS os_p,
    COALESCE(c.country,'unknow') AS country,
    COALESCE(CASE WHEN n.final_id IS NOT NULL THEN 'New' ELSE 'Old' END,'unknow') AS is_new,
    COALESCE(d.is_ua,'unknow') AS is_ua,

    COUNT(DISTINCT d.final_id) AS mau,
    COUNT(DISTINCT n_next.final_id) AS next_month_retained ,

   CAST(d.date_p AS BIGINT) AS date_p
FROM
    (SELECT final_id, os_p, country_id, 
     FROM_UNIXTIME(UNIX_TIMESTAMP(CAST(date_p AS STRING),'yyyyMMdd'),'yyyyMM')  date_p,
     max(is_ua) is_ua
     FROM stat_sdk.sdk_odz_active
     WHERE date_p BETWEEN ${start_date} AND ${end_date}
       AND app_key_p IN ('C851ED7164B6DF0F','7F7023B6CEC7CDED')
       AND os_p IS NOT NULL
    group by final_id, os_p, country_id,
     FROM_UNIXTIME(UNIX_TIMESTAMP(CAST(date_p AS STRING),'yyyyMMdd'),'yyyyMM')) d
LEFT JOIN
    (SELECT distinct id AS country_id, name AS country
     FROM stat_sdk.dim_rna_ip_location
     WHERE level='1' and date_p is not null) c
    ON d.country_id = c.country_id
LEFT JOIN
    (SELECT distinct final_id,country_id,
      FROM_UNIXTIME(UNIX_TIMESTAMP(CAST(date_p AS STRING),'yyyyMMdd'),'yyyyMM')  date_p

     FROM stat_sdk.sdk_odz_new_device_info
     WHERE date_p BETWEEN ${start_date} AND ${end_date}
       AND app_key_p IN ('C851ED7164B6DF0F','7F7023B6CEC7CDED')
       AND os_p is not null) n
    ON d.final_id = n.final_id  AND d.date_p = n.date_p AND d.country_id = n.country_id
LEFT JOIN
    (SELECT distinct final_id,
     FROM_UNIXTIME(UNIX_TIMESTAMP(CAST(date_p AS STRING),'yyyyMMdd'),'yyyyMM')  date_p
     FROM stat_sdk.sdk_odz_active
     WHERE date_p BETWEEN ${start_date} AND ${end_date}
       AND app_key_p IN ('C851ED7164B6DF0F','7F7023B6CEC7CDED')
       AND os_p is not null) n_next
    ON d.final_id = n_next.final_id
and n_next.date_p = date_format(
  add_months(
    from_unixtime(unix_timestamp(concat(d.date_p, '01'), 'yyyyMMdd')),
    1
  ),
  'yyyyMM'
)
GROUP BY
    d.os_p,
    c.country,
    CASE WHEN n.final_id IS NOT NULL THEN 'New' ELSE 'Old' END,
    d.is_ua,
    d.date_p
   ) as aa group by os_p,country,is_new,is_ua,date_p  with cube -- having date_p IS NOT NULL
   
   union ALL
   select os_p,'整体' as country,is_new, is_ua,mau, next_month_retained , date_p
from(
 SELECT 
     COALESCE(os_p,'整体') AS os_p,
    COALESCE(is_new,'整体') AS is_new,
    COALESCE(is_ua,'整体') AS is_ua,

    sum(mau) AS mau,
    sum(next_month_retained) AS next_month_retained ,
    date_p
    from(
SELECT
    COALESCE(d.os_p,'unknow') AS os_p,
    COALESCE(CASE WHEN n.final_id IS NOT NULL THEN 'New' ELSE 'Old' END,'unknow') AS is_new,
    COALESCE(d.is_ua,'unknow') AS is_ua,

    COUNT(DISTINCT d.final_id) AS mau,
    COUNT(DISTINCT n_next.final_id) AS next_month_retained ,
   CAST(d.date_p AS BIGINT) AS date_p
FROM
    (SELECT final_id, os_p, 
     FROM_UNIXTIME(UNIX_TIMESTAMP(CAST(date_p AS STRING),'yyyyMMdd'),'yyyyMM')  date_p
     , max(is_ua) is_ua
     FROM stat_sdk.sdk_odz_active
     WHERE date_p BETWEEN ${start_date} AND ${end_date}
       AND app_key_p IN ('C851ED7164B6DF0F','7F7023B6CEC7CDED')
       AND os_p IS NOT NULL
    group by final_id, os_p,
     FROM_UNIXTIME(UNIX_TIMESTAMP(CAST(date_p AS STRING),'yyyyMMdd'),'yyyyMM') ) d

LEFT JOIN
    (SELECT distinct final_id,
      FROM_UNIXTIME(UNIX_TIMESTAMP(CAST(date_p AS STRING),'yyyyMMdd'),'yyyyMM')  date_p
     FROM stat_sdk.sdk_odz_new_device_info
     WHERE date_p BETWEEN ${start_date} AND ${end_date}
       AND app_key_p IN ('C851ED7164B6DF0F','7F7023B6CEC7CDED')
       AND os_p is not null) n
    ON d.final_id = n.final_id  AND d.date_p = n.date_p 
LEFT JOIN
    (SELECT distinct final_id,
     FROM_UNIXTIME(UNIX_TIMESTAMP(CAST(date_p AS STRING),'yyyyMMdd'),'yyyyMM')  date_p
     FROM stat_sdk.sdk_odz_active
     WHERE date_p BETWEEN ${start_date} AND ${end_date}
       AND app_key_p IN ('C851ED7164B6DF0F','7F7023B6CEC7CDED')
       AND os_p is not null) n_next
    ON d.final_id = n_next.final_id
and n_next.date_p = date_format(
  add_months(
    from_unixtime(unix_timestamp(concat(d.date_p, '01'), 'yyyyMMdd')),
    1
  ),
  'yyyyMM'
)
GROUP BY
    d.os_p,
    CASE WHEN n.final_id IS NOT NULL THEN 'New' ELSE 'Old' END,
    d.is_ua,
    d.date_p
) AS base
group by os_p,is_new,is_ua,date_p
with cube
-- having date_p IS NOT NULL
  )a

