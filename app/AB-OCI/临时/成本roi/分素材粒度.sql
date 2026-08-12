with cost_detail as (
    select
        date_p,
        gnum as gid,
        case when func_name in ('ai_filter','ai_image') then 'ai_filter'
             when func_name in ('filters') then 'filters'
             else '其他'
        end as func_name,
        func_effect,
        cost
    from stat_aigc.cost_odz_aigc_cost_detail_d_oci_app
    where
        date_p between 20260323 and 20260329
        and app_name_cn='AirBrush'
        and cost_type='外采'
        -- and func_name in ('ai_filter','ai_image','filters')
),
pay_event as (
    select
        gid,pay_date,invalid_date
    from stat_vip.paid_oda_all_order_summary
    where app_id_p IN (7329803307041000000)
        and pay_date <= 20260329
        and is_subscribe='订阅'
)

select
    c.date_p,
    c.func_name,
    c.func_effect,
    if(s.gid is not null,1,0) as is_sub,
    count(1) as pv,
    count(distinct c.gid) as uv,
    sum(c.cost) as cost
from (select * from cost_detail) c
left join (
    select distinct a.date_p,a.gid
    from (
        select distinct date_p,gid from cost_detail
    ) a
    join (select * from pay_event) b
    on a.gid=b.gid
    where b.pay_date<a.date_p and b.invalid_date>=a.date_p
) s
on c.gid = s.gid and c.date_p=s.date_p
group by c.date_p, c.func_name, c.func_effect,if(s.gid is not null,1,0)

;


select   pay_date
        ,case when source_0='ai_filter' then 'ai_filter'
            when source_0 in ('f_filter','f_filters') then 'filters'
        end func
        ,material_id func_effect
        ,sum(ord_amt_usd) ord_amt_usd
from (
    select 
        pay_date,
        source_module,
        source_0,
        split_material_id material_id,
        ord_amt_usd / material_count as ord_amt_usd
    from (
        select
            pay_date,
            ord_amt_usd,
            source_module,
            source_0,
            material_id,
            size(split(material_id, ',')) as material_count
        from (
            select
                pay_date,
                get_json_object(big_data,'$.source_module') as source_module,
                get_json_object(big_data,'$.source_0') as source_0,
                get_json_object(big_data,'$.mids_material_id') as material_id,
                ord_amt_usd
            from stat_vip.paid_oda_vip_all_order
            WHERE date_p=20260331
                and pay_date BETWEEN 20260323 and 20260329
                and app_id_p IN (7329803307041000000)
                and commodity_id_P not in (-1)
                and order_type=2   -- (1:非续期订阅 2:续期订阅 3:消耗品 4:非消耗品)
                and contract_id<>0
                and get_json_object(big_data,'$.source_module') in ('AIGC','p_edit')
                and get_json_object(big_data,'$.source_0') in ('ai_filter','f_filter','f_filters')
        ) base
    ) tmp 
    lateral view explode(split(material_id, ',')) mat_tbl as split_material_id
) t
WHERE case when source_0 in ('f_filter','f_filters') then material_id in ('AB_FIL_00000501','AB_FIL_00000506')
    else 1=1 end
group by pay_date,case when source_0='ai_filter' then 'ai_filter'
            when source_0 in ('f_filter','f_filters') then 'filters'
        end,material_id