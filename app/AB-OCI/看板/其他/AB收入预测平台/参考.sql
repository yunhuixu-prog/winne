--- 订阅数据

set hive.exec.dynamic.partition.mode = nonstrict;
set hive.exec.dynamic.partition = true;
INSERT OVERWRITE TABLE stat_ainancial.forcast_amz_subscription_orders partition(business_line_p='mtxx', business_series_p='key_countries', date_p)

-- 由于是月维度数据，连续包周SKU需要特殊处理使用order_id 来统计订单数，使用合约订单数会导致收入不准确

SELECT  business_unit
       ,compute_unit
       ,period_type
       ,days
       ,nvl(gmv_new,0)                                                                                        AS new_sub_amt_net_incl_refund
       ,nvl(gmv_new,0)-nvl(refund_amount_new,0)                                                               AS new_sub_amt_net_excl_refund
       ,nvl(gmv_total_new,0)                                                                                  AS new_sub_amt_gross_incl_refund
       ,nvl(nvl(gmv_total_new,0)-(nvl(refund_amount_new,0)/(nvl(gmv_new,0)/nvl(gmv_total_new,0))),0)          AS new_sub_amt_gross_excl_refund
       ,nvl(gmv_renewal,0)                                                                                    AS renewal_sub_amt_net_incl_refund
       ,nvl(gmv_renewal,0)-nvl(refund_amount_renewal,0)                                                       AS renewal_sub_amt_net_excl_refund
       ,nvl(gmv_total_renewal,0)                                                                              AS renewal_sub_amt_gross_incl_refund
       ,nvl(nvl(gmv_total_renewal,0)-(nvl(refund_amount_renewal,0)/(nvl(gmv_renewal,0)/nvl(gmv_total_renewal,1))),0) AS renewal_sub_amt_gross_excl_refund
       ,nvl(new_sub_orders,0)                                                                                 AS new_sub_orders
       ,nvl(renewal_sub_orders,0)                                                                             AS renewal_sub_orders
       ,${start_time}                                                                                         AS date_p
FROM
(
	SELECT  nvl(country_name,'整体')                                         AS business_unit
	       ,nvl(os_p,'整体')                                                 AS compute_unit
	       ,nvl(period_type,'整体')                                          AS period_type
	       ,nvl(days,'整体')                                                 AS days
	       ,SUM(if(type_gmv = '新增',gmv,0))                                 AS gmv_new
	       ,SUM(if(type_gmv = '新增',refund_amount,0))                       AS refund_amount_new
	       ,SUM(if(type_gmv = '新增',gmv_total,0))                           AS gmv_total_new
	       ,SUM(if(type_gmv = '续费',gmv,0))                                 AS gmv_renewal
	       ,SUM(if(type_gmv = '续费',refund_amount,0))                       AS refund_amount_renewal
	       ,SUM(if(type_gmv = '续费',gmv_total,0))                           AS gmv_total_renewal
	       ,COUNT(distinct if(cur_pay_withhold_stage = 1,out_pay_id,null)) AS new_sub_orders
	       ,COUNT(distinct if(cur_pay_withhold_stage > 1,out_pay_id,null)) AS renewal_sub_orders
	FROM
	(
		SELECT  a.country_name
		       ,concat(a.country_name,a.os_type1) AS os_p
		       ,period_type
		       ,type_gmv
		       ,cur_pay_withhold_stage
		       ,days
		       ,out_pay_id
		       ,SUM(gmv)                          AS gmv
		       ,SUM(gmv_total)                    AS gmv_total
		       ,SUM(refund_amount)                AS refund_amount
		FROM
		( -- 收 入
			SELECT  CASE WHEN country_name IN ('中国') THEN '中国大陆'
			             WHEN country_name IN ('中国香港','中国澳门') THEN '香港+澳门'
			             WHEN country_name IN ('中国台湾','泰国','美国','日本','韩国','越南') THEN country_name
                         WHEN country_name IN ('印度尼西亚') THEN '印尼'  ELSE '海外其他' END            AS country_name
			       ,CASE WHEN os_type1 IN ('android','google') THEN 'Android'
			             WHEN os_type1 = 'ios' THEN 'iOS'
			             WHEN os_type1 = 'harmony' THEN 'Harmony'  ELSE 'other' END                                                   AS os_type1
			       ,CASE WHEN product_type = 2 AND period_type1 IN ('月','季','年','周') THEN concat('连续包',period_type1)
			             WHEN product_type = 2 THEN '续期其他SKU'
			             WHEN product_type != 2 AND period_type1 IN ('月','季','年','周') THEN concat('包',period_type1)  ELSE '其他SKU' END AS period_type
			       ,CASE WHEN os_type1 != 'ios' or product_type != 2 THEN '不区分'
			             WHEN os_type1 = 'ios' AND product_type = 2 AND days <= 365 or days is null THEN '一年以内'
			             WHEN os_type1 = 'ios' AND product_type = 2 AND days > 365 THEN '一年以上'  ELSE '不区分' END                        AS days
			       ,type_gmv
			       ,out_pay_id
			       ,gmv
			       ,gmv_total
			       ,0 refund_amount
			       ,cur_pay_withhold_stage
			FROM stat_meitu.mtxx_oda_vip_order_all
			WHERE date_p = ${day_now}
			AND created_at <= ${end_time}
			AND created_at >= ${start_time}
			AND period_type1 NOT IN ('周') 
			UNION ALL
			 -- 退款
			SELECT  CASE WHEN country_name IN ('中国') THEN '中国大陆'
			             WHEN country_name IN ('中国香港','中国澳门') THEN '香港+澳门'
			             WHEN country_name IN ('中国台湾','泰国','美国','日本','韩国','越南') THEN country_name
                         WHEN country_name IN ('印度尼西亚') THEN '印尼'  ELSE '海外其他' END            AS country_name          
			       ,CASE WHEN os_type1 IN ('android','google') THEN 'Android'
			             WHEN os_type1 = 'ios' THEN 'iOS'
			             WHEN os_type1 = 'harmony' THEN 'Harmony'  ELSE 'other' END                                                   AS os_type1
			       ,CASE WHEN product_type = 2 AND period_type1 IN ('月','季','年','周') THEN concat('连续包',period_type1)
			             WHEN product_type = 2 THEN '续期其他SKU'
			             WHEN product_type != 2 AND period_type1 IN ('月','季','年','周') THEN concat('包',period_type1)  ELSE '其他SKU' END AS period_type
			       ,CASE WHEN os_type1 != 'ios' or product_type != 2 THEN '不区分'
			             WHEN os_type1 = 'ios' AND product_type = 2 AND days <= 365 or days is null THEN '一年以内'
			             WHEN os_type1 = 'ios' AND product_type = 2 AND days > 365 THEN '一年以上'  ELSE '不区分' END                        AS days
			       ,type_gmv
			       ,out_pay_id
			       ,0 gmv
			       ,0 gmv_total
			       ,refund_amount
			       ,cur_pay_withhold_stage
			FROM stat_meitu.mtxx_oda_vip_order_all
			WHERE date_p = ${day_now}
			AND created_at <= ${end_time}
			AND nvl(refund_amount, 2) > 0
			AND from_unixtime(cast(refund_time AS bigint), "yyyyMMdd") <= ${end_time}
            AND from_unixtime(cast(refund_time AS bigint), "yyyyMMdd")>= ${start_time}
			AND period_type1 NOT IN ('周') -- 包周特殊处理(out_pay_id改成order_id)
 
			UNION ALL
			 -- 收入
			SELECT  CASE WHEN country_name IN ('中国') THEN '中国大陆'
			             WHEN country_name IN ('中国香港','中国澳门') THEN '香港+澳门'
			             WHEN country_name IN ('中国台湾','泰国','美国','日本','韩国','越南') THEN country_name
                         WHEN country_name IN ('印度尼西亚') THEN '印尼'  ELSE '海外其他' END            AS country_name
			       ,CASE WHEN os_type1 IN ('android','google') THEN 'Android'
			             WHEN os_type1 = 'ios' THEN 'iOS'
			             WHEN os_type1 = 'harmony' THEN 'Harmony'  ELSE 'other' END                                                   AS os_type1
			       ,CASE WHEN product_type = 2 AND period_type1 IN ('月','季','年','周') THEN concat('连续包',period_type1)
			             WHEN product_type = 2 THEN '续期其他SKU'
			             WHEN product_type != 2 AND period_type1 IN ('月','季','年','周') THEN concat('包',period_type1)  ELSE '其他SKU' END AS period_type
			       ,CASE WHEN os_type1 != 'ios' or product_type != 2 THEN '不区分'
			             WHEN os_type1 = 'ios' AND product_type = 2 AND days <= 365 or days is null THEN '一年以内'
			             WHEN os_type1 = 'ios' AND product_type = 2 AND days > 365 THEN '一年以上'  ELSE '不区分' END                        AS days
			       ,type_gmv
			       ,order_id                                                                                                          AS out_pay_id
			       ,gmv
			       ,gmv_total
			       ,0 refund_amount
			       ,cur_pay_withhold_stage
			FROM stat_meitu.mtxx_oda_vip_order_all
			WHERE date_p = ${day_now}
			AND created_at <= ${end_time}
			AND created_at >= ${start_time}
			AND period_type1 IN ('周') 
			UNION ALL
			 -- 退款
			SELECT  CASE WHEN country_name IN ('中国') THEN '中国大陆'
			             WHEN country_name IN ('中国香港','中国澳门') THEN '香港+澳门'
			             WHEN country_name IN ('中国台湾','泰国','美国','日本','韩国','越南') THEN country_name
                         WHEN country_name IN ('印度尼西亚') THEN '印尼'  ELSE '海外其他' END            AS country_name
			       ,CASE WHEN os_type1 IN ('android','google') THEN 'Android'
			             WHEN os_type1 = 'ios' THEN 'iOS'
			             WHEN os_type1 = 'harmony' THEN 'Harmony'  ELSE 'other' END                                                   AS os_type1
			       ,CASE WHEN product_type = 2 AND period_type1 IN ('月','季','年','周') THEN concat('连续包',period_type1)
			             WHEN product_type = 2 THEN '续期其他SKU'
			             WHEN product_type != 2 AND period_type1 IN ('月','季','年','周') THEN concat('包',period_type1)  ELSE '其他SKU' END AS period_type
			       ,CASE WHEN os_type1 != 'ios' or product_type != 2 THEN '不区分'
			             WHEN os_type1 = 'ios' AND product_type = 2 AND days <= 365 or days is null THEN '一年以内'
			             WHEN os_type1 = 'ios' AND product_type = 2 AND days > 365 THEN '一年以上'  ELSE '不区分' END                        AS days
			       ,type_gmv
			       ,order_id                                                                                                          AS out_pay_id
			       ,0 gmv
			       ,0 gmv_total
			       ,refund_amount
			       ,cur_pay_withhold_stage
			FROM stat_meitu.mtxx_oda_vip_order_all
			WHERE date_p = ${day_now}
			AND created_at <= ${end_time}
			AND from_unixtime(cast(refund_time AS bigint), "yyyyMMdd") <= ${end_time}
            AND from_unixtime(cast(refund_time AS bigint), "yyyyMMdd") >= ${start_time}
			AND period_type1 IN ('周') 
		)a
		GROUP BY  a.country_name
		         ,concat(a.country_name,a.os_type1)
		         ,period_type
		         ,type_gmv
		         ,cur_pay_withhold_stage
		         ,days
		         ,out_pay_id
	) t
	GROUP BY  country_name
	         ,os_p
	         ,period_type
	         ,days
	WITH CUBE
)orders



---- 整体指标表

set hive.exec.dynamic.partition.mode = nonstrict;
set hive.exec.dynamic.partition = true;
INSERT OVERWRITE TABLE stat_ainancial.forcast_amz_overview_metrics partition(business_line_p='mtxx', business_series_p='key_countries', date_p)

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
	       ,COUNT(distinct server_id) AS mau
	       ,COUNT(distinct gid)       AS valid_mau
	FROM
	(
		SELECT  concat(t1.country_name,t1.os_p) AS os_p
		       ,t1.country_name
		       ,t1.server_id
		       ,t2.gid
		FROM
		( -- MAU
			SELECT  CASE WHEN os_p = 'ios' THEN 'iOS'
			             WHEN os_p = 'android' THEN 'Android'
			             WHEN os_p = 'harmony' THEN 'Harmony' else 'other'  end    AS os_p
			       ,server_id                                                 
			       ,CASE WHEN country_id = 10184 THEN '中国大陆'
			             WHEN country_id IN (10239,10257) THEN '香港+澳门'
			             WHEN country_id = 10196 THEN '韩国'
			             WHEN country_id = 10100 THEN '美国'
			             WHEN country_id = 10248 THEN '中国台湾'
			             WHEN country_id = 10170 THEN '日本'
			             WHEN country_id = 10141 THEN '泰国'
			             WHEN country_id = 10179 THEN '越南'
			             WHEN country_id = 10220 THEN '印尼'  ELSE '海外其他' END AS country_name
			FROM stat_sdk.sdk_active_odz
			WHERE app_key_p in( 'C4FAF9CE1569F541', 'F5C7F68C7117630B', '5EFDCAC464136336' )
			AND os_p in('ios', 'android', 'harmony')
			AND country_id = 10184 -- 大陆包含鸿蒙数据单独处理
			AND date_p >= ${start_time}
			AND date_p <= ${end_time}
			GROUP BY  CASE WHEN os_p = 'ios' THEN 'iOS'
			             WHEN os_p = 'android' THEN 'Android'
			             WHEN os_p = 'harmony' THEN 'Harmony' else 'other'  end 
			         ,server_id
			         ,CASE WHEN country_id = 10184 THEN '中国大陆'
			             WHEN country_id IN (10239,10257) THEN '香港+澳门'
			             WHEN country_id = 10196 THEN '韩国'
			             WHEN country_id = 10100 THEN '美国'
			             WHEN country_id = 10248 THEN '中国台湾'
			             WHEN country_id = 10170 THEN '日本'
			             WHEN country_id = 10141 THEN '泰国'
			             WHEN country_id = 10179 THEN '越南'
			             WHEN country_id = 10220 THEN '印尼'  ELSE '海外其他' END
			UNION ALL
			SELECT  CASE WHEN os_p = 'ios' THEN 'iOS'
			             WHEN os_p = 'android' THEN 'Android'
			             WHEN os_p = 'harmony' THEN 'Harmony' else 'other'  end      AS os_p
			       ,server_id                                                 
			       ,CASE WHEN country_id = 10184 THEN '中国大陆'
			             WHEN country_id IN (10239,10257) THEN '香港+澳门'
			             WHEN country_id = 10196 THEN '韩国'
			             WHEN country_id = 10100 THEN '美国'
			             WHEN country_id = 10248 THEN '中国台湾'
			             WHEN country_id = 10170 THEN '日本'
			             WHEN country_id = 10141 THEN '泰国'
			             WHEN country_id = 10179 THEN '越南'
			             WHEN country_id = 10220 THEN '印尼'  ELSE '海外其他' END AS country_name
			FROM stat_sdk.sdk_active_odz
			WHERE app_key_p in( 'C4FAF9CE1569F541', 'F5C7F68C7117630B', '5EFDCAC464136336' )
			AND os_p in('ios', 'android')
			AND country_id != 10184
			AND date_p >= ${start_time}
			AND date_p <= ${end_time}
			GROUP BY  CASE WHEN os_p = 'ios' THEN 'iOS'
			             WHEN os_p = 'android' THEN 'Android'
			             WHEN os_p = 'harmony' THEN 'Harmony' else 'other'  end 
			         ,server_id
			         ,CASE WHEN country_id = 10184 THEN '中国大陆'
			             WHEN country_id IN (10239,10257) THEN '香港+澳门'
			             WHEN country_id = 10196 THEN '韩国'
			             WHEN country_id = 10100 THEN '美国'
			             WHEN country_id = 10248 THEN '中国台湾'
			             WHEN country_id = 10170 THEN '日本'
			             WHEN country_id = 10141 THEN '泰国'
			             WHEN country_id = 10179 THEN '越南'
			             WHEN country_id = 10220 THEN '印尼'  ELSE '海外其他' END
		) t1
		LEFT JOIN
		( -- 非会员MAU = MAU-会员不可新增且活跃的MAU
			SELECT  os_p
			       ,gid
			       ,country_name
			FROM
			( -- 非续期当月一直有效
				SELECT  CASE WHEN country_name IN ('中国') THEN '中国大陆'
				             WHEN country_name IN ('中国香港','中国澳门') THEN '香港+澳门'
				             WHEN country_name IN ('中国台湾','泰国','美国','日本','韩国','越南') THEN country_name 
                             WHEN country_name IN ('印度尼西亚') THEN '印尼' ELSE '海外其他' END AS country_name
				       ,CASE WHEN os_type1 IN ('google','android') THEN 'Android'
				             WHEN os_type1 = 'ios' THEN 'iOS'
				             WHEN os_type1 = 'harmony' THEN 'Harmony'  ELSE 'other' END os_p
				       ,gid
				FROM stat_meitu.mtxx_oda_vip_order_all
				WHERE date_p = ${day_now}
				AND created_at < ${start_time}
				AND from_unixtime(invalid_time, 'yyyyMMdd') > ${end_time}
				AND cur_pay_withhold_stage >= 1
				
				UNION ALL
				 --续期产品当月过期的会员，属于自动续费场景
				SELECT  CASE WHEN country_name IN ('中国') THEN '中国大陆'
				             WHEN country_name IN ('中国香港','中国澳门') THEN '港澳'
				             WHEN country_name IN ('中国台湾','泰国','美国','日本','韩国','越南') THEN country_name 
                             WHEN country_name IN ('印度尼西亚') THEN '印尼' ELSE '海外其他' END AS country_name
				       ,CASE WHEN os_type1 = 'google' THEN 'android'  ELSE os_type1 END os_p
				       ,gid
				FROM stat_meitu.mtxx_oda_vip_order_all
				WHERE date_p = ${day_now}
				AND created_at < ${start_time}
				AND from_unixtime(invalid_time, 'yyyyMMdd') >= ${start_time}
                and from_unixtime(invalid_time, 'yyyyMMdd')<=${end_time}
				AND cur_pay_withhold_stage >= 1
				AND product_type = 2 
			) a
			GROUP BY  os_p
			         ,gid
			         ,country_name
		) t2
		ON t1.server_id = t2.gid AND t1.country_name = t2.country_name AND t1.os_p = t2.os_p
		GROUP BY  concat(t1.country_name,t1.os_p)
		         ,t1.country_name
		         ,t1.server_id
		         ,t2.gid
	) p
	GROUP BY  os_p
	         ,country_name
	WITH CUBE
) mau