select
    a.date_p date_p,
    a.os_type os_type
    ,case when b.ab_code in ('29080') then '对照组'
        when b.ab_code in ('29081') then '实验组A'
        when b.ab_code in ('29082') then '实验组B'
      end code
    ,b.is_new is_new
    ,case when b.country in ('巴西','英国','澳大利亚') then b.country else '其他' end country
--     ,b.enter_abtest_date
    -- 付费
    ,case when a.sku ='com.meitu.airbrush.autorenew.vip17' then '分期年卡' else a.duration end duration

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
        date_p between 20260717 and 20260803
        and event_id in ('w_subscription_enter','w_subscription_click','w_subscription_success','sub_suc')
) a
join (
    SELECT gid, os_type, is_new, ab_code, event_timestamp, date_p, country
    FROM (
        SELECT gid, os_type, is_new, ab_code, event_timestamp, date_p, country
            ,ROW_NUMBER() OVER (PARTITION BY gid ORDER BY event_timestamp) AS ranks
        FROM stat_ab.filing_odz_abtest_active_user
        WHERE date_p BETWEEN 20260717 AND 20260803
            AND ab_code IN ('29080','29081','29082')
    ) t
    WHERE ranks = 1
) b
on a.gid= b.gid
where b.event_timestamp-15 <= a.event_timestamp
group by a.os_type,case when b.ab_code in ('29080') then '对照组'
        when b.ab_code in ('29081') then '实验组A'
        when b.ab_code in ('29082') then '实验组B'
      end,b.is_new,case when b.country in ('巴西','英国','澳大利亚') then b.country else '其他' end
        ,case when a.sku ='com.meitu.airbrush.autorenew.vip17' then '分期年卡' else a.duration end
        ,a.date_p

union all

select
    a.enter_abtest_date date_p,
    case when a.os_type = 'ios' then 'iOS'
         when a.os_type = 'android' then 'Android'
            end os_type
    ,case when a.ab_code in ('29080') then '对照组'
        when a.ab_code in ('29081') then '实验组A'
        when a.ab_code in ('29082') then '实验组B'
        end code
    ,a.is_new is_new
    ,case when a.country in ('巴西','英国','澳大利亚') then a.country else '其他' end country
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
    SELECT gid, os_type, is_new, ab_code, event_timestamp, date_p enter_abtest_date, country
    FROM (
        SELECT gid, os_type, is_new, ab_code, event_timestamp, date_p, country
            ,ROW_NUMBER() OVER (PARTITION BY gid ORDER BY event_timestamp) AS ranks
        FROM stat_ab.filing_odz_abtest_active_user
        WHERE date_p BETWEEN 20260717 AND 20260803
            AND ab_code IN ('29080','29081','29082')
    ) t
    WHERE ranks = 1
) a
group by 
    a.enter_abtest_date
    ,case when a.os_type = 'ios' then 'iOS'
         when a.os_type = 'android' then 'Android'
            end
    ,case when a.ab_code in ('29080') then '对照组'
        when a.ab_code in ('29081') then '实验组A'
        when a.ab_code in ('29082') then '实验组B'
        end
    ,a.is_new
    ,case when a.country in ('巴西','英国','澳大利亚') then a.country else '其他' end
