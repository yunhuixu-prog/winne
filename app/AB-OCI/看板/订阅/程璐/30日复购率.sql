set hive.new.job.grouping.set.cardinality=128;
SET spark.sql.shuffle.partitions=600;
set spark.sql.hive.convertMetastoreOrc=true;

SELECT 
a.date_p
       ,a.country
       ,a.os_type1
       ,a.period_type1
       ,a.product_type
       ,type_xf
       ,a.app_type
       ,b.day_cnt
       ,a.cnt
       ,b.lc_cnt
FROM
(
	SELECT  ${day_30}              AS date_p
	       ,nvl(country,'整体')      AS country
	       ,nvl(os_type1,'整体')     AS os_type1
	       ,nvl(period_type1,'整体') AS period_type1
	       ,nvl(product_type,'整体') AS product_type
           ,nvl(app_type,'整体') AS app_type
	       ,COUNT(distinct gid) cnt
	FROM
	(


        SELECT  contract_id
               ,case when platform=1 then 'android'
                      when platform=2 then 'ios'
                      when platform=3 then 'google'
                      when platform=4 and platform_desc='web' then 'WEB'
                      when platform=4 then 'PC'
                      else '其他' end as os_type1,
                      gid,
                      substr(invalid_time,1,8) invalid_date
               ,case when app_id='6829803307009000000' then 'chic'
                     when app_id='6829803307010000000' then 'wink'
                     when app_id='6829803307012000000' and platform_desc='web' then '秀秀设计室Web端'
                     when app_id='6829803307012000000' then '秀秀设计室PC端'
                     when app_id='6829803307013000000' and commodity_id_P=6 then '秀秀粉钻'
                     when app_id='6829803307013000000' and commodity_id_P=7 then '秀秀设计室移动端'
                     when app_id='6829803307014000000' then '美颜相机'
                     when app_id='6829803307017000000' then '蛋啵'
                     when app_id='6829803307011000000' then '潮自拍'
                     when app_id='6829803307019000000' then '海报工厂'
                      when app_id='6829803307027000000' then 'WHEE'
                     else '其他' end as app_type
               ,case when country_name='中国' then '大陆' when length(country_name)=0 then '未知' else '海外' end as country
               ,period_type period_type1,
                 CASE
    WHEN product_type = 1 THEN '非续期'
    WHEN product_type = 2 THEN '续期'
    ELSE '未知'
  END AS product_type
        FROM stat_vip.mpub_mda_vip_all_order
        WHERE date_p=${day_30}            
              and substr(invalid_time,1,8)=${day_30}
              and app_id_p in('6829803307027000000','6829803307009000000','6829803307010000000','6829803307011000000','6829803307012000000','6829803307013000000','6829803307014000000','6829803307015000000','6829803307017000000','6829803307019000000')
              and commodity_id_P not in (-1)
               and cur_pay_withhold_stage>=1



	)s
	GROUP BY  country
	         ,os_type1
	         ,period_type1
	         ,product_type
             ,app_type
	WITH cube
)a
LEFT JOIN
(
	SELECT  ${day_30}              AS date_p
	       ,nvl(country,'整体')      AS country
	       ,nvl(os_type1,'整体')     AS os_type1
	       ,nvl(period_type1,'整体') AS period_type1
	       ,nvl(product_type,'整体') AS product_type
           ,nvl(type_xf,'整体') as type_xf
           ,nvl(app_type,'整体') as app_type
	       ,nvl(day_cnt,'整体') day_cnt
	       ,COUNT(distinct gid) lc_cnt
	FROM
	(
		SELECT  
            /*+ broadcast(t1) */
      country
		       ,os_type1
		       ,period_type1
		       ,product_type,app_type
		       ,case when meitu_datediff(created_at1,invalid_date)=0 then '到期当日' else concat('过期第',meitu_datediff(created_at1,invalid_date),'日') end as day_cnt
               ,case when t1.out_pay_id=t2.out_pay_id then '自动扣款' else '非自动扣款' end as type_xf 
		       ,t2.gid
		FROM
		(

        SELECT  contract_id out_pay_id
               ,case when platform=1 then 'android'
                      when platform=2 then 'ios'
                      when platform=3 then 'google'
                      when platform=4 and platform_desc='web' then 'WEB'
                      when platform=4 then 'PC'
                      else '其他' end as os_type1,
                      gid,
                      substr(invalid_time,1,8) invalid_date
               ,case when app_id='6829803307009000000' then 'chic'
                     when app_id='6829803307010000000' then 'wink'
                     when app_id='6829803307012000000' and platform_desc='web' then '秀秀设计室Web端'
                     when app_id='6829803307012000000' then '秀秀设计室PC端'
                     when app_id='6829803307013000000' and commodity_id_P=6 then '秀秀粉钻'
                     when app_id='6829803307013000000' and commodity_id_P=7 then '秀秀设计室移动端'
                     when app_id='6829803307014000000' then '美颜相机'
                     when app_id='6829803307017000000' then '蛋啵'
                     when app_id='6829803307011000000' then '潮自拍'
                     when app_id='6829803307019000000' then '海报工厂'
          when app_id='6829803307027000000' then 'WHEE'
                     else '其他' end as app_type
               ,case when country_name='中国' then '大陆' when length(country_name)=0 then '未知' else '海外' end as country
               ,period_type period_type1,
                 CASE
    WHEN product_type = 1 THEN '非续期'
    WHEN product_type = 2 THEN '续期'
    ELSE '未知'
  END AS product_type,app_id
        FROM stat_vip.mpub_mda_vip_all_order
        WHERE date_p=${day_30}            
              and substr(invalid_time,1,8)=${day_30}
              and app_id_p in('6829803307027000000','6829803307009000000','6829803307010000000','6829803307011000000','6829803307012000000','6829803307013000000','6829803307014000000','6829803307015000000','6829803307017000000','6829803307019000000')
              and commodity_id_P not in (-1)
               and cur_pay_withhold_stage>=1

		)t1
		JOIN
		(
			SELECT  pay_date created_at1
			       ,gid
                   ,contract_id out_pay_id,app_id
			FROM stat_vip.mpub_mda_vip_all_order
			WHERE date_p = ${day}
			and cur_pay_withhold_stage>=1
           and app_id_p in('6829803307027000000','6829803307009000000','6829803307010000000','6829803307011000000','6829803307012000000','6829803307013000000','6829803307014000000','6829803307015000000','6829803307017000000','6829803307019000000')
              and commodity_id_P not in (-1)
			AND pay_date >= ${day_30}
			AND pay_date <= ${day}
		)t2
		ON t1.gid = t2.gid and t1.app_id=t2.app_id
	)s2
	GROUP BY  country
	         ,os_type1
	         ,period_type1
	         ,product_type,app_type
             ,type_xf
	         ,day_cnt
	WITH cube
)b
ON a.country = b.country AND a.os_type1 = b.os_type1 AND a.period_type1 = b.period_type1 AND a.product_type = b.product_type and a.app_type=b.app_type