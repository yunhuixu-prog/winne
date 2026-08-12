SET hive.exec.dynamic.partition=true;
SET hive.exec.dynamic.partition.mode=nonstrict;
SET hive.exec.max.dynamic.partitions=1500;
SET hive.exec.max.dynamic.partitions.pernode=1000;

insert overwrite table stat_ab.filing_adz_external_cost_and_sub_overall PARTITION(date_p)

select country_name,os_type,function_name,function_effect
    ,task_uv,task_pv,cost
    ,pay_uv,ord_amt,ord_before_amt
    ,date_p
from (
select 
    coalesce(a.country_name,'整体') country_name,coalesce(a.os_type,'整体') os_type
    ,coalesce(a.second_source,'整体') function_name,coalesce(a.third_source,'整体') function_effect
    ,sum(a.task_uv) task_uv,sum(a.task_pv) task_pv,sum(a.cost) cost
    ,sum(a.pay_uv) pay_uv,sum(a.ord_amt) ord_amt,sum(a.ord_before_amt) ord_before_amt
    ,a.date_p
from (
select coalesce(a.country_name,b.country_name) country_name,coalesce(a.os_type,b.os_type) os_type
    ,coalesce(a.second_source,b.second_source) second_source,coalesce(a.third_source,b.third_source) third_source
    ,a.task_uv,a.task_pv,a.cost
    ,b.pay_uv,b.ord_amt,b.ord_before_amt
    ,coalesce(a.date_p,b.date_p) date_p
from (
    select 
        --  cost_type,algo_provider,model_name,
        coalesce(country_name,'未知') country_name,coalesce(os_type,'未知') os_type
        ,second_source,third_source
        ,count(distinct gid) task_uv
        ,count(distinct order_id) task_pv
        ,sum(cost) cost
        ,date_p
    from stat_ab.filing_odz_cost_event_detail
    where date_p between ${start_time} AND ${end_time}
        and cost_type = '外采'
    group by coalesce(country_name,'未知'),coalesce(os_type,'未知')
            ,second_source,third_source,date_p
) a
full outer join (
    select coalesce(country_name,'未知') country_name,coalesce(os_type,'未知') os_type
        --  ,gid,ord_amt_usd
        --  ,s.source_module,s.source_0,s.source_1
        -- ,case when m.first_source is not null then m.first_source
        --     when m1.first_source is not null then m1.first_source
        -- end first_source
        ,case when m.second_source is not null then m.second_source
            when m1.second_source is not null then m1.second_source
        end second_source
        ,case when m.third_source is not null then m.third_source
            when m1.third_source='source_id' then s.source_1
            when m1.third_source is not null then m1.third_source
        end third_source
        ,count(distinct case when type='no_refund' then gid else null end) pay_uv
        ,sum(ord_amt) ord_amt
        ,sum(ord_before_amt) ord_before_amt
        ,s.pay_date date_p
    from
    (
        select 
            type,
            pay_date,
            country_name,
            case when os_type='android' then 'Android' 
                 when os_type='ios' then 'iOS'
                 end os_type,
            gid,
            source_module,
            source_0,
            case when split_source_1='' or split_source_1 is null then '无' else split_source_1 end source_1,
            ord_amt / source_1_count as ord_amt,
            ord_before_amt / source_1_count as ord_before_amt
        from (
            select
                type,
                pay_date,
                gid,
                country_name,
                os_type,
                ord_amt,
                ord_before_amt,
                source_module,
                source_0,
                coalesce(source_1,'无') source_1,
                size(split(coalesce(source_1,'无'), ',')) as source_1_count
            from (
                select
                    'no_refund' type,
                    pay_date,
                    get_json_object(big_data,'$.source_module') as source_module,
                    get_json_object(big_data,'$.source_0') as source_0,

                    case when get_json_object(big_data,'$.source_0') in ('f_makeup','ai_filter','f_filter','f_filters','f_ai_retouch')
                            then get_json_object(big_data,'$.mids_material_id')
                        else get_json_object(big_data,'$.source_1')
                    end as source_1,
                    ord_amt,ord_before_amt,
                    gid,
                    device_type as os_type,country_name
                from stat_vip.paid_oda_all_order_summary
                WHERE is_subscribe='订阅'
                    and pay_date BETWEEN ${start_time} AND ${end_time}
                    and app_id_p IN (7329803307041000000)
                    and cur_pay_withhold_stage>=1

                union all 

                select
                    'refund' type,
                    refund_date pay_date,
                    get_json_object(big_data,'$.source_module') as source_module,
                    get_json_object(big_data,'$.source_0') as source_0,

                    case when get_json_object(big_data,'$.source_0') in ('f_makeup','ai_filter','f_filter','f_filters','f_ai_retouch')
                            then get_json_object(big_data,'$.mids_material_id')
                        else get_json_object(big_data,'$.source_1')
                    end as source_1,
                    -refund_amt ord_amt,-refund_before_amt ord_before_amt,
                    gid,
                    device_type as os_type,country_name
                from stat_vip.paid_oda_all_order_summary
                WHERE is_subscribe='订阅'
                    and refund_date BETWEEN ${start_time} AND ${end_time}
                    and app_id_p IN (7329803307041000000)
                    and pay_status=6
            ) t
        ) t
        lateral view explode(split(source_1, ',')) mat_tbl as split_source_1
    ) s
    left join
    (
        select case when source_module='' or source_module is null then '无' else source_module end source_module
            ,case when source_0='' or source_0 is null then '无' else source_0 end source_0
            ,case when source_1='' or source_1 is null then '无' else source_1 end source_1
            ,coalesce(max(first_source),'') first_source
            ,coalesce(max(second_source),'') second_source
            ,coalesce(max(third_source),'') third_source
        from stat_ab.filing_rna_cost_sub_mapping
        group by case when source_module='' or source_module is null then '无' else source_module end
            ,case when source_0='' or source_0 is null then '无' else source_0 end
            ,case when source_1='' or source_1 is null then '无' else source_1 end
    ) m
    on s.source_module=m.source_module and s.source_0=m.source_0 and s.source_1=m.source_1
    left join
    (
        select case when source_module='' or source_module is null then '无' else source_module end source_module
            ,case when source_0='' or source_0 is null then '无' else source_0 end source_0
            ,coalesce(max(first_source),'') first_source
            ,coalesce(max(second_source),'') second_source
            ,coalesce(max(third_source),'') third_source
        from stat_ab.filing_rna_cost_sub_mapping
        where source_1='source_id'
        group by case when source_module='' or source_module is null then '无' else source_module end
            ,case when source_0='' or source_0 is null then '无' else source_0 end
    ) m1
    on s.source_module=m1.source_module and s.source_0=m1.source_0
    group by coalesce(country_name,'未知'),coalesce(os_type,'未知')
        -- ,case when m.first_source is not null then m.first_source
        --     when m1.first_source is not null then m1.first_source
        -- else '未知' end
        ,case when m.second_source is not null then m.second_source
            when m1.second_source is not null then m1.second_source
        end
        ,case when m.third_source is not null then m.third_source
            when m1.third_source='source_id' then s.source_1
            when m1.third_source is not null then m1.third_source
        end,s.pay_date
) b 
on a.country_name=b.country_name and a.os_type=b.os_type and a.date_p=b.date_p
    and a.second_source=b.second_source and a.third_source=b.third_source
where case when b.second_source = 'AI Filter' or a.second_source is not null then 1=1 
           when b.second_source is not null and a.second_source is null then 1=0
      end
) a
group by a.country_name,a.os_type,a.date_p,a.second_source,a.third_source GROUPING SETS (
        (a.country_name,a.os_type,a.second_source,a.third_source,a.date_p),
        (a.country_name,a.os_type,a.second_source,a.date_p),
        (a.country_name,a.os_type,a.third_source,a.date_p),
        (a.country_name,a.os_type,a.date_p),

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