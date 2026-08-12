select date_p,is_subscribed,count(distinct gid) as user_cnt
from 
(
    SELECT
        a.gid
        ,a.date_p
        -- 当前是否订阅：活跃时间落在订单的开始和结束之间，非当天新订阅
        ,MAX(CASE WHEN a.date_p > o.pay_date  and a.date_p <= cast(o.invalid_date as bigint) THEN 1 ELSE 0 END) AS is_subscribed
    FROM (
            SELECT date_p, os_p, country_id, final_id gid -- 历史firebase的咋办的
            FROM stat_sdk.sdk_odz_active
            WHERE date_p BETWEEN 20260510 AND 20260510
                AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
                AND os_p = 'ios'
                AND app_version = '8.8.0'
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
            and pay_date <= 20260510
            and is_subscribe='订阅'
            and product_sub_line = 'AirBrush'
    ) o
    ON a.gid = o.gid
    GROUP BY
        a.gid,
        a.date_p
) t
group by date_p,is_subscribed
;

select a.date_p,count(distinct a.gid) as dau
    ,count(distinct case when o.gid is not null then a.gid end) as popup_uv
FROM (
    SELECT date_p, os_p, country_id, final_id gid
    FROM stat_sdk.sdk_odz_active
    WHERE date_p BETWEEN 20260510 AND 20260510
        AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
        AND os_p = 'ios'
        AND app_version = '8.8.0'
) a
LEFT JOIN (
    SELECT distinct date_p,gid
    FROM stat_sdk.sdk_odz_source_data
    WHERE date_p BETWEEN 20260510 AND 20260510
        AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
        AND event_id IN  ('popup_show')
        AND params['pop_name']='no_free_delivery_popup'
) o
ON a.gid = o.gid and a.date_p = o.date_p
GROUP BY
    a.date_p