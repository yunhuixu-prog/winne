set hive.exec.dynamic.partition.mode=nonstrict;
set hive.exec.max.dynamic.partitions =500;
set hive.exec.max.dynamic.partitions.pernode=500;

insert overwrite table stat_ab.filing_odz_cost_event_detail PARTITION(date_p)

select cost_type,algo_provider,model_name
     ,country_name
     ,case when os_type='android' then 'Android' else os_type end os_type
     ,gid,`time`,req_time,cost
     ,s.level,s.func_name,s.func_effect
     ,case when m.first_source is not null then m.first_source
           when m1.first_source is not null then m1.first_source
     else '未知' end first_source
     ,case when m.second_source is not null then m.second_source
           when m1.second_source is not null then m1.second_source
     else '未知' end second_source
     ,case when m.third_source is not null then m.third_source
           when m1.third_source='source_id' then s.func_effect
           when m1.third_source is not null then m1.third_source
     else '未知' end third_source
     ,s.task_id,s.order_id
     ,s.date_p
from
(
    select
        cost_type,algo_provider,model_name,
        country_name,os_type,
        get_json_object(mtcc_client , "$.position.level1" ) as level,
        func_name,
        case when func_effect='未知' or func_effect='' or func_effect is null then '无' else func_effect end func_effect,
        gnum as gid,`time`,req_time,
        cost,
        task_id,
        order_id,
        date_p
    from
        stat_aigc.cost_odz_aigc_cost_detail_d_oci_app
    where
        date_p between ${start_time} AND ${end_time}
        and app_name_cn='AirBrush'
) s
left join
(
    select case when level='' or level is null then '无' else level end level
         ,case when name='' or name is null then '无' else name end name
         ,case when effect='' or effect is null then '无' else effect end effect
         ,coalesce(max(first_source),'') first_source
         ,coalesce(max(second_source),'') second_source
         ,coalesce(max(third_source),'') third_source
    from stat_ab.filing_rna_cost_sub_mapping
    group by case when level='' or level is null then '无' else level end
         ,case when name='' or name is null then '无' else name end
         ,case when effect='' or effect is null then '无' else effect end
) m
on s.level=m.level and s.func_name=m.name and s.func_effect=m.effect
left join
(
    select case when level='' or level is null then '无' else level end level
         ,case when name='' or name is null then '无' else name end name
         ,coalesce(max(first_source),'') first_source
         ,coalesce(max(second_source),'') second_source
         ,coalesce(max(third_source),'') third_source
    from stat_ab.filing_rna_cost_sub_mapping
    where effect='source_id'
    group by case when level='' or level is null then '无' else level end
         ,case when name='' or name is null then '无' else name end
) m1
on s.level=m1.level and s.func_name=m1.name
