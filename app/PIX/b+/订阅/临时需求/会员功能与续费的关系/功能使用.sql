drop table if exists `beautyplus-bc0ed.temp.winne_function_use_for_vip`;
create table `beautyplus-bc0ed.temp.winne_function_use_for_vip` as

with
func_raw as
(
    --关联付费功能
    SELECT
        event_date
        ,user_pseudo_id
        ,module
        ,class
        ,ifnull(c.en_cn_name,function) as function_en
        ,sum(pv) pv
    FROM
        `beautyplus-bc0ed.event_dataset_4.dwd_dz_event_group_04` a
        join    (select
                    behavior_table_name,en_cn_name,is_pay
                from
                `dataintegration-265403.dim.dim_gs_common_dmi_da_func_name_dictionary`
                --where module='修图'
                group by 1,2,3) c on a.function=c.behavior_table_name and is_pay in ('付费','混合')
    WHERE
        event_date between '2024-11-01' and '2024-11-30'
        and action='保存'
        and mark=2
        and class<>'美妆'
    group by
        1,2,3,4,5
    union all
    SELECT
        event_date
        ,user_pseudo_id
        ,module
        ,class
        ,class function_en
        ,sum(pv) pv
    FROM
        `beautyplus-bc0ed.event_dataset_4.dwd_dz_event_group_04` a
    WHERE
        event_date between '2024-11-01' and '2024-11-30'
        and action='保存'
        and mark=1 --以下功能归类在一级功能
        and class in('滤镜','美妆','AR','Look')
        group by 1,2,3,4,5
)

select
    distinct f.event_date,f.user_pseudo_id,i.uuid,f.module,f.class,f.function_en,f.pv
from
    func_raw f
-- 匹配id
left join
(select uuid,key from `dataintegration-265403.stat.dmi_dz_idmapping` group by 1,2) i on f.user_pseudo_id=i.key
