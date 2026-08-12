with sub as
(
    select '调整后' ver,'no_refund' type,pay_date,substr(create_time,1,8) create_date
        ,case when country_name in ('美国','巴西','英国','墨西哥','西班牙','加拿大','澳大利亚') then country_name
          else '海外其他'
          end country
         ,days,os_type,pay_status,cur_pay_stage,cur_pay_withhold_stage
         ,ord_amt,ord_before_amt
         ,ord_amt_usd,round(case when ord_amt=0 then 0 else ord_amt_usd*ord_before_amt/ord_amt end,3) ord_before_amt_usd
    from stat_vip.paid_oda_vip_all_order
    WHERE date_p=20260601
        and pay_date BETWEEN 20260101 AND 20260530
        and substr(create_time,1,8)<=20260530
        and app_id_p IN (7329803307041000000)
        and commodity_id_P not in (-1)

    union all

    select '调整后' ver,'refund' type,substr(refund_time,1,8) pay_date,substr(create_time,1,8) create_date
        ,case when country_name in ('美国','巴西','英国','墨西哥','西班牙','加拿大','澳大利亚') then country_name
          else '海外其他'
          end country
         ,days,os_type,pay_status,cur_pay_stage,cur_pay_withhold_stage
         ,-refund_amt ord_amt,-refund_before_amt ord_before_amt
         ,-refund_amt_usd ord_amt_usd,-round(case when refund_amt=0 then 0 else refund_amt_usd*refund_before_amt/refund_amt end,3) ord_before_amt_usd
    from stat_vip.paid_oda_vip_all_order
    WHERE date_p=20260601
        and substr(refund_time,1,8) BETWEEN 20260101 AND 20260530
        and substr(create_time,1,8)<=20260530
        and app_id_p IN (7329803307041000000)
        and commodity_id_P not in (-1)
        and pay_status=6

    union all 

    select '调整前' ver,'no_refund' type,pay_date,substr(create_time,1,8) create_date
        ,case when country_name in ('美国','巴西','英国','墨西哥','西班牙','加拿大','澳大利亚') then country_name
          else '海外其他'
          end country
         ,days,os_type,pay_status,cur_pay_stage,cur_pay_withhold_stage
         ,ord_amt,ord_before_amt
         ,ord_amt_usd,round(case when ord_amt=0 then 0 else ord_amt_usd*ord_before_amt/ord_amt end,3) ord_before_amt_usd
    from stat_ab.filing_oda_vip_all_order_copy
    WHERE date_p=20260530
        and pay_date BETWEEN 20260101 AND 20260530
        and substr(create_time,1,8)<=20260530
        and app_id_p IN (7329803307041000000)
        and commodity_id_P not in (-1)
    
    union all

    select '调整前' ver,'refund' type,substr(refund_time,1,8) pay_date,substr(create_time,1,8) create_date
        ,case when country_name in ('美国','巴西','英国','墨西哥','西班牙','加拿大','澳大利亚') then country_name
          else '海外其他'
          end country
         ,days,os_type,pay_status,cur_pay_stage,cur_pay_withhold_stage
         ,-refund_amt ord_amt,-refund_before_amt ord_before_amt
         ,-refund_amt_usd ord_amt_usd,-round(case when refund_amt=0 then 0 else refund_amt_usd*refund_before_amt/refund_amt end,3) ord_before_amt_usd
    from stat_ab.filing_oda_vip_all_order_copy
    WHERE date_p=20260530
        and substr(refund_time,1,8) BETWEEN 20260101 AND 20260530
        and substr(create_time,1,8)<=20260530
        and app_id_p IN (7329803307041000000)
        and commodity_id_P not in (-1)
        and pay_status=6
)

select
	 substr(pay_date,1,6) pay_month
     ,country
     ,os_type

     ,sum(case when ver='调整前' then ord_amt_usd end) usd_no_refund_pre
     ,sum(case when ver='调整前' then ord_before_amt_usd end) usd_before_no_refund_pre
     ,sum(case when ver='调整前' and type='no_refund' then ord_amt_usd end) usd_pre
     ,sum(case when ver='调整前' and type='no_refund' then ord_before_amt_usd end) usd_before_pre

     ,sum(case when ver='调整后' then ord_amt_usd end) usd_no_refund_afe
     ,sum(case when ver='调整后' then ord_before_amt_usd end) usd_before_no_refund_afe
     ,sum(case when ver='调整后' and type='no_refund' then ord_amt_usd end) usd_afe
     ,sum(case when ver='调整后' and type='no_refund' then ord_before_amt_usd end) usd_before_afe
from sub
group by substr(pay_date,1,6),country,os_type









;
-- 吴奎口径
SELECT  *
FROM
(
    SELECT  product_line
           ,pay_month
           ,pay_channel
           ,case when country_name in ('美国','巴西','英国') then country_name
          else '其他'
          end country
           ,SUM(if(type = 'relase',cnt,0))            AS cnt
           ,SUM(if(type = 'test',cnt,0))              AS test_cnt
           ,SUM(if(type = 'relase',ord_amt,0))        AS ord_amt
           ,SUM(if(type = 'test',ord_amt,0))          AS test_ord_amt
           ,SUM(if(type = 'relase',ord_before_amt,0)) AS ord_before_amt
           ,SUM(if(type = 'test',ord_before_amt,0))   AS test_ord_before_amt
           ,SUM(if(type = 'relase',ord_amt_usd,0))    AS ord_amt_usd
           ,SUM(if(type = 'test',ord_amt_usd,0))      AS test_ord_amt_usd
    FROM
    (
        SELECT  'relase'               AS type
               ,product_line
               ,substr(pay_date,1,6)   AS pay_month
               ,pay_channel
               ,nvl(country_name,'未知') AS country_name
               ,COUNT(*)               AS cnt
               ,SUM(ord_amt)           AS ord_amt
               ,SUM(ord_before_amt)    AS ord_before_amt
               ,SUM(ord_amt_usd)       AS ord_amt_usd
        FROM stat_vip.paid_oda_all_order_summary
        WHERE  app_id_p IN (7329803307041000000)
        AND pay_channel IN ('google', 'iap')
        AND pay_date >= 20260101

        AND create_date <= 20260525
        AND pay_date <= 20260525
        GROUP BY  product_line
                 ,substr(pay_date,1,6)
                 ,pay_channel
                 ,nvl(country_name,'未知')
        UNION ALL
        SELECT  'test'                 AS type
               ,product_line
               ,substr(pay_date,1,6)   AS pay_month
               ,pay_channel
               ,nvl(country_name,'未知') AS country_name
               ,COUNT(*)               AS cnt
               ,SUM(ord_amt)           AS ord_amt
               ,SUM(ord_before_amt)    AS ord_before_amt
               ,SUM(ord_amt_usd)       AS ord_amt_usd
        FROM stat_vip.paid_oda_all_order_summary_test
        WHERE  app_id_p IN (7329803307041000000)
        AND pay_channel IN ('google', 'iap')
        AND pay_date >= 20260101
        AND create_date <= 20260525
        AND pay_date <= 20260525
        GROUP BY  product_line
                 ,substr(pay_date,1,6)
                 ,pay_channel
                 ,nvl(country_name,'未知')
    ) a
    GROUP BY  product_line
             ,pay_month
             ,pay_channel
             ,case when country_name in ('美国','巴西','英国') then country_name
          else '其他'
          end
) a
ORDER BY pay_channel , pay_month , product_line, abs(ord_amt - test_ord_amt) desc