SET hive.exec.dynamic.partition=true;
SET hive.exec.dynamic.partition.mode=nonstrict;
SET hive.exec.max.dynamic.partitions=1500;
SET hive.exec.max.dynamic.partitions.pernode=1000;

insert overwrite table stat_ab.filing_adz_cost_event_distributed_daily PARTITION(date_p)

select country_name,os_type,function_name,function_effect
    ,is_subscribed,task_pv_dis
    ,task_uv,task_pv,cost
    ,date_p
from (
select 
    coalesce(a.country_name,'整体') country_name,coalesce(a.os_type,'整体') os_type
    ,a.second_source function_name,a.third_source function_effect
    ,coalesce(a.is_subscribed,'整体') is_subscribed
    ,a.task_pv_dis
    ,sum(a.task_uv) task_uv,sum(a.task_pv) task_pv,sum(a.cost) cost
    ,a.date_p
from (
    select 
        coalesce(a.country_name,'未知') country_name,coalesce(a.os_type,'未知') os_type
        ,a.second_source,a.third_source
        ,a.task_pv task_pv_dis
        ,b.is_subscribed
        ,count(distinct a.gid) task_uv
        ,sum(a.task_pv) task_pv
        ,sum(a.cost) cost
        ,a.date_p
    from (
        select country_name,os_type
                ,second_source,third_source
                ,gid,date_p
                ,count(distinct order_id) task_pv
                ,sum(cost) cost
        from stat_ab.filing_odz_cost_event_detail
        where date_p between ${start_time} AND ${end_time}
        group by country_name,os_type,second_source,third_source,gid,date_p
    ) a
    left join (
        SELECT
            a.gid
            ,a.date_p
            -- 当前是否订阅：活跃时间落在订单的开始和结束之间，非当天新订阅
            ,MAX(CASE WHEN a.date_p > o.pay_date  and a.date_p <= cast(o.invalid_date as bigint) THEN '订阅' ELSE '非订阅' END) AS is_subscribed
        FROM (
                select gid,date_p
                from stat_ab.filing_odz_cost_event_detail
                where date_p between ${start_time} AND ${end_time}
                group by gid,date_p
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
                and pay_date <= ${end_time}
                and is_subscribe='订阅'
                and product_sub_line = 'AirBrush'
        ) o
        ON a.gid = o.gid
        GROUP BY
            a.gid,
            a.date_p
    ) b
    ON a.gid = b.gid and a.date_p = b.date_p
    group by coalesce(a.country_name,'未知'),coalesce(a.os_type,'未知')
            ,a.second_source,a.third_source,a.task_pv,a.date_p,b.is_subscribed
) a
group by a.country_name,a.os_type,a.date_p,a.second_source,a.third_source,a.task_pv_dis,a.is_subscribed GROUPING SETS (
        (a.is_subscribed,a.country_name,a.os_type,a.second_source,a.third_source,a.task_pv_dis,a.date_p),

        (a.is_subscribed,a.country_name,a.second_source,a.third_source,a.task_pv_dis,a.date_p),

        (a.is_subscribed,a.os_type,a.second_source,a.third_source,a.task_pv_dis,a.date_p),

        (a.country_name,a.os_type,a.second_source,a.third_source,a.task_pv_dis,a.date_p),

        (a.is_subscribed,a.second_source,a.third_source,a.task_pv_dis,a.date_p),

        (a.country_name,a.second_source,a.third_source,a.task_pv_dis,a.date_p),

        (a.os_type,a.second_source,a.third_source,a.task_pv_dis,a.date_p),

        (a.second_source,a.third_source,a.task_pv_dis,a.date_p)
      )
) a


union all 


select country_name,os_type,function_name,function_effect
    ,is_subscribed,task_pv_dis
    ,task_uv,task_pv,cost
    ,date_p
from (
select 
    coalesce(a.country_name,'整体') country_name,coalesce(a.os_type,'整体') os_type
    ,a.second_source function_name,'整体' function_effect
    ,coalesce(a.is_subscribed,'整体') is_subscribed
    ,a.task_pv_dis
    ,sum(a.task_uv) task_uv,sum(a.task_pv) task_pv,sum(a.cost) cost
    ,a.date_p
from (
    select 
        coalesce(a.country_name,'未知') country_name,coalesce(a.os_type,'未知') os_type
        ,a.second_source
        ,a.task_pv task_pv_dis
        ,b.is_subscribed
        ,count(distinct a.gid) task_uv
        ,sum(a.task_pv) task_pv
        ,sum(a.cost) cost
        ,a.date_p
    from (
        select country_name,os_type
                ,second_source
                ,gid,date_p
                ,count(distinct order_id) task_pv
                ,sum(cost) cost
        from stat_ab.filing_odz_cost_event_detail
        where date_p between ${start_time} AND ${end_time}
        group by country_name,os_type,second_source,gid,date_p
    ) a
    left join (
        SELECT
            a.gid
            ,a.date_p
            -- 当前是否订阅：活跃时间落在订单的开始和结束之间，非当天新订阅
            ,MAX(CASE WHEN a.date_p > o.pay_date  and a.date_p <= cast(o.invalid_date as bigint) THEN '订阅' ELSE '非订阅' END) AS is_subscribed
        FROM (
                select gid,date_p
                from stat_ab.filing_odz_cost_event_detail
                where date_p between ${start_time} AND ${end_time}
                group by gid,date_p
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
                and pay_date <= ${end_time}
                and is_subscribe='订阅'
                and product_sub_line = 'AirBrush'
        ) o
        ON a.gid = o.gid
        GROUP BY
            a.gid,
            a.date_p
    ) b
    ON a.gid = b.gid and a.date_p = b.date_p
    group by coalesce(a.country_name,'未知'),coalesce(a.os_type,'未知')
            ,a.second_source,a.task_pv,a.date_p,b.is_subscribed
) a
group by a.country_name,a.os_type,a.date_p,a.second_source,a.task_pv_dis,a.is_subscribed GROUPING SETS (
        (a.is_subscribed,a.country_name,a.os_type,a.second_source,a.task_pv_dis,a.date_p),

        (a.is_subscribed,a.country_name,a.second_source,a.task_pv_dis,a.date_p),

        (a.is_subscribed,a.os_type,a.second_source,a.task_pv_dis,a.date_p),

        (a.country_name,a.os_type,a.second_source,a.task_pv_dis,a.date_p),

        (a.is_subscribed,a.second_source,a.task_pv_dis,a.date_p),

        (a.country_name,a.second_source,a.task_pv_dis,a.date_p),

        (a.os_type,a.second_source,a.task_pv_dis,a.date_p),

        (a.second_source,a.task_pv_dis,a.date_p)
      )
) a