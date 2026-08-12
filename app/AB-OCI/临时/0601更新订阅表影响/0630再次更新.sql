with sub as
(
    select '调整前' ver,'no_refund' type,pay_date,substr(create_time,1,8) create_date
        ,case when country_name in ('美国','巴西','英国','墨西哥','西班牙','加拿大','澳大利亚') then country_name
          else '海外其他'
          end country
         ,days,os_type,pay_status,cur_pay_stage,cur_pay_withhold_stage
         ,ord_amt,ord_before_amt
         ,ord_amt_usd,round(case when ord_amt=0 then 0 else ord_amt_usd*ord_before_amt/ord_amt end,3) ord_before_amt_usd
    from stat_vip.paid_oda_vip_all_order
    WHERE date_p=20260627
        and pay_date BETWEEN 20260101 AND 20260627
        and substr(create_time,1,8)<=20260627
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
    from stat_vip.paid_oda_vip_all_order
    WHERE date_p=20260627
        and substr(refund_time,1,8) BETWEEN 20260101 AND 20260627
        and substr(create_time,1,8)<=20260627
        and app_id_p IN (7329803307041000000)
        and commodity_id_P not in (-1)
        and pay_status=6

    union all 

    select '调整后' ver,'no_refund' type,pay_date,substr(create_time,1,8) create_date
        ,case when country_name in ('美国','巴西','英国','墨西哥','西班牙','加拿大','澳大利亚') then country_name
          else '海外其他'
          end country
         ,days,os_type,pay_status,cur_pay_stage,cur_pay_withhold_stage
         ,ord_amt,ord_before_amt
         ,ord_amt_usd,round(case when ord_amt=0 then 0 else ord_amt_usd*ord_before_amt/ord_amt end,3) ord_before_amt_usd
    from stat_vip.paid_oda_vip_all_order
    WHERE date_p=20260628
        and pay_date BETWEEN 20260101 AND 20260627
        and substr(create_time,1,8)<=20260627
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
    WHERE date_p=20260628
        and substr(refund_time,1,8) BETWEEN 20260101 AND 20260627
        and substr(create_time,1,8)<=20260627
        and app_id_p IN (7329803307041000000)
        and commodity_id_P not in (-1)
        and pay_status=6
)

select
	 substr(pay_date,1,6) pay_month
     ,case when pay_date<=20260621 then '20260621之前' else '20260621之后' end periods
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
group by substr(pay_date,1,6),country,os_type,case when pay_date<=20260621 then '20260621之前' else '20260621之后' end

