
select date_p
     ,os_type
     ,country_code
     ,pay_member,gmv_usd_no_refund,new_pay_member,new_pay_gmv_usd,renew_member,renew_gmv_usd
from stat_ab.filing_adz_income_daily
where date_p between 20260323 and 20260405
    and period_type='整体' and pay_channel='整体' and geographic_subdivision_v2='整体'
order by date_p
;
select date_p
     ,os_type
     ,country_code
     ,period_type
     ,pay_member,gmv_usd_no_refund,new_pay_member,new_pay_gmv_usd,renew_member,renew_gmv_usd
from stat_ab.filing_adz_income_daily
where date_p between 20260323 and 20260405
    and country_code in ('整体','美国','巴西','英国') and pay_channel='整体' and geographic_subdivision_v2='整体'
order by date_p