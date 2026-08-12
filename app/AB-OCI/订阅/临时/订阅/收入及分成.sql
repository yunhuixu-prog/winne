-- select   contract_id
--       ,gid
--       ,os_type
--       ,country_name country
--       ,period_type
--       ,pay_date,pay_time
--       ,cur_pay_withhold_stage
--       ,ord_amt,ord_before_amt
--       ,third_product_id
--       ,get_json_object(big_data,'$.source_module') source_module
--       ,get_json_object(big_data,'$.source_0') source_0
--       ,get_json_object(big_data,'$.source_1') source_1
--       ,get_json_object(big_data,'$.mids_material_id') mids_material_id
--       ,get_json_object(big_data,'$.mids_category_id') mids_category_id
with sub as
(
    select 'no_refund' type,pay_date
         ,case when country_name in ('美国','巴西','英国','墨西哥','西班牙','加拿大','澳大利亚') then country_name
          else '其他'
          end country
         ,ord_amt,ord_before_amt,days,os_type,ord_amt_usd,ord_before_amt_usd
    from stat_vip.paid_oda_vip_all_order
    WHERE date_p=20260208
        and pay_date BETWEEN 20230101 AND 20251231
        and substr(create_time,1,8)<=20251231
        and app_id_p IN (7329803307041000000)
        and commodity_id_P not in (-1)

    union all

    select 'refund' type,substr(refund_time,1,8) pay_date
         ,case when country_name in ('美国','巴西','英国','墨西哥','西班牙','加拿大','澳大利亚') then country_name
          else '其他'
          end country
         ,-refund_amt ord_amt,-refund_before_amt ord_before_amt,days,os_type
         ,-refund_amt_usd ord_amt_usd,-round(refund_amt_usd*refund_before_amt/refund_amt,3) ord_before_amt_usd
    from stat_vip.paid_oda_vip_all_order
    WHERE date_p=20260208
        and substr(refund_time,1,8) BETWEEN 20230101 AND 20251231
        and substr(create_time,1,8)<=20251231
        and app_id_p IN (7329803307041000000)
        and commodity_id_P not in (-1)
        and pay_status=6
)

select cast(pay_date/10000 as bigint) pay_year,cast((pay_date/100)%100 as bigint) pay_month
     ,pay_date,os_type
     ,country
     ,sum(ord_amt) ord_amt,sum(ord_before_amt) ord_before_amt
--      ,sum(ord_amt_usd) ord_amt_usd,sum(ord_before_amt_usd) ord_before_amt_usd
     ,sum(case when (os_type='ios' and days>365) or os_type in ('android','androidpad') then ord_before_amt*0.85
               when os_type='ios' and nvl(days,0)<=365 then ord_before_amt*0.7 end) ord_amt_no_free
--      ,sum(case when os_type='ios' then ord_before_amt end) amt_ios
--      ,sum(case when os_type='ios' and days>365 then ord_before_amt end) amt_ios_bigger_365
--      ,sum(case when os_type='ios' and days<=365 then ord_before_amt end) amt_ios_smaller_365
--      ,sum(case when os_type='ios' and days is null then ord_before_amt end) amt_ios_no_365
from sub
group by pay_date,os_type,country
;

-- 和pix收入对比
with sub as
(
    select 'no_refund' type,pay_date,substr(create_time,1,8) create_date
        ,case when country_name in ('美国','巴西','英国','墨西哥','西班牙','加拿大','澳大利亚') then country_name
          else '其他'
          end country
         ,days,os_type,pay_status
         ,ord_amt,ord_before_amt
         ,ord_amt_usd,round(ord_amt_usd*ord_before_amt/ord_amt,3) ord_before_amt_usd
    from stat_vip.paid_oda_vip_all_order
    WHERE date_p=20260113
        and pay_date BETWEEN 20230101 AND 20251231
        and app_id_p IN (7329803307041000000) -- 另外一个是B+，后面其他都要改
        and commodity_id_P not in (-1)

    union all

    select 'refund' type,substr(refund_time,1,8) pay_date,substr(create_time,1,8) create_date
        ,case when country_name in ('美国','巴西','英国','墨西哥','西班牙','加拿大','澳大利亚') then country_name
          else '其他'
          end country
         ,days,os_type,pay_status
         ,-refund_amt ord_amt,-refund_before_amt ord_before_amt
         ,-refund_amt_usd ord_amt_usd,-round(refund_amt_usd*refund_before_amt/refund_amt,3) ord_before_amt_usd
    from stat_vip.paid_oda_vip_all_order
    WHERE date_p=20260113
        and substr(refund_time,1,8) BETWEEN 20230101 AND 20251231
        and app_id_p IN (7329803307041000000) -- 另外一个是B+，后面其他都要改
        and commodity_id_P not in (-1)
        and pay_status=6
)

select substr(pay_date,1,6) pay_month
--      ,pay_date,os_type

     ,sum(ord_amt_usd) ord_amt_usd_no_refund,sum(ord_before_amt_usd) ord_before_amt_usd_no_refund

     ,sum(case when type='no_refund' then ord_amt end) ord_amt
     ,sum(case when type='no_refund' then ord_before_amt end) ord_before_amt
     ,sum(case when type='no_refund' then ord_amt_usd end) ord_amt_usd
     ,sum(case when type='no_refund' then ord_before_amt_usd end) ord_before_amt_usd

     ,sum(case when type='no_refund' and pay_status!=6 then ord_amt_usd end) ord_amt_usd_no_refund_pix
     ,sum(case when type='no_refund' and pay_status!=6 then ord_before_amt_usd end) ord_before_amt_usd_no_refund_pix
from sub
-- where create_date<=20251231
group by substr(pay_date,1,6)



