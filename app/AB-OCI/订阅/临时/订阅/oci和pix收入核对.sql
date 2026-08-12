with sub as
(
    select 'no_refund' type,pay_date,substr(create_time,1,8) create_date
        ,case when country_name in ('美国','巴西','英国','墨西哥','西班牙','加拿大','澳大利亚') then country_name
          else '其他'
          end country
         ,days,os_type,pay_status
         ,ord_amt,ord_before_amt
         ,ord_amt_usd,round(case when ord_amt=0 then 0 else ord_amt_usd*ord_before_amt/ord_amt end,3) ord_before_amt_usd
    from stat_vip.paid_oda_vip_all_order
    WHERE date_p=20260224
        and pay_date BETWEEN 20260101 AND 20260224
        and app_id_p IN (7329803307041000000)
        and commodity_id_P not in (-1)

    union all

    select 'refund' type,substr(refund_time,1,8) pay_date,substr(create_time,1,8) create_date
        ,case when country_name in ('美国','巴西','英国','墨西哥','西班牙','加拿大','澳大利亚') then country_name
          else '其他'
          end country
         ,days,os_type,pay_status
         ,-refund_amt ord_amt,-refund_before_amt ord_before_amt
         ,-refund_amt_usd ord_amt_usd,-round(case when refund_amt=0 then 0 else refund_amt_usd*refund_before_amt/refund_amt end,3) ord_before_amt_usd
    from stat_vip.paid_oda_vip_all_order
    WHERE date_p=20260224
        and substr(refund_time,1,8) BETWEEN 20260101 AND 20260224
        and app_id_p IN (7329803307041000000)
        and commodity_id_P not in (-1)
        and pay_status=6
)

select
	 substr(pay_date,1,6) pay_month
     ,country
-- 	 pay_date
     -- ,os_type
     ,sum(ord_amt) ord_amt_no_refund,sum(ord_before_amt) ord_before_amt_no_refund
     ,sum(case when type='no_refund' then ord_amt end) ord_amt
     ,sum(case when type='no_refund' then ord_before_amt end) ord_before_amt
     ,sum(case when type='no_refund' and pay_status!=6 then ord_amt end) ord_amt_no_refund_pix
     ,sum(case when type='no_refund' and pay_status!=6 then ord_before_amt end) ord_before_amt_no_refund_pix


     ,sum(case when create_date<=pay_date then ord_amt_usd end) ord_amt_usd_no_refund_oci
     ,sum(case when create_date<=pay_date then ord_before_amt_usd end) ord_before_amt_usd_no_refund_oci
     ,sum(ord_amt_usd) ord_amt_usd_no_refund,sum(ord_before_amt_usd) ord_before_amt_usd_no_refund
     ,sum(case when type='no_refund' then ord_amt_usd end) ord_amt_usd
     ,sum(case when type='no_refund' then ord_before_amt_usd end) ord_before_amt_usd
     ,sum(case when type='no_refund' and pay_status!=6 then ord_amt_usd end) ord_amt_usd_no_refund_pix
     ,sum(case when type='no_refund' and pay_status!=6 then ord_before_amt_usd end) ord_before_amt_usd_no_refund_pix
from sub
where create_date<=20260224
group by substr(pay_date,1,6),country
