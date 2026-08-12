SELECT
    a.gid
    ,a.date_p
    -- 当前是否订阅：活跃时间落在订单的开始和结束之间，非当天新订阅
    ,MAX(CASE WHEN a.date_p > o.pay_date  and a.date_p <= cast(o.invalid_date as bigint) THEN 1 ELSE 0 END) AS is_subscribed
    -- 历史订阅次数与金额
    ,SUM(CASE WHEN o.pay_date < a.date_p AND cur_pay_stage=1 and cur_pay_withhold_stage=0 THEN 1 ELSE 0 END) AS hist_trial_cnt
    ,SUM(CASE WHEN o.pay_date < a.date_p AND cur_pay_withhold_stage>=1 THEN 1 ELSE 0 END) AS hist_pay_cnt
FROM (
        SELECT date_p, os_p, country_id, final_id gid -- 历史firebase的咋办的
        FROM stat_sdk.sdk_odz_active
        WHERE date_p BETWEEN 20250101 AND 20260331
            AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
            AND os_p IS NOT NULL
) a
LEFT JOIN (
    select
        gid
        ,pay_date
        ,invalid_date
        ,period_type
        ,device_type as os_type
        ,nvl(country_name,'未知') country_code
        ,cur_pay_stage
        ,cur_pay_withhold_stage
        ,ord_amt_usd
    from stat_vip.paid_oda_all_order_summary
    where app_id_p IN (7329803307041000000)
        and pay_date <= 20260329
        and is_subscribe='订阅'
        and product_sub_line = 'AirBrush'
) o
ON a.gid = o.gid
GROUP BY
    a.gid,
    a.date_p

;
-- 当前仍是会员的用户
select gid
    from stat_vip.paid_sda_vip_membership_user
    where date_p = ${day}
    and app_id = 7329803307041000000          -- AirBrush
    and nvl(gid,'0') <> '0'
    and replace(to_date(from_unixtime(
        cast(substring(invalidate_time,0,10) as bigint),
        'yyyy-MM-dd HH:mm:ss')),'-','') >= ${day}
    group by gid
;
select
        gid
    from stat_vip.paid_oda_all_order_summary
    where app_id_p IN (7329803307041000000)
        and pay_date <= ${day}
        and is_subscribe='订阅'
        and product_sub_line = 'AirBrush'
        and cast(invalid_date as bigint)>=${day}
    group by gid
-- 历史是会员
select gid
    from stat_vip.paid_sda_vip_membership_user
    where date_p = ${day}
    and app_id = 7329803307041000000          -- AirBrush
    and nvl(gid,'0') <> '0'
    group by gid
;
select
        gid
    from stat_vip.paid_oda_all_order_summary
    where app_id_p IN (7329803307041000000)
        and pay_date <= ${day}
        and is_subscribe='订阅'
        and product_sub_line = 'AirBrush'
    group by gid