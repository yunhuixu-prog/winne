-- 有效会员数
set hive.exec.dynamic.partition.mode = nonstrict;
set hive.exec.dynamic.partition = true;
INSERT OVERWRITE TABLE stat_sdk.filing_amz_subscription_valid_users partition(business_line_p='airbrush', business_series_p='key_countries', date_p)
-- stat_ainancial.forcast_amz_subscription_valid_users -- 北斗表

SELECT nvl(country_name,'整体') AS business_unit 
       ,nvl(os_p,'整体')         AS compute_unit
       ,nvl(period_type,'整体')  AS period_type
       ,COUNT(distinct b.gid)  AS monthly_valid_cnt
       ,${start_time} date_p
FROM
(
	SELECT  country_name
	       ,concat(country_name,os_p)                                  AS os_p
	       ,period_type
	       ,gid
	FROM
	(
        select 
            device_type as os_p
            ,case when country_name in ('美国','英国','巴西','墨西哥','西班牙','加拿大','澳大利亚') then country_name
            else '其他' end as country_name
            ,gid
            ,concat('连续包',period_type) period_type
        from stat_vip.paid_oda_all_order_summary
        where app_id_p IN (7329803307041000000)
            and create_date <= ${end_time}
            and pay_date<=${end_time}
            and invalid_date >= ${start_time}
            and product_sub_line = 'AirBrush'
            and is_subscribe='订阅'
            AND cur_pay_withhold_stage >= 1 -- 剔除试用单
	) a
	GROUP BY  country_name
	         ,concat(country_name,os_p)
	         ,period_type
             ,gid
)b
GROUP BY  
         os_p
         ,country_name
         ,period_type
WITH CUBE