select
    -- a.date_p,
    a.os_type os_type
    ,case when b.ab_code in ('28923') then '对照组'
        when b.ab_code in ('28924') then '实验组A'
        when b.ab_code in ('28932') then '实验组B'
        end code
    ,b.is_new is_new
    ,case when b.country in ('美国','巴西','英国') then b.country else '其他' end country
    ,b.install_days_type install_days_type
    ,b.hist_sub_type hist_sub_type
--     ,b.enter_abtest_date
    -- 付费
    ,a.duration duration

    ,count(distinct case when a.event_id='w_subscription_enter' then a.gid end) sub_enter_uv
    ,count(distinct case when a.event_id='w_subscription_click' then a.gid end) sub_click_uv
    ,count(distinct case when a.event_id='sub_suc' then a.gid end) sub_suc_uv
    ,count(distinct case when a.event_id='sub_suc' and a.is_paid=1 then a.gid end) sub_suc_to_paid_uv
    ,round(sum(case when a.event_id='sub_suc' and a.is_paid=1 then a.paid_ord_amt end),2) sub_suc_to_paid_gmv
    ,0 enter_abtest_uv
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
        date_p between 20260508 and 20260526
        and event_id in ('w_subscription_enter','w_subscription_click','w_subscription_success','sub_suc')
) a
join (
    select *
    from
    (
        select
            fa.gid,fa.os_p os_type,fa.country,fa.is_new
            ,e.ab_code,e.enter_abtest_date,e.event_timestamp
            ,case when fa.is_new='New' then '0:新用户'
                  when meitu_datediff(e.enter_abtest_date, d.first_launch_date)<=30 then '1:老用户激活天数小于30天'
                  when meitu_datediff(e.enter_abtest_date, d.first_launch_date)<=90 then '2:老用户激活天数大于30天小于90天'
                  when meitu_datediff(e.enter_abtest_date, d.first_launch_date)<=365 then '3:老用户激活天数大于90天小于365天'
                  else '4:老用户激活天数大于365天'
                  end install_days_type
            ,case when coalesce(hist.hist_pay_cnt, 0) > 0 then '历史付费过'
                  when coalesce(hist.hist_trial_cnt, 0) > 0 then '历史试用过'
                  else '历史未订阅'
                  end hist_sub_type
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
                WHERE date_p BETWEEN 20260508 and 20260526
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
                WHERE date_p BETWEEN 20260508 and 20260526
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
            WHERE date_p between 20260508 and 20260526
                AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
                AND event_id = 'abcode_enter_test'
                AND params['current_abcode'] in ('28923','28924','28932')
        ) e ON e.gid = fa.gid and e.enter_abtest_date = fa.date_p
        left join (
            -- 安装/激活天数：进组日距首次启动日（取最早 first_launch_date）
            select
                server_id as gid
                ,min(first_launch_date) as first_launch_date
            from stat_sdk.sdk_oda_all_device_info
            where os_p in ('ios', 'android')
                and app_key_p in (
                    '7F7023B6CEC7CDED'
                    , 'C851ED7164B6DF0F'
                )
                and date_p = 20260526
                and server_id > 0
            group by server_id
        ) d
            on fa.gid = d.gid
        left join (
            -- 历史是否订阅过：进组日之前的订单（对齐说明/重点指标计算口径 hist_trial_cnt / hist_pay_cnt）
            select
                ent.gid
                ,ent.enter_abtest_date
                ,sum(case
                    when o.pay_date < ent.enter_abtest_date
                        and o.cur_pay_stage = 1
                        and o.cur_pay_withhold_stage = 0
                    then 1 else 0
                end) hist_trial_cnt
                ,sum(case
                    when o.pay_date < ent.enter_abtest_date
                        and o.cur_pay_withhold_stage >= 1
                    then 1 else 0
                end) hist_pay_cnt
            from (
                select distinct gid, date_p enter_abtest_date
                from stat_sdk.sdk_odz_source_data
                where date_p between 20260508 and 20260526
                    and app_key_p in ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
                    and event_id = 'abcode_enter_test'
                    and params['current_abcode'] in ('28923','28924','28932')
            ) ent
            left join (
                select
                    gid
                    ,pay_date
                    ,cur_pay_stage
                    ,cur_pay_withhold_stage
                from stat_vip.paid_oda_all_order_summary
                where app_id_p in (7329803307041000000)
                    and product_sub_line = 'AirBrush'
                    and is_subscribe = '订阅'
                    and pay_date < 20260526
            ) o
                on ent.gid = o.gid
            group by ent.gid, ent.enter_abtest_date
        ) hist
            on fa.gid = hist.gid
            and e.enter_abtest_date = hist.enter_abtest_date
        where e.gid is not null
    ) t
    where ranks=1
) b
on a.gid= b.gid
where b.event_timestamp-15 <= a.event_timestamp
group by a.os_type,case when b.ab_code in ('28923') then '对照组'
        when b.ab_code in ('28924') then '实验组A'
        when b.ab_code in ('28932') then '实验组B'
        end,b.is_new,case when b.country in ('美国','巴西','英国') then b.country else '其他' end
        ,b.install_days_type
        ,b.hist_sub_type
        ,a.duration
        -- ,a.date_p,

union all

select
    -- a.enter_abtest_date,
    case when a.os_type = 'ios' then 'iOS'
         when a.os_type = 'android' then 'Android'
            end os_type
    ,case when a.ab_code in ('28923') then '对照组'
        when a.ab_code in ('28924') then '实验组A'
        when a.ab_code in ('28932') then '实验组B'
        end code
    ,a.is_new is_new
    ,case when a.country in ('美国','巴西','英国') then a.country else '其他' end country
    ,a.install_days_type install_days_type
    ,a.hist_sub_type hist_sub_type
--     ,b.enter_abtest_date
    -- 付费
    ,'无' duration

    ,0 sub_enter_uv
    ,0 sub_click_uv
    ,0 sub_suc_uv
    ,0 sub_suc_to_paid_uv
    ,0.0 sub_suc_to_paid_gmv
    ,count(distinct a.gid) enter_abtest_uv
from (
    select *
    from
    (
        select
            fa.gid,fa.os_p os_type,fa.country,fa.is_new
            ,e.ab_code,e.enter_abtest_date,e.event_timestamp
            ,case when fa.is_new='New' then '0:新用户'
                  when meitu_datediff(e.enter_abtest_date, d.first_launch_date)<=30 then '1:老用户激活天数小于30天'
                  when meitu_datediff(e.enter_abtest_date, d.first_launch_date)<=90 then '2:老用户激活天数大于30天小于90天'
                  when meitu_datediff(e.enter_abtest_date, d.first_launch_date)<=365 then '3:老用户激活天数大于90天小于365天'
                  else '4:老用户激活天数大于365天'
                  end install_days_type
            ,case when coalesce(hist.hist_pay_cnt, 0) > 0 then '历史付费过'
                  when coalesce(hist.hist_trial_cnt, 0) > 0 then '历史试用过'
                  else '历史未订阅'
                  end hist_sub_type
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
                WHERE date_p BETWEEN 20260508 and 20260526
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
                WHERE date_p BETWEEN 20260508 and 20260526
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
            WHERE date_p between 20260508 and 20260526
                AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
                AND event_id = 'abcode_enter_test'
                AND params['current_abcode'] in ('28923','28924','28932')
        ) e ON e.gid = fa.gid and e.enter_abtest_date = fa.date_p
        left join (
            select
                server_id as gid
                ,min(first_launch_date) as first_launch_date
            from stat_sdk.sdk_oda_all_device_info
            where os_p in ('ios', 'android')
                and app_key_p in (
                    '7F7023B6CEC7CDED'
                    , 'C851ED7164B6DF0F'
                )
                and date_p = 20260526
                and server_id > 0
            group by server_id
        ) d
            on fa.gid = d.gid
        left join (
            select
                ent.gid
                ,ent.enter_abtest_date
                ,sum(case
                    when o.pay_date < ent.enter_abtest_date
                        and o.cur_pay_stage = 1
                        and o.cur_pay_withhold_stage = 0
                    then 1 else 0
                end) hist_trial_cnt
                ,sum(case
                    when o.pay_date < ent.enter_abtest_date
                        and o.cur_pay_withhold_stage >= 1
                    then 1 else 0
                end) hist_pay_cnt
            from (
                select distinct gid, date_p enter_abtest_date
                from stat_sdk.sdk_odz_source_data
                where date_p between 20260508 and 20260526
                    and app_key_p in ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
                    and event_id = 'abcode_enter_test'
                    and params['current_abcode'] in ('28923','28924','28932')
            ) ent
            left join (
                select
                    gid
                    ,pay_date
                    ,cur_pay_stage
                    ,cur_pay_withhold_stage
                from stat_vip.paid_oda_all_order_summary
                where app_id_p in (7329803307041000000)
                    and product_sub_line = 'AirBrush'
                    and is_subscribe = '订阅'
                    and pay_date < 20260526
            ) o
                on ent.gid = o.gid
            group by ent.gid, ent.enter_abtest_date
        ) hist
            on fa.gid = hist.gid
            and e.enter_abtest_date = hist.enter_abtest_date
        where e.gid is not null
    ) t
    where ranks=1
) a
group by case when a.os_type = 'ios' then 'iOS'
         when a.os_type = 'android' then 'Android'
            end
    ,case when a.ab_code in ('28923') then '对照组'
        when a.ab_code in ('28924') then '实验组A'
        when a.ab_code in ('28932') then '实验组B'
        end
    ,a.is_new
    ,case when a.country in ('美国','巴西','英国') then a.country else '其他' end
    ,a.install_days_type
    ,a.hist_sub_type
