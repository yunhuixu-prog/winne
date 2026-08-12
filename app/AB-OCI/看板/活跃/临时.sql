SELECT
    CAST(d.date_p AS BIGINT) AS date_p,
    COUNT(DISTINCT d.final_id) AS mau,
    COUNT(DISTINCT n_next.final_id) AS next_month_retained
FROM
    (SELECT distinct final_id, os_p,
     FROM_UNIXTIME(UNIX_TIMESTAMP(CAST(date_p AS STRING),'yyyyMMdd'),'yyyyMM')  date_p
     FROM stat_sdk.sdk_odz_active
     WHERE date_p BETWEEN 20251201 AND 20251231
       AND app_key_p IN ('C851ED7164B6DF0F','7F7023B6CEC7CDED')
       AND os_p IS NOT NULL) d
LEFT JOIN
    (SELECT distinct final_id,
      FROM_UNIXTIME(UNIX_TIMESTAMP(CAST(date_p AS STRING),'yyyyMMdd'),'yyyyMM')  date_p

     FROM stat_sdk.sdk_odz_new_device_info
     WHERE date_p BETWEEN 20251201 AND 20251231
       AND app_key_p IN ('C851ED7164B6DF0F','7F7023B6CEC7CDED')
       AND os_p is not null) n
    ON d.final_id = n.final_id  AND d.date_p = n.date_p
LEFT JOIN
    (SELECT distinct final_id,
     FROM_UNIXTIME(UNIX_TIMESTAMP(CAST(date_p AS STRING),'yyyyMMdd'),'yyyyMM')  date_p
     FROM stat_sdk.sdk_odz_active
     WHERE date_p BETWEEN 20260101 AND 20260131
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
WHERE n.final_id IS NOT NULL
GROUP BY d.date_p