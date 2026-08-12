select
    date_p
    ,substr(date_p,1,6) month
    ,case when func_name in ('ai_filter','ai_image') then 'ai_filter'
         when func_name in ('filters') then 'filters'
    else '其他'
    end func_name
    ,func_effect
	-- case when country_name='俄罗斯' then 1 
    --      when country_name is null or country_name='未知' then -1
    -- else 0 end is_russia
    ,count(1) pv,count(gnum) uv,sum(cost) cost
from
  stat_aigc.cost_odz_aigc_cost_detail_d
where
  date_p between 20260101 and 20260331
  and app_name_cn='AirBrush'
  and cost_type='外采'
  -- and func_name in ('ai_filter','ai_image','filters')
group by date_p,substr(date_p,1,6),func_name,func_effect

;

select   pay_date,substr(pay_date,1,6) month
        ,case when source_0='ai_filter' then 'ai_filter'
            when source_0 in ('f_filter','f_filters') then 'filters'
        end func
        ,case when source_0 in ('f_filter','f_filters') then material_id else '未知' end func_effect
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
                and pay_date BETWEEN 20260101 and 20260331
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
group by pay_date,substr(pay_date,1,6),case when source_0='ai_filter' then 'ai_filter'
            when source_0 in ('f_filter','f_filters') then 'filters'
        end,case when source_0 in ('f_filter','f_filters') then material_id else '未知' end