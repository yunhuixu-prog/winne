select
    -- 
    a.os_type os_type
    ,case when b.ab_code in ('28819') then '对照组'
        when b.ab_code in ('28820') then '实验组A'
        when b.ab_code in ('28821') then '实验组B'
        end code
    ,a.date_p date_p
    ,a.duration types
    ,round(sum(case when a.event_id='sub_suc' and a.is_paid=1 then a.paid_ord_amt end),2) gmv
from (
    select date_p
        ,case when os_type in ('其他') then 'Android'
            else os_type
            end os_type
        ,event_id
        ,unix_timestamp(event_time, 'yyyyMMddHHmmss') event_timestamp -- 1776025242
        ,gid,is_new,is_ua,country
        ,duration,source_module,source_0,source_1
        ,mids_material_id,mids_category_id,sku
        ,is_paid,paid_date,paid_ord_amt
    from stat_ab.filing_onz_sub_source_event_detail
    where
        date_p between 20260414 and 20260426
        and event_id in ('w_subscription_enter','w_subscription_click','w_subscription_success','sub_suc')
) a
join (
    select *
    from
    (
        select
            fa.gid,fa.os_p os_type,fa.country,fa.is_new
            ,e.ab_code,e.enter_abtest_date,e.event_timestamp
            ,row_number() over(partition by e.gid order by event_timestamp) ranks
        from (
            SELECT
                a.date_p,
                a.os_p,
                c.name AS country,
                a.final_id gid,
                CASE WHEN new_device.final_id IS NOT NULL THEN 'New' ELSE 'Old' END AS is_new
            FROM
            (
                SELECT date_p, os_p, country_id, final_id
                FROM stat_sdk.sdk_odz_active
                WHERE date_p BETWEEN 20260414 and 20260426
                    AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
                    AND os_p IS NOT NULL
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
                WHERE date_p BETWEEN 20260414 and 20260426
                AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
                AND os_p IS NOT NULL
            )new_device
            ON a.final_id = new_device.final_id AND a.date_p = new_device.date_p
        ) fa
        join (
            SELECT date_p enter_abtest_date
                ,CAST(`time`/1000 AS bigint) event_timestamp
                ,sdk_type os_type,gid
                ,params['current_abcode'] ab_code
            FROM stat_sdk.sdk_odz_source_data
            WHERE date_p between 20260414 and 20260426
                AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
                AND event_id = 'abcode_enter_test'
                AND params['current_abcode'] in ('28819','28820','28821')
        ) e ON e.gid = fa.gid and e.enter_abtest_date = fa.date_p
        where e.gid is not null
    ) t
    where ranks=1
) b
on a.gid= b.gid
where b.event_timestamp-15 <= a.event_timestamp
group by a.os_type,case when b.ab_code in ('28819') then '对照组'
        when b.ab_code in ('28820') then '实验组A'
        when b.ab_code in ('28821') then '实验组B'
        end
        ,a.duration
        ,a.date_p