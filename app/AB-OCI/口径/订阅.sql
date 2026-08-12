-- 表一：stat_vip.paid_oda_all_order_summary
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
;
-- 上级表（用来核对）:相比stat_vip.paid_oda_all_order_summary多了三个字段，以及去掉is_subscribe='订阅'
select substr(a.refund_time,1,8)  AS refund_date
    ,substr(a.invalid_time,1,8) AS invalid_date
    ,substr(a.create_time,1,8)  AS create_date
from stat_vip.paid_oda_vip_all_order
WHERE date_p=20260203
    and pay_date BETWEEN 20260122 AND 20260129
    and app_id_p IN (7329803307041000000)
;
-- 分摊收入表（不怎么用）
SELECT  share_date
    ,sum(share_ord_amt) ord_amt
    ,sum(share_ord_before_amt) ord_before_amt
FROM stat_vip.paid_mda_analyze_share_detail
WHERE share_date between 20260101 and 20260228
    and app_id IN (7329803307041000000)
    and busi_type_name='交易'
group by share_date
-- refund_share_date,refund_share_before_amt


;