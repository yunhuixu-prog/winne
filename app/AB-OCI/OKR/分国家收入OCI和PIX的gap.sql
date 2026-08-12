-- OCI
select country_code,gmv_year_usd-refund_gmv_year_usd
from stat_vip.vip_adz_middle_income_dayoci
where date_p=20260430
    and os_type='整体'
    and country_code in ('整体','美国','巴西','英国','墨西哥','西班牙','加拿大','澳大利亚')
    and period_type='整体'
    and pay_channel='整体'
    and geographic_subdivision_v2='整体'
    and ocean_name='整体'
    and product_sub_line='AirBrush'
    and type='订阅'
;

with sub as
(
    select 'no_refund' type,pay_date,substr(create_time,1,8) create_date
         ,case when country_name in ('美国','巴西','英国','墨西哥','西班牙','加拿大','澳大利亚') then country_name
          else '其他'
          end country
         ,days,os_type,pay_status
         ,ord_amt,ord_before_amt
         ,ord_amt_usd,round(case when ord_amt=0 then 0 else ord_amt_usd*ord_before_amt/ord_amt end,3) ord_before_amt_usd
         ,cur_pay_stage,cur_pay_withhold_stage,order_type,gid,period_type
    from stat_vip.paid_oda_vip_all_order
    WHERE date_p=20260430
        and pay_date between 20260101 and 20260430
        and substr(create_time,1,8)<=20260430
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
         ,cur_pay_stage,cur_pay_withhold_stage,order_type,gid,period_type
    from stat_vip.paid_oda_vip_all_order
    WHERE date_p=20260430
        and pay_date between 20260101 and 20260430
        and substr(create_time,1,8)<=20260430
        and app_id_p IN (7329803307041000000)
        and commodity_id_P not in (-1)
        and pay_status=6
)

select country
        ,sum(ord_amt_usd) gmv_no_refund_day    -- 毛利(剔除退款)
        ,sum(ord_before_amt_usd) gmv_no_refund_day_before    -- 收入(剔除退款)
from sub
group by country


;
-- PIX
select case when country in ('United States','Brazil','United Kingdom','Mexico','Spain','Canada','Australia') then country 
    else 'Others' end country
    ,sum(VAS) Bookings
from dataintegration-265403.subscription.dws_subscription_overview_monthly_view
where Date between '2026-01-01' and '2026-04-30' 
    and App='AirBrush' and (country!='All' or country is null)
group by 1
