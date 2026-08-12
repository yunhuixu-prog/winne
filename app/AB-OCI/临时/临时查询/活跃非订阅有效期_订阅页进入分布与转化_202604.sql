select 
    CASE
            WHEN coalesce(enter_cnt,0) <= 10 THEN coalesce(enter_cnt,0)
            ELSE 999
        END AS enter_cnt_bucket
    ,COUNT(1) AS user_cnt
    ,SUM(has_success) AS success_user_cnt
    ,SUM(has_success_to_paid) AS success_to_paid_user_cnt
    ,SUM(has_success_to_paid_ord_amt) AS success_to_paid_ord_amt
from (
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
            WHERE date_p BETWEEN 20260401 AND 20260430
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
            and pay_date <= 20260430
            and is_subscribe='订阅'
            and product_sub_line = 'AirBrush'
    ) o
    ON a.gid = o.gid
    GROUP BY
        a.gid,
        a.date_p
) a 
left join (
    -- SELECT
    --     date_p,gid,
    --     SUM(CASE WHEN event_id = 'w_subscription_enter' THEN 1 ELSE 0 END) AS enter_cnt,
    --     MAX(CASE WHEN event_id = 'w_subscription_success' THEN 1 ELSE 0 END) AS has_success
    -- FROM stat_sdk.sdk_odz_source_data
    -- WHERE date_p BETWEEN 20260401 AND 20260430
    --     AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
    --     AND event_id IN ('w_subscription_enter', 'w_subscription_click', 'w_subscription_success')
    --     AND app_version >= '7.19.0'
    -- GROUP BY date_p,gid

    select date_p
        ,gid
        ,SUM(CASE WHEN event_id = 'w_subscription_enter' THEN 1 ELSE 0 END) AS enter_cnt
        ,MAX(CASE WHEN event_id = 'sub_suc' THEN 1 ELSE 0 END) AS has_success
        ,MAX(CASE WHEN event_id = 'sub_suc' and is_paid=1 THEN 1 ELSE 0 END) AS has_success_to_paid
        ,MAX(CASE WHEN event_id = 'sub_suc' and is_paid=1 THEN paid_ord_amt ELSE 0 END) AS has_success_to_paid_ord_amt
    from stat_ab.filing_onz_sub_source_event_detail
    where
        date_p between 20260401 AND 20260430
        and event_id in ('w_subscription_enter','w_subscription_click','w_subscription_success','sub_suc')
    GROUP BY date_p,gid
) b
on a.gid=b.gid and a.date_p=b.date_p
where a.is_subscribed=0 -- and a.hist_trial_cnt=0 and a.hist_pay_cnt=0
group by CASE
            WHEN coalesce(enter_cnt,0) <= 10 THEN coalesce(enter_cnt,0)
            ELSE 999
        END
