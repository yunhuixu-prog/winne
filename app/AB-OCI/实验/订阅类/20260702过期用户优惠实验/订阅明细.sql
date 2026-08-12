select
    -- a.date_p,
    a.os_type os_type
    ,case when b.ab_code in ('29032','29034') then '对照组'
        when b.ab_code in ('29033','29035') then '实验组A'
        -- when b.ab_code in ('28907') then '实验组B'
        end code
    ,b.is_new is_new
    ,case when b.country in ('美国','巴西','英国') then b.country else '其他' end country
    ,b.is_hist_sub is_hist_sub
--     ,b.enter_abtest_date
    -- 付费
    ,a.duration duration
    ,a.sku
    ,case when a.sale_status like '%resubscribe_discount%' then a.sale_status else 'else' end sale_status

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
        ,gid,is_new,is_ua,country,sale_status
        ,duration,source_module,source_0,source_1
        ,mids_material_id,mids_category_id,sku
        ,is_paid,paid_date,paid_ord_amt
    from stat_ab.filing_onz_sub_source_event_detail
    where
        date_p between 20260702 and 20260709
        and event_id in ('w_subscription_enter','w_subscription_click','w_subscription_success','sub_suc')
) a
JOIN (
        SELECT
            e.gid, e.os_type, e.is_new, e.ab_code, e.event_timestamp, e.country
            ,CASE
                WHEN COALESCE(p.hist_trial_cnt, 0) > 0
                    OR COALESCE(p.hist_pay_cnt, 0) > 0
                THEN 1 ELSE 0
            END AS is_hist_sub
            ,COALESCE(p.is_subscribed, 0) AS is_cur_valid_sub
            ,case when o.gid is not null then 1 else 0 end as is_pop
        FROM (
            SELECT gid, os_type, is_new, ab_code, event_timestamp, date_p, country
            FROM (
                SELECT gid, os_type, is_new, ab_code, event_timestamp, date_p, country
                    ,ROW_NUMBER() OVER (PARTITION BY gid ORDER BY event_timestamp) AS ranks
                FROM stat_ab.filing_odz_abtest_active_user
                WHERE date_p BETWEEN 20260702 AND 20260709
                    AND ab_code IN ('29032','29033','29034','29035')
            ) t
            WHERE ranks = 1
        ) e
        LEFT JOIN (
            SELECT gid, date_p, is_subscribed, hist_trial_cnt, hist_pay_cnt
            FROM stat_ab.filing_odz_active_user_profile
            WHERE date_p BETWEEN 20260702 AND 20260709
        ) p
            ON e.gid = p.gid AND e.date_p = p.date_p
        left join (
            SELECT distinct gid
            FROM stat_sdk.sdk_odz_source_data
            WHERE date_p between 20260702 and 20260709
                AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
                AND event_id = 'strategy_popup_show' 
                and params['strategy_name']='discount_for_resubscribe_homepage'
        ) o ON o.gid = e.gid
) b ON a.gid = b.gid
where b.event_timestamp-15 <= a.event_timestamp
    -- and b.enter_abtest_date = a.date_p
group by a.os_type,case when b.ab_code in ('29032','29034') then '对照组'
        when b.ab_code in ('29033','29035') then '实验组A'
        end
        ,b.is_new
        ,case when b.country in ('美国','巴西','英国') then b.country else '其他' end
        ,a.duration
        ,a.sku
        ,case when a.sale_status like '%resubscribe_discount%' then a.sale_status else 'else' end
        ,b.is_hist_sub
        -- ,a.date_p

union all

select
    -- a.enter_abtest_date date_p,
    case when a.os_type = 'ios' then 'iOS'
         when a.os_type = 'android' then 'Android'
            end os_type
    ,case when a.ab_code in ('29032','29034') then '对照组'
        when a.ab_code in ('29033','29035') then '实验组A'
        end code
    ,a.is_new is_new
    ,case when a.country in ('美国','巴西','英国') then a.country else '其他' end country
    ,a.is_hist_sub is_hist_sub
--     ,b.enter_abtest_date
    -- 付费
    ,'无' duration
    ,'无' sku
    ,'无' sale_status
    -- ,'无' source_0

    ,0 sub_enter_uv
    ,0 sub_click_uv
    ,0 sub_suc_uv
    ,0 sub_suc_to_paid_uv
    ,0.0 sub_suc_to_paid_gmv
    ,count(distinct a.gid) enter_abtest_uv
from (
    SELECT
            e.gid, e.os_type, e.is_new, e.ab_code, e.country
            ,CASE
                WHEN COALESCE(p.hist_trial_cnt, 0) > 0
                    OR COALESCE(p.hist_pay_cnt, 0) > 0
                THEN 1 ELSE 0
            END AS is_hist_sub
            ,COALESCE(p.is_subscribed, 0) AS is_cur_valid_sub
            ,case when o.gid is not null then 1 else 0 end as is_pop
        FROM (
            SELECT gid, os_type, is_new, ab_code, date_p, country
            FROM (
                SELECT gid, os_type, is_new, ab_code, date_p, country
                    ,ROW_NUMBER() OVER (PARTITION BY gid ORDER BY event_timestamp) AS ranks
                FROM stat_ab.filing_odz_abtest_active_user
                WHERE date_p BETWEEN 20260702 AND 20260709
                    AND ab_code IN ('29032','29033','29034','29035')
            ) t
            WHERE ranks = 1
        ) e
        LEFT JOIN (
            SELECT gid, date_p, is_subscribed, hist_trial_cnt, hist_pay_cnt
            FROM stat_ab.filing_odz_active_user_profile
            WHERE date_p BETWEEN 20260702 AND 20260709
        ) p
            ON e.gid = p.gid AND e.date_p = p.date_p
        left join (
            SELECT distinct gid
            FROM stat_sdk.sdk_odz_source_data
            WHERE date_p between 20260702 and 20260709
                AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
                AND event_id = 'strategy_popup_show' 
                and params['strategy_name']='discount_for_resubscribe_homepage'
        ) o ON o.gid = e.gid
) a
group by case when a.os_type = 'ios' then 'iOS'
         when a.os_type = 'android' then 'Android'
            end
    ,case when a.ab_code in ('29032','29034') then '对照组'
        when a.ab_code in ('29033','29035') then '实验组A'
        end
    ,a.is_new
    -- ,a.enter_abtest_date
    ,case when a.country in ('美国','巴西','英国') then a.country else '其他' end
    ,a.is_hist_sub
