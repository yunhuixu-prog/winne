-- 整体指标
set hive.exec.dynamic.partition.mode = nonstrict;
set hive.exec.dynamic.partition = true;
INSERT OVERWRITE TABLE stat_sdk.filing_amz_overview_metrics partition(business_line_p='airbrush', business_series_p='key_countries', date_p)
-- stat_ainancial.forcast_amz_overview_metrics -- 北斗表

SELECT  country_name         AS business_unit
       ,os_p                 AS compute_unit
       ,mau                  AS mau
       ,mau-nvl(valid_mau,0) AS non_member_mau
       ,'0' revenue_share_rate
       ,${start_time} date_p
FROM
(
	SELECT  nvl(os_p,'整体')            AS os_p
	       ,nvl(country_name,'整体')    AS country_name
	       ,COUNT(distinct final_id) AS mau
	       ,COUNT(distinct gid)       AS valid_mau
	FROM
	(
		SELECT  concat(t1.country_name,t1.os_p) AS os_p
		       ,t1.country_name
		       ,t1.final_id
		       ,t2.gid
		FROM
		( -- MAU
			SELECT
                a.os_p
                ,case when c.name in ('美国','英国','巴西','墨西哥','西班牙','加拿大','澳大利亚') then c.name
                    else '其他' end as country_name
                ,a.final_id
                ,a.server_id
            FROM
            (
                SELECT date_p, os_p, country_id, final_id, server_id
                FROM stat_sdk.sdk_odz_active
                WHERE date_p BETWEEN ${start_time} AND ${end_time}
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
		) t1
		LEFT JOIN
		( -- 非会员MAU = MAU-会员不可新增且活跃的MAU
			SELECT  os_p
			       ,gid
			       ,country_name
			FROM
			(
                select 
                    device_type as os_p
                    ,case when country_name in ('美国','英国','巴西','墨西哥','西班牙','加拿大','澳大利亚') then country_name
                    else '其他' end as country_name
                    ,gid
                from stat_vip.paid_oda_all_order_summary
                where app_id_p IN (7329803307041000000)
                    and create_date < ${start_time}
                    and invalid_date >= ${start_time}
                    and product_sub_line = 'AirBrush'
                    and is_subscribe='订阅'
                    AND cur_pay_withhold_stage >= 1
			) a
			GROUP BY  os_p
			         ,gid
			         ,country_name
		) t2
		ON t1.server_id = t2.gid AND t1.country_name = t2.country_name AND t1.os_p = t2.os_p
		GROUP BY  concat(t1.country_name,t1.os_p)
		         ,t1.country_name
		         ,t1.final_id
		         ,t2.gid
	) p
	GROUP BY  os_p
	         ,country_name
	WITH CUBE
) mau