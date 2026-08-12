select date_p,os_type,country_code,period_type
    ,gmv_usd_no_refund,new_pay_member,renew_member,pay_member,new_pay_gmv_usd,renew_gmv_usd
    -- ,sum(gmv_usd_no_refund) gmv_usd_no_refund
    -- ,sum(new_pay_member) new_pay_member
    -- ,sum(renew_member) renew_member
    -- ,sum(pay_member) pay_member
    -- ,sum(new_pay_gmv_usd) new_pay_gmv_usd
    -- ,sum(renew_gmv_usd) renew_gmv_usd
from stat_ab.filing_amz_income_monthly
where date_p between 20250101 and 20250630
and country_code in ('整体','美国','巴西','英国')
and period_type in ('整体','年','月','周')
and pay_channel='整体'
and geographic_subdivision_v2='整体'

union all 

select date_p,os_type,country_code,period_type
    ,gmv_usd_no_refund,new_pay_member,renew_member,pay_member,new_pay_gmv_usd,renew_gmv_usd
from stat_ab.filing_amz_income_monthly
where date_p between 20250701 and 20251231
and country_code in ('整体','美国','巴西','英国')
and period_type in ('整体','年','月','周')
and pay_channel='整体'
and geographic_subdivision_v2='整体'

union all 

select date_p,os_type,country_code,period_type
    ,gmv_usd_no_refund,new_pay_member,renew_member,pay_member,new_pay_gmv_usd,renew_gmv_usd
from stat_ab.filing_amz_income_monthly
where date_p between 20260101 and 20260331
and country_code in ('整体','美国','巴西','英国')
and period_type in ('整体','年','月','周')
and pay_channel='整体'
and geographic_subdivision_v2='整体'
