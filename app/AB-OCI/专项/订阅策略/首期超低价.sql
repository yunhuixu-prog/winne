select a.country,a.os_p
    ,sum(uv) uv
    ,sum(sub_enter_uv) sub_enter_uv
    ,sum(sub_uv) sub_uv
    ,sum(pay_uv) pay_uv
    ,round(sum(sub_amt),2) sub_amt
    ,sum(retention_1_uv) retention_1_uv
    ,sum(sub_enter_uv_edit) sub_enter_uv_edit
    ,sum(sub_uv_edit) sub_uv_edit
    ,sum(pay_uv_edit) pay_uv_edit
    ,round(sum(sub_amt_edit),2) sub_amt_edit
from (
select
    -- case when a.country in ('美国','巴西','英国') then a.country else '其他' end country
    a.date_p
    ,case when a.country='巴西' then concat(a.country,'-',a.os_p) else a.country end country
    ,a.os_p
    ,count(distinct a.gid) uv
    ,count(distinct case when coalesce(s.is_sub_enter,0)=1 then a.gid end) sub_enter_uv
    ,count(distinct case when coalesce(s.is_sub,0)=1 then a.gid end) sub_uv
    ,count(distinct case when coalesce(s.is_sub_to_paid,0)=1 then a.gid end) pay_uv
    ,round(sum(s.sub_paid_ord_amt),2) sub_amt

    ,count(distinct a1.gid) retention_1_uv

    ,count(distinct case when coalesce(s.is_sub_enter_edit,0)=1 then a.gid end) sub_enter_uv_edit
    ,count(distinct case when coalesce(s.is_sub_edit,0)=1 then a.gid end) sub_uv_edit
    ,count(distinct case when coalesce(s.is_sub_to_paid_edit,0)=1 then a.gid end) pay_uv_edit
    ,round(sum(s.sub_paid_ord_amt_edit),2) sub_amt_edit
from (
    SELECT
        a.date_p,
        a.os_p,
        c.name AS country,
        a.final_id gid,
        CASE WHEN new_device.final_id IS NOT NULL THEN 'New' ELSE 'Old' END AS is_new
    FROM
    (
        SELECT date_p, final_id
                , max(os_p) os_p, max(country_id) country_id
        FROM stat_sdk.sdk_odz_active
        WHERE date_p BETWEEN 20260101 AND 20260430
            AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
            AND os_p IS NOT NULL
        group by date_p,final_id
    ) a
    LEFT JOIN
    (
        SELECT DISTINCT id, name
        FROM stat_sdk.dim_rna_ip_location
        WHERE level='1' and date_p is not null
    ) c
    ON a.country_id = c.id
    LEFT JOIN
    (
        SELECT final_id, date_p
        FROM stat_sdk.sdk_odz_new_device_info
        WHERE date_p BETWEEN 20260101 AND 20260430
          AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
          AND os_p IS NOT NULL
    )new_device
    ON a.final_id = new_device.final_id AND a.date_p = new_device.date_p
) a
-- Airbrush激活天数。定义: 设备首次启动距今天数。(如果有多次启动日期取最早日期)。
left join 
(
    select
        server_id as gid,min(first_launch_date) as first_launch_date
    from stat_sdk.sdk_oda_all_device_info
    where os_p in ('ios', 'android')
    and app_key_p in (
        '7F7023B6CEC7CDED'                -- Airbrush: Android
        , 'C851ED7164B6DF0F'              -- Airbrush: ios
    )
    and date_p = ${now_date}
    and server_id > 0
    group by server_id
) d 
on a.gid = d.gid
left join (
    SELECT
        a.gid
        ,a.date_p
        -- 当前是否订阅：活跃时间落在订单的开始和结束之间，非当天新订阅
        ,MAX(CASE WHEN a.date_p > o.pay_date  and a.date_p <= o.invalid_date THEN 1 ELSE 0 END) AS is_subscribed
        -- 历史订阅次数与金额
        ,SUM(CASE WHEN o.pay_date < a.date_p AND cur_pay_stage=1 and cur_pay_withhold_stage=0 THEN 1 ELSE 0 END) AS hist_trial_cnt
        ,SUM(CASE WHEN o.pay_date < a.date_p AND cur_pay_withhold_stage>=1 THEN 1 ELSE 0 END) AS hist_pay_cnt
    FROM (
            SELECT date_p, final_id gid
            FROM stat_sdk.sdk_odz_active
            WHERE date_p BETWEEN 20260101 AND 20260430
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
            and pay_date <= ${now_date}
            and is_subscribe='订阅'
            and product_sub_line = 'AirBrush'
    ) o
    ON a.gid = o.gid
    GROUP BY
        a.gid,
        a.date_p
) p
on a.date_p=p.date_p and a.gid=p.gid
left join (
    select
        date_p,gid
        ,MAX(case when event_id='sub_enter' then 1 end) is_sub_enter
        ,COUNT(case when event_id='sub_enter' then 1 end) sub_enter_pv
        ,MAX(case when event_id='sub_suc' then 1 end) is_sub
        ,MAX(case when event_id='sub_suc' and is_paid=1 then 1 end) is_sub_to_paid
        ,SUM(case when event_id='sub_suc' and is_paid=1 then devide_paid_ord_amt end) sub_paid_ord_amt

        ,MAX(case when event_id='sub_enter' and first_source='Edit' and second_source in ('Edit','Retouch','Material') then 1 end) is_sub_enter_edit
        ,MAX(case when event_id='sub_suc' and first_source='Edit' and second_source in ('Edit','Retouch','Material') then 1 end) is_sub_edit
        ,MAX(case when event_id='sub_suc' and is_paid=1 and first_source='Edit' and second_source in ('Edit','Retouch','Material') then 1 end) is_sub_to_paid_edit
        ,SUM(case when event_id='sub_suc' and is_paid=1 and first_source='Edit' and second_source in ('Edit','Retouch','Material') then devide_paid_ord_amt end) sub_paid_ord_amt_edit
    from stat_ab.filing_onz_sub_source_event_detail_level
    where date_p between 20260101 and 20260430
    group by date_p,gid
) s
on a.date_p=s.date_p and a.gid=s.gid
left join (
    SELECT date_p, final_id gid
    FROM stat_sdk.sdk_odz_active
    WHERE date_p BETWEEN 20260101 AND ${now_date}
        AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
        AND os_p IS NOT NULL
    group by date_p,final_id
) a1 
on a.gid=a1.gid and a.date_p=CAST(FROM_UNIXTIME(UNIX_TIMESTAMP(CAST(a1.date_p AS STRING), 'yyyyMMdd') - 86400, 'yyyyMMdd') AS BIGINT)
where coalesce(p.is_subscribed,0) = 0 and coalesce(p.hist_trial_cnt,0) = 0 and coalesce(p.hist_pay_cnt,0) = 0 
    and meitu_datediff(a.date_p, d.first_launch_date)>30
group by a.date_p,case when a.country='巴西' then concat(a.country,'-',a.os_p) else a.country end,a.os_p
) a
group by a.country,a.os_p
