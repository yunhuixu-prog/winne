select
    -- a.date_p,
    a.os_type os_type
    ,case when b.ab_code in ('28881','28882','28883','28875','28876','28877') then '月SKU'
        when b.ab_code in ('28878','28879','28880','28872','28873','28874') then '年SKU'
        end abtest_type
    ,case when b.ab_code in ('28878','28881','28872','28875') then '对照组'
        when b.ab_code in ('28879','28882','28873','28876') then '实验组A'
        when b.ab_code in ('28880','28883','28874','28877') then '实验组B'
        end code
    ,b.is_new is_new
    ,case when b.country in ('美国','巴西','英国') then b.country else '其他' end country
-- --     ,b.enter_abtest_date
--     -- 付费
    ,a.duration duration
    ,case when a.sku in (
                        -- ios
                        'airbrush.subs.month12.func00.lev00.campaign.instant2023.ver2' -- 年老用户
                        ,'airbrush.subs.month12.func00.lev00.campaign.recall30.ver0' -- 年新用户
                        ,'com.meitu.airbrush.autorenew.vip7'
                        ,'com.meitu.airbrush.autorenew.vip8'

                        ,'airbrush.subs.month1.func00.lev00.campaign.instant2023.ver0' -- 月老用户
                        ,'airbrush.subs.month1.func00.lev00.campaign.recall30.ver0' -- 月新用户
                        ,'com.meitu.airbrush.autorenew.vip13'
                        ,'com.meitu.airbrush.autorenew.vip14'
                        -- android
                        ,'com.meitu.airbrush.12mo_discount30' -- 年老用户
                        ,'airbrush.subs_12mo_30off_2024.func00' -- 年新用户
                        ,'com.meitu.airbrush.subscription.vip16'
                        ,'com.meitu.airbrush.subscription.vip17'

                        ,'airbrush.subs.func00.lev00.1mo.instant' -- 月老用户
                        ,'airbrush.subs_1mo_30off_2024.func00' -- 月新用户
                        ,'com.meitu.airbrush.subscription.vip18'
                        ,'com.meitu.airbrush.subscription.vip19'
                        ) then '挽留SKU' else '其他' end sku_type
    ,a.sku sku

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
        date_p between 20260425 and 20260511
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
                WHERE date_p BETWEEN 20260425 and 20260511
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
                WHERE date_p BETWEEN 20260425 and 20260511
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
            WHERE date_p between 20260425 and 20260511
                AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
                AND event_id = 'abcode_enter_test'
                AND params['current_abcode'] in ('28878','28879','28880'
                                                ,'28881','28882','28883'
                                                ,'28872','28873','28874'
                                                ,'28875','28876','28877')
        ) e ON e.gid = fa.gid and e.enter_abtest_date = fa.date_p
        where e.gid is not null
    ) t
    where ranks=1
) b
on a.gid= b.gid
where b.event_timestamp-15 <= a.event_timestamp
group by a.os_type
        ,case when b.ab_code in ('28881','28882','28883','28875','28876','28877') then '月SKU'
        when b.ab_code in ('28878','28879','28880','28872','28873','28874') then '年SKU'
        end
        ,case when b.ab_code in ('28878','28881','28872','28875') then '对照组'
        when b.ab_code in ('28879','28882','28873','28876') then '实验组A'
        when b.ab_code in ('28880','28883','28874','28877') then '实验组B'
        end
        ,b.is_new,case when b.country in ('美国','巴西','英国') then b.country else '其他' end
        ,a.duration
        ,case when a.sku in (
                        -- ios
                        'airbrush.subs.month12.func00.lev00.campaign.instant2023.ver2' -- 年老用户
                        ,'airbrush.subs.month12.func00.lev00.campaign.recall30.ver0' -- 年新用户
                        ,'com.meitu.airbrush.autorenew.vip7'
                        ,'com.meitu.airbrush.autorenew.vip8'

                        ,'airbrush.subs.month1.func00.lev00.campaign.instant2023.ver0' -- 月老用户
                        ,'airbrush.subs.month1.func00.lev00.campaign.recall30.ver0' -- 月新用户
                        ,'com.meitu.airbrush.autorenew.vip13'
                        ,'com.meitu.airbrush.autorenew.vip14'
                        -- android
                        ,'com.meitu.airbrush.12mo_discount30' -- 年老用户
                        ,'airbrush.subs_12mo_30off_2024.func00' -- 年新用户
                        ,'com.meitu.airbrush.subscription.vip16'
                        ,'com.meitu.airbrush.subscription.vip17'

                        ,'airbrush.subs.func00.lev00.1mo.instant' -- 月老用户
                        ,'airbrush.subs_1mo_30off_2024.func00' -- 月新用户
                        ,'com.meitu.airbrush.subscription.vip18'
                        ,'com.meitu.airbrush.subscription.vip19'
                        ) then '挽留SKU' else '其他' end
        ,a.sku
        -- ,a.date_p,

union all

select
    -- a.enter_abtest_date,
    case when a.os_type = 'ios' then 'iOS'
         when a.os_type = 'android' then 'Android'
            end os_type
    ,case when a.ab_code in ('28881','28882','28883','28875','28876','28877') then '月SKU'
        when a.ab_code in ('28878','28879','28880','28872','28873','28874') then '年SKU'
        end abtest_type
    ,case when a.ab_code in ('28878','28881','28872','28875') then '对照组'
        when a.ab_code in ('28879','28882','28873','28876') then '实验组A'
        when a.ab_code in ('28880','28883','28874','28877') then '实验组B'
        end code
    ,a.is_new is_new
    ,case when a.country in ('美国','巴西','英国') then a.country else '其他' end country
--     ,b.enter_abtest_date
    -- 付费
    ,'无' duration
    ,'无' sku_type
    ,'无' sku
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
                WHERE date_p BETWEEN 20260425 and 20260511
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
                WHERE date_p BETWEEN 20260425 and 20260511
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
            WHERE date_p between 20260425 and 20260511
                AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
                AND event_id = 'abcode_enter_test'
                AND params['current_abcode'] in ('28878','28879','28880'
                                                ,'28881','28882','28883'
                                                ,'28872','28873','28874'
                                                ,'28875','28876','28877')
        ) e ON e.gid = fa.gid and e.enter_abtest_date = fa.date_p
        where e.gid is not null
    ) t
    where ranks=1
) a
group by case when a.os_type = 'ios' then 'iOS'
         when a.os_type = 'android' then 'Android'
            end
    ,case when a.ab_code in ('28881','28882','28883','28875','28876','28877') then '月SKU'
        when a.ab_code in ('28878','28879','28880','28872','28873','28874') then '年SKU'
        end
    ,case when a.ab_code in ('28878','28881','28872','28875') then '对照组'
        when a.ab_code in ('28879','28882','28873','28876') then '实验组A'
        when a.ab_code in ('28880','28883','28874','28877') then '实验组B'
        end
    ,a.is_new
    ,case when a.country in ('美国','巴西','英国') then a.country else '其他' end