-- id2 含逗号时拆成多行，ord_amt_usd 按权益个数均分（Hive：LATERAL VIEW；Presto 可改 CROSS JOIN UNNEST(split(id2, ',')) AS u(id2_part)）
  select
      pay_date
      ,case when get_json_object(big_data,'$.source_module') in ('p_video')
              then 'video'
            else get_json_object(big_data,'$.source_0') end id1
      ,case when get_json_object(big_data,'$.source_module') in ('p_video')
              then get_json_object(big_data,'$.source_0')
            when get_json_object(big_data,'$.source_0') in ('f_ai_tattoo') and get_json_object(big_data,'$.mids_category_id') = 'tattoo_custom_tag'
              then get_json_object(big_data,'$.mids_category_id')
            when get_json_object(big_data,'$.source_0') in ('f_hair_dye','f_ai_retouch','f_hairstyles','f_hair_enrich','f_makeup','f_ai_tattoo')
              then get_json_object(big_data,'$.mids_material_id')
        else get_json_object(big_data,'$.source_1') end id2
      ,sum(ord_amt_usd) ord_amt_usd
  from stat_vip.paid_oda_all_order_summary
  where app_id_p IN (7329803307041000000)
      and pay_date between 20260701 and 20260708
      and is_subscribe='订阅'
      and product_sub_line = 'AirBrush'
      -- and get_json_object(big_data,'$.source_0') in ('f_ai_retouch','f_relight','f_adjust','f_hair_dye','f_body','f_eraser','f_hairstyles','f_face','f_hair_enrich','f_ai_tattoo','f_eraser','f_makeup','f_teeth')
  group by pay_date
      ,case when get_json_object(big_data,'$.source_module') in ('p_video')
              then 'video'
            else get_json_object(big_data,'$.source_0') end
      ,case when get_json_object(big_data,'$.source_module') in ('p_video')
              then get_json_object(big_data,'$.source_0')
            when get_json_object(big_data,'$.source_0') in ('f_ai_tattoo') and get_json_object(big_data,'$.mids_category_id') = 'tattoo_custom_tag'
              then get_json_object(big_data,'$.mids_category_id')
            when get_json_object(big_data,'$.source_0') in ('f_hair_dye','f_ai_retouch','f_hairstyles','f_hair_enrich','f_makeup','f_ai_tattoo')
              then get_json_object(big_data,'$.mids_material_id')
        else get_json_object(big_data,'$.source_1') end

;

select
    base.pay_date
    ,base.id1
    ,trim(e.id2_part) as id2
    ,sum(base.ord_amt_usd / size(split(base.id2, ','))) as ord_amt_usd
from (
    select
        pay_date
        ,case when get_json_object(big_data,'$.source_module') in ('p_video')
                then 'video'
              else get_json_object(big_data,'$.source_0') end id1
        ,case when get_json_object(big_data,'$.source_module') in ('p_video')
                then get_json_object(big_data,'$.source_0')
              when get_json_object(big_data,'$.source_0') in ('f_ai_tattoo') and get_json_object(big_data,'$.mids_category_id') = 'tattoo_custom_tag'
                then get_json_object(big_data,'$.mids_category_id')
              when get_json_object(big_data,'$.source_0') in ('f_hair_dye','f_ai_retouch','f_hairstyles','f_hair_enrich','f_makeup','f_ai_tattoo')
                then get_json_object(big_data,'$.mids_material_id')
          else get_json_object(big_data,'$.source_1') end id2
        ,ord_amt_usd
    from stat_vip.paid_oda_all_order_summary
    where app_id_p IN (7329803307041000000)
        and pay_date between 20260701 and 20260708
        and is_subscribe='订阅'
        and product_sub_line = 'AirBrush'
        -- and get_json_object(big_data,'$.source_0') in ('f_ai_retouch','f_relight','f_adjust','f_hair_dye','f_body','f_eraser','f_hairstyles','f_face','f_hair_enrich','f_ai_tattoo','f_eraser','f_makeup','f_teeth')
) base
LATERAL VIEW explode(split(base.id2, ',')) e as id2_part
group by base.pay_date, base.id1, trim(e.id2_part)
