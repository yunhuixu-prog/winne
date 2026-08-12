SET hive.exec.dynamic.partition.mode=nonstrict;
SET hive.exec.max.dynamic.partitions=1500;
SET hive.exec.max.dynamic.partitions.pernode=1000;
insert overwrite table stat_ab.filing_adz_income_daily PARTITION(date_p)
select
     t3.os_type as os_type
     ,t3.country_code as country_code
     ,t3.geographic_subdivision_v2 as geographic_subdivision_v2
     ,period_type
     ,pay_channel
     ,gmv_usd
     ,refund_gmv_usd
     ,gmv_rmb_no_refund
     ,gmv_before_rmb_no_refund
     ,gmv_usd_no_refund
     ,gmv_before_usd_no_refund
     ,new_member
     ,trial_member
     ,new_pay_member
     ,renew_member
     ,pay_member
     ,new_pay_gmv_usd
     ,new_pay_gmv_before_usd
     ,renew_gmv_usd
     ,renew_gmv_before_usd
     ,new_pay_notifyid
     ,renew_notifyid
     ,pay_date date_p
from
(
    select  nvl(os_type,'整体')  as os_type
            ,nvl(country_code,'整体') as country_code
            ,nvl(period_type,'整体') as period_type
            ,nvl(pay_channel,'整体') as pay_channel
            ,nvl(geographic_subdivision_v2,'整体') as  geographic_subdivision_v2
            ,pay_date
            ,sum(gmv_usd) gmv_usd
            ,sum(refund_gmv_usd) refund_gmv_usd
            ,sum(gmv_rmb_no_refund) gmv_rmb_no_refund
            ,sum(gmv_before_rmb_no_refund) gmv_before_rmb_no_refund
            ,sum(gmv_usd_no_refund) gmv_usd_no_refund
            ,sum(gmv_before_usd_no_refund) gmv_before_usd_no_refund
            ,sum(new_member) new_member
            ,sum(trial_member) trial_member
            ,sum(new_pay_member) new_pay_member
            ,sum(renew_member) renew_member
            ,sum(pay_member) pay_member
            ,sum(new_pay_gmv_usd) new_pay_gmv_usd
            ,sum(new_pay_gmv_before_usd) new_pay_gmv_before_usd
            ,sum(renew_gmv_usd) renew_gmv_usd
            ,sum(renew_gmv_before_usd) renew_gmv_before_usd
            ,sum(new_pay_notifyid) new_pay_notifyid
            ,sum(renew_notifyid) renew_notifyid
    from
    (
        select
            os_type
            ,country_code
            ,period_type
            ,pay_channel
            ,nvl(t22.geographic_subdivision_v2,'东亚') as geographic_subdivision_v2
            ,pay_date
            ,sum(case when type='no_refund' then ord_amt_usd else 0 end) as gmv_usd     -- 每天收入
            ,sum(case when type='refund' then ord_amt_usd else 0 end) as refund_gmv_usd     -- 每天退款
            ,sum(ord_amt) as gmv_rmb_no_refund, sum(ord_before_amt) as gmv_before_rmb_no_refund
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
            ,count(distinct case when type='no_refund' and cur_pay_withhold_stage=1 then notify_pay_id else null end) as new_pay_notifyid   -- 新增付费订单
            ,count(distinct case when type='no_refund' and cur_pay_withhold_stage>=2 then notify_pay_id else null end) as renew_notifyid   -- 续费订单
        from
        (
            select 'no_refund' type
                ,notify_pay_id
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
                and pay_date between ${start_time} and ${end_time}
--                 and create_date <= pay_date  -- 和中台表每天收入统一口径，尽量保证每天数值不变，但不同订单分区仍会有较小差距
                and product_sub_line = 'AirBrush'
                and is_subscribe='订阅'

            union all

            select 'refund' type
                ,notify_pay_id
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
                and refund_date between ${start_time} and ${end_time}
--                 and create_date <= refund_date  -- 和中台表每天收入统一口径，保证每天数值不变，但不同订单分区仍会有较小差距
                and product_sub_line = 'AirBrush'
                and is_subscribe='订阅'
                and pay_status=6
        ) t1
        left join
        (
            select sdk_country_name
                    ,geographic_subdivision_v2
            from stat_sdk.dim_rna_ip_location
            where date_p=${now_time}
            group by sdk_country_name,geographic_subdivision_v2
        ) t22
        on t1.country_code=t22.sdk_country_name
        group by os_type,country_code,period_type,pay_channel,nvl(t22.geographic_subdivision_v2,'东亚'),pay_date
    )d
--     group by os_type,country_code,period_type,pay_channel,geographic_subdivision_v2,pay_date with cube
    group by os_type,country_code,period_type,pay_channel,geographic_subdivision_v2,pay_date GROUPING SETS (
        (os_type, country_code, period_type, pay_channel, geographic_subdivision_v2, pay_date),
        -- 5维度
        (os_type, country_code, period_type, pay_channel, pay_date),
        (os_type, country_code, period_type, geographic_subdivision_v2, pay_date),
        (os_type, country_code, pay_channel, geographic_subdivision_v2, pay_date),
        (os_type, period_type, pay_channel, geographic_subdivision_v2, pay_date),
        (country_code, period_type, pay_channel, geographic_subdivision_v2, pay_date),
        -- 4维度
        (os_type, country_code, period_type, pay_date),
        (os_type, country_code, pay_channel, pay_date),
        (os_type, country_code, geographic_subdivision_v2, pay_date),
        (os_type, period_type, pay_channel, pay_date),
        (os_type, period_type, geographic_subdivision_v2, pay_date),
        (os_type, pay_channel, geographic_subdivision_v2, pay_date),
        (country_code, period_type, pay_channel, pay_date),
        (country_code, period_type, geographic_subdivision_v2, pay_date),
        (country_code, pay_channel, geographic_subdivision_v2, pay_date),
        (period_type, pay_channel, geographic_subdivision_v2, pay_date),
        -- 3维度
        (os_type, country_code, pay_date),
        (os_type, period_type, pay_date),
        (os_type, pay_channel, pay_date),
        (os_type, geographic_subdivision_v2, pay_date),
        (country_code, period_type, pay_date),
        (country_code, pay_channel, pay_date),
        (country_code, geographic_subdivision_v2, pay_date),
        (period_type, pay_channel, pay_date),
        (period_type, geographic_subdivision_v2, pay_date),
        (pay_channel, geographic_subdivision_v2, pay_date),
        -- 2维度
        (os_type, pay_date),
        (country_code, pay_date),
        (period_type, pay_date),
        (pay_channel, pay_date),
        (geographic_subdivision_v2, pay_date),
        -- 1维度
        (pay_date)
      )
) t3
