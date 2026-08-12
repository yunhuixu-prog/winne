select a.function_name
    ,sum(enter_uv) enter_uv
    ,sum(use_uv) use_uv
    ,sum(save_uv) save_uv
    ,sum(sub_enter_uv) sub_enter_uv
    ,sum(sub_uv) sub_uv
    ,sum(pay_uv) pay_uv
    ,round(sum(sub_amt),2) sub_amt
    ,sum(retention_1_uv_save) retention_1_uv_save
    ,sum(blocked_uv) blocked_uv
    ,sum(no_blocked_uv) no_blocked_uv
    ,sum(retention_1_uv_blocked) retention_1_uv_blocked
    ,sum(retention_1_uv_no_blocked) retention_1_uv_no_blocked
from (
select
    a.date_p
    ,f.sub_func_level2_name as function_name
    ,count(distinct case when coalesce(f.enter_pv,0)>0 then a.gid end) enter_uv
    ,count(distinct case when coalesce(f.use_pv,0)>0 then a.gid end) use_uv
    ,count(distinct case when coalesce(f.save_pv,0)>0 then a.gid end) save_uv
    ,count(distinct case when coalesce(sf.is_sub_enter,0)=1 then a.gid end) sub_enter_uv
    ,count(distinct case when coalesce(sf.is_sub,0)=1 then a.gid end) sub_uv
    ,count(distinct case when coalesce(sf.is_sub_to_paid,0)=1 then a.gid end) pay_uv
    ,round(sum(sf.sub_paid_ord_amt),2) sub_amt

    ,count(distinct case when coalesce(f.save_pv,0)>0 then a1.gid end) retention_1_uv_save
    ,count(distinct case when coalesce(f.enter_pv,0)>0 and coalesce(sf.is_sub_enter,0)>=1 
        then a.gid end) blocked_uv
    ,count(distinct case when coalesce(f.enter_pv,0)>0 and coalesce(sf.is_sub_enter,0)=0 
        then a.gid end) no_blocked_uv
    ,count(distinct case when coalesce(f.enter_pv,0)>0 and coalesce(sf.is_sub_enter,0)>=1 
        then a1.gid end) retention_1_uv_blocked
    ,count(distinct case when coalesce(f.enter_pv,0)>0 and coalesce(sf.is_sub_enter,0)=0 
        then a1.gid end) retention_1_uv_no_blocked
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
        WHERE date_p BETWEEN 20260101 AND 20260331
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
        WHERE date_p BETWEEN 20260101 AND 20260331
          AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
          AND os_p IS NOT NULL
    )new_device
    ON a.final_id = new_device.final_id AND a.date_p = new_device.date_p
) a
left join (
    SELECT
        a.gid
        ,a.date_p
        -- 当前是否订阅：活跃时间落在订单的开始和结束之间，非当天新订阅
        ,MAX(CASE WHEN a.date_p > o.pay_date  and a.date_p <= cast(o.invalid_date as bigint) THEN 1 ELSE 0 END) AS is_subscribed
        -- 历史订阅次数与金额
        ,SUM(CASE WHEN o.pay_date < a.date_p AND cur_pay_stage=1 and cur_pay_withhold_stage=0 THEN 1 ELSE 0 END) AS hist_trial_cnt
        ,SUM(CASE WHEN o.pay_date < a.date_p AND cur_pay_withhold_stage>=1 THEN 1 ELSE 0 END) AS hist_pay_cnt
    FROM (
            SELECT date_p, final_id gid
            FROM stat_sdk.sdk_odz_active
            WHERE date_p BETWEEN 20260101 AND 20260331
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
join (
    SELECT date_p,gid,sub_func_level2_name
        ,SUM(case when event_type='进入' then cnt end) enter_pv
        ,SUM(case when event_type='打勾' then cnt end) use_pv
        ,SUM(case when event_type='保存' then cnt end) save_pv
    FROM stat_sdk.airbrush_mdz_tool_behavior_detail
    WHERE date_p between 20260101 and 20260331
        AND model_p IN ('image_edit') -- , 'camera', 'sp_edit', 'H5'
        AND tool_level in ('2')
    GROUP BY date_p,gid,sub_func_level2_name
) f
on a.date_p=f.date_p and a.gid=f.gid
left join (
    select
        date_p,gid
        ,case when third_source in ('Skin') then fourth_source 
                when first_source='AIGC' then 'AI Image'
        else third_source end third_source
        ,MAX(case when event_id='sub_enter' then 1 end) is_sub_enter
        ,COUNT(case when event_id='sub_enter' then 1 end) sub_enter_pv
        ,MAX(case when event_id='sub_suc' then 1 end) is_sub
        ,MAX(case when event_id='sub_suc' and is_paid=1 then 1 end) is_sub_to_paid
        ,SUM(case when event_id='sub_suc' and is_paid=1 then devide_paid_ord_amt end) sub_paid_ord_amt
    from stat_ab.filing_onz_sub_source_event_detail_level
    where date_p between 20260101 and 20260331
        and ((first_source='Edit' and second_source in ('Edit','Retouch','Material')) 
            or (first_source='AIGC' and second_source='AI Filter'))
    group by date_p,gid,case when third_source in ('Skin') then fourth_source 
                when first_source='AIGC' then 'AI Image'
        else third_source end
) sf
on f.date_p=sf.date_p and f.gid=sf.gid and f.sub_func_level2_name=sf.third_source
left join (
    SELECT date_p, final_id gid
    FROM stat_sdk.sdk_odz_active
    WHERE date_p BETWEEN 20260101 AND ${now_date}
        AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
        AND os_p IS NOT NULL
) a1 
-- on a.gid=a1.gid and a.date_p=a.date_p=CAST(FROM_UNIXTIME(UNIX_TIMESTAMP(CAST(a1.date_p AS STRING), 'yyyyMMdd') - 86400, 'yyyyMMdd') AS BIGINT)
on a.gid=a1.gid and a.date_p=CAST(date_format(date_sub(from_unixtime(unix_timestamp(cast(a1.date_p as string), 'yyyyMMdd')), 1), 'yyyyMMdd') AS BIGINT)
where a.country in ('巴西')
    and coalesce(p.is_subscribed,0) = 0
group by a.date_p,f.sub_func_level2_name
) a
group by a.function_name
