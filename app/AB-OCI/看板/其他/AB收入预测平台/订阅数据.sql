-- 订阅数据
set hive.exec.dynamic.partition.mode = nonstrict;
set hive.exec.dynamic.partition = true;
INSERT OVERWRITE TABLE stat_sdk.filing_amz_subscription_orders partition(business_line_p='airbrush', business_series_p='key_countries', date_p)
-- stat_ainancial.forcast_amz_subscription_orders -- 北斗表

-- 由于是月维度数据，连续包周SKU需要特殊处理使用order_id 来统计订单数，使用合约订单数会导致收入不准确

SELECT  business_unit
       ,compute_unit
       ,period_type
       ,days
       ,nvl(gmv_new,0)                                              AS new_sub_amt_net_incl_refund
       ,nvl(gmv_new,0)-nvl(refund_new,0)                            AS new_sub_amt_net_excl_refund
       ,nvl(gmv_total_new,0)                                        AS new_sub_amt_gross_incl_refund
       ,nvl(gmv_total_new,0)-nvl(refund_total_new,0)                AS new_sub_amt_gross_excl_refund
       ,nvl(gmv_renewal,0)                                          AS renewal_sub_amt_net_incl_refund
       ,nvl(gmv_renewal,0)-nvl(refund_renewal,0)                    AS renewal_sub_amt_net_excl_refund
       ,nvl(gmv_total_renewal,0)                                    AS renewal_sub_amt_gross_incl_refund
       ,nvl(gmv_total_renewal,0)-nvl(refund_total_renewal,0)        AS renewal_sub_amt_gross_excl_refund
       ,nvl(new_sub_orders,0)                                       AS new_sub_orders
       ,nvl(renewal_sub_orders,0)                                   AS renewal_sub_orders
       ,${start_time}                                               AS date_p
FROM
(
	SELECT  nvl(country_name,'整体')                                         AS business_unit
	       ,nvl(os_p,'整体')                                                 AS compute_unit
	       ,nvl(period_type,'整体')                                          AS period_type
	       ,nvl(days,'整体')                                                 AS days
	       ,SUM(if(cur_pay_withhold_stage = 1,gmv,0))                                 AS gmv_new
	       ,SUM(if(cur_pay_withhold_stage = 1,gmv_total,0))                           AS gmv_total_new
	       ,SUM(if(cur_pay_withhold_stage = 1,refund,0))                              AS refund_new
	       ,SUM(if(cur_pay_withhold_stage = 1,refund_total,0))                        AS refund_total_new
	       ,SUM(if(cur_pay_withhold_stage > 1,gmv,0))                                 AS gmv_renewal
	       ,SUM(if(cur_pay_withhold_stage > 1,gmv_total,0))                           AS gmv_total_renewal
	       ,SUM(if(cur_pay_withhold_stage > 1,refund,0))                              AS refund_renewal
	       ,SUM(if(cur_pay_withhold_stage > 1,refund_total,0))                        AS refund_total_renewal
	       ,COUNT(distinct if(cur_pay_withhold_stage = 1 and type='no_refund',notify_pay_id,null)) AS new_sub_orders
	       ,COUNT(distinct if(cur_pay_withhold_stage > 1 and type='no_refund',notify_pay_id,null)) AS renewal_sub_orders
	FROM
	(
		SELECT  a.country_name
		       ,concat(a.country_name,a.os_type) AS os_p
		       ,period_type
		       ,cur_pay_withhold_stage
		       ,days
		       ,notify_pay_id
               ,type
		       ,SUM(case when type='no_refund' then ord_amt_usd else 0 end) AS gmv
		       ,SUM(case when type='no_refund' then ord_before_amt_usd else 0 end) AS gmv_total
		       ,SUM(case when type='refund' then -ord_amt_usd else 0 end) AS refund
		       ,SUM(case when type='refund' then -ord_before_amt_usd else 0 end) AS refund_total
		FROM
		( -- 收 入
            select 'no_refund' type
                ,case when period_type in ('周') then order_id else notify_pay_id end as notify_pay_id  -- 包周特殊处理(notify_pay_id改成order_id)
                ,device_type as os_type
                ,case when country_name in ('美国','英国','巴西','墨西哥','西班牙','加拿大','澳大利亚') then country_name
                else '其他' end as country_name
                ,concat('连续包',period_type) period_type
                ,CASE WHEN device_type != 'ios' or order_type != 2 THEN '不区分'
			          WHEN device_type = 'ios' AND order_type = 2 AND days <= 365 or days is null THEN '一年以内'
			          WHEN device_type = 'ios' AND order_type = 2 AND days > 365 THEN '一年以上'  
                      ELSE '不区分' 
                END AS days
                ,pay_date
                ,ord_amt,ord_before_amt
                ,ord_amt_usd,round(case when ord_amt=0 then 0 else ord_amt_usd*ord_before_amt/ord_amt end,3) ord_before_amt_usd
                ,cur_pay_stage
                ,cur_pay_withhold_stage
            from stat_vip.paid_oda_all_order_summary
            where app_id_p IN (7329803307041000000)
                and pay_date between ${start_time} and ${end_time}
                -- and create_date <= ${end_time}
                and substr(create_date,1,4) <= substr(pay_date,1,4)
                and product_sub_line = 'AirBrush'
                and is_subscribe='订阅'

            union all

            select 'refund' type
                ,case when period_type in ('周') then order_id else notify_pay_id end as notify_pay_id  -- 包周特殊处理(notify_pay_id改成order_id)
                ,device_type as os_type
                ,case when country_name in ('美国','英国','巴西','墨西哥','西班牙','加拿大','澳大利亚') then country_name
                else '其他' end as country_name
                ,concat('连续包',period_type) period_type
                ,CASE WHEN device_type != 'ios' or order_type != 2 THEN '不区分'
			          WHEN device_type = 'ios' AND order_type = 2 AND days <= 365 or days is null THEN '一年以内'
			          WHEN device_type = 'ios' AND order_type = 2 AND days > 365 THEN '一年以上'  
                      ELSE '不区分' 
                END AS days
                ,refund_date pay_date
                ,-refund_amt ord_amt,-refund_before_amt ord_before_amt
                ,-refund_amt_usd ord_amt_usd,-round(case when refund_amt=0 then 0 else refund_amt_usd*refund_before_amt/refund_amt end,3) ord_before_amt_usd
                ,cur_pay_stage
                ,cur_pay_withhold_stage
            from stat_vip.paid_oda_all_order_summary
            where app_id_p IN (7329803307041000000)
                and refund_date between ${start_time} and ${end_time}
                -- and create_date <= ${end_time}
                and substr(create_date,1,4) <= substr(refund_date,1,4)
                and product_sub_line = 'AirBrush'
                and is_subscribe='订阅'
                and pay_status=6
		)a
		GROUP BY  a.country_name
		         ,concat(a.country_name,a.os_type)
		         ,period_type
		         ,cur_pay_withhold_stage
		         ,days
		         ,notify_pay_id
                 ,type
	) t
	GROUP BY  country_name
	         ,os_p
	         ,period_type
	         ,days
	WITH CUBE
)orders


