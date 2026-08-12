select
    -- 
    a.os_type os_type
    ,case when b.ab_code in ('29080') then '对照组'
        when b.ab_code in ('29081') then '实验组A'
        when b.ab_code in ('29082') then '实验组B'
      end code
    ,a.date_p date_p
    ,case when a.sku ='com.meitu.airbrush.autorenew.vip17' then '分期年卡' else a.duration end types
    ,case when b.country in ('巴西','英国','澳大利亚') then b.country else '其他' end country
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
        date_p between 20260717 and 20260803
        and event_id in ('sub_suc')
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
      end
        ,case when b.country in ('巴西','英国','澳大利亚') then b.country else '其他' end
        ,case when a.sku ='com.meitu.airbrush.autorenew.vip17' then '分期年卡' else a.duration end
        ,a.date_p