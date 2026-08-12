with dau as
(
    SELECT distinct d.final_id,d.country_id,d.is_ua
         ,d.date_m  date_p
         ,CASE WHEN n.final_id IS NOT NULL THEN 'New' ELSE 'Old' END is_new
         ,c.country
    FROM
    (
        SELECT distinct final_id,country_id,is_ua,date_p
           ,FROM_UNIXTIME(UNIX_TIMESTAMP(CAST(date_p AS STRING),'yyyyMMdd'),'yyyyMM') date_m
        FROM stat_sdk.sdk_odz_active
        WHERE date_p BETWEEN 20251101 AND 20260430
            AND app_key_p IN ('C851ED7164B6DF0F','7F7023B6CEC7CDED')
            AND os_p is not null
    ) d
    LEFT JOIN
    (
        SELECT distinct final_id,date_p
        FROM stat_sdk.sdk_odz_new_device_info
        WHERE date_p BETWEEN 20251101 AND 20260430
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



SELECT months
     ,case when country in ('美国','巴西','英国','墨西哥','西班牙','加拿大','澳大利亚') then country
            else '其他'
            end country
     ,sum(mau) mau
     ,sum(mnu) mnu
     ,sum(mau_non_organic) mau_non_organic
     ,sum(mau_organic) mau_organic
     ,sum(mnu_non_organic) mnu_non_organic
     ,sum(mnu_organic) mnu_organic
     ,sum(pre_mnu) pre_mnu
     ,sum(pre_mnu_non_organic) pre_mnu_non_organic
     ,sum(pre_mnu_organic) pre_mnu_organic
     ,sum(pre_mou) pre_mou
     ,sum(huiliu) huiliu
FROM (
SELECT
    d.date_p months
    ,d.country
    ,COUNT(DISTINCT d.final_id) AS mau
    ,COUNT(DISTINCT CASE WHEN d.is_new='New' THEN d.final_id END) AS mnu
    ,COUNT(DISTINCT CASE WHEN d.is_ua='non-Organic' THEN d.final_id END) AS mau_non_organic
    ,COUNT(DISTINCT CASE WHEN d.is_ua='Organic' THEN d.final_id END) AS mau_organic
    ,COUNT(DISTINCT CASE WHEN d.is_ua='non-Organic' and d.is_new='New' THEN d.final_id END) AS mnu_non_organic
    ,COUNT(DISTINCT CASE WHEN d.is_ua='Organic' and d.is_new='New' THEN d.final_id END) AS mnu_organic

    ,COUNT(DISTINCT CASE WHEN d.is_new='Old' and pre.is_new='New' THEN d.final_id END) AS pre_mnu
    ,COUNT(DISTINCT CASE WHEN d.is_new='Old' and pre.is_ua='non-Organic' and pre.is_new='New' THEN d.final_id END) AS pre_mnu_non_organic
    ,COUNT(DISTINCT CASE WHEN d.is_new='Old' and pre.is_ua='Organic' and pre.is_new='New' THEN d.final_id END) AS pre_mnu_organic
    ,COUNT(DISTINCT CASE WHEN d.is_new='Old' and pre.is_new='Old' THEN d.final_id END) AS pre_mou
    ,COUNT(DISTINCT CASE WHEN d.is_new='Old' and pre.final_id is null THEN d.final_id END) AS huiliu
FROM
(
    SELECT date_p,final_id,country,MAX(is_ua) is_ua,MIN(is_new) is_new -- 有一天是渠道/新用户就算该月是渠道/新用户
    FROM dau
    WHERE date_p >= date_format(add_months(from_unixtime(unix_timestamp(cast(20251101 AS STRING), 'yyyyMMdd')),1),'yyyyMM')
    group by date_p,final_id,country
) d
LEFT JOIN
(
    SELECT date_p,final_id,MAX(is_ua) is_ua,MIN(is_new) is_new -- 上个月有一天是渠道/新用户就算
    FROM dau
    GROUP BY date_p,final_id
) pre
ON d.final_id = pre.final_id
and d.date_p = date_format(add_months(from_unixtime(unix_timestamp(concat(pre.date_p, '01'), 'yyyyMMdd')),1),'yyyyMM')
GROUP BY
    d.date_p,
    d.country
) p
GROUP BY
    months,
    case when country in ('美国','巴西','英国','墨西哥','西班牙','加拿大','澳大利亚') then country
            else '其他'
            end

union all

SELECT
    d.date_p months
    ,'整体' country
    ,COUNT(DISTINCT d.final_id) AS mau
    ,COUNT(DISTINCT CASE WHEN d.is_new='New' THEN d.final_id END) AS mnu
    ,COUNT(DISTINCT CASE WHEN d.is_ua='non-Organic' THEN d.final_id END) AS mau_non_organic
    ,COUNT(DISTINCT CASE WHEN d.is_ua='Organic' THEN d.final_id END) AS mau_organic

    ,COUNT(DISTINCT CASE WHEN d.is_ua='non-Organic' and d.is_new='New' THEN d.final_id END) AS mnu_non_organic
    ,COUNT(DISTINCT CASE WHEN d.is_ua='Organic' and d.is_new='New' THEN d.final_id END) AS mnu_organic

    ,COUNT(DISTINCT CASE WHEN d.is_new='Old' and pre.is_new='New' THEN d.final_id END) AS pre_mnu
    ,COUNT(DISTINCT CASE WHEN d.is_new='Old' and pre.is_ua='non-Organic' and pre.is_new='New' THEN d.final_id END) AS pre_mnu_non_organic
    ,COUNT(DISTINCT CASE WHEN d.is_new='Old' and pre.is_ua='Organic' and pre.is_new='New' THEN d.final_id END) AS pre_mnu_organic
    ,COUNT(DISTINCT CASE WHEN d.is_new='Old' and pre.is_new='Old' THEN d.final_id END) AS pre_mou
    ,COUNT(DISTINCT CASE WHEN d.is_new='Old' and pre.final_id is null THEN d.final_id END) AS huiliu
FROM
(
    SELECT date_p,final_id,MAX(is_ua) is_ua,MIN(is_new) is_new -- 有一天是渠道/新用户就算
    FROM dau
    WHERE date_p >= date_format(add_months(from_unixtime(unix_timestamp(cast(20251101 AS STRING), 'yyyyMMdd')),1),'yyyyMM')
    group by date_p,final_id
) d
LEFT JOIN
(
    SELECT date_p,final_id,MAX(is_ua) is_ua,MIN(is_new) is_new -- 上个月有一天是渠道/新用户就算
    FROM dau
    GROUP BY date_p,final_id
) pre
ON d.final_id = pre.final_id
and d.date_p = date_format(add_months(from_unixtime(unix_timestamp(concat(pre.date_p, '01'), 'yyyyMMdd')),1),'yyyyMM')
GROUP BY
    d.date_p

-- ;

-- SELECT FROM_UNIXTIME(UNIX_TIMESTAMP(CAST(date_p AS STRING),'yyyyMMdd'),'yyyyMM')  date_p
--      ,count(distinct final_id) uv_gid
--      -- ,count(distinct firebase_id) uv_fire
--      ,count(distinct idfa) uv_idfa
--      ,count(distinct android_id) uv_android
--      ,count(case when os_p='ios' then 1 end) pv_ios
--      ,count(case when os_p='ios' and (idfa is null or idfa='') then 1 end) pv_no_idfa
--      ,count(case when os_p='android' then 1 end) pv_android
--      ,count(case when os_p='android' and (android_id is null or android_id='') then 1 end) pv_no_android
--         FROM stat_sdk.sdk_odz_active
--         WHERE date_p BETWEEN 20251201 AND 20260228
--             AND app_key_p IN ('C851ED7164B6DF0F','7F7023B6CEC7CDED')
--             AND os_p is not null
-- group by FROM_UNIXTIME(UNIX_TIMESTAMP(CAST(date_p AS STRING),'yyyyMMdd'),'yyyyMM')
