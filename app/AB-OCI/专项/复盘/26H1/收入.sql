
select
    substr(pay_date,1,6) pay_month
    ,case when pay_date between 20250101 and 20250630 then '2025H1'
          when pay_date between 20250701 and 20251231 then '2025H2'
          when pay_date between 20260101 and 20260630 then '2026H1'
    end pay_h
    ,os_type
    ,case when country_code in ('美国','英国','巴西','墨西哥','西班牙','加拿大','澳大利亚') then country_code
    else '其他' end as country_name
    ,period_type
    ,sum(case when type='no_refund' then ord_amt_usd else 0 end) as gmv_usd     -- 每天收入
    ,sum(case when type='refund' then ord_amt_usd else 0 end) as refund_gmv_usd     -- 每天退款
    ,sum(ord_amt_usd) as gmv_usd_no_refund, sum(ord_before_amt_usd) as gmv_before_usd_no_refund
    ,count(distinct case when type='no_refund' and cur_pay_stage=1 then gid else null end) as new_member           -- 新增会员（含免费试用)
    ,count(distinct case when type='no_refund' and cur_pay_stage=1 and cur_pay_withhold_stage=0 and order_type=2 then gid else null end) as trial_member           -- 新增试用会员
    ,count(distinct case when type='no_refund' and cur_pay_withhold_stage=1 then gid else null end) as new_pay_member   -- 新增付费会员
    ,count(distinct case when type='no_refund' and cur_pay_withhold_stage>=2 then gid else null end) as renew_member   -- 续费会员数
    ,count(distinct case when type='no_refund' and cur_pay_withhold_stage>=1 then gid else null end) as pay_member   -- 付费会员数
    ,sum(case when type='no_refund' and cur_pay_withhold_stage=1 then ord_amt_usd else null end) new_pay_gmv_usd
    ,sum(case when type='no_refund' and cur_pay_withhold_stage=1 then ord_before_amt_usd else null end) new_pay_gmv_before_usd
    ,sum(case when type='no_refund' and cur_pay_withhold_stage>=2 then ord_amt_usd else null end) renew_gmv_usd
    ,sum(case when type='no_refund' and cur_pay_withhold_stage>=2 then ord_before_amt_usd else null end) renew_gmv_before_usd
    ,count(distinct case when type='no_refund' and cur_pay_withhold_stage=1 then order_id else null end) as new_pay_notifyid   -- 新增付费订单
    ,count(distinct case when type='no_refund' and cur_pay_withhold_stage>=2 then order_id else null end) as renew_notifyid   -- 续费订单
from
(
    select 'no_refund' type
        ,notify_pay_id,order_id
        ,device_type as os_type
        ,nvl(country_name,'未知') country_code
        ,period_type
        ,pay_date
        ,ord_amt,ord_before_amt
        ,ord_amt_usd,round(case when ord_amt=0 then 0 else ord_amt_usd*ord_before_amt/ord_amt end,3) ord_before_amt_usd
        ,gid
        ,cur_pay_stage
        ,cur_pay_withhold_stage
        ,order_type
        ,invalid_date
        ,pay_status
        ,case when pay_channel is null or pay_channel = '' then '未知'
                else pay_channel end as pay_channel
    from stat_vip.paid_oda_all_order_summary
    where app_id_p IN (7329803307041000000)
        and pay_date between 20250101 and 20260630
        and create_date <= 20260630
        and substr(create_date,1,4) <= substr(pay_date,1,4)
        and product_sub_line = 'AirBrush'
        and is_subscribe='订阅'

    union all

    select 'refund' type
        ,notify_pay_id,order_id
        ,device_type as os_type
        ,nvl(country_name,'未知') country_code
        ,period_type
        ,refund_date pay_date
        ,-refund_amt ord_amt,-refund_before_amt ord_before_amt
        ,-refund_amt_usd ord_amt_usd,-round(case when refund_amt=0 then 0 else refund_amt_usd*refund_before_amt/refund_amt end,3) ord_before_amt_usd
        ,gid
        ,cur_pay_stage
        ,cur_pay_withhold_stage
        ,order_type
        ,invalid_date
        ,pay_status
        ,case when pay_channel is null or pay_channel = '' then '未知'
                else pay_channel end as pay_channel
    from stat_vip.paid_oda_all_order_summary
    where app_id_p IN (7329803307041000000)
        and refund_date between 20250101 and 20260630
        and create_date <= 20260630
        and substr(create_date,1,4) <= substr(pay_date,1,4)
        and product_sub_line = 'AirBrush'
        and is_subscribe='订阅'
        and pay_status=6
) t1
left join
(
    select sdk_country_name
            ,geographic_subdivision_v2
    from stat_sdk.dim_rna_ip_location
    where date_p=20260630
    group by sdk_country_name,geographic_subdivision_v2
) t22
on t1.country_code=t22.sdk_country_name
group by os_type
    ,case when country_code in ('美国','英国','巴西','墨西哥','西班牙','加拿大','澳大利亚') then country_code
    else '其他' end
    ,period_type,substr(pay_date,1,6)
    ,case when pay_date between 20250101 and 20250630 then '2025H1'
          when pay_date between 20250701 and 20251231 then '2025H2'
          when pay_date between 20260101 and 20260630 then '2026H1'
    end

;
-- 非会员MAU
select 
    case when business_unit in ('美国','英国','巴西','墨西哥','西班牙','加拿大','澳大利亚') then business_unit
    else '其他' end as country_name
    ,date_p
    ,sum(mau) mau
    ,sum(non_member_mau) non_member_mau
from stat_sdk.filing_amz_overview_metrics
where business_line_p='airbrush'
    and business_series_p='key_countries'
    and date_p between 20250101 and 20260630
    and business_unit!='整体'
    and compute_unit='整体'
group by case when business_unit in ('美国','英国','巴西','墨西哥','西班牙','加拿大','澳大利亚') then business_unit
    else '其他' end,date_p
