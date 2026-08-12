-- 导入到财务平台表
set hive.exec.dynamic.partition.mode = nonstrict;
set hive.exec.dynamic.partition = true;
INSERT OVERWRITE TABLE stat_ainancial.forcast_amz_overview_metrics partition(business_line_p='airbrush', business_series_p='key_countries', date_p)

select business_unit,
        case when compute_unit like '%ios' then replace(compute_unit,'ios','iOS')
             when compute_unit like '%android' then replace(compute_unit,'android','Android')
        else compute_unit
        end compute_unit,
        mau,
        non_member_mau,
        revenue_share_rate,
        date_p
from stat_sdk.filing_amz_overview_metrics_from_oci
where business_line_p='airbrush' 
    and business_series_p='key_countries' 
    and date_p=${start_time}

;

set hive.exec.dynamic.partition.mode = nonstrict;
set hive.exec.dynamic.partition = true;
INSERT OVERWRITE TABLE stat_ainancial.forcast_amz_subscription_orders partition(business_line_p='airbrush', business_series_p='key_countries', date_p)

select business_unit,
        case when compute_unit like '%ios' then replace(compute_unit,'ios','iOS')
             when compute_unit like '%android' then replace(compute_unit,'android','Android')
        else compute_unit
        end compute_unit,
        period_type,
        days,
        new_sub_amt_net_incl_refund,
        new_sub_amt_net_excl_refund,
        new_sub_amt_gross_incl_refund,
        new_sub_amt_gross_excl_refund,
        renewal_sub_amt_net_incl_refund,
        renewal_sub_amt_net_excl_refund,
        renewal_sub_amt_gross_incl_refund,
        renewal_sub_amt_gross_excl_refund,
        new_sub_orders,
        renewal_sub_orders,
        date_p
from stat_sdk.filing_amz_subscription_orders_from_oci
where business_line_p='airbrush' 
    and business_series_p='key_countries' 
    and date_p=${start_time}

;

set hive.exec.dynamic.partition.mode = nonstrict;
set hive.exec.dynamic.partition = true;
INSERT OVERWRITE TABLE stat_ainancial.forcast_amz_subscription_valid_users partition(business_line_p='airbrush', business_series_p='key_countries', date_p)

select business_unit
        ,case when compute_unit like '%ios' then replace(compute_unit,'ios','iOS')
             when compute_unit like '%android' then replace(compute_unit,'android','Android')
        else compute_unit
        end compute_unit
        ,period_type
        ,monthly_valid_cnt
        ,date_p
from stat_sdk.filing_amz_subscription_valid_users_from_oci
where business_line_p='airbrush' 
    and business_series_p='key_countries' 
    and date_p=${start_time}

