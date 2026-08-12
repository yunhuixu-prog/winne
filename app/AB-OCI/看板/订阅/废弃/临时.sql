
select * from stat_ab.filing_adz_income_daily
where date_p=20260209 and os_type='整体'
	and country_code='整体'
    and geographic_subdivision_v2='整体'
    and period_type='整体'
    and pay_channel='整体'
;
select sum(ord_amt_usd)
            from stat_vip.paid_oda_vip_all_order
            where app_id_p IN (7329803307041000000)
            	and date_p=20260211
                and pay_date = 20260211
                and substr(create_time,1,8) <= 20260211
                and product_sub_line = 'AirBrush'
;
