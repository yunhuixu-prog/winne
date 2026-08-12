set hive.exec.dynamic.partition.mode=nonstrict;
set hive.exec.max.dynamic.partitions=800;
set hive.exec.max.dynamic.partitions.pernode=800;

-- 多跑一个月
with active as
(
    SELECT distinct d.final_id,d.country_id,d.is_ua,d.os_p,d.date_m date_p
         ,CASE WHEN n.final_id IS NOT NULL THEN 'New' ELSE 'Old' END is_new
         ,c.country
    FROM
    (
        SELECT distinct final_id,country_id,is_ua,os_p,date_p
            ,FROM_UNIXTIME(UNIX_TIMESTAMP(CAST(date_p AS STRING),'yyyyMMdd'),'yyyyMM')  date_m
        FROM stat_sdk.sdk_odz_active
        WHERE date_p BETWEEN ${start_date} AND ${end_date}
            AND app_key_p IN ('C851ED7164B6DF0F','7F7023B6CEC7CDED')
            AND os_p is not null
    -- cast(date_format(add_months(from_unixtime(unix_timestamp(cast(${start_date} AS STRING), 'yyyyMMdd')),-1),'yyyyMMdd') as bigint)
    ) d
    LEFT JOIN
    (
        SELECT distinct final_id,date_p
        FROM stat_sdk.sdk_odz_new_device_info
        WHERE date_p BETWEEN ${start_date} AND ${end_date}
            AND app_key_p IN ('C851ED7164B6DF0F','7F7023B6CEC7CDED')
            AND os_p is not null
    ) n
    ON d.final_id = n.final_id  AND d.date_p = n.date_p
    LEFT JOIN
    (
        SELECT distinct id AS country_id, name AS country
        FROM stat_sdk.dim_rna_ip_location
        WHERE level='1' and date_p is not null
    ) c
    ON d.country_id = c.country_id
)

INSERT OVERWRITE TABLE stat_ab.filing_adz_month_mau_split  PARTITION(date_p)

SELECT
     country
     ,COALESCE(os_p,'整体') AS os_p
     ,sum(mau) mau
     ,sum(mnu) mnu
     ,sum(mau_non_organic) mau_non_organic
     ,sum(mau_organic) mau_organic
     ,sum(mnu_non_organic) mnu_non_organic
     ,sum(mnu_organic) mnu_organic
     ,sum(pre_mnu_non_organic) pre_mnu_non_organic
     ,sum(pre_mnu_organic) pre_mnu_organic
     ,sum(pre_mou) pre_mou
     ,sum(huiliu) huiliu
     ,date_p
FROM
(
SELECT
    COALESCE(d.country,'unknow') AS country
    ,COALESCE(d.os_p,'unknow') AS os_p
    ,COUNT(DISTINCT d.final_id) AS mau
    ,COUNT(DISTINCT CASE WHEN d.is_new='New' THEN d.final_id END) AS mnu
    ,COUNT(DISTINCT CASE WHEN d.is_ua='non-Organic' THEN d.final_id END) AS mau_non_organic
    ,COUNT(DISTINCT CASE WHEN d.is_ua='Organic' THEN d.final_id END) AS mau_organic
    ,COUNT(DISTINCT CASE WHEN d.is_ua='non-Organic' and d.is_new='New' THEN d.final_id END) AS mnu_non_organic
    ,COUNT(DISTINCT CASE WHEN d.is_ua='Organic' and d.is_new='New' THEN d.final_id END) AS mnu_organic

    ,COUNT(DISTINCT CASE WHEN d.is_new='Old' and pre.is_ua='non-Organic' and pre.is_new='New' THEN d.final_id END) AS pre_mnu_non_organic
    ,COUNT(DISTINCT CASE WHEN d.is_new='Old' and pre.is_ua='Organic' and pre.is_new='New' THEN d.final_id END) AS pre_mnu_organic
    ,COUNT(DISTINCT CASE WHEN d.is_new='Old' and pre.is_new='Old' THEN d.final_id END) AS pre_mou
    ,COUNT(DISTINCT CASE WHEN d.is_new='Old' and pre.final_id is null THEN d.final_id END) AS huiliu

    ,CAST(d.date_p AS BIGINT) date_p
FROM
(
    SELECT date_p,final_id,country,os_p,MAX(is_ua) is_ua,MIN(is_new) is_new -- 有一天是渠道/新用户就算该月是渠道/新用户
    FROM active
    WHERE date_p >= date_format(add_months(from_unixtime(unix_timestamp(cast(${start_date} AS STRING), 'yyyyMMdd')),1),'yyyyMM')
    group by date_p,final_id,country,os_p
) d
LEFT JOIN
(
    SELECT date_p,final_id,MAX(is_ua) is_ua,MIN(is_new) is_new -- 上个月有一天是渠道/新用户就算
    FROM active
    GROUP BY date_p,final_id
) pre
ON d.final_id = pre.final_id
and d.date_p = date_format(add_months(from_unixtime(unix_timestamp(concat(pre.date_p, '01'), 'yyyyMMdd')),1),'yyyyMM')
GROUP BY
    d.date_p,
    d.country,
    d.os_p
) s
GROUP BY date_p,country,os_p with cube
having date_p IS NOT NULL and country IS NOT NULL


union all
-- 整体对国家去重
SELECT
     '整体' country
     ,COALESCE(os_p,'整体') AS os_p
     ,sum(mau) mau
     ,sum(mnu) mnu
     ,sum(mau_non_organic) mau_non_organic
     ,sum(mau_organic) mau_organic
     ,sum(mnu_non_organic) mnu_non_organic
     ,sum(mnu_organic) mnu_organic
     ,sum(pre_mnu_non_organic) pre_mnu_non_organic
     ,sum(pre_mnu_organic) pre_mnu_organic
     ,sum(pre_mou) pre_mou
     ,sum(huiliu) huiliu
     ,date_p
FROM
(
SELECT
    COALESCE(d.os_p,'unknow') AS os_p
    ,COUNT(DISTINCT d.final_id) AS mau
    ,COUNT(DISTINCT CASE WHEN d.is_new='New' THEN d.final_id END) AS mnu
    ,COUNT(DISTINCT CASE WHEN d.is_ua='non-Organic' THEN d.final_id END) AS mau_non_organic
    ,COUNT(DISTINCT CASE WHEN d.is_ua='Organic' THEN d.final_id END) AS mau_organic

    ,COUNT(DISTINCT CASE WHEN d.is_ua='non-Organic' and d.is_new='New' THEN d.final_id END) AS mnu_non_organic
    ,COUNT(DISTINCT CASE WHEN d.is_ua='Organic' and d.is_new='New' THEN d.final_id END) AS mnu_organic

    ,COUNT(DISTINCT CASE WHEN d.is_new='Old' and pre.is_ua='non-Organic' and pre.is_new='New' THEN d.final_id END) AS pre_mnu_non_organic
    ,COUNT(DISTINCT CASE WHEN d.is_new='Old' and pre.is_ua='Organic' and pre.is_new='New' THEN d.final_id END) AS pre_mnu_organic
    ,COUNT(DISTINCT CASE WHEN d.is_new='Old' and pre.is_new='Old' THEN d.final_id END) AS pre_mou
    ,COUNT(DISTINCT CASE WHEN d.is_new='Old' and pre.final_id is null THEN d.final_id END) AS huiliu

    ,CAST(d.date_p AS BIGINT) date_p
FROM
(
    SELECT date_p,final_id,os_p,MAX(is_ua) is_ua,MIN(is_new) is_new -- 有一天是渠道/新用户就算
    FROM active
    WHERE date_p >= date_format(add_months(from_unixtime(unix_timestamp(cast(${start_date} AS STRING), 'yyyyMMdd')),1),'yyyyMM')
    group by date_p,final_id,os_p
) d
LEFT JOIN
(
    SELECT date_p,final_id,MAX(is_ua) is_ua,MIN(is_new) is_new -- 上个月有一天是渠道/新用户就算
    FROM active
    GROUP BY date_p,final_id
) pre
ON d.final_id = pre.final_id
and d.date_p = date_format(add_months(from_unixtime(unix_timestamp(concat(pre.date_p, '01'), 'yyyyMMdd')),1),'yyyyMM')
GROUP BY
    d.date_p,d.os_p
) s
GROUP BY date_p,os_p with cube
having date_p IS NOT NULL


