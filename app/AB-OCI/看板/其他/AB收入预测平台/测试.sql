-- oci
select *
from stat_sdk.filing_amz_subscription_valid_users
where business_unit='整体' and compute_unit='整体' and period_type='整体' 
	and business_line_p='airbrush' and business_series_p='key_countries'
    and date_p=20260401
;
select sum(monthly_valid_cnt)
from stat_sdk.filing_amz_subscription_valid_users
where business_unit='整体' and compute_unit!='整体' and period_type='整体' 
	and business_line_p='airbrush' and business_series_p='key_countries'
    and date_p=20260401
;
select pay_date,sum(ord_amt_usd) bookings
                ,sum(case when days > 365 then ord_amt_usd end) bookings_1
            from stat_vip.paid_oda_all_order_summary
            where app_id_p IN (7329803307041000000)
                and pay_date between 20260101 and 20260430
                and create_date <= 20260430
                and product_sub_line = 'AirBrush'
                and is_subscribe='订阅'
                and device_type = 'ios' AND order_type = 2
                and cur_pay_withhold_stage=1
                and period_type='月'
                and country_name='美国'
group by pay_date
;
-- 有效会员数和年月付费订单量的关系
select 
-- create_date,pay_date,invalid_date,period_type,refund_date,iap_product_id
count(distinct order_id) order_num_1
,count(distinct notify_pay_id) order_num,count(distinct gid) uv
            from stat_vip.paid_oda_all_order_summary
            where app_id_p IN (7329803307041000000)
                and (
                  		(pay_date between 20250401 and 20260331 and cur_pay_withhold_stage>=1)
                     	or (pay_date between 20260401 and 20260430 and cur_pay_withhold_stage=1)
                     )
                -- and create_date<=20250430
                and substr(create_date,1,6)<=substr(pay_date,1,6)
                and product_sub_line = 'AirBrush'
                and is_subscribe='订阅'
                and device_type = 'ios' -- AND order_type = 2
                and period_type='年'
                and country_name='美国'
                
                and create_date<=20260430
                and pay_date<=20260430
                -- and invalid_date<20260401
                and invalid_date is null
                -- group by substr(pay_date,1,6)
;

SELECT
    COUNT(DISTINCT notify_pay_id) AS order_num,
    count(distinct case when interval_days>=365 then notify_pay_id end) order_num_1,
    count(distinct case when interval_days<365 then notify_pay_id end) order_num_2

FROM (
    SELECT
        notify_pay_id,
        datediff(
            to_date(from_unixtime(unix_timestamp(lpad(trim(cast(invalid_date AS string)), 8, '0'), 'yyyyMMdd'))),
            to_date(from_unixtime(unix_timestamp(lpad(trim(cast(pay_date AS string)), 8, '0'), 'yyyyMMdd')))
        ) AS interval_days
    FROM stat_vip.paid_oda_all_order_summary
    WHERE app_id_p IN (7329803307041000000)
        AND pay_date BETWEEN 20250301 AND 20260331
        AND cur_pay_withhold_stage >= 1
        -- AND substr(create_date, 1, 6) <= substr(cast(pay_date AS string), 1, 6)
        AND product_sub_line = 'AirBrush'
        AND is_subscribe = '订阅'
        AND period_type = '年'
  		and country_name='美国'
  		and device_type = 'ios'
        AND invalid_date IS NOT NULL
        AND pay_date IS NOT NULL
) t
WHERE interval_days IS NOT NULL
;
-- 北斗
select *
from stat_ainancial.forcast_amz_subscription_valid_users
where business_unit='整体' and compute_unit='整体' and period_type='整体' 
	and business_line_p='airbrush' and business_series_p='key_countries'
    and date_p=20260401