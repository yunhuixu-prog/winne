SET hive.exec.dynamic.partition=true;
SET hive.exec.dynamic.partition.mode=nonstrict;
SET hive.exec.max.dynamic.partitions=1500;
SET hive.exec.max.dynamic.partitions.pernode=1000;

insert overwrite table stat_ab.filing_adz_cost_event_overall PARTITION(date_p)

select cost_type,country_name,os_type,function_name,function_effect
    ,task_uv,task_pv,cost
    ,date_p
from (
select 
    coalesce(a.cost_type,'整体') cost_type
    ,coalesce(a.country_name,'整体') country_name,coalesce(a.os_type,'整体') os_type
    ,coalesce(a.second_source,'整体') function_name,coalesce(a.third_source,'整体') function_effect
    ,sum(a.task_uv) task_uv,sum(a.task_pv) task_pv,sum(a.cost) cost
    ,a.date_p
from (
    select 
        coalesce(cost_type,'未知') cost_type,
        coalesce(country_name,'未知') country_name,coalesce(os_type,'未知') os_type
        ,second_source,third_source
        ,count(distinct gid) task_uv
        ,count(distinct order_id) task_pv
        ,sum(cost) cost
        ,date_p
    from stat_ab.filing_odz_cost_event_detail
    where date_p between ${start_time} AND ${end_time}
    group by coalesce(cost_type,'未知'),
            coalesce(country_name,'未知'),coalesce(os_type,'未知')
            ,second_source,third_source,date_p
) a
group by a.cost_type,a.country_name,a.os_type,a.date_p,a.second_source,a.third_source GROUPING SETS (
        (a.cost_type,a.country_name,a.os_type,a.second_source,a.third_source,a.date_p),
        (a.cost_type,a.country_name,a.os_type,a.second_source,a.date_p),
        (a.cost_type,a.country_name,a.os_type,a.third_source,a.date_p),
        (a.cost_type,a.country_name,a.os_type,a.date_p),

        (a.cost_type,a.country_name,a.second_source,a.third_source,a.date_p),
        (a.cost_type,a.country_name,a.second_source,a.date_p),
        (a.cost_type,a.country_name,a.third_source,a.date_p),
        (a.cost_type,a.country_name,a.date_p),

        (a.cost_type,a.os_type,a.second_source,a.third_source,a.date_p),
        (a.cost_type,a.os_type,a.second_source,a.date_p),
        (a.cost_type,a.os_type,a.third_source,a.date_p),
        (a.cost_type,a.os_type,a.date_p),

        (a.country_name,a.os_type,a.second_source,a.third_source,a.date_p),
        (a.country_name,a.os_type,a.second_source,a.date_p),
        (a.country_name,a.os_type,a.third_source,a.date_p),
        (a.country_name,a.os_type,a.date_p),

        (a.cost_type,a.second_source,a.third_source,a.date_p),
        (a.cost_type,a.second_source,a.date_p),
        (a.cost_type,a.third_source,a.date_p),
        (a.cost_type,a.date_p),

        (a.country_name,a.second_source,a.third_source,a.date_p),
        (a.country_name,a.second_source,a.date_p),
        (a.country_name,a.third_source,a.date_p),
        (a.country_name,a.date_p),

        (a.os_type,a.second_source,a.third_source,a.date_p),
        (a.os_type,a.second_source,a.date_p),
        (a.os_type,a.third_source,a.date_p),
        (a.os_type,a.date_p),

        (a.second_source,a.third_source,a.date_p),
        (a.second_source,a.date_p),
        (a.third_source,a.date_p),
        (a.date_p)
      )
) a