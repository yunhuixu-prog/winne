with sub as
(
    select pay_date
         ,case when country_name in ('美国','巴西','英国','墨西哥','西班牙','加拿大','澳大利亚') then country_name
         else '其他'
         end country
         ,ord_amt,ord_before_amt,days,os_type,ord_amt_usd,ord_before_amt_usd
    from stat_vip.paid_oda_vip_all_order
    WHERE date_p=20260512
        and pay_date BETWEEN 20250101 AND 20260430
        -- and substr(create_time,1,8)<=20260430
        and substr(create_time,1,6)<=substr(pay_date,1,6)
        and app_id_p IN (7329803307041000000)
        and commodity_id_P not in (-1)

    -- union all

    -- select substr(refund_time,1,8) pay_date
    --      ,-refund_amt ord_amt,-refund_before_amt ord_before_amt,days,os_type
    --      ,-refund_amt_usd ord_amt_usd,-round(refund_amt_usd*refund_before_amt/refund_amt,3) ord_before_amt_usd
    -- from stat_vip.paid_oda_vip_all_order
    -- WHERE date_p=20260512
    --     and substr(refund_time,1,8) BETWEEN 20250101 AND 20260430
    --     and substr(create_time,1,8)<=20260430
    --     and app_id_p IN (7329803307041000000)
    --     and commodity_id_P not in (-1)
    --     and pay_status=6
)

select substr(pay_date,1,4) year,country
	 ,round(count(case when nvl(days,-1)=-1 then 1 end)/count(1),4) rati
     ,sum(ord_amt) ord_amt,sum(ord_before_amt) ord_before_amt
     ,round(sum(ord_amt)/sum(ord_before_amt),3) ratio
     ,round(sum(case when (os_type='ios' and days>365) or os_type in ('android','androidpad') then ord_before_amt*0.85
               when os_type='ios' and nvl(days,0)<=365 then ord_before_amt*0.7 end)/sum(ord_before_amt),2) ratio

from sub
group by substr(pay_date,1,4),country_name
